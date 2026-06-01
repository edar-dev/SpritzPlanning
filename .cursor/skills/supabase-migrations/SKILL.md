---
name: supabase-migrations
description: Create and review Supabase SQL migrations for SpritzPlanning — tables, RPC functions, RLS policies, Realtime. Use when writing or modifying supabase/migrations/ files.
---

# Supabase Migrations

## Progetto

- **ID:** `eyvfsgzbrdibheyejikf`
- **Regione:** `eu-central-1`
- **Path:** `supabase/migrations/`

## Elenco migration (001–011)

| File | Scopo |
|------|--------|
| `001_initial_schema.sql` | Schema, RPC, RLS, Realtime |
| `002_security_hardening.sql` | RLS write bloccato, rate limit `create_room` |
| `003_room_cleanup.sql` | `cleanup_stale_rooms()` |
| `004_pg_cron.sql` | Job pg_cron cleanup stanze (6h) |
| `005_transfer_facilitator.sql` | RPC `transfer_facilitator` |
| `006_story_management.sql` | Edit/riordino ordini (`update_story`, reorder) |
| `007_voting_timer.sql` | `voting_deadline_at`, timer votazione |
| `008_remove_participant.sql` | RPC `remove_participant` (kick) |
| `009_room_deck_settings.sql` | Deck custom per stanza, `set_room_deck` |
| `010_bulk_add_stories.sql` | RPC `add_stories` (batch titoli) |
| `011_join_room_rejoin.sql` | `join_room` reclaim + `leave_room` |

Nuovo file: numero sequenziale successivo (es. `012_…`). Aggiornare [supabase/README.md](../../../supabase/README.md). Su merge a `main`, CI applica con `supabase-migrations.yml` se `SUPABASE_ACCESS_TOKEN` è configurato.

## Template RPC

```sql
CREATE OR REPLACE FUNCTION my_rpc(p_participant_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- validate facilitator if needed
  -- mutate data
  PERFORM touch_room(v_room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION my_rpc(UUID) TO anon, authenticated;
```

## Naming

- Tables: plural snake_case (`participants`, `stories`)
- RPC: verb_noun (`create_room`, `cast_vote`)
- Enums: snake_case type names

## Checklist

- [ ] RLS enabled on all tables
- [ ] Realtime publication updated if nuove tabelle
- [ ] GRANT EXECUTE on new RPCs
- [ ] Input validation in RPC body
- [ ] Foreign keys with ON DELETE CASCADE where appropriate
- [ ] README supabase aggiornato
- [ ] PR indica se migration applicata su cloud

## Applicazione

```bash
supabase db push
```

Oppure MCP Supabase / SQL Editor con contenuto completo del file migration.
