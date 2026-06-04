-- Phase 18 (#80, #85, #83 MVP, #86): workspace metadata, audit trail, external links, health

-- ---------------------------------------------------------------------------
-- Room workspace branding (#80)
-- ---------------------------------------------------------------------------
ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS workspace_name TEXT,
  ADD COLUMN IF NOT EXISTS brand_color TEXT;

-- ---------------------------------------------------------------------------
-- Audit trail (#85)
-- ---------------------------------------------------------------------------
CREATE TYPE audit_event_kind AS ENUM (
  'role_changed',
  'votes_revealed',
  'estimate_finalized',
  'session_closed',
  'external_sync'
);

CREATE TABLE audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  participant_id UUID REFERENCES participants(id) ON DELETE SET NULL,
  kind audit_event_kind NOT NULL,
  summary TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_events_room_created
  ON audit_events(room_id, created_at DESC);

CREATE OR REPLACE FUNCTION append_audit_event(
  p_room_id UUID,
  p_participant_id UUID,
  p_kind audit_event_kind,
  p_summary TEXT,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_events (room_id, participant_id, kind, summary, metadata)
  VALUES (
    p_room_id,
    p_participant_id,
    p_kind,
    left(trim(p_summary), 500),
    COALESCE(p_metadata, '{}'::jsonb)
  );
END;
$$;

CREATE OR REPLACE FUNCTION get_room_audit_events(
  p_room_id UUID,
  p_limit INT DEFAULT 100
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_limit INT := LEAST(GREATEST(COALESCE(p_limit, 100), 1), 200);
BEGIN
  RETURN (
    SELECT COALESCE(json_agg(payload ORDER BY created_at DESC), '[]'::json)
    FROM (
      SELECT
        json_build_object(
          'id', id,
          'kind', kind::TEXT,
          'summary', summary,
          'metadata', metadata,
          'created_at', created_at,
          'participant_id', participant_id
        ) AS payload,
        created_at
      FROM audit_events
      WHERE room_id = p_room_id
      ORDER BY created_at DESC
      LIMIT v_limit
    ) sub
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- External story mapping (#83 MVP — mapping + audit; push via client)
-- ---------------------------------------------------------------------------
CREATE TABLE story_external_links (
  story_id UUID PRIMARY KEY REFERENCES stories(id) ON DELETE CASCADE,
  provider TEXT NOT NULL CHECK (provider IN ('jira', 'ado')),
  external_key TEXT NOT NULL,
  external_id TEXT,
  last_pushed_estimate TEXT,
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_story_external_links_story ON story_external_links(story_id);

CREATE OR REPLACE FUNCTION link_story_external(
  p_participant_id UUID,
  p_story_id UUID,
  p_provider TEXT,
  p_external_key TEXT,
  p_external_id TEXT DEFAULT NULL
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

  IF p_provider NOT IN ('jira', 'ado') THEN
    RAISE EXCEPTION 'Provider non supportato';
  END IF;

  IF char_length(trim(p_external_key)) < 1 THEN
    RAISE EXCEPTION 'Chiave esterna richiesta';
  END IF;

  INSERT INTO story_external_links (story_id, provider, external_key, external_id)
  VALUES (
    p_story_id,
    p_provider,
    trim(p_external_key),
    NULLIF(trim(p_external_id), '')
  )
  ON CONFLICT (story_id) DO UPDATE SET
    provider = EXCLUDED.provider,
    external_key = EXCLUDED.external_key,
    external_id = EXCLUDED.external_id;

  PERFORM append_audit_event(
    v_room_id,
    p_participant_id,
    'external_sync',
    'Collegato ordine a ' || p_provider || ' ' || trim(p_external_key),
    jsonb_build_object('story_id', p_story_id, 'provider', p_provider)
  );

  PERFORM touch_room(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION record_external_sync_push(
  p_participant_id UUID,
  p_story_id UUID,
  p_estimate TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_link story_external_links%ROWTYPE;
  v_story stories%ROWTYPE;
BEGIN
  v_room_id := assert_can_moderate(p_participant_id);

  SELECT * INTO v_story FROM stories WHERE id = p_story_id;
  IF v_story.id IS NULL OR v_story.room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  SELECT * INTO v_link FROM story_external_links WHERE story_id = p_story_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Nessun collegamento esterno per questo ordine';
  END IF;

  UPDATE story_external_links SET
    last_pushed_estimate = p_estimate,
    last_synced_at = now()
  WHERE story_id = p_story_id;

  PERFORM append_audit_event(
    v_room_id,
    p_participant_id,
    'external_sync',
    'Sync push ' || v_link.provider || ' ' || v_link.external_key || ' → ' || p_estimate,
    jsonb_build_object(
      'story_id', p_story_id,
      'provider', v_link.provider,
      'external_key', v_link.external_key,
      'estimate', p_estimate
    )
  );

  PERFORM touch_room(v_room_id);

  RETURN json_build_object(
    'provider', v_link.provider,
    'external_key', v_link.external_key,
    'estimate', p_estimate,
    'story_title', v_story.title
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Ops health snapshot (#86)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ops_health_snapshot()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN json_build_object(
    'checked_at', now(),
    'active_rooms_1h', (
      SELECT count(*)::INT FROM rooms
      WHERE last_activity_at > now() - interval '1 hour'
    ),
    'active_rooms_24h', (
      SELECT count(*)::INT FROM rooms
      WHERE last_activity_at > now() - interval '24 hours'
    ),
    'audit_events_24h', (
      SELECT count(*)::INT FROM audit_events
      WHERE created_at > now() - interval '24 hours'
    ),
    'external_links_total', (
      SELECT count(*)::INT FROM story_external_links
    ),
    'stories_done_24h', (
      SELECT count(*)::INT FROM stories
      WHERE status = 'done'
        AND created_at > now() - interval '24 hours'
    )
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- create_room (+ workspace branding)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_room(TEXT, TEXT, TEXT);

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
-- Audit hooks on critical RPCs
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
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può confermare la stima';
  END IF;

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

  PERFORM append_audit_event(
    p_room_id,
    NULL,
    'votes_revealed',
    'Voti rivelati',
    jsonb_build_object('story_id', v_story_id)
  );

  PERFORM touch_room(p_room_id);
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
  SELECT room_id INTO v_room_id FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Partecipante non trovato';
  END IF;

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

GRANT EXECUTE ON FUNCTION append_audit_event(UUID, UUID, audit_event_kind, TEXT, JSONB) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_room_audit_events(UUID, INT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION link_story_external(UUID, UUID, TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION record_external_sync_push(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_ops_health_snapshot() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION log_session_close(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;
