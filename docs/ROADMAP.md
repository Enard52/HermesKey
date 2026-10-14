# HermesKey roadmap

This document is the high-level product map. Use GitHub issues for detailed execution and milestones for grouping work.

## Current direction

HermesKey already has the core hotkey dictation loop:

- one-key push-to-talk toggle
- prewarmed `faster-whisper` server
- direct typing into the active app
- desktop helper tools
- bootstrap install flow

The next work should focus on usability, correctness, and distribution.

## Phase 1 — Settings GUI

Target milestone: **v0.5.0 — Settings GUI**

Goal: make setup and day-to-day configuration much easier without turning HermesKey into a giant app.

Planned areas:

- settings window shell
- config load/save wiring
- microphone source picker
- model and language controls
- overlay / sound / insertion toggles
- service status and action buttons

## Phase 2 — Lexicon / Corrections

Target milestone: **v0.6.0 — Lexicon / Corrections**

Goal: improve real-world transcription quality for names, jargon, and project-specific terms.

Planned areas:

- lexicon file format
- post-transcription correction engine
- tests for correction rules
- optional GUI editor for lexicon entries
- optional model prompting based on lexicon data later

## Phase 3 — Packaging

Target milestone: **v0.7.0 — Packaging**

Goal: make HermesKey feel native on Linux distributions.

Planned areas:

- tighten RPM packaging scaffold
- define COPR-first distribution path
- improve AUR packaging scaffold
- verify installed desktop metadata and launcher layout
- document supported packaging workflows

## Phase 4 — UX polish

Target milestone: **v0.8.0 — UX Polish**

Goal: reduce friction and make HermesKey easier to trust.

Planned areas:

- first-run setup guidance
- config validation and sanity checks
- smarter diagnostics output
- better post-install messaging
- final README / docs editorial cleanup

## Working method

- **GitHub issues** track concrete tasks
- **GitHub milestones** group those tasks by release phase
- this file preserves the product-level plan

## Out of scope for now

Not immediate priorities:

- a giant OpenSuperWhisper-style application
- elaborate visual branding beyond the app icon and README banner
- broad cross-desktop support claims before testing catches up
