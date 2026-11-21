# How to build the test machines for a new developer

These instructions create two virtual machines on one Windows laptop:

* **lab01-ubuntu** — Ubuntu Server (Linux)
* **lab02-windows** — Windows 11

They can talk to each other, both have internet access, and both have a snapshot so the developer can break things and roll back in one click.

**You need:**
* A Windows laptop/PC with at least **16 GB RAM** (8 GB works with 2 GB per VM — see the table at the end) and virtualization enabled in BIOS/UEFI
* About **100 GB of free disk space** on the drive where the VMs will live
* About 2 hours (most of it is waiting for installations)

Every step ends with a **Check** line. If the check does not match, stop and look at **Troubleshooting** at the end.

> Screenshots: the VirtualBox windows are from my real build. The screens of the Ubuntu and Windows **installers** (steps 6 and 7) were captured on 21.11.2026 by repeating the installation in a temporary VM with exactly the same settings and the same ISO files.

---

## Step 1. Install VirtualBox

1. Go to https://www.virtualbox.org/wiki/Downloads
2. Click **Windows hosts** and run the downloaded installer.
3. Accept all default options; when Windows asks to install network drivers, click **Install**.
4. Do **not** install the "Extension Pack".

![VirtualBox installed](evidence/build/step1-virtualbox-about.png)

> **Why VirtualBox?** It is free for any use, including in a company (GPLv3), and runs on an ordinary Windows laptop. The Extension Pack is free only for personal/educational use — in an office it needs a paid licence, and we do not need it (it adds USB 3 and webcam pass-through).

> **Check:** the Start menu has *Oracle VirtualBox*; *Help → About VirtualBox* shows a version 7.x.

**Before creating any VM:** open **File → Preferences → General** and set **Default Machine Folder** to the drive with the most free space (for example `D:\VirtualBox VMs`). By default VirtualBox uses the C: drive; two VMs can grow to ~90 GB and fill it.

---

## Step 2. Download the two operating system images

1. **Ubuntu Server 26.04 LTS** — https://ubuntu.com/download/server → *Download* (file `ubuntu-26.04.1-live-server-amd64.iso`, about 2.7 GB).
2. **Windows 11 Enterprise Evaluation** — https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise → fill in the short form → *ISO – Enterprise download 64-bit edition* (about 7.7 GB).

Save both in your **Downloads** folder.

My two files (full output with SHA-256 hashes: [evidence/build/step2-iso-files.txt](evidence/build/step2-iso-files.txt)):

```
Name                                                                                            SizeGB
26300.9457.260913-1737.26h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso   7.66
ubuntu-26.04.1-live-server-amd64.iso                                                              2.73
```

> **Why these two?** Ubuntu Server is free and is what most web servers run. The Windows Evaluation is a free, legal 90-day version for testing; after 90 days you roll back the snapshot or rebuild (see README, section 2 — licences).

> **Check:** both `.iso` files are in Downloads and their sizes are about 2.7 GB and 7.7 GB. A file of a few MB means the download failed. To be sure the file is not damaged, compare `Get-FileHash <file> -Algorithm SHA256` with the checksum published on the download page.

---

## Step 3. Create the Ubuntu virtual machine

1. Open VirtualBox and click **New**.
2. Name: `lab01-ubuntu`; ISO Image: choose the Ubuntu ISO; tick **Skip Unattended Installation**.
3. Memory: **4096 MB**, Processors: **2**.
4. Hard disk: **Create a virtual hard disk now** → **25 GB**, leave **Pre-allocate Full Size** unticked.
5. Click **Finish**.

![Ubuntu VM settings](evidence/build/step3-ubuntu-settings.png)

> **Why these numbers?** The host has 16 GB RAM and 12 threads. 4 GB / 2 vCPU per guest leaves 8 GB and 8 threads for the host, so the laptop does not slow down when both VMs run. 25 GB is enough for Ubuntu Server plus development tools; "dynamic" means the file on the host only grows when the guest actually writes data.

> **Check:** `lab01-ubuntu` appears in the list on the left; its *Details* page shows 4096 MB memory, 2 processors and a 25 GB disk on SATA port 0 (the three 2 GB disks below it on my screenshot were added later for Lab 4 — you do not need them). The OS label may say a slightly different Ubuntu version, e.g. "Ubuntu 25.04" — it is only the VirtualBox template name and changes nothing.

---

## Step 4. Create the Windows virtual machine

1. Click **New** again.
2. Name: `lab02-windows`; ISO Image: choose the Windows ISO; Type **Microsoft Windows**, Version **Windows 11 (64-bit)**; tick **Skip Unattended Installation**.

   ![New VM wizard](evidence/01-new-vm-wizard.png)

3. Memory: **4096 MB**, Processors: **2**.
4. Hard disk: **64 GB**, **Pre-allocate Full Size** unticked.

   ![Disk settings](evidence/02-disk-settings.png)

5. Click **Finish**. Then select the VM → **Settings → System** and check that **Enable EFI**, **Secure Boot** and **TPM v2.0** are on.

   ![System settings: EFI, Secure Boot, TPM 2.0](evidence/build/step4-windows-system-settings.png)

> **Why?** Windows 11 refuses to install without UEFI, Secure Boot and TPM 2.0 ("This PC can't run Windows 11"). VirtualBox sets them automatically for "Windows 11 (64-bit)", but if you picked another version they are off. 64 GB is Microsoft's minimum for Windows 11.

> **Check:** the VM's *Details* page (screenshot above) shows **TPM type 2.0**, **EFI: enabled**, **Secure Boot: enabled**, and the disk is 64 GB. (The 1 GB `lab04-extra.vdi` on my screenshot was added later for Lab 4.)

---

## Step 5. Put both machines on the same network

1. **File → Tools → Network Manager** → tab **NAT Networks** → **Create**. Name it `NatNetwork`, IPv4 prefix `10.0.2.0/24`, **Enable DHCP** ticked → **Apply**.

   ![NAT Network](evidence/build/step5-nat-network.png)

2. For **each** VM: **Settings → Network → Adapter 1 → Attached to: NAT Network**, Name: **NatNetwork** → **OK**.

   ![Network adapter](evidence/03-network-adapter.png)

> **Why NAT Network and not ordinary NAT?** Ordinary NAT gives each VM its own private network, so the two VMs cannot see each other. NAT Network puts them on one shared private network that still has internet access through the laptop, and keeps them invisible to the office network. Bridged would put them directly on the office network — not wanted for a test machine.

> **Check:** both VMs show *NAT Network 'NatNetwork'* under *Network* on their summary page.

---

## Step 6. Install Ubuntu Server

Select `lab01-ubuntu` → **Start**. The installer is keyboard-only: arrows to move, **Space** to tick, **Enter** to confirm, **Tab** to jump to *Done*.

| # | Screen | What to do | Why |
|---|---|---|---|
| 1 | Language | **English** → Enter | Error messages in English are easier to search for. |
| 2 | Keyboard configuration | leave **English (US)** → *Done* | Other layouts can be added later; US avoids wrong symbols in commands. |
| 3 | Type of installation | **Ubuntu Server** (not minimized) → *Done* | Minimized has no editor, no man pages — painful for a developer. |
| 4 | Network | leave the DHCP address (10.0.2.x) → *Done* | Proves the NAT Network works *before* installing. |
| 5 | Proxy | leave empty → *Done* | No proxy in this office. |
| 6 | Mirror | leave the default (`kz.archive.ubuntu.com`) → wait for "passed tests" → *Done* | Kazakhstan mirror is fastest. |
| 7 | Guided storage | **Use an entire disk**, **Set up this disk as an LVM group** → *Done* | LVM lets the disk be extended later without reinstalling. |
| 8 | Storage summary | → *Done* | Shows `/` and `/boot` on the 25 GB virtual disk. |
| 9 | Confirm destructive action | **Continue** | It erases only the *virtual* disk — the laptop's files are not touched. |
| 10 | Profile | your name, server name `lab01`, username, password → *Done* | Write the password down — it is needed for `sudo`. |
| 11 | Ubuntu Pro | **Skip for now** → *Continue* | Not needed on a test VM. |
| 12 | SSH configuration | tick **Install OpenSSH server** (Space) → *Done* | Lets the developer connect from the laptop's terminal, where copy-paste works. |
| 13 | Featured server snaps | tick nothing → *Done* | Install only what is needed, later. |
| 14 | Installing system | wait (10–15 min) → **Reboot Now** | Press Enter if asked to remove the installation medium. |

Screens 1–14 in order:

![1 language](evidence/build/step6-ubuntu-01-language.png)
![2 keyboard](evidence/build/step6-ubuntu-02-keyboard.png)
![3 install type](evidence/build/step6-ubuntu-03-install-type.png)
![4 network](evidence/build/step6-ubuntu-04-network.png)
![5 proxy](evidence/build/step6-ubuntu-05-proxy.png)
![6 mirror](evidence/build/step6-ubuntu-06-mirror.png)
![7 storage](evidence/build/step6-ubuntu-07-storage.png)
![8 storage summary](evidence/build/step6-ubuntu-08-storage-summary.png)
![9 confirm](evidence/build/step6-ubuntu-09-confirm.png)
![10 profile](evidence/build/step6-ubuntu-10-profile.png)
![11 Ubuntu Pro](evidence/build/step6-ubuntu-11-ubuntu-pro.png)
![12 SSH](evidence/build/step6-ubuntu-12-ssh.png)
![13 snaps](evidence/build/step6-ubuntu-13-snaps.png)
![14 installing](evidence/build/step6-ubuntu-14-installing.png)

After the reboot, log in and run:

```bash
uname -a
lsb_release -a
```

> **Check:** `lsb_release -a` prints `Ubuntu 26.04.1 LTS` (my output: [04-guest-uname.txt](evidence/04-guest-uname.txt)).

---

## Step 7. Install Windows 11

Select `lab02-windows` → **Start**. When you see *"Press any key to boot from CD or DVD…"*, press a key **immediately** (you have ~5 seconds; if you miss it, close the window → *Power off*, and start again).

| # | Screen | What to do | Why |
|---|---|---|---|
| 1 | Select language settings | English (United States) → **Next** | |
| 2 | Select keyboard settings | **US** → **Next** | Add Russian/Kazakh later in Settings. |
| 3 | Select setup option | **Install Windows 11**, tick **I agree everything will be deleted…** → **Next** | Only the empty virtual disk is affected. |
| 4 | License terms | **Accept** | Evaluation licence: free for 90 days, for testing. |
| 5 | Select location | **Disk 0 Unallocated Space 64.0 GB** → **Next** | Windows creates its own partitions on the empty disk. |
| 6 | Ready to install | check it says *Windows 11 Enterprise Evaluation* → **Install** | If you see "This PC can't run Windows 11" instead, go back to step 4 (EFI/TPM/Secure Boot). |
| 7 | Installing Windows 11 | wait; the VM restarts several times (20–30 min) | **Do not** press a key at "Press any key to boot from CD" after these restarts — it would start the installer again. |

![1 language](evidence/build/step7-windows-01-language.png)
![2 keyboard](evidence/build/step7-windows-02-keyboard.png)
![3 setup option](evidence/build/step7-windows-03-setup-option.png)
![4 licence](evidence/build/step7-windows-04-license.png)
![5 disk](evidence/build/step7-windows-05-disk.png)
![6 ready](evidence/build/step7-windows-06-ready.png)
![7 installing](evidence/build/step7-windows-07-installing.png)

After the restarts (first-start setup):

8. Region **Kazakhstan**, keyboard **US** (add a second layout if you like).
9. When asked to sign in with a Microsoft account, choose **Sign-in options → Domain join instead** and create a **local** user with a password. *Why:* a test VM should not be tied to anyone's personal Microsoft account.
10. Turn off all the privacy toggles → **Accept**.
11. When the desktop appears: VirtualBox menu **Devices → Insert Guest Additions CD image**, open the CD in File Explorer, run `VBoxWindowsAdditions.exe`, accept defaults, **Reboot**. *Why:* without Guest Additions the screen is small, the mouse lags and copy-paste between laptop and VM does not work.
12. Turn on the shared clipboard: VirtualBox menu **Devices → Shared Clipboard → Bidirectional**.

> **Check:** after the reboot the Windows screen resizes when you resize the VM window, and text copied on the laptop can be pasted in the VM.

---

## Step 8. Check that everything works

### Allow ping on Windows first

Windows blocks incoming ping by default, so the test from Ubuntu to Windows fails without this. In Windows, open **PowerShell as Administrator** and run:

```powershell
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
```

*Why not just turn the firewall off?* Because the developer tests software on this VM — it should behave like a real, protected Windows machine. This rule opens only ping.

### On Ubuntu

```bash
ip -br a              # note the 10.0.2.x address
ping -c 4 10.0.2.4    # Windows address (from ipconfig below)
ping -c 4 ubuntu.com  # internet
```

![Ubuntu ping](evidence/build/step8-ubuntu-ping.png)

### On Windows (PowerShell)

```powershell
ipconfig              # note the 10.0.2.x address
ping 10.0.2.3         # Ubuntu address
ping ubuntu.com       # internet
```

![Windows ping](evidence/build/step8-windows-ping.png)

> **Check:** all four pings show `0% packet loss` / `Lost = 0`. Your addresses may differ (10.0.2.4, 10.0.2.5…) — use the ones `ip -br a` and `ipconfig` show. My full output: [05-ping-between-guests.txt](evidence/05-ping-between-guests.txt).

---

## Step 9. Take a clean snapshot of each machine

Do this for **both** VMs, right after step 8:

1. Shut the VM down completely (Ubuntu: `sudo poweroff`; Windows: Start → Power → Shut down). *Why:* a snapshot of a switched-off VM is small and fast; a snapshot of a running VM also saves all its memory (4 GB) and can take many minutes.
2. In VirtualBox select the VM → click the **☰ menu** next to its name → **Snapshots**.
3. Click **Take**, name it `clean-install` (Ubuntu) or `clean-baseline` (Windows), add a description → **OK**.

![Ubuntu snapshot](evidence/06-snapshot-list.png)
![Windows snapshot](evidence/build/step9-windows-snapshot.png)

The same from the command line ([evidence/build/step9-snapshot-list.txt](evidence/build/step9-snapshot-list.txt)): `VBoxManage snapshot lab02-windows list` → `clean-baseline`.

> **Check:** each VM's Snapshots list shows the snapshot and, below it, *Current State*.

### How to roll back later

1. Shut the VM down.
2. Open **Snapshots**, select `clean-install` / `clean-baseline`.
3. Click **Restore**, untick *Create a snapshot of the current machine state* (unless you want to keep the broken state), → **Restore**.

*The VM returns to exactly the state it had when the snapshot was taken — everything installed or broken since then is gone.*

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Ping Ubuntu → Windows fails, Windows → Ubuntu works | Windows Firewall blocks incoming ping | Run the `New-NetFirewallRule` command in step 8. Do not switch the firewall off. |
| Ping between the VMs fails in both directions | One VM is on "NAT" instead of "NAT Network", or on a different NAT network | Step 5: both adapters → *NAT Network*, name *NatNetwork*. |
| "This PC can't run Windows 11" | EFI / Secure Boot / TPM 2.0 off | Power off → *Settings → System* → turn on all three (step 4) → start again. |
| "VT-x/AMD-V hardware acceleration is not available" | Virtualization is off in the laptop's BIOS/UEFI | Reboot the laptop into BIOS (F2/Del), enable *Intel VT-x* or *AMD SVM*, save. |
| Windows VM shows "Press any key to boot from CD…" after installation and setup starts again | A key was pressed at that prompt after a restart | Close the window → *Power off*; *Settings → Storage* → remove the Windows ISO → start again. |
| Screen small, mouse jumps, copy-paste does not work | Guest Additions not installed (Windows) | Step 7, items 11–12. On Ubuntu Server there is no graphical clipboard — use `ssh` from the laptop instead. |
| Snapshot "takes forever" / VM hangs while snapshotting | Snapshot of a **running** VM saves all its RAM to disk; closing the VM window during it aborts it | Shut the VM down first (step 9). If it hangs, wait for it to finish; do not close the window. |
| Laptop very slow, C: almost full | VMs stored on a small C: drive | *File → Preferences → General → Default Machine Folder* to a bigger drive before creating VMs; move existing ones with *Machine → Move*. |
| Ubuntu disk is smaller than planned (e.g. 19 GB instead of 25 GB) | A different size was typed in the *New VM* wizard | Power off → `VBoxManage modifymedium disk <file.vdi> --resize 25600` → in Ubuntu: `sudo growpart /dev/sda 3 && sudo pvresize /dev/sda3 && sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv`. **If the VM has snapshots, resize every disk in the chain** (base `.vdi` and each `Snapshots/{…}.vdi`), otherwise the VM pauses with *BLKCACHE_IOERR* as soon as Linux writes past the old size. |
| Windows nags "Your evaluation period has expired" | 90-day evaluation ended | Restore `clean-baseline` or rebuild from the ISO; or buy a Windows 11 Pro licence for the VM. |

---

## Quick reference

| Setting | Ubuntu | Windows 11 | On an 8 GB laptop |
| :--- | :--- | :--- | :--- |
| **vCPU** | 2 | 2 | 2 / 2 |
| **RAM** | 4 GB | 4 GB | 2 GB / 4 GB, run one VM at a time |
| **Disk** | 25 GB dynamic | 64 GB dynamic | same |
| **Network** | NAT Network `NatNetwork` | NAT Network `NatNetwork` | same |
| **Firmware** | default | UEFI + Secure Boot + TPM 2.0 | same |
| **Snapshot** | `clean-install` | `clean-baseline` | same |

*That is everything needed to rebuild the test environment from scratch.*
