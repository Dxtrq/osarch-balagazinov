# Ticket 1 — New developer starts Monday, needs a test machine

## 1. What was asked

> From: Aigerim T. (Office Manager)  
> Subject: test machine for new dev  
>
> Hi, we have someone starting on Monday and he needs a test computer  
> set up. Nothing special, just so he can try things without breaking  
> anything. Can you write down how to do it so I can do the next one  
> myself? Thanks

## 2. What was actually needed

The request sounds simple, but it leaves out almost everything required for a usable test environment.

**What the request left out:**
- Which operating systems are needed (Linux, Windows, or both)
- How much RAM, CPU and free disk the host machine actually has
- Whether the machines need internet access
- Whether the developer needs to test communication between machines
- Whether a snapshot / rollback point is required
- Who will actually follow the instructions (Aigerim has never opened a hypervisor)
- Which licences the company has — nothing in the request says whether there is a Windows licence for a test machine

**Where the request itself was wrong:**  
- Calling it "a test computer" implies **one** machine. For a developer who needs to "try things without breaking anything", a single OS is not enough: real testing needs a Linux server and a Windows client, and one machine cannot show whether two machines can talk to each other.  
- "Without breaking anything" is not a property of a computer — it comes from **snapshots**. A physical test PC can still be broken; a virtual machine with a snapshot can be reset in one click. So the answer is virtual machines, not a computer.  
- "Nothing special" — but Windows 11 refuses to install without UEFI, Secure Boot and TPM 2.0, which are *not* the VirtualBox defaults. The document has to cover exactly this "special" part, or Aigerim gets stuck on the first try.

**Licences (the request does not mention them, but an office must get them right):**

| Component | Licence | What it means for the office |
|---|---|---|
| VirtualBox (base package) | GPLv3, free | Free for any use, including commercial. |
| VirtualBox Extension Pack | PUEL — free only for personal / educational / evaluation use | **Not installed** and not needed (it only adds USB 3, webcam, disk encryption). Installing it on an office PC would need a paid Oracle licence. |
| Ubuntu Server 26.04 LTS | Free, open source | No cost; security updates until 2031 (standard LTS). |
| Windows 11 Enterprise **Evaluation** | Free 90-day trial for testing and evaluation, not for production use | Fine for a test VM. After 90 days it nags and shuts down hourly → either restore the snapshot / rebuild from the ISO (allowed for test use), or the company buys a Windows 11 Pro licence for the VM. A developer *testing* software is evaluation use; using the VM as a daily office PC would not be. |

**Questions I would have asked Aigerim (and what I assumed because I could not ask):**

| # | Question for Aigerim | What I assumed instead |
|---|---|---|
| 1 | Which laptop will he use — how much RAM and free disk does it have? | A laptop like mine: 16 GB RAM, 6 cores / 12 threads, ≥ 100 GB free on the SSD. |
| 2 | What will he develop — web/server software, Windows desktop software, or both? | Both: an Ubuntu server and a Windows client. |
| 3 | Must the test machines reach the internet, and must they see each other? | Yes to both (package installs + client/server testing), but not be reachable from the office network. |
| 4 | Does the company have a Windows licence for a test machine, or should we use the free evaluation? | No licence → Windows 11 Enterprise Evaluation, rebuilt or reset when the 90 days run out. |
| 5 | Who rolls the machine back when he breaks it — him or you? | He does it himself, so a named snapshot (`clean-install` / `clean-baseline`) is required and the rollback is in the document. |
| 6 | Is it OK to install free software (VirtualBox) on the office laptop without IT approval? | Yes, because the base VirtualBox is free for commercial use; the Extension Pack is left out. |

These assumptions shaped every decision below. If any of them is wrong (e.g. the laptop has 8 GB), the Quick reference table in BUILD.md says what to change.

## 3. What I did

1. Measured the real host resources (16 GB RAM, 6 cores / 12 threads; disk: C: 51 GB free, D: 383 GB free on 21.11.2026 (`Get-Volume`)).
2. Chose VirtualBox as the hypervisor (see "Alternative considered").
3. Created two virtual machines:
   - `lab01-ubuntu` — Ubuntu Server 26.04.1 LTS, 2 vCPU, 4 GB RAM, 25 GB dynamic disk
   - `lab02-windows` — Windows 11 Enterprise Evaluation, 2 vCPU, 4 GB RAM, 64 GB dynamic disk, UEFI + Secure Boot + TPM 2.0
4. Put both machines on the same **NAT Network** so they can talk to each other and still reach the internet.
5. Hit a problem with ping (see below) and fixed it with a Windows Firewall rule instead of disabling the firewall.
6. Verified connectivity in both directions and to the internet.
7. Took a snapshot of **both** guests: `clean-install` (Ubuntu) and `clean-baseline` (Windows).
8. Wrote `BUILD.md` for a non-technical reader: every step has a screenshot, a "why" and a "Check" line, and there is a troubleshooting table at the end.
9. To get screenshots of the installers themselves, I repeated the Ubuntu and Windows installations on 21.11.2026 in throw-away VMs with the same settings, booted from the same ISO files, and captured the screen at every step (`VBoxManage controlvm <vm> screenshotpng`). Those VMs were deleted afterwards.

### What went wrong and how I fixed it

After installing both guests, ping from **Windows → Ubuntu** worked, but ping from **Ubuntu → Windows** (`ping 10.0.2.4`) got no replies. Both machines had addresses in `10.0.2.0/24` and both could reach the internet, so the NAT Network itself was fine — the problem had to be on the Windows side.

The cause is the Windows Firewall: on a new ("Public") network Windows blocks inbound ICMP echo requests (ping) by default, while outbound ping is allowed — which is exactly why it worked in one direction only.

The quick fix many guides give is to switch the firewall off. I did not do that, because the developer will test things on this machine and a VM without a firewall is a bad habit. Instead I allowed only inbound ping:

```powershell
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

After that the ping worked both ways (`evidence/05-ping-between-guests.txt`). The problem and the fix are now the first row of the troubleshooting table in BUILD.md, so Aigerim does not have to rediscover it.

**A second problem, found on 21.11.2026:** my Ubuntu disk was **19 GB, not the 25 GB** this document specifies (`VBoxManage showmediuminfo` → Capacity 19456 MB) — a different number had been typed in the wizard, and inside Ubuntu only 10 GB of it was given to `/`. I resized the disk to 25 GB with `VBoxManage modifymedium --resize 25600` and grew the partition, LVM volume and ext4 inside the guest (`growpart`, `pvresize`, `lvextend -r`). The first attempt **paused the VM** with `BLKCACHE_IOERR`: I had resized only the current disk layer, while the two snapshot layers below it were still 19 GB, so every write beyond 19 GB failed. I saved the VM state, resized the other two layers, resumed the VM, and the resize finished cleanly (`/` is now 23 GB, no I/O errors in the kernel log). This is now a row in the troubleshooting table.

### Resource calculation (from my real host)

| Resource | Host has | Given to Ubuntu | Given to Windows | Left for host |
|----------|----------|-----------------|------------------|---------------|
| RAM      | 16 GB    | 4 GB            | 4 GB             | ~8 GB         |
| CPU      | 12 threads | 2 vCPU        | 2 vCPU           | 8 threads     |
| Disk (max) | C: 51 GB free, D: 383 GB free | 25 GB (dynamic) | 64 GB (dynamic) | see below |

I never give more than half of the host's cores to any single guest. 4 GB per guest leaves 8 GB for Windows on the host plus the VirtualBox processes, so the host itself does not start swapping when both guests run at once.

**Disk — a risk I found while writing this:** VirtualBox keeps VMs in `C:\Users\<name>\VirtualBox VMs` by default, which is on C:. On my laptop C: has only 51 GB free, while the two dynamic disks may grow to 25 + 64 = 89 GB, plus snapshots. Dynamic disks start small (that is why it worked so far), but a developer who installs a lot would fill C: and stop the host. BUILD.md therefore tells Aigerim to set **File → Preferences → General → Default Machine Folder** to the drive with the most free space (D: here) before creating the VMs.

### Non-default settings (and why)

| Setting | Default in VirtualBox | What I chose | Why |
|---------|-----------------------|--------------|-----|
| Network mode | NAT | **NAT Network** | Ordinary NAT isolates each guest; they cannot ping each other. NAT Network keeps internet access **and** lets the two guests talk. |
| Windows firmware | BIOS | **UEFI + Secure Boot + TPM 2.0** | Windows 11 requires these three things. |
| Disk allocation | Pre-allocate full size | **Dynamically allocated** | Saves host disk space until the guest actually needs it. |
| Windows RAM | 2 GB (VirtualBox suggestion) | **4 GB** | Windows 11 is unusable under 4 GB for any real work. |
| Windows Firewall | blocks inbound ping | **one inbound ICMPv4 rule** | Needed for the guest-to-guest test; the rest of the firewall stays on. |
| Snapshots | None | **`clean-install` (Ubuntu), `clean-baseline` (Windows)** | The whole point of a test machine is the ability to roll back after the developer breaks something. |

### Alternative considered

I also considered **VMware Workstation Player**.  
It is smoother with Windows guests and has better 3D support, but:

- The free Player version has more restrictions on snapshots and networking.
- VirtualBox is completely free for this use case and is already installed on most student machines.

I stayed with VirtualBox because the goal is a document that Aigerim can follow on a normal office laptop without buying anything.

## 4. Evidence

| File | What it proves |
|------|----------------|
| `evidence/01-new-vm-wizard.png` | Correct creation of the Windows 11 VM with the right type and version |
| `evidence/02-disk-settings.png` | Disk is 64 GB and dynamically allocated |
| `evidence/03-network-adapter.png` | Both guests are attached to the same NAT Network |
| `evidence/04-guest-uname.txt` | Ubuntu is running: `uname -a` **and** `lsb_release -a` (Ubuntu 26.04.1 LTS) |
| `evidence/05-ping-between-guests.txt` | Ping works both directions + both machines reach the internet |
| `evidence/06-snapshot-list.png` | Snapshot `clean-install` exists for Ubuntu |
| `evidence/build/` | One screenshot per step of BUILD.md: Ubuntu installer screens, Windows installer screens, firmware settings, ping from each guest, both snapshot lists |

## 5. What I would do differently

1. I would prepare a one-page "cheat sheet" with only the five most important clicks and the exact numbers (RAM, CPU, disk size). The full `BUILD.md` is correct, but for a person who is in a hurry it is still long.
2. I would take the screenshots **while** doing the first build, not afterwards. Because I did not, I had to repeat both installations in throw-away VMs just to capture the installer screens.
3. I would ask Aigerim the six questions above *before* building, by email, instead of assuming — especially the licence question, which decides whether the Windows VM has to be rebuilt every 90 days.
