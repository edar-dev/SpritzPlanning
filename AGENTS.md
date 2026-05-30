# SpritzPlanning — Guida per Agenti AI

## Stack

- **Frontend**: Flutter 3 + Dart + Material 3 (Web + Android)
- **Backend**: Supabase (PostgreSQL + Realtime + RPC)
- **State**: flutter_riverpod
- **Navigazione**: go_router

## Vincoli

- UI **solo italiano**, tema **bar/spritz**
- **Nessun login** — nickname + codice stanza
- Mutazioni via **RPC Supabase**, sync via **Realtime**

## Comandi

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
flutter run -d android --dart-define-from-file=env.json
flutter test
flutter analyze
flutter build web --dart-define-from-file=env.json
flutter build apk --dart-define-from-file=env.json
```

## Supabase

```bash
# Richiede Supabase CLI
supabase init
supabase db push          # applica migrations/
```

Migration iniziale: `supabase/migrations/001_initial_schema.sql`

Config env: copiare `env.json.example` → `env.json` con URL e anon key del progetto Supabase.

## Struttura

| Path | Ruolo |
|------|-------|
| `lib/core/` | Theme, stringhe, storage |
| `lib/data/` | Modelli, repository, providers |
| `lib/features/` | Schermate per feature |
| `lib/shared/widgets/` | Widget riutilizzabili |
| `supabase/migrations/` | Schema SQL + RPC |

## Glossario

Vedi `lib/core/constants/app_strings.dart` e skill `.cursor/skills/spritz-planning-domain/`.

## Regole Cursor

- `.cursor/rules/spritz-theme.mdc` — copy e palette
- `.cursor/rules/flutter-architecture.mdc` — pattern codice
- `.cursor/rules/supabase-realtime.mdc` — backend
