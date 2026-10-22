# Lab 1 — Your first virtual machine

## Summary

| What                        | Value                                              | Details |
|-----------------------------|----------------------------------------------------|---------|
| Hypervisor                  | Oracle VirtualBox                                  | Licence: https://www.virtualbox.org/wiki/Licensing_FAQ |
| Guest OS                    | Ubuntu Server 26.04.1 LTS (Resolute)               | evidence/guest-release.txt |
| VM name                     | lab01-ubuntu                                       | — |
| vCPU                        | 2                                                  | Host has 6 cores / 12 threads (Lab 0) |
| RAM                         | 4 GB (4096 MB)                                     | Host has 16 GB (Lab 0) |
| Disk                        | 25 GB, dynamically allocated (VDI)                 | — |
| Network                     | NAT                                                | — |
| Snapshot                    | clean-install                                      | Taken while powered off |
| Break method                | Option A — deleted `/etc/hostname`                 | evidence/broken.png |
| Rollback                    | Restored to clean-install                          | evidence/snapshot-list.png |

## Resource justification

Host (from Lab 0): AMD Ryzen 5 7430U (6 cores / 12 threads), 16 GB RAM, >280 GB free on D:.  
Allocated 2 vCPU (less than half of host cores) and 4 GB RAM. Windows + VirtualBox already use ~6–7 GB idle, so 4 GB leaves enough headroom for the host and for the future Windows guest in Lab 2. Disk is 25 GB dynamic.

## Evidence

All files are in the `evidence/` folder:

- `vm-settings.png` — CPU, memory and disk as configured
- `guest-release.txt` — output of `lsb_release -a`
- `broken.png` — guest after deleting `/etc/hostname`
- `snapshot-list.png` — snapshot list after rollback

## What did not work the first time

- SSH from the host failed with "Connection refused" because OpenSSH was not installed during the first installation attempt. Fixed by installing `openssh-server` and adding port forwarding 2222 → 22 in VirtualBox.
- First settings screenshot was taken while the VM was running. Had to power it off and retake a clean one.

## Commands used (inside the guest)

```bash
# Check system
lsb_release -a
hostname
nproc
free -h
df -h /
ip -br a

# Break (Option A)
cat /etc/hostname
sudo rm /etc/hostname
cat /etc/hostname
sudo reboot

# After rollback
cat /etc/hostname
hostname
