# Release

## Versioning

Semantic versioning. The version in the manifest, the `/api/v1/version` response, the
`build_info` metric, the UI's about box, and the git tag are all the same string, derived
from one source. Builds also carry the commit SHA and build timestamp.

## Release steps

1. Changelogs are current ([changelog.md](changelog.md)) — CI enforces this
2. Version bumped; `CHANGELOG.md` `Unreleased` section promoted to the new version
3. Full CI green, including migration up/down/up
4. Tag `vX.Y.Z`; build artifacts carry version + commit
5. Deploy: migrate, then release, then verify `/api/v1/ready` and `POST /selftest`
6. Watch error rate and latency for the agreed window before declaring done

## Rollback

Every release has a written rollback path **before** it ships. If a migration is not
backward compatible, the release is split so that it is. Rollback is practiced, not
theoretical, and `app db status` plus `/version` tell you unambiguously what is running.

## Release notes

Generated from the public changelog, not written from scratch. Developer-facing notes
(breaking changes, new env vars, required migrations, flag changes) come from the developer
changelog.

## Checklist

- [ ] One source of truth for version, exposed in API, metrics, and UI
- [ ] Changelogs updated and promoted
- [ ] Rollback path written before deploy
- [ ] Post-deploy readiness + self-test verified
- [ ] New env vars and flags called out in the developer changelog
