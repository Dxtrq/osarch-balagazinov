# PCPartPicker lists — compatibility and power check (23.11.2026)

PCPartPicker has no Kazakhstan region, so its prices are US dollars from US shops and are **not** used for the budget — the tenge prices come from shop.kz (`budget.csv`, `screenshots/`). PCPartPicker is used for what it is good at: an automatic **compatibility check** (socket, chipset/BIOS, memory type, form factor) and an **estimated power draw** for choosing the PSU.

Each link is a permanent snapshot of the list. A screenshot of each list is in [pcpartpicker/](pcpartpicker/).

| Build | PCPartPicker list | Compatibility result | Estimated wattage | PSU in the build | Screenshot |
|---|---|---|---|---|---|
| Accountant | https://pcpartpicker.com/list/gNbf2k | ⚠ Warning: BIOS (see below) | **183 W** | 500 W | [accountant-list.jpg](pcpartpicker/accountant-list.jpg) |
| Sales manager | https://pcpartpicker.com/list/WRmHn2 | ⚠ Warning: BIOS (see below) | **226 W** | 500 W | [sales-list.jpg](pcpartpicker/sales-list.jpg) |
| Web developer | https://pcpartpicker.com/list/nZbf2k | ✅ No issues | **257 W** | 500 W | [webdev-list.jpg](pcpartpicker/webdev-list.jpg) |
| Designer | https://pcpartpicker.com/list/BPrf2k | ✅ No issues | **473 W** | 650 W | [designer-list.jpg](pcpartpicker/designer-list.jpg) |

## What the check found

**1. BIOS warning on the MSI PRO H610M-S DDR4 II (accountant and sales builds).** PCPartPicker:

> The MSI PRO H610M-S DDR4 II … supports the Intel Core i3-12100 … with BIOS version Latest Beta BIOS. If the motherboard is using an older BIOS version, updating the BIOS will be necessary to support the CPU.

The same warning appears for the i5-12400. Both CPUs are 12th-gen Alder Lake, the generation the H610 chipset launched with, and the "II" revision of this board is a newer production batch, so a board from the shelf will most likely run them as delivered. But a warning is a warning: before assembly I would check the BIOS version on the board's sticker against MSI's CPU support list for this exact board, and ask the shop to update the BIOS if it is older (shop.kz offers assembly, so this can be part of the order). It is now part of the assembly checklist. The B760 board (web developer, designer) gets no such warning with the 14th-gen CPUs.

**2. Power.** The designer build is the only one with a graphics card: 473 W estimated against a 650 W PSU = 73 % load at full CPU+GPU load, which is the efficient range for an 80+ Bronze unit and leaves headroom. The three office builds draw 183–257 W against 500 W units — a 500 W PSU is the smallest decent unit available, not a requirement. My hand estimate in builds.md ("≈ 400 W peak" for the designer) was too low; PCPartPicker's 473 W is the number I now use.

**3. What PCPartPicker does not check:** RAM clearance under the CPU cooler (the AK400 is a tower cooler; Lexar's low-profile DDR4 without heatsinks fits under it) and real-world turbo power of the i7-14700 (PL2 = 219 W — already inside the 473 W estimate).

## Parts that are not in PCPartPicker's (US) catalogue — stand-ins used

PCPartPicker lists what is sold in the US. Where the exact shop.kz model is missing, I used the closest US-catalogue part **with the same compatibility-relevant properties**. The budget still uses the shop.kz model.

| Build part (shop.kz) | Stand-in in PCPartPicker | Why it is equivalent for the check |
|---|---|---|
| Lexar LD4AU008G / LD4AU016G DDR4-3200 (no heatsink) | Lexar THOR 2 × 8 GB / 2 × 16 GB DDR4-3200 | same type, speed, capacity and module count |
| DeepCool Theta 31 PWM (accountant, sales) | DeepCool AG200 | small air cooler for LGA1700, same class (65 W CPUs) |
| PCCooler C3 B310 case (accountant, sales) | MSI MAG FORGE M100A | both Micro-ATX / ATX mid towers; the board is Micro-ATX |
| MSI MAG A500N-H 500 W | MSI MAG A550BN 550 W | same series, ATX, 80+ Bronze; 500 W model not listed |
| Philips 24E1N1100A 23.8" 1080p | Philips 241V8LB 23.8" 1080p | monitors do not affect compatibility |
| AOC Q27B36X 27" 1440p | AOC Q27G4XF 27" 1440p | same (it was the original choice before it went out of stock) |
| Lenovo L27q-4A 27" 1440p | Lenovo L27q 27" 1440p | same |
| Defender G-Lens 2581 webcam (sales) | — (left out) | USB peripheral, no compatibility impact |

Exact matches (same model in both): Intel i3-12100, i5-12400, i5-14400, i7-14700; MSI PRO H610M-S DDR4 II; ASRock B760M Pro-A D4; Kingston NV3 1 TB; WD Blue SN5100 1 TB; DeepCool AK400; Gigabyte RTX 5060 WINDFORCE MAX OC 8 GB; MSI MAG A650BN; Windows 11 Pro OEM; Logitech MK120.

## shop.kz product links (the parts actually priced)

The full list with prices, dates and a screenshot for every line is in `../budget.csv`. Out-of-stock originals: `screenshots/gpu-msi-rtx5060-shadow-OUT-OF-STOCK.png`, `screenshots/monitor-aoc-q27g4xf-OUT-OF-STOCK.png`.
