# 00 — Device and stock layout

## Device

| Item | Value |
|---|---|
| Model / SKU | moto g power - 2026 / `XT2617V` |
| Android codename | `vegas26` |
| Bootloader product | `vegas` |
| SoC | MediaTek MT6835 (Dimensity 6300) |
| CPU | 2× Cortex-A76 + 6× Cortex-A55 |
| GPU | Mali-G57 MC2 |
| RAM / storage | 4 GB / 128 GB (as tested) |
| Display | 1080 × 2388, 120 Hz, TXD FT8725 panel, Focaltech in-cell touch |
| Firmware | `W1WEOS36.48-22-3-3-4-3` |
| Android | 16, security patch 2026-06-01 |
| Kernel | `5.15.189-android13-8-00018-g9c82b71884fd-ab14885418` |
| Slot | `_a` |
| Bootloader | unlocked (`flashing_unlocked`) |

The bootloader screen calls the product `vegas`; Android reports `vegas26`.
Do not confuse this with the 2025 G Power (`vegas`, XT2515) or the G Play 2026
(`nevada`) / G 2026 (`utah`).

## Recovery model

This device has **no `recovery` partition**. Recovery lives in **`vendor_boot`**:

- The stock `vendor_boot_a` contains **one `platform` fragment** with the full stock
  recovery ramdisk.
- There is **no `/init` in the stock vendor ramdisk**; init comes from `boot.img`.
- The bootloader is entered with **Power + Volume Down**.
- Recovery is entered from the **bootloader menu**:
  **Volume Down → `Recovery mode` → Power**.
- `fastboot reboot recovery` boots normal Android on this unit (`ro.boot.mode=normal`).
- `fastboot boot` is disabled by Motorola.

## Stock `vendor_boot` geometry (reference)

```
magic          VNDRBOOT
header version 4
page size      4096
header size    2128
kernel addr    0x40000000
ramdisk addr   0x66f00000
tags addr      0x47c80000
dtb addr       0x47c80000
dtb size       183530
dtb SHA-256    50cf268426f0c29c1081decf7e61b39c2f0be3a7d83eb39cfcb84c223934d3c8
cmdline        bootopt=64S3,32N2,64N2 mem.enable_mglru=1 loglevel=4 initcall_debug=0
fragments      1 × platform (30,447,050 bytes)
total size     67,108,864 bytes (64 MiB partition)
```

mkbootimg in the A14/A12 trees rejects the three extra kernel tokens
(`mem.enable_mglru=1 loglevel=4 initcall_debug=0`), so builds normally drop them.
The DTB must remain byte-identical to stock.

## Partition sizes (as read from this unit)

| Partition | Bytes |
|---|---:|
| `super` | 11,475,615,744 |
| `boot_a` / `boot_b` | 67,108,864 each |
| `init_boot_a` / `init_boot_b` | 8,388,608 each |
| `vendor_boot_a` / `vendor_boot_b` | 67,108,864 each |
| `vbmeta_a` | 8,388,608 |
| `vbmeta_system_a` | 8,388,608 |
| `dtbo_a` | 8,388,608 |
| `lk_a` / `lk_b` | 16,777,216 each |
| `md1img_a` | 209,715,200 |
| `nvram` / `nvdata` | 67,108,864 each |
| `persist` | 50,331,648 |
| `frp` | 1,048,576 |
| `misc` | 524,288 |

`super` contains the dynamic partitions: `system`, `system_ext`, `product`,
`vendor`, `vendor_dlkm`, `system_dlkm`.

## Host tooling used

- Windows platform-tools **37.0.1** (`C:\ADB`) and **35.0.0** as fallback.
  Avoid 37.0.3; it can stall on `flash`.
- WSL2 Ubuntu 22.04, 24 GB RAM, for AOSP/TWRP builds and image repacking.
- `mkbootimg` / `lz4` / `cpio` from the TWRP 14.1 host tools for repacks.

## Cautions

- Do not relock the bootloader with modified `lk`/`init_boot`.
- Do not flash another device's recovery/image.
- Keep `nvram`, `nvdata`, `seccfg`, `persist`, `frp`, `protect*`, `md1img` private.
- Do not accept Motorola firmware updates if you rely on this exact `-4-3` setup.
