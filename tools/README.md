# Root / unlock tools

Everything here is an **unmodified upstream release** or source tree, kept so this
project does not depend on a link staying alive. Verify hashes before running anything.

## APKs for temporary + persistent root

| File | Version | SHA-256 | Source | License |
|---|---|---|---|---|
| `apk/DFRoot_4.7.apk` | 4.7 | `9e193ffdaada8577e14a04fb19403256b3fa4991fae1331c7956e083c098a7b1` | <https://github.com/diabl0w/DFRoot/releases/tag/v4.7> | GPL-2.0 |
| `apk/KernelSU_v3.3.1_32680-release.apk` | v3.3.1 (32680) | `b4a059ace71de2fa65cc7f12b1c58d55fc23ab25e057ee4230ce779742abe450` | <https://github.com/tiann/KernelSU/releases/tag/v3.3.1> | GPL-3.0 |
| `apk/Magisk-v31.1.apk` | v31.1 | `89cefac0a318afa39fb3880c45c87b036c05bc1ebf02a7a715b7f8d7c26ac6e7` | <https://github.com/topjohnwu/Magisk/releases/tag/v31.1> | GPL-3.0 |

The tested sequence is in [`../WALKTHROUGH.md`](../WALKTHROUGH.md):

- DFRoot + KernelSU for temporary root and Shell access;
- Magisk 31.1 for persistent root on `init_boot_a`.

These are **firmware-specific** tools. DFRoot depends on a vulnerable kernel; do not
run it on a different build expecting it to work. Install only on a phone you own.

## Unlock / modem source

| Directory | What it is | Source | License |
|---|---|---|---|
| `val-protocol/` | Patch your own `lk_a`, generate unlock keys | <https://github.com/Maikyxd/val-protocol> | AGPL-3.0 |
| `vegas-freedom/` | Check/build the `md1img` modem unlock, backup helpers | <https://github.com/andrewwm/vegas-freedom> | AGPL-3.0 |

Both are included with their licences in `licenses/`. Do not use another phone's
serial, keys or `md1img`.

## What is not here

- platform-tools (use 35.0.0 or 37.0.1; link in the walkthrough)
- the stock firmware, `md1img`, `super`, `nvram`, `nvdata`, `seccfg`, `persist`,
  `frp`, `protect*` or any device-unique backup
- Test DPC (Google's provisioning QR downloads it; see the walkthrough)
