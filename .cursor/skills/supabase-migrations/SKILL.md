---
name: supabase-migrations
description: Create and review Supabase SQL migrations for SpritzPlanning — tables, RPC functions, RLS policies, Realtime. Use when writing or modifying supabase/migrations/ files.
---

# Supabase Migrations

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
- [ ] Realtime publication updated
- [ ] GRANT EXECUTE on new RPCs
- [ ] Input validation in RPC body
- [ ] Foreign keys with ON DELETE CASCADE where appropriate
