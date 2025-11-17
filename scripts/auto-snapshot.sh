#!/usr/bin/env bash
set -euo pipefail

# Create a snapshot tag once per hour if there are changes.
MSG=${1:-"auto snapshot"}

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository" >&2
  exit 0
fi

if [[ -n "$(git status --porcelain)" ]]; then
  ./scripts/snapshot.sh "$MSG"
else
  echo "No changes; skipping auto snapshot"
fi

