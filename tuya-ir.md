# Flashing a Tuya Wi-Fi IR blaster (WB3S / BK7231T)

<!-- spellchecker:ignore bk7231n bk7231t bk72xx cb3s elektroda esphome isolator -->

<!-- spellchecker:ignore irc02 irrecv irsend libretiny ltchiptool openbeken -->

<!-- spellchecker:ignore openbekeniot openshwprojects pinout rbl ssrc tuya wb3s -->

For the **IR-only** Tuya IR remote/blaster built on a **WB3S** module
(**BK7231T**). For the **IR + 433 MHz RF** variant, do this first, then continue
with [`tuya-ir-rf.md`](./tuya-ir-rf.md).

> Wired UART flash only (no cloud-cutter). See [`README.md`](./README.md) for the
> jig, the 3.3 V isolator + UART chain, and the generic `ltchiptool` commands —
> this guide only adds the IR-blaster specifics.

## 1. Confirm the chip

Open the case; the Wi-Fi module is marked **WB3S → BK7231T**. (A `CB3S` marking
would be BK7231N — the jig fits both; just select the matching type in the tool.)

## 2. Back up, then flash OpenBeken (UART, via the jig)

1. Jig pins on VCC / GND / TXD1 / RXD1 / CEN (or the PCB pads), **3.3 V**.
1. **Back up first** (full 2 MB): `ltchiptool flash read BK7231T wb3s-stock.bin`
   — keep it (contains Wi-Fi credentials).
1. Flash OpenBeken (see README → *Install new firmware*): download the
   `OpenBK7231T_UA_*.bin`
   [release image](https://github.com/openshwprojects/OpenBK7231T_App/releases)
   and `ltchiptool flash write` it. Reset
   into download mode with **CEN → GND**.

## 3. Find the pins in OpenBeken

Join the `OpenBK7231T_xxxx` AP → set Wi-Fi → open the web UI (it has a live log).

- **Start from the baseline template** — OpenBeken's
  [CS-SSRC-IRC](https://openbekeniot.github.io/webapp/devices/Tuya_CS_SSRC_IRC.html)
  config is the common starting point for both Tuya WB3S remotes: **IR-RX P8, LED
  P9, IR-TX P26** (the template's P23 `dInput` is the IR+RF unit's side button —
  absent on the IR-only board). Always verify; or browse the full
  [device database](https://openbekeniot.github.io/webapp/devicesList.html).
- **IR-RX:** set a candidate pin's role to `IRRecv`, watch the log, and press any
  IR remote at the device — the pin that logs decoded IR is it.
- **IR-TX:** set a candidate to `IRSend`, fire a test, and watch the IR LED
  **through a phone camera** (IR shows as a purple/white glow).
- **LED / button:** set roles `LED` / `Btn` and toggle / press, observe.
- Pins are `P0…P26`. Known maps (always verify):
  - **S06**: btn P6, IR-RX P8, LED P9, IR-TX P26
  - **S18**: btn P6, IR-RX P7, LED P8, IR-TX P26
  - **IRC02**: btn P6, LED P7, IR-RX P24, IR-TX P26 — *PCB swaps the RX/TX silk*

## 4. Use it

Set the IR pins, enable **Flag 14** (Config → Flags) to publish received IR to
`<device>/ir/get` over MQTT, then integrate with Home Assistant.

## 5. (Optional) Move to ESPHome — OTA, no re-opening

Upload ESPHome/LibreTiny's built `image_bk7231t_app.ota.rbl` via OpenBeken's OTA
panel; rename it to start with `OpenBK7231T_` so OpenBeken's filename check passes
(use the `.ota.rbl`, **not** the `UG` file). Your jig + backup are the recovery
path if it fails. Example ESPHome (LibreTiny) config:

```yaml
bk72xx:
  board: wb3s                              # WB3S = BK7231T
remote_transmitter:
  pin: P26                                 # IR-TX — verify
  carrier_duty_percent: 50%
remote_receiver:
  pin: { number: P8, inverted: true }      # IR-RX — verify
  dump: all
status_led:
  pin: { number: P9, inverted: true }      # LED — polarity verify
button:
  - platform: template
    name: "TV Power"                         # one template button per IR function
    on_press:
      - remote_transmitter.transmit_nec:     # decoded protocol — read via dump: all
          address: 0xE0E0
          command: 0x40BF
```

Read each code from the logs (`dump: all`) once, then hard-code it as a
`template` button like above — one per function. **Prefer decoded protocols
(NEC/Samsung/…) over raw.** The two runtime, no-recompile alternatives — a
`globals`-based slot store, or the
[IR/RF Proxy](https://esphome.io/components/ir_rf_proxy/) — replay the **raw**
captured timings, which are more fragile (capture jitter, repeat-frame and
receiver-tolerance issues), whereas a decoded code regenerates a spec-clean
waveform on every send. Runtime learning's only real win is capturing *unknown*
remotes without a re-flash.

## References

- [`README.md`](./README.md) — jig, UART/isolator chain, datasheet & pinout links
- [OpenBeken](https://github.com/openshwprojects/OpenBK7231T_App) +
  [device database](https://openbekeniot.github.io/webapp/devicesList.html)
- [IR remote pin maps (S06/S18/IRC02)](https://www.elektroda.com/rtvforum/topic3999618.html)
