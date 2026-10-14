#!/usr/bin/env bash
set -euo pipefail

REPO="graygarbage/HermesKey"
API_URL="https://api.github.com/repos/$REPO/releases/latest"
MAIN_TARBALL_URL="https://github.com/$REPO/archive/refs/heads/main.tar.gz"
CHANNEL="release"

for arg in "$@"; do
  case "$arg" in
    --main)
      CHANNEL="main"
      ;;
    *)
      printf 'Unknown argument: %s\n' "$arg" >&2
      exit 1
      ;;
  esac
done

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  }
}

need_cmd bash
need_cmd curl
need_cmd tar
need_cmd mktemp

latest_asset_url() {
  local json
  json="$(curl -fsSL "$API_URL")"

  if command -v python3 >/dev/null 2>&1; then
    RELEASE_JSON="$json" python3 - <<'PY'
import json
import os

payload = json.loads(os.environ['RELEASE_JSON'])
for asset in payload.get('assets', []):
    url = asset.get('browser_download_url', '')
    if url.endswith('.tar.gz') and 'hermeskey-' in url:
        print(url)
        raise SystemExit(0)
raise SystemExit(1)
PY
    return 0
  fi

  printf '%s\n' "$json" | grep -Eo 'https://[^[:space:]"]+hermeskey-[^"]+\.tar\.gz' | head -n1
}

download_url() {
  if [[ "$CHANNEL" == "main" ]]; then
    printf '%s\n' "$MAIN_TARBALL_URL"
    return 0
  fi

  latest_asset_url
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ARCHIVE_URL="$(download_url)"
ARCHIVE_PATH="$TMP_DIR/hermeskey.tar.gz"
EXTRACT_DIR="$TMP_DIR/extract"

printf 'Downloading HermesKey from: %s\n' "$ARCHIVE_URL"
curl -fsSL "$ARCHIVE_URL" -o "$ARCHIVE_PATH"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR"

if [[ -f "$EXTRACT_DIR/install.sh" ]]; then
  ROOT="$EXTRACT_DIR"
else
  ROOT="$(find "$EXTRACT_DIR" -mindepth 1 -maxdepth 1 -type d | head -n1)"
fi

if [[ -z "${ROOT:-}" || ! -f "$ROOT/install.sh" ]]; then
  printf 'Could not find install.sh in extracted archive.\n' >&2
  exit 1
fi

chmod +x "$ROOT/install.sh"
exec bash "$ROOT/install.sh"
