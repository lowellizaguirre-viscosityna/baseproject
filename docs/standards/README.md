# Standards

Baseline conventions for every project. Read the relevant file before writing code in that
area; the index with the non-negotiables is in [CLAUDE.md](../../CLAUDE.md).

## The five questions these standards exist to answer

1. **What went wrong?** → [logging.md](logging.md), [errors.md](errors.md)
2. **Can I see it without a terminal?** → [diagnostics.md](diagnostics.md)
3. **What does this button actually call?** → [debug-mode.md](debug-mode.md),
   [ui-api-contract.md](ui-api-contract.md)
4. **Can I reproduce it from the command line?** → [cli-parity.md](cli-parity.md),
   [correlation-ids.md](correlation-ids.md)
5. **Is what I'm looking at the code I just wrote?** → [build-deploy.md](build-deploy.md),
   [changelog.md](changelog.md)
6. **Why is this file unreadable in git?** → [encoding.md](encoding.md)

## Files

| Doc | Covers |
| --- | --- |
| [logging.md](logging.md) | Log levels, JSONL structure, rotation, redaction, required events |
| [diagnostics.md](diagnostics.md) | Support bundle; export, open, email, tail logs |
| [ui-api-contract.md](ui-api-contract.md) | UI calls an API for everything; action registry; envelope |
| [cli-parity.md](cli-parity.md) | CLI mirrors every endpoint; exit codes; `--dry-run` |
| [debug-mode.md](debug-mode.md) | Per-panel and per-control annotations; inspector |
| [correlation-ids.md](correlation-ids.md) | One ID from click to log line |
| [errors.md](errors.md) | Error taxonomy, stable codes, retry policy, failure UX |
| [config.md](config.md) | Precedence, schema validation, secrets, provenance |
| [health.md](health.md) | Health, readiness, version, self-test |
| [testing.md](testing.md) | Layers, required coverage, CI gates |
| [feature-flags.md](feature-flags.md) | Declared flags with expiry; kill switches |
| [observability.md](observability.md) | Metrics, tracing, audit log |
| [data.md](data.md) | Migrations, backups, destructive ops, retention |
| [security.md](security.md) | Authz, validation, secrets, dependencies |
| [changelog.md](changelog.md) | Public + developer changelogs, enforced in CI |
| [build-deploy.md](build-deploy.md) | `make ship`: rebuild, redeploy, verify every artifact |
| [release.md](release.md) | Versioning, release steps, rollback |
| [onboarding.md](onboarding.md) | 10-minute setup, standard make targets, `make doctor` |
| [encoding.md](encoding.md) | UTF-8 everywhere, the PowerShell BOM exception, line endings |
| [../../.gitignore](../../.gitignore) | Canonical ignore rules; no blanket `*.zip` |
| [../../.gitattributes](../../.gitattributes) | Line-ending normalization, binary declarations |
| [../../.editorconfig](../../.editorconfig) | charset and EOL enforced in the editor |
| [../adr/README.md](../adr/README.md) | Architecture decision records |

## Adopting these in a project

Copy this directory and `CLAUDE.md` into the repo, then work through
[onboarding.md](onboarding.md)'s checklist. Each standard ends with a checklist; a project
is compliant when every box is ticked or a deviation is recorded as an ADR.
