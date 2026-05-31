# Testing — SpritzPlanning

**Ultimo aggiornamento:** Fase 10

## Unit e widget test

```bash
# Windows
.\scripts\flutter.ps1 test

# Linux / macOS
bash scripts/flutter.sh test
```

Cartella: `test/` — non richiedono rete né Supabase.

Verifica locale completa:

```bash
bash scripts/flutter.sh gen-l10n
bash scripts/flutter.sh analyze --fatal-infos
bash scripts/flutter.sh test
```

## Integration test (Supabase)

File: `integration/room_flow_integration_test.dart`

Flusso E2E: crea locale → join → ordine → voto → reveal → stima → next.

### Prerequisiti

- Progetto Supabase **dedicato ai test** (consigliato), non produzione `eyvfsgzbrdibheyejikf`
- Rete verso Supabase
- `env.test.json` (non committare)

### Setup

```bash
cp env.test.json.example env.test.json
# Inserire SUPABASE_URL e SUPABASE_ANON_KEY del progetto test
```

### Note tecniche

Il test usa `TestWidgetsFlutterBinding` (richiesto da `supabase_flutter`) e imposta `HttpOverrides.global = null` in `setUpAll` così le richieste HTTP reali verso Supabase non vengono intercettate dal mock di `flutter_test` (che altrimenti risponde sempre 400). L’inizializzazione usa `initializeSupabase(forIntegrationTest: true)` con storage auth in memoria.

### Esecuzione

**Windows:**

```powershell
.\scripts\run-integration.ps1
```

**Linux / macOS:**

```bash
bash scripts/run-integration.sh
```

Equivalente manuale:

```bash
flutter test integration/room_flow_integration_test.dart \
  --dart-define-from-file=env.test.json
```

Se `env.test.json` manca, lo script copia l’example e esce con istruzioni.

### Cleanup stanze test

Il test crea stanze con nome `IT-<timestamp>`. Per pulizia manuale su progetto test:

```sql
-- SQL Editor (progetto test only)
DELETE FROM rooms WHERE name LIKE 'IT-%';
```

Oppure attendere `cleanup_stale_rooms(24)` se pg_cron attivo.

### Agenti AI

- Non eseguire integration in loop contro produzione
- Non committare `env.test.json`
- Preferire progetto test separato documentato nel playbook

## CI

| Workflow | Quando | Secrets |
|----------|--------|---------|
| [ci.yml](../.github/workflows/ci.yml) | ogni PR/push `main` | `SUPABASE_URL_TEST`, `SUPABASE_ANON_KEY_TEST` (job integration su push main; skip se assenti) |
| [integration.yml](../.github/workflows/integration.yml) | `workflow_dispatch` + lunedì 06:00 UTC | stessi secrets |

Nomi secrets GitHub (Settings → Secrets → Actions):

- `SUPABASE_URL_TEST`
- `SUPABASE_ANON_KEY_TEST`

Configurazione automatica (dopo `gh auth login`):

```powershell
.\scripts\configure-github-secrets.ps1
# oppure da env.test.json:
.\scripts\configure-github-secrets.ps1 -EnvFile env.test.json
```

Valori da progetto Supabase **SpritzPlanning** (`eyvfsgzbrdibheyejikf`) via dashboard o MCP. Per isolamento completo, creare un secondo progetto Supabase e usare le sue credenziali in `env.test.json`.

Run manuale: Actions → **Integration (scheduled)** → Run workflow, oppure:

```bash
gh workflow run integration.yml --repo edar-dev/SpritzPlanning
```

## Riferimenti

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [AGENT-PLAYBOOK.md](AGENT-PLAYBOOK.md)
