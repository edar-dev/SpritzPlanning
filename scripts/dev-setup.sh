#!/usr/bin/env bash
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> SpritzPlanning dev setup"
bash "$ROOT/scripts/check-flutter-version.sh"

if [ ! -f env.json ]; then
  cp env.json.example env.json
  echo "Created env.json from env.json.example — add SUPABASE_URL and SUPABASE_ANON_KEY (see env.json.example.md)."
else
  echo "env.json present."
fi

bash "$ROOT/scripts/flutter.sh" pub get
bash "$ROOT/scripts/flutter.sh" gen-l10n

echo ""
echo "Supabase project: eyvfsgzbrdibheyejikf (eu-central-1)"
echo "Dashboard: https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf"
echo "Migrations: supabase db push  (requires Supabase CLI + link)"
echo ""
echo "Run app:"
echo "  bash scripts/flutter.sh run -d chrome --dart-define-from-file=env.json"
echo ""
echo "Optional: lefthook install  (see docs/CONTRIBUTING.md)"
