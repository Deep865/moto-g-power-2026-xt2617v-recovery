# Archive — previous working images

Keep the last known-good GSI/recovery here for rollback. Images are gitignored.

| Image | Purpose | SHA-256 |
|---|---|---|
| `vegas_ofox_base.img` | original XDA OrangeFox base (before the FT8725 module repack) | `4664f5638791c62b948593597cef52ec8ed7b5a8d75623d290ca8e6b0835a0aa` |

When you update:
1. Move the old `current/` images here with a date suffix, e.g.
   `LineageOS-23.2-2026.11.18-microG-gsi.img` → `archive/`.
2. Update this folder’s `SHA256SUMS.txt`.
3. Move the tested new image into `current/`.

Never archive `nvram`, `nvdata`, `seccfg`, `persist`, `frp`, `protect*`, `md1img`, or
`super.img` in a public repo; keep those in your private backups.
