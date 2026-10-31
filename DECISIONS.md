# Decisions

> Durable "why we chose X" notes that outlive any single session. Append a numbered
> entry when a real decision is made; don't rewrite old ones. If a decision is later
> reversed, add a new entry that supersedes it (and say which number it replaces).

<!-- Template:

## NNN. Short title of the decision

**Date:** YYYY-MM-DD
**Decision:** what we decided.
**Why:** the reasoning and the main alternatives rejected.
**Status:** accepted | superseded by #NNN

-->

## 001. Memory lives in three in-repo markdown files

**Date:** 2026-10-31
**Decision:** Track project continuity with `STATE.md` (present), `JOURNAL.md`
(append-only history), and `DECISIONS.md` (rationale), all plain markdown in the repo.
**Why:** The objective is resuming work after long gaps. Keeping it in-repo means the
memory travels with the code, lives in git history, works with any tool, and depends on
nothing external. Rejected: a heavy standards framework (over-fit to apps, the previous
baseline's failing) and relying on Claude's private memory dir (not portable, invisible
to humans and other tools).
**Status:** accepted
