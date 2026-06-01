-- pg_cron: enable extension and schedule stale-room cleanup (requires 003_room_cleanup)

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;

-- Idempotent: replace existing job with same name
DO $$
DECLARE
  v_jobid BIGINT;
BEGIN
  SELECT jobid INTO v_jobid FROM cron.job WHERE jobname = 'cleanup-stale-rooms';
  IF v_jobid IS NOT NULL THEN
    PERFORM cron.unschedule(v_jobid);
  END IF;
END;
$$;

SELECT cron.schedule(
  'cleanup-stale-rooms',
  '0 */6 * * *',
  $$ SELECT cleanup_stale_rooms(24); $$
);
