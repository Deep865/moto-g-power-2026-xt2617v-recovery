# 13 — Backport roadmap: newer OrangeFox features into 12.1

The 12.1 recovery is the only base that boots reliably on this `XT2617V`. We do not
ship 14.1/16.0 images. After the 2026-11-22 tests we are **not pursuing 14.1/16.0
further**; their userspace does not reach the UI on this vendor. We only backport
specific fixes that work on the 12.1 core.

The source-tree version of this document, with patch rules, is:
<https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source/blob/main/experimental/BACKPORT-ROADMAP.md>

## Now in the 12.1 core (`8cd9df2b4`)

| Fix | What it does |
|---|---|
| Skip data-size scan before decrypt | Avoids a hang on this encrypted `/data` |
| Alternate block-device paths | Falls back between `/dev/block/bootdevice/by-name` and `/dev/block/by-name` |
| Thermal unsigned-wrap fix | Correct CPU temperature reading |
| bzip2 | Adds `bzip2` to recovery unless excluded |
| Vibration defaults | `OF_VIBRATION_DEFAULTS` build variable |
| Reboot Recovery after actions | Completion pages offer Reboot Recovery |
| Double-tap-to-wake | **Enabled** in the 2026-11-22 image (`873b5614…`); packed FT8725 handler; single tap blocked, double tap confirmed |

The two former hand-applied patches are in `patches/historical-12.1/` for history; the latest
core already contains them. The 17/17-tested OrangeFox image is from this core.

## Candidates

| Area | Why it might help | Risk |
|---|---|---|
| Partition/decrypt path fixes | MTK path differences cause scan/decrypt hangs | Low–medium; two fixes already here |
| Dynamic-partition / `super` handling | Backup and restore of logical partitions | Medium |
| Backup compression / split archives | Faster, smaller `/data` backups | Medium |
| USB / sideload / MTP fixes | Recovery USB reliability | Low; must pass sideload |
| Touch / module load order | Avoid `ENODEV` and haptic races | Low; device tree already fixed |
| Theme/minui assets | Cosmetic only if it fits the size limit | High size risk |
| 14.1/16.0 UI code | Needs the newer userspace; does not fit 12.1 | **Do not attempt** |

## dt2w test (2026-11-22)

Enabled in the final image with a packed FT8725 handler. Verified on hardware:

- single tap does nothing while the screen is dimmed/off
- double tap wakes the screen
- swipes and long presses do not wake
- 17/17 self-test still passes

The lock-screen line now shows battery only; the CPU field is hidden because recovery
cannot read the CPU thermal zones (`EINVAL`).

## Acceptance rules

1. Applies to `fox_12.1` at the pinned `bootable/recovery` commit (`8cd9df2b4`, or a deliberate
   re-pin) and compiles for `omni_vegas26-eng`.
2. Image stays under the bootloader's ~55.5 MB `vendor_boot` content limit.
3. Full **17/17** self-test with PIN `1234`: UI, FT8725 touch, FBE decrypt,
   `/sdcard` read/write, gatekeeper symlink, haptics, MTP/ADB, six panels,
   `/metadata`, backup dirs.
4. ADB sideload still works.
5. No backup/restore or normal-boot regression.
6. Record patch, source branch/commit, image SHA-256 and test result. Do not publish
   an untested image as a recovery option.

## Test loop

```bash
FOX_TREE=$HOME/fox_12.1 DEVICE_TREE=$DEVICE_TREE OUT_DIR=$OUT_DIR \
  "$DEVICE_TREE/scripts/91-build-ofox12-recovery.sh"
python3 "$DEVICE_TREE/scripts/extract_frags.py" "$OUT_DIR/OrangeFox-R12.0-vegas26.img" /tmp/ofox
# flash vendor_boot_a, enter from bootloader menu, PIN 1234:
adb shell 'sh /tmp/recovery-selftest.sh'
adb pull /tmp/recovery_selftest.txt
```

See [`05-ofox16.md`](05-ofox16.md) for why the 14.1/16.0 images are not supported.
