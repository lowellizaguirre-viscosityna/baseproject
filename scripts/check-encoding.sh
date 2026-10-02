#!/bin/bash
# Fail on text files that are not UTF-8, carry an unexpected BOM, or have broken
# line endings. Pre-commit hook and CI gate. Policy: docs/standards/encoding.md
#
#   ./scripts/check-encoding.sh              # check tracked files (or cwd tree)
#   ./scripts/check-encoding.sh --staged     # pre-commit: only staged files
#   ./scripts/check-encoding.sh path/ file   # check specific paths
#   ./scripts/check-encoding.sh --quiet      # only failures

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1

STAGED=0; QUIET=0; PATHS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --staged) STAGED=1 ;;
        --quiet|-q) QUIET=1 ;;
        -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
        *) PATHS+=("$1") ;;
    esac
    shift
done

# Extensions we treat as text and therefore police.
TEXT_RE='\.(ps1|psm1|psd1|ps1xml|sh|bash|zsh|bat|cmd|sql|py|ts|tsx|js|jsx|json|jsonc|md|txt|css|scss|html|xml|yml|yaml|toml|ini|cfg|conf|cs|go|rs|java|rb|pl|csv|tsv|env|example|gitignore|gitattributes|editorconfig)$'

collect() {
    if [ ${#PATHS[@]} -gt 0 ]; then
        for p in "${PATHS[@]}"; do
            [ -d "$p" ] && find "$p" -type f -print0 || printf '%s\0' "$p"
        done
    elif [ "$STAGED" -eq 1 ]; then
        git diff --cached --name-only --diff-filter=ACM -z
    elif git rev-parse --git-dir >/dev/null 2>&1; then
        git ls-files -z
    else
        find . -type f -not -path './.git/*' -print0
    fi
}

violations=0
checked=0

while IFS= read -r -d '' f; do
    [ -f "$f" ] || continue
    [ -s "$f" ] || continue
    case "$f" in */node_modules/*|*/.venv/*|*/venv/*|*/__pycache__/*|*/dist/*|*/build/*|*/.git/*) continue ;; esac
    # Only police known text extensions, plus extensionless files that look like text.
    if ! printf '%s' "$f" | grep -qiE "$TEXT_RE"; then
        case "$(basename "$f")" in Makefile|makefile|Dockerfile|*.dockerfile) ;; *) continue ;; esac
    fi
    checked=$((checked + 1))

    bom="$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')"
    enc="$(file -b --mime-encoding "$f" 2>/dev/null)"
    base="$(basename "$f")"
    ext="${f##*.}"

    # 1. UTF-16 / UTF-32 -- always a failure.
    case "$bom" in
        fffe0000*) echo "FAIL  $f  UTF-32LE (BOM ff fe 00 00)"; violations=$((violations+1)); continue ;;
        0000feff*) echo "FAIL  $f  UTF-32BE (BOM 00 00 fe ff)"; violations=$((violations+1)); continue ;;
        fffe*)     echo "FAIL  $f  UTF-16LE (BOM ff fe)";       violations=$((violations+1)); continue ;;
        feff*)     echo "FAIL  $f  UTF-16BE (BOM fe ff)";       violations=$((violations+1)); continue ;;
    esac
    case "$enc" in
        utf-16*|utf-32*) echo "FAIL  $f  $enc (no BOM -- detected)"; violations=$((violations+1)); continue ;;
        binary)
            # NUL bytes in a file we consider text: almost always UTF-16 without a BOM.
            echo "FAIL  $f  contains NUL bytes (UTF-16 without BOM, or misnamed binary)"
            violations=$((violations+1)); continue ;;
    esac

    # 2. BOM on UTF-8. Allowed only for PowerShell source (5.1 compatibility).
    if [ "${bom:0:6}" = "efbbbf" ]; then
        case "$ext" in
            ps1|psm1|psd1|ps1xml) [ "$QUIET" -eq 1 ] || echo "ok    $f  UTF-8 BOM (allowed for PowerShell)" ;;
            *) echo "FAIL  $f  UTF-8 BOM not allowed for .$ext"; violations=$((violations+1)); continue ;;
        esac
    fi

    # 3. Invalid UTF-8 (latin-1 / cp1252 smuggled in).
    if ! iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1; then
        echo "FAIL  $f  not valid UTF-8 (likely Windows-1252)"; violations=$((violations+1)); continue
    fi

    # 4. Line endings.
    crlf="$(grep -cU $'\r$' "$f" 2>/dev/null || true)"
    lfonly="$(grep -cUv $'\r$' "$f" 2>/dev/null || true)"
    case "$ext" in
        sh|bash|zsh)
            [ "${crlf:-0}" -gt 0 ] && { echo "FAIL  $f  CRLF in a shell script (breaks the shebang)"; violations=$((violations+1)); continue; } ;;
    esac
    if [ "${crlf:-0}" -gt 0 ] && [ "${lfonly:-0}" -gt 0 ]; then
        echo "FAIL  $f  mixed line endings ($crlf CRLF, $lfonly LF)"; violations=$((violations+1)); continue
    fi

    [ "$QUIET" -eq 1 ] || echo "ok    $f  $enc"
done < <(collect)

echo
if [ "$violations" -gt 0 ]; then
    echo "$violations violation(s) in $checked file(s). Fix with: ./scripts/fix-encoding.sh --apply"
    exit 1
fi
echo "$checked file(s) checked, all UTF-8 with correct line endings."
