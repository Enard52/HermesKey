# Changelog

All notable changes to HermesKey will be documented in this file.

## [Unreleased]

- TBD

## [0.2.0] - 2026-10-13

Command-and-distribution polish release.

### Added

- `hermeskey --help`, `--version`, `--status`, and `--doctor`
- richer bootstrap installer output and post-install guidance
- release process documentation and helper script
- packaging direction docs and starter RPM / AUR scaffolding
- hotkey setup documentation

### Changed

- improved README install flow and distro quick-start presentation
- tightened the project’s packaging and release story

## [0.1.3] - 2026-10-13

Workflow maintenance release.

### Changed

- upgraded GitHub Actions workflow versions to current non-deprecated releases
- kept CI and release automation aligned with the latest toolchain expectations

## [0.1.2] - 2026-10-13

Maintenance release.

### Changed

- fixed CI unit verification for environments without `ydotoold` installed
- kept release automation and package build green on GitHub Actions

## [0.1.1] - 2026-10-13

Polish release focused on packaging, branding, and maintainability.

### Added

- branded SVG banner, mark, and workflow art
- `hermeskey-doctor` diagnostics command
- release packaging script and GitHub release workflow
- CODEOWNERS, CODE_OF_CONDUCT, SECURITY, SUPPORT, and Dependabot config
- expanded configuration, FAQ, install, troubleshooting, and architecture docs

### Changed

- upgraded README presentation and quick-start flow
- improved installer guidance and preflight checks
- tightened shell compatibility for CI and shellcheck

## [0.1.0] - 2026-10-13

Initial public release.

### Added

- prewarmed `faster-whisper` server
- one-key push-to-talk toggle workflow
- click-through recording/transcribing overlay
- soft start/stop tones
- direct typing into active app
- clipboard backup and terminal paste fallback
- user-level `ydotoold` service for Wayland
- install and uninstall scripts
- config file support
