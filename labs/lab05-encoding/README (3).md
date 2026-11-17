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

Script used: `scripts/fix.sh`

```sh
#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8, CRLF -> LF
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv

iconv -f RK1048 -t UTF-8 "$in" > "$out"          # 1. encoding
sed -i 's/\r$//' "$out"                           # 2. CRLF -> LF
# 3. BOM: not added — Linux tools expect clean UTF-8
```

Decisions for the fixed file:
- **Encoding:** UTF-8
- **Line endings:** LF (Unix) — cleaner for scripts and Linux tools; CRLF can cause `$'\r': command not found`
- **BOM:** not added — BOM can stick to the first column name (`﻿ID`) and break some tools. Excel can still open the file correctly via Data → From Text/CSV or when the locale is set properly.

## Verification

`file` after conversion:
```
Unicode text, UTF-8 text
```
(evidence/file-after.txt)

Hex after conversion shows proper UTF-8 sequences for Cyrillic/Kazakh letters (`D0 A4` = Ә, `D0 9A` = Қ, etc.).

All names (including Kazakh letters Ә, Қ, Ү, Ө, Ғ, Ұ, Ң, І) read correctly in:
- Excel
- LibreOffice Calc
- `cat` in the Linux terminal

→ see `evidence/opens-correctly.png`

## What did not work the first time

I first tried `iconv -f WINDOWS-1251`. Russian names looked almost correct, but Kazakh letters (Ә, Қ, Ұ, etc.) came out wrong (see evidence/first-attempt-wp1251.txt).  

That forced me to look at the actual bytes of the Kazakh characters and test RK1048 / KZ-1048, which matched perfectly.

## Evidence

- [evidence/staff-broken.csv](evidence/staff-broken.csv) — original file, untouched
- [evidence/staff-fixed.csv](evidence/staff-fixed.csv) — converted file
- [evidence/file-before.txt](evidence/file-before.txt) — `file` + hexdump + cat -A of the original
- [evidence/hexdump-before.txt](evidence/hexdump-before.txt) — first bytes
- [evidence/file-after.txt](evidence/file-after.txt) — `file` + hexdump of the fixed file
- [evidence/encoding-test-rk1048.txt](evidence/encoding-test-rk1048.txt) — proof that RK1048 decodes correctly
- [evidence/first-attempt-wp1251.txt](evidence/first-attempt-wp1251.txt) — failed Windows-1251 attempt
- [evidence/line-endings-after.txt](evidence/line-endings-after.txt) — confirmation of LF after conversion
- [evidence/opens-correctly.png](evidence/opens-correctly.png) — Excel + LibreOffice + terminal side by side
