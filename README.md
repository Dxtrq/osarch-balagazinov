# osarch-balagazinov

Operating System Architecture — Innotech University, Almaty. Semester repository of Damir Balagazinov.

## Status

| Work | Folder | Status |
|---|---|---|
| Lab 0 — Inventory | [labs/lab00-inventory](labs/lab00-inventory/) | submitted |
| Lab 1 — First VM | [labs/lab01-first-vm](labs/lab01-first-vm/) | submitted |
| Lab 2 — Windows VM and network | [labs/lab02-windows-vm](labs/lab02-windows-vm/) | submitted |
| Lab 3 — Teardown | [labs/lab03-teardown](labs/lab03-teardown/) | submitted |
| Lab 4 — Partition, mirror, fail, recover | [labs/lab04-storage](labs/lab04-storage/) | resubmitted 21.11.2026 |
| Lab 5 — Encoding forensics | [labs/lab05-encoding](labs/lab05-encoding/) | resubmitted 21.11.2026 |
| Lab 6 — Processes and memory pressure | [labs/lab06-processes](labs/lab06-processes/) | 21.11.2026 |
| Lab 7 — CLI dojo | [labs/lab07-cli-dojo](labs/lab07-cli-dojo/) | 25.11.2026 |
| Ticket 1 — VM build document | [tickets/ticket1-vm-build-doc](tickets/ticket1-vm-build-doc/) | updated 21.11.2026 |
| Ticket 2 — Office spec | [tickets/ticket2-office-spec](tickets/ticket2-office-spec/) | 21.11.2026 |

## Use of AI assistants

| Tool | Used in | What for |
|---|---|---|
| Claude (Anthropic), Claude Code | Lab 4 resubmission | Writing the scripts that run the fail/recover cycle and record evidence (`scripts/lab04-linux.sh`, `lab04-windows.ps1`), diagnosing the array that came up degraded after reboot, drafting the README. All commands ran on my VMs; the evidence is their real output. |
| Claude (Anthropic), Claude Code | Lab 5 resubmission | Finding the mismatch between the committed CSV and the evidence (Git `autocrlf`, BOM), rewriting `fix.sh`, regenerating evidence, combining my three screenshots into one image, README text. |
| Claude (Anthropic), Claude Code | Lab 6 | Writing `lab06-linux.sh` / `lab06-windows.ps1` (process facts, memory pressure, log extracts), explaining the tool differences, drafting the README. The experiment ran on my VMs. |
| Claude (Anthropic), Claude Code | Lab 7 | Typing the commands into the guest's Command Prompt through VirtualBox keyboard input, reading the forfiles and robocopy help with me, drafting the README. All 20 commands ran in cmd.exe on lab02-windows. |
| Claude (Anthropic), Claude Code | Ticket 1 update | Capturing installer screenshots in a temporary VM, rewriting BUILD.md (troubleshooting table, check lines) and section 2 of the README. |
| Claude (Anthropic), Claude Code | Ticket 2 | Collecting dated prices from shop.kz, drafting the four builds and the README; for the resubmission: taking dated screenshots of every product page, replacing two out-of-stock parts, adding totals to budget.csv, entering the four builds in PCPartPicker (via Claude in Chrome). I checked the reasoning and the totals. |
