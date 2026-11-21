# Modem SIM/network unlock (`md1img_a`)

Status: **patched `md1img_a` flashed 2026-11-21; SIM/network verification pending**.

This unit:

```
Model        : XT2617V / bootloader product `vegas` / `vegas26`
Carrier      : ro.carrier = tracfone
SIM          : gsm.sim.state = ABSENT,NOT_READY (no SIM inserted)
Build        : W1WEOS36.48-22-3-3-4-3
Modem        : md1img_a (stock backup, 209,715,200 bytes)
```

The network lock is separate from the bootloader unlock. A GSI does not remove it. It is
enforced by the MediaTek modem (`md1img`); IMEI/calibration live in `nvram`/`nvdata`/
`protect*`, not in `md1img`.

## Tool / references

- **`andrewwm/vegas-freedom`** — the tested modem `md1img` unlock scripts:
  <https://github.com/andrewwm/vegas-freedom>
- **`qfertig/vegas26-gsi` Part 3** — the complete SIM/modem guide:
  <https://github.com/qfertig/vegas26-gsi>
- **XDA Walmart-special thread**:
  <https://xdaforums.com/t/moto-g-power-2026-xt2617v-walmart-special-root-modem-unlock-bypass-unlocked-bootloader.4809158/>
- **RomLord14495 Moto Roms Drive** (additional files, referenced by that thread):
  <https://drive.google.com/drive/folders/1WAlJfCoh0CA8jhdGqINo_kgn7r-Dt678>
- Stock firmware mirror: <https://mirrors.lolinet.com/firmware/moto/>

> **Slot warning conflict:** the XDA Drive post says “flash slot b or you’ll brick
> including lk.” That is **not** the `vegas-freedom`/`qfertig` modem path. For this tool,
> flash **`md1img_a` only, never `md1img_b`**. Do not follow the Drive’s slot-b instruction
> for the modem unless the Drive’s own package explicitly documents a different,
> verified procedure for your exact build.

## Offline check/build (already done)

The stock `md1img_a` backup is the one in `private-backups-2026-11-21`:

- stock dump: 209,715,200 bytes; trimmed to 76,088,352 bytes
- trimmed stock SHA-256: `9b0ea2cf00b037753d7956ca66aebb8bb39dfde6a7c2a950336f8afb313d71a8`
- `check`: **CANDIDATE MATCH** — 8/8 CATI + microMIPS32 patterns; audit
  `entries=23 layout_ok=True integrity=True`
- `build --experimental-relocate` on the `-4-3` modem: **audit passed**
  - `work/md1img_experimental_patched.signed.img`
  - 76,088,448 bytes
  - SHA-256 `76880246dd4614443513f41c74c7f218b073c6b0e42e3ce50fd7ff9f38f8b0cc`
- stock trimmed revert:
  - `work/modem_work/md1img_stock_trimmed.img`
  - SHA-256 `9b0ea2cf00b037753d7956ca66aebb8bb39dfde6a7c2a950336f8afb313d71a8`

The tool was pinned to the verified `-4-2` build; this phone is `-4-3`, so the build is
**experimental/untested on hardware**. It matched all 8 signatures and passed the image
audit, but that is not a guarantee.

## Flash (only `md1img_a`)

Bootloader must be unlocked:

```powershell
adb reboot bootloader
fastboot getvar securestate        # expect: flashing_unlocked
fastboot flash md1img_a <work>\md1img_experimental_patched.signed.img
fastboot reboot
```

Never flash `md1img_b`, `preloader`, `lk`, `seccfg`, `gpt`, `efuse`, `nvram`, `nvdata`,
`protect1`, `protect2`, or `persist`.

## Flash performed (2026-11-21)

The patched image was flashed to `md1img_a` only, and the phone booted back into
LineageOS 23.2 microG:

```text
fastboot getvar securestate  -> flashing_unlocked
fastboot flash md1img_a ...  -> OK (74,305 KB)
```

Post-flash checks:

```text
gsm.version.baseband = MT6835O_NR17.RC.MP.V18.6.6.P107.02.309R
gsm.sim.state        = ABSENT,NOT_READY   (no SIM)
vendor.gsm.sim.slot.lock.device.lock.remain.count = 5
```

The network lock cannot be verified until a non-Tracfone SIM is inserted. The stock
trimmed image remains the revert.

## Verify the unlock (needs a non-Tracfone SIM)

There is no way to verify the network unlock without a SIM. The offline build/audit is
done, but the `NETWORK_LOCKED → LOADED` transition requires a non-Tracfone SIM.

Suggested cheap physical SIMs:

- **US Mobile Dark Star (AT&T)** — the carrier tested by `qfertig`; most likely path.
- US Mobile Warp (Verizon) or GSM (T-Mobile)
- Mint Mobile / T-Mobile prepaid
- AT&T prepaid

A physical SIM is fine; no eSIM needed. Expect roughly $10 or a cheap prepaid plan.

Insert the SIM and check:

```powershell
adb shell getprop gsm.sim.state
# LOADED (or LOADED,NOT_READY) = unlocked; NETWORK_LOCKED = still locked
adb shell getprop gsm.sim.operator.alpha
adb shell getprop vendor.gsm.sim.slot.lock.device.lock.remain.count   # expect 5
adb logcat -b radio -b main
```

Then set the carrier APN, toggle airplane mode once, and verify data/SMS. VoLTE needs the
LineageOS 23.2 microG GSI’s `com.mediatek.ims`; check with:

```powershell
adb shell pm list packages | grep mediatek.ims
```

**IMEI caveat:** the XDA report says a new SIM connected to other providers after the
modem unlock, but a **Verizon MVNO refused the IMEI** because Straight Talk had not
released the phone. Network unlock and carrier IMEI activation are separate. An
AT&T/T-Mobile/GSM MVNO is more likely to activate; a Verizon MVNO may still reject the
IMEI. This does not affect Wi-Fi backup use.

## eSIM?

The hardware reports:

```text
ro.vendor.hw.esim = true
ro.vendor.esimid  = 89043051202509096226009887161491
```

But the current LineageOS 23.2 microG GSI has **no euicc/LPA package**:
`pm list packages | grep euicc` is empty and `cmd phone get-eid` is unknown on this
build. The **T-Mobile eSIM app** is therefore unlikely to work on the GSI, and T-Mobile
may reject the Tracfone IMEI just like the Verizon MVNO in the XDA report.

Use a **physical prepaid SIM** for the network-lock test. The stock firmware may expose
the eSIM; the GSI currently does not.

## Revert

```powershell
adb reboot bootloader
fastboot flash md1img_a <work>\md1img_stock_trimmed.img
fastboot reboot
```

The original full `md1img_a.img` backup is also kept. Do not publish `md1img`, IMEI,
`nvram`, `nvdata`, `seccfg`, `persist`, `frp`, or `protect*`.

## Risks / legal

- Modifying the modem can brick the device; keep the stock `md1img_a` and a full backup.
- Use only on a device you own. SIM-unlocking a phone you own is legal in the US
  (Unlocking Consumer Choice and Wireless Competition Act); carrier terms and IMEI
  activation policies still apply.
- Do not modify the IMEI. `vegas-freedom` does not.
- `md1img_a` only; never `md1img_b`/`lk`/`preloader`/`seccfg`/`gpt`/`nvram`/`nvdata`/
  `protect*`/`persist`.
- The `-4-3` build is experimental in this tool; the verified profile is `-4-2`.

## References

- `andrewwm/vegas-freedom` — `check` / `build --experimental-relocate` / `md1img_a`.
- `qfertig/vegas26-gsi` — Part 3 SIM/modem + Part 4 APN/VoLTE.
- XDA Walmart-special thread + RomLord Drive — user reports, extra files, slot warning.
- `parsimo2010/...` — FRP/OEM-unlock background.
