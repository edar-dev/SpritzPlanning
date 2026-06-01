-- Phase 14: spike, observer, auto-reveal, PIN, facilitator notes, duplicate room

CREATE TYPE story_kind AS ENUM ('story', 'spike');

ALTER TABLE stories
  ADD COLUMN IF NOT EXISTS kind story_kind NOT NULL DEFAULT 'story';

ALTER TABLE stories
  ADD COLUMN IF NOT EXISTS facilitator_note TEXT NOT NULL DEFAULT '';

ALTER TABLE participants
  ADD COLUMN IF NOT EXISTS is_observer BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS auto_reveal_when_all_voted BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS join_pin_hash TEXT;

-- ---------------------------------------------------------------------------
-- perform_reveal (internal + auto-reveal from cast_vote)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION perform_reveal(p_room_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_story_id UUID;
BEGIN
  SELECT current_story_id INTO v_story_id FROM rooms WHERE id = p_room_id;
  IF v_story_id IS NULL THEN
    RETURN;
  END IF;

  UPDATE rooms SET
    phase = 'revealed',
    votes_revealed = true,
    voting_deadline_at = NULL
  WHERE id = p_room_id;

  UPDATE stories SET status = 'revealed' WHERE id = v_story_id;
  PERFORM touch_room(p_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- mark_story_spike
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION mark_story_spike(
  p_participant_id UUID,
  p_story_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story stories%ROWTYPE;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può segnare uno spike';
  END IF;

  SELECT * INTO v_story FROM stories WHERE id = p_story_id;
  IF v_story.id IS NULL OR v_story.room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;
  IF v_story.status != 'pending' THEN
    RAISE EXCEPTION 'Solo ordini in attesa possono diventare spike';
  END IF;

  UPDATE stories SET
    kind = 'spike',
    status = 'done',
    final_estimate = '—'
  WHERE id = p_story_id;

  UPDATE rooms SET
    phase = 'lobby',
    current_story_id = NULL,
    votes_revealed = false,
    voting_deadline_at = NULL
  WHERE id = v_room_id AND current_story_id = p_story_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- set_room_settings (auto-reveal)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_room_settings(
  p_participant_id UUID,
  p_auto_reveal_when_all_voted BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può modificare le impostazioni';
  END IF;

  UPDATE rooms SET auto_reveal_when_all_voted = p_auto_reveal_when_all_voted
  WHERE id = v_room_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- set_room_pin
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_room_pin(
  p_participant_id UUID,
  p_pin TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
    UPDATE rooms SET join_pin_hash = crypt(trim(p_pin), gen_salt('bf'))
    WHERE id = v_room_id;
  END IF;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- get_room_join_info (public metadata for join form)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_room_join_info(p_code TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room rooms%ROWTYPE;
BEGIN
  SELECT * INTO v_room FROM rooms WHERE upper(code) = upper(trim(p_code));
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Locale non trovato';
  END IF;

  RETURN json_build_object(
    'requires_pin', v_room.join_pin_hash IS NOT NULL,
    'room_name', v_room.name
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- duplicate_room
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION duplicate_room(
  p_participant_id UUID,
  p_source_room_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_source rooms%ROWTYPE;
  v_room_id UUID;
  v_participant_id UUID;
  v_code TEXT;
  v_attempts INT := 0;
  v_story stories%ROWTYPE;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM participants
    WHERE id = p_participant_id
      AND room_id = p_source_room_id
      AND is_facilitator = true
  ) THEN
    RAISE EXCEPTION 'Solo il barman può duplicare il locale';
  END IF;

  SELECT * INTO v_source FROM rooms WHERE id = p_source_room_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Locale non trovato';
  END IF;

  LOOP
    v_code := generate_room_code();
    BEGIN
      INSERT INTO rooms (
        code, name, deck_values, allow_coffee_break,
        auto_reveal_when_all_voted
      )
      VALUES (
        v_code,
        v_source.name,
        v_source.deck_values,
        v_source.allow_coffee_break,
        v_source.auto_reveal_when_all_voted
      )
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
  SELECT v_room_id, nickname, true, false
  FROM participants WHERE id = p_participant_id
  RETURNING id INTO v_participant_id;

  FOR v_story IN
    SELECT * FROM stories
    WHERE room_id = p_source_room_id
    ORDER BY sort_order
  LOOP
    INSERT INTO stories (
      room_id, title, description, sort_order, status,
      final_estimate, kind, facilitator_note
    )
    VALUES (
      v_room_id,
      v_story.title,
      v_story.description,
      v_story.sort_order,
      'pending',
      NULL,
      CASE WHEN v_story.kind = 'spike' THEN 'story'::story_kind ELSE v_story.kind END,
      v_story.facilitator_note
    );
  END LOOP;

  PERFORM touch_room(v_room_id);

  RETURN json_build_object(
    'room_id', v_room_id,
    'participant_id', v_participant_id,
    'code', v_code
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- create_room (+ optional PIN)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_room(
  p_name TEXT,
  p_nickname TEXT,
  p_pin TEXT DEFAULT NULL
)
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
    v_pin_hash := crypt(trim(p_pin), gen_salt('bf'));
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
CREATE OR REPLACE FUNCTION join_room(
  p_code TEXT,
  p_nickname TEXT,
  p_observer BOOLEAN DEFAULT false,
  p_pin TEXT DEFAULT NULL
)
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

-- ---------------------------------------------------------------------------
-- start_voting (reject spike)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION start_voting(
  p_participant_id UUID,
  p_story_id UUID,
  p_duration_seconds INT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story_room_id UUID;
  v_kind story_kind;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può avviare la votazione';
  END IF;

  SELECT room_id, kind INTO v_story_room_id, v_kind FROM stories WHERE id = p_story_id;
  IF v_story_room_id IS NULL OR v_story_room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;
  IF v_kind = 'spike' THEN
    RAISE EXCEPTION 'Non si può votare uno spike';
  END IF;

  UPDATE stories SET status = 'pending'
  WHERE room_id = v_room_id AND status = 'voting';

  UPDATE stories SET status = 'voting' WHERE id = p_story_id;

  UPDATE rooms SET
    phase = 'voting',
    current_story_id = p_story_id,
    votes_revealed = false,
    voting_deadline_at = CASE
      WHEN p_duration_seconds IS NOT NULL AND p_duration_seconds > 0
      THEN now() + make_interval(secs => p_duration_seconds)
      ELSE NULL
    END
  WHERE id = v_room_id;

  DELETE FROM votes WHERE story_id = p_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- cast_vote (observer guard + auto-reveal)
-- ---------------------------------------------------------------------------
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
  v_allowed TEXT[];
  v_required INT;
  v_voted INT;
  v_absence_seconds INT := 120;
BEGIN
  SELECT * INTO v_participant FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;
  IF v_participant.is_observer THEN
    RAISE EXCEPTION 'Gli osservatori non possono votare';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE id = v_participant.room_id;
  SELECT * INTO v_story FROM stories WHERE id = p_story_id;

  SELECT array_agg(elem::TEXT)
  INTO v_allowed
  FROM jsonb_array_elements_text(v_room.deck_values) AS elem;

  IF p_value IS NULL OR NOT (p_value = ANY (v_allowed)) THEN
    RAISE EXCEPTION 'Valore voto non valido';
  END IF;

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

  IF v_room.auto_reveal_when_all_voted AND NOT v_room.votes_revealed THEN
    SELECT COUNT(*)::INT INTO v_required
    FROM participants
    WHERE room_id = v_room.id
      AND NOT is_observer
      AND last_seen_at > now() - make_interval(secs => v_absence_seconds);

    SELECT COUNT(*)::INT INTO v_voted
    FROM votes v
    INNER JOIN participants p ON p.id = v.participant_id
    WHERE v.story_id = p_story_id
      AND v.value IS NOT NULL
      AND p.room_id = v_room.id
      AND NOT p.is_observer
      AND p.last_seen_at > now() - make_interval(secs => v_absence_seconds);

    IF v_required > 0 AND v_voted >= v_required THEN
      PERFORM perform_reveal(v_room.id);
    END IF;
  END IF;
END;
$$;

-- ---------------------------------------------------------------------------
-- reveal_votes (uses perform_reveal)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION reveal_votes(p_participant_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story_id UUID;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può rivelare i voti';
  END IF;

  SELECT current_story_id INTO v_story_id FROM rooms WHERE id = v_room_id;
  IF v_story_id IS NULL THEN
    RAISE EXCEPTION 'Nessun ordine in votazione';
  END IF;

  PERFORM perform_reveal(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- update_story (+ facilitator_note)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS update_story(UUID, UUID, TEXT, TEXT);

CREATE OR REPLACE FUNCTION update_story(
  p_participant_id UUID,
  p_story_id UUID,
  p_title TEXT,
  p_description TEXT DEFAULT '',
  p_facilitator_note TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story stories%ROWTYPE;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può modificare ordini';
  END IF;

  SELECT * INTO v_story FROM stories WHERE id = p_story_id;
  IF v_story.id IS NULL OR v_story.room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  IF v_story.status NOT IN ('pending', 'done') THEN
    RAISE EXCEPTION 'Ordine non modificabile in questo stato';
  END IF;

  IF char_length(trim(p_title)) < 1 THEN
    RAISE EXCEPTION 'Titolo ordine troppo corto';
  END IF;

  IF p_facilitator_note IS NOT NULL AND char_length(p_facilitator_note) > 2000 THEN
    RAISE EXCEPTION 'Nota troppo lunga';
  END IF;

  UPDATE stories SET
    title = trim(p_title),
    description = COALESCE(trim(p_description), ''),
    facilitator_note = CASE
      WHEN p_facilitator_note IS NOT NULL THEN trim(p_facilitator_note)
      ELSE facilitator_note
    END
  WHERE id = p_story_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- transfer_facilitator (observers cannot become barman)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION transfer_facilitator(
  p_from_participant_id UUID,
  p_to_participant_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_from participants%ROWTYPE;
  v_to participants%ROWTYPE;
BEGIN
  IF p_from_participant_id = p_to_participant_id THEN
    RAISE EXCEPTION 'Non puoi passare il bancone a te stesso';
  END IF;

  SELECT * INTO v_from FROM participants WHERE id = p_from_participant_id;
  IF NOT FOUND OR NOT v_from.is_facilitator THEN
    RAISE EXCEPTION 'Solo il barman può passare il bancone';
  END IF;

  SELECT * INTO v_to FROM participants WHERE id = p_to_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  IF v_to.room_id != v_from.room_id THEN
    RAISE EXCEPTION 'I clienti devono essere nello stesso locale';
  END IF;

  IF v_to.is_observer THEN
    RAISE EXCEPTION 'Un osservatore non può diventare barman';
  END IF;

  UPDATE participants SET is_facilitator = false WHERE room_id = v_from.room_id;
  UPDATE participants SET is_facilitator = true WHERE id = p_to_participant_id;

  PERFORM touch_room(v_from.room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION mark_story_spike(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_room_settings(UUID, BOOLEAN) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_room_pin(UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_room_join_info(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION duplicate_room(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_story(UUID, UUID, TEXT, TEXT, TEXT) TO anon, authenticated;
