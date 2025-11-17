#!/usr/bin/env bash
set -euo pipefail

VERSION=${1:-}
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <x.y.z> [summary]" >&2
  exit 1
fi

SUMMARY=${2:-"release $VERSION"}

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository" >&2
  exit 1
fi

# Ensure key docs updated recently (best-effort)
if ! git diff --name-only HEAD~10..HEAD | grep -E "docs/(PROJECT_STATUS|TASKS).md" >/dev/null 2>&1; then
  echo "Warning: PROJECT_STATUS or TASKS not updated in recent commits." >&2
fi

TAG="v$VERSION"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists: $TAG" >&2
  exit 1
fi

./scripts/snapshot.sh "pre-release $TAG" || true
git tag -a "$TAG" -m "$TAG — $SUMMARY"
echo "Created release tag $TAG"

