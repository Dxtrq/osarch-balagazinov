# Lab 6 — Live processes and memory pressure

Pair: Damir Balagazinov (alone)
Machine: Windows 11 host, VirtualBox — `lab01-ubuntu` (Ubuntu 26.04.1, 2 vCPU, 3.3 GiB usable RAM) and `lab02-windows` (Windows 11 Enterprise Evaluation, 2 vCPU, 4 GB RAM)
Date: 21.11.2026

## What I did

### 1. One process in three tools

A Linux process and a Windows process can never be the *same* process, so I picked the process with the **same job** on both systems — the service manager, the process that starts and supervises all background services:

- **Windows:** `services.exe` (Service Control Manager), looked at in **Task Manager** and **Process Explorer** at the same moment (18:47–18:49 guest time), plus `Get-Process` / `Win32_Process` as text.
- **Linux:** `systemd`, **PID 1**, looked at in **htop**, plus `ps` and `/proc/1/*` as text.

```bash
# Linux (inside lab01, as root) — from scripts/lab06-linux.sh
htop -p 1
ps -o pid,ppid,user,stat,nlwp,vsz,rss,%mem,%cpu,lstart,cmd -p 1
grep -E '^(Name|State|PPid|Threads|VmSize|VmRSS|RssAnon|RssFile|VmSwap)' /proc/1/status
ls /proc/1/fd | wc -l
```

```powershell
# Windows (inside lab02, admin) — from scripts/lab06-windows.ps1
Get-Process -Id 860 | Format-List Id, HandleCount, Threads, WorkingSet64, PrivateMemorySize64, VirtualMemorySize64
Get-CimInstance Win32_Process -Filter 'ProcessId=860' | Format-List ProcessId, ParentProcessId, HandleCount, ThreadCount
```

### 2. Memory pressure on Linux

```bash
sudo bash lab06-linux.sh      # in lab01; the parts that matter:
swapon --show                 # → nothing: the guest had NO swap (see "What did not work")
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
python3 /tmp/hog.py &         # allocate 100 MB per step and write to every page
# every 2 s: free -h, VmRSS/VmSwap of the hog, time ls /, vmstat si/so/wa
journalctl -k -b | grep -i -E 'out of memory|oom|killed process'
```

### 3. Same class of event on Windows

```powershell
powershell -ExecutionPolicy Bypass -File \\VBoxSvr\lab06\scripts\lab06-windows.ps1
# allocates 100 MB byte arrays in PowerShell and touches every page, logs RAM / commit / pagefile,
# then reads the System log for Microsoft-Windows-Resource-Exhaustion-Detector
```

## Result

### The three tools on one process

| | Task Manager (Windows) | Process Explorer (Windows) | htop (Linux) |
|---|---|---|---|
| Process | `services.exe` | `services.exe` | `systemd` |
| PID | 860 | 860 | 1 |
| Parent | **not shown at all** | tree: under `wininit.exe` (728) | not in default view; `ps`: PPID **0** (started by the kernel) |
| Memory figure(s) | **Memory (active private working set): 3,724 K** | **Private Bytes: 4,512 K**, **Working Set: 11,520 K** | **VIRT 25,196**, **RES 16,444**, **SHR 11,708** (KiB) |
| Handles / FDs | not in the default columns | not in the default columns; `Get-Process`: **HandleCount 610**, 7 threads | not shown; `/proc/1/fd`: **147** file descriptors, 1 thread |
| Description | "Services and Controller app" | *empty* (Description and Company columns blank) | full command line `/usr/lib/systemd/systemd --switched-root --system` |

### Where the tools disagree or use different names

1. **Three different memory numbers for the same process at the same moment.** Task Manager 3,724 K, Process Explorer 4,512 K and 11,520 K. They measure different things:
   - Task Manager's default *Memory* = **active private working set** — only the private pages that are in RAM right now.
   - Process Explorer *Private Bytes* = all private memory the process has **committed**, whether it is in RAM or in the pagefile (`Get-Process` PrivateMemorySize = 4,452 K agrees).
   - Process Explorer *Working Set* = **everything** in RAM for this process, private **and** shared DLL pages (`Get-Process` WorkingSet = 11,564 K agrees).
   So Task Manager shows the smallest number by design; neither tool is "wrong".
2. **Same idea, different names on Linux:** Windows *Working Set* ≈ Linux **RSS / RES** (16,444 KiB, identical in htop, `ps` and `/proc/1/status` VmRSS). The shared part — Windows "shareable working set" — is htop's **SHR** (11,708 KiB = `RssFile` in `/proc`). The private part ≈ `RssAnon` (4,736 KiB). Virtual size: htop **VIRT** 25,196 KiB vs Windows **Virtual Size 2,101,321 MB (~2 TB)** — on 64-bit Windows a process reserves a huge address range without using it, so this number means almost nothing.
3. **Handles vs file descriptors.** Windows counts **610 handles** for `services.exe`: files, but also registry keys, events, mutexes, threads, ALPC ports. Linux counts **147 file descriptors** for systemd — and on Linux "file" also covers sockets, pidfds, inotify and BPF programs (see `ls -l /proc/1/fd` in `evidence/process-systemd.txt`). The numbers cannot be compared directly.
4. **Parent.** Task Manager does not show a parent at all. Process Explorer draws the tree (`wininit.exe` → `services.exe`), and `Win32_Process` shows that wininit's own parent, PID 624, **no longer exists** — that is why Process Explorer draws wininit at the top level. On Linux PID 1 has parent **0**: no process started it, the kernel did.
5. **Missing information in Process Explorer.** For `services.exe` the Description and Company columns are empty, while Task Manager shows "Services and Controller app". while Task Manager gets the description some other way. My guess is that this is because `services.exe` is a *protected* process that even an elevated Process Explorer cannot fully open; Task Manager also leaves *Architecture* blank for it, as for the other protected system processes in the list (`csrss.exe`, `smss.exe`, `lsass.exe`).

### Memory pressure — Linux (`evidence/memory-pressure.txt`)

| | used | free | available | swap used | `ls /` took | vmstat |
|---|---|---|---|---|---|---|
| **Before** (13:29:51) | 466 Mi | 2.5 Gi | 2.9 Gi | 0 B of 2.0 Gi | 0.006 s | — |
| During t+9 s (2,500 MB allocated) | 2.9 Gi | 162 Mi | 446 Mi | **0 B** | 0.036 s | so=0 |
| During t+18 s (2,900 MB) | 3.0 Gi | 404 Mi | 362 Mi | **331 Mi** | 0.057 s | so=44,544 KB/s, wa=3 % |
| During t+22 s (3,400 MB) | 3.2 Gi | 149 Mi | 105 Mi | 606 Mi | 0.242 s | so=74,352 KB/s, wa=14 % |
| During t+46 s (4,800 MB) | 3.2 Gi | 149 Mi | 100 Mi | **1.9 Gi** | **0.360 s** | so=64,368 KB/s, wa=16 % |
| **Killed** at 5,100 MB (13:30:40) | | | | | | exit status 137 = SIGKILL |
| **After** (13:30:45) | 382 Mi | 3.0 Gi | 2.9 Gi | 31 Mi | 0.012 s | — |

What happened, in order:
1. While free RAM lasted, swap stayed at **0** — the kernel first gave away the page cache (buff/cache fell from 573 Mi to ~140 Mi).
2. At ~2.9 GB the RAM was full and the kernel started **swapping out** the hog's pages: 44–100 MB/s written to swap, I/O wait up to 16 %.
3. **Responsiveness:** a simple `ls /` became **60× slower** (0.006 → 0.36 s). The console itself still reacted, but with visible pauses.
4. When swap was almost full (1.9 of 2.0 Gi) and a page fault could not be satisfied, the **OOM killer** chose the process with the largest memory footprint and sent it **SIGKILL** (exit status 137). Nothing else was killed.
5. Seconds later memory and swap were back to normal.

**The kernel's record** (`evidence/kernel-log-extract.txt`):
```
Nov 21 13:30:40 lab01 kernel: python3 invoked oom-killer: gfp_mask=0x440dc0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_COMP), order=0, oom_score_adj=0
Nov 21 13:30:40 lab01 kernel: oom-kill:constraint=CONSTRAINT_NONE,...,global_oom,task_memcg=/user.slice/user-1000.slice/session-1.scope,task=python3,pid=1744,uid=0
Nov 21 13:30:40 lab01 kernel: Out of memory: Killed process 1744 (python3) total-vm:5343696kB, anon-rss:3163812kB, file-rss:2400kB, shmem-rss:0kB, UID:0 pgtables:10300kB oom_score_adj:0
```
`global_oom` = the whole machine ran out, not a cgroup limit; `anon-rss 3,163,812 kB` = ~3 GB of the hog was in RAM at the moment of the kill, the rest in swap.

### Memory pressure — Windows (`evidence/windows-memory-pressure.txt`)

| | RAM free | commit used / limit | pagefile allocated / used |
|---|---|---|---|
| **Before** (18:52:08) | 1,784 MB of 4,077 | 2,020 / 5,485 MB | 1,408 / 3 MB |
| During — 2,000 MB allocated | 23 MB | 4,035 / 5,485 MB | 1,408 / 13 MB |
| During — 3,500 MB | 67 MB | 5,556 / **6,048** MB | **1,970** / 16 MB |
| During — 6,000 MB | 21 MB | 8,084 / **8,910** MB | **4,832** / 161 MB |
| During — 9,500 MB | 168 MB | 11,640 / 11,900 MB | 7,823 / 280 MB |
| **Allocation failed** at 9,900 MB (18:52:54) | 327 MB | 12,036 / 12,091 MB | 8,014 / 280 MB |
| **After** (18:53:03) | 2,994 MB | 2,144 / 6,621 MB | 2,543 / 275 MB |

**The event log record** (`evidence/windows-event-log-extract.txt`), System log:
```
TimeCreated : 11/21/2026 6:52:53 PM    Id : 2004    Level : Warning
Provider    : Microsoft-Windows-Resource-Exhaustion-Detector
Message     : Windows successfully diagnosed a low virtual memory condition. The following programs consumed
              the most virtual memory: powershell.exe (2808) consumed 10504773632 bytes, MsMpEng.exe (3340) ...
```

### Linux vs Windows — the same class of event, handled differently

| | Linux | Windows |
|---|---|---|
| Limit that is hit | RAM + swap (2 GB fixed swap file) | **commit limit** = RAM + pagefile, and the pagefile **grows automatically** (1.4 → 8.0 GB, limit 5.5 → 12.1 GB) |
| What happens to the process | **killed** by the OOM killer (SIGKILL, no chance to react) | **not killed**: the allocation call fails, the program gets `OutOfMemoryException` and can handle it |
| Who is blamed | the kernel picks a victim by `oom_score` | nobody is killed; the event *names* the top consumers |
| Log record | kernel ring buffer / journal: `Out of memory: Killed process 1744 (python3)` | System log, event **2004**, Resource-Exhaustion-Detector |
| Got to | 5.1 GB allocated | 9.9 GB allocated |

One more difference I did not expect: Windows committed ~12 GB but used only 280 MB of the pagefile, while Linux wrote 1.9 GB to swap for a smaller amount. My allocator writes one byte per 4 KB page, so the pages are almost empty; Windows 11 compresses memory pages in RAM (the *Memory Compression* process in Process Explorer) before paging them out, while the Linux kernel here wrote them to swap as they were. I did not measure the compression directly, so this is my explanation, not a proven fact.

## What did not work the first time

1. **Wrong process choice.** I first chose `VBoxService` (the VirtualBox guest service), because it exists on both guests. `pgrep VBoxService` on Ubuntu returned nothing — no VirtualBox guest service runs in this Ubuntu guest. So I switched to the *role* that exists on both: the service manager (`systemd` / `services.exe`).
2. **No swap at all on Ubuntu.** htop showed `Swp [0K/0K]` and `swapon --show` printed nothing — this VM had no swap configured at all (the Ubuntu installer usually creates `/swap.img`; here there was none). Without swap the lab's "allocate until the machine starts swapping" is impossible: the OOM killer would fire as soon as RAM is full. I created a 2 GB swap file first (`evidence/swap-setup.txt`) and then ran the experiment.
3. **Process Explorer keyboard trap.** While trying to add the *Handles* column with the keyboard, I pressed Space in the main window — that **pauses** Process Explorer's refresh ("Paused" in the status bar) and the numbers freeze. I took the screenshot again after un-pausing and took the handle count from `Get-Process` instead.

## Evidence

- [evidence/task-manager.png](evidence/task-manager.png) — Task Manager → Details, `services.exe` PID 860 selected, Memory (active private working set) 3,724 K
- [evidence/process-explorer.png](evidence/process-explorer.png) — Process Explorer tree `wininit.exe` → `services.exe` 860, Private Bytes / Working Set
- [evidence/htop.png](evidence/htop.png) — htop `-p 1`: systemd, VIRT/RES/SHR; header shows `Swp [0K/0K]` before the swap file
- [evidence/process-systemd.txt](evidence/process-systemd.txt) — `ps`, `/proc/1/status`, `/proc/1/fd` (147), `smaps_rollup` for systemd
- [evidence/windows-process-services.txt](evidence/windows-process-services.txt) — `Get-Process` / `Win32_Process` for services.exe: handles 610, threads 7, parent 728 wininit
- [evidence/swap-setup.txt](evidence/swap-setup.txt) — no swap before, 2 GB swap file created
- [evidence/memory-pressure.txt](evidence/memory-pressure.txt) — Linux `free -h` before / during (every 2 s) / after, swap-out rate, `ls` time, exit status 137
- [evidence/kernel-log-extract.txt](evidence/kernel-log-extract.txt) — kernel OOM report: `Out of memory: Killed process 1744 (python3)`
- [evidence/windows-memory-pressure.txt](evidence/windows-memory-pressure.txt) — Windows RAM / commit / pagefile before / during / after, `OutOfMemoryException`
- [evidence/windows-event-log-extract.txt](evidence/windows-event-log-extract.txt) — System log event 2004, Resource-Exhaustion-Detector
- [scripts/lab06-linux.sh](scripts/lab06-linux.sh), [scripts/lab06-windows.ps1](scripts/lab06-windows.ps1) — the scripts that produced the text evidence
