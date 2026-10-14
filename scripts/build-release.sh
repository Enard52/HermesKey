#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
DIST="$ROOT/dist"
NAME="hermeskey-$VERSION"
ARCHIVE="$DIST/$NAME.tar.gz"

mkdir -p "$DIST"
rm -f "$ARCHIVE"

tar \
  --exclude='.git' \
  --exclude='dist' \
  --exclude='bin/__pycache__' \
  -C "$ROOT" \
  -czf "$ARCHIVE" \
  .

echo "$ARCHIVE"
