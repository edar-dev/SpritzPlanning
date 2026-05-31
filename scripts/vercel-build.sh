#!/usr/bin/env bash
set -eu

if [ ! -d flutter ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$(pwd)/flutter/bin"

flutter config --enable-web
flutter --version
flutter pub get

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
  "${DART_DEFINES[@]}"
