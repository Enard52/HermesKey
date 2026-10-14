# Contributing to HermesKey

Thanks for your interest in improving HermesKey.

## Ground rules

- Keep the hotkey workflow fast.
- Avoid changes that steal focus or require mouse interaction.
- Prefer local-first behavior.
- Be conservative about Wayland typing changes.

## Development setup

```bash
git clone https://github.com/graygarbage/HermesKey.git
cd HermesKey
python3 -m venv ~/venvs/stt
source ~/venvs/stt/bin/activate
pip install -U pip
pip install -r requirements.txt
```

## Checks

Before opening a PR, run:

```bash
bash -n bin/hermeskey install.sh uninstall.sh
python3 -m py_compile bin/hermeskey-server.py bin/hermeskey-overlay.py
```

If `shellcheck` is installed, please also run:

```bash
shellcheck bin/hermeskey install.sh uninstall.sh
```

## Pull requests

Please keep PRs:

- focused
- well-described
- tested on a real desktop workflow if they touch typing, overlay, or audio

Include:

- what changed
- why it changed
- what environment you tested on
- any regressions or tradeoffs

## Bug reports

Helpful bug reports include:

- distro
- desktop environment / compositor
- session type (`echo $XDG_SESSION_TYPE`)
- hotkey method
- relevant logs from `~/.local/state/hermeskey/hermeskey.log`
- `journalctl --user -u hermeskey.service`

## Design philosophy

HermesKey is intentionally simple:

- shell script for orchestration
- small Python helpers where Python is a better fit
- systemd user services for long-lived components

Please preserve that simplicity unless there is a very strong reason not to.
