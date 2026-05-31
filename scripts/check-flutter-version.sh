#!/usr/bin/env bash
# Verifies the active Flutter SDK matches the repo pin (FVM / CI / Vercel).
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

EXPECTED="${FLUTTER_VERSION:-}"
if [ -z "$EXPECTED" ] && [ -f .fvm/fvm_config.json ]; then
  EXPECTED="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' .fvm/fvm_config.json | head -1)"
fi
if [ -z "$EXPECTED" ] && [ -f .fvmrc ]; then
  EXPECTED="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' .fvmrc | head -1)"
fi
EXPECTED="${EXPECTED:-3.35.6}"

bash "$ROOT/scripts/flutter.sh" --version >/tmp/flutter-version.txt 2>&1 || true
ACTUAL="$(grep -E '^Flutter [0-9]' /tmp/flutter-version.txt | head -1 | awk '{print $2}')"

if [ -z "$ACTUAL" ]; then
  echo "ERROR: Could not read Flutter version. Install Flutter $EXPECTED or FVM (https://fvm.app)."
  exit 1
fi

if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "ERROR: Flutter version mismatch."
  echo "  Expected: $EXPECTED (see .fvm/fvm_config.json)"
  echo "  Actual:   $ACTUAL"
  echo "  Fix: fvm install && fvm use   OR install Flutter $EXPECTED manually"
  exit 1
fi

echo "OK: Flutter $ACTUAL matches pin $EXPECTED"
