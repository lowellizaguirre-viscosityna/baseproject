# Activity log (for toolbox / ops projects)

Some repositories are not an app and not a web service — they are a **toolbox**: a set of
scripts, maintenance utilities, or one-off operations run by hand against a machine or an
external system. For these, most app standards do not apply (there is no UI, no API, no
deploy target, no request to trace). What still matters is: **what did we do, when, why,
and what happened?**

That record is `ACTIVITY.md` at the repo root. It is the primary history for a toolbox
project — the counterpart to logging and correlation IDs in an app.

## When a project uses an activity log

A project keeps an `ACTIVITY.md` instead of the app-only standards when it is a toolbox:
it is run interactively, it mutates state outside the repo (a workstation, a NAS, an
installed application, a cloud account), and there is nothing long-running to observe.
Declare the shape in `CLAUDE.md` (see its "Project shape" section).

The dual changelogs still apply: they record changes to the **scripts in the repo**. The
activity log records **operations performed with them** — including operations that
changed nothing in the repo (a recovery, a one-off fix, an incident). The two do not
overlap: a bug fix to a script is a changelog entry; running that script against a machine
is an activity entry.

## Format

Reverse-chronological (newest first). One entry per operation or incident. Keep it to a
few lines; link to an ADR when the operation reflects a decision worth preserving.

```markdown
## 2026-10-29 — Resolved "interpreter could not be resolved" across projects

- **What:** Set `python.defaultInterpreterPath` to `/home/lowell/myenv/bin/python3` in
  VS Code user settings (Code, Insiders, Insiders-Business).
- **Why:** Projects with no interpreter selected fell back to the PATH-derived `python`
  (myenv, auto-activated in `.bashrc`), which the extension could not catalogue.
- **Scope:** Local workstation only. `~/.config/Code*/User/settings.json`.
- **Outcome:** Verified venv healthy (3.12.3); message clears after window reload.
- **Reversible:** Delete the added line from each `settings.json`.
```

Recommended fields, as plain bold labels (omit ones that do not apply):

- **What** — the action taken, concretely (commands, files, settings, targets).
- **Why** — the reason or the triggering problem.
- **Scope** — what was touched: which machine, account, paths, or system.
- **Outcome** — result, and how it was verified.
- **Reversible** — how to undo it, or "no" if it cannot be undone.

## Rules

- Record the operation when it is run, not later. An undated memory is not a record.
- Destructive or hard-to-reverse operations (deletes, overwrites, restores) are logged
  **before and after**: what you intend, then what actually happened.
- An incident (something broke, something was recovered) is an activity entry too, with
  the same fields. If it changes how the project works going forward, also write an ADR.
- Absolute dates only (`YYYY-MM-DD`), never "yesterday" or "last week".

## Agent rule

When an agent performs an operation against an external system on the user's behalf —
applying a customization, recovering files, changing machine config — appending the
`ACTIVITY.md` entry is part of that operation, in the same turn. Name the exact paths and
targets touched and say why.

## Checklist

- [ ] `ACTIVITY.md` exists at the repo root with the newest entry first
- [ ] Project shape declared as toolbox/ops in `CLAUDE.md`
- [ ] Destructive operations are logged before and after
- [ ] Incidents and recoveries are logged, and linked to an ADR when they change the plan
