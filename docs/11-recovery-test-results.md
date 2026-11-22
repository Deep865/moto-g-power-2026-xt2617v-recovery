# 11 — Recovery test results (2026-11-22)

Device: Moto G Power 2026 `XT2617V` (`vegas26`), GSI LineageOS 23.2 microG
(`2026-11-18`), bootloader unlocked. Tests were run over ADB with the PIN set to a
known test value; `/data` was encrypted.

## Results

| Candidate | Image | Size | Result |
|---|---|---:|---|
| **OrangeFox R12.0** (12.1 core `8cd9df2b4`) | `873b5614…` | 55.2 MB | **17/17** + sideload |
| **TWRP 3.7.1-12** | `0a241558…` | 52.8 MB | **17/17** |
| **PBRP 4.x** | `c899f61e…` | 54.9 MB | **17/17** |
| OrangeFox 14.1 fit | `7fb3c54e…` | 55.0 MB | **FAIL — bootloop** |
| OrangeFox 16.0 fit | `3d9cccc9…` | 54.3 MB | **FAIL — bootloop** |
| OrangeFox 14.1 full | — | 61.9 MB | over `vendor_boot` limit |
| OrangeFox 16.0 full | — | 64.3 MB | over `vendor_boot` limit |

The three published images were re-tested on 2026-11-22 with the PIN set to 1234:
**17/17 each** (UI, touch, FBE decrypt, backups, haptics, MTP/ADB, six panels).

## Newer OrangeFox 12.1 core

The OrangeFox image was rebuilt on the newer `fox_12.1` core `8cd9df2b4`:
skip-data-size-scan and alternate block paths (the former hand backports), thermal
unsigned-wrap fix, bzip2, configurable vibration defaults, Reboot Recovery after
actions and double-tap-to-wake. It passed **17/17 + ADB sideload** on 2026-11-22.

The final image also hides the CPU temperature (recovery kernel returns `EINVAL` for
the CPU thermal zones) and removes the CPU part of the lock-screen line, leaving
battery only. Double-tap-to-wake was confirmed on hardware: single tap did not wake,
double tap woke, and 17/17 still passed.

Verified in the running recovery:

- `ro.build.fox_codebase = 2026-11-18 (8cd9df2b4)`
- `/system/bin/bzip2` present (93,104 bytes)
- haptic defaults `tw_button_vibrate=40`, `tw_action_vibrate=160`
- `vendor_boot` content 55,162,250 bytes, under the bootloader limit
- `/sdcard/ofox_test_zip_ok.txt` written after `adb sideload ofox-test.zip`

Raw self-test report (serial redacted):
[`artifacts/2026-11-22-ofox-backports-selftest.txt`](../artifacts/2026-11-22-ofox-backports-selftest.txt).

## Bundled root APKs (2026-11-22)

Installed from `tools/apk/` on the running GSI:

- DFRoot 4.7 (`versionCode 407`) — installed, launched, `LAUNCH ROOT` reached
  KernelSU **Working [Jailbreak mode]** (`32680-5`).
- KernelSU v3.3.1 (`versionCode 32680`) — installed and launched; it reports
  “Not installed” while Magisk is the active root, which is expected.
- Magisk 31.1 (`versionCode 31100`) — installed; persistent root remains
  `u:r:magisk:s0` after reboot.

After the DFRoot test the phone was rebooted; the temporary KernelSU jailbreak
session ended and Magisk root returned. These are the unmodified upstream APKs;
their SHA-256 values match the official release digests. The DFRoot exploit is
still stock-firmware-specific, but the APK/UI/root path works on this test unit.

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
