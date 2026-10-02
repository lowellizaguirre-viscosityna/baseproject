#!/bin/bash
# Convert text files to UTF-8 and normalize line endings, detecting the actual
# byte order from the BOM rather than assuming. Policy: docs/standards/encoding.md
#
#   ./scripts/fix-encoding.sh                   # dry run over tracked files
#   ./scripts/fix-encoding.sh --apply           # convert in place
#   ./scripts/fix-encoding.sh --apply path/     # limit to a path
#   ./scripts/fix-encoding.sh --apply --keep-crlf   # convert encoding only
#
# Conversion rewrites every line of a file. Commit it on its own, with no other
# changes, or the real diff is impossible to find.
#
# .ps1/.psm1/.psd1 keep CRLF and keep a UTF-8 BOM if they already had one, because
# Windows PowerShell 5.1 reads BOM-less files as the system codepage.

set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1

APPLY=0; KEEP_CRLF=0; PATHS=()
while [ $# -gt 0 ]; do
    case "$1" in
        --apply) APPLY=1 ;;
        --keep-crlf) KEEP_CRLF=1 ;;
        -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
        *) PATHS+=("$1") ;;
    esac
    shift
done

TEXT_RE='\.(ps1|psm1|psd1|ps1xml|sh|bash|zsh|bat|cmd|sql|py|ts|tsx|js|jsx|json|jsonc|md|txt|css|scss|html|xml|yml|yaml|toml|ini|cfg|conf|cs|go|rs|java|rb|pl|csv|tsv)$'

collect() {
    if [ ${#PATHS[@]} -gt 0 ]; then
        for p in "${PATHS[@]}"; do
            [ -d "$p" ] && find "$p" -type f -print0 || printf '%s\0' "$p"
        done
    elif git rev-parse --git-dir >/dev/null 2>&1; then
        git ls-files -z
    else
        find . -type f -not -path './.git/*' -print0
    fi
}

[ "$APPLY" -eq 1 ] || echo "DRY RUN -- nothing will change. Re-run with --apply."
converted=0; skipped=0

while IFS= read -r -d '' f; do
    [ -f "$f" ] && [ -s "$f" ] || continue
    case "$f" in */node_modules/*|*/.venv/*|*/__pycache__/*|*/.git/*|*/dist/*|*/build/*) continue ;; esac
    printf '%s' "$f" | grep -qiE "$TEXT_RE" || continue

    bom="$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')"
    enc="$(file -b --mime-encoding "$f" 2>/dev/null)"
    ext="${f##*.}"
    from=""; had_utf8_bom=0

    case "$bom" in
        fffe0000*) from="UTF-32LE" ;;
        0000feff*) from="UTF-32BE" ;;
        fffe*)     from="UTF-16LE" ;;
        feff*)     from="UTF-16BE" ;;
        efbbbf*)   had_utf8_bom=1 ;;
    esac
    # No BOM but NUL bytes or a UTF-16 verdict: trust `file`, defaulting to LE,
    # which is what Windows tooling emits when it omits the BOM.
    if [ -z "$from" ] && [ "$had_utf8_bom" -eq 0 ]; then
        case "$enc" in
            utf-16le) from="UTF-16LE" ;;
            utf-16be) from="UTF-16BE" ;;
            utf-16)   from="UTF-16LE" ;;
            utf-32le) from="UTF-32LE" ;;
            utf-32be) from="UTF-32BE" ;;
            binary)   grep -qU $'\x00' "$f" 2>/dev/null && from="UTF-16LE" || continue ;;
            iso-8859-1|unknown-8bit)
                # Windows-1252 is a superset of latin-1 and is what Windows editors
                # actually write, so decode as 1252 to keep smart quotes and dashes.
                from="WINDOWS-1252" ;;
        esac
    fi

    is_ps=0
    case "$ext" in ps1|psm1|psd1|ps1xml) is_ps=1 ;; esac

    # Decide what, if anything, needs doing.
    needs_conv=0; needs_bom_strip=0; needs_eol=0
    [ -n "$from" ] && needs_conv=1
    [ "$had_utf8_bom" -eq 1 ] && [ "$is_ps" -eq 0 ] && needs_bom_strip=1
    if [ "$KEEP_CRLF" -eq 0 ] && [ "$is_ps" -eq 0 ]; then
        case "$ext" in
            bat|cmd|reg|vbs|sln|csproj|sqlproj) ;;   # legitimately CRLF
            *) grep -qU $'\r$' "$f" 2>/dev/null && needs_eol=1 ;;
        esac
    fi
    [ $((needs_conv + needs_bom_strip + needs_eol)) -eq 0 ] && { skipped=$((skipped+1)); continue; }

    actions=""
    [ "$needs_conv" -eq 1 ]      && actions="$actions ${from}->UTF-8"
    [ "$needs_bom_strip" -eq 1 ] && actions="$actions strip-BOM"
    [ "$needs_eol" -eq 1 ]       && actions="$actions CRLF->LF"

    if [ "$APPLY" -eq 0 ]; then
        printf 'would fix  %-60s %s\n' "$f" "$actions"
        converted=$((converted+1))
        continue
    fi

    tmp="$(mktemp)"
    if [ "$needs_conv" -eq 1 ]; then
        if ! iconv -f "$from" -t UTF-8 "$f" > "$tmp" 2>/dev/null; then
            echo "ERROR      $f  iconv failed from $from -- left untouched"
            rm -f "$tmp"; continue
        fi
    else
        cat "$f" > "$tmp"
    fi

    # Strip any BOM the conversion produced or the file already had.
    if [ "$is_ps" -eq 1 ] && { [ "$had_utf8_bom" -eq 1 ] || [ "$needs_conv" -eq 1 ]; }; then
        # Keep exactly one UTF-8 BOM for PowerShell (5.1 compatibility).
        sed -i '1s/^\xEF\xBB\xBF//' "$tmp"
        printf '\xEF\xBB\xBF' | cat - "$tmp" > "$tmp.b" && mv "$tmp.b" "$tmp"
    else
        sed -i '1s/^\xEF\xBB\xBF//' "$tmp"
    fi

    # Line endings: PowerShell and batch keep CRLF, everything else gets LF.
    if [ "$is_ps" -eq 1 ] || [ "$KEEP_CRLF" -eq 1 ]; then
        case "$ext" in
            ps1|psm1|psd1|ps1xml|bat|cmd|reg|vbs|sln|csproj|sqlproj)
                sed -i -e 's/\r$//' -e 's/$/\r/' "$tmp" ;;
        esac
    elif [ "$needs_eol" -eq 1 ] || [ "$needs_conv" -eq 1 ]; then
        case "$ext" in
            bat|cmd|reg|vbs|sln|csproj|sqlproj) sed -i -e 's/\r$//' -e 's/$/\r/' "$tmp" ;;
            *) sed -i 's/\r$//' "$tmp" ;;
        esac
    fi

    # Preserve permissions; replace content in place so the inode's mode survives.
    cat "$tmp" > "$f" && rm -f "$tmp"
    printf 'fixed      %-60s %s\n' "$f" "$actions"
    converted=$((converted+1))
done < <(collect)

echo
if [ "$APPLY" -eq 1 ]; then
    echo "$converted file(s) fixed, $skipped already correct."
    echo "Review with 'git diff --stat', then commit ALONE:"
    echo "  git commit -am 'Convert files to UTF-8 and normalize line endings'"
else
    echo "$converted file(s) would be fixed, $skipped already correct."
fi
