# Data, migrations, and destructive operations

## Migrations

- Every schema change is a numbered, committed migration file. No hand-edited schemas, no
  "run this SQL" in a chat message.
- Each migration has a tested `down`, or an explicit, reviewed note saying why it cannot be
  reversed. CI applies up → down → up on a scratch database.
- Migrations run at deploy as an explicit step, logged `migration.applied` with version and
  duration. The app refuses to start if the schema version is newer than the code expects.
- Backward compatible by default: add columns nullable, backfill in a separate step, drop
  only after the old code is gone (expand → migrate → contract).
- `app db status` prints current version, pending migrations, and drift.

## Backups

- Automated, scheduled, and — the part people skip — **restore-tested** on a schedule, with
  the restore drill logged. An untested backup is not a backup.
- Document RPO and RTO here per project. Document where backups live and who can read them.

## Destructive operations

Any operation that deletes or irreversibly changes data must:

1. Be soft-delete by default (`deleted_at`), with a documented purge window
2. Require explicit confirmation in the UI (type the resource name, not just "OK")
3. Require `--yes` in the CLI and support `--dry-run` showing exactly what would change
4. Write an audit line before committing ([observability.md](observability.md))
5. Report an affected-row count back to the caller
6. Be idempotent, or guarded by an idempotency key

Bulk operations additionally require a preview of the affected set and a cap, above which
they refuse and tell the operator to narrow the selection.

## Retention

Each table/collection has a documented retention period and a job that enforces it. Logs:
14 days. Audit: per policy, minimum 1 year. Personal data: the minimum the feature needs.

## Checklist

- [ ] Numbered migrations with tested `down`
- [ ] up/down/up verified in CI
- [ ] Schema-version guard at startup
- [ ] Restore drill scheduled and logged
- [ ] Destructive ops: soft delete, confirm, dry-run, audit, row count
- [ ] Retention documented per dataset and enforced by a job
