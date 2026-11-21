# Reproduce the working OrangeFox image

This is the exact path that produced a recovery with working touch, `/data` decryption,
backup/restore, MTP and ADB on `XT2617V` (`vegas26`).

## Inputs

1. **Base image:** `vegas_ofox.img` from the XDA thread
   [TWRP/OrangeFox — Moto G Play/Moto G (2026)](https://xdaforums.com/t/recovery-twrp-orangefox-moto-g-play-moto-g-2026.4799348/).
   It is an OrangeFox R12.0 unofficial image built for the same board: DTB `183530` /
   SHA-256 `50cf2684…34d3c8`, 1080×2388 panel modules. Despite reporting
   `ro.product.device = nevada`, it carries the vegas26 DTB and panel set.

2. **The phone’s own touch module** from `vendor_dlkm`
   (`focaltech_0flash_mmi_v3.ko`, 234,560 bytes, MD5 `c0af43…`,
   SHA-256 `587ab792…`). The image’s bundled module (412,600 bytes, MD5 `85263c…`) is
   the wrong variant and fails with `ENODEV`.

## Steps

### 1. Pull the stock touch module

From Android with Magisk root:

```powershell
adb push scripts/extract-stock-touch-module.sh /data/local/tmp/
adb shell su -c 'sh /data/local/tmp/extract-stock-touch-module.sh'
adb pull /data/local/tmp/stock_focaltech.ko .
```

The script tries the mounted `/vendor_dlkm` first; if it is not mounted, it mounts the
mapped `vendor_dlkm` (`/dev/block/dm-6`, erofs) read-only and copies the module.

### 2. Extract the base image

```bash
python3 scripts/extract_frags.py vegas_ofox.img /tmp/ofox
# /tmp/ofox/frags/recovery_ramdisk.lz4 is the OrangeFox recovery fragment
```

Decompress and extract the recovery ramdisk:

```bash
mkdir -p /tmp/ofox/rec
cd /tmp/ofox/rec
lz4 -d ../frags/recovery_ramdisk.lz4 rec.cpio
cpio -idm --no-absolute-filenames < rec.cpio
rm -f rec.cpio
```

### 3. Replace the touch module

```bash
cp stock_focaltech.ko vendor/lib/modules/focaltech_0flash_mmi_v3.ko
cp stock_focaltech.ko vendor_dlkm/lib/modules/focaltech_0flash_mmi_v3.ko
chmod 644 vendor/lib/modules/focaltech_0flash_mmi_v3.ko \
           vendor_dlkm/lib/modules/focaltech_0flash_mmi_v3.ko
```

### 4. Repack and verify

Use `scripts/60-repack-ofox-touch.sh` (edit the `<you>` paths). It:

- repacks the recovery ramdisk with `cpio -o -H newc` and `lz4 -l -12`,
- rebuilds the **same two-fragment** vendor_boot with mkbootimg
  (`platform` + `recovery`/`recovery`),
- pads to 67,108,864 bytes and verifies the header/DTB/fragments.

Expected result:

```
SHA-256  ddcc59675552d31d5069925507312aa9128ce12911fff2980088eb664cd445d0
size     67,108,864
fragments 2
```

### 5. Flash

```powershell
fastboot flash vendor_boot_a vegas_ofox_fixed.img
```

Enter recovery from the **bootloader menu**:

**Volume Down → `Recovery mode` → Power**

### 6. If the UI is only a log with no nav keys

The Nevada-sized OrangeFox theme can open its console page on the 1080×2388 panel.
Reset the UI settings:

```sh
mv /sdcard/Fox/.foxs /sdcard/Fox/.foxs.bak
sync
reboot recovery
```

The default main menu returns. Your `/sdcard/Fox/BACKUPS` data is untouched.

## What works after this

- Touch (Focaltech FT8725, `fts_ts` on `/dev/input/event2`)
- `/data` decryption
- Backup/restore
- MTP / ADB / sideload
- The recovery is OrangeFox (TWRP-based), not TWRP-branded.

## Revert

```powershell
fastboot flash vendor_boot_a revert\vendor_boot_a.img
```

Keep the stock `vendor_boot` image separately; the “current” `vendor_boot_a` is the
custom recovery once you flash this.
