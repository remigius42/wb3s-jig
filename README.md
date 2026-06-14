# [WB3S in-circuit programming jig](https://github.com/remigius42/wb3s-jig)

<!-- spellchecker:ignore adum aliexpress autocenter beken bk7231n bk7231t bk7231tools -->

<!-- spellchecker:ignore cb3s ch340 cloudcutter cts datasheet debossed esphome -->

<!-- spellchecker:ignore imgsize isolator kuba ltchiptool makerworld openbeken -->

<!-- spellchecker:ignore openscad openshwprojects pinout printables rts ssid -->

<!-- spellchecker:ignore szczodrzyński ttl ttyusb tuya uart uf2 usb2uart viewall -->

Copyright 2026 [Andreas Remigius Schmidt](https://github.com/remigius42)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/remigius42/wb3s-jig/actions/workflows/ci.yml/badge.svg)](https://github.com/remigius42/wb3s-jig/actions/workflows/ci.yml)

> [!WARNING]
> **Work in progress — untested.** This jig and its flashing guides have not yet
> been printed or verified against real hardware. The `shield_*` dimensions are
> read off low-resolution datasheet figures, so expect to tune parameters before
> anything fits. Treat everything here as a design draft and use at your own risk.

An OpenSCAD-printed clip-on jig for flashing a **Tuya WB3S** Wi-Fi/BT module
*after* it has been SMD-soldered onto a host PCB — no test header, and no
soldering of flying leads.

The jig is a cap that drops over the module's shield can. Female-to-male Dupont
jumper wires are pushed (male end first) into angled channels that guide their
tips onto the five castellated edge pads needed for flashing — **VCC, GND, TXD1,
RXD1, CEN**. The female ends plug into a USB-UART adapter, so the jig itself
never wears out. A sprung C-clip squeezes the cap down onto the host PCB to keep
the pins seated.

## Files

- [`wb3s_jig.scad`](./wb3s_jig.scad) — the cap + clamp (renders both, side by
  side).
- [`tuya-ir.md`](./tuya-ir.md) — flashing guide for a Tuya IR-only blaster.
- [`tuya-ir-rf.md`](./tuya-ir-rf.md) — flashing guide for a Tuya IR + 433 MHz RF
  blaster (extends `tuya-ir.md`).

## How it works

- **Registration:** the roof drops over the shield can; internal rims hug the
  can sides (X/Y) and the roof rests on the can top (Z).
- **Contacts:** angled bores carry each Dupont pin from above-outside down to
  its edge pad. TXD1/RXD1 fan apart because their pads are only 2 mm apart.
- **Inspection:** a viewport over each pad lets you watch the pin tip seat.
- **Labels:** pin names are debossed on top next to each viewport; the antenna
  meander is engraved on top as an orientation key (long parallel segments to
  the right = matches the chip viewed top-down).
- **Clamp:** a C-clip hooks over the cap top and under the host PCB at the back
  (antenna side, no pads), springing the stack together. Assumes the host PCB is
  reachable from behind the module.

## Pinout (top view, antenna pointing away from you)

| edge | pads (back → front) |
| -- | -- |
| left (X = 0) | CEN … VCC |
| right (X = pcb_w) | TXD1, RXD1 … GND |

The Y = 0 short edge carries only the flash/test pads (SCK/CS/SI/SO) — not used
(the smaller Tuya boards don't even connect them).

## Hardware / tools

Flashing chain: **PC → USB isolator → USB-UART adapter (3.3 V) → Dupont wires →
this jig → WB3S**.

- **USB-to-TTL UART adapter (CH340G / CH340E)** —
  [AliExpress](https://de.aliexpress.com/item/32809304504.html). **Switch it to
  3.3 V** — the WB3S is a 3.3 V part and 5 V logic can damage it. Wire TXD1 →
  adapter RX, RXD1 → adapter TX, plus VCC / GND / CEN.
  - Printable case:
    [MakerWorld](https://makerworld.com/en/models/2462910-case-for-usb-2-ttl-ch340-ch340g-usb2uart)
- **USB isolator (ADuM3160, 1500 V)** —
  [AliExpress](https://de.aliexpress.com/item/33016336073.html). Galvanic
  isolation between PC and target; strongly recommended when the host board is
  (or has been) mains-powered.
  - Printable case:
    [Printables](https://www.printables.com/model/748947-adum-3160-usb-isolator-case-enclosure)

## Flashing workflow

With the jig's pins on the pads (TXD1, RXD1, CEN, VCC, GND) and the chain
connected (PC → isolator → **3.3 V** UART → jig), use
[`ltchiptool`](https://github.com/libretiny-eu/ltchiptool) (LibreTiny's CLI,
which wraps [`bk7231tools`](https://github.com/tuya-cloudcutter/bk7231tools)).
The WB3S's chip family is **BK7231T**. (The pin-compatible **CB3S** uses the
**BK7231N** instead; the flash tools auto-detect the chip during the handshake,
and a CRC error usually means the wrong chip type was selected. Read the marking
on the can if unsure: `WB3S` → BK7231T, `CB3S` → BK7231N.)

**Reset into download mode:** start a command, then within a few seconds reset
the chip so the tool can catch it. CEN is the reset line (active-low), brought
out by the jig: briefly bridge the **CEN wire → GND** by hand. The adapter does
**not** need a flow-control pin — that only *automates* the reset: wire CEN →
**RTS** (a driven output the tool can toggle), **not CTS** (an input that can't
drive anything). Without it, reset manually. (You can also just power-cycle by
interrupting the **VCC wire**, but CEN is cleaner.) Keep the supply at **3.3 V**
— a weak adapter regulator can brown out during reset, so power from a proper
3.3 V rail if needed.

### 1. Back up the stock firmware (do this first)

```sh
ltchiptool flash read BK7231T wb3s-stock-backup.bin
```

- Dumps the full 2 MB flash. A valid backup is **exactly 2,097,152 bytes** — any
  other size is incomplete; redo it.
- ⚠️ The dump contains the device's **Wi-Fi SSID/password** — keep it private.
- Keep several copies; it's your only route back to stock.
- Underlying-tool equivalent: `bk7231tools read_flash -d /dev/ttyUSB0 wb3s-stock-backup.bin`

### 2. Erase

- A separate full erase usually **isn't needed** — `flash write` erases the app
  region before writing it, and the new firmware replaces the old one (including
  stored config/credentials).
- ⚠️ **Do not erase/overwrite the bootloader (flash offset `0x000000`).** Unlike
  the BK7231**N**, the BK7231**T** has **no ROM download mode**, so wiping the
  bootloader **bricks the chip** — recoverable only by SPI flashing (e.g.
  [BK7231_SPI_Flasher](https://github.com/openshwprojects/BK7231_SPI_Flasher)).
  A "full-chip erase" over UART is therefore a bad idea on the WB3S.

### 3. Install new firmware

```sh
ltchiptool flash write firmware.uf2
```

- Auto-detects file type and offset. Common targets: **OpenBeken**
  (`OpenBK7231T_*` images) or **LibreTiny / ESPHome** (`.uf2`).
- Power-cycle when done and watch the firmware's UART console to confirm it
  boots.
- GUI alternative (Windows/Mono) that backs up then flashes in one cycle:
  [BK7231GUIFlashTool](https://github.com/openshwprojects/BK7231GUIFlashTool).

## Printing

- Tuned for a **0.4 mm nozzle**. Print the cap **roof-up** (open cavity on the
  bed) so the labels and antenna key land on the top surface.
- Debossed text stems are ~0.45 mm — legible but not crisp; raise `label_size`
  if your printer needs it.
- **Verify the module/can dimensions against your actual part with calipers**
  before printing — the `shield_*` values are read off low-resolution datasheet
  figures.

## Rendering

```sh
openscad -o preview.png --camera=10,15,8,55,0,25,90 \
  --imgsize=1000,800 --autocenter --viewall --render=true wb3s_jig.scad
```

All the tunable parameters (module/can geometry, clamp, channels, labels) are
grouped at the top of `wb3s_jig.scad`.

## References

Not redistributed here for licensing reasons (see [License](#license)):

- WB3S datasheet (© Tuya) — <https://fcc.report/FCC-ID/2ANDL-WB3S/4580793.pdf>
- LibreTiny WB3S board & pinout — <https://docs.libretiny.eu/boards/wb3s/>

## License

The jig design and documentation in this repository are released under the **MIT
License** — see [`LICENSE`](./LICENSE).

Third-party material is **not** bundled here, only linked: the WB3S datasheet is
© Tuya, and the LibreTiny pinout is part of the MIT-licensed
[LibreTiny](https://github.com/libretiny-eu/libretiny) project (© 2022 Kuba
Szczodrzyński).

## Disclaimer

Not affiliated with or endorsed by Tuya, Beken, or any device manufacturer; all
product names and trademarks belong to their respective owners. This project is
intended for use on hardware **you own**. Flashing third-party firmware can
**brick devices**, **voids the manufacturer warranty**, and — because these
modules are often built into **mains-powered** products — can be **dangerous**:
use proper galvanic isolation and work at your own risk. Everything here is
provided **"as is", without warranty of any kind** (see the [MIT
License](./LICENSE)).
