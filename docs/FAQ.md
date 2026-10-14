# FAQ

## Why a long-lived server instead of one Python process per recording?

Model startup is expensive. Keeping `faster-whisper` warm removes most of that delay.

## Why use `ydotoold` as a user service?

On Wayland, user ownership of the socket avoids the permission mess that often happens with a root-owned daemon.

## Why keep clipboard backup enabled?

Because typing into GUI apps is not equally reliable across all Wayland environments. Clipboard backup gives you a safe fallback.

## Why shell plus Python instead of a giant desktop app?

The goal is a hotkey tool that is easy to inspect, debug, and tweak without introducing a heavyweight GUI stack for everything.

## Is this Linux-only?

Right now, yes. HermesKey is intentionally focused on Linux Wayland workflows.
