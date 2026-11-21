#!/bin/bash
# Lab 4, run 2 - full fail/recover cycle with sha256 proof (proof.txt + 20 MB random.bin)
# Run on lab01 as:  sudo bash lab04-linux.sh
# Writes every evidence file into ~/lab04-evidence, each command printed above its output.
set -u
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

USER_HOME=$(getent passwd "${SUDO_USER:-root}" | cut -d: -f6)
OUT="$USER_HOME/lab04-evidence"
MNT=/mnt/raid
mkdir -p "$OUT"; rm -f "$OUT"/*.txt

# run CMD -> print "root@host:# CMD", then its output
run() { echo "root@$(hostname):# $*"; eval "$*" 2>&1; echo; }
state() { run "cat /proc/mdstat"; run "mdadm --detail $MD"; }

# --- 0. preconditions -------------------------------------------------------
MD=$(awk '/^md[0-9]+ :/ {print "/dev/"$1; exit}' /proc/mdstat)
[ -n "$MD" ] || { echo "no md array found in /proc/mdstat"; exit 1; }
mkdir -p "$MNT"; mountpoint -q "$MNT" || mount "$MD" "$MNT"

# array came up degraded after boot -> document why, put the missing member back, wait for resync
if ! mdadm --detail "$MD" | grep -q 'State : clean *$'; then
  CUR=$(mdadm --detail "$MD" | awk '/active sync/ {print $NF}')
  BACK=""
  for p in /dev/sdb1 /dev/sdc1 /dev/sdd1; do
    [ -b "$p" ] || continue
    echo "$CUR" | grep -qx "$p" || { BACK=$p; break; }
  done
  [ -b "$BACK" ] || { echo "no partition to re-add - stop"; exit 1; }
  findmnt -S "$BACK" >/dev/null && { echo "$BACK is mounted - stop"; exit 1; }
  { echo "# Lab 4 run 2 - array found DEGRADED after VM boot - $(date '+%F %T %Z')"; echo
    state
    run "mdadm --examine /dev/sdb1 /dev/sdc1 /dev/sdd1 2>&1 | grep -E '^/dev|Array UUID|Update Time|Events|Device Role|Array State|No md superblock'"
    run "journalctl -k -b --no-pager | grep -i -E 'md0|md/raid1|md: ' | head -n 20"
    run "ls -l $MNT    # filesystem still mounted and readable on the surviving disk"
    run "mdadm --zero-superblock $BACK    # stale member, wipe old RAID metadata"
    run "mdadm --manage $MD --add $BACK"
    run "sleep 2; cat /proc/mdstat    # resync in progress"
    run "mdadm --wait $MD; echo resync finished"
    state; } >> "$OUT/array-boot-repair.txt"
fi

# third disk lost its partition -> recreate it (Linux RAID type) so it can be the rebuild target
for d in /dev/sdb /dev/sdc /dev/sdd; do
  [ -b "${d}1" ] && continue
  lsblk -n -o TYPE "$d" | grep -q part && { echo "$d has other partitions - stop"; exit 1; }
  { echo "# Lab 4 run 2 - $d has no partition, preparing it as the third (spare) disk - $(date '+%F %T %Z')"; echo
    run "lsblk -o NAME,SIZE,TYPE,FSTYPE $d"
    run "parted -s $d mklabel gpt mkpart primary 1MiB 100% set 1 raid on"
    run "partprobe $d; udevadm settle; lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTTYPENAME $d"; } >> "$OUT/array-boot-repair.txt"
done
mdadm --detail "$MD" | grep -q 'State : clean *$' || { echo "$MD is not clean - stop"; mdadm --detail "$MD"; exit 1; }
ACTIVE=$(mdadm --detail "$MD" | awk '/active sync/ {print $NF}')
SPARE=""
for p in /dev/sdb1 /dev/sdc1 /dev/sdd1; do
  echo "$ACTIVE" | grep -qx "$p" || SPARE=$p
done
FAIL=$(echo "$ACTIVE" | tail -n1)   # second member gets failed
[ -b "$SPARE" ] || { echo "spare partition $SPARE missing"; exit 1; }
echo "array=$MD members=$(echo $ACTIVE) fail=$FAIL spare=$SPARE"
mkdir -p "$MNT"; mountpoint -q "$MNT" || mount "$MD" "$MNT"

# --- 1. layout after building the mirror -----------------------------------
{ echo "# Lab 4 run 2 - $(date '+%F %T %Z') on $(hostname)"; echo
  run "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"
  run "df -h $MNT"; } > "$OUT/lsblk-after.txt"

# --- 2. healthy state + test data + checksums -------------------------------
{ echo "# Lab 4 run 2 - healthy mirror before the failure - $(date '+%F %T %Z')"; echo
  state; } > "$OUT/array-healthy.txt"

{ echo "# Lab 4 run 2 - test data written to the healthy mirror - $(date '+%F %T %Z')"; echo
  run "echo 'Lab 4 proof - Damir Balagazinov - $(hostname) - $(date '+%F %T')' > $MNT/proof.txt"
  run "dd if=/dev/urandom of=$MNT/random.bin bs=1M count=20 status=none"
  run "sync"
  run "ls -l $MNT/proof.txt $MNT/random.bin"
  run "cat $MNT/proof.txt"
  run "sha256sum $MNT/proof.txt $MNT/random.bin | tee $USER_HOME/lab04-sha256.txt"; } > "$OUT/checksum-before.txt"

# --- 3. fail + remove one half ----------------------------------------------
{ echo "# Lab 4 run 2 - one disk failed and removed - $(date '+%F %T %Z')"; echo
  run "mdadm --manage $MD --fail $FAIL"
  run "mdadm --manage $MD --remove $FAIL"
  state; } > "$OUT/array-degraded.txt"

# --- 4. data still readable, checksums still match (read from disk, not cache)
{ echo "# Lab 4 run 2 - checksums on the DEGRADED array - $(date '+%F %T %Z')"; echo
  run "grep $(basename $MD) /proc/mdstat"
  run "sync; echo 3 > /proc/sys/vm/drop_caches    # drop page cache so files are re-read from the surviving disk"
  run "cat $MNT/proof.txt"
  run "sha256sum $MNT/proof.txt $MNT/random.bin"
  run "sha256sum -c $USER_HOME/lab04-sha256.txt    # compare with the values taken before the failure"; } > "$OUT/checksum-after-failure.txt"

# --- 5. rebuild onto the spare disk -----------------------------------------
{ echo "# Lab 4 run 2 - rebuild onto $SPARE - $(date '+%F %T %Z')"; echo
  run "mdadm --zero-superblock $SPARE    # old member from run 1, wipe its stale RAID metadata"
  run "mdadm --manage $MD --add $SPARE"
  run "sleep 2; cat /proc/mdstat    # rebuild in progress"
  run "mdadm --wait $MD; echo rebuild finished"
  state
  run "sha256sum -c $USER_HOME/lab04-sha256.txt    # data still intact after the rebuild"
  run "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"; } > "$OUT/array-rebuilt.txt"

chown -R "${SUDO_USER:-root}": "$OUT"
echo; echo "done - evidence in $OUT:"; ls -l "$OUT"
grep -h -E 'State :|OK$|FAILED' "$OUT"/*.txt
