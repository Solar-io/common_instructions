#!/usr/bin/env bash
set -euo pipefail

ts() { date +%F-%H%M; }

# Ensure we are in a git repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository. Initialize with 'git init' first." >&2
  exit 1
fi

CHANGES=$(git status --porcelain)
if [[ -z "$CHANGES" ]]; then
  echo "No changes to snapshot. Skipping commit."
else
  SUMMARY=${1:-"session snapshot"}
  git add -A
  git commit -m "session: $(date '+%F %R') — ${SUMMARY}"
fi

TAG="snapshot/$(ts)"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists: $TAG" >&2
  exit 0
fi

git tag -a "$TAG" -m "Session snapshot $TAG"
echo "Created tag $TAG"

