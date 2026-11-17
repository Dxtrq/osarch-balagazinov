#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8, CRLF -> LF
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv

iconv -f RK1048 -t UTF-8 "$in" > "$out"          # 1. encoding
sed -i 's/\r$//' "$out"                           # 2. CRLF -> LF
# 3. BOM: not added — Linux tools expect clean UTF-8 (reason in README)
