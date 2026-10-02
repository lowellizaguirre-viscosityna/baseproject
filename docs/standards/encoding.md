# Text encoding and line endings

## The rule

**Every text file in the repo is UTF-8.** No UTF-16, no UTF-32, no ANSI/Windows-1252.
No BOM, with one narrow exception for PowerShell described below.

This is not a style preference. UTF-16 files break `grep`, `diff`, `sed`, shebangs, git's
diff and merge, code review, most CI linters, and nearly every text tool on Linux. A
UTF-16 file shows up in review as a single unreadable binary blob, so changes to it are
effectively unreviewable.

## Where UTF-16 comes from

It is almost never a choice — it is a default nobody noticed:

| Source | Default | Fix |
| --- | --- | --- |
| Windows PowerShell 5.1 `>` and `>>` redirection | UTF-16LE | Use `Set-Content -Encoding utf8`, never `>` for files you keep |
| PS 5.1 `Out-File`, `Export-Csv`, `Tee-Object` | UTF-16LE ("Unicode") | Pass `-Encoding utf8` explicitly, every time |
| PowerShell ISE "Save As" | UTF-16LE | Stop using ISE; use VS Code |
| SSMS "Save As" / results to file | UTF-16LE on some versions | Save dialogue → Encoding → UTF-8 |
| Notepad on older Windows ("Unicode") | UTF-16LE | Save as UTF-8 |
| `Export-Clixml`, SQLCMD `-u` | UTF-16 | Avoid, or convert on write |

Set this once in your PowerShell profile so the defaults stop fighting you:

```powershell
$PSDefaultParameterValues['Out-File:Encoding']       = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding']    = 'utf8'
$PSDefaultParameterValues['Export-Csv:Encoding']     = 'utf8'
$PSDefaultParameterValues['Tee-Object:Encoding']     = 'utf8'
```

In PowerShell 7+, `utf8` means UTF-8 **without** BOM and `$PSStyle`/`$OutputEncoding`
already default to UTF-8. In 5.1, `utf8` means UTF-8 **with** BOM. That difference is the
whole BOM exception below.

## The PowerShell BOM exception

Windows PowerShell 5.1 reads a BOM-less file as the system ANSI codepage, not UTF-8. A
`.ps1` with no BOM containing an em-dash, a curly quote, or an accented name will execute
with mangled characters on 5.1 — silently, until a string comparison fails.

So:

- **`.ps1` / `.psm1` / `.psd1` that must run on PowerShell 5.1:** keep the file pure ASCII
  if at all possible — then BOM-less UTF-8 is unambiguous and safe. If it genuinely needs
  non-ASCII characters, save UTF-8 **with** BOM and note why in a comment.
- **Scripts targeting PowerShell 7+ only:** UTF-8, no BOM, like everything else. State the
  minimum version with `#requires -Version 7.0` so the expectation is in the file.
- **Everything else** (`.sh`, `.sql`, `.py`, `.ts`, `.md`, `.json`, `.yml`, `.csv`): UTF-8,
  no BOM, no exceptions. A BOM in a `.sh` file breaks the shebang. A BOM in `.json` breaks
  strict parsers. A BOM in `.sql` breaks `sqlcmd` batch parsing.

## Line endings

`.gitattributes` normalizes to LF in the repository and checks out per-file:

- LF in the repo for everything — this is what makes diffs sane
- `.ps1`, `.psm1`, `.psd1`, `.bat`, `.cmd`, `.reg` check out as CRLF, because `.bat`/`.cmd`
  genuinely misbehave with LF and the PowerShell toolchain is CRLF by convention
- `.sh` is **always** LF, even on Windows — CRLF produces
  `/bin/bash^M: bad interpreter`
- Declared binary files are never touched

Never commit mixed line endings within one file. The checker flags them.

## Enforcement

1. **[`.gitattributes`](../../.gitattributes)** — normalization and binary declarations, so
   git stops guessing.
2. **[`.editorconfig`](../../.editorconfig)** — `charset = utf-8`, LF, with the
   PowerShell/batch CRLF exceptions. VS Code honours it via the EditorConfig extension;
   `.vscode/settings.json` sets `files.encoding: utf8` and
   `files.autoGuessEncoding: false` as a second line of defence.
3. **[`scripts/check-encoding.sh`](../../scripts/check-encoding.sh)** — fails on any
   UTF-16/UTF-32 file, any unexpected BOM, any CRLF in a `.sh`, and any mixed-ending file.
   Runs as a pre-commit hook and as a CI gate.
4. **[`scripts/fix-encoding.sh`](../../scripts/fix-encoding.sh)** — converts offenders in
   place, detecting the actual byte order from the BOM rather than assuming. Dry-run by
   default.

A pre-commit hook is the point of highest leverage here: it catches the file the moment
PowerShell writes it, before the encoding reaches history where it is annoying to fix.

## Converting an existing file

Detect, then convert — never assume the byte order:

```bash
file -b --mime-encoding script.ps1          # utf-16be, utf-16le, utf-8, us-ascii...
iconv -f UTF-16BE -t UTF-8 script.ps1 -o /tmp/x && mv /tmp/x script.ps1
```

`scripts/fix-encoding.sh` does exactly this per file, plus BOM stripping and line-ending
normalization, and is safer than a hand-rolled loop because it reads the BOM instead of
trusting the extension. Converting is a content change to every line, so do it in a
**commit of its own** with no other changes — otherwise the real diff is buried.

## Checklist

- [ ] `.gitattributes` and `.editorconfig` present
- [ ] `check-encoding.sh` wired as a pre-commit hook and a CI gate
- [ ] `$PSDefaultParameterValues` encoding defaults set in the authoring profile
- [ ] `.sh` files are LF with no BOM
- [ ] `.ps1` files are ASCII, or UTF-8 with BOM if they target 5.1 and need non-ASCII
- [ ] Encoding conversions committed separately from behaviour changes
