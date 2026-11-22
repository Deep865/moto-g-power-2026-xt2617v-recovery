# 12 — Flash kit (one download)

**`Moto-G-Power-2026-XT2617V-flash-kit-2026-11-22.zip`**

One download for a Walmart / Straight Talk `XT2617V` (`vegas26`). It contains the
three tested recoveries, the stock `vendor_boot_a` revert, the tested LineageOS 23.2
microG GSI, this documentation and the modem tool. It deliberately contains **no**
device-unique images.

- Download: [release assets](https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery/releases/tag/2026-11-22)
- SHA-256: `56675951a6f7fe1285b279a4ec420d95e2cebcaf9e08e64273480397a1cd80a8`
- Size: 1,358,190,716 bytes (~1.36 GB); the GSI alone is 1.09 GB compressed.

## Contents

```
README-FIRST.txt
WALKTHROUGH.md
recovery/
  OrangeFox-R12.0-vegas26.img
  TWRP-3.7.1-12-vegas26.img
  PBRP-4.x-vegas26.img
  stock-vendor_boot_a.img
  README.txt
gsi/
  LineageOS-23.2-2026.11.18-microG-gsi.img.xz
  SHA256SUMS.txt
modem/
  README.txt
  vegas-freedom/            # AGPL-3.0 tool and licence; patches YOUR stock md1img
docs/
  00-device.md … 13-backport-roadmap.md
tools/
  recovery-selftest.sh
  extract_frags.py
  verify_built.py
  backup-dd.sh
SHA256SUMS.txt
```

## What is not inside

- `md1img` / modem dumps — device-unique; the kit includes the tool and instructions,
  not our image.
- `nvram`, `nvdata`, `seccfg`, `persist`, `frp`, `protect*`, `super.img`.
- IMEI, serial numbers, unlock keys or eSIM IDs.
- Stock `boot_a` / `init_boot_a` / `vbmeta` images. Use your own backups; the
  walkthrough explains the commands. This is intentional: back up **your** device
  before changing it.

## Use it

1. Read `README-FIRST.txt` and `WALKTHROUGH.md`.
2. Back up your own partitions first (`docs/01-backups.md`).
3. Pick a recovery from `recovery/`.
4. Flash only to `vendor_boot_a`, then enter recovery from the bootloader menu.
5. For the GSI, follow `WALKTHROUGH.md` section 7 exactly; the first `/data` wipe must
   be stock recovery's factory reset.

The recovery-only download is
`Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip` (256 MB) if you already have
the GSI.

## Verify

```powershell
Get-FileHash .\Moto-G-Power-2026-XT2617V-flash-kit-2026-11-22.zip -Algorithm SHA256
```

Compare with the release notes / `SHA256SUMS-2026-11-22.txt`. Inside the kit,
`SHA256SUMS.txt` covers the images and GSI.

## Rebuild the kit

The kit is assembled from the release assets and the public docs, not built by the
recovery source. Keep the same layout and run a hash over every large file. Never add
a modem/`md1img` dump or a device-unique backup.
