# Testing

## Layers and their jobs

| Layer | Scope | Must cover |
| --- | --- | --- |
| Unit | One function, no I/O | Branches, edge cases, error paths |
| Contract | One endpoint, real schema | Every documented status + error code |
| Integration | Endpoint + real DB/queue | Persistence, transactions, idempotency |
| CLI | The binary, as a user runs it | Exit codes, `--json` shape, `--dry-run` |
| E2E | UI driving the real API | The happy path of each registered action |

## Rules

- **Every new endpoint ships with a contract test** that asserts the success envelope and
  at least one failure envelope, including that `correlationId` is present.
- **Every error code is tested** at least once — otherwise it is unreachable or wrong.
- **Every registered action** in the action registry has an E2E or CLI test. A CI check
  diffs the registry against the test list and fails on gaps.
- Tests assert on `error.code`, never on message text. Messages are allowed to change.
- No sleeps. Wait on conditions.
- Each test creates its own data and cleans up; tests pass in any order and in parallel.
- Logs during tests are captured and asserted where behaviour is "it must be logged" —
  the required events in [logging.md](logging.md) have tests.
- A bug fix starts with a failing test that reproduces it, named after the issue.

## Coverage

Line coverage is a smoke alarm, not a goal. Hard floor 70%, with these required at 100%:
error-mapping code, the config loader, redaction, and the diagnostics bundle assembler.

## CI gates

`lint` → `typecheck` → `unit` → `contract` → `integration` → `cli` → `e2e` → `build`.
Also: registry/test-gap check, `.env.example` completeness check, no-`console.log` check,
migration-reversibility check. Any gate red = no merge.

## Checklist

- [ ] Contract test per endpoint, failure cases included
- [ ] Every error code exercised
- [ ] Registry-to-test gap check in CI
- [ ] Tests assert codes, not prose
- [ ] Log assertions for required events
