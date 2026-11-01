# How to build the test machines for a new developer

These instructions create two virtual machines:
- one Ubuntu Server (Linux)
- one Windows 11

They can talk to each other and both have internet access.  
A snapshot is included so the developer can break things and roll back.

You will need about 40–50 GB of free disk space and a reasonably modern laptop (at least 8 GB RAM).

---

## Step 1. Install VirtualBox

1. Go to https://www.virtualbox.org/wiki/Downloads
2. Download the version for Windows hosts.
3. Install it with all default options.
4. Restart the computer if the installer asks you to.

**Why VirtualBox?** It is free, works on Windows, and does not require a paid licence.

---

## Step 2. Download the two operating system images

You need two ISO files:

1. **Ubuntu Server**  
   Download the latest LTS version from https://ubuntu.com/download/server

2. **Windows 11 Enterprise Evaluation**  
   Go to the Microsoft Evaluation Center, fill in the short form, and download the 64-bit ISO.  
   Link: https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise

Save both files in your Downloads folder.  
Do **not** put them inside any project folder.

---

## Step 3. Create the Ubuntu virtual machine

1. Open VirtualBox and click **New**.
2. Name: `lab01-ubuntu`
3. Type: Linux → Ubuntu (64-bit)
4. Memory: **4096 MB**
5. Processors: **2**
6. Hard disk: Create a virtual hard disk now → **25 GB**, dynamically allocated
7. Finish.

**Why these numbers?**  
The host has 16 GB of RAM. Giving the guest 4 GB leaves enough memory for Windows and for the host itself. Two processors is safe (never more than half of the host’s cores).

---

## Step 4. Create the Windows virtual machine

1. Click **New** again.
2. Name: `lab02-windows`
3. Type: Microsoft Windows → Windows 11 (64-bit)
4. Tick **Skip Unattended Installation**
5. Memory: **4096 MB**
6. Processors: **2**
7. Hard disk: **64 GB**, dynamically allocated (do **not** tick “Pre-allocate Full Size”)
8. Finish.

After creation, open **Settings → System** and check that:
- Enable EFI is ticked
- TPM is set to v2.0
- Secure Boot is enabled

These three options are required by Windows 11.

---

## Step 5. Put both machines on the same network

1. In VirtualBox go to **File → Tools → Network Manager**.
2. Open the **NAT Networks** tab and create a new network (name it `NatNetwork` if it is not already there). Make sure DHCP is enabled.
3. For **each** virtual machine:
   - Open Settings → Network
   - Adapter 1 → Attached to: **NAT Network**
   - Name: **NatNetwork**

**Why NAT Network and not ordinary NAT?**  
Ordinary NAT gives each machine its own private network, so they cannot see each other. NAT Network puts them on the same internal network while still giving them internet access.

---

## Step 6. Install the operating systems

### Ubuntu
1. Start `lab01-ubuntu`.
2. Select the ISO when asked.
3. Follow the installer (use defaults, create a user, install OpenSSH server if offered).
4. When installation finishes, reboot and log in.

### Windows 11
1. Start `lab02-windows`.
2. Press any key when you see “Press any key to boot from CD…”.
3. Choose “I don’t have a product key”.
4. Select Windows 11 Enterprise (Evaluation).
5. Create a local account (use “Domain join instead” if offered).
6. After the desktop appears, install Guest Additions:
   - Devices → Insert Guest Additions CD image
   - Run the installer inside Windows and reboot.

---

## Step 7. Check that everything works

On Ubuntu run:
```bash
ip -br a
ping -c 4 10.0.2.4        # should reach Windows
ping -c 4 ubuntu.com     # should reach the internet
