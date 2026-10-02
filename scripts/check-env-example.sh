#!/bin/bash
# Keep .env.example honest: it must document every key the code reads, and
# nothing it does not. Run locally or as a CI gate (docs/standards/config.md).
#
#   ./scripts/check-env-example.sh            # check
#   ./scripts/check-env-example.sh --fix      # append missing keys as TODO stubs

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

EXAMPLE=".env.example"
FIX=0
[ "${1:-}" = "--fix" ] && FIX=1
[ -f "$EXAMPLE" ] || { echo "no $EXAMPLE found"; exit 1; }

documented="$(grep -oE '^[A-Z][A-Z0-9_]*=' "$EXAMPLE" | tr -d '=' | sort -u)"

# Keys the code actually reads, across the common access patterns:
#   process.env.KEY   process.env['KEY']   os.environ['KEY']
#   os.environ.get('KEY')   os.getenv('KEY')   $env:KEY   ${KEY}
used="$(grep -rhoE \
    -e 'process\.env\.[A-Z][A-Z0-9_]*' \
    -e "process\.env\[['\"][A-Z][A-Z0-9_]*['\"]\]" \
    -e "os\.environ(\.get)?\(?\[?['\"][A-Z][A-Z0-9_]*['\"]" \
    -e "os\.getenv\(['\"][A-Z][A-Z0-9_]*['\"]" \
    -e '\$env:[A-Z][A-Z0-9_]*' \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    --include='*.py' --include='*.go' --include='*.rs' --include='*.cs' \
    --include='*.sh' --include='*.ps1' \
    --exclude="$(basename "$0")" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.venv \
    --exclude-dir=dist --exclude-dir=build \
    . 2>/dev/null \
  | grep -oE '[A-Z][A-Z0-9_]{2,}' \
  | grep -vE '^(NODE_ENV|PATH|HOME|USER|PWD|SHELL|TERM|LANG|TMPDIR|CI|KEY|TODO)$' \
  | sort -u)"

# A template or docs-only repo has no source to grep. Reporting every documented
# key as unused there is noise, not a finding.
if [ -z "$used" ]; then
    echo "No source files read environment variables yet -- $EXAMPLE documents"
    echo "$(printf '%s\n' "$documented" | grep -c .) key(s). Nothing to cross-check."
    exit 0
fi

missing="$(comm -13 <(printf '%s\n' "$documented") <(printf '%s\n' "$used"))"
unused="$(comm -23 <(printf '%s\n' "$documented") <(printf '%s\n' "$used"))"

status=0

if [ -n "$missing" ]; then
    echo "MISSING from $EXAMPLE (read by code, not documented):"
    printf '  %s\n' $missing
    status=1
    if [ "$FIX" -eq 1 ]; then
        { echo; echo "# ─── TODO: document these ─────────────────────────────────────────────────────"
          for k in $missing; do echo "# TODO: describe $k, note [required]/[secret]"; echo "$k="; done
        } >> "$EXAMPLE"
        echo "  -> appended stubs to $EXAMPLE; fill in the descriptions"
        status=0
    fi
fi

if [ -n "$unused" ]; then
    echo "UNUSED in $EXAMPLE (documented, nothing reads it) -- stale, or read indirectly:"
    printf '  %s\n' $unused
    # Advisory only: keys consumed by docker-compose, CI, or a config loader that
    # iterates the environment are legitimately absent from a source grep.
fi

[ "$status" -eq 0 ] && [ -z "$missing" ] && echo "$EXAMPLE documents every key the code reads."
exit "$status"
