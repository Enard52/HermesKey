# Packaging direction

HermesKey currently installs well from source with a bootstrap script, but the long-term goal is to make installation feel native on major Linux distributions.

## Priorities

### 1. Fedora / Nobara / RPM-based path

This is the most natural first packaging target because HermesKey is already tuned for KDE Plasma Wayland on Fedora-like systems.

Potential routes:

- COPR repository
- standalone RPM release artifacts
- distro package submission later if the project stabilizes enough

## 2. Arch / AUR

HermesKey is script-heavy and user-service based, so an AUR package is a good fit once the install path stabilizes.

## 3. Debian / Ubuntu packaging

Possible later, but not the first target.

## Packaging challenges

- Python dependencies must be available or vendored cleanly
- the tool depends on desktop runtime pieces like `ydotool`, `ffmpeg`, and `wl-clipboard`
- Wayland typing support varies across environments
- user-level systemd services are part of the installation story

## Current state

This repository includes early packaging scaffolding:

- `packaging/rpm/hermeskey.spec`
- `packaging/aur/PKGBUILD`
- desktop launcher templates under `desktop/`
- AppStream metadata: `desktop/hermeskey.metainfo.xml`

These are starting points, not guaranteed production-ready packages.
