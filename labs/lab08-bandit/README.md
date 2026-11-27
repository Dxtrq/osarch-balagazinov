# Lab 8 — Bandit 0–12, and your first bash script

Pair: Damir Balagazinov (alone) · Machine: Windows 11 host, OpenSSH client from PowerShell; script run in Git Bash
Date: 27.11.2026

**No passwords are in this repository** — not in the table, not in the evidence files (ssh never echoes a typed password).

## What I did

Every level was solved with one non-interactive ssh call: the command after the host runs on the Bandit server, prints its result and logs out. The level password was pasted at the ssh prompt.

```powershell
ssh -p 2220 banditN@bandit.labs.overthewire.org "<command>"
```

### Levels 0–12

| Level | Command that got the password | Reasoning (one sentence) |
|---|---|---|
| 0 | `ssh -p 2220 bandit0@bandit.labs.overthewire.org` then `cat readme` | The level 0 login is given on the website, and `ls -la` showed a single readable file, `readme`, in the home directory. |
| 1 | `cat ./-` | The file is called `-`, and `cat -` would read standard input instead of the file, so I gave a path (`./-`) that cannot be mistaken for "stdin". |
| 2 | `cat -- '--spaces in this filename--'` | The name has spaces (needs quotes) and starts with `--` (looks like an option), so `--` tells `cat` that options are over and everything after it is a file name. |
| 3 | `ls -la inhere` then `find inhere -type f -exec cat {} +` | `ls` without `-a` showed an empty `inhere`; `-a` revealed a hidden file whose name starts with dots (`...Hiding-From-You`). |
| 4 | `file ./inhere/* \| grep text \| cut -d: -f1 \| xargs cat` | Nine of the ten `-fileNN` files are binary `data`, and `file` identifies the only one that is `ASCII text` (`-file07`) without me having to open each one. |
| 5 | `find inhere -type f -size 1033c ! -executable -exec cat {} +` | The three properties in the task map directly onto `find` tests (`-size 1033c` = exactly 1033 bytes, `! -executable`), which leaves exactly one file in 20 directories: `inhere/maybehere07/.file2`. |
| 6 | `find / -user bandit7 -group bandit6 -size 33c 2>/dev/null` then `cat` the result | The file can be anywhere on the server, so I searched from `/` by owner, group and size, and hid the hundreds of "Permission denied" lines with `2>/dev/null` (found `/var/lib/dpkg/info/bandit7.password`). |
| 7 | `grep millionth data.txt` | The password sits next to the word "millionth" in a 98,567-line file, so I searched for the word instead of reading the file. |
| 8 | `sort data.txt \| uniq -u` | The password is the only line that occurs once; `uniq -u` prints unique lines but only compares *neighbouring* lines, so the file must be sorted first. |
| 9 | `strings data.txt \| grep ==` | `file` said `data` (binary); `strings` extracts the printable runs, and the hint said the password follows several `=` signs. |
| 10 | `base64 -d data.txt` | The file content was one line of letters, digits and `=` padding at the end — the shape of base64 — and decoding it gave "The password is …". |
| 11 | `tr 'A-Za-z' 'N-ZA-Mn-za-m' < data.txt` | Every letter was rotated by 13 (ROT13: "Gur cnffjbeq vf" = "The password is"), and `tr` maps each letter back 13 places while leaving digits alone. |
| 12 | `cd $(mktemp -d) && xxd -r ~/data.txt > f` then a loop: `file -b f` → `gunzip` / `bunzip2` / `tar xOf` until `file` says `ASCII text` | `data.txt` is a hexdump (`xxd -r` turns it back into bytes) of a file compressed many times, and `file` names the format at each step — it took 8 steps: gzip → bzip2 → gzip → tar → tar → bzip2 → tar → gzip → text. |

Level 12, the full command (single quotes so that PowerShell does not touch the `$`):

```bash
cd $(mktemp -d) && xxd -r ~/data.txt > f && for i in $(seq 1 15); do t=$(file -b f); echo step $i: $t;
  case $t in gzip*) mv f f.gz; gunzip f.gz;; bzip2*) mv f f.bz2; bunzip2 f.bz2;;
             POSIX*) tar xOf f > g; mv g f;; ASCII*) cat f; break;; esac; done
```

### The commands I kept retyping

1. **`ssh -p 2220 banditN@bandit.labs.overthewire.org`** — thirteen times, changing only N. This is what the script automates.
2. **A search command** — `find` (levels 3, 5, 6) and `grep` (7, 9, and inside 4).
3. **A decode/transform step** — `file` to see what something is, then `base64 -d`, `tr`, `xxd -r`, `gunzip`/`bunzip2`/`tar`.

## The script — [scripts/bandit.sh](scripts/bandit.sh)

```bash
./bandit.sh LEVEL        # e.g. ./bandit.sh 5  ->  ssh -p 2220 bandit5@bandit.labs.overthewire.org
```

- **Exactly one argument**, otherwise `Error: expected exactly one argument (the level number), got N.` + usage, exit 1.
- **Digits only** (`[[ ${level} =~ ^[0-9]+$ ]]`), otherwise `Error: 'five' is not a level number …`, exit 2. This also rejects `-3` and `5.5`.
- **A level that exists** (0–34), otherwise `Error: level 99 does not exist …`, exit 2.
- `05` is read as 5 (`$((10#${level}))`) — without `10#` bash would treat a leading zero as octal, and `08` would be an error.
- `set -euo pipefail`; all variables quoted; errors go to stderr; `exec ssh` replaces the script with ssh, so ssh's own exit code is what the caller sees.
- No password in the script or on its command line — ssh asks for it.

Made executable with `chmod +x scripts/bandit.sh`; `.gitattributes` keeps it with LF line endings so it runs on Linux after a clone from Windows.

**Two runs against different levels:**
- [evidence/script-run-level-5.txt](evidence/script-run-level-5.txt) — `bandit.sh 5`: connected as `bandit5`, logged in, `ls -la`, `exit`.
- [evidence/script-run-level-0.txt](evidence/script-run-level-0.txt) — `bandit.sh 0`: connected as `bandit0` and reached that level's password prompt (no password typed; cancelled).

**Refusal:** [evidence/script-run-no-argument.txt](evidence/script-run-no-argument.txt) — no argument, `five`, `-3`, two arguments, `99`.

**ShellCheck:** [evidence/shellcheck-clean.txt](evidence/shellcheck-clean.txt) — ShellCheck 0.11.0. The default check had no findings from the start; with **all optional checks** (`-o all`) it reported three `SC2250` style notes (put braces around `$level`, `$PORT`), which I fixed, so the script is now clean in both modes. (The level 5 run was made just before this cosmetic change; the behaviour is identical.)

## What did not work the first time

1. **Wrong password at level 0.** I typed my Ubuntu VM password at the `bandit0@…'s password:` prompt — three times, then `Permission denied (publickey,password)`. The Bandit server is not my machine; level 0's password is published on the OverTheWire page (`bandit0`).
2. **Pasted passwords rejected.** At level 6 and in the first `bandit.sh 5` run, the first paste gave `Permission denied` (a copied space/line break); the second, clean paste worked. In the first script run I was too slow for the second try and the server closed the connection (`Connection closed by … port 2220`), so the password I pasted afterwards landed in PowerShell as a "command". Nothing leaked into the repository, but it showed why the password must never be part of a command line or a script.
3. **PowerShell and `$`.** For level 12 my loop uses `$(...)` and `$t`. Inside a PowerShell double-quoted string those would be expanded by PowerShell *on my machine* before ssh ever sent them, so the whole remote command had to be in single quotes.

## Note on OverTheWire's rules

The Bandit login banner asks players not to post spoilers. This README contains what the course requires (the commands and the reasoning) but no passwords, so a reader still has to play every level to log in.

## AI use

Claude (Anthropic), via Claude Code: chose the commands for each level, wrote `bandit.sh`, ran ShellCheck and drafted this README. All logins were done by me pasting the passwords; Claude never typed a password.
