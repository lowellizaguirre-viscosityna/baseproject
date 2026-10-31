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
