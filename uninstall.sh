#!/usr/bin/env bash
set -euo pipefail

BIN_DEST="$HOME/.local/bin"
SYSTEMD_DEST="$HOME/.config/systemd/user"
DATA_DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/hermeskey"

systemctl --user disable --now hermeskey.service >/dev/null 2>&1 || true
systemctl --user disable --now hermeskey-ydotoold.service >/dev/null 2>&1 || true

rm -f \
  "$BIN_DEST/hermeskey" \
  "$BIN_DEST/hermeskey-server.py" \
  "$BIN_DEST/hermeskey-overlay.py" \
  "$BIN_DEST/hermeskey-doctor" \
  "$BIN_DEST/ptt_stt_toggle.sh" \
  "$BIN_DEST/ptt_stt_server.py" \
  "$BIN_DEST/ptt_stt_overlay.py" \
  "$SYSTEMD_DEST/hermeskey.service" \
  "$SYSTEMD_DEST/hermeskey-ydotoold.service" \
  "$DATA_DEST_DIR/VERSION"

systemctl --user daemon-reload

echo "HermesKey uninstalled. Config files in ~/.config/hermeskey were left untouched."
