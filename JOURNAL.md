# Journal

> Append-only log of working sessions, **newest first**. One entry per session.
> Never edit or delete past entries — if something changed, say so in a new entry.
> This is the memory that lets a later session reconstruct how we got here.

<!-- Copy this template to the top for each new entry:

## YYYY-MM-DD — short title

**Did:** what changed this session.
**Why:** the reason / goal behind it.
**Next:** what the following session should pick up (should match STATE.md).
**Notes:** gotchas, dead ends, things that surprised you. Optional.

-->

## 2026-11-17 — Added README overview

**Did:** Added `README.md` as the top-level entry point: purpose of the template, a table
of all memory files and their roles, the session rhythm, and how to adopt it for a real
project. Logged paired changelog entries.
**Why:** The repo had no front-door document explaining what it is and how the pieces fit.
**Next:** Unchanged — use the kit on a real project.

## 2026-11-17 — Added shared agent instructions + dual changelog

**Did:** Added `AGENTS.md` as the single source of truth for the working workflow and
reduced `CLAUDE.md` to a pointer to it, so Claude, Codex, and any other engine follow the
same rules. Added a dual changelog: `CHANGELOG.md` (end-user, plain language, safe to
surface inside an app) and `CHANGELOG-DEV.md` (developer detail: request + change + why),
both append-only and paired by timestamp. Documented the "after every change" changelog
habit in AGENTS.md and logged decision #002.
**Why:** The maintainer frequently switches engines mid-day after hitting a usage limit;
one AGENTS.md avoids drift between per-engine instructions. The split changelog lets a
project ship release notes without leaking internal detail while keeping full technical
history.
**Next:** Use it on the first real project. The changelog habit is only as good as the
discipline of writing a paired entry after each change.
**Notes:** AGENTS.md is the emerging cross-agent convention; keeping CLAUDE.md as a thin
pointer means no second copy to maintain.

## 2026-10-31 — Established the resume kit

**Did:** Cleared out the old app-oriented baseline (standards docs, encoding scripts,
dual changelogs, build/deploy ship rules, git hooks) and replaced it with a minimal,
project-type-agnostic resume kit: `STATE.md`, `JOURNAL.md`, `DECISIONS.md`, and a short
`CLAUDE.md` explaining the read-on-start / update-on-end workflow.
**Why:** The previous baseline assumed every project was an app (referenced `make`, a
deploy target, a UI/API) which didn't fit non-app projects. The real goal is simpler:
help an AI pick up where we left off after weeks away, backed by a changelog memory.
**Next:** Use it. When a real project starts here, fill in STATE.md and log decisions.
**Notes:** Old scaffolding is recoverable from git history (commit before this one)
if any piece turns out to be worth keeping.
