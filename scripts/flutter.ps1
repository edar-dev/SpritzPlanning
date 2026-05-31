# Prefer FVM when installed; otherwise use flutter on PATH.
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FlutterArgs
)

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (Get-Command fvm -ErrorAction SilentlyContinue) {
    & fvm flutter @FlutterArgs
    exit $LASTEXITCODE
}

& flutter @FlutterArgs
exit $LASTEXITCODE
