-- Reset active story to pending when barman skips mid-vote via next_story.

CREATE OR REPLACE FUNCTION next_story(p_participant_id UUID)
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
    RAISE EXCEPTION 'Solo il barman può procedere';
  END IF;

  SELECT current_story_id INTO v_story_id FROM rooms WHERE id = v_room_id;

  IF v_story_id IS NOT NULL THEN
    DELETE FROM votes WHERE story_id = v_story_id;
    UPDATE stories SET status = 'pending'
    WHERE id = v_story_id AND status IN ('voting', 'revealed');
  END IF;

  UPDATE stories SET status = 'pending'
  WHERE room_id = v_room_id AND status IN ('voting', 'revealed');

  UPDATE rooms SET
    phase = 'lobby',
    current_story_id = NULL,
    votes_revealed = false,
    voting_deadline_at = NULL,
    confidence_round_active = false
  WHERE id = v_room_id;

  PERFORM touch_room(v_room_id);
END;
$$;
