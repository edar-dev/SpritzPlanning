#!/usr/bin/env bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ ! -f env.test.json ]; then
  cp env.test.json.example env.test.json
  echo "Created env.test.json from env.test.json.example."
  echo "Add SUPABASE_URL and SUPABASE_ANON_KEY for a TEST project (not production)."
  echo "See docs/TESTING.md"
  exit 1
fi

bash "$ROOT/scripts/check-flutter-version.sh"
bash "$ROOT/scripts/flutter.sh" pub get
bash "$ROOT/scripts/flutter.sh" gen-l10n

echo "Running integration test (Supabase)..."
bash "$ROOT/scripts/flutter.sh" test integration/room_flow_integration_test.dart \
  --dart-define-from-file=env.test.json
