# 04 — Troubleshooting

## Getting into recovery

- Power off / bootloader: **Power + Volume Down**.
- In the bootloader menu: **Volume Down → `Recovery mode` → Power**.
- `fastboot reboot recovery` and `adb reboot recovery` are unreliable here; they can boot
  normal Android (`ro.boot.mode=normal`).
- If recovery is a black screen or hangs, hold **Power ~20 s**, then
  **Volume Down + Power** to return to the bootloader.

## Fastboot is empty / hangs

- In bootloader mode the phone is `USB\VID_22B8&PID_2E80`. Windows may show code 28
  until the Motorola/Android Bootloader Interface driver is bound.
- Device Manager → the Android device → Update driver → Browse → pick
  **Android Bootloader Interface** (or **WinUsb Device** from Microsoft).
- Bootloader and **fastbootd are separate USB devices**; bind both.
- Avoid hubs; use a direct port.
- Use platform-tools **37.0.1** or **35.0.0**. 37.0.3 can stall on `flash`.
- If `fastboot devices` shows nothing, fix the driver before issuing any flash.

## Bootloop / stuck on “hello moto”

- A “hello moto” hang (not a glitch loop) usually means the bootloader loaded the image
  but the recovery/userspace died before USB/display takeover.
- Restore stock `vendor_boot` first:
  `fastboot flash vendor_boot_a revert\vendor_boot_a.img` → reboot.
- On Android, read the last boot log:
  ```sh
  su -c 'cat /sys/fs/pstore/console-ramoops-0'
  ```
  Look for `magiskinit: First Stage Init`, `Switching root to '/first_stage_ramdisk'`,
  and `partition(s) not found` (`boot_a`, `super`, `metadata`, `vbmeta_a`,
  `vbmeta_system_a`). That pattern is an init/ueventd/userspace incompatibility, not a
  header/DTB problem.
- A glitch-then-reboot is typically the panel/DSI modules or a kernel/userspace crash.

## TWRP 14.1 builds but does not boot

See `docs/02-recovery.md` Part A. The image and DTB are correct; the TWRP 14.1
userspace does not work with this A16 vendor. Use the OrangeFox recipe instead.

## OrangeFox boots to a log/console with no nav keys

The Nevada-sized theme can open on its console page. Reset the UI settings:

```sh
mv /sdcard/Fox/.foxs /sdcard/Fox/.foxs.bak
sync
reboot recovery
```

Then enter recovery from the bootloader menu. Default main menu returns. The `/sdcard/Fox/BACKUPS`
directory is untouched.

## Touch does not work

- Controller: **Focaltech FT8725** (`/sys/class/touchscreen/primary/productinfo` = `ft8725`).
- The image’s bundled `focaltech_0flash_mmi_v3.ko` (412,600 bytes, MD5 `85263c…`) is the
  wrong variant and fails with `ENODEV`.
- Use the phone’s stock `vendor_dlkm` module (234,560 bytes, MD5 `c0af43…`), baked into
  both `vendor/lib/modules` and `vendor_dlkm/lib/modules` in the recovery ramdisk.
- Quick test in a running recovery with ADB root:
  ```sh
  mount -t erofs -o ro /dev/block/dm-6 /mnt/vdlkm
  rmmod focaltech_0flash_mmi_v3
  insmod /mnt/vdlkm/lib/modules/focaltech_0flash_mmi_v3.ko
  cat /proc/bus/input/devices     # expect fts_ts → event2
  ```
- `getevent -lt /dev/input/event2` should show `ABS_MT_POSITION_X/Y` when you touch.

## Display glitches / black screen

- The recovery ramdisk needs the matching **DSI panel modules**. For this board the
  1080×2388 set is `dsi-panel-mot-vdo-tm-ili77600a-1080-2388-*`,
  `dsi-panel-mot-vdo-txd-ft8725-1080-2388-*`,
  `dsi-panel-mot-vdo-txd-nt36672c-1080-2388-*`.
- Missing panel modules → black screen or corruption (see the XDA thread’s kansas note).

## GSI bootloops after the first boot

That is the `fastboot -w` trap. `fastboot -w` erases `/data`/`metadata` without
formatting them. Use **stock recovery’s factory reset** for the first wipe, then GSIs can
be hot-swapped without wiping.

## No service after the GSI (radio stuck on 3G)

Symptom: the SIM reads fine (`gsm.sim.operator.alpha` populated), but Mobile network says
**No service**, `mServiceState` is `OUT_OF_SERVICE`, there is no serving cell and signal
strength is invalid. It looks like dead RF; it is not.

Cause: the GSI defaults `preferred_network_mode` to `0` (`WCDMA_PREF`), which filters LTE
and NR out of the modem's capabilities. US 3G is shut down, so the radio finds nothing.

```powershell
adb shell settings get global preferred_network_mode   # 0 = 3G preferred
adb shell logcat -b radio -d | Select-String 'setAllowedNetworkTypes'
# filteredRaf without LTE confirms it:
#   modemRaf    = GPRS|UMTS|LTE|GSM|LTE_CA|NR
#   filteredRaf = GPRS|UMTS|GSM
```

Fix: Settings → SIMs → *your SIM* → **Preferred network type → LTE**, or:

```powershell
adb shell settings put global preferred_network_mode 9
adb reboot
```

Expect `filteredRaf = GPRS|UMTS|LTE|GSM|LTE_CA` and registration within a minute.

> `gsm.sim.state` can stay `LOADED,NOT_READY` even when the phone is registered on LTE.
> Check `RegStateResult` in `logcat -b radio` instead.

## `fastboot flash system` says not enough space

In fastbootd:

```sh
fastboot delete-logical-partition product_a
fastboot delete-logical-partition product_b
fastboot flash system <gsi>.img
```

Reversible with `super.img`.

## `fastboot flash init_boot_a` fails

This unit rejects it with `Preflash validation failed`. Patch `init_boot` via Magisk and
write it **from Android** with `dd` (root), not fastboot.

## Restore / revert

- Full dynamic-partition revert: `super.img` in fastbootd.
- Recovery nandroid: restore `system_image`, `vendor_image`, `product_image`,
  `vendor_dlkm_image`, `boot`, `dtbo`, `vbmeta`.
- Stock `vendor_boot`: `revert\vendor_boot_a.img`.
- Always reflash stock `vbmeta`/`vbmeta_system` **without** `--disable-verity` after a
  GSI, then factory reset.

## Recovery ADB has no input/screencap

OrangeFox’s recovery shell is minimal: no `input`, `screencap`, or `wm`. You can read
and write files and load modules, but you cannot drive the UI over ADB. Use touch or the
hardware keys.

## Never

- Relock the bootloader with modified `lk`/`init_boot`.
- Flash another device’s recovery/ROM.
- Flash `md1img_b`, `preloader`, `lk`, `seccfg`, `gpt`, `nvram`, `nvdata`, `protect*`
  for a GSI.
- Publish `nvram`/`nvdata`/`seccfg`/`persist`/`frp`/`md1img` dumps or unlock keys.
