# Configuration

HermesKey reads configuration from:

```bash
~/.config/hermeskey/hermeskey.env
```

The installer copies a starter file there on first install.

## Core settings

```bash
MODEL=medium
STT_LANG=en
RECORD_SOURCE=alsa_input.usb-Beyerdynamic_FOX_5.00-00.mono-fallback
```

- `MODEL`: any supported `faster-whisper` model name
- `STT_LANG`: spoken language code; set empty for auto-detect
- `RECORD_SOURCE`: microphone source from `pactl list short sources`

## Insertion behavior

```bash
INSERT_MODE=type
COPY_TO_CLIPBOARD=1
TYPE_BACKEND=auto
```

- `INSERT_MODE=type` types into the active app
- `INSERT_MODE=clipboard` only copies to clipboard
- `COPY_TO_CLIPBOARD=1` keeps a backup copy even when typing succeeds
- `TYPE_BACKEND` may be `auto`, `ydotool`, `wtype`, or `xdotool`

## Overlay and sound

```bash
OVERLAY_ENABLED=1
SOUND_ENABLED=1
START_TONE_HZ=660
STOP_TONE_HZ=520
TONE_DURATION=0.035
TONE_VOLUME=0.20
```

## Focus safety

```bash
FOCUS_SAFE_MODE=0
```

If enabled, HermesKey tries to verify that focus is still on the original target window before insertion.

## Paste fallback

```bash
TERMINAL_APPS=org.wezfurlong.wezterm,org.kde.konsole,kitty,Alacritty,ghostty,foot,gnome-terminal,tilix,xfce4-terminal
PASTE_FOR_APPS=$TERMINAL_APPS
PASTE_SHORTCUT=auto
```

- `PASTE_FOR_APPS` is a comma-separated pattern list
- `PASTE_SHORTCUT=auto` picks `Ctrl+Shift+V` for terminal-like apps and `Ctrl+V` elsewhere

## Runtime overrides

All settings can also be overridden via environment variables at launch time.
