# Next — stage the next update here

Put the **next** GSI image here before flashing. Nothing in this folder is committed;
`*.img` and `*.xz` are gitignored.

## Fast path

```powershell
.\scripts\fetch-gsi-update.ps1
```

It reads the SourceForge RSS, downloads the latest
`LineageOS-*-microG-gsi.img.xz` into this folder, verifies the published MD5, and
decompresses it if WSL is available.

## Manual path

1. Open <https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/>
2. Download the latest `LineageOS-…-microG-gsi.img.xz` and note the MD5.
3. Verify:
   ```powershell
   Get-FileHash .\LineageOS-*.img.xz -Algorithm MD5
   ```
4. Decompress:
   ```bash
   xz -d LineageOS-*.img.xz
   ```
5. Flash in fastbootd:
   ```powershell
   fastboot flash system .\LineageOS-*.img
   ```
6. If it works, move the old `current/` images to `archive/`, move this image to
   `current/`, and update `current/SHA256SUMS.txt`.

No `/data` wipe is needed for a GSI update once `/data` was formatted by stock recovery
the first time.
