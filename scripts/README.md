# Scripts

Helper scripts used on this `XT2617V` (`vegas26`). They are **not turnkey**; replace
every `<you>` path and provide the source trees/images they expect. Nothing
device-unique is included.

## Building the recoveries

The supported build scripts live in the source repo, not here:

<https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source>

- `scripts/91-build-ofox12-recovery.sh` — OrangeFox R12.0
- `scripts/92-build-twrp12.sh` — TWRP 3.7.1-12
- `scripts/93-build-pbrp12.sh` — PBRP 4.x
- `scripts/build-all-three.sh` — all or a subset

See that repo's `BUILD-ALL.md`.

## Historical build / repack (not supported)

| Script | Purpose |
|---|---|
| `10-build-14.1.sh` | old TWRP 14.1 full build; userspace does not boot |
| `11-rebuild.sh` | incremental rebuild of the same |
| `50-build-hybrid.sh` | stock A16 platform + TWRP 14.1 recovery; logo hang |
| `60-repack-ofox-touch.sh` | replace the XDA OrangeFox touch module and repack (fallback) |
| `verify_built.py` | header/DTB/fragment verification against a stock image |
| `extract_frags.py` | dump vendor_boot fragments |
| `state.sh`, `kill-build.sh` | long-build supervisor helpers |

Assumptions for the historical scripts: TWRP tree at `/root/twrp`, OrangeFox
extraction at `/root/ofox`, stock revert at `<MotoRoot>/revert/vendor_boot_a.img`,
device tree at `<MotoRoot>/device-tree`. Run with `bash`, not `sh`.

## Phone (ADB, root)

| Script | Purpose |
|---|---|
| `backup-dd.sh` | `dd` the key partitions to `/data/local/tmp/backup-YYYYMMDD` and hash them |
| `backup-sizes.sh` | list partition sizes and free space |
| `extract-stock-touch-module.sh` | copy the real `vendor_dlkm` FT8725 module |
| `ofox-touch.sh` | mount the real `vendor_dlkm` (`erofs`) and list stock touch modules |
| `ofox-touch2.sh` | unload the image's modules, load the stock module, show input devices |

Push and run:

```powershell
adb push backup-dd.sh /tmp/backup-dd.sh
adb shell su -c 'sh /tmp/backup-dd.sh'
```

## ROM updates

`fetch-gsi-update.ps1` reads the LineageOS microG GSI RSS, downloads the latest
`.img.xz` into `roms\next`, verifies the published MD5, and can decompress with WSL:

```powershell
.\scripts\fetch-gsi-update.ps1 -Decompress
```

## Verification

```bash
python3 verify_built.py vendor_boot.img revert/vendor_boot_a.img
python3 extract_frags.py vendor_boot.img /tmp/frags
```

## Cautions

- `backup-dd.sh` includes `nvram`, `nvdata`, `seccfg`, `persist`, `frp`, `protect*`
  and `md1img`. Keep those private.
- Do not flash without verifying the header/DTB and keeping a stock revert.
- The 14.1/16.0 scripts are historical; the supported builds are the 12.1 ones in the
  source repo.
