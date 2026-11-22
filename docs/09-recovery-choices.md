# 09 — Which recovery should I use?

Three recoveries now work on this phone (`XT2617V`, `vegas26`). They are built from the
same **12.1** core and the same device tree, so **touch, FBE `/data` decryption,
backup/restore, MTP/ADB and haptics work on all three**. Pick by UI and preference.

| Recovery | Why pick it | Approx. size |
|---|---|---:|
| **OrangeFox R12.0** | Most features; MTK/Trustonic-friendly; theme; `fox` CLI; ADB sideload verified | 55.1 MB |
| **TWRP 3.7.1-12** | Plain TWRP; the UI most people already know; smallest | 52.8 MB |
| **PBRP 4.x** | TWRP-based with a different, more colourful UI | 55.1 MB |

All three are **`vendor_boot` images for slot A**. They are not full ROMs; flash one to
`vendor_boot_a` only.

## What all three do

- Focaltech FT8725 touch (`fts_ts` on `/dev/input/event2`)
- FBE `/data` decryption with your PIN
- Backup/restore to `/sdcard` (`Fox/BACKUPS` or `TWRP/BACKUPS`)
- MTP and ADB
- Haptics (AW862x loaded at boot after `regulator-vibrator`)
- Six 1080×2388 panel modules

## What they don’t

- **OrangeFox 14.1 and 16.0** are not usable on this phone: both bootloop in recovery
  userspace, and their full images exceed the ~55.5 MB `vendor_boot` limit. Do not flash
  a 14.1/16.0 build expecting a UI.
- **ADB sideload** is verified on the OrangeFox 12.1 image. TWRP/PBRP use the same fixed
  `init.recovery.usb.rc` in the final source tree; verify it on your build.
- There is **no `/cache` partition** (A/B + dynamic partitions). Only Dalvik/ART is
  available under Wipe → Advanced.

## Flash

```powershell
fastboot flash vendor_boot_a <recovery>.img
```

Then enter recovery from the **bootloader menu**:

**Volume Down → Recovery mode → Power**

Do not use `fastboot reboot recovery`; on this unit it boots normal Android.

## Revert

Keep your stock `vendor_boot` image and flash it back to `vendor_boot_a`.

## Source

All three build from one device tree:
`Deep865/moto-g-power-2026-xt2617v-recovery-source`

- `scripts/91-build-ofox12-recovery.sh` — OrangeFox 12.1 (+ 14.1 backports)
- `scripts/92-build-twrp12.sh` — TWRP 12.1
- `scripts/93-build-pbrp12.sh` — PBRP 12.1

See `docs/08-source-build.md` for the UPX/CRLF/symlink/fstab traps and the backports.

## One-file pack

Prefer a single download? `Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip`
contains all three images, the stock `vendor_boot_a` revert, a README and checksums.
See `docs/10-recovery-pack.md`.
