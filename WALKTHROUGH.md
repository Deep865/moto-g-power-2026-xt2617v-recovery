# Moto G Power 2026 (`XT2617V`, Walmart / Straight Talk) — full walkthrough

This is the complete path we used on a **Walmart / Straight Talk Moto G Power 2026**,
model `XT2617V`, codename `vegas26`, bootloader product `vegas`, MediaTek MT6835.
It goes from a locked, unactivated phone to:

- no SIM/activation screen;
- temporary root, bootloader unlock and persistent Magisk;
- LineageOS 23.2 microG GSI (Android 16);
- one of three working custom recoveries;
- optionally, the modem/network unlock;
- a clean revert path.

> **Status of the modem step:** the patched `md1img_a` was built and flashed on this
> unit, but there was **no SIM available**, so the network unlock is **not verified**.
> Everything else below was booted and tested on the phone. Read the modem section
> before treating it as a finished unlock.
>
> This is a firmware-specific, experimental procedure. You can lose data or make the
> phone unable to boot. Use a device you own and keep the backups.

## Contents

1. [What you need](#1-what-you-need)
2. [Confirm the phone and stop updates](#2-confirm-the-phone-and-stop-updates)
3. [Get past the SIM / carrier activation screen](#3-get-past-the-sim--carrier-activation-screen)
4. [Temporary root and backups](#4-temporary-root-and-backups)
5. [Unlock the bootloader](#5-unlock-the-bootloader)
6. [Persistent Magisk root](#6-persistent-magisk-root)
7. [Install the LineageOS GSI](#7-install-the-lineageos-gsi)
8. [Flash a working recovery](#8-flash-a-working-recovery)
9. [Modem / network unlock (optional)](#9-modem--network-unlock-optional)
10. [Revert / restore](#10-revert--restore)
11. [Release files](#11-release-files)
12. [Troubleshooting and references](#12-troubleshooting-and-references)

---

## 1. What you need

- The phone, a USB data cable and a Windows/Linux PC. Do not use a hub if you can
  avoid it.
- **Platform-tools 35.0.0 or 37.0.1.** `37.0.3` can stall during `fastboot flash`.
  ADB and Fastboot must be on `PATH`, or use full paths.
- A **non-Tracfone SIM** only if you want to test the modem unlock. None is needed for
  the GSI or recovery.
- The release files: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery/releases/tag/2026-11-22>
  - `Moto-G-Power-2026-XT2617V-flash-kit-2026-11-22.zip` — one download with the
    recoveries, GSI, docs and modem tool.
  - `Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip` — recoveries only.
  - individual images and `SHA256SUMS-2026-11-22.txt`.
- For the unlock step only: `val-protocol`, DFRoot, KernelSU and Magisk. Links are in
  the step. Use the published tools; do not reuse another phone's serial or keys.

> **Never publish or share** `nvram`, `nvdata`, `seccfg`, `persist`, `frp`,
> `protect*`, `md1img` dumps, your serial number, unlock keys or IMEI. They are
> device-unique.

## 2. Confirm the phone and stop updates

Boot Android, enable **Developer options** (tap **Build number** seven times) and
**USB debugging**, then connect and approve the PC.

```powershell
adb devices -l
adb shell getprop ro.boot.hardware.sku            # XT2617V
adb shell getprop ro.build.fingerprint            # ...W1WEOS36.48-22-3-3-4-3...
adb shell getprop ro.build.version.security_patch # 2026-06-01
adb shell getprop ro.boot.slot_suffix             # _a
adb shell getprop ro.boot.flash.locked            # 1 = locked
```

**Stop automatic updates before you start.** An OTA can patch the temporary-root or
LK weakness this process depends on. Turn Wi-Fi off and set:

```powershell
adb shell svc wifi disable
adb shell settings put global ota_disable_automatic_update 1
```

If an update is already staged, do not reboot until you have temporary root and have
checked the slot state. The tested build is `W1WEOS36.48-22-3-3-4-3`; a different
build may need different patches.

## 3. Get past the SIM / carrier activation screen

The Walmart / Straight Talk unit can stop at a carrier activation screen you cannot
pass without a plan. The workaround is Android's **enterprise provisioning** path
with Google's official **Test DPC** app. This is ordinary device provisioning on a
phone you own; it is **not** cellular activation and does **not** SIM-unlock the
modem.

1. Power off, **remove the carrier SIM**, then boot.
2. At the first Welcome/Hello screen, tap the **same blank spot six times**. Android
   opens the enterprise-provisioning QR scanner.
3. Scan Google's official Test DPC QR:
   <https://raw.githubusercontent.com/googlesamples/android-testdpc/master/qrcode.png>
   (from <https://github.com/googlesamples/android-testdpc#provisioning>). Connect to
   Wi-Fi so it can download. **Use only Google's QR**, never an unknown
   administrator's QR.
4. Choose **Use for work only**, then at **Finish Setup** tap **Finish**.
5. You land on the home screen. **Turn Wi-Fi off immediately** and keep updates
   blocked (step 2).
6. Enable Developer options and USB debugging again if needed.

Remove the Test DPC device-owner role and uninstall it:

```powershell
adb shell dumpsys activity service com.afwsamples.testdpc/.DeviceAdminService clear-device-owner
adb shell dumpsys device_policy
adb shell pm uninstall com.afwsamples.testdpc
```

`dumpsys device_policy` should show no Device Owner / Profile Owner, and the uninstall
should return `Success`. Do not uninstall an active device owner without clearing it
first. Do not scan the QR again after setup.

> You will repeat this setup after the bootloader unlock wipe, and again if a later
> data wipe brings the activation screen back.

## 4. Temporary root and backups

You need root to write `frp`, to back up partitions and later to write the patched
`init_boot`. The first root is **temporary** and disappears on reboot.

Install **DFRoot 4.7** and **KernelSU 3.3.1** (links in
[`docs/06-sim-setup.md`](docs/06-sim-setup.md)):

```powershell
adb install DFRoot_4.7.apk
adb install KernelSU_v3.3.1_32680-release.apk
adb shell am start -n df.root/.MainActivity
```

On the phone:

1. In DFRoot, select **KernelSU** as the SU manager.
2. Leave **Start at Boot**, **Auto Soft Reboot** and **Disable KSU Modules** off.
3. Tap **Launch Root once**. KernelSU should show **Working [Jailbreak mode]**.
4. In KernelSU → **Superuser**, enable **Shell** (`com.android.shell`).

Verify:

```powershell
adb shell su -c id
# uid=0(root) ... context=u:r:ksu:s0
```

If `su` is not found, the Shell permission is missing. Stop if root cannot be
verified.

### Back up before writing anything

Back up at least:

```text
lk_a lk_b boot_a init_boot_a vendor_boot_a vbmeta_a vbmeta_system_a
dtbo_a misc nvram nvdata seccfg persist prodpersist proinfo
protect1 protect2 frp preloader_raw_a md1img_a
```

`docs/01-backups.md` has the `dd` loop and the required SHA-256 checks. Pull the
images to the PC and verify both sides before deleting the phone copy. Keep them
private.

- `super.img` is ~11 GB; a full `super` backup is the best GSI revert if you have the
  space.
- The stock `vendor_boot_a` is your recovery revert.
- `md1img_a` is the modem revert.
- Do not publish any of these.

## 5. Unlock the bootloader

> **This is the riskiest step. Unlocking erases userdata.** If
> `ro.boot.flash.locked` is already `0`, skip this section. Do not relock later with
> a modified LK/init_boot.

The Tracfone build can grey out **Allow OEM Unlock**. The tested path is:

1. Patch your own `lk_a` with `val-protocol`.
2. Set the OEM-unlock flag in the last byte of `frp`.
3. Generate unlock keys for **your** serial and run `fastboot oem unlock`.
4. Approve the unlock on the phone.

The full commands and the exact patch flags live in the tools' READMEs and in
[`docs/06-sim-setup.md`](docs/06-sim-setup.md). The sequence that worked here:

```powershell
# 1. Analyse and patch your own LK (run from the val-protocol venv)
python lk_static_analyzer.py $Backup\lk_a.img -o lk-analysis --no-full-disasm
python lk_auto_patch.py $Backup\lk_a.img -o lk.unlock-serial.img `
  --analysis-dir lk-patch-analysis --preset unlock-serial `
  --key-token-secret <YOUR_SECRET> --keep-workdir
# must print: Result: VALID
```

With temporary root still active, set the last byte of `frp`:

```sh
RP=$(realpath /dev/block/by-name/frp)
SZ=$(blockdev --getsize64 "$RP")
blockdev --setrw "$RP"
printf '\001' | dd of="$RP" bs=1 seek=$((SZ-1)) conv=notrunc
dd if="$RP" bs=1 skip=$((SZ-1)) count=1 2>/dev/null | od -An -tx1   # -> 01
```

Then:

```powershell
adb reboot bootloader
fastboot getvar product              # vegas
fastboot getvar current-slot         # a
fastboot flash lk_a lk.unlock-serial.img
fastboot reboot bootloader
fastboot getvar serialno             # use YOUR serial
python lk_keygen.py --secret <YOUR_SECRET> --serialno <YOUR_SERIAL> --count 5
fastboot oem unlock <ONE_OF_YOUR_KEYS>
fastboot getvar securestate          # flashing_unlocked
```

Approve **Unlock bootloader** on the phone when prompted; the confirmation can time
out quickly. If the LK flash fails, **stop** and do not erase or flash other
partitions. A wrong `frp` byte only makes unlock fail again; it does not wipe.

After the unlock wipe, repeat the **Test DPC** setup from step 3, then install
DFRoot/KernelSU again and re-enable Shell root.

## 6. Persistent Magisk root

This writes **only `init_boot_a`**. Do not touch `boot_a`, `super`, `lk_b` or the
other slot.

1. Install **Magisk 31.1** from <https://github.com/topjohnwu/Magisk/releases>.
2. In Magisk, choose **Install → Select and Patch a File**, select your stock
   `init_boot_a.img` backup, and let it create `magisk-patched-init_boot.img`.
3. Pull the patched image and verify its size/hash on the PC.
4. From Android with temporary root, write it with `dd` and verify the readback:

```powershell
adb push magisk-patched-init_boot.img /data/local/tmp/
adb shell su -c 'blockdev --setrw /dev/block/by-name/init_boot_a'
adb shell su -c 'dd if=/data/local/tmp/magisk-patched-init_boot.img of=/dev/block/by-name/init_boot_a bs=1048576 conv=fsync'
adb shell su -c 'sha256sum /dev/block/by-name/init_boot_a'
adb shell su -c 'blockdev --setro /dev/block/by-name/init_boot_a'
adb reboot
```

Do **not** use `fastboot flash init_boot_a` on this unit; it rejects the patched
image with `Preflash validation failed`. After boot, open Magisk, finish any
“additional setup”, grant Shell superuser access, and verify:

```powershell
adb shell su -c id
# uid=0(root) ... context=u:r:magisk:s0
adb shell su -c 'magisk -v'
# 31.1:MAGISK:R
```

## 7. Install the LineageOS GSI

The tested OS is **LineageOS 23.2 microG**, Android 16, build
`23.2-20261118-UNOFFICIAL-GSI`. It is a **GSI flashed to `system`**; the stock vendor
stays. Use the arm64 **A/B, ext4, regular** build, not `vndklite`.

- Image: `LineageOS-23.2-2026.11.18-microG-gsi.img.xz`
- Source: <https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/>
- SHA-256 of the decompressed image:
  `dcefcb1920cd538a80d4a0120996278f0a8a33aacb7c0ee429c50e61f1818345`

LineageOS microG is used because it ships `com.mediatek.ims`, which is required for
VoLTE on this modem. Other GSIs may boot but not do VoLTE.

### 7.1 Decompress and check

```powershell
xz -d LineageOS-23.2-2026.11.18-microG-gsi.img.xz
```

### 7.2 Disable verified boot from the bootloader

Use your own stock `vbmeta_a.img` and `vbmeta_system_a.img` backups:

```powershell
adb reboot bootloader
fastboot --disable-verity --disable-verification flash vbmeta vbmeta_a.img
fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system_a.img
```

Do this from the **bootloader**, not fastbootd; fastbootd cannot see vbmeta on this
unit.

### 7.3 Flash `system` in fastbootd

```powershell
fastboot reboot fastboot
fastboot devices -l
fastboot flash system LineageOS-23.2-2026.11.18-microG-gsi.img
```

If it reports **not enough space**:

```powershell
fastboot delete-logical-partition product_a
fastboot delete-logical-partition product_b
fastboot flash system LineageOS-23.2-2026.11.18-microG-gsi.img
```

This is reversible with your `super.img`.

### 7.4 The critical `/data` wipe

**Do not use `fastboot -w` for the first GSI wipe.** It erases but does not format
`/data`/`metadata`; the first boot creates a wrapped key and the second boot fails
with “Can't load Android system.”

Use **stock recovery's factory reset**:

```powershell
# if the current vendor_boot is not stock, restore it first
fastboot flash vendor_boot_a stock-vendor_boot_a.img
fastboot reboot
```

Let it fail to boot on the stale data and tap **Factory reset**, or:

1. Bootloader → **Recovery mode** → “No command”.
2. Hold **Power**, tap **Volume Up** once.
3. Choose **Wipe data/factory reset**.

First clean boot takes **5–10 minutes**. If the carrier activation screen returns
after the wipe, repeat the Test DPC step.

### 7.5 After Android boots

- Verify Android 16 and the LineageOS version.
- With a SIM: select the carrier APN (the tested path for US Mobile Dark Star is
  `ereseller`), toggle airplane mode once, and test data/SMS.
- VoLTE: LineageOS 23.2 microG includes `com.mediatek.ims`; check a real call and
  `adb logcat -b radio -b main` (`useImsForCall=true`).
- The GSI does **not** remove the modem/network SIM lock. That is step 9.

Once `/data` has been formatted by stock recovery, a newer GSI can be flashed to
`system` and rebooted without wiping.

## 8. Flash a working recovery

There is **no `recovery` partition**; recovery lives in **`vendor_boot_a`**. Flash one
of these three tested images:

| Recovery | Why pick it | SHA-256 |
|---|---|---|
| **OrangeFox R12.0** | Most features, `fox` CLI, ADB sideload verified; newer 12.1 core | `86c42c57…223b` |
| **TWRP 3.7.1-12** | Plain familiar TWRP, smallest | `0a241558…c5d7` |
| **PBRP 4.x** | TWRP-based, different UI | `c899f61e…77cb` |

All three support FT8725 touch, encrypted `/data` decrypt, backups, MTP/ADB, haptics
and six panels. Full hashes and the test matrix:
[`docs/09-recovery-choices.md`](docs/09-recovery-choices.md) and
[`docs/11-recovery-test-results.md`](docs/11-recovery-test-results.md).

```powershell
adb reboot bootloader
fastboot flash vendor_boot_a OrangeFox-R12.0-vegas26.img
fastboot reboot
```

Then enter recovery from the **bootloader menu**:

**Power + Volume Down → Volume Down to `Recovery mode` → Power**

`fastboot reboot recovery` and `adb reboot recovery` can boot normal Android on this
unit. If recovery asks for the PIN, use your `/data` PIN; `/sdcard` should mount and a
backup to `Fox/BACKUPS` (or `TWRP/BACKUPS`) should complete.

### Revert the recovery

Keep the stock `vendor_boot_a` from your backup (and in the release pack):

```powershell
fastboot flash vendor_boot_a stock-vendor_boot_a.img
```

## 9. Modem / network unlock (optional)

> **Read this before flashing.** The network lock is separate from the bootloader
> unlock and is enforced by the MediaTek modem (`md1img`). A GSI does not remove it.
> Our patched image was flashed to `md1img_a` only, but **we had no SIM to verify the
> unlock**. Treat the modem step as experimental.
>
> The release does **not** contain `md1img`. It is device-unique (IMEI/calibration
> data) and must not be published or shared. Use the tool on **your own** stock
> `md1img` or the matching stock firmware for your exact build.

If a non-Tracfone SIM shows `gsm.sim.state = NETWORK_LOCKED`, use
[`andrewwm/vegas-freedom`](https://github.com/andrewwm/vegas-freedom):

1. Get the stock `md1img` for your exact firmware build (from your backup or the
   matching firmware zip). The tested profile was `-4-2`; this phone is `-4-3` and the
   build is marked experimental.
2. Run `check`; require the **CANDIDATE MATCH** (3/3 CATI symbols, 8/8 microMIPS32
   signatures).
3. Run `build --experimental-relocate`; require the audit to pass
   (`entries=23 layout_ok=True integrity=True`, sub-images `hash_ok`/`rsa_ok`).
4. Flash **`md1img_a` only**:

```powershell
adb reboot bootloader
fastboot getvar securestate        # flashing_unlocked
fastboot flash md1img_a md1img_experimental_patched.signed.img
fastboot reboot
```

Never flash `md1img_b`, `preloader`, `lk`, `seccfg`, `gpt`, `efuse`, `nvram`,
`nvdata`, `protect1`, `protect2` or `persist` for the modem unlock.

5. Insert a **non-Tracfone physical SIM** and verify:

```powershell
adb shell getprop gsm.sim.state
# LOADED / LOADED,NOT_READY = registered; NETWORK_LOCKED = still locked
adb shell getprop gsm.sim.operator.alpha
adb shell getprop vendor.gsm.sim.slot.lock.device.lock.remain.count   # 5
```

Then set the APN and test data/SMS. VoLTE needs the LineageOS microG GSI's
`com.mediatek.ims`.

**IMEI caveat:** a network unlock and carrier IMEI activation are separate. A Verizon
MVNO may still reject the phone's IMEI because Straight Talk has not released it; an
AT&T/T-Mobile/GSM MVNO is more likely. This does not affect Wi-Fi use.

### Revert the modem

```powershell
fastboot flash md1img_a md1img_stock_trimmed.img
```

The stock full `md1img_a.img` backup is also valid. Full details:
[`docs/07-modem-unlock.md`](docs/07-modem-unlock.md).

## 10. Revert / restore

Do not relock the bootloader with modified `lk`/`init_boot`.

- **Recovery:** flash stock `vendor_boot_a.img`.
- **GSI:** from fastbootd, flash your stock `super.img`; then reflash stock
  `vbmeta`/`vbmeta_system` **without** the disable-verity flags.
- **Root:** restore stock `init_boot_a.img` (from Android via `dd`, or your backup).
- **Modem:** flash the stock `md1img_a` image.
- **After any stock system restore:** do a stock recovery factory reset.

Keep the raw backups from step 4. A recovery nandroid is convenient, but the raw
`super.img` is the authoritative GSI revert.

## 11. Release files

Release: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery/releases/tag/2026-11-22>

| Asset | What it is |
|---|---|
| `Moto-G-Power-2026-XT2617V-flash-kit-2026-11-22.zip` | One download: three recoveries, stock `vendor_boot_a`, GSI `.xz`, this walkthrough, docs, modem tool and checksums |
| `Moto-G-Power-2026-XT2617V-recovery-pack-2026-11-22.zip` | Recoveries only, with stock revert and checksums |
| `OrangeFox-R12.0-vegas26.img` | OrangeFox 12.1, 17/17 + sideload |
| `TWRP-3.7.1-12-vegas26.img` | TWRP 12.1, 17/17 |
| `PBRP-4.x-vegas26.img` | PBRP 12.1, 17/17 |
| `LineageOS-23.2-2026.11.18-microG-gsi.img.xz` | Tested Android 16 microG GSI |
| `SHA256SUMS-2026-11-22.txt` | Hashes of the release files |
| `vegas_ofox_base.img`, `vegas_ofox_fixed.img` | XDA base and fixed fallback recovery |

The flash kit contains **no** `md1img`, `nvram`, `nvdata`, `seccfg`, `persist`, `frp`,
`protect*`, `super.img`, IMEI, serial or unlock keys. The modem tool patches **your**
stock image.

## 12. Troubleshooting and references

- [`docs/04-troubleshooting.md`](docs/04-troubleshooting.md) — recovery entry, fastboot
  drivers, touch/display, the GSI bootloop, revert.
- [`docs/01-backups.md`](docs/01-backups.md) — exact backup/restore commands.
- [`docs/07-modem-unlock.md`](docs/07-modem-unlock.md) — modem detail and the
  no-SIM caveat.
- [`docs/09-recovery-choices.md`](docs/09-recovery-choices.md) — pick a recovery.
- [`docs/11-recovery-test-results.md`](docs/11-recovery-test-results.md) — 17/17
  matrix and sideload result.
- Source/build: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery-source>
- Original complete guide: <https://github.com/qfertig/vegas26-gsi>
- Base Walmart/Straight Talk WiFi + root guide:
  <https://github.com/parsimo2010/moto-g-power-2026-straight-talk-wifi-root-guide>
- `vegas-freedom` modem/LK tools: <https://github.com/andrewwm/vegas-freedom>
- XDA Walmart-special thread:
  <https://xdaforums.com/t/moto-g-power-2026-xt2617v-walmart-special-root-modem-unlock-bypass-unlocked-bootloader.4809158/>
- XDA recovery thread:
  <https://xdaforums.com/t/recovery-twrp-orangefox-moto-g-play-moto-g-2026.4799348/>

### The traps that cost the most time

- **Test DPC QR** is the way past the no-plan activation screen. Remove the
  device-owner role with the service command; do not just uninstall it.
- **`fastboot -w` is not a factory reset** for the first GSI boot. Use stock
  recovery's factory reset.
- **Recovery entry** is the bootloader menu, not `fastboot reboot recovery`.
- **Touch** needs the phone's own FT8725 module, not the recovery's bundled G Play
  module.
- **Magisk on `init_boot`** must be written from Android with `dd`; this unit rejects
  the fastboot write.
- **Do not relock** the bootloader, and do not flash `md1img_b`.
