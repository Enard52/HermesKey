# Troubleshooting

## No typing appears in the active app

Check the user daemon:

```bash
systemctl --user status hermeskey-ydotoold.service
ls -l /run/user/$UID/.ydotool_socket
```

Test typing directly:

```bash
ydotool type "hello"
```

## Transcription fails

Check the prewarmed server:

```bash
systemctl --user status hermeskey.service
journalctl --user -u hermeskey.service -n 100 --no-pager
```

And the local runtime log:

```bash
tail -n 100 /tmp/hermeskey.log
```

## The wrong microphone is used

List sources:

```bash
pactl list short sources
```

Then set `RECORD_SOURCE` in `~/.config/hermeskey/hermeskey.env`.

## The overlay is distracting

Disable it:

```bash
OVERLAY_ENABLED=0
```

Restart your hotkey workflow after saving the config.
