# Installation

## Recommended target

HermesKey is currently best on KDE Plasma Wayland with PipeWire.

## System packages

### Fedora / Nobara

```bash
sudo dnf install \
  ffmpeg \
  wl-clipboard \
  libnotify \
  ydotool \
  python3 \
  python3-pip \
  python3-virtualenv \
  python3-pyside6 \
  qt6-qtwayland \
  plasma-workspace \
  pulseaudio-utils
```

### Arch / EndeavourOS

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

### Ubuntu / Debian

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

Notes:

- `qdbus` normally comes from the KDE/Qt desktop stack.
- Optional: `kdotool` for active window detection. Without it, HermesKey uses a built-in KWin script that needs `python3-dbus` and `python3-gobject`.
- `paplay` is typically provided by `pulseaudio-utils`.
- Package names vary slightly across distros; if a package name differs, install the nearest equivalent.

## Install HermesKey

### One-line installer

If your system dependencies are already installed, the bootstrap script will:

- download HermesKey
- create `~/venvs/stt` if needed
- install Python dependencies
- run the installer

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash
```

To install from the current `main` branch instead of the latest release:

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash -s -- --main
```

To skip Python environment setup because you are managing it yourself:

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash -s -- --skip-venv
```

### Manual install

```bash
python3 -m venv ~/venvs/stt
source ~/venvs/stt/bin/activate
pip install -U pip
pip install -r requirements.txt
./install.sh
```

## Bind the hotkey

Set your desktop shortcut target to:

```bash
~/.local/bin/hermeskey
```

For a KDE walkthrough, see [HOTKEYS.md](HOTKEYS.md).

## Verify services

```bash
systemctl --user status hermeskey.service
systemctl --user status hermeskey-ydotoold.service
```

## Desktop launchers

The installer also adds local desktop launchers for:

- HermesKey Control Center
- HermesKey Status
- HermesKey Doctor
- HermesKey Logs
- HermesKey Config

For actual dictation, keep binding your hotkey to:

```bash
~/.local/bin/hermeskey
```

## Run the doctor

```bash
hermeskey-doctor
```
