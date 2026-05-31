# Set GitHub Actions secrets for integration tests from env.json or env.test.json.
# Requires: gh auth login  (https://cli.github.com/)
# Usage: .\scripts\configure-github-secrets.ps1
#        .\scripts\configure-github-secrets.ps1 -EnvFile env.test.json

param(
    [string]$EnvFile = "env.json",
    [string]$Repo = "edar-dev/SpritzPlanning"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "Install GitHub CLI: winget install GitHub.cli"
}

$auth = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Run first: gh auth login"
    Write-Host $auth
    exit 1
}

$path = Join-Path $Root $EnvFile
if (-not (Test-Path $path)) {
    Write-Error "Missing $EnvFile. Copy from env.json.example or env.test.json.example."
}

$config = Get-Content $path -Raw | ConvertFrom-Json
$url = $config.SUPABASE_URL
$key = $config.SUPABASE_ANON_KEY

if ([string]::IsNullOrWhiteSpace($url) -or [string]::IsNullOrWhiteSpace($key)) {
    Write-Error "SUPABASE_URL and SUPABASE_ANON_KEY must be set in $EnvFile"
}

Write-Host "Setting SUPABASE_URL_TEST and SUPABASE_ANON_KEY_TEST on $Repo ..."
$url | gh secret set SUPABASE_URL_TEST --repo $Repo
$key | gh secret set SUPABASE_ANON_KEY_TEST --repo $Repo

Write-Host "Done. Verify: gh secret list --repo $Repo"
Write-Host "Trigger integration workflow: gh workflow run integration.yml --repo $Repo"
