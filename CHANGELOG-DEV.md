# Developer Changelog

Technical record of every change: files, endpoints, migrations, config, flags, and the
reasoning behind them. Public-facing summaries live in [CHANGELOG.md](CHANGELOG.md).

Rules and automation: [docs/standards/changelog.md](docs/standards/changelog.md).

## [Unreleased]

### Added
- `docs/standards/activity-log.md`: new standard. Defines `ACTIVITY.md`, a
  reverse-chronological operation/incident log (What / Why / Scope / Outcome / Reversible)
  for **toolbox / ops** projects that have no UI, API, or deploy. Destructive ops logged
  before and after; incidents logged and linked to an ADR when they change the plan.
### Changed
- `CLAUDE.md`: added a "Project shape" section. Shape is declared at bootstrap and decides
  which non-negotiables apply — `app / web / service` (all apply) vs `toolbox / ops`
  (app-only #2–5 and #7 do not apply; replaced by the activity log). Non-negotiables 1, 6
  and the encoding/ADR conventions apply to every shape. Standards index gains an
  `activity-log.md` row; `build-deploy.md` row marked app-shape.
- `docs/standards/README.md`: index gains the `activity-log.md` row.
- `docs/standards/build-deploy.md`: reworked "One command" to be stack-aware. Introduced
  a single `<ship>` entrypoint whose backing command is chosen by project shape — a
  decision table maps Make-based → `make ship`, containerized/web → `./scripts/ship.sh`
  (wraps `docker compose`), Node → `npm run ship`, else a shell wrapper. All downstream
  references (hook, watcher, CI, staging/prod, checklist) now use `<ship>` instead of
  `make ship`; artifact table notes the remote-Docker-host-over-SSH deploy path and that
  a project ships only the artifact kinds it has.
- `CLAUDE.md`: agent rule now says to run the project's one ship entrypoint (named at
  bootstrap) rather than assuming `make ship`.
- `docs/standards/README.md`: index line generalized.
### Deprecated
### Removed
### Fixed
### Security
### Migrations
### Config
### Flags
### Breaking
### Ops
- Build/deploy mechanism is now a project-chosen `<ship>` entrypoint, not hardcoded
  `make ship`. Pick it at bootstrap and name it in `CLAUDE.md`; the same entrypoint is
  used locally, in the post-commit hook, in CI, and for staging/production.
