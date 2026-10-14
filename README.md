# HermesKey

<p align="center"><strong>Push-to-talk speech-to-text for Linux Wayland desktops.</strong></p>

<p align="center">
  <a href="https://github.com/graygarbage/HermesKey/actions/workflows/ci.yml"><img alt="CI" src="https://github.com/graygarbage/HermesKey/actions/workflows/ci.yml/badge.svg?branch=main"></a>
  <a href="https://github.com/graygarbage/HermesKey/releases"><img alt="Release" src="https://img.shields.io/github/v/release/graygarbage/HermesKey?display_name=tag"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-Linux%20Wayland-0f172a">
  <img alt="Desktop" src="https://img.shields.io/badge/tuned%20for-KDE%20Plasma-1d4ed8">
</p>

HermesKey is a local-first dictation tool for people who want voice input to feel native on the desktop instead of bolted on.

Press your hotkey once to start recording. Press it again to stop. HermesKey transcribes locally with a prewarmed Whisper model and sends the text back into the app you were already using.

## Install in 60 seconds

| Step | Command |
| --- | --- |
| Install Linux packages | See distro blocks in [Quick start](#quick-start) |
| Run the bootstrap installer | `curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh \| bash` |
| Bind your hotkey | `~/.local/bin/hermeskey` |
| Verify the setup | `hermeskey-doctor` |

### Quick install by distro

| Distro | Install packages |
| --- | --- |
| Fedora / Nobara | `sudo dnf install ffmpeg wl-clipboard libnotify ydotool python3 python3-pip python3-virtualenv python3-qt6 qt6-qtwayland plasma-workspace pulseaudio-utils` |
| Arch / EndeavourOS | `sudo pacman -S --needed ffmpeg wl-clipboard libnotify ydotool python python-pip python-virtualenv pyside6 qt6-wayland plasma-workspace libpulse` |
| Ubuntu / Debian | `sudo apt-get update && sudo apt-get install -y ffmpeg wl-clipboard libnotify-bin ydotool python3 python3-pip python3-venv python3-pyside6.qtcore python3-pyside6.qtgui python3-pyside6.qtwidgets qt6-wayland pulseaudio-utils` |

**Release install**

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash
```

**Install from `main`**

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash -s -- --main
```

## Why HermesKey

- one-key start/stop workflow
- prewarmed `faster-whisper` for lower latency
- direct typing into the active app
- clipboard backup when typing is unreliable
- paste fallback for terminals and terminal-like apps
- click-through overlay for `Recording` and `Transcribing`
- soft audio cues instead of harsh beeps
- Wayland-friendly typing through a user-owned `ydotoold` service
- built-in diagnostics with `hermeskey-doctor`

## Current target environment

HermesKey is primarily tuned for:

- Linux
- Wayland
- KDE Plasma
- PipeWire / PulseAudio-compatible audio

It may work elsewhere, but KDE Wayland is the first-class target right now.

## Quick start

### Fast path

If your system dependencies are already installed, the bootstrap script will:

- download HermesKey
- create `~/venvs/stt` if needed
- install Python dependencies
- install the HermesKey scripts and user services

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash
```

To install directly from the current `main` branch instead of the latest tagged release:

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash -s -- --main
```

### 1. Install system dependencies

#### Fedora / Nobara

```bash
sudo dnf install \
  ffmpeg \
  wl-clipboard \
  libnotify \
  ydotool \
  python3 \
  python3-pip \
  python3-virtualenv \
  python3-qt6 \
  qt6-qtwayland \
  plasma-workspace \
  pulseaudio-utils
```

#### Arch / EndeavourOS

```bash
sudo pacman -S --needed \
  ffmpeg \
  wl-clipboard \
  libnotify \
  ydotool \
  python \
  python-pip \
  python-virtualenv \
  pyside6 \
  qt6-wayland \
  plasma-workspace \
  libpulse
```

#### Ubuntu / Debian

```bash
sudo apt-get update
sudo apt-get install -y \
  ffmpeg \
  wl-clipboard \
  libnotify-bin \
  ydotool \
  python3 \
  python3-pip \
  python3-venv \
  python3-pyside6.qtcore \
  python3-pyside6.qtgui \
  python3-pyside6.qtwidgets \
  qt6-wayland \
  pulseaudio-utils
```

See [docs/INSTALL.md](docs/INSTALL.md) for notes and troubleshooting.

### 2. Install HermesKey

#### One-line installer

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash
```

#### Manual path

```bash
python3 -m venv ~/venvs/stt
source ~/venvs/stt/bin/activate
pip install -U pip
pip install -r requirements.txt
chmod +x install.sh
./install.sh
```

### 3. Bind your hotkey

Point your desktop shortcut at:

```bash
~/.local/bin/hermeskey
```

For a KDE walkthrough, see [docs/HOTKEYS.md](docs/HOTKEYS.md).

### 4. Dictate

- press once to start recording
- press again to stop and transcribe
- HermesKey copies to clipboard and types into the active app

## CLI

HermesKey also behaves like a proper command:

```bash
hermeskey --help
hermeskey --version
hermeskey --status
hermeskey --doctor
```

## Desktop integration

The installer also drops a few desktop launchers into your local applications menu:

- **HermesKey Control Center**
- **HermesKey Status**
- **HermesKey Doctor**
- **HermesKey Logs**
- **HermesKey Config**

These are helpers for inspection and support. For actual dictation, keep binding your shortcut directly to:

```bash
~/.local/bin/hermeskey
```

More detail:
- [docs/DESKTOP-INTEGRATION.md](docs/DESKTOP-INTEGRATION.md)
- [docs/HOTKEYS.md](docs/HOTKEYS.md)

## How it works

HermesKey is intentionally small and inspectable.

### `bin/hermeskey`
The main hotkey entrypoint.

It handles:
- audio capture
- overlay control
- soft tones
- server communication
- clipboard backup
- typing and paste fallback

### `bin/hermeskey-server.py`
A long-lived local transcription server over a Unix domain socket.

This is the piece that keeps Whisper warm so you do not pay model startup cost on every dictation.

### `bin/hermeskey-overlay.py`
A minimal overlay process designed to be:
- non-focusable
- click-through
- visually clear

See also:
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- [docs/FAQ.md](docs/FAQ.md)
- [docs/RELEASING.md](docs/RELEASING.md)
- [docs/PACKAGING.md](docs/PACKAGING.md)
- [docs/DESKTOP-INTEGRATION.md](docs/DESKTOP-INTEGRATION.md)

## Installed files

`install.sh` installs:

- `~/.local/bin/hermeskey`
- `~/.local/bin/hermeskey-server.py`
- `~/.local/bin/hermeskey-overlay.py`
- `~/.local/bin/hermeskey-doctor`
- `~/.local/bin/hermeskey-desktop-status`
- `~/.local/bin/hermeskey-desktop-doctor`
- `~/.local/bin/hermeskey-open-config`
- `~/.local/bin/hermeskey-open-logs`
- `~/.local/bin/hermeskey-restart-services`
- `~/.local/bin/hermeskey-control-center`
- `~/.local/share/applications/hermeskey-status.desktop`
- `~/.local/share/applications/hermeskey-doctor.desktop`
- `~/.local/share/applications/hermeskey-config.desktop`
- `~/.local/share/applications/hermeskey-logs.desktop`
- `~/.local/share/applications/hermeskey-control-center.desktop`
- `~/.local/share/metainfo/hermeskey.metainfo.xml`
- `~/.config/systemd/user/hermeskey.service`
- `~/.config/systemd/user/hermeskey-ydotoold.service`
- `~/.config/hermeskey/hermeskey.env`
- `~/.config/hermeskey/hermeskey.env.example`

For migration convenience, it also creates compatibility symlinks for the earlier `ptt_stt_*` names.

## Configuration

HermesKey reads config from:

```bash
~/.config/hermeskey/hermeskey.env
```

Example:

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

Typing and paste behavior:

```bash
TYPE_BACKEND=auto
PASTE_SHORTCUT=auto
TERMINAL_APPS=org.wezfurlong.wezterm,org.kde.konsole,kitty,Alacritty,ghostty,foot,gnome-terminal,tilix,xfce4-terminal
PASTE_FOR_APPS=$TERMINAL_APPS
```

More detail:
- [docs/CONFIGURATION.md](docs/CONFIGURATION.md)
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Operations

### Services

Restart the transcription server:

```bash
systemctl --user restart hermeskey.service
```

Restart the typing daemon:

```bash
systemctl --user restart hermeskey-ydotoold.service
```

Check status:

```bash
systemctl --user status hermeskey.service
systemctl --user status hermeskey-ydotoold.service
```

### Doctor

Run a quick environment and service audit:

```bash
hermeskey-doctor
```

This checks core commands, services, sockets, and audio sources.

### Logs

```bash
tail -f /tmp/hermeskey.log
journalctl --user -u hermeskey.service -f
journalctl --user -u hermeskey-ydotoold.service -f
```

## Development

Run the standard checks:

```bash
make check
```

Or manually:

```bash
bash -n bin/hermeskey install.sh uninstall.sh
python3 -m py_compile bin/hermeskey-server.py bin/hermeskey-overlay.py
```

Build a release tarball:

```bash
make package
```

Cut a release tag using the helper script:

```bash
./scripts/release.sh
```

## Distribution roadmap

- RPM / COPR path for Fedora-family systems
- AUR packaging once the install path settles further
- better distro-native installation beyond bootstrap-from-source

See [docs/PACKAGING.md](docs/PACKAGING.md).

## Roadmap

- richer per-app configuration
- improved compositor detection outside KDE
- optional GUI configuration surface
- cleaner branding and demo media

## Contributing

PRs, bug reports, and focused improvements are welcome.

Read:
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [SUPPORT.md](SUPPORT.md)

## License

MIT — see [LICENSE](LICENSE).
