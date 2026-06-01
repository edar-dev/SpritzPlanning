-- Transfer barman role to another participant in the same room

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
BEGIN
  IF p_from_participant_id = p_to_participant_id THEN
    RAISE EXCEPTION 'Non puoi passare il bancone a te stesso';
  END IF;

  SELECT * INTO v_from FROM participants WHERE id = p_from_participant_id;
  IF NOT FOUND OR NOT v_from.is_facilitator THEN
    RAISE EXCEPTION 'Solo il barman può passare il bancone';
  END IF;

  SELECT * INTO v_to FROM participants WHERE id = p_to_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  IF v_to.room_id != v_from.room_id THEN
    RAISE EXCEPTION 'I clienti devono essere nello stesso locale';
  END IF;

  UPDATE participants
  SET is_facilitator = false
  WHERE room_id = v_from.room_id;

  UPDATE participants
  SET is_facilitator = true
  WHERE id = p_to_participant_id;

  PERFORM touch_room(v_from.room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION transfer_facilitator(UUID, UUID) TO anon, authenticated;
