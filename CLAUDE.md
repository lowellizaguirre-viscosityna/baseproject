# How to work in this project

This repo uses a lightweight "resume kit" so an AI assistant (and any human) can pick
up weeks later without re-reading everything. Three files carry the memory:

| File | What it holds | How it's written |
| --- | --- | --- |
| [STATE.md](STATE.md) | Where we left off *right now*: current focus, next steps, open questions, how to run things. | **Overwritten** to reflect the present. Always current, never a history. |
| [JOURNAL.md](JOURNAL.md) | What happened, newest first: one dated entry per working session. | **Append-only.** Never edit or delete past entries. |
| [DECISIONS.md](DECISIONS.md) | Durable "why we chose X" notes that outlive any one session. | Append a numbered entry when a real decision is made. |

## At the start of every session

1. Read [STATE.md](STATE.md) first — it's the single source of "what now".
2. Skim the top few entries of [JOURNAL.md](JOURNAL.md) for recent context.
3. Check [DECISIONS.md](DECISIONS.md) before changing anything architectural, so you
   don't reopen a settled choice (or do so knowingly).

## At the end of every session (before you consider the work done)

1. **Rewrite [STATE.md](STATE.md)** so it describes the project as it stands now:
   what's done, what's next, what's unresolved. Delete anything no longer true.
2. **Prepend a new entry to [JOURNAL.md](JOURNAL.md)** (newest on top) using the
   template in that file: date, what changed, why, and anything the next session
   needs to know.
3. If a lasting decision was made, **add an entry to [DECISIONS.md](DECISIONS.md)**.
4. Commit all of it together with the code so the memory and the work never drift apart.

## Principles

- STATE is the present, JOURNAL is the past, DECISIONS is the reasoning. Keep them
  in their lanes.
- Write for a reader who has forgotten everything — because in a few weeks, they have.
- Prefer updating these files over writing new scattered notes. One place to look.
- This kit assumes nothing about the stack (no build tool, deploy target, or language
  baked in). Add project-specific conventions to this file as the project takes shape.
