# SpritzPlanning

Scrum poker con tema spritz per team di sviluppatori. Flutter (Web + Android) + Supabase.

## Funzionalità

- Crea stanze ("Apri un locale") o unisciti con codice ("Entra al bancone")
- Nessun login — solo nickname
- Menu ordini (user stories), votazione con deck Fibonacci, reveal "Servizio!"
- Sync realtime tra partecipanti

## Setup

### 1. Supabase

1. Crea un progetto su [supabase.com](https://supabase.com)
2. Esegui la migration in `supabase/migrations/001_initial_schema.sql` (SQL Editor o `supabase db push`)
3. Copia URL e anon key

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
