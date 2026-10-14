# Assets

| File | Use |
|---|---|
| `hermeskey-icon.svg` | App icon. Installed as `hermeskey` in the hicolor icon theme and used by the desktop launchers. |
| `hermeskey-banner.svg` | README hero banner. **Generated**: do not edit by hand. |
| `src/hermeskey-banner.src.svg` | Editable banner source (real text). |

The banner's text is converted to outlines so GitHub shows it the same no matter which fonts the viewer has. After editing the source, regenerate it with:

```bash
inkscape assets/src/hermeskey-banner.src.svg --export-text-to-path --export-plain-svg -o assets/hermeskey-banner.svg
```

The banner uses the Cantarell font when generating.

## Palette

| Colour | Hex |
|---|---|
| Navy (tile, background) | `#0f172a` |
| Gold (Hermes wing) | `#f59e0b` |
| Blue (voice) | `#1d4ed8` |
| White / slate (keycap) | `#f8fafc` / `#94a3b8` |
