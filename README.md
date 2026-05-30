# SpritzPlanning

Scrum poker con tema spritz per team di sviluppatori. Flutter (Web + Android) + Supabase.

## Funzionalità

- Crea stanze ("Apri un locale") o unisciti con codice ("Entra al bancone")
- Nessun login — solo nickname
- Menu ordini (user stories), votazione con deck Fibonacci, reveal "Servizio!"
- Sync realtime tra partecipanti

## Setup

### 1. Supabase

Progetto cloud: **SpritzPlanning** (`eyvfsgzbrdibheyejikf`, regione `eu-central-1`)

- Dashboard: https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf
- Migration già applicata: `initial_schema` (tabelle, RPC, RLS, Realtime)

Per sviluppo locale, copia le credenziali in `env.json`:

```bash
cp env.json.example env.json
# Inserisci SUPABASE_URL e SUPABASE_ANON_KEY dalla dashboard → Settings → API
```

### 2. Configurazione locale

```bash
cp env.json.example env.json
# Modifica env.json con SUPABASE_URL e SUPABASE_ANON_KEY
```

### 3. Run

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
flutter run -d android --dart-define-from-file=env.json
```

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

Piani di miglioramento (punti 1–9): [docs/ROADMAP.md](docs/ROADMAP.md)

- [Fase 1 — Sicurezza, CI, cleanup](docs/plans/phase-1-security-ci.md)
- [Fase 2 — Realtime resiliente](docs/plans/phase-2-realtime.md)
- [Fase 3 — UX lobby e votazione](docs/plans/phase-3-lobby-voting-ux.md)
- [Fase 4 — Test e PWA](docs/plans/phase-4-quality-pwa.md)

## Test

```bash
flutter test
flutter analyze
```

## Terminologia

| Scrum | SpritzPlanning |
|-------|----------------|
| Room | Locale |
| Facilitator | Barman |
| User story | Ordine |
| Vote | Dose |
| Reveal | Servizio! |
