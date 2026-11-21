# Moto G Power 2026 (XT2617V / `vegas26`) — recovery, backups, GSI

Field notes and reproducible scripts for the **MediaTek MT6835** Moto G Power 2026
(`XT2617V`, Android codename `vegas26`, bootloader product `vegas`).

The goal of this repo is simple: document what **actually boots** on this specific
board, what doesn't, and the exact steps/scripts used, so the next person doesn't
have to repeat 20+ build/flash cycles.

> This is a personal research log, not an official Motorola/TWRP/OrangeFox project.
> Flashing anything is your risk. Keep backups.

## Status (2026-11-21)

| Item | State |
|---|---|
| Stock firmware | `W1WEOS36.48-22-3-3-4-3`, Android 16, patch 2026-06-01 |
| Bootloader | unlocked (`flashing_unlocked`) |
| Root | Magisk 31.1 (`u:r:magisk:s0`) |
| **Working recovery** | **OrangeFox (14.1-based) with touch, `/data` decryption, backup** |
| TWRP 14.1 build | builds and verifies, but its userspace hangs on this A16 vendor (see `docs/02-recovery.md`) |
| GSI | LineageOS 23.2 microG (Android 16) — **working**, Wi-Fi backup; recovery decrypts its `/data` |

## The short version

There is **no official A16 TWRP branch**. The newest public TWRP base is `twrp-14.1`.
What works here is a **complete OrangeFox recovery** built for the same board (same
`183530`-byte DTB, same `1080x2388` panel) with one critical substitution:

**Use the phone's own `vendor_dlkm` Focaltech FT8725 module instead of the recovery
image's bundled module.** The bundled one is built for a different G Play variant and
fails with `ENODEV`; the stock module binds `fts_ts` on `/dev/input/event2`.

Two other gotchas are documented:

1. Recovery must be entered from the **bootloader menu** (`Volume Down` → `Recovery mode`
   → `Power`). `fastboot reboot recovery` boots normal Android on this unit.
2. If OrangeFox boots to the log/console with no nav keys, rename its UI settings file
   (`/sdcard/Fox/.foxs` → `.foxs.bak`) and reboot recovery; the default main menu returns.

And for any GSI: the first `/data` wipe must be a **stock recovery factory reset**, not
`fastboot -w`, or the second boot bootloops on "Can't load Android system".

## Repo layout

```
README.md
REPRODUCE.md           exact working OrangeFox image recipe
docs/
  00-device.md          device, partitions, stock vendor_boot geometry
  01-backups.md         raw partition backups (super, boot, vbmeta, ...)
  02-recovery.md        TWRP 14.1 build notes + OrangeFox working recipe
  03-gsi.md             LineageOS 23.2 microG GSI plan
  04-troubleshooting.md bootloop/hello moto, touch/display, fastboot, recovery entry
scripts/                the actual build/repack/verify/backup scripts
artifacts/SHA256SUMS.txt hashes of images built during this work
CREDITS.md
```

Nothing device-unique is published: no serial numbers, unlock keys, IMEI, `nvram`,
`nvdata`, `seccfg`, `persist`, `frp`, or `md1img` contents.

## Read this before flashing

- **Never relock the bootloader** with a modified LK/init_boot.
- **Never flash another device's image** (Nevada/Utah/Kansas/TWRP images are different
  boards). The only image that booted here is the `vegas` OrangeFox + your stock touch
  module.
- Use **platform-tools 35.0.0 or 37.0.1**. `37.0.3` can stall on `flash`.
- Keep `private-backups` private. `nvram`, `nvdata`, `seccfg`, `persist`, `frp`,
  `protect*`, `md1img` contain device-unique calibration/security data.
- Back up **before** any `system`/`data` change. A full raw `super.img` is the cleanest
  revert for GSI experiments.

## Credits

See `CREDITS.md`. The working recovery path stands on the XDA `TWRP/OrangeFox` thread,
`crabcakes97`/`evoxdl` device work, and `qfertig/vegas26-gsi` for the GSI + VoLTE notes.
