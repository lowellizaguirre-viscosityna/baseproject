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

## 2026-11-18 15:30 — Add "gates protect operation, not the sandbox" principle

**Request:** Capture, as a short principle in the kit, the lesson from BalamSentry: a
governance/safety gate should protect operation on real people and production, never the
sandbox; a gate across development self-locks the project.
**Changed:** Added a bullet to the Principles section of `AGENTS.md` defining the rule —
scope gates to live operation, leave a no-gate lane for past/public/synthetic/non-personal
sandbox work, and state which lane each rule gates in any governance/hardening doc. Logged
decision #003 and paired changelog entries.
**Why:** The catch-22 that stalled BalamSentry (sign-off gating the prototype that would
justify the sign-off) is a recurring, self-inflicted failure mode. Putting the rule in the
cross-engine source of truth makes every future project inherit correct gate placement.

## 2026-11-17 12:20 — Add README describing the base project

**Request:** Add a README.md describing the purpose of this base project.
**Changed:** Created `README.md` — explains the resume-kit purpose, a table of all the
memory files and their roles, the start/after-change/end-of-session rhythm, and how to
adopt the template for a real project. Added paired changelog entries.
**Why:** The repo had no top-level entry point; a README is the conventional first thing a
visitor (human or AI) reads, and it ties the file set together at a glance.

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
