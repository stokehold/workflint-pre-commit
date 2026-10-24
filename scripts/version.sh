#!/usr/bin/env bash
# Usage: scripts/version.sh
#
# Prints the workflint version that pyproject.toml pins.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(sed -n 's/^dependencies = \["workflint==\([^"]*\)"\]$/\1/p' "$root/pyproject.toml")"
if [ -z "$version" ]; then
  echo "pyproject.toml has no line dependencies = [\"workflint==<version>\"]" >&2
  exit 1
fi
echo "$version"
