# Desktop integration

HermesKey is primarily a hotkey-driven tool, but the installer also ships a few desktop launchers for convenience.

## Installed launchers

- **HermesKey Status** — shows runtime and service status
- **HermesKey Doctor** — runs diagnostics and shows the report
- **HermesKey Config** — opens `~/.config/hermeskey/hermeskey.env`

These launchers are installed into:

```bash
~/.local/share/applications/
```

## Why not a big GUI app?

HermesKey is intentionally built around a fast hotkey loop rather than a full settings window. The desktop launchers are there to make support, status checks, and config editing easier.

## Hotkey binding

For actual dictation, bind your shortcut directly to:

```bash
~/.local/bin/hermeskey
```

See [HOTKEYS.md](HOTKEYS.md) for the KDE shortcut flow.
