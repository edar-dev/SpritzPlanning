# Performance — SpritzPlanning Web

**Toolchain:** Flutter **3.35.6** (CI `.github/workflows/ci.yml`, `scripts/vercel-build.sh`).

## Audit baseline

```bash
flutter build web --release --dart-define-from-file=env.json
npx lighthouse https://spritz-planning.vercel.app --view
```

## Target scores (PWA)

| Category | Target |
|----------|--------|
| PWA | ≥ 80 |
| Performance (mobile) | ≥ 70 |
| Accessibility | ≥ 90 |

## Ottimizzazioni applicate (Fase 7)

- `theme-color` e `preconnect` Supabase in `web/index.html`
- Service worker cache headers in `vercel.json`
- Flutter build release con tree-shaking icone
- Flutter **3.35.6** pin in `scripts/vercel-build.sh` (allineato a CI)
- Cache lunga su `/canvaskit/` e `/assets/` in `vercel.json`

## Log build Vercel (audit)

| Ambiente | Deploy | Esito | Compile web | Note |
|----------|--------|-------|-------------|------|
| Production | `2964c49` | READY | ~122s | Nessuna cache precedente; build ~3 min |
| Preview | redeploy | READY | ~84s | Env Supabase ok dopo fix globale Preview |

Warning benigni nei log: `flutter as root`, suggerimento Wasm dry-run (disabilitato con `--no-wasm-dry-run`).

Runtime Vercel: nessun log serverless (app statica Flutter web).

Sentry (7g): nessun issue unresolved sul progetto `flutter`.

## Comandi utili

```bash
# Build locale
flutter build web --release --dart-define-from-file=env.json

# Analyze bundle size
du -sh build/web
```

## Note

- Lighthouse in CI è flaky; audit manuale documentato qui
- `--wasm` opzionale per sperimentazione, non usato in produzione
