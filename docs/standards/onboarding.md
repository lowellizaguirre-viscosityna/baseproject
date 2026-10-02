# Onboarding

## The 10-minute rule

A new developer goes from `git clone` to a running app with working data in under ten
minutes, using only commands copied from the README. If that breaks, fixing it is a
priority bug, not a chore.

## Required in every repo

- `README.md` — what this is, prerequisites with exact versions, quickstart, how to run
  tests, where the logs are, how to export diagnostics, links to `docs/standards/`
- `make setup` (or `npm run setup`) — installs deps, copies `.env.example` → `.env.local`,
  creates the database, runs migrations, seeds demo data. Idempotent.
- `make dev`, `make test`, `make lint`, `make build`, `make clean` — same names in every
  project, whatever the language underneath
- `.env.example` — the only committed env file; documents every key with type, default,
  `[required]`/`[secret]` annotations, and placeholder secrets that still validate.
  Verified by `scripts/check-env-example.sh`
- `.gitignore` — seeded from the canonical template at the repo root. It deliberately
  does **not** blanket-ignore `*.zip`, because archive and data projects keep vendor
  downloads and exports as zips on purpose; build-output archives are excluded by path
  (`dist/**/*.zip`) and by name pattern (`*_savepoint*.zip`) instead. Adding it to an
  existing repo untracks nothing — run `scripts/untrack-artifacts.sh` after seeding it
- `.vscode/` — recommended extensions, launch configs for app + tests + CLI, shared
  settings (format on save, correct interpreter/SDK)
- `CONTRIBUTING.md` — branch naming, commit format, review expectations, the
  changelog requirement
- `docs/standards/` — this directory, kept current

## Verification

`make doctor` checks the local environment and prints a pass/fail list: runtime version,
required tools present, ports free, database reachable, env vars valid, log directory
writable. It is the first thing to run when something is wrong.

## Checklist

- [ ] Clone to running in under 10 minutes, verified by someone new
- [ ] Standard make targets present
- [ ] `.vscode` launch configs for app, tests, and CLI
- [ ] `make doctor` exists and is useful
- [ ] README links every standard
