-- Phase 17 (#79): participant roles (facilitator / editor / viewer)

CREATE TYPE participant_role AS ENUM ('facilitator', 'editor', 'viewer');

ALTER TABLE participants
  ADD COLUMN IF NOT EXISTS role participant_role;

UPDATE participants
SET role = CASE
  WHEN is_facilitator THEN 'facilitator'::participant_role
  WHEN is_observer THEN 'viewer'::participant_role
  ELSE 'editor'::participant_role
END
WHERE role IS NULL;

ALTER TABLE participants
  ALTER COLUMN role SET DEFAULT 'editor'::participant_role;

ALTER TABLE participants
  ALTER COLUMN role SET NOT NULL;

-- ---------------------------------------------------------------------------
-- Permission helpers
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION assert_can_moderate(p_participant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND role = 'facilitator';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può eseguire questa azione';
  END IF;
  RETURN v_room_id;
END;
$$;

CREATE OR REPLACE FUNCTION assert_can_edit_backlog(p_participant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND role IN ('facilitator', 'editor');
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Permessi insufficienti per modificare il menu';
  END IF;
  RETURN v_room_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- set_participant_role (facilitator only; editor/viewer targets)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_participant_role(
  p_facilitator_id UUID,
  p_target_id UUID,
  p_role participant_role
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_target participants%ROWTYPE;
BEGIN
  v_room_id := assert_can_moderate(p_facilitator_id);

  IF p_role = 'facilitator' THEN
    RAISE EXCEPTION 'Usa passa bancone per cambiare barman';
  END IF;

  SELECT * INTO v_target FROM participants WHERE id = p_target_id;
  IF NOT FOUND OR v_target.room_id != v_room_id THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  IF v_target.is_facilitator THEN
    RAISE EXCEPTION 'Non puoi cambiare il ruolo del barman';
  END IF;

  UPDATE participants
  SET role = p_role
  WHERE id = p_target_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- create_room (+ role on creator)
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

  INSERT INTO participants (
    room_id, nickname, is_facilitator, is_observer, role
  )
  VALUES (
    v_room_id, trim(p_nickname), true, false, 'facilitator'::participant_role
  )
  RETURNING id INTO v_participant_id;

  RETURN json_build_object(
    'room_id', v_room_id,
    'participant_id', v_participant_id,
    'code', v_code
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- join_room (+ role on join/rejoin)
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
  v_observer BOOLEAN := COALESCE(p_observer, false);
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
      is_observer = v_observer,
      is_facilitator = CASE
        WHEN v_observer THEN false
        ELSE is_facilitator
      END,
      role = CASE
        WHEN is_facilitator THEN 'facilitator'::participant_role
        WHEN v_observer THEN 'viewer'::participant_role
        ELSE 'editor'::participant_role
      END
    WHERE id = v_participant_id;
  ELSE
    INSERT INTO participants (
      room_id, nickname, is_facilitator, is_observer, role
    )
    VALUES (
      v_room.id,
      trim(p_nickname),
      false,
      v_observer,
      CASE
        WHEN v_observer THEN 'viewer'::participant_role
        ELSE 'editor'::participant_role
      END
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
-- transfer_facilitator (sync role column)
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
  IF NOT FOUND OR v_from.role != 'facilitator' THEN
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

  UPDATE participants
  SET is_facilitator = false, role = 'editor'::participant_role
  WHERE room_id = v_from.room_id;

  UPDATE participants
  SET is_facilitator = true, role = 'facilitator'::participant_role, is_observer = false
  WHERE id = p_to_participant_id;

  PERFORM touch_room(v_from.room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- Backlog RPCs: editor + facilitator
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_story(
  p_participant_id UUID,
  p_title TEXT,
  p_description TEXT DEFAULT ''
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story_id UUID;
  v_max_order INT;
BEGIN
  v_room_id := assert_can_edit_backlog(p_participant_id);

  SELECT COALESCE(MAX(sort_order), -1) INTO v_max_order
  FROM stories WHERE room_id = v_room_id;

  INSERT INTO stories (room_id, title, description, sort_order)
  VALUES (v_room_id, trim(p_title), COALESCE(trim(p_description), ''), v_max_order + 1)
  RETURNING id INTO v_story_id;

  PERFORM touch_room(v_room_id);
  RETURN v_story_id;
END;
$$;

CREATE OR REPLACE FUNCTION add_stories(
  p_participant_id UUID,
  p_titles TEXT[]
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_max_order INT;
  v_title TEXT;
  v_count INT := 0;
BEGIN
  v_room_id := assert_can_edit_backlog(p_participant_id);

  IF p_titles IS NULL OR array_length(p_titles, 1) IS NULL THEN
    RETURN 0;
  END IF;

  IF array_length(p_titles, 1) > 50 THEN
    RAISE EXCEPTION 'Massimo 50 ordini per import';
  END IF;

  SELECT COALESCE(MAX(sort_order), -1) INTO v_max_order
  FROM stories WHERE room_id = v_room_id;

  FOREACH v_title IN ARRAY p_titles LOOP
    IF char_length(trim(v_title)) < 1 THEN
      CONTINUE;
    END IF;
    v_max_order := v_max_order + 1;
    INSERT INTO stories (room_id, title, description, sort_order)
    VALUES (v_room_id, trim(v_title), '', v_max_order);
    v_count := v_count + 1;
  END LOOP;

  IF v_count > 0 THEN
    PERFORM touch_room(v_room_id);
  END IF;

  RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION remove_story(p_participant_id UUID, p_story_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story_room_id UUID;
BEGIN
  v_room_id := assert_can_edit_backlog(p_participant_id);

  SELECT room_id INTO v_story_room_id FROM stories WHERE id = p_story_id;
  IF v_story_room_id IS NULL OR v_story_room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  UPDATE rooms SET current_story_id = NULL
  WHERE id = v_room_id AND current_story_id = p_story_id;

  DELETE FROM stories WHERE id = p_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION reorder_stories(
  p_participant_id UUID,
  p_story_ids UUID[]
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_room_phase room_phase;
  v_story_id UUID;
  v_idx INT := 0;
BEGIN
  v_room_id := assert_can_edit_backlog(p_participant_id);

  SELECT phase INTO v_room_phase FROM rooms WHERE id = v_room_id;
  IF v_room_phase != 'lobby' THEN
    RAISE EXCEPTION 'Riordino consentito solo in lobby';
  END IF;

  IF p_story_ids IS NULL OR array_length(p_story_ids, 1) IS NULL THEN
    RETURN;
  END IF;

  FOREACH v_story_id IN ARRAY p_story_ids LOOP
    IF NOT EXISTS (
      SELECT 1 FROM stories
      WHERE id = v_story_id
        AND room_id = v_room_id
        AND status IN ('pending', 'done')
    ) THEN
      RAISE EXCEPTION 'Ordine non valido per il riordino';
    END IF;

    UPDATE stories SET sort_order = v_idx WHERE id = v_story_id;
    v_idx := v_idx + 1;
  END LOOP;

  PERFORM touch_room(v_room_id);
END;
$$;

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
  v_room_id := assert_can_edit_backlog(p_participant_id);

  IF p_facilitator_note IS NOT NULL THEN
    PERFORM assert_can_moderate(p_participant_id);
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

CREATE OR REPLACE FUNCTION set_story_public_comment(
  p_participant_id UUID,
  p_story_id UUID,
  p_comment TEXT
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
  v_room_id := assert_can_edit_backlog(p_participant_id);

  SELECT * INTO v_story FROM stories WHERE id = p_story_id;
  IF v_story.id IS NULL OR v_story.room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  IF char_length(trim(COALESCE(p_comment, ''))) > 500 THEN
    RAISE EXCEPTION 'Commento troppo lungo';
  END IF;

  UPDATE stories SET public_comment = trim(COALESCE(p_comment, ''))
  WHERE id = p_story_id;

  PERFORM touch_room(v_room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION assert_can_moderate(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION assert_can_edit_backlog(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_participant_role(UUID, UUID, participant_role) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION join_room(TEXT, TEXT, BOOLEAN, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION transfer_facilitator(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION add_story(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION add_stories(UUID, TEXT[]) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION remove_story(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reorder_stories(UUID, UUID[]) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_story(UUID, UUID, TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_story_public_comment(UUID, UUID, TEXT) TO anon, authenticated;
