# Project Instructions

Baseline conventions for this project. Every standard below is mandatory unless a
file in `docs/standards/` says otherwise for a specific subsystem.

## Non-negotiables

1. **Everything is logged.** No silent failures, no bare `catch {}`. See
   [docs/standards/logging.md](docs/standards/logging.md).
2. **The UI never does work.** Every user action calls an API endpoint; the UI only
   renders the result. See [docs/standards/ui-api-contract.md](docs/standards/ui-api-contract.md).
3. **Every API endpoint is reachable from the command line.** If a button can do it,
   `curl` and the project CLI can do it too. See [docs/standards/cli-parity.md](docs/standards/cli-parity.md).
4. **Debug mode is built in, not bolted on.** Every panel and control self-identifies
   which endpoint it calls. See [docs/standards/debug-mode.md](docs/standards/debug-mode.md).
5. **Every request carries a correlation ID** from click to log line.
   See [docs/standards/correlation-ids.md](docs/standards/correlation-ids.md).
6. **Every change updates both changelogs** in the same commit — public and developer.
   See [docs/standards/changelog.md](docs/standards/changelog.md).
7. **Every change is rebuilt and redeployed** to the dev target and verified running.
   See [docs/standards/build-deploy.md](docs/standards/build-deploy.md).

## Standards index

| Doc | Covers |
| --- | --- |
| [logging.md](docs/standards/logging.md) | Log levels, structure, rotation, redaction |
| [diagnostics.md](docs/standards/diagnostics.md) | Export / open / email logs, support bundles |
| [ui-api-contract.md](docs/standards/ui-api-contract.md) | UI→API rule, no business logic in views |
| [cli-parity.md](docs/standards/cli-parity.md) | CLI mirrors every endpoint |
| [debug-mode.md](docs/standards/debug-mode.md) | In-UI inspection overlay |
| [correlation-ids.md](docs/standards/correlation-ids.md) | Request tracing end to end |
| [errors.md](docs/standards/errors.md) | Error taxonomy, codes, user-facing messages |
| [config.md](docs/standards/config.md) | Env vars, precedence, secrets |
| [health.md](docs/standards/health.md) | Health, readiness, version, self-test |
| [testing.md](docs/standards/testing.md) | Test layers and what each must cover |
| [feature-flags.md](docs/standards/feature-flags.md) | Flags, kill switches |
| [security.md](docs/standards/security.md) | Authn/z, input validation, secret handling |
| [observability.md](docs/standards/observability.md) | Metrics, traces, audit trail |
| [data.md](docs/standards/data.md) | Migrations, backups, destructive-op rules |
| [release.md](docs/standards/release.md) | Versioning, changelog, rollback |
| [onboarding.md](docs/standards/onboarding.md) | Clone → running in under 10 minutes |
| [.gitignore](.gitignore) | Canonical ignore rules (no blanket `*.zip`) |
| [.env.example](.env.example) | Every config key, documented; the only committed env file |
| [encoding.md](docs/standards/encoding.md) | UTF-8 everywhere; no UTF-16; line endings |
| [.gitattributes](.gitattributes) | Line-ending normalization, binary declarations |
| [.editorconfig](.editorconfig) | charset/EOL enforced in the editor |
| [changelog.md](docs/standards/changelog.md) | Dual changelog, enforced every change |
| [build-deploy.md](docs/standards/build-deploy.md) | Rebuild + redeploy every artifact |
| [adr/README.md](docs/adr/README.md) | Architecture decision records |

## Agent rules

- Read the relevant standard before writing code in that area.
- When you add an endpoint: add the CLI command, the debug annotation, the audit log
  line, and a test. An endpoint without all four is incomplete.
- Every change you make ends with: both changelogs updated in the same commit, then the
  project's **one ship entrypoint** run so every artifact is current and verified. What
  that entrypoint is depends on the stack — `make ship` for a Make-based project,
  `./scripts/ship.sh` (wrapping `docker compose`) for a containerized/web one, `npm run
  ship` for Node, etc. Pick one at bootstrap and name it here; don't assume `make`. See
  [docs/standards/build-deploy.md](docs/standards/build-deploy.md).
- Never leave a built artifact stale. If you changed code, rebuild and redeploy it.
- Reading a new env var means documenting it in `.env.example` in the same change.
- Never write a text file as UTF-16. PowerShell's `>`, `Out-File` and `Export-Csv` default
  to UTF-16 on 5.1 — always pass `-Encoding utf8`.
- When a standard is wrong, change the standard in the same PR — do not diverge silently.
