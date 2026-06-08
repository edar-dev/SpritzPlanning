-- Allow barman to switch active order mid-session: reset voting/revealed stories
-- and clear abandoned votes when start_voting targets a different story.

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

  DELETE FROM votes
  WHERE story_id IN (
    SELECT id FROM stories
    WHERE room_id = v_room_id AND status IN ('voting', 'revealed')
  );

  UPDATE stories SET status = 'pending'
  WHERE room_id = v_room_id AND status IN ('voting', 'revealed');

  UPDATE stories SET status = 'voting' WHERE id = p_story_id;

  UPDATE rooms SET
    phase = 'voting',
    current_story_id = p_story_id,
    votes_revealed = false,
    voting_deadline_at = CASE
      WHEN p_duration_seconds IS NOT NULL AND p_duration_seconds > 0
      THEN now() + make_interval(secs => p_duration_seconds)
      ELSE NULL
    END,
    confidence_round_active = false
  WHERE id = v_room_id;

  DELETE FROM votes WHERE story_id = p_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;
