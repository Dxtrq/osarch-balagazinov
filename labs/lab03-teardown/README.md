# Lab 3 — Teardown, and the same machine from the command line

**Student:** Damir Balagazinov  
**Date:** 08.11.2026  
**Host:** Windows 11 laptop (AMD Ryzen 5 7430U, 16 GB RAM)  
**Linux:** Ubuntu Server VM in VirtualBox (describes the virtual machine, not the physical host)

## What I did

1. Opened the official maker pages for all 10 components, took screenshots, and wrote captions that state what each part is, what it connects to, and what limits it.
2. Compared the two motherboards (socket, chipset, memory type, supported CPU generations).
3. Built two working systems from the available parts and explained why each part belongs in that build.
4. Collected the same hardware facts from the command line on Windows and on Linux.

## 1. The ten parts

Every fact below comes from the maker’s page. Shop pages were not used as the primary source.

### Processors

**AMD Ryzen 5 7600**  
![Ryzen 5 7600](evidence/photos/ryzen5-7600.png)  
Desktop CPU, Zen 4 architecture, 6 cores / 12 threads, 3.8 GHz base – 5.1 GHz boost, 65 W TDP, integrated Radeon Graphics.  
Connects to Socket **AM5**.  
Limits: AM5 only (does not fit AM4), DDR5 only, official memory speed DDR5-5200. Comes with the Wraith Stealth cooler.  
Link: https://www.amd.com/en/products/processors/desktops/ryzen/7000-series/amd-ryzen-5-7600.html

**Intel Core i5-13400**  
![Core i5-13400](evidence/photos/i5-13400.png)  
Desktop CPU, 13th Generation (Raptor Lake), 10 cores (6P + 4E) / 16 threads, up to 4.6 GHz, 65 W base power, Intel UHD Graphics 730.  
Connects to Socket **LGA1700**.  
Limits: LGA1700 only. Supports both DDR4-3200 and DDR5-4800 (the motherboard decides which). The boxed version includes the Laminar RM1 cooler.  
Link: https://ark.intel.com/content/www/us/en/ark/products/230495/intel-core-i513400-processor-20m-cache-up-to-4-60-ghz.html

### Motherboards

**ASUS PRIME B650M-A**  
![ASUS PRIME B650M-A](evidence/photos/asus-b650m-a.png)  
Micro-ATX motherboard, Socket AM5, AMD B650 chipset, 4× DDR5 DIMM slots.  
Connects: AM5 CPU, DDR5 memory, M.2 NVMe, SATA drives, 24-pin + 8-pin power.  
Limits: only Ryzen 7000 / 8000 / 9000 series, DDR5 only, no Wi-Fi on this model.  
Link: https://www.asus.com/motherboards-components/motherboards/prime/prime-b650m-a/techspec/

**MSI PRO B760M-A WIFI DDR4**  
![MSI PRO B760M-A WIFI DDR4](evidence/photos/msi-b760m-a-wifi-ddr4.png)  
Micro-ATX motherboard, Socket LGA1700, Intel B760 chipset, 4× DDR4 DIMM slots, Wi-Fi 6E + 2.5G LAN.  
Connects: LGA1700 CPU, DDR4 memory, M.2, SATA, 24-pin + 8-pin power.  
Limits: only Intel 12th / 13th / 14th Gen, DDR4 only.  
Link: https://www.msi.com/Motherboard/PRO-B760M-A-WIFI-DDR4/Specification

### Memory

**Kingston FURY Beast DDR5-5600 16 GB**  
![Kingston FURY Beast](evidence/photos/kingston-fury-ddr5-5600.png)  
DDR5 UDIMM, 16 GB, 5600 MT/s, 288 pins, non-ECC.  
Connects to one DDR5 DIMM slot.  
Limits: fits only DDR5 motherboards. 5600 MT/s requires XMP/EXPO to be enabled in BIOS.  
Link: https://www.kingston.com/en/memory/search?partid=KF556C40BB-16

**Crucial DDR4-3200 16 GB**  
![Crucial DDR4](evidence/photos/crucial-ddr4-3200.png)  
DDR4 UDIMM, 16 GB, 3200 MT/s, 288 pins, non-ECC.  
Connects to one DDR4 DIMM slot.  
Limits: fits only DDR4 motherboards (key notch is in a different place from DDR5).  
Link: https://www.crucial.com/memory/ddr4/ct16g4dfra32a

### SSDs

**Samsung 990 PRO 1 TB**  
![Samsung 990 PRO](evidence/photos/samsung-990-pro-1tb.png)  
NVMe SSD, M.2 2280, PCIe 4.0 x4, up to ~7450 MB/s read.  
Connects directly into an M.2 slot (no cables).  
Limits: needs an M.2 slot with PCIe lanes; speed is limited if the slot is only PCIe 3.0.  
Link: https://semiconductor.samsung.com/consumer-storage/internal-ssd/990pro/

**Samsung 870 EVO 1 TB**  
![Samsung 870 EVO](evidence/photos/samsung-870-evo-1tb.png)  
2.5-inch SATA SSD, SATA 6 Gb/s, ~560 MB/s read.  
Connects with a SATA data cable to the motherboard and a SATA power cable from the PSU.  
Limits: SATA interface caps the speed at approximately 560 MB/s.  
Link: https://www.samsung.com/uk/memory-storage/sata-ssd/870-evo-1tb-sata-3-2-5-ssd-mz-77e1t0b-eu/

### Power and cooling

**Corsair RM750e (750 W)**  
![Corsair RM750e](evidence/photos/corsair-rm750e.png)  
Fully modular ATX power supply, 750 W, 80+ Gold.  
Connects: 24-pin to motherboard, EPS 8-pin to CPU, SATA/Molex to drives, PCIe to graphics card.  
Limits: total continuous power is 750 W.  
Link: https://www.corsair.com/us/en/p/psu/cp-9020262-na/rme-series-rm750e-fully-modular-low-noise-atx-power-supply-cp-9020262-na

**Stock coolers**

- **AMD Wraith Stealth** (comes with Ryzen 5 7600)  
  ![Wraith Stealth](evidence/photos/wraith-stealth.png)  
  Low-profile cooler for 65 W CPUs. Connects to the AM5 retention bracket and the 4-pin CPU_FAN header.

- **Intel Laminar RM1** (comes with boxed i5-13400)  
  ![Laminar RM1](evidence/photos/laminar-rm1.png)  
  Stock cooler for 12th/13th/14th Gen boxed processors. Connects to the LGA1700 retention and the 4-pin CPU_FAN header.

## 2. The two motherboards side by side

| Feature                  | ASUS PRIME B650M-A          | MSI PRO B760M-A WIFI DDR4       |
|--------------------------|-----------------------------|---------------------------------|
| Socket                   | AM5                         | LGA1700                         |
| Chipset                  | AMD B650                    | Intel B760                      |
| Memory type              | 4× DDR5                     | 4× DDR4                         |
| Supported CPUs           | Ryzen 7000 / 8000 / 9000    | Intel 12th / 13th / 14th Gen    |
| Takes Ryzen 5 7600?      | Yes                         | No                              |
| Takes Core i5-13400?     | No                          | Yes                             |
| Wi-Fi                    | No                          | Yes (Wi-Fi 6E)                  |

## 3. Two builds that work

### Build A — AMD platform

| Part                        | Why it is in this build |
|-----------------------------|-------------------------|
| AMD Ryzen 5 7600            | Matches the only AM5 board. Has integrated graphics, so no discrete GPU is required. |
| ASUS PRIME B650M-A          | The only AM5 motherboard in the list. Has HDMI/DP for the CPU graphics. |
| Kingston FURY Beast DDR5    | AM5 platform is DDR5-only; this is the only DDR5 module available. |
| Samsung 990 PRO 1 TB        | Fits the M.2 slot and uses the full PCIe 4.0 bandwidth. |
| Corsair RM750e              | Supplies the required 24-pin and EPS 8-pin connectors. 750 W is more than enough. |
| Wraith Stealth              | Comes in the box with the Ryzen 5 7600. |

**Still needs:** micro-ATX case, monitor, keyboard, mouse, second DDR5 stick for dual-channel, operating system.

### Build B — Intel platform

| Part                        | Why it is in this build |
|-----------------------------|-------------------------|
| Intel Core i5-13400         | Matches the only LGA1700 board. Has UHD 730 graphics. Officially supports DDR4-3200. |
| MSI PRO B760M-A WIFI DDR4   | The only LGA1700 board. Has DDR4 slots and built-in Wi-Fi. |
| Crucial DDR4-3200 16 GB     | The only DDR4 module in the list. Runs at the CPU’s official DDR4 speed. |
| Samsung 870 EVO 1 TB        | Works on the board’s SATA ports (the 990 PRO is already used in Build A). |
| Laminar RM1                 | Comes in the boxed version of the i5-13400. |

**Still needs:** power supply (the only RM750e went to Build A), micro-ATX case, SATA data cable, monitor, keyboard, mouse, operating system.

## 4. The same facts from the command line

| Fact                    | Windows (PowerShell)                                      | Linux                                      |
|-------------------------|-----------------------------------------------------------|--------------------------------------------|
| CPU model               | `Get-CimInstance Win32_Processor \| Select Name`         | `lscpu` (Model name)                       |
| Cores / threads         | `Get-CimInstance Win32_Processor \| Select NumberOfCores, NumberOfLogicalProcessors` | `lscpu` |
| Total memory            | `(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory` | `free -h`                               |
| Memory modules          | `Get-CimInstance Win32_PhysicalMemory`                    | `sudo dmidecode -t memory`                 |
| Disk model / type       | `Get-PhysicalDisk`                                        | `lsblk -d -o NAME,MODEL,SIZE,ROTA,TRAN`    |
| Free space              | `Get-Volume`                                              | `df -h`                                    |
| Firmware type           | `bcdedit` + `Get-CimInstance Win32_BIOS`                  | `ls /sys/firmware/efi`                     |

Raw outputs are saved in:
- `evidence/windows-specs.txt`
- `evidence/linux-specs.txt`

Note: the Linux output was collected inside the VirtualBox Ubuntu Server VM, therefore it describes the virtual machine.

## What did not work the first time

- One shop page incorrectly listed the Ryzen 5 7600 as Socket AM4. AMD’s own page clearly states AM5. Using the shop page would have produced an impossible build.
- The Crucial product page sometimes redirects or returns a soft 404. The datasheet and archived versions were used instead.

## Evidence

- `evidence/photos/` — screenshots of the official maker pages for all ten parts (plus both stock coolers)
- `evidence/windows-specs.txt` — raw PowerShell output
- `evidence/linux-specs.txt` — raw Linux output (from the VM)
