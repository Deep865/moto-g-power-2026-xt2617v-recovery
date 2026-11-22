# 08 — Building the working recoveries from source

All three supported recoveries are reproducible from one device tree:

| Recovery | Script | Base |
|---|---|---|
| OrangeFox R12.0 | `scripts/91-build-ofox12-recovery.sh` | OrangeFox `fox_12.1` |
| TWRP 3.7.1-12 | `scripts/92-build-twrp12.sh` | TWRP `twrp-12.1` |
| PBRP 4.x | `scripts/93-build-pbrp12.sh` | PBRP `android-12.1` |

Source: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source>

Where each change is applied (device-tree files, pinned core, or build-time edit):
<https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source/blob/main/FIXES.md>

The two old `patches/historical-12.1/` files are **not applied** to the current core; they are
already in the pinned `8cd9df2b4` commit and are kept for history. `scripts/91` runs
`scripts/verify-core.sh` after checkout and refuses to build if a required fix is
missing.

The source repo's [`BUILD-ALL.md`](https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source/blob/main/BUILD-ALL.md)
has the full host setup and commands. You build **one** recovery, not all three.

## OrangeFox R12.0

```bash
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 12.1 --path "$HOME/fox_12.1"

export DEVICE_TREE=$HOME/moto-g-power-2026-xt2617v-walmart-recovery-source
export OUT_DIR=$HOME/recovery-images
FOX_TREE=$HOME/fox_12.1 DEVICE_TREE=$DEVICE_TREE OUT_DIR=$OUT_DIR \
  "$DEVICE_TREE/scripts/91-build-ofox12-recovery.sh"
```

`91` pins `bootable/recovery` to the latest tested `fox_12.1` core (`8cd9df2b4`),
which already contains the two former 14.1 backports plus thermal, bzip2,
vibration-default, reboot-recovery and optional double-tap-to-wake fixes. It
disables UPX, fixes the gatekeeper symlinks and builds `lunch omni_vegas26-eng` +
`mka vendorbootimage`.

## TWRP 3.7.1-12

```bash
mkdir -p "$HOME/twrp_12.1" && cd "$HOME/twrp_12.1"
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

TWRP_TREE=$HOME/twrp_12.1 DEVICE_TREE=$DEVICE_TREE OUT_DIR=$OUT_DIR \
  "$DEVICE_TREE/scripts/92-build-twrp12.sh"
```

## PBRP 4.x

```bash
mkdir -p "$HOME/pbrp_12.1" && cd "$HOME/pbrp_12.1"
repo init --depth=1 -u https://github.com/PitchBlackRecoveryProject/manifest_pb -b android-12.1
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

PBRP_TREE=$HOME/pbrp_12.1 DEVICE_TREE=$DEVICE_TREE OUT_DIR=$OUT_DIR \
  "$DEVICE_TREE/scripts/93-build-pbrp12.sh"
```

## The fixes that make the difference

Each is a build-to-boot difference on this unit:

| Symptom | Cause | Fix |
|---|---|---|
| black screen / bootloop | OrangeFox UPX-compresses `/sbin` and `/system/bin`; packed `init`/`recovery` never reach userspace | skip UPX (`FOX_SKIP_UPX=1`) |
| hangs on the OrangeFox splash | `prepdecrypt.sh` had a Windows **CRLF** shebang → init status 127 → crypto/keymint never starts | keep every device-tree text file LF |
| decrypt hangs at `using secdis to decrypt spblob` | `gatekeeper.*.so` were 18-byte text files, not symlinks; `dlopen` fails | real symlinks to `libMcGatekeeper.so` / `libSoftGatekeeper.so` |
| partition scan hang | stock `recovery.fstab` with duplicate erofs/ext4 entries | minimal working `recovery.fstab` |
| `ram init failed` / no haptics | `aw862x` loaded before `regulator-vibrator` | load `regulator-vibrator.ko` first |
| sideload fails | `adbd` conflict | stop `adbd` and configure the gadget in `init.recovery.usb.rc` |
| touch `ENODEV` | recovery bundles a different G Play FT8725 module | use the phone's stock `vendor_dlkm` module |

The CRLF and flattened-symlink traps are Windows artifacts. Build from a Linux
checkout; the scripts fix the copied tree but do not fix a bad source archive.

## Verify

```bash
python3 scripts/extract_frags.py "$OUT_DIR/OrangeFox-R12.0-vegas26.img" /tmp/frags
```

Expected: `VNDRBOOT`, header 4, page 4096, DTB `183530` bytes, two fragments
(`platform` + `recovery`), total 67,108,864 bytes, content under ~55.5 MB.

The tested 2026-11-22 images:

| Image | SHA-256 |
|---|---|
| OrangeFox | `9cd709698b444658d5db5bbbe047429bebfc2ce4209e1b08c377d591ff1a24a0` |
| TWRP | `0a241558f40d4cd18b0b2299d0018ac0154362045691b329c8bfb4a6d562c5d7` |
| PBRP | `c899f61ee38ad14ecccd352fa06fcf9e61737698487eb83001ec4a3d95d977cb` |

A fresh build may differ by build ID. Boot and test it before publishing.

## Flash / revert

```powershell
fastboot flash vendor_boot_a <image>.img
# bootloader menu: Volume Down -> Recovery mode -> Power
```

Revert with the stock `vendor_boot_a.img`.

## 14.1 / 16.0

They build but do not reach a usable recovery UI on this Android 16 vendor; full
images can exceed the size limit. See [`05-ofox16.md`](05-ofox16.md) and the
[backport roadmap](13-backport-roadmap.md). Do not publish them as recovery options.
