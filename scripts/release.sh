#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VERSION="$(tr -d '[:space:]' < VERSION)"
TAG="v$VERSION"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is not clean. Commit or stash changes before releasing." >&2
  exit 1
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG" >&2
  exit 1
fi

if git ls-remote --tags origin "$TAG" | grep -q "$TAG"; then
  echo "Tag already exists on origin: $TAG" >&2
  exit 1
fi

echo "Creating release tag: $TAG"
git tag "$TAG"
git push origin main
git push origin "$TAG"

echo
echo "Release submitted. Watch GitHub Actions for the published artifact:"
echo "  gh run list -R graygarbage/HermesKey --limit 10"
