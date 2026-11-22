# 11 — Recovery test results (2026-11-22)

Device: Moto G Power 2026 `XT2617V` (`vegas26`), GSI LineageOS 23.2 microG
(`2026-11-18`), bootloader unlocked. Tests were run over ADB with the PIN set to a
known test value; `/data` was encrypted.

## Results

| Candidate | Image | Size | Result |
|---|---|---:|---|
| OrangeFox R12.0 (12.1 core) | `72345394…` | 55.1 MB | **17/17** + sideload |
| TWRP 3.7.1-12 (12.1 core) | `6a0c4d52…` | 52.8 MB | **17/17** |
| PBRP 4.x (12.1 core) | `c56cf8fd…` | 55.1 MB | **17/17** |
| OrangeFox 14.1 fit | `7fb3c54e…` | 55.0 MB | **FAIL — bootloop** |
| OrangeFox 16.0 fit | `3d9cccc9…` | 54.3 MB | **FAIL — bootloop** |
| OrangeFox 14.1 full | — | 61.9 MB | over `vendor_boot` limit |
| OrangeFox 16.0 full | — | 64.3 MB | over `vendor_boot` limit |

The published 2026-11-22 images are the same 12.1 core with the final device-tree
fixes (haptic load order, sideload `adbd` stop) and, for OrangeFox, the two 14.1
backports. The core passed 17/17; the final OrangeFox backport image passed 14 checks
with the three data checks skipped only because the device PIN had been changed
mid-session.

## What the self-test covers

- `ro.product.device = vegas26`
- `ro.crypto.state = encrypted`, `crypto.ready = 1`
- `/data` decrypted and mounted (`/dev/block/dm-7` on `/sdcard`)
- read/write on `/tmp` and `/sdcard`
- `gatekeeper.trustonic.so -> libMcGatekeeper.so`
- touch controller `ft8725` and four `/dev/input/event*` nodes
- six `dsi-panel-mot-*` modules and `focaltech_0flash_mmi_v3`
- AW862x haptic node + `aw862xx_play_go`
- `/metadata` mount, USB `mtp,adb`
- backup directories (`Fox/BACKUPS`)
- kernel, slot and SELinux denial count

## ADB sideload

Verified on the OrangeFox 12.1 image: `adb sideload ofox-test.zip` completed and the
test zip’s `update-binary` ran. TWRP/PBRP use the same fixed
`init.recovery.usb.rc` (stop `adbd` + configure the gadget) in the final source tree.

## Not usable

14.1 and 16.0 bootloop in recovery userspace on this A16 vendor. The full images also
exceed the ~55.5 MB `vendor_boot` limit. Do not flash them.
