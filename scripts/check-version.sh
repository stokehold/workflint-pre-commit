#!/usr/bin/env bash
# Usage: scripts/check-version.sh <version>
#
# Fails unless <version> looks like a workflint version. The workflows run it
# on every version that comes from an event, an input, or PyPI before they use
# the version anywhere else.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: scripts/check-version.sh <version>" >&2
  exit 2
fi
if ! [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+([a-z0-9.+-]*)?$ ]]; then
  echo "not a workflint version: $(printf '%q' "$1")" >&2
  exit 1
fi
