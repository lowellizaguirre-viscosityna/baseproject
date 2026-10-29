# Changelog

All notable user-facing changes to this project. Written for users and stakeholders —
plain language, no internals. Developer detail lives in [CHANGELOG-DEV.md](CHANGELOG-DEV.md).

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Projects that are not an app or web service (a toolbox of scripts or one-off operations)
  now have a defined way to track what was done over time: a running activity log.
### Changed
- Build/deploy standard no longer assumes `make`. A project now picks one "ship"
  entrypoint that fits its stack (Make, Docker Compose, npm, …); the rebuild →
  redeploy → verify guarantee is unchanged.
### Deprecated
### Removed
### Fixed
### Security
