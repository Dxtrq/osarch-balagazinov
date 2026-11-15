# Lab 4 — Partition, mirror, fail, recover

Pair: Damir Balagazinov (alone)
Machine: Ubuntu Server guest (lab01) + Windows 11 guest
Date: 15.11.2026

## What I did

### Windows side

- Initialized a new virtual disk as GPT.
- Created a simple volume, formatted it as NTFS and assigned a drive letter.
- Chose GPT because modern systems (UEFI) prefer it and it supports larger disks and more partitions than MBR.

### Linux side

1. Checked available disks:

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
```

2. Created partitions on two disks and set type to Linux RAID (`fd`):

```bash
sudo fdisk /dev/sdb
sudo fdisk /dev/sdc
```

3. Created RAID 1 array:

```bash
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
```

4. Created filesystem and mounted it:

```bash
sudo mkfs.ext4 /dev/md0
sudo mkdir -p /mnt/raid
sudo mount /dev/md0 /mnt/raid
```

5. Wrote a test file and recorded its checksum:

```bash
echo "Lab4 RAID1 test - Damir Balagazinov" | sudo tee /mnt/raid/hello.txt
md5sum /mnt/raid/hello.txt
```

6. Failed and removed one disk:

```bash
sudo mdadm --manage /dev/md0 --fail /dev/sdc1
sudo mdadm --manage /dev/md0 --remove /dev/sdc1
```

7. Verified the file was still readable and checksum matched.

8. Added the third disk and rebuilt the array:

```bash
sudo fdisk /dev/sdd          # create partition, type fd
sudo mdadm --add /dev/md0 /dev/sdd1
```

9. Waited until the array returned to clean state with two active devices.

## Result

- RAID 1 array `/dev/md0` was successfully created, degraded, and rebuilt.
- Checksum of the test file remained identical before and after disk failure: `5074fe8fb229ad77cfcafee67054e1a7`
- Final state: array is clean, two active devices (`sdb1` + `sdd1`).

## Does RAID 1 help if a colleague deleted a file an hour ago?

No. RAID 1 only protects against hardware disk failure by keeping an identical copy of data on two drives. Any change (including deletion) is immediately mirrored to both disks.
To recover a deleted file you need a backup, snapshot, or versioning system — not RAID 1.

## What did not work the first time

When adding the third disk I first typed the wrong sequence inside `fdisk` (entered `t` and `fd` at the wrong prompts).
I had to quit with `q`, restart `fdisk /dev/sdd` and carefully follow the correct order: `n` → `p` → `1` → `Enter` → `Enter` → `t` → `fd` → `w`. After that the partition was created successfully and the array accepted the new disk.

## Evidence

- [evidence/lsblk-before.txt](evidence/lsblk-before.txt) — disks before creating the array
- [evidence/array-healthy.txt](evidence/array-healthy.txt) — healthy RAID 1 (2/2)
- [evidence/array-degraded.txt](evidence/array-degraded.txt) — array after failing one disk
- [evidence/checksum-before.txt](evidence/checksum-before.txt) — checksum of the test file before failure
- [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt) — same checksum after failure
- [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) — array after rebuild finished
