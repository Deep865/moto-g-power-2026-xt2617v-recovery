# Moto G Power 2026 (`XT2617V`, Walmart / Straight Talk) — unlock, degoogle, GSI and three working recoveries

Everything we used and verified on the **Walmart / Straight Talk Moto G Power 2026**
(`XT2617V`, Android codename `vegas26`, bootloader product `vegas`, MediaTek MT6835):
the complete phone walkthrough, the temporary/persistent root APKs, the LineageOS
23.2 microG GSI, the unlock/modem tools, the working recovery images and the revert
files. Everything needed is in the repo and the release; no hunting other projects.

**Start here:** [`WALKTHROUGH.md`](WALKTHROUGH.md) — SIM-screen bypass → temporary
root → bootloader unlock → Magisk → GSI → recovery → modem → revert.

This repo is the **guide + release** half. The **source/build** half is
[`Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source`](https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source).

## Download

[**Release 2026-11-22**](https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-unlock-degoogle-guide/releases/tag/2026-11-22)

| Asset | What it is |
|---|---|
| `Moto-G-Power-2026-XT2617V-flash-kit-2026-11-22.zip` | **One download:** three recoveries, stock `vendor_boot_a`, GSI `.xz`, DFRoot/KernelSU/Magisk APKs, val-protocol, vegas-freedom, this walkthrough, docs and checksums |
| `Moto-G-Power-2026-XT2617V-root-apks-2026-11-22.zip` | DFRoot 4.7, KernelSU 3.3.1 + Magisk 31.1 APKs with licences and hashes |
| `Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip` | Recoveries only: OrangeFox, TWRP, PBRP, stock revert, README, checksums |
| `OrangeFox-R12.0-vegas26.img` | OrangeFox 12.1 — 17/17 + ADB sideload |
| `TWRP-3.7.1-12-vegas26.img` | TWRP 12.1 — 17/17 |
| `PBRP-4.x-vegas26.img` | PBRP 12.1 — 17/17 |
| `LineageOS-23.2-2026.11.18-microG-gsi.img.xz` | Tested Android 16 microG GSI |
| `SHA256SUMS-2026-11-22.txt` | Hashes for the release files |

The flash kit contains **no** `md1img`, `nvram`, `nvdata`, `seccfg`, `persist`, `frp`,
`protect*`, `super.img`, IMEI, serial or unlock keys. The modem tool patches **your**
stock image. The root APKs are the tested unmodified upstream builds; hashes and
licences are in [`tools/`](tools/).

## What works

| Item | State |
|---|---|
| Stock firmware | `W1WEOS36.48-22-3-3-4-3`, Android 16, patch 2026-06-01 |
| Bootloader | unlocked (`flashing_unlocked`) |
| Root | Magisk 31.1 (`u:r:magisk:s0`) |
| **Working recoveries** | **OrangeFox R12.0**, **TWRP 3.7.1-12**, **PBRP 4.x** — all 12.1-based, 17/17 each |
| Recovery features | FT8725 touch, FBE `/data` decrypt, backup/restore, MTP/ADB, haptics, six panels; sideload verified on OrangeFox |
| GSI | LineageOS 23.2 microG, Android 16 — boots and is used as a Wi-Fi backup |
| Modem / SIM | Patched `md1img_a` was flashed, but **not network-verified** (no SIM); see [`docs/07-modem-unlock.md`](docs/07-modem-unlock.md) |

## The path, in order

The full commands are in [`WALKTHROUGH.md`](WALKTHROUGH.md). The short version:

1. **Stop updates** and confirm `XT2617V` / `W1WEOS36.48-22-3-3-4-3` / slot `_a`.
2. **Bypass the carrier activation screen** with Google's Test DPC enterprise QR
   (remove the device-owner role afterwards). This is not a SIM unlock.
3. **Temporary root** with DFRoot + KernelSU, then **back up** `super`, `lk`, `boot`,
   `init_boot`, `vendor_boot`, `vbmeta`, `dtbo`, `md1img`, `nvram`, `nvdata`, `frp`
   and the rest. Keep the backups private.
4. **Unlock the bootloader**: patch your own `lk_a` with val-protocol, set the OEM
   flag in `frp`, generate keys for **your** serial, `fastboot oem unlock`. This
   wipes data and disables FRP.
5. **Persistent root**: patch `init_boot` with Magisk and write it from Android with
   `dd`; this unit rejects `fastboot flash init_boot_a`.
6. **Install the GSI**: disable verified boot from the bootloader, flash `system` in
   fastbootd, then do the first `/data` wipe with **stock recovery factory reset** —
   never `fastboot -w`.
7. **Flash a recovery** to `vendor_boot_a`, enter it from the **bootloader menu**, and
   keep the stock `vendor_boot_a` for revert.
8. **Optional modem unlock**: patch **your own** stock `md1img`, flash **`md1img_a`
   only**, test with a non-Tracfone SIM. Our unit is not verified.

## Pick a recovery

All three are `vendor_boot_a` images and work equally well. Pick by UI.

| Recovery | Why | Size | SHA-256 |
|---|---|---:|---|
| **OrangeFox R12.0** | Most features; `fox` CLI; ADB sideload verified; newer 12.1 core with thermal/bzip2/vibration/reboot-recovery fixes | 55.2 MB | `9cd70969…24a0` |
| **TWRP 3.7.1-12** | Plain familiar TWRP; smallest | 52.8 MB | `0a241558…c5d7` |
| **PBRP 4.x** | TWRP-based with a different, colourful UI | 54.9 MB | `c899f61e…77cb` |

```powershell
fastboot flash vendor_boot_a OrangeFox-R12.0-vegas26.img
```

Then **Power + Volume Down → Volume Down to Recovery mode → Power**.
`fastboot reboot recovery` boots Android on this unit.

Details and revert: [`docs/09-recovery-choices.md`](docs/09-recovery-choices.md),
[`docs/10-recovery-pack.md`](docs/10-recovery-pack.md).

## Build any of them

Source: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source>

One device tree, three build scripts, one per recovery:

- `scripts/91-build-ofox12-recovery.sh` — OrangeFox R12.0 (newer 12.1 core with the former 14.1 backports plus thermal/bzip2/vibration/reboot-recovery fixes)
- `scripts/92-build-twrp12.sh` — TWRP 3.7.1-12
- `scripts/93-build-pbrp12.sh` — PBRP 4.x
- `scripts/build-all-three.sh` — build all or a subset

You do **not** need to build all three. See the source repo
[`recoveries/`](https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source/tree/main/recoveries)
for a per-recovery sheet and `BUILD-ALL.md` for the full guide.

## Not usable on this phone

**OrangeFox 14.1 and 16.0** build but do not reach a usable recovery UI on this A16
vendor, and their full images can exceed the ~55.5 MB `vendor_boot` content limit.
**TWRP 14.1** has the same userspace blocker. They are not published as recovery
options.

We **do** backport useful fixes from those branches into 12.1. See
[`docs/13-backport-roadmap.md`](docs/13-backport-roadmap.md) and the source
`experimental/BACKPORT-ROADMAP.md`.

## Repo layout

```
README.md                 this overview
WALKTHROUGH.md            the complete phone procedure
RELEASE-2026-11-22.md     release notes
docs/
  00-device.md            device, partitions, vendor_boot geometry
  01-backups.md           raw partition backups and restore
  02-recovery.md          recovery history and the working recipe
  03-gsi.md               LineageOS 23.2 microG GSI detail
  04-troubleshooting.md   recovery entry, fastboot, touch, GSI bootloop
  05-ofox16.md            14.1/16.0 experiments (not supported)
  06-sim-setup.md         SIM screen, root, unlock references
  07-modem-unlock.md      md1img_a modem unlock and no-SIM caveat
  08-source-build.md      source build traps (UPX/CRLF/symlinks/fstab)
  09-recovery-choices.md  OrangeFox vs TWRP vs PBRP
  10-recovery-pack.md     recovery pack contents
  11-recovery-test-results.md  17/17 matrix, sideload, failures
  12-flash-kit.md         one-download flash kit contents
  13-backport-roadmap.md  features brought into 12.1 / next candidates
scripts/                  test/backup helpers used here
tools/                    APKs, val-protocol, vegas-freedom, licences
artifacts/                SHA-256 files
CREDITS.md
```

Nothing device-unique is published: no serial numbers, unlock keys, IMEI, `nvram`,
`nvdata`, `seccfg`, `persist`, `frp`, `protect*`, `md1img` or `super.img`.

## Read this before flashing

- **Never relock the bootloader** with a modified `lk`/`init_boot`.
- **Never flash another device's image.** Nevada/Utah/Kansas images are different
  boards.
- Use **platform-tools 35.0.0 or 37.0.1**; 37.0.3 can stall during `flash`.
- Keep `private-backups` private.
- Back up **before** any `system`/`data` change. A raw `super.img` is the cleanest
  GSI revert.
- **Modem:** flash **`md1img_a` only**, never `md1img_b`, `lk`, `preloader`, `seccfg`,
  `gpt`, `nvram`, `nvdata`, `protect*` or `persist`.
- The modem/network unlock cannot be verified without a non-Tracfone SIM. It is
  separate from a carrier's IMEI activation policy.
- Do not accept firmware updates if you rely on this exact `-4-3` setup.

## Credits

See [`CREDITS.md`](CREDITS.md). The working recovery path stands on the XDA
TWRP/OrangeFox thread, `crabcakes97`/`evoxdl` device work, the XDA Walmart-special
thread, `qfertig/vegas26-gsi` for the GSI + SIM/modem + VoLTE notes, and
`andrewwm/vegas-freedom` for the LK/modem tools.
