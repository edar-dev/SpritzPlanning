#!/usr/bin/env bash
# Prefer FVM when installed; otherwise use flutter on PATH.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if command -v fvm >/dev/null 2>&1; then
  exec fvm flutter "$@"
fi
exec flutter "$@"
