-- SpritzPlanning initial schema

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Enums
CREATE TYPE room_phase AS ENUM ('lobby', 'voting', 'revealed');
CREATE TYPE story_status AS ENUM ('pending', 'voting', 'revealed', 'done');

-- Rooms (locales)
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  phase room_phase NOT NULL DEFAULT 'lobby',
  current_story_id UUID,
  votes_revealed BOOLEAN NOT NULL DEFAULT false,
  settings JSONB NOT NULL DEFAULT '{}'::jsonb,
  last_activity_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Participants (clienti)
CREATE TABLE participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  nickname TEXT NOT NULL,
  is_facilitator BOOLEAN NOT NULL DEFAULT false,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT nickname_not_empty CHECK (char_length(trim(nickname)) >= 2)
);

CREATE INDEX idx_participants_room_id ON participants(room_id);

-- Stories (ordini)
CREATE TABLE stories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  sort_order INT NOT NULL DEFAULT 0,
  status story_status NOT NULL DEFAULT 'pending',
  final_estimate TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT title_not_empty CHECK (char_length(trim(title)) >= 1)
);

CREATE INDEX idx_stories_room_id ON stories(room_id);

ALTER TABLE rooms
  ADD CONSTRAINT fk_rooms_current_story
  FOREIGN KEY (current_story_id) REFERENCES stories(id) ON DELETE SET NULL;

-- Votes (bicchieri)
CREATE TABLE votes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  participant_id UUID NOT NULL REFERENCES participants(id) ON DELETE CASCADE,
  value TEXT,
  voted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (story_id, participant_id)
);

CREATE INDEX idx_votes_story_id ON votes(story_id);

-- Helper: generate room code
CREATE OR REPLACE FUNCTION generate_room_code()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  suffix TEXT := '';
  i INT;
BEGIN
  FOR i IN 1..4 LOOP
    suffix := suffix || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN 'SPRT-' || suffix;
END;
$$;

-- Helper: touch room activity
CREATE OR REPLACE FUNCTION touch_room(p_room_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE rooms SET last_activity_at = now() WHERE id = p_room_id;
END;
$$;

-- RPC: create room
CREATE OR REPLACE FUNCTION create_room(p_name TEXT, p_nickname TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_participant_id UUID;
  v_code TEXT;
  v_attempts INT := 0;
BEGIN
  IF char_length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Nome locale troppo corto';
  END IF;
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  LOOP
    v_code := generate_room_code();
    BEGIN
      INSERT INTO rooms (code, name) VALUES (v_code, trim(p_name))
      RETURNING id INTO v_room_id;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      v_attempts := v_attempts + 1;
      IF v_attempts > 10 THEN
        RAISE EXCEPTION 'Impossibile generare codice stanza';
      END IF;
    END;
  END LOOP;

  INSERT INTO participants (room_id, nickname, is_facilitator)
  VALUES (v_room_id, trim(p_nickname), true)
  RETURNING id INTO v_participant_id;

  RETURN json_build_object(
    'room_id', v_room_id,
    'participant_id', v_participant_id,
    'code', v_code
  );
END;
$$;

-- RPC: join room
CREATE OR REPLACE FUNCTION join_room(p_code TEXT, p_nickname TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room rooms%ROWTYPE;
  v_participant_id UUID;
BEGIN
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE upper(code) = upper(trim(p_code));
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Locale non trovato';
  END IF;

  INSERT INTO participants (room_id, nickname, is_facilitator)
  VALUES (v_room.id, trim(p_nickname), false)
  RETURNING id INTO v_participant_id;

  PERFORM touch_room(v_room.id);

  RETURN json_build_object(
    'room_id', v_room.id,
    'participant_id', v_participant_id,
    'code', v_room.code
  );
END;
$$;

-- RPC: add story
CREATE OR REPLACE FUNCTION add_story(
  p_participant_id UUID,
  p_title TEXT,
  p_description TEXT DEFAULT ''
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
  v_story_id UUID;
  v_max_order INT;
BEGIN
  SELECT room_id INTO v_room_id FROM participants
  WHERE id = p_participant_id AND is_facilitator = true;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Solo il barman può aggiungere ordini';
  END IF;

  SELECT COALESCE(MAX(sort_order), -1) INTO v_max_order
  FROM stories WHERE room_id = v_room_id;

  INSERT INTO stories (room_id, title, description, sort_order)
  VALUES (v_room_id, trim(p_title), COALESCE(trim(p_description), ''), v_max_order + 1)
  RETURNING id INTO v_story_id;

  PERFORM touch_room(v_room_id);
  RETURN v_story_id;
END;
$$;

-- RPC: remove story
CREATE OR REPLACE FUNCTION remove_story(p_participant_id UUID, p_story_id UUID)
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
    RAISE EXCEPTION 'Solo il barman può rimuovere ordini';
  END IF;

  SELECT room_id INTO v_story_room_id FROM stories WHERE id = p_story_id;
  IF v_story_room_id IS NULL OR v_story_room_id != v_room_id THEN
    RAISE EXCEPTION 'Ordine non trovato';
  END IF;

  UPDATE rooms SET current_story_id = NULL
  WHERE id = v_room_id AND current_story_id = p_story_id;

  DELETE FROM stories WHERE id = p_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

-- RPC: start voting
CREATE OR REPLACE FUNCTION start_voting(p_participant_id UUID, p_story_id UUID)
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
    votes_revealed = false
  WHERE id = v_room_id;

  DELETE FROM votes WHERE story_id = p_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

-- RPC: cast vote
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
BEGIN
  SELECT * INTO v_participant FROM participants WHERE id = p_participant_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cliente non trovato';
  END IF;

  SELECT * INTO v_room FROM rooms WHERE id = v_participant.room_id;
  SELECT * INTO v_story FROM stories WHERE id = p_story_id;

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

-- RPC: reveal votes
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

  UPDATE rooms SET phase = 'revealed', votes_revealed = true WHERE id = v_room_id;
  UPDATE stories SET status = 'revealed' WHERE id = v_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

-- RPC: reset votes (new round on same story)
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
  UPDATE rooms SET phase = 'voting', votes_revealed = false WHERE id = v_room_id;
  UPDATE stories SET status = 'voting' WHERE id = v_story_id;
  PERFORM touch_room(v_room_id);
END;
$$;

-- RPC: set final estimate
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
    status = 'done'
  WHERE id = p_story_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- RPC: next story (return to lobby)
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
    votes_revealed = false
  WHERE id = v_room_id;

  PERFORM touch_room(v_room_id);
END;
$$;

-- RPC: heartbeat
CREATE OR REPLACE FUNCTION heartbeat(p_participant_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_room_id UUID;
BEGIN
  UPDATE participants SET last_seen_at = now()
  WHERE id = p_participant_id
  RETURNING room_id INTO v_room_id;

  IF v_room_id IS NOT NULL THEN
    PERFORM touch_room(v_room_id);
  END IF;
END;
$$;

-- RLS
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "rooms_select" ON rooms FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "rooms_update" ON rooms FOR UPDATE TO anon, authenticated USING (true);

CREATE POLICY "participants_select" ON participants FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "participants_insert" ON participants FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "participants_update" ON participants FOR UPDATE TO anon, authenticated USING (true);

CREATE POLICY "stories_select" ON stories FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "stories_insert" ON stories FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "stories_update" ON stories FOR UPDATE TO anon, authenticated USING (true);
CREATE POLICY "stories_delete" ON stories FOR DELETE TO anon, authenticated USING (true);

CREATE POLICY "votes_select" ON votes FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "votes_insert" ON votes FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "votes_update" ON votes FOR UPDATE TO anon, authenticated USING (true);
CREATE POLICY "votes_delete" ON votes FOR DELETE TO anon, authenticated USING (true);

-- Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE participants;
ALTER PUBLICATION supabase_realtime ADD TABLE stories;
ALTER PUBLICATION supabase_realtime ADD TABLE votes;

-- Grant execute on RPCs
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION join_room(TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION add_story(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION remove_story(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION start_voting(UUID, UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION cast_vote(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reveal_votes(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION reset_votes(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION set_final_estimate(UUID, UUID, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION next_story(UUID) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION heartbeat(UUID) TO anon, authenticated;
