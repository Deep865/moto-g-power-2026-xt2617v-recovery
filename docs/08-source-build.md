# 08 — Building the working R12.0 from source

The working OrangeFox R12.0 is reproducible from source. Verified on-device on
**2026-11-22**: UI, touch, FBE `/data` decryption and backup all work.

## What the working image actually is

The XDA prebuilt's own props record the build:

```text
ro.build.fox_codebase = 2026-08-21 (3fc9e73f)     # bootable/recovery commit
ro.product.system.device = nevada                  # Moto G Play 2026 tree
build path = /home/runner/work/OrangeFox-Action-Builder/...
FOX_BUILD_DATE = Sat Aug 29 21:50:31 2026
ro.build.fox_id = 78356af1-ad39-4c79-b278-cdbe542a9d1d
```

So it is an **OrangeFox 12.1 branch** build of the **nevada** device tree, made with
the public **OrangeFox-Action-Builder** workflow. It carries the vegas26 DTB
(`183530` bytes, SHA-256 `50cf2684…`) and the 1080×2388 panel modules.

Source tree: **`Deep865/vegas26-recovery-source`**
(device tree + `scripts/90-build-ofox12-source.sh`).

## Build

```bash
git clone https://gitlab.com/OrangeFox/sync.git
cd sync
./orangefox_sync.sh --branch 12.1 --path /root/fox_12.1

# copy the device tree to /root/fox_12.1/device/motorola/vegas26
# (scripts/90-build-ofox12-source.sh does this automatically)

cd /root/fox_12.1
bash /path/to/vegas26-recovery-source/scripts/90-build-ofox12-source.sh
```

The script:

- checks out **`bootable/recovery` at `3fc9e73f`** (the working image's commit);
- sets `FOX_SKIP_UPX=1` and patches `vendor/recovery/OrangeFox_vendor.sh`;
- sets `FOX_EXTREME_SIZE_REDUCTION=0` (keeps fonts, FFiles, bash);
- fixes the gatekeeper symlinks and uses the minimal working fstab;
- builds `mka vendorbootimage` and copies the result to
  `wsl-build/vendor_boot_ofox12_source.img`.

## The four traps

These are the differences between "it builds" and "it boots"; each one was observed
on this unit.

| Symptom | Cause | Fix |
|---|---|---|
| black screen / bootloop | OrangeFox compresses `/sbin` and `/system/bin` with UPX (`init`, `recovery`, `adbd`, `sh`); the packed binaries never reached userspace | skip UPX (`FOX_SKIP_UPX=1`); the working image's binaries are exactly the decompressed sizes |
| hangs on the OrangeFox splash | `prepdecrypt.sh` had a Windows **CRLF** shebang (`#!/sbin/sh\r`) → init `execv` status 127 → `crypto.ready` never set → Trustonic KeyMint never starts → `keystore2` aborts with `connect_keymint: NAME_NOT_FOUND` → TWRP waits forever for `keystore2` | keep every device-tree text file LF |
| decrypt hangs at `using secdis to decrypt spblob` | `vendor/lib64/hw/gatekeeper.trustonic.so` / `gatekeeper.default.so` were **18/20-byte text files** ("libMcGatekeeper.so") instead of symlinks; `dlopen` fails and gatekeeper crash-loops | make them symlinks to `libMcGatekeeper.so` / `libSoftGatekeeper.so` |
| TWRP partition scan / hang | stock `recovery.fstab` with duplicate erofs/ext4 entries and `first_stage_mount` | use the minimal working `recovery.fstab` (1,871 bytes) |
| small UI differences | newer `bootable/recovery` | pin `3fc9e73f` |

The CRLF and flattened-symlink traps are **Windows artifacts**: the device tree was
edited on NTFS, which saved symlinks as text files and text as CRLF. Always build from
a Linux checkout (or let the script convert/fix the tree).

## Verify on the device

```text
ro.product.device = vegas26
ro.build.fox_codebase = 2026-08-21 (3fc9e73f2)
crypto.ready = 1
init.svc.keystore2 = running
/sys/class/touchscreen/primary/productinfo = ft8725
```

Then in the UI: the decrypt screen accepts the PIN, `/data` mounts, and a backup of
`/data` completes.

The verified flashed image was `vendor_boot_ofox12_sym.img`:

```text
SHA-256 88510c28fa1cfd0729356d5cac4add4e2f9e4847a03268d969bc95b37851631f
fragments  platform 2,689,051 + recovery 52,303,722
```

A fresh build may differ only in build IDs. The XDA prebuilt
(`vegas_ofox_fixed.img`, SHA-256 `ddcc5967…`) remains the tested fallback.

## Flash / revert

```powershell
fastboot flash vendor_boot_a vendor_boot_ofox12_source.img
# bootloader menu: Volume Down -> Recovery mode -> Power
```

Revert:

```powershell
fastboot flash vendor_boot_a revert\vendor_boot_a.img
```
