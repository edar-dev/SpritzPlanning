# Fase 1 — Sicurezza, manutenzione dati, CI

**Punti:** #1 Sicurezza RLS/RPC · #9 CI/CD · #3 Cleanup stanze  
**Branch suggerito:** `feat/security-and-ci`  
**Durata stimata:** 3–5 giorni

## Obiettivo

Ridurre la superficie d’attacco dell’API anonima, automatizzare qualità pre-deploy, pulire stanze inattive.

---

## #1 Sicurezza RLS e RPC

### Strategia

- Le **mutazioni** restano **solo via RPC** (come oggi in [`lib/data/repositories/room_repository.dart`](../../lib/data/repositories/room_repository.dart)).
- Le policy dirette su INSERT/UPDATE/DELETE diventano **restrittive** (o assenti).
- **SELECT** resta aperto per Realtime e `fetchRoomState`.

### Migration: `supabase/migrations/002_security_hardening.sql`

1. Rimuovere policy permissive su write per `rooms`, `participants`, `stories`, `votes`.
2. Mantenere `SELECT` su tutte le tabelle.
3. Aggiungere helper `assert_participant_in_room(p_participant_id, p_room_id)` usato in ogni RPC.
4. **Rate limit** su `create_room`: limite soft (es. max 20 room/ora via tabella/contatore).
5. Revocare `GRANT EXECUTE` su `touch_room` e `generate_room_code` per `anon` (solo interne).
6. `generate_room_code`: aggiungere `SET search_path = public`.

### Flutter

Nessun cambio previsto se tutte le write passano già dal repository.

### Verifica

- [ ] Supabase Database Linter: nessun errore critico su RLS permissive
- [ ] Test manuale: create → join → add story → vote → reveal → next story

---

## #3 Cleanup stanze abbandonate

### Migration: `supabase/migrations/003_room_cleanup.sql`

```sql
-- Funzione che elimina rooms dove last_activity_at < now() - interval
CREATE OR REPLACE FUNCTION cleanup_stale_rooms(p_inactive_hours int DEFAULT 24)
RETURNS int ...
```

### pg_cron

1. Abilitare estensione **pg_cron** (Supabase Dashboard → Database → Extensions).
2. Schedulare job (es. ogni 6 ore):

```sql
SELECT cron.schedule(
  'cleanup-stale-rooms',
  '0 */6 * * *',
  $$ SELECT cleanup_stale_rooms(24); $$
);
```

### Documentazione

Aggiornare [`README.md`](../../README.md): stanze inattive > 24h vengono rimosse.

### Verifica

- [ ] Funzione testabile manualmente da SQL Editor
- [ ] Cron visibile in Dashboard

---

## #9 CI/CD GitHub Actions

### File: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
```

### Opzionale

- Job `build-web` con `--dart-define` dummy per verificare che la web compili (senza deploy).

### Verifica

- [ ] Workflow verde su push a `main`
- [ ] PR bloccata se `analyze` o `test` falliscono

---

## Criteri di done — Fase 1

- [ ] Migration 002 e 003 applicate su progetto Supabase `eyvfsgzbrdibheyejikf`
- [ ] CI attiva su GitHub
- [ ] README aggiornato (TTL stanze + note sicurezza)
- [ ] Nessuna regressione sul flusso poker in produzione

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| RLS rompe Realtime | Testare SELECT + subscribe dopo migration |
| pg_cron non su piano free | Documentare requisito; cleanup manuale alternativo |
| Rate limit troppo aggressivo | Parametro configurabile, valore iniziale alto |

## Dipendenze

Nessuna — questa fase è il punto di partenza della roadmap.
