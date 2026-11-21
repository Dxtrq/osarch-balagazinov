# Lab 4 — Partition, mirror, fail, recover

Pair: Damir Balagazinov (alone)
Machine: Windows 11 host, Oracle VirtualBox — Ubuntu Server guest `lab01-ubuntu` (3 × 2 GB extra disks) + Windows 11 guest `lab02-windows` (1 × 1 GB extra disk)
Dates: 15.11.2026 (run 1), 21.11.2026 (run 2 — full cycle with sha256 proof, Windows side)

All evidence files contain the command and its output together. The Linux evidence for run 2 was produced by [scripts/lab04-linux.sh](scripts/lab04-linux.sh), the Windows evidence by [scripts/lab04-windows.ps1](scripts/lab04-windows.ps1); every command in the scripts is printed into the evidence file right above its output.

## Windows side

Evidence: [evidence/windows-disk.txt](evidence/windows-disk.txt) — `Get-Disk` and `Get-Volume` before, the three commands, `Get-Disk` / `Get-Partition` / `Get-Volume` after.

| | Disk 1 (1 GB extra disk) |
|---|---|
| Before | `PartitionStyle RAW` — not initialised, no volume (disk 0 = system disk, GPT, 64 GB) |
| Commands | `Initialize-Disk -Number 1 -PartitionStyle GPT` → `New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter R` → `Format-Volume -DriveLetter R -FileSystem NTFS -NewFileSystemLabel LAB04` |
| After | `PartitionStyle GPT`; partition 1 = 16 MB Microsoft Reserved (created automatically on GPT), partition 2 = `R:` 1008 MB Basic data; volume `R:` NTFS `LAB04`, `HealthStatus Healthy` |

(`Initialize-Disk -PassThru` still prints `RAW` — it returns the disk object as it was before the call; the `Get-Disk` after it shows `GPT`.)

**MBR or GPT, and why: GPT.** The VM boots in UEFI mode (`BiosFirmwareType : Uefi` in the evidence) and its system disk 0 is GPT, so the data disk uses the same scheme. GPT keeps a backup copy of the partition table at the end of the disk and a CRC, allows 128 partitions instead of 4 primary, and has no 2 TB limit. MBR is only needed for legacy-BIOS booting, which this machine does not use.

## Linux side — layout before and after

Before ([evidence/lsblk-before.txt](evidence/lsblk-before.txt), run 1): `sdb`, `sdc`, `sdd` are empty 2 GB disks.

After ([evidence/lsblk-after.txt](evidence/lsblk-after.txt), run 2): one Linux-RAID partition per disk, the mirror `md0` (RAID 1, ext4) mounted on `/mnt/raid`:

```
sdc                          2G disk
└─sdc1                       2G part  linux_raid_member
  └─md0                      2G raid1 ext4              /mnt/raid
sdd                          2G disk
└─sdd1                       2G part  linux_raid_member
  └─md0                      2G raid1 ext4              /mnt/raid
```

Commands used to build it (run 1):

```bash
sudo fdisk /dev/sdb            # n, p, 1, Enter, Enter, t, fd, w  (same for sdc)
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
sudo mkfs.ext4 /dev/md0
sudo mount /dev/md0 /mnt/raid
```

## Fail and recover (run 2, 21.11.2026)

Array UUID `a7afa6e4:e2cf3bb9:0257cefd:abb6c5a4` in every file; the Events counter only grows (66 → 70 → 93), which shows the three states are consecutive moments of the same array, not one screenshot.

| State | File | `/proc/mdstat` | `mdadm --detail` State | Members | Events |
|---|---|---|---|---|---|
| Healthy | [array-healthy.txt](evidence/array-healthy.txt) | `[2/2] [UU]` | `clean` | sdc1 + sdd1 | 66 |
| Degraded | [array-degraded.txt](evidence/array-degraded.txt) | `[2/1] [U_]` | `active, degraded` | sdc1, sdd1 failed + removed | 70 |
| Rebuilt | [array-rebuilt.txt](evidence/array-rebuilt.txt) | `[2/2] [UU]` (recovery 19 % shown on the way) | `clean` | sdc1 + **sdb1** (third disk) | 93 |

### Checksum proof

Test data written to the healthy mirror ([evidence/checksum-before.txt](evidence/checksum-before.txt)):

- `proof.txt` — recognisable text: `Lab 4 proof - Damir Balagazinov - lab01 - 2026-11-21 11:31:00`
- `random.bin` — 20 MB from `/dev/urandom` (20 971 520 bytes)

| File | sha256 before failure | after failure (degraded) | after rebuild |
|---|---|---|---|
| proof.txt | `50f6bbbb…88757943` | identical — `OK` | `OK` |
| random.bin | `2a6b455f…4304ef1851` | identical — `OK` | `OK` |

After failing `sdd1` I dropped the page cache (`echo 3 > /proc/sys/vm/drop_caches`) so both files were really read back from the one surviving disk, printed `proof.txt`, recomputed the hashes and checked them with `sha256sum -c` against the list saved before the failure ([evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt)). The same check was repeated after the rebuild (end of [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt)).

Steps:

```bash
sudo mdadm --manage /dev/md0 --fail /dev/sdd1
sudo mdadm --manage /dev/md0 --remove /dev/sdd1
sha256sum -c lab04-sha256.txt            # proof.txt: OK, random.bin: OK
sudo mdadm --manage /dev/md0 --add /dev/sdb1
cat /proc/mdstat                          # recovery = 19.0% ...
sudo mdadm --wait /dev/md0                # waited until the rebuild finished
```

## Does RAID 1 help if a colleague deleted a file an hour ago?

No. RAID 1 writes every change to both disks at the same moment, so the deletion was mirrored to the second disk an hour ago and the file is gone from both. RAID protects against a disk *failing*, not against people or software *changing* data — for that you need a backup or snapshot taken before the deletion.

## What did not work the first time

1. **fdisk order (run 1).** When adding the third disk I first typed the wrong sequence inside `fdisk` (entered `t` and `fd` at the wrong prompts). I quit with `q`, restarted `fdisk /dev/sdd` and followed `n` → `p` → `1` → `Enter` → `Enter` → `t` → `fd` → `w`.
2. **The array came up degraded after the VM was restarted (run 2).** Before redoing the checksum test I found `md0` running on `sdd1` alone ([evidence/array-boot-repair.txt](evidence/array-boot-repair.txt)). The kernel log says `md: kicking non-fresh sdc1 from array!` — `sdc1` was the disk I had failed in run 1, its superblock still had Events 18 while `sdd1` had 44, so mdadm refused to trust it. `sdb` showed only an empty GPT table and no partition, so it could not be assembled either. The filesystem stayed mounted and readable on `sdd1`. I wiped the stale superblock on `sdc1`, added it back, waited for the resync, and re-created a Linux-RAID partition on `sdb` with `parted` so it could serve as the third disk for the rebuild. Lesson: a removed member does not rejoin by itself — it has to be zeroed and added again, and `cat /proc/mdstat` should be checked after every reboot.
3. **Run 1 checksum was too weak.** In run 1 I only took an `md5sum` of a one-line `hello.txt`, which proves little about a mirror. Run 2 uses sha256 of a text file and of 20 MB of random data, read back from disk after dropping the cache. Run 1 files are kept in [evidence/run1-2026-11-15/](evidence/run1-2026-11-15/).

## Evidence

- [evidence/lsblk-before.txt](evidence/lsblk-before.txt) — disks before creating the array
- [evidence/lsblk-after.txt](evidence/lsblk-after.txt) — layout after: partitions, `md0`, mount point, `df -h`
- [evidence/array-healthy.txt](evidence/array-healthy.txt) — healthy RAID 1 `[UU]`, clean
- [evidence/checksum-before.txt](evidence/checksum-before.txt) — proof.txt + 20 MB random.bin written, sha256
- [evidence/array-degraded.txt](evidence/array-degraded.txt) — `--fail` + `--remove`, `[U_]`, degraded
- [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt) — sha256 on the degraded array, `sha256sum -c` OK
- [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) — `--add` third disk, rebuild progress, finished `[UU]`, sha256 OK again
- [evidence/array-boot-repair.txt](evidence/array-boot-repair.txt) — degraded-after-boot problem and its repair
- [evidence/windows-disk.txt](evidence/windows-disk.txt) — Windows: Get-Disk / Get-Volume before and after, GPT
- [evidence/run1-2026-11-15/](evidence/run1-2026-11-15/) — first run (md5 of hello.txt)
