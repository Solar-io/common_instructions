#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs/SESSION_LOGS"
TEMPLATE="$DOCS_DIR/SESSION_TEMPLATE.md"

DATE_STR="$(date +%F)"
TIME_STR="$(date +%H:%M)"
TARGET="$DOCS_DIR/$DATE_STR.md"

mkdir -p "$DOCS_DIR"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

if [[ -f "$TARGET" ]]; then
  echo "Session file already exists: $TARGET" >&2
  exit 0
fi

sed "s/YYYY-MM-DD/$DATE_STR/g; s/HH:MM/$TIME_STR/g" "$TEMPLATE" > "$TARGET"
echo "Created $TARGET"

