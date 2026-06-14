# Flashing a Tuya Wi-Fi IR + 433 MHz RF blaster (WB3S + SH-4)

<!-- spellchecker:ignore bk7231t bk72xx cbu cmt2300a csb elektroda esphome fcsb -->

<!-- spellchecker:ignore fsk gencodes gfsk hoperf libretiny moes mosi olivluca ook -->

<!-- spellchecker:ignore openbeken pinout rbl sclk sh4 tinytuya tuya wb3s -->

**Extends [`tuya-ir.md`](./tuya-ir.md)** — do everything there first (confirm
WB3S/BK7231T, back up, flash OpenBeken, find the IR / LED / button pins). This
file only adds the **RF** half.

## The RF hardware

The RF section is a separate **SH-4** module = a **HopeRF CMT2300A** Sub-GHz
transceiver (no onboard antenna → the external antenna you can see). The BK7231T
drives it over a **bit-banged SPI** bus (CSB / SCLK / MOSI + data) — not a single
GPIO, and not UART.

## Firmware choice changes for this unit

- **OpenBeken has no CMT2300A / SH-4 driver** → RF won't work there (IR still
  will). So use OpenBeken only to map the IR / LED / button pins…
- …then **OTA to ESPHome + the
  [`olivluca/tuya_rf`](https://github.com/olivluca/tuya_rf) component**, which is
  the only thing that drives the SH-4. (OTA steps: see `tuya-ir.md` step 5.)

## RF pins (the part OpenBeken can't find for you)

The SPI-bus pins aren't discoverable with OpenBeken's single-pin tester — get
them from a matching device template or by tracing the PCB. The `tuya_rf`
**defaults** (Moes UFO-R2-RF) are:

| role | pin |
| -- | -- |
| tx | P20 |
| rx | P22 |
| sclk | P14 |
| mosi | P16 |
| csb | P6 |
| fcsb | P26 |

⚠️ Because **P26 is the RF `fcsb`** on these combo boards, the **IR-TX moves off
P26** (e.g. to P7) — so this unit's IR map differs from the IR-only blaster's.
Always verify per board.

## ESPHome YAML (IR + RF)

```yaml
external_components:
  - source: github://olivluca/tuya_rf
    components: [tuya_rf]

bk72xx:
  board: wb3s              # WB3S = BK7231T (the repo example uses 'cbu' = BK7231N)

tuya_rf:                   # 433 MHz via SH-4 / CMT2300A — verify pins for YOUR board
  id: rf
  dump: raw
  tx_pin: P20
  rx_pin: P22
  sclk_pin: P14
  mosi_pin: P16
  csb_pin: P6
  fcsb_pin: P26

remote_transmitter:        # IR — P7 here, since P26 is taken by the RF fcsb
  id: ir
  pin: P7
  carrier_duty_percent: 50%
remote_receiver:
  pin: { number: P8, inverted: true }
  dump: nec
```

## Capturing RF codes & limits

- Capture codes from the stock device with `tinytuya`'s
  `RFRemoteControlDevice.py`, then `gencodes.py`; send them as `template` buttons
  emitting raw timings. The repo's `tuya.yaml` has full button examples.
- ⚠️ **Fixed-code OOK / ASK / FSK only — rolling-code remotes can't be cloned.**

## References

- [`tuya-ir.md`](./tuya-ir.md) — the base flow this extends
- [`olivluca/tuya_rf`](https://github.com/olivluca/tuya_rf) — ESPHome SH-4 /
  CMT2300A component (full `tuya.yaml`, code capture)
- [Tuya SH4 module datasheet](https://developer.tuya.com/en/docs/iot/sh4-module-datasheet?id=Ka04qyuydvubw)
- [CBU + SH4/CMT2300A reverse-engineering (S11)](https://www.elektroda.com/rtvforum/topic3975921.html)
