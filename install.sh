#!/usr/bin/env bash
set -euo pipefail

APP_ID="hermeskey"
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DEST="$HOME/.local/bin"
SYSTEMD_DEST="$HOME/.config/systemd/user"
CONFIG_DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$APP_ID"
CONFIG_DEST="$CONFIG_DEST_DIR/hermeskey.env"
CONFIG_EXAMPLE_DEST="$CONFIG_DEST_DIR/hermeskey.env.example"

mkdir -p "$BIN_DEST" "$SYSTEMD_DEST" "$CONFIG_DEST_DIR"

install -m 0755 "$ROOT/bin/hermeskey" "$BIN_DEST/hermeskey"
install -m 0755 "$ROOT/bin/hermeskey-server.py" "$BIN_DEST/hermeskey-server.py"
install -m 0755 "$ROOT/bin/hermeskey-overlay.py" "$BIN_DEST/hermeskey-overlay.py"
install -m 0644 "$ROOT/systemd/user/hermeskey.service" "$SYSTEMD_DEST/hermeskey.service"
install -m 0644 "$ROOT/systemd/user/hermeskey-ydotoold.service" "$SYSTEMD_DEST/hermeskey-ydotoold.service"
install -m 0644 "$ROOT/config/hermeskey.env.example" "$CONFIG_EXAMPLE_DEST"

if [[ ! -f "$CONFIG_DEST" ]]; then
  install -m 0644 "$ROOT/config/hermeskey.env.example" "$CONFIG_DEST"
fi

ln -sfn "$BIN_DEST/hermeskey" "$BIN_DEST/ptt_stt_toggle.sh"
ln -sfn "$BIN_DEST/hermeskey-server.py" "$BIN_DEST/ptt_stt_server.py"
ln -sfn "$BIN_DEST/hermeskey-overlay.py" "$BIN_DEST/ptt_stt_overlay.py"

if systemctl --user list-unit-files | grep -q '^ptt-stt.service'; then
  systemctl --user disable --now ptt-stt.service >/dev/null 2>&1 || true
fi
if systemctl --user list-unit-files | grep -q '^ydotoold.service'; then
  systemctl --user disable --now ydotoold.service >/dev/null 2>&1 || true
fi

systemctl --user daemon-reload
systemctl --user enable --now hermeskey-ydotoold.service
systemctl --user enable --now hermeskey.service

echo
printf 'HermesKey installed.\n\n'
printf 'Main command: %s\n' "$BIN_DEST/hermeskey"
printf 'Config file:   %s\n' "$CONFIG_DEST"
printf 'Hotkey target: %s\n\n' "$BIN_DEST/hermeskey"
printf 'Suggested next steps:\n'
printf '  1. Activate your Python venv if needed.\n'
printf '  2. Edit %s\n' "$CONFIG_DEST"
printf '  3. Bind your desktop hotkey to: %s\n' "$BIN_DEST/hermeskey"
printf '  4. Restart the service after config changes: systemctl --user restart hermeskey.service\n'
