# Developer Changelog

Technical record of every change: files, endpoints, migrations, config, flags, and the
reasoning behind them. Public-facing summaries live in [CHANGELOG.md](CHANGELOG.md).

Rules and automation: [docs/standards/changelog.md](docs/standards/changelog.md).

## [Unreleased]

### Added
### Changed
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
