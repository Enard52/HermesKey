# Architecture

HermesKey has three runtime layers:

## 1. Hotkey entrypoint

`bin/hermeskey`

Responsibilities:

- toggle start/stop recording
- play soft audio cues
- show/hide overlay
- capture audio with `ffmpeg`
- send audio to the local STT server
- copy text to clipboard
- type or paste into the active app

This layer is intentionally a shell script because it is easy to debug in a live desktop environment.

## 2. Speech server

`bin/hermeskey-server.py`

Responsibilities:

- load `faster-whisper` once
- stay resident in memory
- serve transcription requests over a Unix domain socket

This avoids paying model startup cost on every dictation.

## 3. Overlay process

`bin/hermeskey-overlay.py`

Responsibilities:

- show a small visual status chip
- remain click-through
- avoid focus stealing

## Supporting services

### `hermeskey.service`

Keeps the speech model warm.

### `hermeskey-ydotoold.service`

Runs `ydotoold` as a **user service**, which is important for Wayland typing workflows.

## Design principles

- local-first
- fast startup
- minimal dependencies
- focus-safe behavior by default where practical
- no mandatory mouse interaction
