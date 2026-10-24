#!/usr/bin/env bash
# Usage: scripts/test.sh
#
# Tests check-version.sh, version.sh, and set-version.sh, the last two on a
# copy of the repository.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
failures=0

# Runs a command and checks its exit status and its standard output.
# Usage: check <name> <expected status> <expected output> <command...>
check() {
  local name="$1" want_status="$2" want_output="$3"
  shift 3
  local output status=0
  output="$("$@" 2> "$work/stderr")" || status=$?
  if [ "$status" -ne "$want_status" ] || [ "$output" != "$want_output" ]; then
    echo "FAIL: $name"
    echo "  status: $status, expected $want_status"
    echo "  output: $(printf '%q' "$output")"
    echo "  expected: $(printf '%q' "$want_output")"
    echo "  stderr: $(cat "$work/stderr")"
    failures=$((failures + 1))
  else
    echo "ok: $name"
  fi
}

check_version="$here/check-version.sh"
check "a release version is valid" 0 "" "$check_version" 1.2.3
check "a pre-release version is valid" 0 "" "$check_version" 1.2.3-rc.1
check "a version with build metadata is valid" 0 "" "$check_version" 1.2.3+build.5
check "a version with two parts is invalid" 1 "" "$check_version" 1.2
check "a version with a v is invalid" 1 "" "$check_version" v1.2.3
check "a version with a space is invalid" 1 "" "$check_version" "1.2.3 x"
check "a version with a quote is invalid" 1 "" "$check_version" '1.2.3"'
check "a version with a new line is invalid" 1 "" "$check_version" $'1.2.3\nx'
# shellcheck disable=SC2016 # The $( ) is the input, not to expand.
check "a version with a dollar sign is invalid" 1 "" "$check_version" '1.2.3$(id)'
check "an empty version is invalid" 1 "" "$check_version" ""

copy="$work/repo"
mkdir -p "$copy"
cp -R "$here/../scripts" "$here/../pyproject.toml" "$here/../README.md" "$copy/"
current="$("$here/version.sh")"
check "version.sh prints the pin" 0 "$current" "$copy/scripts/version.sh"
check "set-version.sh rejects an invalid version" 1 "" "$copy/scripts/set-version.sh" '1.2.3/x'
check "set-version.sh leaves the pin of a rejected version" 0 "$current" "$copy/scripts/version.sh"
check "set-version.sh pins a new version" 0 "" "$copy/scripts/set-version.sh" 9.8.7-rc.1
check "version.sh prints the new pin" 0 "9.8.7-rc.1" "$copy/scripts/version.sh"
check "set-version.sh changes every rev line of README.md" 0 $'    rev: v9.8.7-rc.1\n    rev: v9.8.7-rc.1' \
  grep -E '^ *rev:' "$copy/README.md"
check "set-version.sh changes nothing else" 0 \
  "$(grep -v -E '^ *rev:|^dependencies' "$here/../README.md" "$here/../pyproject.toml" | sed "s|$here/../||")" \
  sh -c "grep -v -E '^ *rev:|^dependencies' '$copy/README.md' '$copy/pyproject.toml' | sed 's|$copy/||'"

if [ "$failures" -ne 0 ]; then
  echo "$failures check(s) failed"
  exit 1
fi
