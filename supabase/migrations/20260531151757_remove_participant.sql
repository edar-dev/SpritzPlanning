-- Phase 6: remove participant (kick AFK)

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
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_barman_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può rimuovere clienti';
  END IF;

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

GRANT EXECUTE ON FUNCTION remove_participant(UUID, UUID) TO anon, authenticated;
