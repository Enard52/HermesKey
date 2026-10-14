# HermesKey

HermesKey is a Linux push-to-talk speech-to-text tool with:

- prewarmed `faster-whisper`
- toggle start/stop recording with one hotkey
- desktop overlay for **Recording** and **Transcribing**
- soft start/stop tones
- direct typing into the active app
- paste fallback for terminals
- `ydotoold` user service for Wayland typing

The name comes from **Hermes**, the Greek messenger god.

## Status

Built and tested on KDE Wayland.

## Repo layout

- `bin/ptt_stt_toggle.sh` — main hotkey target
- `bin/ptt_stt_server.py` — prewarmed whisper server over a Unix socket
- `bin/ptt_stt_overlay.py` — click-through overlay
- `systemd/user/ptt-stt.service` — prewarmed server service
- `systemd/user/ydotoold.service` — user-level ydotool daemon
- `install.sh` — installs scripts and services into the current user account

## Requirements

System packages you will usually want:

- `ffmpeg`
- `wl-clipboard`
- `libnotify` / `notify-send`
- `ydotool`
- `python3`
- `python3-pip`
- `qt6` / `PySide6` runtime support
- `qdbus` on KDE for app detection
- `paplay` for soft tones

Python packages:

```bash
pip install -r requirements.txt
```

A dedicated venv is recommended, for example:

```bash
python3 -m venv ~/venvs/stt
source ~/venvs/stt/bin/activate
pip install -U pip
pip install -r requirements.txt
```

## Install

From the repo root:

```bash
chmod +x install.sh
./install.sh
```

That installs to:

- `~/.local/bin/ptt_stt_toggle.sh`
- `~/.local/bin/ptt_stt_server.py`
- `~/.local/bin/ptt_stt_overlay.py`
- `~/.config/systemd/user/ptt-stt.service`
- `~/.config/systemd/user/ydotoold.service`

Then bind your desktop hotkey to:

```bash
~/.local/bin/ptt_stt_toggle.sh
```

## Default behavior

- press hotkey once → start recording
- press hotkey again → stop recording and transcribe
- transcript is copied to clipboard and typed into the active app
- terminal-like apps use paste fallback by default

## Configuration

HermesKey is configured through environment variables.

Common ones:

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

Restart the prewarmed server:

```bash
systemctl --user restart ptt-stt.service
```

Restart the typing daemon:

```bash
systemctl --user restart ydotoold.service
```

Check logs:

```bash
tail -f /tmp/ptt_stt_debug.log
journalctl --user -u ptt-stt.service -f
journalctl --user -u ydotoold.service -f
```

## Notes

- On KDE Wayland, `ydotoold` should run as a **user** service, not the root system service.
- If typing fails in some apps, clipboard copy remains as backup.
- If you want stricter window targeting, set `FOCUS_SAFE_MODE=1`.

## License

MIT
