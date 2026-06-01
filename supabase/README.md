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
| `20260530120808_initial_schema.sql` | Schema, RPC, RLS iniziale, Realtime |
| `20260530205137_security_hardening.sql` | RLS write bloccato, rate limit create_room |
| `20260530205145_room_cleanup.sql` | `cleanup_stale_rooms()` |
| `20260530205849_pg_cron.sql` | Estensione `pg_cron` + job `cleanup-stale-rooms` (ogni 6h) |
| `20260530213606_transfer_facilitator.sql` | RPC `transfer_facilitator` per passaggio ruolo barman |
| `20260531151743_story_management.sql` | Edit titolo/descrizione ordini, riordino menu |
| `20260531151756_voting_timer.sql` | `voting_deadline_at`, timer e clear su reveal/next |
| `20260531151757_remove_participant.sql` | RPC `remove_participant` (kick cliente / AFK) |
| `20260531190333_room_deck_settings.sql` | Deck JSON per stanza, `set_room_deck`, validazione voti |
| `20260601120938_bulk_add_stories.sql` | RPC `add_stories` — import batch titoli (max 50) |
| `20260601131912_join_room_rejoin.sql` | `join_room` reclaim nickname assente; RPC `leave_room` per uscita |
| `20260602140000_session_advanced.sql` | Spike, osservatori, auto-reveal, PIN, note barman, duplica stanza |

I nomi usano il timestamp Supabase (`YYYYMMDDHHMMSS_nome.sql`) per allinearsi a `supabase_migrations.schema_migrations` e a `supabase db push` in CI.

## CI (GitHub Actions)

Su push a `main` che modifica `supabase/migrations/`, il workflow [`.github/workflows/supabase-migrations.yml`](../.github/workflows/supabase-migrations.yml) esegue `supabase db push` sul progetto `eyvfsgzbrdibheyejikf`.

Configura il secret **`SUPABASE_ACCESS_TOKEN`** nel repository (Settings → Secrets → Actions): [Account tokens](https://supabase.com/dashboard/account/tokens).

## Cleanup automatico (pg_cron)

Applica `004_pg_cron.sql` (o `supabase db push` dopo 001–003).

- Job: `cleanup-stale-rooms`
- Schedule: ogni 6 ore (`0 */6 * * *`)
- Azione: `cleanup_stale_rooms(24)` — elimina stanze inattive da **24 ore** (cascade su partecipanti, ordini, voti)

Alternativa senza migration: MCP Supabase `execute_sql` o SQL Editor (stesso SQL del file 004).

Rimuovere il job:

```sql
SELECT cron.unschedule(jobid) FROM cron.job WHERE jobname = 'cleanup-stale-rooms';
```

Test manuale:

```sql
SELECT cleanup_stale_rooms(24);
```

## Sicurezza

- **Letture**: policy `SELECT` su `rooms`, `participants`, `stories`, `votes` per `anon`
- **Scritture**: solo tramite RPC `SECURITY DEFINER` (no INSERT/UPDATE/DELETE diretti)
- **Rate limit**: max 20 `create_room` / ora (globale)
- Funzioni interne (`generate_room_code`, `touch_room`, `check_rate_limit`) non esposte ad `anon`
