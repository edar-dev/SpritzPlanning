#!/usr/bin/env bash
set -eu

# Vercel Ignored Build Step: exit 0 = skip build, exit 1 = build.
# https://vercel.com/docs/project-configuration#ignored-build-step

if [ "${VERCEL_FORCE_BUILD:-}" = "1" ]; then
  echo "VERCEL_FORCE_BUILD=1 — building"
  exit 1
fi

# Returns 0 if the file is under a deployable path.
is_deployable_path() {
  case "$1" in
    lib/*|lib) return 0 ;;
    web/*|web) return 0 ;;
    assets/*|assets) return 0 ;;
    pubspec.yaml|pubspec.lock|l10n.yaml|analysis_options.yaml) return 0 ;;
    scripts/vercel-build.sh|vercel.json|.fvmrc) return 0 ;;
  esac
  return 1
}

PREV="${VERCEL_GIT_PREVIOUS_SHA:-}"
CURRENT="${VERCEL_GIT_COMMIT_SHA:-HEAD}"

if [ -z "$PREV" ]; then
  if git rev-parse "${CURRENT}^" >/dev/null 2>&1; then
    PREV="$(git rev-parse "${CURRENT}^")"
  else
    echo "No previous commit — building"
    exit 1
  fi
fi

CHANGED="$(git diff --name-only "$PREV" "$CURRENT" 2>/dev/null || true)"

if [ -z "$CHANGED" ]; then
  echo "No diff — building to be safe"
  exit 1
fi

while IFS= read -r file; do
  [ -z "$file" ] && continue
  if is_deployable_path "$file"; then
    echo "Deployable change: $file — building"
    exit 1
  fi
done <<< "$CHANGED"

echo "Only non-deployable paths changed — skipping Vercel build:"
echo "$CHANGED"
exit 0
