#!/usr/bin/env bash
# Usage: scripts/pypi-wheels.sh <version>
#
# Prints true when PyPI has workflint <version> with at least one platform
# wheel, and false otherwise. workflint 0.0.1 on PyPI is a placeholder with a
# pure Python wheel and no binary, so a version without platform wheels is
# never pinned, tested, or tagged.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/pypi-wheels.sh <version>" >&2
  exit 2
fi
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
version="$1"
"$here/check-version.sh" "$version"

status=0
json="$(curl -fsSL --retry 3 "https://pypi.org/pypi/workflint/$version/json")" || status=$?
# curl exits with 22 on an HTTP error, such as the 404 of a missing version.
if [ "$status" -eq 22 ]; then
  echo false
  exit 0
elif [ "$status" -ne 0 ]; then
  exit "$status"
fi
jq -r '[.urls[] | select(.packagetype == "bdist_wheel" and (.filename | endswith("-none-any.whl") | not))]
  | if length > 0 then "true" else "false" end' <<< "$json"
