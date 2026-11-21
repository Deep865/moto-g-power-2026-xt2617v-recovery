# 01 — Backups (raw images)

A recovery/nandroid backup is convenient, but for GSI work the **raw partition images**
are the reliable revert. `super.img` restores `system`, `system_ext`, `product`,
`vendor`, `vendor_dlkm`, and `system_dlkm` in one shot.

## What to back up

Minimum set for a GSI experiment:

```
super            (10.7 GiB)  ← stock system/vendor/product
vbmeta_a
vbmeta_system_a
boot_a
init_boot_a      (Magisk-patched if rooted)
vendor_boot_a    (current recovery image; keep stock separately)
dtbo_a
misc
frp
md1img_a         (modem; SIM unlock revert)
```

Full safety set (used here):

```
super boot_a init_boot_a vendor_boot_a vbmeta_a vbmeta_system_a dtbo_a misc
lk_a lk_b md1img_a nvram nvdata seccfg persist prodpersist proinfo
protect1 protect2 frp preloader_raw_a boot_b init_boot_b vendor_boot_b
```

Sizes and exact names are in `docs/00-device.md`.

> `nvram`, `nvdata`, `seccfg`, `persist`, `frp`, `protect*`, `md1img` are
> device-unique calibration/security data. Keep them private; never publish them.

## Make them (root required)

Use the script `scripts/backup-dd.sh` or do it manually:

```sh
D=/data/local/tmp/backup-$(date +%Y%m%d)
mkdir -p "$D"
for p in super boot_a init_boot_a vendor_boot_a vbmeta_a vbmeta_system_a \
         dtbo_a misc lk_a lk_b md1img_a nvram nvdata seccfg persist \
         prodpersist proinfo protect1 protect2 frp preloader_raw_a \
         boot_b init_boot_b vendor_boot_b; do
  dd if=/dev/block/by-name/$p of="$D/$p.img" bs=4M
  sha256sum "$D/$p.img" >> "$D/SHA256SUMS.txt"
done
sync
```

Pull, then verify on the PC:

```powershell
adb pull /data/local/tmp/backup-YYYYMMDD C:\path\to\private-backups
# compare every SHA-256 in SHA256SUMS.txt against the pulled files
```

Delete the phone-side copy only after the PC hashes match.

## Restore

- `boot` / `init_boot` / `vendor_boot` / `dtbo` / `vbmeta`:
  `fastboot flash <partition> <image>` from the bootloader (or `init_boot` from Android
  via `dd`, because this unit rejects `fastboot flash init_boot_a` with
  `Preflash validation failed`).
- `super`: from **fastbootd**:
  `fastboot flash super super.img`.
  This is the cleanest GSI revert. If the bootloader refuses, restore the logical
  partitions individually from an OrangeFox/TWRP nandroid
  (`system_image`, `vendor_image`, `product_image`, `vendor_dlkm_image`).
- After restoring a stock `system`/`super`, reflash stock
  `vbmeta`/`vbmeta_system` **without** the `--disable-verity --disable-verification`
  flags, then do a recovery factory reset.

## Practical notes

- `dd` while Android is running produced consistent images here; the device was not
  writing to the partitions during the copy.
- `super.img` is ~11 GB; the phone had ~95 GB free on `/data`, so a temporary copy fits.
- Keep a copy of the stock `vendor_boot_a` separately (`revert/vendor_boot_a.img`) — the
  "current" `vendor_boot_a` may be a custom recovery by the time you need the stock one.
- A full OrangeFox nandroid (`Boot`, `System Image`, `Vendor Image`, `Product Image`,
  `Vendor Dlkm Image`, `Dtbo`, `Vbmeta`, optional `Data`) is a good convenience backup,
  but `super.img` remains the authoritative GSI revert.
