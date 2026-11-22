# Moto G Power 2026 (XT2617V, Walmart / Straight Talk) — recovery, backups, GSI

Field notes and reproducible scripts for the **MediaTek MT6835** Moto G Power 2026
(`XT2617V`, Android codename `vegas26`, bootloader product `vegas`).

The goal of this repo is simple: document what **actually boots** on this specific
board, what doesn't, and the exact steps/scripts used, so the next person doesn't
have to repeat 20+ build/flash cycles.

> This is a personal research log, not an official Motorola/TWRP/OrangeFox project.
> Flashing anything is your risk. Keep backups.

## Status (2026-11-22)

| Item | State |
|---|---|
| Stock firmware | `W1WEOS36.48-22-3-3-4-3`, Android 16, patch 2026-06-01 |
| Bootloader | unlocked (`flashing_unlocked`) |
| Root | Magisk 31.1 (`u:r:magisk:s0`) |
| **Working recoveries** | **OrangeFox R12.0**, **TWRP 3.7.1-12** and **PBRP 4.x** — all on the 12.1 core; touch, `/data` decrypt, backup, haptics, MTP/ADB |
| **Pick one** | `docs/09-recovery-choices.md` — OrangeFox (features), TWRP (plain), PBRP (different UI); all three flash the same way |
| **Source** | `Deep865/moto-g-power-2026-xt2617v-recovery-source` — one device tree, three build scripts |
| 14.1 / 16.0 source | **not usable here**: both bootloop; the full images also exceed the ~55.5 MB `vendor_boot` limit |
| GSI | LineageOS 23.2 microG (Android 16) — **working**, Wi-Fi backup; recovery decrypts its `/data` |
| SIM / modem | no SIM (`ABSENT,NOT_READY`); modem unlock image built offline, not flashed — see `docs/07-modem-unlock.md` |

## Download

[Release assets](https://github.com/Deep865/moto-g-power-2026-xt2617v-recovery/releases/tag/2026-11-21)
— `OrangeFox-R12.0-vegas26.img`, `TWRP-3.7.1-12-vegas26.img`,
`PBRP-4.x-vegas26.img`, checksums, and the LineageOS 23.2 microG GSI.
Pick one in `docs/09-recovery-choices.md`.

## Start here (original setup)

The initial setup and SIM-screen/activation path are not reproduced here; use the original
public guides:

- **`qfertig/vegas26-gsi`** — complete unlock, GSI, SIM/modem, APN and VoLTE guide:
  <https://github.com/qfertig/vegas26-gsi>
- **`parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide`** — base
  FRP/OEM-unlock/SIM-screen guide:
  <https://github.com/parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide>
- **XDA Walmart-special thread** (activation bypass, modem reports, extra files):
  <https://xdaforums.com/t/moto-g-power-2026-xt2617v-walmart-special-root-modem-unlock-bypass-unlocked-bootloader.4809158/>
- **`andrewwm/vegas-freedom`** — modem `md1img_a` SIM unlock:
  <https://github.com/andrewwm/vegas-freedom>
- **XDA recovery thread** — source of the working `vegas_ofox.img`:
  <https://xdaforums.com/t/recovery-twrp-orangefox-moto-g-play-moto-g-2026.4799348/>

See `docs/06-sim-setup.md` for the SIM-screen/IMEI notes and `docs/07-modem-unlock.md`
for the tested `md1img_a`-only modem path.

## The short version

There is **no official A16 TWRP branch**. Three recoveries now work on this board, all
built from the **12.1** core: **OrangeFox R12.0**, **TWRP 3.7.1-12**, and **PBRP 4.x**.
They share the same device tree and fixes — touch (FT8725), Trustonic TEE, FBE
`/data` decryption, backups, haptics, MTP/ADB. Pick the UI you prefer; see
`docs/09-recovery-choices.md`.

They are **reproducible from source** — the traps were UPX compression, Windows CRLF in
`prepdecrypt.sh`, two flattened gatekeeper symlinks and the stock fstab — see
`docs/08-source-build.md`. The newer OrangeFox **14.1** and **16.0** branches are **not
usable** on this phone: both bootloop in recovery userspace, and their full images
exceed the ~55.5 MB `vendor_boot` limit. Recovery compatibility here is with the A16
vendor/firmware, not the Android version.

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
roms/                  current / next / archive image staging + update sources
docs/
  00-device.md          device, partitions, stock vendor_boot geometry
  01-backups.md         raw partition backups (super, boot, vbmeta, ...)
  02-recovery.md        TWRP 14.1 build notes + OrangeFox working recipe
  03-gsi.md             LineageOS 23.2 microG GSI plan
  04-troubleshooting.md bootloop/hello moto, touch/display, fastboot, recovery entry
  05-ofox16.md          OrangeFox 16.0 source results, size limit, hybrids
  06-sim-setup.md       original setup/SIM-screen references
  07-modem-unlock.md    vegas-freedom md1img_a modem unlock (not flashed)
  08-source-build.md    working R12.0 from source (UPX/CRLF/symlink/fstab traps)
  09-recovery-choices.md OrangeFox vs TWRP vs PBRP — pick one, flash the same way
  10-recovery-pack.md   one-file zip: three images + stock vendor_boot + checksums
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
- **Modem:** flash **`md1img_a` only**, never `md1img_b`, `lk`, `preloader`, `seccfg`,
  `gpt`, `nvram`, `nvdata`, `protect*` or `persist`. The tested path is
  `andrewwm/vegas-freedom`; the RomLord Drive’s “flash slot b” warning is a different
  package/step. See `docs/07-modem-unlock.md`.
- Without a non-Tracfone SIM the network unlock cannot be verified; the modem patch can be
  built/audited offline, but `gsm.sim.state` stays `ABSENT` until a SIM is inserted.

## Credits

See `CREDITS.md`. The working recovery path stands on the XDA `TWRP/OrangeFox` thread,
`crabcakes97`/`evoxdl` device work, the XDA Walmart-special thread and RomLord Drive,
and `qfertig/vegas26-gsi` for the GSI + SIM/modem + VoLTE notes.
