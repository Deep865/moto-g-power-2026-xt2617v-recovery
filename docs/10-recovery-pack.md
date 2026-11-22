# 10 — Recovery pack (one-file download)

For users who just want everything in one place:

**`Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip`**

- Size: 256 MB
- SHA-256: `0f16d6ed960e10470e18d98c2c7c8b95c0c66afaca055c6e25711b6e18f9a8c9`
- Download: [release assets](https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-unlock-degoogle-guide/releases/tag/2026-11-22)

## Contents

| File | Purpose |
|---|---|
| `OrangeFox-R12.0-vegas26.img` | OrangeFox 12.1, most features; sideload verified |
| `TWRP-3.7.1-12-vegas26.img` | plain TWRP 12.1 |
| `PBRP-4.x-vegas26.img` | PBRP 4.x 12.1 |
| `stock-vendor_boot_a.img` | stock revert for `vendor_boot_a` |
| `README.txt` | quick flash/revert instructions |
| `SHA256SUMS.txt` | hashes of the four images |

All three recoveries are `vendor_boot` images for slot A. They share the same device
tree and fixes (FT8725 touch, FBE decrypt, backups, MTP/ADB, haptics, six panels).

Want the GSI and docs in the same download? Use the
[flash kit](12-flash-kit.md) instead.

## Flash

```powershell
fastboot flash vendor_boot_a OrangeFox-R12.0-vegas26.img
```

Then **bootloader menu → Volume Down → Recovery mode → Power**. `fastboot reboot
recovery` boots Android on this unit.

## Revert

```powershell
fastboot flash vendor_boot_a stock-vendor_boot_a.img
```

## Caveats

- No `/cache` partition; Dalvik/ART only.
- OrangeFox 14.1/16.0 do not work here (bootloop / size limit).
- ADB sideload verified on OrangeFox 12.1.
- Never relock the bootloader with modified images.
