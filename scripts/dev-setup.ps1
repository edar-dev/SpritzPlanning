# SpritzPlanning one-command dev bootstrap (Windows).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

Write-Host "==> SpritzPlanning dev setup"
& "$Root/scripts/check-flutter-version.ps1"

if (-not (Test-Path "env.json")) {
    Copy-Item "env.json.example" "env.json"
    Write-Host "Created env.json from env.json.example - add SUPABASE_URL and SUPABASE_ANON_KEY (see env.json.example.md)."
} else {
    Write-Host "env.json present."
}

& "$Root/scripts/flutter.ps1" pub get
& "$Root/scripts/flutter.ps1" gen-l10n

Write-Host ""
Write-Host "Supabase project: eyvfsgzbrdibheyejikf (eu-central-1)"
Write-Host "Dashboard: https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf"
Write-Host "Migrations: supabase db push (requires Supabase CLI + link)"
Write-Host ""
Write-Host "Run app:"
Write-Host "  .\scripts\flutter.ps1 run -d chrome --dart-define-from-file=env.json"
Write-Host ""
Write-Host "Optional: lefthook install - see docs/CONTRIBUTING.md"
