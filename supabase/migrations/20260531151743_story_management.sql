-- Phase 6: story edit and reorder

CREATE OR REPLACE FUNCTION update_story(
  p_participant_id UUID,
  p_story_id UUID,
  p_title TEXT,
  p_description TEXT DEFAULT ''
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

  UPDATE stories SET
    title = trim(p_title),
    description = COALESCE(trim(p_description), '')
  WHERE id = p_story_id;

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
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può riordinare ordini';
  END IF;

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

GRANT EXECUTE ON FUNCTION update_story(UUID, UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reorder_stories(UUID, UUID[]) TO anon, authenticated;
