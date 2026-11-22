# 02 — Recovery: TWRP 14.1 build notes + working OrangeFox recipe

Two separate things are documented here:

1. A from-source **TWRP 14.1** build — it compiles, passes every header/DTB check, and
   flashes, but its userspace does not reach a usable UI on this Android 16 vendor.
2. A **working OrangeFox** recovery built from a device-specific image plus one critical
   substitution: the phone's own `vendor_dlkm` Focaltech FT8725 module.

## Part A — TWRP 14.1 from source

### Tree and manifest

```bash
repo init --depth=1 \
  -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git \
  -b twrp-14.1
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags
# device tree:
cp -r device-tree device/motorola/vegas26   # or git clone your tree

source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_vegas26-ap2a-eng
mka vendorbootimage -j16
```

On a 16 GB host, Soong's analysis phase OOMs. This was built on a 32 GB Ryzen host in
WSL2 Ubuntu 22.04 (24 GB to WSL, 16 jobs). The A14 tree also needs the 32-bit ARM half
removed to shrink the module graph unless you have a lot of RAM.

### AOSP 14 fixes required by the tree

The device tree is written for an older TWRP branch; A14 needs:

| Problem | Fix |
|---|---|
| `envsetup.sh: TOP: unbound variable` | do not run with `set -u`; use `set -eo pipefail` |
| CTS rejects `PLATFORM_VERSION := 16` | append `16` to `cts/tests/tests/os/assets/platform_releases.txt` and `platform_versions.txt` |
| `-ndk_platform` AIDL module names gone | `sed -i 's/-ndk_platform/-ndk/g'` in `bootable/recovery/Android.mk` and `libtar/Android.mk` |
| `libtar` calls fscrypt helpers that no longer exist in A14 `vold` | set `TW_INCLUDE_CRYPTO_FBE := false` in `bootable/recovery/Android.mk` (libtar only; main recovery keeps FBE) |
| `cryptfs_check_passwd`, `cryptfs_get_password_type`, `cryptfs_check_footer`, `set_partition_data`, `delete_crypto_blk_dev` removed | stub/neutralize the FDE-only call sites (device is FBE-only) |
| `fscrypt_policy` is a macro to `fscrypt_policy_v1` in C++ | `struct fscrypt_policy *fep;` in `libtar/libtar.h` |
| bootctrl HAL missing `android::base` symbols | add `libbase` to `device/motorola/vegas26/bootctrl/Android.bp` |
| recovery link missing `crypto_scrypt` | add `libscrypt_static` to recovery static libs |

Everything is automated in `scripts/10-build-14.1.sh` / `scripts/11-rebuild.sh`.

### Output and repack

The A14 build emits a **type-2 `recovery` fragment** plus a small `platform` fragment.
This bootloader uses the `platform` fragment, so the recovery ramdisk was repacked as a
single platform fragment:

```bash
python3 scripts/extract_frags.py out/.../vendor_boot.img /tmp/frags
mkbootimg --header_version 4 --pagesize 4096 --board "" --base 0x3fff8000 \
  --kernel_offset 0x00008000 --ramdisk_offset 0x26f08000 \
  --tags_offset 0x07c88000 --dtb_offset 0x07c88000 \
  --dtb device/motorola/vegas26/prebuilt/dtb.img \
  --vendor_cmdline "bootopt=64S3,32N2,64N2" \
  --vendor_ramdisk /tmp/frags/recovery_ramdisk.lz4 \
  --vendor_boot vendor_boot_platform.img
```

Result: `vendor_boot_14_platform.img`, 67,108,864 bytes, single platform fragment,
DTB byte-identical to stock. Verification passes (`scripts/verify_built.py`).

### Outcome

The image flashes and the bootloader accepts it, but TWRP does not reach a usable UI:
the tested unit showed a glitch/reboot or hung at the Motorola logo. pstore showed the
TWRP `init`/`ueventd` stage failing to create the MTK block devices
(`boot_a`, `super`, `metadata`, `vbmeta_a`, `vbmeta_system_a`), i.e. the A14 recovery
userspace is not compatible with this A16 vendor.

A hybrid (stock A16 vendor ramdisk + TWRP 14.1 `recovery` binary + its unique libs)
also hung at the logo. The packaging, DTB and header were proven correct; the blocker is
the TWRP 14.1 userspace, not the image format.

Use the OrangeFox path below for a working recovery.

## Part B — Working OrangeFox (14.1-based)

> The label is historical: the working image is **R12.0**, built from the 12.1 branch.
> It is now reproducible from source; see `docs/08-source-build.md`.

### Source image

From the XDA thread **“TWRP/OrangeFox — Moto G Play/Moto G (2026)”**:
`vegas_ofox.img` (OrangeFox R12.0 unofficial, 64 MB, `ro.product.device = nevada`).
Despite the Nevada name, this image carries the **vegas26 DTB** and **1080×2388 panel
modules**, matching this board:

- DTB size `183530`, SHA-256 `50cf2684…34d3c8` — identical to stock.
- Panel modules: `dsi-panel-mot-vdo-tm-ili77600a-1080-2388-*`,
  `dsi-panel-mot-vdo-txd-ft8725-1080-2388-*`,
  `dsi-panel-mot-vdo-txd-nt36672c-1080-2388-*`.
- Header: VNDRBOOT v4, page 4096, kernel `0x40000000`, ramdisk `0x66f00000`,
  two fragments (platform 2,689,123 + recovery 52,741,246).

### The touch fix (the important part)

The image's bundled touch modules are for a different G Play variant:

| Module | Size | MD5 | Result |
|---|---:|---|---|
| Image's `focaltech_0flash_mmi_v3.ko` | 412,600 | `85263c33f1b186dd5db8332b358eebea` | `insmod: No such device` (ENODEV); no input device |
| Stock `vendor_dlkm` `focaltech_0flash_mmi_v3.ko` | 234,560 | `c0af43bf421e19a4538cd716ad6bb8e1` | binds `fts_ts` on `/dev/input/event2` |

The touch controller is **Focaltech FT8725** (`/sys/class/touchscreen/primary/productinfo`
= `ft8725`). The stock module is the one built for this kernel/DTB.

Repack:

1. Mount the real `vendor_dlkm` (already mapped as `/dev/block/dm-6` in OrangeFox):
   `mount -t erofs -o ro /dev/block/dm-6 /mnt/vdlkm`
2. Pull `focaltech_0flash_mmi_v3.ko` from `/mnt/vdlkm/lib/modules/`.
3. Replace both copies in the OrangeFox ramdisk:
   `vendor/lib/modules/focaltech_0flash_mmi_v3.ko` and
   `vendor_dlkm/lib/modules/focaltech_0flash_mmi_v3.ko`.
4. Repack the recovery ramdisk (`find . | cpio -o -H newc | lz4 -l -12`) and rebuild the
   two-fragment vendor_boot with mkbootimg:
   ```bash
   mkbootimg --header_version 4 --pagesize 4096 --board "" --base 0x3fff8000 \
     --kernel_offset 0x00008000 --ramdisk_offset 0x26f08000 \
     --tags_offset 0x07c88000 --dtb_offset 0x07c88000 \
     --dtb device/motorola/vegas26/prebuilt/dtb.img \
     --vendor_cmdline "bootopt=64S3,32N2,64N2" \
     --vendor_ramdisk platform.lz4 \
     --ramdisk_type recovery --ramdisk_name recovery \
     --vendor_ramdisk_fragment recovery.lz4 \
     --vendor_boot vegas_ofox_fixed.img
   ```
5. Pad to 67,108,864 and verify.

Result: **`vegas_ofox_fixed.img`**
SHA-256 `ddcc59675552d31d5069925507312aa9128ce12911fff2980088eb664cd445d0`.

Working: touch, `/data` decryption, backup/restore, MTP, ADB.

### If OrangeFox shows only a log with no buttons

The Nevada-sized theme can land on its console page on the 1080×2388 panel. Reset the
UI settings and reboot recovery:

```sh
mv /sdcard/Fox/.foxs /sdcard/Fox/.foxs.bak
sync
reboot recovery   # or bootloader → Recovery mode
```

The default main menu returns. OrangeFox may still have minor density quirks (the XDA
author notes a cut-off settings item), but it is usable.

### Revert

```powershell
fastboot flash vendor_boot_a revert\vendor_boot_a.img
```

Stock `vendor_boot` is single-platform, has stock recovery, and is the known-good revert.
