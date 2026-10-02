# Errors

## Taxonomy

Every error is one of these, carries a stable `code`, and knows whether it is the user's
problem or ours.

| Class | Code prefix | HTTP | Exit | Who fixes it |
| --- | --- | --- | --- | --- |
| Usage / validation | `E_VALIDATION`, `E_BAD_REQUEST` | 400 | 3 | User |
| Auth | `E_UNAUTHENTICATED`, `E_FORBIDDEN` | 401/403 | 4 | User |
| Not found | `E_NOT_FOUND` | 404 | 5 | User |
| Conflict / state | `E_CONFLICT`, `E_PRECONDITION` | 409/412 | 6 | User |
| Rate limit | `E_RATE_LIMITED` | 429 | 7 | Retry |
| Dependency | `E_UPSTREAM`, `E_TIMEOUT` | 502/504 | 8 | Retry / ops |
| Internal | `E_INTERNAL` | 500 | 1 | Us |

Codes are a closed enum in one file. Adding one is a deliberate act, and each gets a row
in that file with its user-facing message and whether it is retryable.

## Error object

```ts
class AppError extends Error {
  code: ErrorCode;        // stable, greppable, never reworded
  message: string;        // safe to show the user, no internals
  field?: string;         // for validation, which input
  retryable: boolean;
  cause?: unknown;        // original error, preserved, never discarded
  details?: object;       // structured, redacted, for logs and debug mode
}
```

## Rules

- **Never swallow.** `catch` either handles and logs, or rethrows wrapped with context.
  An empty catch block fails review.
- **Wrap, don't replace.** Always set `cause` so the original stack survives.
- **Fail fast at boundaries.** Validate input once at the edge with a schema; interior
  code assumes valid data.
- Messages are written for the user: what happened, what to do next. No "null is not an
  object", no SQL, no file paths from the server.
- Internal details go to logs and to debug mode, never to the user's screen — but always
  one click away via "Copy details".
- Retries: only for `retryable` errors, exponential backoff with jitter, bounded attempts,
  and every attempt logged with its attempt number. Mutations need an idempotency key.
- Unhandled rejections and uncaught exceptions are logged `fatal`, flush the log, exit
  non-zero. Never continue in an unknown state.

## User-facing failure UX

Every failed action shows: a plain-language message, the error code, the correlation ID,
a **Copy details** button, a **Retry** button if retryable, and an **Export diagnostics**
link. Toasts are not the only channel — the inline field error must also appear for
validation failures.

## Checklist

- [ ] Closed error-code enum in one file with messages
- [ ] `AppError` with cause chaining
- [ ] No empty catch blocks (lint-enforced)
- [ ] Schema validation at every input boundary
- [ ] Retry policy with backoff + idempotency keys
- [ ] Fatal handlers installed, log flushed before exit
