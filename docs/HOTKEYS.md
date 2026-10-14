# Hotkey setup

HermesKey is designed around a single global hotkey that toggles recording on and off.

## KDE Plasma

1. Open **System Settings**.
2. Go to **Keyboard** → **Shortcuts** → **Custom Shortcuts**.
3. Create a new **Command/URL** shortcut.
4. Set the command to:

```bash
~/.local/bin/hermeskey
```

5. Assign the key or key combination you want.

## Recommended hotkey style

Good options:

- a dedicated side key or spare function key
- a modifier you are already comfortable using as push-to-talk
- a combo that does not conflict with your window manager or editor

## Notes

- HermesKey uses toggle behavior: press once to start, press again to stop.
- If you change your config, restart the server with:

```bash
systemctl --user restart hermeskey.service
```
