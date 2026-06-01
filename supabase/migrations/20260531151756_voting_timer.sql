-- Phase 6: voting timer

ALTER TABLE rooms ADD COLUMN IF NOT EXISTS voting_deadline_at TIMESTAMPTZ;

DROP FUNCTION IF EXISTS start_voting(UUID, UUID);

CREATE OR REPLACE FUNCTION clear_voting_timer(p_room_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE rooms SET voting_deadline_at = NULL WHERE id = p_room_id;
END;
$$;

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
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può avviare la votazione';
  END IF;

  SELECT room_id INTO v_story_room_id FROM stories WHERE id = p_story_id;
  IF v_story_room_id IS NULL OR v_story_room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
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

  UPDATE rooms SET
    phase = 'revealed',
    votes_revealed = true,
    voting_deadline_at = NULL
  WHERE id = v_room_id;
  UPDATE stories SET status = 'revealed' WHERE id = v_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION reset_votes(p_participant_id UUID)
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
    RAISE EXCEPTION 'Solo il barman può resettare i voti';
  END IF;

  SELECT current_story_id INTO v_story_id FROM rooms WHERE id = v_room_id;
  IF v_story_id IS NULL THEN
    RAISE EXCEPTION 'Nessun ordine attivo';
  END IF;

  DELETE FROM votes WHERE story_id = v_story_id;
  UPDATE rooms SET
    phase = 'voting',
    votes_revealed = false,
    voting_deadline_at = NULL
  WHERE id = v_room_id;
  UPDATE stories SET status = 'voting' WHERE id = v_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION next_story(p_participant_id UUID)
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
    RAISE EXCEPTION 'Solo il barman può procedere';
  END IF;

  UPDATE rooms SET
    phase = 'lobby',
    current_story_id = NULL,
    votes_revealed = false,
    voting_deadline_at = NULL
  WHERE id = v_room_id;

  PERFORM touch_room(v_room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION start_voting(UUID, UUID, INT) TO anon, authenticated;
