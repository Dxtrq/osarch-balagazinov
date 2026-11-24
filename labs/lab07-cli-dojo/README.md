# Lab 7 — CLI dojo

Pair: Damir Balagazinov (alone) · Machine: Windows 11 host, VirtualBox guest `lab02-windows` (Windows 11 Enterprise Evaluation, build 26100)
Date: 25.11.2026 · **Started: 12:27 AM · Finished: 12:36 AM** (guest clock, `time /t`)

Everything was done in **Command Prompt** (`cmd.exe`, prompt `C:\dojo>`, not `PS C:\…>`): a normal window for 1–17 and 19, and an **Administrator** Command Prompt for 18 and 20. No File Explorer, Settings, Task Manager or Control Panel. The command history of both windows is saved with `doskey /history` in [evidence/history-normal-window.txt](evidence/history-normal-window.txt) and [evidence/history-admin-window.txt](evidence/history-admin-window.txt).

Working folder: `mkdir C:\dojo & cd /d C:\dojo & mkdir evidence` (12:27).

## Results — 20 of 20 solved

| # | Challenge | Command | Time |
|---|-----------|---------|------|
| 1 | Print the full path of the current folder | `cd` | 12:27 |
| 2 | Create `C:\dojo\a\b\c` with one command | `mkdir C:\dojo\a\b\c` (checked with `dir /s /b C:\dojo\a`) | 12:27 |
| 3 | Write today's date into `C:\dojo\info.txt` | `date /t > C:\dojo\info.txt` | 12:28 |
| 4 | Append the computer name, then print the file | `hostname >> C:\dojo\info.txt` then `type C:\dojo\info.txt` → `Wed 11/25/2026` / `lab02-windows` | 12:28 |
| 5 | Home folder and computer name from environment variables | `echo %USERPROFILE% %COMPUTERNAME%` → `C:\Users\dxtra LAB02-WINDOWS` | 12:28 |
| 6 | Every `.exe` in System32 starting with "net" | `dir /b C:\Windows\System32\net*.exe` | 12:28 |
| 7 | Count the `.dll` files in System32 — one number | `dir /b C:\Windows\System32\*.dll \| find /c /v ""` → **3441** | 12:28 |
| 8 | Only the IPv4 address and default gateway lines | `ipconfig \| findstr "IPv4 Gateway"` → 10.0.2.4 / 10.0.2.1 | 12:28 |
| 9 | MAC address of the network adapter | `getmac /v /fo list` → Physical Address **08-00-27-70-22-21** | 12:28 |
| 10 | Ping the default gateway exactly two times | `ping -n 2 10.0.2.1` | 12:29 |
| 11 | IP of ubuntu.com and which DNS server answered | `nslookup ubuntu.com` → server 192.168.100.1; 185.125.190.20/.29/.21 + 3 IPv6 | 12:29 |
| 12 | Route to 8.8.8.8 without name lookups | `tracert -d -h 12 -w 500 8.8.8.8` | 12:29 |
| 13 | Which PID listens on port 135 | `netstat -ano \| findstr :135` → **740** | 12:29 |
| 14 | Turn that PID into a program name | `tasklist /fi "PID eq 740"` → **svchost.exe** | 12:30 |
| 15 | Start Notepad, then end it from the command line | `start notepad & timeout /t 3 /nobreak > nul & tasklist /fi "imagename eq notepad.exe" & taskkill /im notepad.exe /f` | 12:30 |
| 16 | Every svchost.exe with the services inside it | `tasklist /svc /fi "imagename eq svchost.exe"` | 12:30 |
| 17 | **Read the help.** Files in `C:\Windows\Logs` (and below) changed in the last 7 days | `forfiles /p C:\Windows\Logs /s /d +11/18/2026 /c "cmd /c echo @fdate @ftime @path"` | 12:31 |
| 18 | When the machine last booted — one line (**Administrator**) | `systeminfo \| findstr /c:"System Boot Time"` → `11/25/2026, 12:22:53 AM` | 12:32 |
| 19 | **Read the help.** Mirror `C:\dojo` to `C:\dojo-copy`, skip `*.txt`, write a log | `robocopy C:\dojo C:\dojo-copy /MIR /XF *.txt *.log /R:1 /W:1 /LOG:C:\dojo\robocopy.log` | 12:32 |
| 20 | Check protected system files without repairing (**Administrator**) and say what the result means | `sfc /verifyonly` → *Windows Resource Protection did not find any integrity violations*, exit code 0 | 12:36 |

**What the result of 20 means:** `/verifyonly` compares every protected system file with the known-good copy in the component store (`C:\Windows\WinSxS`) and only *reports* — it does not replace anything (`/scannow` would). "Did not find any integrity violations" means no protected Windows file is missing, modified or corrupted, so there is nothing to repair; exit code 0 confirms it. Had it found violations, the next step would be `sfc /scannow` (and `DISM /Online /Cleanup-Image /RestoreHealth` if the component store itself were damaged). The admin window was needed: `whoami /groups | find "S-1-16-12288"` showed **High Mandatory Level** before running 18 and 20.

## Read the help

- **17 — `forfiles /?`.** The switch is **`/D`**. The help says: *"Selects files with a last modified date greater than or equal to (+), or less than or equal to (−), the specified date using the "MM/dd/yyyy" format; or … the current date plus "dd" days, or … minus "dd" days."* So `/D -7` (my first guess) means *older* than 7 days — it returned 89 files, the wrong set. "Changed in the last 7 days" needs **`/D +date`**: today is 11/25/2026, so `/D +11/18/2026`. Also used from the same page: `/P` (path), `/S` (recurse into subfolders), `/C "cmd /c echo @fdate @ftime @path"` (what to do with each file — the help notes that internal CMD commands must be preceded by `cmd /c`). Result: 107 files and folders dated 18–25 Nov.
- **19 — `robocopy /?`** (filtered with `robocopy /? | findstr /i /c:"/MIR " /c:"/XF " /c:"/LOG:" /c:"/R:" /c:"/W:"`). Three switches answer the task: **`/MIR`** — *"MIRror a directory tree (equivalent to /E plus /PURGE)"*, **`/XF file [file]...`** — *"eXclude Files matching given names/paths/wildcards"*, **`/LOG:file`** — *"output status to LOG file"*. The help also showed a trap: **`/R:n`** *"default 1 million"* retries and **`/W:n`** *"default is 30 seconds"* — one locked file would make robocopy wait for days, so I added `/R:1 /W:1`. Result: 6 folders mirrored, both `.txt` files skipped, 0 copied.

## Five hardest

[evidence/output-for-five-hardest.txt](evidence/output-for-five-hardest.txt) — made with `>>`, a header line before each challenge and the command echoed above its output. Re-run in the Administrator window at 12:38–12:43:

- **13 + 14** — `netstat -ano | findstr :135` and `tasklist /fi "PID eq 740"`
- **16** — `tasklist /svc /fi "imagename eq svchost.exe"`
- **17** — the wrong `/D -7` (count: 89) and the correct `forfiles … /d +11/18/2026 …` (107 lines)
- **19** — `robocopy …` with its full log and `dir /s /b C:\dojo-copy` (also [evidence/robocopy.log](evidence/robocopy.log))
- **20** — `sfc /verifyonly`

## What did not work the first time

1. **Challenge 19, log in the root of C:.** `robocopy … /LOG:C:\dojo-robocopy.log` → `Access is denied.` and `ERROR : Invalid Parameter #8`. A standard user may not create files in the root of `C:\`. I moved the log into `C:\dojo\robocopy.log` — but that folder is the *source* of the mirror, so I also excluded `*.log` (`/XF *.txt *.log`); otherwise robocopy would try to copy its own open log file.
2. **Challenge 17, the date sign.** My first guess `/D -7` looked like "the last 7 days" but selects files *older* than 7 days (89 files). Only the help text made the difference between `-dd` and `+date` clear.
3. **Challenge 20, the evidence file.** `sfc /verifyonly >> output-for-five-hardest.txt` produced text like `B.e.g.i.n.n.i.n.g` — sfc writes **UTF-16** when its output is redirected. `type` does not convert it; `more < C:\dojo\sfc-raw.txt >> …` does, so the evidence file stays plain text.
4. **Challenge 12 shows only one hop.** `tracert -d 8.8.8.8` reached 8.8.8.8 in "1 hop" (96–118 ms). The command is right; my explanation is that the guest sits behind VirtualBox's NAT Network, whose NAT engine forwards the probes as its own traffic, so the real hops between the host and Google are invisible from inside the VM.
5. **Challenge 15.** Windows 11 Notepad runs as **two** `Notepad.exe` processes; `taskkill /im notepad.exe` ended both. I used `/f` (force) straight away, so I did not test whether a plain `taskkill` would have been enough.
6. **History is incomplete.** `doskey /history` keeps only the last 50 commands of a window, so the very first commands of the normal window (`cd`, `mkdir`, `date /t`) are no longer in `history-normal-window.txt`. Their output is in the table and the times are from `time /t` on screen.

## AI use

Claude (Anthropic), via Claude Code: typed the commands into the guest's Command Prompt (VirtualBox keyboard input), read the help pages with me, and drafted this README. Every command in the table was actually run in `cmd.exe` on `lab02-windows` at the time shown; the evidence files are copied from `C:\dojo\evidence` through a VirtualBox shared folder.
