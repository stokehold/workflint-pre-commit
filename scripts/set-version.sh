#!/usr/bin/env bash
# Usage: scripts/set-version.sh <version>
#
# Pins workflint <version> in pyproject.toml and writes `rev: v<version>` in
# README.md.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/set-version.sh <version>" >&2
  exit 2
fi
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/.." && pwd)"
version="$1"
"$here/check-version.sh" "$version"

# Rewrites the lines of <file> that match <pattern> with <replacement>, and
# fails when no line matches.
# Usage: rewrite <file> <pattern> <replacement>
rewrite() {
  local file="$1" pattern="$2" replacement="$3"
  if ! grep -q -E "$pattern" "$file"; then
    echo "$file has no line that matches $pattern" >&2
    exit 1
  fi
  sed -E "s/$pattern/$replacement/" "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

rewrite "$root/pyproject.toml" '^dependencies = \["workflint==[^"]*"\]$' "dependencies = [\"workflint==$version\"]"
rewrite "$root/README.md" '^( *)rev: v[^ ]*$' "\\1rev: v$version"
