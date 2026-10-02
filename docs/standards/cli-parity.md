# CLI parity

## The rule

Anything the UI can do, the CLI can do. The CLI is the debugging interface, the
automation interface, and the support interface — all three for free, because both
front-ends call the same endpoints.

## Structure

```
app <resource> <verb> [args] [--flags]

app invoices list --status unpaid --json
app invoices submit --file invoice.json
app invoices void inv_55 --reason duplicate
app diag export --out ~/Desktop
app health --verbose
```

Global flags on every command:

| Flag | Effect |
| --- | --- |
| `--json` | Machine-readable output only; nothing else on stdout |
| `--verbose` / `-v` | Repeatable; raises log level toward `trace` |
| `--quiet` | Errors only |
| `--correlation-id ID` | Reuse an ID so CLI and UI traces join up |
| `--dry-run` | Validate and show what would happen; change nothing |
| `--trace-http` | Print the exact request/response for each API call |
| `--timeout MS` | Per-call timeout |
| `--profile NAME` | Which configured environment to hit |

## Rules

- Exit codes are meaningful: `0` success, `1` unexpected error, `2` usage error,
  `3` validation failure, `4` auth failure, `5` not found, `6` conflict. Documented in
  `--help` and in [errors.md](errors.md).
- Human output to stdout, logs and progress to stderr — so `app x --json | jq` works.
- No interactive prompt without a non-interactive flag equivalent; `--yes` skips
  confirmations so CI can run it.
- `app api <METHOD> <PATH> [--data JSON]` is an escape hatch that hits any endpoint
  directly, so a new endpoint is testable before its command exists.
- `app actions` lists the whole action registry from [ui-api-contract.md](ui-api-contract.md)
  with the CLI command and endpoint for each — this is how a developer answers "what does
  the Submit button call?" without opening the UI.

## Reproducing a UI action from the terminal

Debug mode shows a **Copy as CLI** button on every control. It emits a ready-to-paste
command, including the correlation ID:

```
app invoices submit --file ./payload.json --correlation-id 01JB2F9T7K3QX8Z --trace-http
```

## Checklist

- [ ] Every endpoint has a command or is reachable via `app api`
- [ ] `app actions` enumerates the registry
- [ ] Documented, stable exit codes
- [ ] `--json` output is pure JSON
- [ ] `--dry-run` on every mutating command
