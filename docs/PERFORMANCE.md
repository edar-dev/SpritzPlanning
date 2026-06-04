# Performance e accessibilità — SpritzPlanning

## Contrasto (Fase 13)

- Testo secondario: `AppColors.textSecondary` (#57534E) su bianco ≥ WCAG AA 4.5:1.
- Hint: `AppColors.textMuted` (#78716C) — solo placeholder, non copy critico.
- Home: barra preferenze su `surface`; tagline usa `textPrimary`.
- Card bianche: widget `LightSurfaceScope` / `SpritzSurfaceCard` — con tema scuro i form non devono ereditare campi scuri e testo chiaro sulla card.
- Obiettivo Lighthouse Accessibility: **≥ 90** su preview produzione (workflow CI `.github/workflows/lighthouse.yml`).

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

## PWA / service worker (Fase 22)

Con landing statica alla root e app sotto `/app/`, il build Vercel usa `--pwa-strategy=none` e `--no-source-maps` per evitare:

- precache del service worker su file marketing assenti in `/app/` (timeout 4s in Firefox);
- errori DevTools su `flutter.js.map` assente.

L’app resta installabile via `manifest.json`; la cache offline Flutter si può rivalutare in Fase 23 con manifest SW dedicato solo a `/app/`.

All’avvio, `web/index.html` disinstalla eventuali service worker legacy (una ricarica con `sessionStorage`). Dopo un deploy, se la console mostra ancora messaggi SW o `flutter.js.map` 404: **Ctrl+Shift+R** una volta su `/app/`.

Messaggi noti **non risolvibili in app** (sicuri da ignorare): `unreachable code` in `main.dart.js` (dart2js), `WEBGL_debug_renderer_info` (CanvasKit/Firefox), cookie `__cf_bm` su WebSocket Supabase (Cloudflare).

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

## Lighthouse CI (Fase 16, #77)

Workflow `.github/workflows/lighthouse.yml` su push/PR verso `main`: build web release, audit con [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci) (config `.github/lighthouse/lighthouserc.json`).

Soglie minime in CI:

| Category | Min score |
|----------|-----------|
| Performance | 0.6 |
| Accessibility | 0.85 |
| Best Practices | 0.8 |
| PWA | 0.5 |

Audit manuale consigliato prima del release; la CI serve come regressione su build preview.

## Note

- `--wasm` opzionale per sperimentazione, non usato in produzione
