# Ticket 1 — New developer starts Monday, needs a test machine

## 1. What was asked

> From: Aigerim T. (Office Manager)  
> Subject: test machine for new dev  
>
> Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks

## 2. What was actually needed

The request sounds simple, but it leaves out almost everything that matters for a usable test environment.

**What was missing:**
- Which operating systems are needed (Linux, Windows, or both?)
- How much RAM and CPU the host machine has
- Whether the machines need internet access
- Whether the developer needs to test networking between machines
- Whether a snapshot / rollback point is required
- Who will actually follow the instructions (Aigerim has never opened a hypervisor)

**Where the request itself was wrong:**
Calling it “a test computer” implies one machine. For a developer who needs to “try things without breaking anything”, a single OS is not enough. Real testing almost always needs both a Linux server and a Windows client (or at least two different systems). One machine also cannot demonstrate network isolation or inter-guest communication.

**What I assumed instead of asking:**
- The host is a typical student laptop (mine has 16 GB RAM and 6 cores).
- The developer needs both Ubuntu Server and Windows 11 so he can test cross-platform behaviour.
- Both guests must reach the internet and each other.
- A clean snapshot is mandatory so the developer can break things and roll back.
- The instructions must be written for someone who has never used VirtualBox.

These assumptions shaped the entire build document.

## 3. What I did

1. Checked the real resources of my host (16 GB RAM, 6 cores / 12 threads).
2. Created two virtual machines in Oracle VirtualBox:
   - `lab01-ubuntu` — Ubuntu Server 26.04.1 LTS, 2 vCPU, 4 GB RAM, 25 GB dynamic disk
   - `lab02-windows` — Windows 11 Enterprise Evaluation, 2 vCPU, 4 GB RAM, 64 GB dynamic disk, UEFI + Secure Boot + TPM
3. Put both machines on the same **NAT Network** so they can talk to each other and still reach the internet.
4. Added a proper Windows Firewall rule that allows ping (ICMP) without disabling the firewall.
5. Verified that both guests can reach the internet and each other.
6. Took a clean snapshot of the Ubuntu guest.
7. Wrote a step-by-step `BUILD.md` that a non-technical person can follow.

## 4. Evidence

| File | What it proves |
|------|----------------|
| `evidence/01-new-vm-wizard.png` | Correct creation of the Windows 11 VM with the right type and version |
| `evidence/02-disk-settings.png` | Disk is 64 GB and dynamically allocated (not pre-allocated) |
| `evidence/03-network-adapter.png` | Both guests are attached to the same NAT Network |
| `evidence/04-guest-uname.txt` | Ubuntu guest is running and reports its kernel |
| `evidence/05-ping-between-guests.txt` | Both directions of ping work + both machines reach the internet |
| `evidence/06-snapshot-list.png` | A clean snapshot exists and can be restored |

## 5. What I would do differently

I would prepare a short one-page “cheat sheet” with only the five most important clicks and the exact numbers (RAM, CPU, disk size). The full `BUILD.md` is correct, but for a person who is in a hurry it is still long. A one-page version would reduce the chance of skipping a critical step.
