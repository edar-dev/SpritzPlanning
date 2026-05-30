# Supabase — SpritzPlanning

Progetto: `eyvfsgzbrdibheyejikf` (eu-central-1)

## Migrations

Applica in ordine:

```bash
supabase db push
# oppure SQL Editor: eseguire ogni file in supabase/migrations/
```

| File | Contenuto |
|------|-----------|
| `001_initial_schema.sql` | Schema, RPC, RLS iniziale, Realtime |
| `002_security_hardening.sql` | RLS write bloccato, rate limit create_room |
| `003_room_cleanup.sql` | `cleanup_stale_rooms()` |

## Cleanup automatico (pg_cron)

1. Dashboard → Database → Extensions → abilita **pg_cron**
2. SQL Editor:

```sql
SELECT cron.schedule(
  'cleanup-stale-rooms',
  '0 */6 * * *',
  $$ SELECT cleanup_stale_rooms(24); $$
);
```

Stanze senza attività per **24 ore** vengono eliminate (cascade su partecipanti, ordini, voti).

Test manuale:

```sql
SELECT cleanup_stale_rooms(24);
```

## Sicurezza

- **Letture**: policy `SELECT` su `rooms`, `participants`, `stories`, `votes` per `anon`
- **Scritture**: solo tramite RPC `SECURITY DEFINER` (no INSERT/UPDATE/DELETE diretti)
- **Rate limit**: max 20 `create_room` / ora (globale)
- Funzioni interne (`generate_room_code`, `touch_room`, `check_rate_limit`) non esposte ad `anon`
