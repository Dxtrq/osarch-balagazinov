# Lab 5 — Encoding forensics

**Name:** Damir Balagazinov  
**Pair:** Alone  
**Date:** 17.11.2026  
**Tools:** Ubuntu guest (iconv, file, xxd, sed)

## What I received

- **Excel** — mojibake, names unreadable (garbage characters).
- **LibreOffice Calc** — import dialog appeared; default character set produced incorrect Kazakh letters.
- **Terminal (`cat`)** — Cyrillic and Kazakh letters shown as garbage / high-bit characters.

## Diagnosis (made before the fix)

`file` said:
```
Non-ISO extended-ASCII text, with CRLF line terminators
```
(evidence/file-before.txt)

First bytes (hexdump):
```
00000000: 4944 3bd4 e0ec e8eb e8ff 3bc8 ecff 3bce  ID;.......;...;.
00000020: eef0 eee4 0d0a 3130 313b a3e1 e4b3 f0e0  ......101;......
```
(evidence/hexdump-before.txt)

- **Encoding: KZ-1048 (RK1048)**  
  Reason: single-byte encoding. Kazakh letters present as single high bytes (Ә = `A3`, Қ = `8D`).  
  Windows-1251 produces wrong Kazakh characters (see first-attempt-wp1251.txt).  
  `iconv -f RK1048` yields correct names (see encoding-test-rk1048.txt).

- **Line ending: CRLF**  
  Reason: every line ends with `0D 0A` (visible in hexdump and `cat -A`).

- **BOM: no**  
  Reason: file starts with `49 44 3B` ("ID;"), not `EF BB BF` / `FF FE` / `FE FF`.

- **Separator: semicolon (`;`)**

## Fix

Script used: `scripts/fix.sh` (run from `labs/lab05-encoding`)

```sh
#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8 with BOM, CRLF -> LF
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv

printf '\357\273\277' > "$out"                          # 1. BOM (EF BB BF) so Excel detects UTF-8 on double-click
iconv -f RK1048 -t UTF-8 "$in" | sed 's/\r$//' >> "$out" # 2. KZ-1048 -> UTF-8, 3. CRLF -> LF
```

The committed `evidence/staff-fixed.csv` is exactly the output of this script; it was not opened and re-saved in any editor afterwards. `.gitattributes` marks `*.csv` as `-text`, so Git stores both CSV files byte for byte (no automatic CRLF/LF conversion).

Decisions for the fixed file:
- **Encoding:** UTF-8 — the only encoding that holds both Russian and Kazakh letters and is read the same way on Windows and Linux.
- **Line endings:** LF (Unix) — CRLF leaves a hidden `\r` at the end of the last field, which breaks scripts (`$'\r': command not found`, `"Алматы\r" != "Алматы"`). Excel and LibreOffice read LF without problems.
- **BOM: added (`EF BB BF`)** — when a CSV is opened by double-click, Excel assumes the ANSI code page unless the file starts with a UTF-8 BOM; without it the names turn into mojibake again. LibreOffice and `cat` handle the BOM. Trade-off: a script that reads the header must strip the BOM (e.g. Python `encoding='utf-8-sig'`), otherwise the first column is called `\ufeffID`.

## Verification

`file` after conversion (evidence/file-after.txt):
```
evidence/staff-fixed.csv: Unicode text, UTF-8 (with BOM) text
```
There is no "with CRLF line terminators" any more, `grep -c $'\r'` returns `0`, and `cat -A` shows every line ending in `$` with no `^M` (evidence/line-endings-after.txt).

The hex of the fixed file starts with the BOM `EF BB BF`, then `49 44 3B` (`ID;`), then `D0 A4` = **Ф** (first letter of `Фамилия`). The Kazakh letters are now two-byte UTF-8 sequences: **Ә = `D3 98`**, **Қ = `D2 9A`** (shown with `printf | xxd` at the end of evidence/file-after.txt).

All names (including the Kazakh letters Ә, Қ, Ү, Ө, Ғ, Ұ, Ң, І) read correctly in:
- Microsoft Excel — `staff-fixed.csv` opened by double-click
- LibreOffice Calc — `staff-fixed.csv`, Character set: Unicode (UTF-8), separator `;`
- `cat evidence/staff-fixed.csv` in the Linux terminal

→ see `evidence/opens-correctly.png` (each panel shows the application and the file name `staff-fixed.csv` in its title bar)

## What did not work the first time

I first tried `iconv -f WINDOWS-1251`. Russian names looked almost correct, but Kazakh letters (Ә, Қ, Ұ, etc.) came out wrong (see evidence/first-attempt-wp1251.txt).  

That forced me to look at the actual bytes of the Kazakh characters and test RK1048 / KZ-1048, which matched perfectly.

Second problem: the line endings of the committed files did not match my evidence. Git on Windows has `core.autocrlf=true`, so on commit it silently stored `staff-broken.csv` with LF instead of the original CRLF, and the `staff-fixed.csv` I later uploaded through the GitHub web page was a different copy (with BOM and CRLF), not the output of my script. I fixed it by adding `.gitattributes` (`*.csv -text`, so Git never touches CSV bytes), regenerating `staff-fixed.csv` with `scripts/fix.sh` only, and re-running `file` / `xxd` / `cat -A` on the committed file. Lesson: verify the file that is actually in the repository, not a copy that was opened in an editor.

## Evidence

- [evidence/staff-broken.csv](evidence/staff-broken.csv) — original file, untouched
- [evidence/staff-fixed.csv](evidence/staff-fixed.csv) — converted file
- [evidence/file-before.txt](evidence/file-before.txt) — `file` + hexdump + cat -A of the original
- [evidence/hexdump-before.txt](evidence/hexdump-before.txt) — first bytes
- [evidence/file-after.txt](evidence/file-after.txt) — `file`, hexdump, BOM check and CR count of the fixed file
- [evidence/encoding-test-rk1048.txt](evidence/encoding-test-rk1048.txt) — proof that RK1048 decodes correctly
- [evidence/first-attempt-wp1251.txt](evidence/first-attempt-wp1251.txt) — failed Windows-1251 attempt
- [evidence/line-endings-after.txt](evidence/line-endings-after.txt) — `cat -A` and CR count: LF only after conversion
- [evidence/opens-correctly.png](evidence/opens-correctly.png) — Excel + LibreOffice + terminal side by side
