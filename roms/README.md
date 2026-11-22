# ROMs and recovery images

Local staging area for what is flashed on **XT2617V / `vegas26`**. Images are
gitignored; only the READMEs and `SHA256SUMS.txt` files are committed.

## Layout

```
roms/
  current/   current GSI + working OrangeFox 12.1 recovery + fallback
  next/      downloaded next update, not flashed/tested yet
  archive/   previous images and base images for rollback
```

## Current (2026-11-22)

| Image | Purpose | SHA-256 |
|---|---|---|
| `current/LineageOS-23.2-2026.11.18-microG-gsi.img` | Android 16 GSI on `system_a` | `dcefcb1920…` |
| `current/OrangeFox-R12.0-vegas26.img` | current working recovery on `vendor_boot_a` | `86c42c57…` |
| `current/vegas_ofox_fixed.img` | XDA-prebuilt OrangeFox fallback | `ddcc5967…` |
| `archive/vegas_ofox_base.img` | original XDA OrangeFox base used for the repack | `4664f563…` |

TWRP 3.7.1-12 and PBRP 4.x from the release are equally working alternatives.

Full hashes are in the `SHA256SUMS.txt` next to each folder.

## GitHub Release

**`2026-11-22`**:
<https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery/releases/tag/2026-11-22>

- `Moto-G-Power-2026-XT2617V-flash-kit-2026-11-22.zip` (recoveries + GSI + docs)
- `Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip` (recoveries only)
- `OrangeFox-R12.0-vegas26.img`, `TWRP-3.7.1-12-vegas26.img`, `PBRP-4.x-vegas26.img`
- `LineageOS-23.2-2026.11.18-microG-gsi.img.xz` (1.09 GB; decompress before flashing)
- `vegas_ofox_fixed.img` (64 MB fallback), `vegas_ofox_base.img` (original base)
- `SHA256SUMS-2026-11-22.txt`

The decompressed GSI `.img` is 2.9 GB and exceeds GitHub's 2 GB/file release-asset
limit; use the `.xz`.

## Where updates come from

### LineageOS 23.2 microG GSI (Android 16)
- Folder: <https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/>
- RSS: <https://sourceforge.net/projects/lineageos-4-microg/rss?path=/GSI/16>
- Tested: `LineageOS-23.2-2026.11.18-microG-gsi.img.xz`
- Pick the **arm64 A/B, ext4, regular** build (not `vndklite`).

### Recovery source
- Source repo: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source>
- Build one of the three 12.1 recoveries with `scripts/91`, `92`, `93`, or all with
  `scripts/build-all-three.sh`.
- Do not expect 14.1/16.0 to boot; see `docs/05-ofox16.md`.

### Stock firmware (fallback / `md1img`)
- lolinet mirror: <https://mirrors.lolinet.com/firmware/moto/>
- Use only the `vegas26` / `XT2617V` package for your build.

### Tools
- Platform-tools: <https://developer.android.com/tools/releases/platform-tools>
  (35.0.0 or 37.0.1; avoid 37.0.3)
- Magisk: <https://github.com/topjohnwu/Magisk/releases>

## Update workflow

1. Download a new GSI `.img.xz` into `next/`.
2. Verify the published MD5; decompress with `xz -d`.
3. Flash `next/` in fastbootd: `fastboot flash system <new.img>`. No `/data` wipe is
   needed once stock recovery has formatted `/data` once.
4. If it boots and works, move the old images to `archive/`, move the new into
   `current/`, and update `current/SHA256SUMS.txt`.
5. Keep the last known-good GSI and recovery in `archive/`.

## GitHub size limits

- Normal git history rejects files > 100 MB; the GSI `.img` is 2.9 GB. Do not commit it.
- The `.xz` is 1.09 GB and fits a GitHub **Release asset** (2 GB/file limit).
- The recovery images are 64 MB; attach them to the release, not normal git.
