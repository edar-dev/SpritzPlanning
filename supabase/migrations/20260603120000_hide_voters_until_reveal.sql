-- Phase 15: anonymous vote until reveal (#64)

ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS hide_voters_until_reveal BOOLEAN NOT NULL DEFAULT false;

DROP FUNCTION IF EXISTS set_room_settings(UUID, BOOLEAN);

CREATE OR REPLACE FUNCTION set_room_settings(
  p_participant_id UUID,
  p_auto_reveal_when_all_voted BOOLEAN,
  p_hide_voters_until_reveal BOOLEAN DEFAULT NULL
)
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
    RAISE EXCEPTION 'Solo il barman può modificare le impostazioni';
  END IF;

  UPDATE rooms SET
    auto_reveal_when_all_voted = p_auto_reveal_when_all_voted,
    hide_voters_until_reveal = COALESCE(
      p_hide_voters_until_reveal,
      hide_voters_until_reveal
    )
  WHERE id = v_room_id;

  PERFORM touch_room(v_room_id);
END;
$$;

GRANT EXECUTE ON FUNCTION set_room_settings(UUID, BOOLEAN, BOOLEAN) TO anon, authenticated;
