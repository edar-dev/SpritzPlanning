-- Phase 7: customizable deck per room

ALTER TABLE rooms ADD COLUMN IF NOT EXISTS deck_values JSONB
  NOT NULL DEFAULT '["0","½","1","2","3","5","8","13","21","?","☕"]'::jsonb;

ALTER TABLE rooms ADD COLUMN IF NOT EXISTS allow_coffee_break BOOLEAN
  NOT NULL DEFAULT true;

UPDATE rooms SET deck_values = '["0","½","1","2","3","5","8","13","21","?","☕"]'::jsonb
WHERE deck_values IS NULL;

CREATE OR REPLACE FUNCTION set_room_deck(
  p_participant_id UUID,
  p_deck_values JSONB,
  p_allow_coffee_break BOOLEAN DEFAULT true
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_room_phase room_phase;
  v_value TEXT;
  v_count INT;
  v_clean TEXT[] := ARRAY[]::TEXT[];
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può modificare il deck';
  END IF;

  SELECT phase INTO v_room_phase FROM rooms WHERE id = v_room_id;
  IF v_room_phase != 'lobby' THEN
    RAISE EXCEPTION 'Deck modificabile solo in lobby';
  END IF;

  IF p_deck_values IS NULL OR jsonb_typeof(p_deck_values) != 'array' THEN
    RAISE EXCEPTION 'Deck non valido';
  END IF;

  v_count := jsonb_array_length(p_deck_values);
  IF v_count < 1 OR v_count > 20 THEN
    RAISE EXCEPTION 'Il deck deve avere tra 1 e 20 valori';
  END IF;

  FOR v_value IN SELECT jsonb_array_elements_text(p_deck_values) LOOP
    IF v_value IS NULL OR char_length(trim(v_value)) < 1 THEN
      RAISE EXCEPTION 'Valore deck vuoto non consentito';
    END IF;
    IF trim(v_value) = '☕' AND NOT p_allow_coffee_break THEN
      CONTINUE;
    END IF;
    v_clean := array_append(v_clean, trim(v_value));
  END LOOP;

  IF array_length(v_clean, 1) IS NULL OR array_length(v_clean, 1) < 1 THEN
    RAISE EXCEPTION 'Deck non valido';
  END IF;

  UPDATE rooms SET
    deck_values = to_jsonb(v_clean),
    allow_coffee_break = p_allow_coffee_break
  WHERE id = v_room_id;

  PERFORM touch_room(v_room_id);
END;
$$;

CREATE OR REPLACE FUNCTION cast_vote(
  p_participant_id UUID,
  p_story_id UUID,
  p_value TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_participant participants%ROWTYPE;
  v_room rooms%ROWTYPE;
  v_story stories%ROWTYPE;
  v_allowed TEXT[];
BEGIN
  SELECT * INTO v_participant FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE id = v_participant.room_id;
  SELECT * INTO v_story FROM stories WHERE id = p_story_id;

  SELECT array_agg(elem::TEXT)
  INTO v_allowed
  FROM jsonb_array_elements_text(v_room.deck_values) AS elem;

  IF p_value IS NULL OR NOT (p_value = ANY (v_allowed)) THEN
    RAISE EXCEPTION 'Valore voto non valido';
  END IF;

  IF v_story.id IS NULL OR v_story.room_id != v_room.id THEN
    RAISE EXCEPTION 'Ordine non valido';
  END IF;
  IF v_room.phase != 'voting' OR v_room.current_story_id != p_story_id THEN
    RAISE EXCEPTION 'Votazione non attiva';
  END IF;
  IF v_room.votes_revealed THEN
    RAISE EXCEPTION 'Voti già rivelati';
  END IF;

  INSERT INTO votes (story_id, participant_id, value, voted_at)
  VALUES (p_story_id, p_participant_id, p_value, now())
  ON CONFLICT (story_id, participant_id)
  DO UPDATE SET value = EXCLUDED.value, voted_at = now();

  UPDATE participants SET last_seen_at = now() WHERE id = p_participant_id;
  PERFORM touch_room(v_room.id);
END;
$$;

GRANT EXECUTE ON FUNCTION set_room_deck(UUID, JSONB, BOOLEAN) TO anon, authenticated;
