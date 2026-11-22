# 03 — LineageOS 23.2 microG GSI (Android 16)

This is the practical custom-OS path for `vegas26`. It is a **GSI flashed to `system`**
(the stock `vendor` stays), not a device-specific ROM. It was verified end-to-end on the
same `-4-3` build by `qfertig/vegas26-gsi`, including mobile data, SMS and VoLTE.

> Status: **flashed and booted on 2026-11-21.** Android 16,
> LineageOS 23.2-20261118-UNOFFICIAL-GSI, `/data` encrypted. The tested OrangeFox 12.1,
> TWRP 12.1 and PBRP 12.1 recoveries boot, decrypt the GSI's `/data`, and touch works.
> This unit is used as a Wi-Fi backup phone (no SIM). The GSI does **not**
> SIM/network-unlock the modem.
> Follow the order exactly — the `/data` wipe method is the difference between a working
> install and a permanent bootloop.

## Image

`LineageOS-23.2-2026.11.18-microG-gsi.img`

| | |
|---|---|
| Source | `https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/` |
| Compressed | 1,089,012,932 bytes (`.img.xz`) |
| MD5 (`.xz`) | `4cc3fcba0ffa031c60909d129683e642` |
| Decompressed | 2.9 GB |
| SHA-256 (`.img`) | `dcefcb1920cd538a80d4a0120996278f0a8a33aacb7c0ee429c50e61f1818345` |

Pick the **arm64 A/B, ext4, regular** build (not `vndklite`). Device readiness:
`ro.treble.enabled=true`, `ro.virtual_ab.enabled=true`, `ro.product.cpu.abi=arm64-v8a`,
`ro.vndk.version=33`.

LineageOS microG is used because it ships `com.mediatek.ims`; other GSIs without it will
not do VoLTE on this MediaTek modem.

## Before flashing

- Verified raw backups: `super.img`, `vbmeta_a.img`, `vbmeta_system_a.img`, `boot_a.img`,
  `init_boot_a.img`, `dtbo_a.img`, `md1img_a.img`, `frp.img` (see `docs/01-backups.md`).
- Stock `vendor_boot_a.img` (for the stock recovery wipe).
- Platform-tools 37.0.1 or 35.0.0.
- Phone charged; direct USB port.

## Flash sequence

### 1. Disable verification (from the bootloader)

```powershell
fastboot --disable-verity --disable-verification flash vbmeta        vbmeta_a.img
fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system_a.img
```

Do this from the **bootloader**, not fastbootd; fastbootd cannot see vbmeta on this unit.

### 2. Flash the GSI to `system` in fastbootd

```powershell
fastboot reboot fastboot
fastboot devices -l
fastboot flash system LineageOS-23.2-2026.11.18-microG-gsi.img
```

If it reports **not enough space**, in fastbootd:

```powershell
fastboot delete-logical-partition product_a
fastboot delete-logical-partition product_b
fastboot flash system LineageOS-23.2-2026.11.18-microG-gsi.img
```

This is reversible with `super.img`.

### 3. The critical `/data` wipe

`fastboot -w` **erases but does not format** `/data`/`metadata`. The first boot creates a
wrapped key on raw space, and the second boot cannot re-derive it → “Can't load Android
system” loop.

Use **stock recovery’s factory reset**:

```powershell
fastboot flash vendor_boot_a revert\vendor_boot_a.img
fastboot reboot
```

Then either:

- let it fail with **“Can't load Android system”** and tap **Factory reset**, or
- bootloader → **Recovery mode** → “No command” → hold **Power**, tap **Volume Up** once
  → **Wipe data/factory reset**.

First clean boot: 5–10 minutes.

### 4. After boot

- Setup; verify Android 16 and data/SMS.
- APN: select the carrier APN (Tracfone AT&T / `ereseller` for US Mobile Dark Star).
  Toggle airplane mode once if data is slow to attach.
- VoLTE: LineageOS 23.2 microG includes `com.mediatek.ims`; verify a real call with
  `adb logcat -b radio -b main` (`useImsForCall=true`, `qci:1`).
- Optional: reflash the working 12.1 recovery of your choice (OrangeFox, TWRP or
  PBRP); all three booted normal Android with this image. See
  `docs/09-recovery-choices.md`.

## SIM / network unlock (optional)

Only needed if `gsm.sim.state = NETWORK_LOCKED`. The `vegas-freedom` tool patches
`md1img`; flash **`md1img_a` only** and keep the stock image as revert. Do not touch
`md1img_b`, `preloader`, `lk`, `seccfg`, `gpt`, `nvram`, `nvdata`, `protect*`.
Legal on a device you own; never publish the modem dump or IMEI.

## Revert to stock

1. Bootloader:
   ```powershell
   fastboot flash vbmeta        vbmeta_a.img
   fastboot flash vbmeta_system vbmeta_system_a.img
   ```
2. fastbootd:
   ```powershell
   fastboot reboot fastboot
   fastboot flash super super.img
   ```
3. Stock vendor_boot:
   ```powershell
   fastboot flash vendor_boot_a revert\vendor_boot_a.img
   ```
4. Recovery → factory reset → reboot.

## Updates

Once `/data` has been formatted once by stock recovery, a newer GSI can be flashed to
`system` and the phone rebooted without wiping. `/data`, `/product` overlays and the
modem stay. GSIs have no OTA; reflash is the update.

## Reference

`qfertig/vegas26-gsi` — the original tested guide, including the layer model, APN/VoLTE
details, optional camera/cutout overlays, and troubleshooting.
