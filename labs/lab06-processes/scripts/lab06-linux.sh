#!/bin/bash
# Lab 6, Linux part. Run on lab01 as:  sudo bash lab06-linux.sh
# 1) facts about one process (systemd, PID 1 = Linux service manager) for the three-tool comparison
# 2) memory pressure: allocate until swap fills and the OOM killer acts; free -h before/during/after
# 3) kernel log extract of what the kernel did
set -u
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }
OUT="$(getent passwd "${SUDO_USER:-root}" | cut -d: -f6)/lab06-evidence"
mkdir -p "$OUT"; rm -f "$OUT"/*.txt
run() { echo "root@$(hostname):# $*"; eval "$*" 2>&1; echo; }

# ---------- 1. one process, seen from /proc and ps ----------
P=1
{ echo "# Lab 6 - process facts for systemd (PID 1) on $(hostname) - $(date '+%F %T %Z')"; echo
  run "ps -o pid,comm -p 1"
  run "ps -o pid,ppid,user,stat,nlwp,vsz,rss,%mem,%cpu,lstart,cmd -p $P"
  run "ps -o ppid= -p $P    # parent PID: 0 = no user-space parent, PID 1 is started by the kernel itself"
  run "grep -E '^(Name|State|PPid|Threads|VmPeak|VmSize|VmRSS|RssAnon|RssFile|VmSwap)' /proc/$P/status"
  run "ls /proc/$P/fd | wc -l    # number of open file descriptors"
  run "ls -l /proc/$P/fd"
  run "grep -E '^(Rss|Pss|Shared_Clean|Shared_Dirty|Private_Clean|Private_Dirty|Swap):' /proc/$P/smaps_rollup"
} > "$OUT/process-systemd.txt"

# ---------- 2. memory pressure ----------
# the guest was installed without swap (htop: Swp 0K/0K) -> add a 2 GB swap file first, keep the log of it
{ echo "# Lab 6 - swap check before the experiment - $(date '+%F %T %Z')"; echo
  run "swapon --show; free -h    # empty swapon output = no swap at all"
  if [ -z "$(swapon --show --noheadings)" ]; then
    run "fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile"
    run "swapon --show; free -h"
  fi; } > "$OUT/swap-setup.txt"

cat > /tmp/hog.py <<'EOF'
import time, sys
chunks = []
mb = 0
while True:
    b = bytearray(100 * 1024 * 1024)        # 100 MB
    for i in range(0, len(b), 4096):          # touch every page so it is really used
        b[i] = 1
    chunks.append(b)
    mb += 100
    print(f"{time.strftime('%H:%M:%S')} allocated {mb} MB", flush=True)
EOF

{ echo "# Lab 6 - memory pressure on $(hostname) - $(date '+%F %T %Z')"
  echo "# guest: $(nproc) vCPU, $(free -h | awk '/Mem:/ {print $2}') RAM, swap: $(swapon --show=NAME,SIZE --noheadings | tr '\n' ' ')"; echo
  echo "################ BEFORE ################"
  run "free -h"
  run "swapon --show"
  run "cat /proc/sys/vm/swappiness /proc/sys/vm/overcommit_memory    # swappiness, overcommit mode"
  run "time ls / > /dev/null    # baseline responsiveness"

  echo "################ DURING ################"
  echo "root@$(hostname):# python3 /tmp/hog.py > /tmp/hog.log &    # allocate 100 MB/step, touch every page"
  python3 /tmp/hog.py > /tmp/hog.log 2>&1 &
  HOG=$!
  echo "hog PID = $HOG"; echo
  T0=$(date +%s)
  while kill -0 $HOG 2>/dev/null; do
    echo "---- t+$(( $(date +%s) - T0 ))s  $(tail -n1 /tmp/hog.log)"
    free -h | sed -n '1,3p'
    grep -E '^(VmRSS|VmSwap)' /proc/$HOG/status 2>/dev/null | tr '\n' ' '; echo
    TIMEFORMAT="responsiveness: 'ls /' took %R s"; time ls / > /dev/null
    vmstat 1 2 | tail -n1 | awk '{print "vmstat: si=" $7 " KB/s swapped in, so=" $8 " KB/s swapped out, wa=" $16 "% IO wait"}'
    echo
    sleep 2
  done
  wait $HOG; RC=$?
  echo "hog process ended, exit status $RC (137 = killed by SIGKILL)"
  echo "last lines of its output:"; tail -n3 /tmp/hog.log; echo

  echo "################ AFTER ################"
  sleep 3
  run "free -h"
  run "time ls / > /dev/null"
} > "$OUT/memory-pressure.txt" 2>&1

# ---------- 3. kernel log ----------
{ echo "# Lab 6 - kernel log extract, boot of $(uptime -s) - $(date '+%F %T %Z')"; echo
  run "journalctl -k -b --no-pager | grep -i -E 'out of memory|oom|killed process' "
  run "journalctl -k -b --no-pager | grep -A 45 'invoked oom-killer' | head -n 90    # full OOM report"
  run "dmesg -T | grep -i -E 'oom|killed process' | tail -n 20"
} > "$OUT/kernel-log-extract.txt"

chown -R "${SUDO_USER:-root}": "$OUT"
echo "done:"; ls -l "$OUT"; grep -h -i "killed process" "$OUT/kernel-log-extract.txt" | head -n 2
