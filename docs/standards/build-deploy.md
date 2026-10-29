# Build and deploy after every change

## The rule

A change is not finished when the code compiles. It is finished when every artifact the
project produces has been **rebuilt and redeployed to the local/dev target**, and verified
running. Stale artifacts are the single most common cause of "but I fixed that."

Artifacts means all of them, for whatever the project actually has: Docker images, the
website or static bundle, deployment zips/installers, the CLI binary, published packages.
A project only ships the kinds it has — ignore the rows below that don't apply.

## One command — chosen to fit the project

Every project exposes **exactly one ship entrypoint** that does the whole
`lint → test → build → (package) → deploy → verify` pipeline. It is idempotent, safe to
run repeatedly, and fails loudly — it never deploys a failed build.

What *backs* that entrypoint depends on the project's shape. Pick one at bootstrap, then
use the same command everywhere (hook, CI, staging/prod). Do not hardcode `make` into a
project that has no `make`.

| If the project is… | Ship entrypoint | What backs it |
| --- | --- | --- |
| **Make-based** (a `Makefile` is the natural task runner: polyglot, native builds, mixed artifacts) | `make ship` | a `ship` make target |
| **Containerized / web, no Make** (Docker Compose is the unit of deploy) | `./scripts/ship.sh` | a shell wrapper over `docker compose build` + `up -d` + verify |
| **Node / TypeScript** | `npm run ship` | a `ship` script in `package.json` |
| **Something else** | `./scripts/ship.sh` | a shell wrapper calling that stack's build/deploy tools |

Throughout the rest of this doc, **`<ship>`** means whichever one the project chose. Name
it in the project's own `CLAUDE.md` and `onboarding.md` so there is no ambiguity.

```
<ship>            # build everything, deploy to the default target, verify
ENV=dev <ship>    # explicit target
```

### Artifacts, deploy, and verify by type

| Target | Artifact | Deploy step | Verify step |
| --- | --- | --- | --- |
| Docker | image(s) tagged `<app>:<version>-<sha>` and `:dev` | `docker compose up -d --build` (locally or against a remote Docker host over SSH) | containers healthy + `/api/v1/ready` 200 |
| Website / SPA | hashed static bundle | sync to the dev site root / preview host, or bake into the serving image | fetch index, assert commit SHA in `/version` |
| Deployment zip | `dist/<app>-<version>-<sha>.zip` | copy to the artifacts directory | checksum recorded, zip integrity test |
| CLI | binary in `dist/bin/` | install to local path | `app --version` matches the build |

## Rules

- **Tag with version + commit SHA**, never `latest` alone. `:dev`/`:latest` may move, but a
  pinned immutable tag must always exist for every build.
- **Verification is part of deploy.** After deploying, hit `/api/v1/version` and confirm
  the commit SHA matches what was just built, then `/api/v1/ready`, then `POST /selftest`.
  A deploy that is not verified did not happen.
- **Rebuild is deterministic and incremental** — layer caching, lockfiles, no network
  surprises. If `<ship>` is slow enough that people skip it, that is a bug to fix.
- **Record every build** in `dist/build-manifest.json`: version, commit, timestamp,
  artifact names, checksums. Include it in support bundles so you can tell exactly which
  build a user is running.
- **Clean before packaging** release artifacts so no stale files ride along.
- Log `build.started` / `build.completed` / `deploy.completed` with version, commit, target,
  and duration, and add a `Ops` line to `CHANGELOG-DEV.md` when the build or deploy process
  itself changes ([changelog.md](changelog.md)).

## Automation

- `post-commit` hook (opt-in) runs `ENV=dev <ship>` in the background and notifies on
  failure — so the dev target is always current without anyone thinking about it.
- A file watcher in dev mode (e.g. `docker compose watch`, or the stack's own watcher)
  rebuilds and redeploys the affected artifact on save.
- CI runs the same `<ship>` against a scratch target on every push. The local path and the
  CI path are the same script, so there is no "works locally" class of bug.

## Staging and production

Automatic rebuild-and-deploy applies to **local and dev targets**. Staging and production
deploys use the same `<ship>` entrypoint with `ENV=staging` / `ENV=production`, but are
gated: green CI on the tagged commit, changelogs promoted, a written rollback path, and an
explicit human trigger. See [release.md](release.md). This keeps the "always rebuilt"
guarantee without shipping a half-finished change to users.

## Checklist

- [ ] One `<ship>` entrypoint, named in `CLAUDE.md`, backed by the stack's natural tooling
- [ ] `<ship>` builds, (packages,) deploys, and verifies every artifact the project has
- [ ] Immutable version+SHA tags on every artifact
- [ ] Deployed commit SHA verified via `/api/v1/version` after every deploy
- [ ] `dist/build-manifest.json` written and included in support bundles
- [ ] Post-commit / watch automation keeps the dev target current
- [ ] Same entrypoint used locally, in CI, and for staging/production
- [ ] Staging and production require an explicit trigger
