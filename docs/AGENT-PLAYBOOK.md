# Agent Playbook — SpritzPlanning

**Ultimo aggiornamento:** 2026-05-31 (Fase 10)

Checklist operativa per agenti AI e contributor. Per stack e comandi vedi [AGENTS.md](../AGENTS.md).

---

## 1. Prima di iniziare

- [ ] Leggere [AGENTS.md](../AGENTS.md)
- [ ] Identificare fase in [ROADMAP.md](ROADMAP.md) e piano in [docs/plans/](plans/)
- [ ] Branch: `feat/…` (feature), `chore/…` (tooling/doc), `fix/…` (bugfix)
- [ ] **Non** creare commit/push salvo richiesta esplicita dell’utente

Skill consigliata: `.cursor/skills/phase-delivery/SKILL.md`

---

## 2. Ambiente locale

```powershell
# Windows
.\scripts\dev-setup.ps1
```

```bash
# Linux / macOS / Dev Container
bash scripts/dev-setup.sh
```

| Requisito | Valore |
|-----------|--------|
| Flutter | **3.35.6** — FVM (`.fvm/fvm_config.json`) o install manuale |
| Verifica versione | `scripts/check-flutter-version.sh` |
| Config run | `--dart-define-from-file=env.json` |
| Env | [env.json.example.md](../env.json.example.md) |
| Hook | `lefthook install` — vedi [CONTRIBUTING.md](CONTRIBUTING.md) |
| Launch VS Code | `.vscode/launch.json` (Chrome / Android / test senza env) |

---

## 3. Database (Supabase)

| Regola | Dettaglio |
|--------|-----------|
| Progetto | `eyvfsgzbrdibheyejikf` · `eu-central-1` |
| Migration | Solo file in `supabase/migrations/` — **001 → 009** in ordine |
| Applicazione | `supabase db push` oppure MCP Supabase / SQL Editor con contenuto del file |
| Vietato | Schema o RPC “a mano” senza migration versionata |

Dopo nuova migration nel PR, indicare in descrizione: **migration applicata su progetto cloud: sì/no**.

Elenco migration: [supabase/README.md](../supabase/README.md)

---

## 4. Verifica pre-PR

```bash
scripts/flutter.sh gen-l10n
scripts/flutter.sh analyze --fatal-infos
scripts/flutter.sh test
```

Se hai modificato ARB o UI:

- [ ] Switch IT/EN in app (home → selettore lingua)
- [ ] Dark mode leggibile su schermate toccate

Se hai modificato `integration/`:

- [ ] `scripts/run-integration.ps1` con `env.test.json` (progetto test, non produzione)

---

## 5. Vercel (Preview e build)

| Variabile | Scope Preview |
|-----------|----------------|
| `SUPABASE_URL` | Tutti i branch Preview (non solo un branch nominato) |
| `SUPABASE_ANON_KEY` | Idem |
| `SENTRY_DSN` | Opzionale |

Build: `scripts/vercel-build.sh` — Flutter **3.35.6**, `flutter gen-l10n`, `flutter build web --no-wasm-dry-run`.

Cache statica: `vercel.json` (`/canvaskit/`, `/assets/`).

Se Preview fallisce con errore Supabase/env → controllare dashboard Vercel → Environment Variables → Preview.

---

## 6. Produzione

1. PR verso `main` con CI verde (analyze + test + build web)
2. Merge (squash o merge commit secondo convenzione repo)
3. Verificare deploy Vercel **READY** su https://spritz-planning.vercel.app
4. Se il PR include migration: confermare applicata su progetto production **prima** o **subito dopo** merge

---

## 7. Android App Links

File: `web/.well-known/assetlinks.json`

- Debug keystore SHA256 già in `assetlinks.json` (build debug/local)
- Sostituire `REPLACE_WITH_RELEASE_SHA256_FINGERPRINT` con fingerprint **release** keystore per APK store
- Host: dominio Vercel produzione (`spritz-planning.vercel.app`)
- Manifest: `android/app/src/main/AndroidManifest.xml` intent-filter verified

---

## 8. Handoff (commit / PR)

Includere sempre:

| Campo | Esempio |
|-------|---------|
| Fase / issue | Fase 8 — agent docs |
| Migration | 009 già su cloud / N/A |
| Test eseguiti | `flutter test`, `flutter analyze` |
| Deploy | Preview URL se disponibile |
| Note | assetlinks da aggiornare, env Vercel, ecc. |

Template PR: [.github/pull_request_template.md](../.github/pull_request_template.md)

---

## Riferimenti (non duplicare qui)

| Argomento | File |
|-----------|------|
| Performance / Lighthouse | [PERFORMANCE.md](PERFORMANCE.md) |
| Test (unit + integration) | [TESTING.md](TESTING.md) |
| Sicurezza RLS/RPC | [supabase/README.md](../supabase/README.md) |
| Roadmap | [ROADMAP.md](ROADMAP.md) |
