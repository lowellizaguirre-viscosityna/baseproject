# Changelog

> **End-user** changelog: what changed, in plain language, newest first. Every entry is
> timestamped. This file is written so it can be surfaced *inside the application* (an
> "What's new" screen, a release-notes page) — keep it free of jargon, file names, and
> internal detail. The developer-facing counterpart is [CHANGELOG-DEV.md](CHANGELOG-DEV.md).

<!-- Add new entries to the TOP. One line per change:

## YYYY-MM-DD HH:MM — Short, plain-language summary

What's different for you, in a sentence or two. No code, no file names.

-->

## 2026-11-18 15:30 — Added a "gates protect operation, not the sandbox" working principle

The assistant's working rules now include a principle that keeps safety and governance
checks from accidentally blocking early development — they apply when real people or
production are involved, not to sandboxed work on test data.

## 2026-11-17 12:20 — Added a project overview

The project now has a README explaining what this template is for and how its files fit
together.

## 2026-11-17 12:00 — Added a dual changelog and shared agent instructions

The project now keeps a running list of changes you can read, and the assistant follows
the same working rules no matter which AI engine is in use.
