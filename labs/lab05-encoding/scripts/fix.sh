#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8 with BOM, CRLF -> LF
# Run from labs/lab05-encoding:  sh scripts/fix.sh
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv

printf '\357\273\277' > "$out"                          # 1. BOM (EF BB BF) so Excel detects UTF-8 on double-click
iconv -f RK1048 -t UTF-8 "$in" | sed 's/\r$//' >> "$out" # 2. KZ-1048 -> UTF-8, 3. CRLF -> LF
