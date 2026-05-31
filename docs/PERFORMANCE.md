# Performance — SpritzPlanning Web

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
