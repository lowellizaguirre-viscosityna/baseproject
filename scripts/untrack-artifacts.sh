#!/bin/bash
# Untrack files that .gitignore now covers but git is still following.
#
# Adding a .gitignore does not untrack anything already committed, so a repo can
# have a perfect .gitignore and still push 2,500 __pycache__ files every night.
# This removes them from the index only -- files on disk are never touched.
#
# History is NOT rewritten: old blobs stay in the repo's history. That is the
# safe default. Shrinking history needs git-filter-repo and a force-push, which
# is a separate, deliberate decision per repo.
#
#   ./untrack-artifacts.sh                 # dry run, current directory
#   ./untrack-artifacts.sh --apply         # actually untrack
#   ./untrack-artifacts.sh --all /path     # dry run every repo under /path
#   ./untrack-artifacts.sh --all /path --apply

set -uo pipefail

APPLY=0
ALL_ROOT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        --all)   ALL_ROOT="${2:?--all needs a path}"; shift ;;
        -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
        *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
    shift
done

process_repo() {
    local repo="$1" name list count
    name="$(basename "$repo")"
    [ -d "$repo/.git" ] || { printf '%-32s skipped (not a git repo)\n' "$name"; return 0; }

    # Files git tracks that .gitignore would now exclude. NUL-delimited, held in
    # a temp file: command substitution strips NUL bytes, so a variable cannot
    # carry this list safely.
    list="$(mktemp)"
    git -C "$repo" ls-files -z --cached --ignored --exclude-standard > "$list" 2>/dev/null

    if [ ! -s "$list" ]; then
        printf '%-32s clean\n' "$name"
        rm -f "$list"
        return 0
    fi

    count="$(tr -cd '\0' < "$list" | wc -c | tr -d ' ')"

    if [ "$APPLY" -eq 1 ]; then
        git -C "$repo" update-index --force-remove -z --stdin < "$list"
        printf '%-32s UNTRACKED %s file(s) -- commit the result\n' "$name" "$count"
    else
        printf '%-32s would untrack %s file(s)\n' "$name" "$count"
        tr '\0' '\n' < "$list" | head -10 | sed -e 's/^/    /'
        [ "$count" -gt 10 ] && printf '    ... and %s more\n' "$((count - 10))"
    fi
    rm -f "$list"
}

if [ "$APPLY" -eq 0 ]; then
    echo "DRY RUN -- nothing will change. Re-run with --apply to untrack."
    echo
fi

if [ -n "$ALL_ROOT" ]; then
    for d in "$ALL_ROOT"/*/; do process_repo "${d%/}"; done
else
    process_repo "$(pwd)"
fi

if [ "$APPLY" -eq 1 ]; then
    echo
    echo "Files remain on disk. Review with 'git status', then commit:"
    echo "  git commit -m 'Untrack build artifacts now covered by .gitignore'"
fi
