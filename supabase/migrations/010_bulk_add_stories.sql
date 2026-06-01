-- Bulk add stories (facilitator only), max 50 titles per call.

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
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può aggiungere ordini';
  END IF;

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

GRANT EXECUTE ON FUNCTION add_stories(UUID, TEXT[]) TO anon, authenticated;
