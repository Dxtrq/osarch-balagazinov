# Lab 00 — System Inventory

## Summary table

| What                        | Value                                              | Where I got it |
|-----------------------------|----------------------------------------------------|----------------|
| CPU                         | AMD Ryzen 5 7430U with Radeon Graphics             | `Get-CimInstance Win32_Processor` → evidence/cpu.txt |
| Cores / Threads             | 6 cores / 12 logical processors                    | `Get-CimInstance Win32_Processor` → evidence/cpu.txt |
| RAM                         | 16 GB (2 × 8 GB) @ 3200 MHz                        | `Get-CimInstance Win32_PhysicalMemory` → evidence/memory.txt |
| RAM Manufacturer            | Wodposit                                           | `Get-CimInstance Win32_PhysicalMemory` → evidence/memory.txt |
| Storage                     | 954 GB NVMe SSD (WPBSNM8-1TMP)                     | `Get-PhysicalDisk` → evidence/disk.txt |
| Disk bus                    | NVMe                                               | `Get-PhysicalDisk` → evidence/disk.txt |
| Volume C:                   | 299 GB total, 73 GB free                           | `Get-Volume` → evidence/disk.txt |
| Volume D:                   | 653 GB total, 283 GB free                          | `Get-Volume` → evidence/disk.txt |
| Volume used for VMs         | D: (Local Disk) — more free space                  | Chosen based on free space from `Get-Volume` |
| BIOS Manufacturer           | American Megatrends International, LLC.            | `Get-CimInstance Win32_BIOS` → evidence/bios.txt |
| BIOS Version                | 1.17                                               | `Get-CimInstance Win32_BIOS` → evidence/bios.txt |
| BIOS Release Date           | 2025-04-24                                         | `Get-CimInstance Win32_BIOS` → evidence/bios.txt |
| Firmware type               | UEFI                                               | `$env:firmware_type` and `Get-ComputerInfo` → evidence/firmware-virtualization.txt |
| Virtualization              | Enabled in firmware (True). Hypervisor is present. | `Get-CimInstance Win32_Processor` + `systeminfo` → evidence/firmware-virtualization.txt |

## Evidence

All raw PowerShell outputs are stored in the `evidence/` folder:

- `cpu.txt`
- `memory.txt`
- `disk.txt`
- `bios.txt`
- `firmware-virtualization.txt`

## What did not work the first time

- The first submission used PNG screenshots instead of raw text evidence.
- The `Get-Volume` output was cut off, so free space was not visible.
- Firmware type and virtualization information were missing.
- The README did not contain the required three-column table (What | Value | Where I got it).
- The repository link pointed to the profile instead of the specific lab folder.
- Evidence files had numbered names (`01-cpu.txt` etc.) instead of the required names (`cpu.txt`, `memory.txt`, `disk.txt`).

## Commands used

```powershell
# CPU
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors | Format-List

# Memory
Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, @{n='GB';e={$_.Capacity/1GB}}, Speed, ConfiguredClockSpeed, Manufacturer | Format-Table

# Disk
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, BusType, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}} | Format-Table
Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, FileSystemLabel, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}}, @{n='FreeGB';e={[math]::Round($_.SizeRemaining/1GB)}} | Format-Table

# BIOS
Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate | Format-List

# Firmware + Virtualization
$env:firmware_type
(Get-ComputerInfo -Property BiosFirmwareType).BiosFirmwareType
Get-CimInstance Win32_Processor | Select-Object Name, VirtualizationFirmwareEnabled, SecondLevelAddressTranslationExtensions, VMMonitorModeExtensions | Format-List
systeminfo | Select-String -Pattern "Hyper-V|Virtualization"
