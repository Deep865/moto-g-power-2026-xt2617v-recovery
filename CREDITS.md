# Credits and prior work

This repo is a field log assembled from public work by others plus hands-on testing on
one `XT2617V`. No affiliation with Motorola, TeamWin, OrangeFox, LineageOS or the authors
below.

## Recovery / OrangeFox path

- XDA thread: **[RECOVERY] TWRP/OrangeFox — Moto G Play/Moto G (2026)** by `RomLord14495`
  https://xdaforums.com/t/recovery-twrp-orangefox-moto-g-play-moto-g-2026.4799348/
  (source of the working `vegas_ofox.img` and the panel/touch notes)
- The working image is **OrangeFox R12.0**, not 14.1. The README’s older
  “14.1-based” label was wrong; `REPRODUCE.md` and the `R12.0` base are correct.
  The TWRP 14.1 source and the OrangeFox 14.1/16.0 source builds are newer controls,
  documented in `STATUS.md` and `docs/05-ofox16.md`.
- XDA Walmart-special thread by `moto98_` — carrier activation bypass, modem unlock,
  bootloader unlock, OTA blocker:
  https://xdaforums.com/t/moto-g-power-2026-xt2617v-walmart-special-root-modem-unlock-bypass-unlocked-bootloader.4809158/
- `RomLord14495` Moto Roms Drive (network unlock / LineageOS files; slot-b warning):
  https://drive.google.com/drive/folders/1WAlJfCoh0CA8jhdGqINo_kgn7r-Dt678
- `crabcakes97` — Nevada TWRP trees / stock recovery base:
  https://github.com/crabcakes97/moto_G_Play_2026_TWRP
  https://github.com/crabcakes97/stock_tree_recovery_nevada_base
- `evoxdl` — Moto G 2025 (`kansas`) tree and the rebase/display/touch fixes:
  https://github.com/evoxdl/android_device_motorola_kansas
- Hovatek — original base-tree approach.
- TeamWin Recovery Project and the OrangeFox Recovery Project for the recovery engine.

## vegas26 LineageOS / GSI path

- `qfertig/vegas26-gsi` — the tested LineageOS 23.2 microG GSI guide, data/SMS/VoLTE,
  SIM unlock, overlays:
  https://github.com/qfertig/vegas26-gsi
- `jimmielin/android_device_motorola_vegas26` — LineageOS 23.2 device tree for
  `vegas26` (`mt6835-common`, stock 5.15 kernel, TXD FT8725 panel / Focaltech touch):
  https://github.com/jimmielin/android_device_motorola_vegas26
- LineageOS for microG / Colors — GSI builds:
  https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/
- `MisterZtr/LineageOS_gsi` — alternate GSI index.

## Bootloader / root / unlock background

- `parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide`
  https://github.com/parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide
- `jesussaves-dev/moto-g-power-2026-root`
  https://github.com/jesussaves-dev/moto-g-power-2026-root
- `Maikyxd/val-protocol` — LK unlock patch.
- `andrewwm/vegas-freedom` — modem SIM unlock.
- `diabl0w/DFRoot` and KernelSU — temporary root used before persistent Magisk.

## AOSP / TWRP build notes

The A14/TWRP build fixes in `docs/02-recovery.md` are ordinary AOSP-14 source drift
(CTS asset lists, AIDL NDK module names, removed `vold` FDE helpers). They are documented
so the next porter does not rediscover them.

## Licensing

- This repo’s original text and scripts: MIT (see `LICENSE`).
- AOSP/TWRP/OrangeFox/LineageOS components retain their own licenses (Apache-2.0 / GPL).
- Do not redistribute device-unique calibration/security partitions or unlock keys.
