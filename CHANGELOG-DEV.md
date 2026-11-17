# Developer Changelog

> **Developer** changelog: the detailed, technical record of every change, newest first.
> Each entry pairs with a line in the end-user [CHANGELOG.md](CHANGELOG.md) via an
> identical timestamp. Capture the request that prompted the change, what actually
> changed, and why — enough that a future developer (or a different AI engine) can
> reconstruct the reasoning. **Append-only**; never edit past entries.

<!-- Add new entries to the TOP:

## YYYY-MM-DD HH:MM — Short title

**Request:** what was asked for (quote or paraphrase the prompt).
**Changed:** files touched, approach taken, anything notable.
**Why:** the reasoning; alternatives considered or rejected.

-->

## 2026-11-17 12:00 — Add shared agent instructions + dual changelog to the resume kit

**Request:** Maintainer wanted (1) a separate markdown for Codex / other agents, since
they frequently switch engines after hitting a usage limit, and (2) a dual-changelog
system — an end-user summary and a developer summary, each timestamped, written after
every change, with the end-user one optionally includable in the application.

**Changed:**
- Added `AGENTS.md` as the single source of truth for the working workflow (cross-agent
  convention read by Codex and others).
- Rewrote `CLAUDE.md` into a thin pointer to `AGENTS.md` plus a short summary, so the two
  engines never follow divergent rules.
- Added `CHANGELOG.md` (end-user, plain language, app-surfaceable) and this
  `CHANGELOG-DEV.md` (developer detail), both append-only and newest-first, paired by
  timestamp.
- Documented the "after every change" changelog habit and the five memory files in
  `AGENTS.md`.

**Why:** A single `AGENTS.md` avoids drift between duplicated per-engine instructions and
makes mid-day engine handoffs seamless. Splitting the changelog into user- and
developer-facing files lets the project ship release notes from `CHANGELOG.md` without
leaking internal detail, while preserving full technical history alongside it.
