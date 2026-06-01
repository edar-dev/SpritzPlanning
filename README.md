# SpritzPlanning

Scrum poker con tema spritz per team di sviluppatori. Flutter (Web + Android) + Supabase.

## Funzionalità

- Crea stanze ("Apri un locale") o unisciti con codice ("Entra al bancone")
- Nessun login — solo nickname
- Menu ordini (user stories), votazione con deck Fibonacci, reveal "Servizio!"
- Sync realtime tra partecipanti

## Quick start

**Flutter 3.35.6** (pin del repo). Consigliato [FVM](https://fvm.app): `fvm install && fvm use`.

**Windows:**

```powershell
.\scripts\dev-setup.ps1
.\scripts\flutter.ps1 run -d chrome --dart-define-from-file=env.json
```

**Linux / macOS:**

```bash
bash scripts/dev-setup.sh
bash scripts/flutter.sh run -d chrome --dart-define-from-file=env.json
```

Senza FVM: installa Flutter 3.35.6 e verifica con `scripts/check-flutter-version.ps1`.

- Credenziali: [env.json.example.md](env.json.example.md) → copia in `env.json`
- Hook git: [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) (`lefthook install`)
- Dev Container: [.devcontainer/README.md](.devcontainer/README.md)

Guida agenti: [AGENTS.md](AGENTS.md) · Playbook: [docs/AGENT-PLAYBOOK.md](docs/AGENT-PLAYBOOK.md)

## Setup (dettaglio)

### Supabase

Progetto cloud: **SpritzPlanning** (`eyvfsgzbrdibheyejikf`, regione `eu-central-1`)

- Dashboard: https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf
- Migrations (in ordine): `001`–`011` (vedi [supabase/README.md](supabase/README.md)); su `main` applicate da CI se configurato `SUPABASE_ACCESS_TOKEN`

## Build

```bash
flutter build web --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
```

## Deploy (Vercel)

- **Produzione**: https://spritz-planning.vercel.app
- **Dashboard**: https://vercel.com/edar-devs-projects/spritz-planning
- Repo collegato a GitHub: `edar-dev/SpritzPlanning`

Variabili d'ambiente configurate su Vercel (Production + Development):

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Il build usa `scripts/vercel-build.sh` (installa Flutter su Linux e compila la web app).

## Roadmap

Panoramica: [docs/ROADMAP.md](docs/ROADMAP.md)

| Fase | Piano |
|------|--------|
| 1–4 | [Sicurezza/CI](docs/plans/phase-1-security-ci.md) · [Realtime](docs/plans/phase-2-realtime.md) · [Lobby/voto](docs/plans/phase-3-lobby-voting-ux.md) · [PWA/E2E](docs/plans/phase-4-quality-pwa.md) |
| 5–7 | [Produzione](docs/plans/phase-5-production-value.md) · [Sessione](docs/plans/phase-6-session-ux.md) · [Reach/polish](docs/plans/phase-7-reach-polish.md) |
| 8–10 | [Agent docs](docs/plans/phase-8-agent-docs.md) · [Toolchain](docs/plans/phase-9-dev-toolchain.md) · [Quality gates](docs/plans/phase-10-quality-gates.md) |

Miglioramenti DX (#21–30): [docs/IMPROVEMENTS-DX.md](docs/IMPROVEMENTS-DX.md)

Miglioramenti prod / production-ready (#31–40): [docs/IMPROVEMENTS-PROD.md](docs/IMPROVEMENTS-PROD.md)

## Sicurezza

- Le **mutazioni** (crea locale, join, voti, reveal, ecc.) passano solo tramite **RPC** `SECURITY DEFINER`; le policy RLS non consentono INSERT/UPDATE/DELETE diretti con la chiave `anon`.
- Le **letture** restano aperte su `SELECT` per Realtime e sincronizzazione stato.
- **Rate limit**: massimo 20 creazioni locale (`create_room`) per ora (limite globale).
- **Nickname**: un solo cliente attivo per nickname nella stessa stanza; dopo `leave_room` o ~2 min senza heartbeat si può rientrare con lo stesso nome (`join_room`).
- **Voti**: solo valori del deck Fibonacci ammessi in `cast_vote`.

## Dati e retention

- Ogni attività aggiorna `last_activity_at` sulla stanza.
- Le stanze **inattive da più di 24 ore** possono essere eliminate con `cleanup_stale_rooms(24)` (cascade su partecipanti, ordini, voti).
- Per cleanup automatico: applica la migration `004_pg_cron.sql` (vedi [supabase/README.md](supabase/README.md)).

## CI

Su push/PR verso `main`, GitHub Actions esegue `flutter analyze`, `flutter test` e un build web di verifica (`.github/workflows/ci.yml`).

Opzionale in produzione: `SENTRY_DSN` in Vercel per error reporting (vedi `env.json.example`).

## Test

```bash
scripts/flutter.ps1 test              # Windows — unit/widget
scripts/flutter.sh analyze --fatal-infos
```

Guida completa: [docs/TESTING.md](docs/TESTING.md) · [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)

### Test integrazione (Supabase)

Progetto test dedicato + `env.test.json` (da `env.test.json.example`):

```powershell
.\scripts\run-integration.ps1
```

CI: secrets `SUPABASE_URL_TEST` / `SUPABASE_ANON_KEY_TEST`; workflow settimanale [integration.yml](.github/workflows/integration.yml).

## Installa come app (PWA)

La build web è una **Progressive Web App** installabile:

1. Apri https://spritz-planning.vercel.app in Chrome (desktop o Android)
2. Quando disponibile, usa il banner **Installa** in home oppure il menu del browser → *Installa app* / *Aggiungi a schermata Home*
3. Su iOS Safari: Condividi → *Aggiungi a Home*

Il manifest e il service worker Flutter sono in `web/manifest.json`; Vercel invia `Cache-Control: no-cache` su `flutter_service_worker.js` per evitare cache obsoleta.

## Terminologia

| Scrum | SpritzPlanning |
|-------|----------------|
| Room | Locale |
| Facilitator | Barman |
| User story | Ordine |
| Vote | Dose |
| Reveal | Servizio! |
