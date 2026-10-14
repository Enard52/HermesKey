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
- `paplay` is typically provided by `pulseaudio-utils`.
- Package names vary slightly across distros; if a package name differs, install the nearest equivalent.

## Install HermesKey

### One-line installer

If your system dependencies are already installed, the bootstrap script will:

- download HermesKey
- create `~/venvs/stt` if needed
- install Python dependencies
- run the installer

#### Public repo

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

#### Private repo

If the repository is private, use authenticated `gh` access instead of the raw URL:

```bash
gh api repos/graygarbage/HermesKey/contents/scripts/bootstrap.sh?ref=main --jq .content | tr -d '\n' | base64 -d | bash
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

## Verify services

```bash
systemctl --user status hermeskey.service
systemctl --user status hermeskey-ydotoold.service
```

## Run the doctor

```bash
hermeskey-doctor
```
