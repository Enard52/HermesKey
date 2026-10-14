# Releasing HermesKey

## Release philosophy

HermesKey releases should feel deliberate:

- changelog updated
- docs updated
- CI green
- release artifact generated
- release notes written by a human, not just auto-generated

## Checklist

- [ ] update `VERSION`
- [ ] update `CHANGELOG.md`
- [ ] run `make check`
- [ ] verify install docs still match reality
- [ ] verify the bootstrap installer still works
- [ ] commit release prep changes
- [ ] tag the release
- [ ] push branch and tag
- [ ] verify GitHub Actions created the release artifact
- [ ] update release notes if needed

## Helper commands

Check the repo:

```bash
make check
```

Build the release tarball:

```bash
make package
```

Cut a release using the helper script:

```bash
./scripts/release.sh
```

## Notes

- `scripts/release.sh` expects a clean git working tree.
- The release workflow publishes a `.tar.gz` archive when a `v*` tag is pushed.
- Hand-written release notes live under `docs/releases/`.
