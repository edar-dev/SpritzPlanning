#!/usr/bin/env bash
set -eu

# Align with CI (.github/workflows/ci.yml) to avoid analyze/build drift.
FLUTTER_VERSION="${FLUTTER_VERSION:-3.35.6}"

if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1
fi
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter --version
flutter pub get
flutter gen-l10n

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "ERROR: SUPABASE_URL and SUPABASE_ANON_KEY must be set in Vercel environment variables."
  exit 1
fi

DART_DEFINES=(
  "--dart-define=SUPABASE_URL=$SUPABASE_URL"
  "--dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
)

if [ -n "${SENTRY_DSN:-}" ]; then
  DART_DEFINES+=("--dart-define=SENTRY_DSN=$SENTRY_DSN")
fi

flutter build web \
  --release \
  --no-wasm-dry-run \
  "${DART_DEFINES[@]}"
