-- Security hardening: RLS read-only for anon, mutations via RPC only, rate limits

-- ---------------------------------------------------------------------------
-- Rate limiting (global soft limit for create_room)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS app_rate_limits (
  key TEXT PRIMARY KEY,
  window_start TIMESTAMPTZ NOT NULL DEFAULT now(),
  count INT NOT NULL DEFAULT 0
);

ALTER TABLE app_rate_limits ENABLE ROW LEVEL SECURITY;

-- No policies: only SECURITY DEFINER functions access this table

CREATE OR REPLACE FUNCTION check_rate_limit(
  p_key TEXT,
  p_max_count INT,
  p_window INTERVAL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row app_rate_limits%ROWTYPE;
BEGIN
  SELECT * INTO v_row FROM app_rate_limits WHERE key = p_key FOR UPDATE;

  IF NOT FOUND THEN
    INSERT INTO app_rate_limits (key, window_start, count)
    VALUES (p_key, now(), 1);
    RETURN;
  END IF;

  IF v_row.window_start + p_window < now() THEN
    UPDATE app_rate_limits
    SET window_start = now(), count = 1
    WHERE key = p_key;
    RETURN;
  END IF;

  IF v_row.count >= p_max_count THEN
    RAISE EXCEPTION 'Troppi locali creati di recente. Riprova tra qualche minuto.';
  END IF;

  UPDATE app_rate_limits SET count = count + 1 WHERE key = p_key;
END;
$$;

-- ---------------------------------------------------------------------------
-- Helpers (internal)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION assert_participant_exists(p_participant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  SELECT room_id INTO v_room_id FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;
  RETURN v_room_id;
END;
$$;

CREATE OR REPLACE FUNCTION generate_room_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  suffix TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..4 LOOP
    suffix := suffix || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN 'SPRT-' || suffix;
END;
$$;

REVOKE ALL ON FUNCTION generate_room_code() FROM PUBLIC;
REVOKE ALL ON FUNCTION touch_room(UUID) FROM PUBLIC;

-- ---------------------------------------------------------------------------
-- Drop permissive write policies (SELECT retained for Realtime)
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "rooms_update" ON rooms;

DROP POLICY IF EXISTS "participants_insert" ON participants;
DROP POLICY IF EXISTS "participants_update" ON participants;

DROP POLICY IF EXISTS "stories_insert" ON stories;
DROP POLICY IF EXISTS "stories_update" ON stories;
DROP POLICY IF EXISTS "stories_delete" ON stories;

DROP POLICY IF EXISTS "votes_insert" ON votes;
DROP POLICY IF EXISTS "votes_update" ON votes;
DROP POLICY IF EXISTS "votes_delete" ON votes;

-- ---------------------------------------------------------------------------
-- create_room: add rate limit (max 20 rooms per hour, global)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_room(p_name TEXT, p_nickname TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_participant_id UUID;
  v_code TEXT;
  v_attempts INT := 0;
BEGIN
  PERFORM check_rate_limit('create_room', 20, interval '1 hour');

  IF char_length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Nome locale troppo corto';
  END IF;
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  LOOP
    v_code := generate_room_code();
    BEGIN
      INSERT INTO rooms (code, name) VALUES (v_code, trim(p_name))
      RETURNING id INTO v_room_id;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      v_attempts := v_attempts + 1;
      IF v_attempts > 10 THEN
        RAISE EXCEPTION 'Impossibile generare codice stanza';
      END IF;
    END;
  END LOOP;

  INSERT INTO participants (room_id, nickname, is_facilitator)
  VALUES (v_room_id, trim(p_nickname), true)
  RETURNING id INTO v_participant_id;

  RETURN json_build_object(
    'room_id', v_room_id,
    'participant_id', v_participant_id,
    'code', v_code
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- join_room: reject duplicate nickname in same room
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION join_room(p_code TEXT, p_nickname TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room rooms%ROWTYPE;
  v_participant_id UUID;
BEGIN
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE upper(code) = upper(trim(p_code));
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Locale non trovato';
  END IF;

  IF EXISTS (
    SELECT 1 FROM participants
    WHERE room_id = v_room.id AND lower(trim(nickname)) = lower(trim(p_nickname))
  ) THEN
    RAISE EXCEPTION 'Nickname già presente in questo locale';
  END IF;

  INSERT INTO participants (room_id, nickname, is_facilitator)
  VALUES (v_room.id, trim(p_nickname), false)
  RETURNING id INTO v_participant_id;

  PERFORM touch_room(v_room.id);

  RETURN json_build_object(
    'room_id', v_room.id,
    'participant_id', v_participant_id,
    'code', v_room.code
  );
END;
$$;

-- cast_vote: validate deck value
CREATE OR REPLACE FUNCTION cast_vote(
  p_participant_id UUID,
  p_story_id UUID,
  p_value TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_participant participants%ROWTYPE;
  v_room rooms%ROWTYPE;
  v_story stories%ROWTYPE;
  v_allowed TEXT[] := ARRAY[
    '0', '½', '1', '2', '3', '5', '8', '13', '21', '?', '☕'
  ];
BEGIN
  IF p_value IS NULL OR NOT (p_value = ANY (v_allowed)) THEN
    RAISE EXCEPTION 'Valore voto non valido';
  END IF;

  SELECT * INTO v_participant FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE id = v_participant.room_id;
  SELECT * INTO v_story FROM stories WHERE id = p_story_id;

  IF v_story.id IS NULL OR v_story.room_id != v_room.id THEN
    RAISE EXCEPTION 'Ordine non valido';
  END IF;
  IF v_room.phase != 'voting' OR v_room.current_story_id != p_story_id THEN
    RAISE EXCEPTION 'Votazione non attiva';
  END IF;
  IF v_room.votes_revealed THEN
    RAISE EXCEPTION 'Voti già rivelati';
  END IF;

  INSERT INTO votes (story_id, participant_id, value, voted_at)
  VALUES (p_story_id, p_participant_id, p_value, now())
  ON CONFLICT (story_id, participant_id)
  DO UPDATE SET value = EXCLUDED.value, voted_at = now();

  UPDATE participants SET last_seen_at = now() WHERE id = p_participant_id;
  PERFORM touch_room(v_room.id);
END;
$$;

-- Revoke public execute on internal helpers
REVOKE ALL ON FUNCTION check_rate_limit(TEXT, INT, INTERVAL) FROM PUBLIC;
REVOKE ALL ON FUNCTION assert_participant_exists(UUID) FROM PUBLIC;

-- Ensure public RPCs remain callable
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION join_room(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION add_story(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION remove_story(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION start_voting(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cast_vote(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reveal_votes(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reset_votes(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_final_estimate(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION next_story(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION heartbeat(UUID) TO anon, authenticated;
