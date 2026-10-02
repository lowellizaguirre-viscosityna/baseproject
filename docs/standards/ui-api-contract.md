# UI → API contract

## The rule

**The UI contains no business logic.** Every user action becomes exactly one API call.
The UI's only jobs are: render state, collect input, call an endpoint, show the result.

If a feature cannot be exercised with `curl`, it is not finished.

## What this forbids in UI code

- Validation that is not also enforced server-side (client validation is UX only)
- Computing totals, permissions, eligibility, or derived state
- Direct database, filesystem, or third-party API access
- Writing files, spawning processes, reading env vars other than the API base URL
- Conditional business rules (`if (user.plan === 'pro')` → ask the API instead)

## Shape

```
components/        presentation only, no fetch calls
  InvoiceForm.tsx
api/               one module per resource, the ONLY place fetch() appears
  invoices.ts      submitInvoice() -> POST /api/v1/invoices
server/routes/     the endpoint, where the logic lives
  invoices.ts
```

Each UI action maps to one function in `api/`, which maps to one endpoint. The mapping
is declared, not implied:

```ts
export const ACTIONS = {
  'invoice.submit': { method: 'POST', path: '/api/v1/invoices',            label: 'Submit' },
  'invoice.void':   { method: 'POST', path: '/api/v1/invoices/:id/void',   label: 'Void'   },
} as const;
```

That table is what debug mode renders and what [cli-parity.md](cli-parity.md) generates
commands from. One source of truth.

## Envelope

Every response, success or failure, uses the same envelope so the UI never special-cases:

```json
{ "ok": true,  "data": { }, "correlationId": "01JB2F…", "durationMs": 42 }
{ "ok": false, "error": { "code": "E_VALIDATION", "message": "Amount must be positive",
  "field": "amount", "retryable": false, "details": {} },
  "correlationId": "01JB2F…" }
```

The UI shows `error.message` to the user and `error.code` + `correlationId` in the
copyable details. Never show a stack trace to a user; always make it one click away.

## Loading and failure states

Every action has four visual states — idle, pending, success, failure — and every one is
implemented. No action may silently no-op. Buttons disable while pending and re-enable
on both outcomes.

## Versioning

All endpoints live under `/api/v1/`. Breaking a response shape means `/api/v2/`, with v1
kept until the UI is migrated. Never change a field's meaning in place.

## Checklist

- [ ] No `fetch`/HTTP client outside `api/`
- [ ] Action registry exists and is the only action source
- [ ] Shared response envelope with correlation ID
- [ ] Server re-validates everything the client validated
- [ ] All four states implemented per action
