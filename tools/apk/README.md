# Temporary + persistent root APKs

Unmodified upstream APKs used on the tested `XT2617V`:

| APK | Version | SHA-256 |
|---|---|---|
| `DFRoot_4.7.apk` | 4.7 | `9e193ffdaada8577e14a04fb19403256b3fa4991fae1331c7956e083c098a7b1` |
| `KernelSU_v3.3.1_32680-release.apk` | v3.3.1 | `b4a059ace71de2fa65cc7f12b1c58d55fc23ab25e057ee4230ce779742abe450` |
| `Magisk-v31.1.apk` | v31.1 | `89cefac0a318afa39fb3880c45c87b036c05bc1ebf02a7a715b7f8d7c26ac6e7` |

Sources and licences: [`../README.md`](../README.md) and [`../licenses/`](../licenses/).

## Tested use

1. Install **DFRoot 4.7** and **KernelSU 3.3.1**.
2. DFRoot → KernelSU as SU manager → **Launch Root once**.
3. KernelSU → Superuser → enable **Shell** (`com.android.shell`).
4. `adb shell su -c id` must return `uid=0`.
5. For persistent root, install **Magisk 31.1**, patch your own `init_boot_a.img`,
   and write it from Android with `dd`. This phone rejects
   `fastboot flash init_boot_a` with `Preflash validation failed`.

Full procedure: [`../../WALKTHROUGH.md`](../../WALKTHROUGH.md) sections 4 and 6.

These are not a universal root method. They depend on the tested Android 16 build;
do not run them on a different firmware and expect the same result.
