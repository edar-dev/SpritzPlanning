# Verifies the active Flutter SDK matches the repo pin (FVM / CI / Vercel).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$Expected = $env:FLUTTER_VERSION
if (-not $Expected -and (Test-Path ".fvm/fvm_config.json")) {
    $json = Get-Content ".fvm/fvm_config.json" -Raw | ConvertFrom-Json
    $Expected = $json.flutterSdkVersion
}
if (-not $Expected -and (Test-Path ".fvmrc")) {
    if ((Get-Content ".fvmrc" -Raw) -match '([0-9]+\.[0-9]+\.[0-9]+)') {
        $Expected = $Matches[1]
    }
}
if (-not $Expected) { $Expected = "3.35.6" }

$versionOutput = & "$Root/scripts/flutter.ps1" --version 2>&1 | Out-String
$match = [regex]::Match($versionOutput, 'Flutter\s+([0-9]+\.[0-9]+\.[0-9]+)')
if (-not $match.Success) {
    Write-Error "Could not read Flutter version. Install Flutter $Expected or FVM (https://fvm.app)."
}

$Actual = $match.Groups[1].Value
if ($Actual -ne $Expected) {
    Write-Host "ERROR: Flutter version mismatch."
    Write-Host "  Expected: $Expected (see .fvm/fvm_config.json)"
    Write-Host "  Actual:   $Actual"
    Write-Host "  Fix: fvm install; fvm use   OR install Flutter $Expected manually"
    exit 1
}

Write-Host "OK: Flutter $Actual matches pin $Expected"
