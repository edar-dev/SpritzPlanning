-- Fix PIN hashing on Supabase where pgcrypto functions live in `extensions` schema.
-- Error seen: function gen_salt(unknown) does not exist

-- ---------------------------------------------------------------------------
-- set_room_pin
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS set_room_pin(UUID, TEXT);

CREATE OR REPLACE FUNCTION set_room_pin(
  p_participant_id UUID,
  p_pin TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può impostare il PIN';
  END IF;

  IF p_pin IS NULL OR trim(p_pin) = '' THEN
    UPDATE rooms SET join_pin_hash = NULL WHERE id = v_room_id;
  ELSE
    IF trim(p_pin) !~ '^[0-9]{4,6}$' THEN
      RAISE EXCEPTION 'PIN deve essere di 4-6 cifre';
    END IF;
    UPDATE rooms
    SET join_pin_hash = crypt(trim(p_pin), gen_salt('bf'::TEXT))
    WHERE id = v_room_id;
  END IF;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- create_room (+ optional PIN)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_room(TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION create_room(
  p_name TEXT,
  p_nickname TEXT,
  p_pin TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_room_id UUID;
  v_participant_id UUID;
  v_code TEXT;
  v_attempts INT := 0;
  v_pin_hash TEXT;
BEGIN
  PERFORM check_rate_limit('create_room', 20, interval '1 hour');

  IF char_length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Nome locale troppo corto';
  END IF;
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  IF p_pin IS NOT NULL AND trim(p_pin) != '' THEN
    IF trim(p_pin) !~ '^[0-9]{4,6}$' THEN
      RAISE EXCEPTION 'PIN deve essere di 4-6 cifre';
    END IF;
    v_pin_hash := crypt(trim(p_pin), gen_salt('bf'::TEXT));
  END IF;

  LOOP
    v_code := generate_room_code();
    BEGIN
      INSERT INTO rooms (code, name, join_pin_hash)
      VALUES (v_code, trim(p_name), v_pin_hash)
      RETURNING id INTO v_room_id;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      v_attempts := v_attempts + 1;
      IF v_attempts > 10 THEN
        RAISE EXCEPTION 'Impossibile generare codice stanza';
      END IF;
    END;
  END LOOP;

  INSERT INTO participants (room_id, nickname, is_facilitator, is_observer)
  VALUES (v_room_id, trim(p_nickname), true, false)
  RETURNING id INTO v_participant_id;

  RETURN json_build_object(
    'room_id', v_room_id,
    'participant_id', v_participant_id,
    'code', v_code
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- join_room (+ observer, PIN; keeps rejoin logic)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS join_room(TEXT, TEXT, BOOLEAN, TEXT);

CREATE OR REPLACE FUNCTION join_room(
  p_code TEXT,
  p_nickname TEXT,
  p_observer BOOLEAN DEFAULT false,
  p_pin TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_room rooms%ROWTYPE;
  v_participant_id UUID;
  v_absence_seconds INT := 120;
BEGIN
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE upper(code) = upper(trim(p_code));
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Locale non trovato';
  END IF;

  IF v_room.join_pin_hash IS NOT NULL THEN
    IF p_pin IS NULL OR trim(p_pin) = ''
       OR crypt(trim(p_pin), v_room.join_pin_hash) != v_room.join_pin_hash THEN
      RAISE EXCEPTION 'PIN non valido';
    END IF;
  END IF;

  SELECT id INTO v_participant_id
  FROM participants
  WHERE room_id = v_room.id
    AND lower(trim(nickname)) = lower(trim(p_nickname))
  LIMIT 1;

  IF v_participant_id IS NOT NULL THEN
    IF EXISTS (
      SELECT 1 FROM participants
      WHERE id = v_participant_id
        AND last_seen_at > now() - make_interval(secs => v_absence_seconds)
    ) THEN
      RAISE EXCEPTION 'Nickname già presente in questo locale';
    END IF;

    UPDATE participants
    SET
      last_seen_at = now(),
      is_observer = COALESCE(p_observer, false),
      is_facilitator = CASE
        WHEN COALESCE(p_observer, false) THEN false
        ELSE is_facilitator
      END
    WHERE id = v_participant_id;
  ELSE
    INSERT INTO participants (room_id, nickname, is_facilitator, is_observer)
    VALUES (
      v_room.id,
      trim(p_nickname),
      false,
      COALESCE(p_observer, false)
    )
    RETURNING id INTO v_participant_id;
  END IF;

  PERFORM touch_room(v_room.id);

  RETURN json_build_object(
    'room_id', v_room.id,
    'participant_id', v_participant_id,
    'code', v_room.code
  );
END;
$$;

GRANT EXECUTE ON FUNCTION set_room_pin(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION join_room(TEXT, TEXT, BOOLEAN, TEXT) TO anon, authenticated;
