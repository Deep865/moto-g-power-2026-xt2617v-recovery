# ROMs and recovery images

Local staging area for what is flashed on **XT2617V / `vegas26`**. Actual images are
gitignored; only the READMEs and `SHA256SUMS.txt` files are committed.

## Layout

```
roms/
  current/   exactly what is flashed right now (GSI + working recovery)
  next/      downloaded next update, not flashed/tested yet
  archive/   previous working images and base images for rollback
```

## Current (2026-11-21)

| Image | Purpose | SHA-256 |
|---|---|---|
| `current/LineageOS-23.2-2026.11.18-microG-gsi.img` | Android 16 GSI flashed to `system_a` | `dcefcb1920…` |
| `current/vegas_ofox_fixed.img` | OrangeFox 14.1 recovery on `vendor_boot_a`, stock FT8725 module | `ddcc5967…` |
| `archive/vegas_ofox_base.img` | original XDA OrangeFox base used for the repack | `4664f563…` |

Full hashes are in the `SHA256SUMS.txt` next to each folder.

## Where updates come from

### LineageOS 23.2 microG GSI (Android 16)
- Folder: <https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/>
- RSS: <https://sourceforge.net/projects/lineageos-4-microg/rss?path=/GSI/16>
- Current: `LineageOS-23.2-2026.11.18-microG-gsi.img.xz`
- The RSS entry carries the published MD5. Pick the **arm64 A/B, ext4, regular** build
  (not `vndklite`).

### OrangeFox base (for the recovery repack)
- XDA thread: <https://xdaforums.com/t/recovery-twrp-orangefox-moto-g-play-moto-g-2026.4799348/>
- Base: `vegas_ofox.img` (first post)
- Then apply `scripts/60-repack-ofox-touch.sh` with your phone's stock FT8725 module.
  See `REPRODUCE.md`.

### Stock firmware (fallback / `md1img`)
- lolinet mirror: <https://mirrors.lolinet.com/firmware/moto/>
- Use only the `vegas26` / `XT2617V` package for your build.

### Tools
- Platform-tools: <https://developer.android.com/tools/releases/platform-tools>
  (35.0.0 or 37.0.1; avoid 37.0.3)
- Magisk: <https://github.com/topjohnwu/Magisk/releases>

## Update workflow

1. Download the new GSI `.img.xz` into `next/` (or run `scripts/fetch-gsi-update.ps1`).
2. Verify the published MD5; decompress with `xz -d`.
3. Flash `next/` in fastbootd and test:
   `fastboot flash system <new.img>`.
   No `/data` wipe is needed once `/data` was formatted once by stock recovery.
4. If it boots and works:
   - move the old `current/` images to `archive/`,
   - move the new image into `current/`,
   - update `current/SHA256SUMS.txt`.
5. Keep the last known-good GSI and recovery in `archive/`.

## GitHub size limits

- GitHub rejects files > 100 MB in normal git history; Git LFS allows 2 GB/file.
- The GSI `.img` is **2.9 GB** — do not commit it.
- The GSI `.xz` is **1.09 GB** — also too large for normal git, but it fits a GitHub
  **Release asset** (2 GB/file limit).
- The 64 MB recovery images could be stored as release assets or release artifacts.

The recommended pattern is: commit the `SHA256SUMS.txt` and update links; keep the
images in this folder locally, or attach the `.xz`/recovery image to a GitHub Release.
