# Ticket 2 — We are kitting out the new office

## 1. What was asked

> From: Daniyar K. (Director)  
> Subject: computers for the new office  
>
> We are opening the second office and need four computers -- accountant,  
> sales, web developer, designer. Budget 3,000,000 tenge for everything.  
> Everyone says we should just buy the same four machines, is that right?  
> Make sure they last a few years. Monitors included.

## 2. What was actually needed

**Where the request is wrong — four identical machines.** No. The four jobs load a computer in completely different ways (details in [builds.md](builds.md)):

| Role | What limits the work | What it needs most |
|---|---|---|
| Accountant | single-thread speed, disk latency (1C) | fast SSD; 4 cores and 16 GB are enough |
| Sales manager | memory (browser tabs + video calls) | 32 GB; CPU almost idle |
| Web developer | memory and cores (Docker, IDE, builds) | 32 GB+, 10+ cores, big screen |
| Designer | graphics card and memory | a real GPU, 32 GB, 8+ cores |

Identical machines force a bad choice. If all four are built like the designer's (1,112,100 KZT), four cost **4,448,400 KZT** — 48 % over budget. If all four are built like the accountant's (451,520 KZT), the designer gets a machine with no graphics card that cannot run Premiere properly, and the developer gets 16 GB that Docker fills in a day. The only thing that *should* be identical is the platform (same socket, same memory type, same SSD and PSU family), so spare parts are interchangeable — that is what I did.

**What the request left out:**
- What software each person actually uses — "designer" can mean Canva in a browser or 4K video in Premiere.
- Whether 3,000,000 includes Windows licences, keyboards, mice, webcams, headsets, a UPS, assembly and delivery. The ticket mentions only monitors.
- What "a few years" means — I took **4–5 years**, the usual office replacement cycle; it decides whether to buy the cheapest parts or leave room for upgrades.
- Whether there is anything already in the new office (monitors, peripherals) and whether there is an IT person to assemble four machines.
- Licensing — a company must use licensed Windows; the request does not mention it.

**What I would have asked Daniyar, and what I assumed instead:**

| Question | My assumption |
|---|---|
| What programs does each person use daily? | Accountant: 1C + Excel; sales: browser CRM + video calls; developer: Docker + IDE; designer: Photoshop/Illustrator/Figma + Premiere for short 1080p videos. |
| Does the budget include Windows, peripherals, assembly? | Windows 11 Pro + keyboard/mouse + monitor are inside the budget; assembly, delivery and a UPS are paid from the reserve. |
| How long should they last? | 4–5 years, with one memory upgrade in the middle for the heavy roles. |
| Do they need Pro or Home Windows? | Pro — BitLocker for the accountant's data, Remote Desktop, and a possible domain later. |
| Who assembles them? | An IT person in the office (me); otherwise see question 2 — prebuilt. |

**Hard requirements from the brief, all met:** every machine has ≥ 16 GB RAM (16/32/32/32), a 1 TB SSD, licensed Windows 11 Pro and a monitor; prices in KZT from shop.kz (delivers across Kazakhstan), each dated 23.11.2026 with a screenshot.

## 3. What I did

1. Wrote down the load for each role and found its bottleneck (table above, details in builds.md).
2. Collected prices on **21.11.2026** at shop.kz and **re-checked them on 23.11.2026 with a screenshot of every product page** ([evidence/screenshots/](evidence/screenshots/), 30 images, each with the URL and capture time in a bar above the page). Two parts had gone out of stock in those two days and were replaced (see builds.md). The 21.11 text notes are kept in [evidence/vendor-quotes/](evidence/vendor-quotes/), each with the product, price, URL, date and a short quote of the price on the page. I re-checked three of them (GPU, RAM, Windows) directly against the product page the same day.
3. Found that memory decides the platform: 32 GB DDR5 = 387,100–446,300 KZT, 32 GB DDR4 = 171,200 KZT. So all four builds are Intel LGA1700 + DDR4 (AMD's current desktop chips need DDR5).
4. Built each machine around its bottleneck and cut everything that does not serve it (no GPU for three roles, cheaper CPU where memory matters more).
5. Entered all four builds in **PCPartPicker** for the compatibility check and power estimate ([evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md): 4 list links + screenshots). Result: web developer and designer — no issues; accountant and sales — a BIOS-version warning for the H610 board (checked before assembly); designer 473 W on a 650 W PSU. PCPartPicker has no Kazakhstan region, so its dollar prices are not used; where a shop.kz model is missing from its US catalogue, a part with the same socket/type/form factor stands in (table in that file).
6. Priced the same four as prebuilt machines (question 2).

**Result** ([budget.csv](budget.csv)):

| Build | KZT |
|---|---:|
| Accountant | 451,520 |
| Sales manager | 571,210 |
| Web developer | 654,710 |
| Designer | 1,112,100 |
| **Total** | **2,789,540** |
| Reserve (of 3,000,000) | 210,460 (7 %) |

### Question 1 — Which machine will I upgrade first, eighteen months from now, and why?

**The designer's — memory, from 32 GB to 64 GB.** The designer is the only role where the hardware is the limit, and it is the role whose software grows fastest: every Photoshop and Premiere release uses more RAM, and video work moves from 1080p to 4K. I already cut this build to 32 GB to stay in budget, and the ASRock B760M board has two empty slots, so the upgrade is two more DDR4 sticks (171,200 KZT on 23.11.2026, unchanged since 21.11), ten minutes, no reinstall. DDR4 is end-of-line, so if prices start to rise it is worth buying earlier. The web developer is second in line for the same upgrade (same board, also two free slots). The accountant and sales machines should not need anything in their 4–5 years.

### Question 2 — Prebuilt: what does the company gain and lose?

Same vendor, same date, closest prebuilt machine per role ([evidence/vendor-quotes/prebuilt-*.md](evidence/vendor-quotes/)). Prebuilts at shop.kz come **without Windows** (except the Lenovo), so I added the same Windows 11 Pro, monitor and keyboard/mouse as in my builds:

| Role | Prebuilt | PC price | + Windows, monitor, keyboard | vs my build |
|---|---|---:|---:|---:|
| Accountant | WW-KZ office, i3-12100, 16 GB DDR4, **512 GB SSD** | 271,290 | 416,870 | −34,650 |
| Sales | WW-KZ office, i5-14400, **16 GB** DDR5, **512 GB SSD** | 374,490 | 520,070 | −51,140 |
| Web developer | WW-KZ, i5-14400, 32 GB DDR5, 1 TB, RTX 3050 | 731,390 | 930,360 | +275,650 |
| Designer | WW-KZ, Ryzen 5 7500F, RTX 5060 Ti 8 GB, 32 GB DDR5, 1 TB | 899,190 | 1,131,860 | +19,760 |
| **Total** | | | **2,999,160** | **+209,620** |

Prebuilt lands at **2,999,160 KZT — 840 tenge under the budget, with no reserve left at all** — and it still does not meet the brief: two machines have 512 GB SSDs (the requirement is 1 TB) and the sales machine has 16 GB instead of 32 GB. Fixing that (two 1 TB SSDs + 16 GB more DDR5) would add roughly 360,000 KZT more (2 × 85,990 for SSDs + about 190,000 for 16 GB DDR5 at 23.11.2026 prices). The developer prebuilt also carries a gaming GPU (RTX 3050) that a web developer does not use.

- **What the company gains with prebuilt:** one warranty for the whole machine from one seller (no arguing whether the board or the RAM is at fault), assembled and tested before delivery, no IT time spent on assembly, faster to get running.
- **What it loses:** about 230,000 KZT more for *weaker* machines; it pays for parts it does not need (GPU for the developer) and lacks the ones it does (SSD, memory); the role-specific choices disappear — prebuilts come in "office" and "gaming" flavours, not "accountant" and "designer"; and the upgrade path is less certain (unknown board, slots, PSU headroom).

For two of the four roles (accountant, sales) a prebuilt with an SSD swap would be a reasonable choice if nobody in the office can assemble PCs. For the developer and the designer, building wins clearly.

### Question 3 — Who complains about performance within a month, and about what?

**The designer, about Premiere Pro.** Everything else in the office will feel fast, but the designer's machine is the one where I made real compromises: an **8 GB** graphics card and 32 GB of RAM. The first time the designer edits a 4K clip with colour correction and a few effects, the timeline playback will drop frames and Premiere may warn about low video memory; exporting is fine, *editing* in real time is not. The fix is to work with proxies (Premiere makes 1080p copies for editing), and the long-term fix is question 1. I would explain this to the designer on the first day rather than wait for the complaint.

## 4. Evidence

| File | What it proves |
|---|---|
| [budget.csv](budget.csv) | Every part: role, component, model, price KZT, source URL, date (23.11.2026), screenshot file; a TOTAL row per build, GRAND TOTAL, BUDGET and RESERVE rows |
| [evidence/screenshots/](evidence/screenshots/) | 30 screenshots of the shop.kz product pages taken 23.11.2026: price and stock visible, URL and capture time in the caption bar; two `*-OUT-OF-STOCK.png` show why two parts were replaced |
| [builds.md](builds.md) | Load → bottleneck → trade-off for each machine, totals, compatibility reasoning |
| [evidence/vendor-quotes/](evidence/vendor-quotes/) | 45 price snapshots: product, price, vendor, URL, date, a verbatim price line from the page, availability |
| [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md), [evidence/pcpartpicker/](evidence/pcpartpicker/) | 4 PCPartPicker lists (permanent links) with screenshots: compatibility result and estimated wattage per build, stand-in parts explained |

## 5. What I would do differently

1. **Ask for two more quotes.** All prices come from one vendor (shop.kz). Other vendors either blocked automated access (mechta.kz returned 403) or timed out on the day. One vendor makes the comparison easy to check but gives no leverage; for a real order I would get a second quote (Technodom, Sulpak or a local system builder) and a written invoice with a validity date.
2. **Check the designer's monitor before ordering.** shop.kz does not list sRGB coverage for the Lenovo L27q-4A. For a designer, colour accuracy matters more than resolution; I would confirm ≥ 99 % sRGB on Lenovo's spec sheet or pick a monitor that states it, even if it costs more.
3. **Add a headset for the sales manager.** No wired USB headset was in stock on 21.11.2026, so it is missing from the build; it would come out of the reserve.
4. **Screenshot every price at the moment I take it.** My first version had only text notes of the prices. When I went back two days later to take screenshots, two of the parts (the RTX 5060 and the developer's monitor) were already sold out and had to be replaced. A text note cannot prove a price was on the page; a dated screenshot can — and a quote is only valid for days, so the order should be placed right after the quote, or the quote repeated.
