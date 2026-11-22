# Fetch the latest LineageOS microG GSI into downloads/gsi and verify it.
# Usage:
#   .\scripts\fetch-gsi-update.ps1
#   .\scripts\fetch-gsi-update.ps1 -Decompress
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [switch]$Decompress
)
$ErrorActionPreference = 'Stop'

$rss     = 'https://sourceforge.net/projects/lineageos-4-microg/rss?path=/GSI/16'
$referer = 'https://sourceforge.net/projects/lineageos-4-microg/files/GSI/16/'
$dest    = Join-Path $RepoRoot 'downloads\gsi'
New-Item -ItemType Directory -Force -Path $dest | Out-Null

Write-Host '== Reading SourceForge RSS ==' -ForegroundColor Cyan
$raw = (Invoke-WebRequest -UseBasicParsing -Uri $rss -TimeoutSec 60).Content
$items = [regex]::Matches($raw, '<item>(.*?)</item>', [Text.RegularExpressions.RegexOptions]::Singleline)
$item = $items | Where-Object { $_.Value -match '\.img\.xz' } | Select-Object -First 1
if (-not $item) { throw 'No GSI .img.xz entry found in the RSS feed.' }

$name = [regex]::Match($item.Value, '<title><!\[CDATA\[.*?/([^/]+)\]\]></title>').Groups[1].Value
$md5  = [regex]::Match($item.Value, '<media:hash algo="md5">([0-9a-f]+)</media:hash>').Groups[1].Value
if (-not $name -or -not $md5) { throw 'Could not parse the file name or MD5 from the RSS feed.' }

$out = Join-Path $dest $name
Write-Host "Latest: $name"
Write-Host "MD5:    $md5"

if (Test-Path $out) {
    $have = (Get-FileHash -LiteralPath $out -Algorithm MD5).Hash.ToLower()
    if ($have -eq $md5) {
        Write-Host "Already present and verified: $out" -ForegroundColor Green
    } else {
        Write-Host 'Existing file has a different hash; re-downloading.' -ForegroundColor Yellow
        Remove-Item -LiteralPath $out -Force
    }
}

if (-not (Test-Path $out)) {
    Write-Host '== Resolving SourceForge mirror ==' -ForegroundColor Cyan
    $page = (Invoke-WebRequest -UseBasicParsing -Uri ($referer + $name + '/download') -TimeoutSec 60).Content
    $m = [regex]::Match($page, 'url=(https://downloads\.sourceforge\.net/[^"]+)')
    if (-not $m.Success) { throw 'Could not find the signed mirror URL on the SourceForge download page.' }
    $signed = $m.Groups[1].Value -replace '&amp;', '&'

    Write-Host '== Downloading ==' -ForegroundColor Cyan
    & curl.exe -L --fail --retry 3 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -e $referer -o $out $signed
    if ($LASTEXITCODE -ne 0) { throw "curl failed with exit code $LASTEXITCODE" }
}

$got = (Get-FileHash -LiteralPath $out -Algorithm MD5).Hash.ToLower()
if ($got -ne $md5) { throw "MD5 mismatch: expected $md5, got $got" }
Write-Host "Verified MD5: $got" -ForegroundColor Green

if ($Decompress) {
    $wsl = Get-Command wsl -ErrorAction SilentlyContinue
    if (-not $wsl) { throw 'WSL not found; decompress manually with: xz -d ' + $out }
    $drive = $out.Substring(0, 1).ToLower()
    $wslPath = '/mnt/' + $drive + ($out.Substring(2) -replace '\\', '/')
    Write-Host "== Decompressing $wslPath ==" -ForegroundColor Cyan
    & wsl -d Ubuntu-22.04 -u root -- xz -dkf $wslPath
    if ($LASTEXITCODE -ne 0) { throw 'xz decompression failed.' }
}

Write-Host ''
Write-Host 'Next steps:' -ForegroundColor Cyan
Write-Host '  1. Flash in fastbootd:  fastboot flash system ' + ($out -replace '\.xz$', '')
Write-Host '  2. Flash it in fastbootd as shown above.'
