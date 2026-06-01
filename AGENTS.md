# SpritzPlanning — Guida per Agenti AI

**Ultimo aggiornamento:** Fase 8 (agent DX, doc allineata post–Fase 7).

## Stack

- **Frontend**: Flutter 3.35.6 + Dart + Material 3 (Web + Android)
- **Backend**: Supabase (PostgreSQL + Realtime + RPC)
- **State**: flutter_riverpod
- **Navigazione**: go_router
- **i18n**: `flutter gen-l10n` — IT (default), EN
- **Osservabilità**: Sentry (opzionale via `SENTRY_DSN`)

## Vincoli

- UI **IT/EN** con tema **bar/spritz** (terminologia bancone, no Scrum in copy)
- **Nessun login** — nickname + codice stanza
- Mutazioni via **RPC Supabase**, sync via **Realtime**
- **Dark mode** e **deck personalizzabile** per locale (migration 009)

## UI e stringhe

- Testi: `lib/l10n/app_it.arb`, `lib/l10n/app_en.arb`
- In widget: `context.l10n` (`lib/core/l10n/l10n_extensions.dart`)
- Import: `package:spritz_planning/l10n/app_localizations.dart`
- **Non** usare `app_strings.dart` (rimosso in Fase 8)
- Dopo modifica ARB: `flutter gen-l10n`

## Toolchain

- **Flutter 3.35.6** — `.fvm/fvm_config.json`; preferire FVM (`fvm use`)
- Bootstrap: `scripts/dev-setup.ps1` / `scripts/dev-setup.sh`
- Wrapper: `scripts/flutter.ps1` / `scripts/flutter.sh` (usa FVM se presente)
- Contributi: [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)

## Comandi

```bash
# Dopo dev-setup (o manualmente):
scripts/flutter.sh pub get
scripts/flutter.sh gen-l10n
scripts/flutter.sh run -d chrome --dart-define-from-file=env.json
scripts/flutter.sh test
scripts/flutter.sh analyze --fatal-infos
scripts/flutter.sh build web --dart-define-from-file=env.json
```

## Supabase

- **Progetto:** `eyvfsgzbrdibheyejikf` (eu-central-1)
- Dashboard: https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf

```bash
supabase link --project-ref eyvfsgzbrdibheyejikf
supabase db push
```

Migration **001–009** in ordine — tabella in [supabase/README.md](supabase/README.md).

Config locale: `env.json.example` → `env.json` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, opzionale `SENTRY_DSN`).

## Struttura

| Path | Ruolo |
|------|-------|
| `lib/core/` | Theme, l10n extensions, storage, constants |
| `lib/l10n/` | ARB + file generati da gen-l10n |
| `lib/data/` | Modelli, repository, providers |
| `lib/features/` | Schermate per feature |
| `lib/shared/widgets/` | Widget riutilizzabili |
| `supabase/migrations/` | Schema SQL + RPC |
| `docs/` | Roadmap, piani, playbook |
| `scripts/vercel-build.sh` | Build produzione (Flutter 3.35.6 pin) |

## Roadmap e delivery

- Panoramica: [docs/ROADMAP.md](docs/ROADMAP.md)
- Piani per fase: [docs/plans/](docs/plans/)
- Miglioramenti DX (#21–30): [docs/IMPROVEMENTS-DX.md](docs/IMPROVEMENTS-DX.md)
- Miglioramenti prod (#31–40, fasi 11–12): [docs/IMPROVEMENTS-PROD.md](docs/IMPROVEMENTS-PROD.md)
- **Playbook operativo:** [docs/AGENT-PLAYBOOK.md](docs/AGENT-PLAYBOOK.md)

Prima di feature non banali: leggere il piano di fase e seguire la skill `phase-delivery`.

## Glossario e dominio

- Terminologia bar: skill `.cursor/skills/spritz-planning-domain/`
- Chiavi UI: `lib/l10n/app_it.arb` (template ARB)

## Regole e skill Cursor

| Risorsa | Uso |
|---------|-----|
| `.cursor/rules/spritz-theme.mdc` | Palette, copy, l10n |
| `.cursor/rules/l10n.mdc` | Nessuna stringa hardcoded in UI |
| `.cursor/rules/flutter-architecture.mdc` | Pattern codice |
| `.cursor/rules/supabase-realtime.mdc` | Backend |
| `.cursor/skills/phase-delivery/` | Branch → piano → PR → deploy |
| `.cursor/skills/supabase-migrations/` | Nuove migration SQL |
| `.cursor/skills/spritz-planning-domain/` | Flussi poker / barman |

## Deploy

- Produzione: https://spritz-planning.vercel.app
- Preview: env `SUPABASE_URL` + `SUPABASE_ANON_KEY` su **tutti** i branch Preview
- Dettagli: [docs/AGENT-PLAYBOOK.md](docs/AGENT-PLAYBOOK.md), [docs/PERFORMANCE.md](docs/PERFORMANCE.md)
