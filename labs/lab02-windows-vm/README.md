# Lab 2 — A Windows guest, and a network between them

| | |
|---|---|
| **Student** | Damir Balagazinov |
| **Pair** | working alone |
| **Machine** | Laptop, Windows 11 host, AMD Ryzen 5 7430U (6 cores / 12 threads), 16 GB RAM |
| **Guests** | Ubuntu Server 26.04 (`lab01-ubuntu`) + Windows 11 Enterprise Evaluation (`lab02-windows`) |
| **Date** | 01.11.2026 |
| **Hypervisor** | Oracle VirtualBox |

---

## What I did

1. Downloaded Windows 11 Enterprise Evaluation ISO from the official Microsoft Evaluation Center.
   Licence: https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
2. Created VM `lab02-windows` with the required settings:
   - 2 vCPU
   - 4 GB RAM
   - 64 GB thin (dynamically allocated) disk
   - UEFI + Secure Boot + virtual TPM 2.0
3. Installed Windows 11 Enterprise Evaluation and Guest Additions.
4. Created a **NAT Network** (`NatNetwork`, `10.0.2.0/24`) and attached **both** guests to it.
5. Obtained IP addresses:
   - Ubuntu (`lab01-ubuntu`): **10.0.2.3**
   - Windows (`lab02-windows`): **10.0.2.4**
6. Ping from Ubuntu to Windows timed out because Windows Defender Firewall blocks incoming ICMP Echo Requests by default.
   Fixed with the proper rule (firewall was **not** disabled):
   ```powershell
   New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
   ```
7. Verified connectivity in both directions and to the internet.
8. Performed the overcommitment experiment: raised both guests to 10 GB each (20 GB promised on a 16 GB host).

---

## Network diagram

```text
                          Internet
                              |
                     Host laptop (16 GB RAM)
                              |
          [VirtualBox NAT Network · NatNetwork · 10.0.2.0/24]
                 /                                \
        lab01-ubuntu                         lab02-windows
        10.0.2.3                             10.0.2.4
        (Ubuntu Server)                      (Windows 11 Enterprise eval)
```

### Why NAT Network?

Both guests must reach each other **and** the internet.

- Plain NAT in VirtualBox gives each VM its own isolated network → guests cannot see each other.
- Bridged mode often fails on campus Wi-Fi (unknown MAC addresses are dropped).
- Host-only has no internet.

NAT Network is the correct choice for this lab.

---

## Result — Overcommitment experiment

| | Before (both VMs off) | After (both VMs 10 GB) |
|---|---|---|
| **Host RAM in use** | ~5.5 GB | 15.0 GB |
| **Available** | ~9.9 GB | 0.37 GB |
| **Committed / Swap used** | ~12 GB | 30.1 / 31.2 GB |
| **What I noticed** | — | Strong lag, mouse stuttering, windows freezing for several seconds. Host became almost unusable until one guest was shut down. |

---

## What did not work the first time

1. After switching both VMs to NAT Network, Ubuntu lost internet access.
   `ping ubuntu.com` showed 100% packet loss.
   Fixed by running `sudo netplan apply` and then a full reboot of the Ubuntu guest. After that, internet worked normally.
2. Ping from Ubuntu to Windows timed out.
   Cause: Windows Defender Firewall blocks incoming ICMP Echo Requests by default.
   Solution: added a specific inbound rule for ICMPv4 type 8 instead of disabling the firewall.

---

## Evidence

| File | Description |
|---|---|
| `evidence/ipconfig-windows.txt` | Windows IP address (10.0.2.4) |
| `evidence/ip-addr-linux.txt` | Ubuntu IP address (10.0.2.3) |
| `evidence/ping-both-ways.txt` | Ping both directions + internet from both guests |
| `evidence/host-memory-before.png` | Host memory with both guests powered off |
| `evidence/host-memory-after.png` | Host memory under overcommitment (both guests 10 GB) |
