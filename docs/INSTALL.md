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
  python3-qt6 \
  qt6-qtwayland \
  plasma-workspace \
  pulseaudio-utils
```

Notes:

- `qdbus` normally comes from the KDE/Qt desktop stack.
- `paplay` is typically provided by `pulseaudio-utils`.

## Python environment

```bash
python3 -m venv ~/venvs/stt
source ~/venvs/stt/bin/activate
pip install -U pip
pip install -r requirements.txt
```

## Install HermesKey

### One-line installer

After system dependencies and the Python environment are ready:

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash
```

To install from the current `main` branch instead of the latest release:

```bash
curl -fsSL https://raw.githubusercontent.com/graygarbage/HermesKey/main/scripts/bootstrap.sh | bash -s -- --main
```

### Manual install

```bash
./install.sh
```

## Bind the hotkey

Set your desktop shortcut target to:

```bash
~/.local/bin/hermeskey
```

## Verify services

```bash
systemctl --user status hermeskey.service
systemctl --user status hermeskey-ydotoold.service
```

## Run the doctor

```bash
hermeskey-doctor
```
