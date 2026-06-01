-- Allow re-joining with the same nickname after voluntary leave or absence.

-- Seconds without heartbeat before the nickname can be reclaimed (matches app SessionConstants).
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
  v_absence_seconds INT := 120;
BEGIN
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE upper(code) = upper(trim(p_code));
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Locale non trovato';
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
    SET last_seen_at = now()
    WHERE id = v_participant_id;
  ELSE
    INSERT INTO participants (room_id, nickname, is_facilitator)
    VALUES (v_room.id, trim(p_nickname), false)
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

-- Marks the participant as left so join_room can reclaim the nickname immediately.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION leave_room(p_participant_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_participant_id IS NULL THEN
    RETURN;
  END IF;

  UPDATE participants
  SET last_seen_at = '1970-01-01'::timestamptz
  WHERE id = p_participant_id;
END;
$$;

GRANT EXECUTE ON FUNCTION leave_room(UUID) TO anon, authenticated;
