# HermesKey

[![CI](https://img.shields.io/github/actions/workflow/status/graygarbage/HermesKey/ci.yml?branch=main&label=CI)](https://github.com/graygarbage/HermesKey/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Push-to-talk speech-to-text for Linux Wayland desktops.**

HermesKey gives you a single hotkey to start recording, stop recording, transcribe locally with a prewarmed Whisper model, and type the result back into the active app.

It was built for the workflow of:

- hold a thought
- hit one key
- speak
- hit the same key again
- keep typing without touching the mouse

## Why “HermesKey”?

**Hermes** is the messenger god in Greek mythology: fast, direct, and always delivering the message.

## Features

- **One-key toggle** for start/stop recording
- **Prewarmed `faster-whisper` server** for lower latency
- **On-screen overlay** for `Recording` and `Transcribing`
- **Soft audio cues** instead of harsh system beeps
- **Direct typing into the active app**
- **Clipboard backup** for safety
- **Paste fallback for terminals** and terminal-like apps
- **Wayland-friendly typing** via a **user-level `ydotoold`** service
- **Optional focus safety mode** if you want strict target-window matching
- **Simple config file** under `~/.config/hermeskey/`

## Current target environment

HermesKey is currently tuned for:

- **Linux**
- **Wayland**
- **KDE Plasma**
- **PipeWire / PulseAudio-compatible audio**

It may also work on other environments, but KDE Wayland is the primary tested target right now.

## Architecture

HermesKey is split into three parts:

1. `bin/hermeskey`  
   Main toggle script. Starts/stops recording, talks to the STT server, manages overlay, typing, tones, and clipboard fallback.

2. `bin/hermeskey-server.py`  
   Long-lived local `faster-whisper` server over a Unix domain socket.

3. `bin/hermeskey-overlay.py`  
   Small click-through, non-focusable overlay window for desktop status.

Systemd user services keep the whisper server and `ydotoold` daemon ready.

More detail:

- [docs/INSTALL.md](docs/INSTALL.md)
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

## Quick start

### 1. Install system dependencies

Typical dependencies:

- `ffmpeg`
- `wl-clipboard`
- `libnotify` / `notify-send`
- `ydotool`
- `python3`
- `python3-pip`
- `python3-venv`
- `PySide6` runtime support
- `qdbus` on KDE
- `paplay`

See [docs/INSTALL.md](docs/INSTALL.md) for a more detailed setup guide.

### 2. Create a Python environment

```bash
python3 -m venv ~/venvs/stt
source ~/venvs/stt/bin/activate
pip install -U pip
pip install -r requirements.txt
```

### 3. Install HermesKey

```bash
chmod +x install.sh
./install.sh
```

### 4. Bind your hotkey

Bind your desktop shortcut to:

```bash
~/.local/bin/hermeskey
```

### 5. Speak

- press hotkey once → recording starts
- press hotkey again → recording stops and transcribes
- transcript is copied to clipboard and typed into the active app

## Installation details

`install.sh` installs:

- `~/.local/bin/hermeskey`
- `~/.local/bin/hermeskey-server.py`
- `~/.local/bin/hermeskey-overlay.py`
- `~/.config/systemd/user/hermeskey.service`
- `~/.config/systemd/user/hermeskey-ydotoold.service`
- `~/.config/hermeskey/hermeskey.env`
- `~/.config/hermeskey/hermeskey.env.example`

It also creates backward-compatible symlinks for the earlier `ptt_stt_*` script names.

## Configuration

HermesKey reads config from:

```bash
~/.config/hermeskey/hermeskey.env
```

Example config is shipped at:

```bash
~/.config/hermeskey/hermeskey.env.example
```

Common settings:

```bash
MODEL=medium
STT_LANG=en
RECORD_SOURCE=alsa_input.usb-Beyerdynamic_FOX_5.00-00.mono-fallback
INSERT_MODE=type
COPY_TO_CLIPBOARD=1
OVERLAY_ENABLED=1
SOUND_ENABLED=1
FOCUS_SAFE_MODE=0
```

Sound tuning:

```bash
START_TONE_HZ=660
STOP_TONE_HZ=520
TONE_DURATION=0.035
TONE_VOLUME=0.20
```

Typing/paste behavior:

```bash
TYPE_BACKEND=auto
PASTE_SHORTCUT=auto
TERMINAL_APPS=org.wezfurlong.wezterm,org.kde.konsole,kitty,Alacritty,ghostty,foot,gnome-terminal,tilix,xfce4-terminal
PASTE_FOR_APPS=$TERMINAL_APPS
```

## Services

Restart the whisper server:

```bash
systemctl --user restart hermeskey.service
```

Restart the typing daemon:

```bash
systemctl --user restart hermeskey-ydotoold.service
```

Check service status:

```bash
systemctl --user status hermeskey.service
systemctl --user status hermeskey-ydotoold.service
```

## Logs

```bash
tail -f /tmp/hermeskey.log
journalctl --user -u hermeskey.service -f
journalctl --user -u hermeskey-ydotoold.service -f
```

## Troubleshooting

### `ydotool` is installed but typing does not work

Make sure the **user** daemon is running:

```bash
systemctl --user status hermeskey-ydotoold.service
```

On KDE Wayland, HermesKey expects a user-owned socket under:

```bash
/run/user/$UID/.ydotool_socket
```

### The server is not responding

Check:

```bash
systemctl --user status hermeskey.service
journalctl --user -u hermeskey.service -n 100 --no-pager
```

### The overlay is annoying or you want a quieter setup

Disable overlay:

```bash
OVERLAY_ENABLED=0
```

Disable sound:

```bash
SOUND_ENABLED=0
```

### I want stricter insertion safety

Enable focus-safe mode:

```bash
FOCUS_SAFE_MODE=1
```

That makes HermesKey verify the target window before typing.

## Development

Lint and syntax-check locally:

```bash
bash -n bin/hermeskey install.sh uninstall.sh
python3 -m py_compile bin/hermeskey-server.py bin/hermeskey-overlay.py
```

## Roadmap

- packaged releases for common distros
- per-app config beyond env vars
- richer overlay styling
- optional direct GUI settings
- better compositor detection outside KDE

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
