# Run Supabase integration test (requires env.test.json).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not (Test-Path "env.test.json")) {
    Copy-Item "env.test.json.example" "env.test.json"
    Write-Host "Created env.test.json from env.test.json.example."
    Write-Host "Add SUPABASE_URL and SUPABASE_ANON_KEY for a TEST project (not production)."
    Write-Host "See docs/TESTING.md"
    exit 1
}

& "$Root/scripts/check-flutter-version.ps1"
& "$Root/scripts/flutter.ps1" pub get
& "$Root/scripts/flutter.ps1" gen-l10n

Write-Host "Running integration test (Supabase)..."
& "$Root/scripts/flutter.ps1" test integration/room_flow_integration_test.dart `
    --dart-define-from-file=env.test.json
exit $LASTEXITCODE
