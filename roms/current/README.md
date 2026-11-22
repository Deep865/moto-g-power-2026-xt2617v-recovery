# Current local staging — updated 2026-11-22

Device: `XT2617V` / `vegas26`, slot `_a`, unlock `flashing_unlocked`.

| Image | Purpose | Size | SHA-256 |
|---|---|---|---|
| `LineageOS-23.2-2026.11.18-microG-gsi.img` | GSI on `system_a` | 3,071,406,080 | `dcefcb1920cd538a80d4a0120996278f0a8a33aacb7c0ee429c50e61f1818345` |
| `OrangeFox-R12.0-vegas26.img` | current working recovery on `vendor_boot_a` | 67,108,864 | `5714ece262c4aeeb399ffc05878d4af070bc161e6333a9e18875b130c4b3f9b7` |
| `vegas_ofox_fixed.img` | XDA-prebuilt fallback recovery | 67,108,864 | `ddcc59675552d31d5069925507312aa9128ce12911fff2980088eb664cd445d0` |

TWRP 3.7.1-12 and PBRP 4.x are equally working alternatives; download them from the
release.

Working state:
- Android 16 / LineageOS 23.2-20261118-UNOFFICIAL-GSI.
- `/data` encrypted; OrangeFox 12.1 decrypts it.
- Touch works (`ft8725` / `fts_ts` / event2).
- Wi-Fi backup phone, no SIM; the GSI does not unlock the modem.

Release: <https://github.com/Deep865/moto-g-power-2026-xt2617v-walmart-recovery/releases/tag/2026-11-22>

## Re-flash

GSI (fastbootd):

```powershell
fastboot reboot fastboot
fastboot flash system LineageOS-23.2-2026.11.18-microG-gsi.img
```

Recovery:

```powershell
fastboot flash vendor_boot_a OrangeFox-R12.0-vegas26.img
```

Do **not** use `fastboot -w` for the first `/data` wipe. Use stock recovery’s factory
reset (see `docs/03-gsi.md`).
