#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DEST="$HOME/.local/bin"
SYSTEMD_DEST="$HOME/.config/systemd/user"

mkdir -p "$BIN_DEST" "$SYSTEMD_DEST"
install -m 0755 "$ROOT/bin/ptt_stt_toggle.sh" "$BIN_DEST/ptt_stt_toggle.sh"
install -m 0755 "$ROOT/bin/ptt_stt_server.py" "$BIN_DEST/ptt_stt_server.py"
install -m 0755 "$ROOT/bin/ptt_stt_overlay.py" "$BIN_DEST/ptt_stt_overlay.py"
install -m 0644 "$ROOT/systemd/user/ptt-stt.service" "$SYSTEMD_DEST/ptt-stt.service"
install -m 0644 "$ROOT/systemd/user/ydotoold.service" "$SYSTEMD_DEST/ydotoold.service"

systemctl --user daemon-reload
systemctl --user enable --now ydotoold.service
systemctl --user enable --now ptt-stt.service

echo "Installed to $BIN_DEST"
echo "Bind your hotkey to: $BIN_DEST/ptt_stt_toggle.sh"
