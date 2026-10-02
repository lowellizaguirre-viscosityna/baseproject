# Feature flags and kill switches

## Rules

- Flags are declared in one file with: key, description, default, owner, and an
  **expiry date**. An expired flag fails CI — flags are temporary by contract.
- Resolution order: request override (debug mode only) → env var → remote/config value →
  default. Resolution is logged once per process at `debug`.
- Every risky or externally-dependent feature gets a **kill switch**: a flag that disables
  it without a deploy. Payments, outbound email, background jobs, and any new write path
  start behind one.
- Flag state appears in debug mode's Flags tab, in `app config show`, and in the support
  bundle. "It works on my machine" is usually a flag difference — make it visible.
- Never branch on flags deep in business logic. Resolve once at the entry point and pass
  behaviour down, so removing a flag is a small, safe diff.
- Removing a flag is a scheduled task, not a hope. The expiry date is the deadline.

## Declaration

```ts
export const FLAGS = {
  newInvoiceEngine: { default: false, owner: 'lowell', expires: '2026-12-01',
                      description: 'Route submissions through v2 calculation engine' },
  emailEnabled:     { default: true,  owner: 'lowell', expires: '2027-06-01',
                      description: 'Kill switch for all outbound email' },
} as const;
```

CLI: `app flags list`, `app flags set newInvoiceEngine=true --local`.

## Checklist

- [ ] Single declaration file with owners and expiry dates
- [ ] CI fails on expired flags
- [ ] Kill switch on every external dependency and new write path
- [ ] Flags visible in debug mode, CLI, and support bundle
