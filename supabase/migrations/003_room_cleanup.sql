-- Cleanup inactive rooms (cascade deletes participants, stories, votes)

CREATE OR REPLACE FUNCTION cleanup_stale_rooms(p_inactive_hours INT DEFAULT 24)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_deleted INT;
BEGIN
  IF p_inactive_hours < 1 THEN
    RAISE EXCEPTION 'p_inactive_hours deve essere >= 1';
  END IF;

  WITH deleted AS (
    DELETE FROM rooms
    WHERE last_activity_at < now() - (p_inactive_hours || ' hours')::interval
    RETURNING id
  )
  SELECT count(*)::int INTO v_deleted FROM deleted;

  RETURN v_deleted;
END;
$$;

REVOKE ALL ON FUNCTION cleanup_stale_rooms(INT) FROM PUBLIC;

-- Callable by service role / SQL editor only (not anon client app)
GRANT EXECUTE ON FUNCTION cleanup_stale_rooms(INT) TO service_role;

-- Scheduled cleanup: see 004_pg_cron.sql
