# SIM setup, activation, and the original guides

This page collects the **original setup references** and the practical SIM/activation notes
for the Moto G Power 2026 (`XT2617V` / `vegas26` / bootloader `vegas`). It does not replace
those guides; it points to them and records what applied to this `tracfone` unit.

## Original guides

- **`qfertig/vegas26-gsi`** — the complete end-to-end guide:
  <https://github.com/qfertig/vegas26-gsi>
  Covers bootloader unlock, the LineageOS 23.2 microG GSI, **SIM/modem unlock**, APN,
  data/SMS/VoLTE, and the overlay notes. This is the main “start here” reference.
- **`parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide`** — the base
  Straight Talk/Walmart root guide, including the FRP/OEM-unlock wall:
  <https://github.com/parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide>
- **`andrewwm/vegas-freedom`** — the bootloader (`lk`) and modem (`md1img`) SIM-unlock
  scripts: <https://github.com/andrewwm/vegas-freedom>
- **XDA — “Moto G Power 2026 XT2617V - WalMart Special (Root, modem unlock/bypass/Unlocked Bootloader)”**:
  <https://xdaforums.com/t/moto-g-power-2026-xt2617v-walmart-special-root-modem-unlock-bypass-unlocked-bootloader.4809158/>
  User reports: carrier activation bypassed, modem unlocked with a new SIM, bootloader
  unlocked, OTA blocker installed.
- **RomLord14495 Moto Roms Drive** (referenced in that XDA thread):
  <https://drive.google.com/drive/folders/1WAlJfCoh0CA8jhdGqINo_kgn7r-Dt678>
  The thread says it contains the network unlock and LineageOS files and warns
  “flash slot b or you’ll brick including lk.” That warning **conflicts** with the
  `vegas-freedom`/`qfertig` modem path, which flashes **`md1img_a` only**. Treat the
  Drive as an additional reference, not a replacement for the tested `md1img_a` path.
- **XDA recovery thread** (source of the working `vegas_ofox.img`):
  <https://xdaforums.com/t/recovery-twrp-orangefox-moto-g-play-moto-g-2026.4799348/>
- **`jimmielin/android_device_motorola_vegas26`** — LineageOS 23.2 device tree:
  <https://github.com/jimmielin/android_device_motorola_vegas26>
- **`Maikyxd/val-protocol`** — LK unlock patch:
  <https://github.com/Maikyxd/val-protocol>
- **`diabl0w/DFRoot`** — temporary root used before persistent Magisk:
  <https://github.com/diabl0w/DFRoot>
- **`tiann/KernelSU`** — KernelSU manager:
  <https://github.com/tiann/KernelSU/releases>
- **Stock firmware mirror** (for `md1img` and other stock images):
  <https://mirrors.lolinet.com/firmware/moto/>

## The SIM screen / carrier activation

The Walmart/Straight Talk units are carrier-locked and the stock setup can stop at a
SIM/activation screen. The two original guides cover this; the short version is:

1. **Back up first** (Part 1.2 of `vegas-freedom` / the `qfertig` guide): all partitions,
   especially `md1img_a`, `lk_a`, `nvram`, `nvdata`, `seccfg`, `persist`, `protect*`,
   `frp`.
2. **Bypass the carrier OEM-unlock wall** if present: on the Tracfone build the
   `no_moto_oem_unlock` restriction greys out “Allow OEM Unlock”; the `frp` last-byte
   write followed by `fastboot oem unlock` is the documented path.
3. **Temporary root** with DFRoot + KernelSU; enable Shell superuser for `adb shell su`.
4. **Install the GSI** (or stay stock). The first `/data` wipe must be a **stock recovery
   factory reset**, not `fastboot -w`, or the second boot bootloops with
   “Can’t load Android system.” The `qfertig` guide has the exact sequence.
5. **APN / data / VoLTE** after the SIM is recognized.

## Carrier lock vs IMEI activation

The XDA report is important: after the modem unlock, a new SIM connected to other
providers, but a **Verizon MVNO refused the IMEI** because Straight Talk had not released
the phone. The **network lock** and the **carrier’s IMEI activation** are separate:

- The modem unlock removes the `NETWORK_LOCKED` SIM restriction.
- The carrier may still reject the IMEI in its activation database, especially Verizon
  MVNOs. An **AT&T/T-Mobile/GSM MVNO** is more likely to activate; the `qfertig` guide
  tested **US Mobile Dark Star (AT&T)**. This does not affect the Wi-Fi backup use.

## No SIM

This unit is used as a Wi-Fi backup and currently reports:

```
ro.product.model = vegas
ro.carrier = tracfone
gsm.sim.state = ABSENT,NOT_READY
```

Without a non-Tracfone SIM you cannot verify the network unlock or the carrier
registration. The patched image was flashed to this unit's `md1img_a`, but the
`NETWORK_LOCKED → LOADED` check still needs a SIM. See `07-modem-unlock.md`.

## References

- `qfertig/vegas26-gsi` — complete setup, GSI, SIM/modem, APN, VoLTE.
- `parsimo2010/...` — FRP/OEM-unlock/SIM-screen background.
- `andrewwm/vegas-freedom` — tested modem `md1img_a` unlock.
- XDA Walmart-special thread + RomLord Drive — user reports and additional files.
- XDA recovery thread — `vegas_ofox.img` and panel/touch notes.
