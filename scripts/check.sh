#!/usr/bin/env bash
set -euo pipefail

bash -n bin/hermeskey bin/hermeskey-doctor bin/hermeskey-desktop-status bin/hermeskey-desktop-doctor bin/hermeskey-open-config install.sh uninstall.sh scripts/check.sh scripts/build-release.sh scripts/bootstrap.sh scripts/release.sh
python3 -m py_compile bin/hermeskey-server.py bin/hermeskey-overlay.py
systemd-analyze --user verify systemd/user/hermeskey.service systemd/user/hermeskey-ydotoold.service

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck bin/hermeskey bin/hermeskey-doctor bin/hermeskey-desktop-status bin/hermeskey-desktop-doctor bin/hermeskey-open-config install.sh uninstall.sh scripts/check.sh scripts/build-release.sh scripts/bootstrap.sh scripts/release.sh
else
  echo 'shellcheck not installed; skipping'
fi

echo 'All checks passed.'
