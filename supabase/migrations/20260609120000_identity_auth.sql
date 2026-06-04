-- Phase 19 (#89, #90, #91, #96): Supabase Auth foundation, user profiles, participant linking

-- ---------------------------------------------------------------------------
-- user_profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT NOT NULL DEFAULT '',
  avatar_url TEXT,
  preferred_locale TEXT NOT NULL DEFAULT 'it'
    CHECK (preferred_locale IN ('it', 'en')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT display_name_not_empty CHECK (char_length(trim(display_name)) >= 1)
);

ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_profiles_select_own ON user_profiles
  FOR SELECT TO authenticated
  USING (id = auth.uid());

CREATE POLICY user_profiles_update_own ON user_profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- ---------------------------------------------------------------------------
-- participants.user_id
-- ---------------------------------------------------------------------------
ALTER TABLE participants
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_participants_room_user
  ON participants (room_id, user_id)
  WHERE user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_participants_user_id ON participants(user_id);

-- ---------------------------------------------------------------------------
-- Auto-create profile on signup
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION handle_new_user_profile()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_name TEXT;
BEGIN
  v_name := COALESCE(
    NULLIF(trim(NEW.raw_user_meta_data->>'full_name'), ''),
    NULLIF(trim(NEW.raw_user_meta_data->>'name'), ''),
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''),
    'Cliente'
  );

  INSERT INTO user_profiles (id, display_name)
  VALUES (NEW.id, v_name)
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created_profile ON auth.users;
CREATE TRIGGER on_auth_user_created_profile
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user_profile();

-- ---------------------------------------------------------------------------
-- assert_participant_access (#96 hybrid model)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION assert_participant_access(p_participant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_user_id UUID;
BEGIN
  SELECT room_id, user_id INTO v_room_id, v_user_id
  FROM participants
  WHERE id = p_participant_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  IF v_user_id IS NOT NULL THEN
    IF auth.uid() IS NULL THEN
      RAISE EXCEPTION 'Collega il tuo account per continuare';
    END IF;
    IF v_user_id IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'Non autorizzato per questo partecipante';
    END IF;
  END IF;

  RETURN v_room_id;
END;
$$;

CREATE OR REPLACE FUNCTION assert_can_moderate(p_participant_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  v_room_id := assert_participant_access(p_participant_id);

  IF NOT EXISTS (
    SELECT 1 FROM participants
    WHERE id = p_participant_id AND role = 'facilitator'
  ) THEN
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
  v_room_id := assert_participant_access(p_participant_id);

  IF NOT EXISTS (
    SELECT 1 FROM participants
    WHERE id = p_participant_id AND role IN ('facilitator', 'editor')
  ) THEN
    RAISE EXCEPTION 'Permessi insufficienti per modificare il menu';
  END IF;

  RETURN v_room_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Profile RPCs (#91)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_my_profile()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row user_profiles%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;

  SELECT * INTO v_row FROM user_profiles WHERE id = auth.uid();
  IF NOT FOUND THEN
    INSERT INTO user_profiles (id, display_name)
    VALUES (auth.uid(), 'Cliente')
    RETURNING * INTO v_row;
  END IF;

  RETURN json_build_object(
    'id', v_row.id,
    'display_name', v_row.display_name,
    'avatar_url', v_row.avatar_url,
    'preferred_locale', v_row.preferred_locale,
    'updated_at', v_row.updated_at
  );
END;
$$;

CREATE OR REPLACE FUNCTION upsert_my_profile(
  p_display_name TEXT,
  p_preferred_locale TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row user_profiles%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;

  IF char_length(trim(p_display_name)) < 2 THEN
    RAISE EXCEPTION 'Nome troppo corto';
  END IF;

  INSERT INTO user_profiles (id, display_name, preferred_locale)
  VALUES (
    auth.uid(),
    trim(p_display_name),
    COALESCE(NULLIF(trim(p_preferred_locale), ''), 'it')
  )
  ON CONFLICT (id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    preferred_locale = COALESCE(
      NULLIF(EXCLUDED.preferred_locale, ''),
      user_profiles.preferred_locale
    ),
    updated_at = now()
  RETURNING * INTO v_row;

  RETURN json_build_object(
    'id', v_row.id,
    'display_name', v_row.display_name,
    'avatar_url', v_row.avatar_url,
    'preferred_locale', v_row.preferred_locale,
    'updated_at', v_row.updated_at
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- link_participant_to_user (#90)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION link_participant_to_user(p_participant_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_participant participants%ROWTYPE;
  v_nickname TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;

  SELECT * INTO v_participant FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  IF v_participant.user_id IS NOT NULL
     AND v_participant.user_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Questo posto al bancone è già collegato a un altro account';
  END IF;

  IF EXISTS (
    SELECT 1 FROM participants
    WHERE room_id = v_participant.room_id
      AND user_id = auth.uid()
      AND id IS DISTINCT FROM p_participant_id
  ) THEN
    RAISE EXCEPTION 'Sei già presente in questo locale con il tuo account';
  END IF;

  UPDATE participants
  SET user_id = auth.uid()
  WHERE id = p_participant_id;

  v_nickname := trim(v_participant.nickname);

  UPDATE user_profiles
  SET
    display_name = CASE
      WHEN char_length(trim(display_name)) < 2 THEN v_nickname
      ELSE display_name
    END,
    updated_at = now()
  WHERE id = auth.uid();

  RETURN json_build_object(
    'participant_id', p_participant_id,
    'user_id', auth.uid()
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- join_room: auto-link authenticated user (#90)
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

  IF auth.uid() IS NOT NULL AND EXISTS (
    SELECT 1 FROM participants
    WHERE room_id = v_room.id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Sei già presente in questo locale con il tuo account';
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
      END,
      user_id = COALESCE(user_id, auth.uid())
    WHERE id = v_participant_id;
  ELSE
    INSERT INTO participants (
      room_id, nickname, is_facilitator, is_observer, role, user_id
    )
    VALUES (
      v_room.id,
      trim(p_nickname),
      false,
      v_observer,
      CASE
        WHEN v_observer THEN 'viewer'::participant_role
        ELSE 'editor'::participant_role
      END,
      auth.uid()
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
-- create_room: link creator when authenticated
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_room(TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION create_room(
  p_name TEXT,
  p_nickname TEXT,
  p_pin TEXT DEFAULT NULL,
  p_workspace_name TEXT DEFAULT NULL,
  p_brand_color TEXT DEFAULT NULL
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

  IF auth.uid() IS NOT NULL AND EXISTS (
    SELECT 1 FROM participants p
    JOIN rooms r ON r.id = p.room_id
    WHERE p.user_id = auth.uid()
      AND r.last_activity_at > now() - interval '24 hours'
  ) THEN
    -- soft: allow multiple rooms; only block duplicate user in same room at join
    NULL;
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
      INSERT INTO rooms (
        code, name, join_pin_hash, workspace_name, brand_color
      )
      VALUES (
        v_code,
        trim(p_name),
        v_pin_hash,
        NULLIF(trim(p_workspace_name), ''),
        NULLIF(trim(p_brand_color), '')
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

  INSERT INTO participants (
    room_id, nickname, is_facilitator, is_observer, role, user_id
  )
  VALUES (
    v_room_id, trim(p_nickname), true, false, 'facilitator'::participant_role, auth.uid()
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
-- Hardened RPCs (#96)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION remove_participant(
  p_barman_id UUID,
  p_target_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_target participants%ROWTYPE;
  v_room rooms%ROWTYPE;
BEGIN
  v_room_id := assert_can_moderate(p_barman_id);

  IF p_barman_id = p_target_id THEN
    RAISE EXCEPTION 'Non puoi rimuovere te stesso';
  END IF;

  SELECT * INTO v_target FROM participants WHERE id = p_target_id;
  IF v_target.id IS NULL OR v_target.room_id != v_room_id THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE id = v_room_id;

  IF v_room.phase = 'voting'
     AND v_room.current_story_id IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM votes
       WHERE story_id = v_room.current_story_id
         AND participant_id = p_target_id
         AND value IS NOT NULL
     ) THEN
    DELETE FROM votes
    WHERE story_id = v_room.current_story_id
      AND participant_id = p_target_id;
  END IF;

  DELETE FROM participants WHERE id = p_target_id;
  PERFORM touch_room(v_room_id);
END;
$$;

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
  v_room_id UUID;
BEGIN
  IF p_from_participant_id = p_to_participant_id THEN
    RAISE EXCEPTION 'Non puoi passare il bancone a te stesso';
  END IF;

  v_room_id := assert_can_moderate(p_from_participant_id);

  SELECT * INTO v_to FROM participants WHERE id = p_to_participant_id;
  IF NOT FOUND OR v_to.room_id != v_room_id THEN
    RAISE EXCEPTION 'Cliente non trovato nello stesso locale';
  END IF;

  IF v_to.is_observer THEN
    RAISE EXCEPTION 'Un osservatore non può diventare barman';
  END IF;

  UPDATE participants
  SET
    is_facilitator = false,
    role = 'editor'::participant_role
  WHERE id = p_from_participant_id;

  UPDATE participants
  SET
    is_facilitator = true,
    role = 'facilitator'::participant_role
  WHERE id = p_to_participant_id;

  PERFORM touch_room(v_room_id);
END;
$$;

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

  UPDATE participants SET role = p_role WHERE id = p_target_id;

  PERFORM append_audit_event(
    v_room_id,
    p_facilitator_id,
    'role_changed',
    'Ruolo aggiornato a ' || p_role::TEXT,
    jsonb_build_object('target_id', p_target_id, 'role', p_role::TEXT)
  );

  PERFORM touch_room(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION set_final_estimate(
  p_participant_id UUID,
  p_story_id UUID,
  p_estimate TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story_room_id UUID;
  v_title TEXT;
BEGIN
  v_room_id := assert_can_moderate(p_participant_id);

  SELECT room_id, title INTO v_story_room_id, v_title
  FROM stories WHERE id = p_story_id;
  IF v_story_room_id IS NULL OR v_story_room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  UPDATE stories SET
    final_estimate = p_estimate,
    status = 'done',
    estimate_history = estimate_history || jsonb_build_array(
      jsonb_build_object(
        'estimate', p_estimate,
        'at', to_jsonb(now() AT TIME ZONE 'utc'),
        'kind', 'final'
      )
    )
  WHERE id = p_story_id;

  UPDATE rooms SET confidence_round_active = false WHERE id = v_room_id;

  PERFORM append_audit_event(
    v_room_id,
    p_participant_id,
    'estimate_finalized',
    'Stima finale «' || left(v_title, 80) || '»: ' || p_estimate,
    jsonb_build_object('story_id', p_story_id, 'estimate', p_estimate)
  );

  PERFORM touch_room(v_room_id);
END;
$$;

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
  v_room_id := assert_can_moderate(p_participant_id);

  SELECT current_story_id INTO v_story_id FROM rooms WHERE id = v_room_id;
  IF v_story_id IS NULL THEN
    RAISE EXCEPTION 'Nessun ordine in votazione';
  END IF;

  PERFORM perform_reveal(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION log_session_close(p_participant_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  v_room_id := assert_participant_access(p_participant_id);

  PERFORM append_audit_event(
    v_room_id,
    p_participant_id,
    'session_closed',
    'Sessione chiusa dal partecipante',
    '{}'::jsonb
  );

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
GRANT EXECUTE ON FUNCTION assert_participant_access(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_my_profile() TO authenticated;
GRANT EXECUTE ON FUNCTION upsert_my_profile(TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION link_participant_to_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION join_room(TEXT, TEXT, BOOLEAN, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION remove_participant(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION transfer_facilitator(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_participant_role(UUID, UUID, participant_role) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_final_estimate(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reveal_votes(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION log_session_close(UUID) TO anon, authenticated;
