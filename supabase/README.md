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
| `20260606130000_fix_pin_pgcrypto_search_path.sql` | Fix PIN hashing: `gen_salt/crypt` con `search_path` compatibile Supabase (`public, extensions`) |
| `20260603120000_hide_voters_until_reveal.sql` | Voto anonimo pre-reveal (#64) |
| `20260604120000_drop_rpc_overloads.sql` | Rimuove overload `create_room`/`join_room` (fix PostgREST PGRST203) |
| `20260605120000_session_depth.sql` | Reference story, commenti pubblici, confidence vote, cronologia stime, push subscription (#71–#75, #78) |
| `20260607120000_participant_roles.sql` | Ruoli partecipante (`facilitator`/`editor`/`viewer`) + permessi backlog (#79) |
| `20260608120000_enterprise_readiness.sql` | Workspace branding su room, audit trail, link Jira/ADO, health RPC (#80, #85, #83, #86) |
| `20260609120000_identity_auth.sql` | Supabase Auth: `user_profiles`, `participants.user_id`, link account, RPC hardening (#89–#91, #96) |

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

## Auth (Fase 19)

Configurazione in [Supabase Dashboard → Authentication](https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf/auth/providers):

| Provider | Note |
|----------|------|
| Email (magic link) | Abilitare; conferma email opzionale in dev |
| Google / Azure | OAuth; client ID/secret in dashboard |

**Redirect URLs** (Authentication → URL Configuration):

- Produzione: `https://spritz-planning.vercel.app/auth/callback`
- Preview Vercel: `https://*.vercel.app/auth/callback` (o ogni preview esplicita)
- Locale web: `http://localhost:<port>/auth/callback`

Deep link mobile (se usato): `io.supabase.spritzplanning://auth/callback`

## Sicurezza

- **Letture**: policy `SELECT` su `rooms`, `participants`, `stories`, `votes` per `anon`
- **Profili**: `user_profiles` leggibile/aggiornabile solo da `authenticated` con `id = auth.uid()`
- **Scritture**: solo tramite RPC `SECURITY DEFINER` (no INSERT/UPDATE/DELETE diretti)
- **Rate limit**: max 20 `create_room` / ora (globale)
- Funzioni interne (`generate_room_code`, `touch_room`, `check_rate_limit`) non esposte ad `anon`
