-- Phase 16: reference story, public comments, confidence votes, estimate history, push subscription

ALTER TABLE stories
  ADD COLUMN IF NOT EXISTS is_reference BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS public_comment TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS estimate_history JSONB NOT NULL DEFAULT '[]'::jsonb;

ALTER TABLE participants
  ADD COLUMN IF NOT EXISTS push_subscription JSONB;

ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS confidence_round_active BOOLEAN NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS confidence_votes (
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  participant_id UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  value SMALLINT NOT NULL CHECK (value BETWEEN 1 AND 5),
  voted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (story_id, participant_id)
);

ALTER TABLE confidence_votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "confidence_votes_select" ON confidence_votes
  FOR SELECT TO anon, authenticated USING (true);

-- ---------------------------------------------------------------------------
-- set_reference_story
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_reference_story(
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
    RAISE EXCEPTION 'Solo il barman può impostare lo story di riferimento';
  END IF;

  SELECT * INTO v_story FROM stories WHERE id = p_story_id;
  IF v_story.id IS NULL OR v_story.room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  UPDATE stories SET is_reference = false WHERE room_id = v_room_id;
  UPDATE stories SET is_reference = true WHERE id = p_story_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- set_story_public_comment (any participant in room)
-- ---------------------------------------------------------------------------
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
  SELECT room_id INTO v_room_id FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

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

-- ---------------------------------------------------------------------------
-- confidence vote round
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION start_confidence_vote(p_participant_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room rooms%ROWTYPE;
BEGIN
  SELECT r.* INTO v_room FROM rooms r
  JOIN participants p ON p.room_id = r.id
  WHERE p.id = p_participant_id AND p.is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può avviare il confidence vote';
  END IF;
  IF NOT v_room.votes_revealed OR v_room.current_story_id IS NULL THEN
    RAISE EXCEPTION 'Disponibile solo dopo il reveal';
  END IF;

  DELETE FROM confidence_votes WHERE story_id = v_room.current_story_id;
  UPDATE rooms SET confidence_round_active = true WHERE id = v_room.id;

  PERFORM touch_room(v_room.id);
END;
$$;

CREATE OR REPLACE FUNCTION cast_confidence_vote(
  p_participant_id UUID,
  p_value SMALLINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_participant participants%ROWTYPE;
  v_room rooms%ROWTYPE;
BEGIN
  IF p_value IS NULL OR p_value < 1 OR p_value > 5 THEN
    RAISE EXCEPTION 'Valore confidence non valido';
  END IF;

  SELECT * INTO v_participant FROM participants WHERE id = p_participant_id;
  IF NOT FOUND OR v_participant.is_observer THEN
    RAISE EXCEPTION 'Non autorizzato';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE id = v_participant.room_id;
  IF NOT v_room.confidence_round_active OR v_room.current_story_id IS NULL THEN
    RAISE EXCEPTION 'Confidence vote non attivo';
  END IF;

  INSERT INTO confidence_votes (story_id, participant_id, value)
  VALUES (v_room.current_story_id, p_participant_id, p_value)
  ON CONFLICT (story_id, participant_id)
  DO UPDATE SET value = EXCLUDED.value, voted_at = now();

  PERFORM touch_room(v_room.id);
END;
$$;

CREATE OR REPLACE FUNCTION end_confidence_vote(p_participant_id UUID)
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
    RAISE EXCEPTION 'Solo il barman può chiudere il confidence vote';
  END IF;

  UPDATE rooms SET confidence_round_active = false WHERE id = v_room_id;
  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- register_push_subscription
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION register_push_subscription(
  p_participant_id UUID,
  p_subscription JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE participants SET push_subscription = p_subscription
  WHERE id = p_participant_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- set_final_estimate (+ estimate history)
-- ---------------------------------------------------------------------------
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
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può confermare la stima';
  END IF;

  SELECT room_id INTO v_story_room_id FROM stories WHERE id = p_story_id;
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

  PERFORM touch_room(v_room_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- mark_story_spike (+ history)
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
    final_estimate = '—',
    estimate_history = estimate_history || jsonb_build_array(
      jsonb_build_object(
        'estimate', '—',
        'at', to_jsonb(now() AT TIME ZONE 'utc'),
        'kind', 'spike'
      )
    )
  WHERE id = p_story_id;

  UPDATE rooms SET
    phase = 'lobby',
    current_story_id = NULL,
    votes_revealed = false,
    voting_deadline_at = NULL,
    confidence_round_active = false
  WHERE id = v_room_id AND current_story_id = p_story_id;

  PERFORM touch_room(v_room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION set_reference_story(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_story_public_comment(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION start_confidence_vote(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cast_confidence_vote(UUID, SMALLINT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION end_confidence_vote(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION register_push_subscription(UUID, JSONB) TO anon, authenticated;
