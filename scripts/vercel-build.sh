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

if [ -n "${VERCEL_GIT_COMMIT_SHA:-}" ]; then
  DART_DEFINES+=("--dart-define=GIT_SHA=$VERCEL_GIT_COMMIT_SHA")
elif [ -n "${GIT_SHA:-}" ]; then
  DART_DEFINES+=("--dart-define=GIT_SHA=$GIT_SHA")
fi

flutter build web \
  --release \
  --no-wasm-dry-run \
  --base-href /app/ \
  "${DART_DEFINES[@]}"

# Vercel serves /index.html before rewrites — root must be the marketing landing.
# Flutter assets live under /app/ so /app/*.js is not rewritten to HTML.
WEB="build/web"
APP="$WEB/app"
mkdir -p "$APP"

for item in assets canvaskit flutter_bootstrap.js flutter.js main.dart.js \
  flutter_service_worker.js version.json manifest.json; do
  if [ -e "$WEB/$item" ]; then
    mv "$WEB/$item" "$APP/"
  fi
done

if [ -d "$WEB/icons" ]; then
  mv "$WEB/icons" "$APP/icons"
fi

if [ -f "$WEB/favicon.png" ]; then
  cp "$WEB/favicon.png" "$APP/favicon.png"
fi

mv "$WEB/index.html" "$APP/index.html"
cp "$WEB/landing.html" "$WEB/index.html"

echo "Web package: landing at /, Flutter under /app/"
