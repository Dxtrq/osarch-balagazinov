# Lab 00 — System Inventory

## Summary table

| Component              | Details                                      |
|------------------------|----------------------------------------------|
| **CPU**                | AMD Ryzen 5 7430U with Radeon Graphics       |
| **Cores / Threads**    | 6 cores / 12 logical processors              |
| **RAM**                | 16 GB (2 × 8 GB) @ 3200 MHz                  |
| **RAM Manufacturer**   | Wodposit                                     |
| **Storage**            | 954 GB NVMe SSD (WPBSNM8-1TMP)               |
| **Disk bus**           | NVMe                                         |
| **Volumes**            | C: 299 GB (73 GB free), D: 653 GB (283 GB free) |
| **BIOS Manufacturer**  | American Megatrends International, LLC.      |
| **BIOS Version**       | 1.17                                         |
| **BIOS Release Date**  | 2025-04-24                                   |
| **Firmware type**      | UEFI                                         |
| **Virtualization**     | Enabled in firmware (True). Hypervisor is present. |

## Evidence

All raw command outputs are stored in the `evidence/` folder as plain text files:

- `01-cpu.txt` — processor name, cores, logical processors  
- `02-memory.txt` — memory modules (capacity, speed, manufacturer)  
- `03-disk.txt` — physical disk + volumes (size & free space)  
- `04-bios.txt` — BIOS manufacturer, version, release date  
- `05-firmware-virtualization.txt` — firmware type (UEFI) + virtualization status  

## Commands used

```powershell
# CPU
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors | Format-List

# Memory modules
Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, @{n='GB';e={$_.Capacity/1GB}}, Speed, ConfiguredClockSpeed, Manufacturer | Format-Table

# Disk
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, BusType, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}} | Format-Table
Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, FileSystemLabel, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}}, @{n='FreeGB';e={[math]::Round($_.SizeRemaining/1GB)}} | Format-Table

# BIOS
Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate | Format-List

# Firmware type
$env:firmware_type
(Get-ComputerInfo -Property BiosFirmwareType).BiosFirmwareType

# Virtualization
Get-CimInstance Win32_Processor | Select-Object Name, VirtualizationFirmwareEnabled, SecondLevelAddressTranslationExtensions, VMMonitorModeExtensions | Format-List
systeminfo | Select-String -Pattern "Hyper-V|Virtualization"
