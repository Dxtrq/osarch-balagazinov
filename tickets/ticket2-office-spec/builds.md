# Four builds — load, bottleneck, trade-off

All prices: shop.kz (Белый Ветер / White Wind, Almaty, delivers across Kazakhstan), first collected **21.11.2026** and **re-checked on 23.11.2026** with a screenshot of every product page ([evidence/screenshots/](evidence/screenshots/), URL and capture time on each image). Every line is in [budget.csv](budget.csv), which also has the per-build TOTAL rows and the GRAND TOTAL. Compatibility and power draw were checked in PCPartPicker ([evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md)).

**Two parts changed between the two dates** — both went out of stock (screenshots `*-OUT-OF-STOCK.png`): the MSI RTX 5060 Shadow 2X (305,990) was replaced by the **Gigabyte RTX 5060 Windforce MAX OC V2** (324,990, same GPU), and the AOC Q27G4XF monitor (98,990) by the **AOC Q27B36X** (86,990, also 27" IPS 2560×1440, 144 Hz instead of 180 Hz — irrelevant for code). All other prices were identical on both dates.

**One platform for all four:** Intel LGA1700 with **DDR4**. On 21.11.2026 memory is the most expensive part in Kazakhstan: 32 GB of DDR5 costs 387,100–446,300 KZT, 32 GB of DDR4 (2 × 16 GB Lexar) costs 171,200 KZT. Every AMD option that fits (Ryzen 8500G/8600G, Ryzen 7 7700) needs DDR5, which would eat ~220,000 KZT more per 32 GB machine. DDR4-3200 is slower than DDR5-5600 by roughly 5–10 % in memory-heavy work — a loss nobody in this office will notice, unlike a 220,000 KZT hole in the budget. A side benefit: one platform, one spare-parts shelf, and RAM/SSD/PSU are interchangeable between machines.

Shared by all four: **1 TB NVMe SSD** (hard requirement), **Windows 11 Pro OEM** (102,990 — Pro, not Home, because an office needs BitLocker, Remote Desktop and joining a domain later), **Logitech MK120** keyboard + mouse (8,990).

---

### Build 1 — Accountant
**Load:** 1C:Enterprise (file database on the local disk), Excel with large ledgers, a browser with the bank client and the tax portal (cabinet.salyk.kz), PDF scans. One or two programs at a time.
**Bottleneck:** single-thread speed and disk latency. 1C in file mode is mostly one thread and many small random reads — a fast NVMe matters more than cores. Graphics, cores and huge RAM do not matter here.
**Trade-off:** Core i3-12100 (4 cores) instead of an i5. It has the same per-core speed as the i5-12400 in single-threaded work; the ~22,700 KZT saved went into the sales machine's memory. 16 GB (2 × 8 GB, dual channel) is the hard minimum and is enough for 1C + Excel + browser. A 24" 1080p IPS screen — enough for spreadsheets, no reason to pay for 1440p.

| Part | Model | KZT |
|---|---|---|
| CPU | Intel Core i3-12100 (4C/8T, UHD 730) | 64,800 |
| Cooler | DeepCool Theta 31 PWM | 5,790 |
| Board | MSI PRO H610M-S DDR4 II | 31,990 |
| RAM | 2 × 8 GB DDR4-3200 Lexar | 81,800 |
| SSD | Kingston NV3 1 TB PCIe 4.0 | 85,990 |
| Case / PSU | PCCooler C3 B310 / MSI MAG A500N-H 500 W | 26,580 |
| OS | Windows 11 Pro OEM | 102,990 |
| Monitor | Philips 24E1N1100A 23.8" IPS 1080p | 42,590 |
| Keyboard + mouse | Logitech MK120 | 8,990 |
| **Total** | | **451,520** (budget.csv rows 2–12) |

### Build 2 — Sales manager
**Load:** CRM in a browser with 30–40 tabs, WhatsApp Web, Excel, video calls (Zoom / Google Meet) for several hours a day, often all at once.
**Bottleneck:** memory, not CPU. Chrome with forty tabs plus a video call takes 11–12 GB; with 16 GB and Windows itself the machine starts paging in the middle of a customer call. The second load is video encoding during calls — the i5's 6 cores and Intel Quick Sync handle it.
**Trade-off:** Core i5-12400 instead of an i5-14400, and the money went into **32 GB instead of 16 GB**. The CPU idles in this role; the memory does not. Same cheap board and 1080p monitor as the accountant. A webcam is included (7,590) because a desktop monitor has none.

| Part | Model | KZT |
|---|---|---|
| CPU | Intel Core i5-12400 (6C/12T, UHD 730) | 87,500 |
| RAM | 2 × 16 GB DDR4-3200 Lexar | 171,200 |
| Webcam | Defender G-Lens 2581 Full HD | 7,590 |
| Cooler, board, SSD, case, PSU, OS, monitor, keyboard+mouse | same as Build 1 | 304,920 |
| **Total** | | **571,210** (budget.csv rows 13–24) |

### Build 3 — Web developer
**Load:** VS Code / JetBrains IDE, Docker with 4–6 containers (database, backend, frontend dev server, Redis), a browser with DevTools, sometimes a Linux VM; builds (`npm run build`, `docker build`) many times a day.
**Bottleneck:** memory first, then cores. Each container and the IDE's indexer hold RAM permanently; a VM takes 4 GB on its own. Builds and test runs are parallel and scale with cores.
**Trade-off:** Core i5-14400 (10 cores / 16 threads) instead of an i7 — about half the price of the i7-14700 for roughly two-thirds of its multi-core speed (16 threads vs 28). 32 GB DDR4, but on a **B760 board with four DIMM slots**, so the step to 64 GB later is just "add two sticks", no replacement. A faster SSD (WD SN5100) because `node_modules` and Docker layers are thousands of small files. A 27" 1440p monitor: code and a browser side by side is a productivity gain, not a luxury.

| Part | Model | KZT |
|---|---|---|
| CPU | Intel Core i5-14400 (10C/16T) | 90,990 |
| Cooler | DeepCool AK400 | 13,990 |
| Board | ASRock B760M Pro-A/D4 (4 DIMM slots) | 51,990 |
| RAM | 2 × 16 GB DDR4-3200 Lexar | 171,200 |
| SSD | WD Blue SN5100 1 TB PCIe 4.0 | 96,990 |
| Case / PSU | MSI MAG Forge M100A / MSI MAG A500N-H 500 W | 30,580 |
| OS | Windows 11 Pro OEM | 102,990 |
| Monitor | AOC Q27B36X 27" IPS 2560×1440, 144 Hz | 86,990 |
| Keyboard + mouse | Logitech MK120 | 8,990 |
| **Total** | | **654,710** (budget.csv rows 25–35) |

### Build 4 — Designer
**Load:** Photoshop and Illustrator with large layered files, Figma, Premiere Pro for short social-media videos (1080p, sometimes 4K), exporting and rendering.
**Bottleneck:** GPU and memory together. Photoshop filters, Premiere playback with effects and exports all use the GPU; large PSDs and Premiere's cache fill RAM. The CPU matters for export, and Intel's Quick Sync speeds up H.264/H.265 timelines in Premiere.
**Trade-off:** this is where most of the money goes (40 % of what is spent) and it should — the designer's machine is the only one where the hardware limits the work. Still, I took an **RTX 5060 8 GB instead of an RTX 5060 Ti 16 GB** and **32 GB instead of 64 GB** to stay in budget. 8 GB of video memory is enough for Photoshop and 1080p video, tight for 4K. The board has two free DIMM slots, so 64 GB is a later upgrade. 650 W PSU for the GPU with headroom. Monitor: 27" IPS 1440p; shop.kz does not list its sRGB coverage, so that has to be checked against Lenovo's specification before buying (see README, section 5).

| Part | Model | KZT |
|---|---|---|
| CPU | Intel Core i7-14700 (20C/28T, Quick Sync) | 179,690 |
| Cooler | DeepCool AK400 | 13,990 |
| Board | ASRock B760M Pro-A/D4 (4 DIMM slots) | 51,990 |
| RAM | 2 × 16 GB DDR4-3200 Lexar | 171,200 |
| SSD | WD Blue SN5100 1 TB PCIe 4.0 | 96,990 |
| GPU | Gigabyte GeForce RTX 5060 Windforce MAX OC V2 8 GB | 324,990 |
| Case / PSU | MSI MAG Forge M100A / MSI MAG A650BN 650 W | 40,580 |
| OS | Windows 11 Pro OEM | 102,990 |
| Monitor | Lenovo L27q-4A 27" IPS 2560×1440 | 120,690 |
| Keyboard + mouse | Logitech MK120 | 8,990 |
| **Total** | | **1,112,100** (budget.csv rows 36–47) |

---

## Totals

| Build | KZT | Share |
|---|---:|---:|
| Accountant | 451,520 | 16 % |
| Sales manager | 571,210 | 20 % |
| Web developer | 654,710 | 24 % |
| Designer | 1,112,100 | 40 % |
| **All four** | **2,789,540** (budget.csv row 48, GRAND TOTAL) | |
| Budget | 3,000,000 | |
| **Left** | **210,460** (budget.csv row 50) | |

The 210,460 KZT left is deliberately **not** spent on more hardware: assembly and delivery are not included in shop.kz prices, a sales headset is still missing (none in stock on 21.11.2026), and memory prices in Kazakhstan have been moving within weeks — a 7 % reserve protects the order if prices change between this quote and payment — and they did: in two days two parts went out of stock and the replacements changed the total by +7,000 KZT. If the reserve is not needed, the first use is +32 GB for the designer (see README, question 1).

**Compatibility check:** all four builds are entered in PCPartPicker ([evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md), list links and screenshots). Web developer and designer: **no issues**. Accountant and sales: one **warning** — PCPartPicker says the MSI PRO H610M-S DDR4 II needs its latest BIOS for the i3-12100 / i5-12400, so the BIOS version is checked (and updated by the shop if needed) before assembly. Estimated power: 183 W / 226 W / 257 W on 500 W units, **473 W on the designer's 650 W** unit (73 % at full load) — my earlier hand estimate of ~400 W for the designer was too low. By hand I also checked what PCPartPicker does not: the i7-14700 gets a tower cooler (AK400), not the small Theta 31, because it can draw up to 219 W in turbo.
