-- Fix PostgREST PGRST203: drop legacy 2-arg overloads superseded by Phase 14.
-- create_room(text, text, text DEFAULT NULL) and join_room(text, text, boolean, text)
-- remain as the only public signatures.

DROP FUNCTION IF EXISTS create_room(TEXT, TEXT);
DROP FUNCTION IF EXISTS join_room(TEXT, TEXT);

GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION join_room(TEXT, TEXT, BOOLEAN, TEXT) TO anon, authenticated;
