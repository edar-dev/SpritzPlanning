-- Phase 20 (#92–#95, #97): organizations, cloud workspaces, entitlements, audit actor

-- ---------------------------------------------------------------------------
-- Types
-- ---------------------------------------------------------------------------
CREATE TYPE org_member_role AS ENUM ('owner', 'admin', 'member');
CREATE TYPE commercial_plan_tier AS ENUM ('free', 'pro', 'team');

-- ---------------------------------------------------------------------------
-- Organizations & membership (#93)
-- ---------------------------------------------------------------------------
CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  plan_tier commercial_plan_tier NOT NULL DEFAULT 'free',
  stripe_customer_id TEXT,
  subscription_status TEXT,
  grace_until TIMESTAMPTZ,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT org_name_not_empty CHECK (char_length(trim(name)) >= 2)
);

CREATE TABLE org_members (
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role org_member_role NOT NULL DEFAULT 'member',
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (org_id, user_id)
);

CREATE INDEX idx_org_members_user ON org_members(user_id);

CREATE TABLE org_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  token TEXT NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  invited_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at TIMESTAMPTZ
);

CREATE INDEX idx_org_invites_token ON org_invites(token) WHERE accepted_at IS NULL;

-- ---------------------------------------------------------------------------
-- Cloud workspaces (#92)
-- ---------------------------------------------------------------------------
CREATE TABLE workspaces (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  brand_color TEXT,
  deck_values JSONB NOT NULL DEFAULT '[]'::jsonb,
  logo_emoji TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT workspace_name_not_empty CHECK (char_length(trim(name)) >= 1)
);

CREATE INDEX idx_workspaces_org ON workspaces(org_id);

-- ---------------------------------------------------------------------------
-- Rooms + profile active org
-- ---------------------------------------------------------------------------
ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS org_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS workspace_id UUID REFERENCES workspaces(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_rooms_org ON rooms(org_id);

ALTER TABLE user_profiles
  ADD COLUMN IF NOT EXISTS active_org_id UUID REFERENCES organizations(id) ON DELETE SET NULL;

-- ---------------------------------------------------------------------------
-- Audit actor (#97)
-- ---------------------------------------------------------------------------
ALTER TABLE audit_events
  ADD COLUMN IF NOT EXISTS actor_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION org_role_rank(p_role org_member_role)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE p_role
    WHEN 'owner' THEN 3
    WHEN 'admin' THEN 2
    ELSE 1
  END;
$$;

CREATE OR REPLACE FUNCTION plan_tier_rank(p_tier commercial_plan_tier)
RETURNS INT
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE p_tier
    WHEN 'team' THEN 3
    WHEN 'pro' THEN 2
    ELSE 1
  END;
$$;

CREATE OR REPLACE FUNCTION slugify_org_name(p_name TEXT)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  v_slug TEXT;
BEGIN
  v_slug := lower(regexp_replace(trim(p_name), '[^a-zA-Z0-9]+', '-', 'g'));
  v_slug := trim(both '-' from v_slug);
  IF v_slug = '' THEN
    v_slug := 'team';
  END IF;
  RETURN left(v_slug, 40);
END;
$$;

CREATE OR REPLACE FUNCTION assert_org_member(
  p_org_id UUID,
  p_min_role org_member_role DEFAULT 'member'
)
RETURNS org_member_role
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_role org_member_role;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;

  SELECT role INTO v_role
  FROM org_members
  WHERE org_id = p_org_id AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Non sei membro di questa organizzazione';
  END IF;

  IF org_role_rank(v_role) < org_role_rank(p_min_role) THEN
    RAISE EXCEPTION 'Permessi insufficienti nell''organizzazione';
  END IF;

  RETURN v_role;
END;
$$;

CREATE OR REPLACE FUNCTION effective_org_plan_tier(p_org_id UUID)
RETURNS commercial_plan_tier
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_org organizations%ROWTYPE;
BEGIN
  SELECT * INTO v_org FROM organizations WHERE id = p_org_id;
  IF NOT FOUND THEN
    RETURN 'free'::commercial_plan_tier;
  END IF;

  IF v_org.grace_until IS NOT NULL AND v_org.grace_until > now() THEN
    RETURN v_org.plan_tier;
  END IF;

  IF v_org.subscription_status IN ('active', 'trialing') THEN
    RETURN v_org.plan_tier;
  END IF;

  IF v_org.subscription_status IS NULL AND v_org.plan_tier != 'free' THEN
    -- Demo / manual tier without Stripe subscription row
    RETURN v_org.plan_tier;
  END IF;

  RETURN 'free'::commercial_plan_tier;
END;
$$;

-- ---------------------------------------------------------------------------
-- #93 Organizations RPCs
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_organization(p_name TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_org_id UUID;
  v_slug TEXT;
  v_suffix INT := 0;
  v_ws_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;
  IF char_length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Nome organizzazione troppo corto';
  END IF;

  v_slug := slugify_org_name(p_name);
  LOOP
    BEGIN
      INSERT INTO organizations (name, slug, created_by)
      VALUES (trim(p_name), CASE WHEN v_suffix = 0 THEN v_slug ELSE v_slug || '-' || v_suffix END, auth.uid())
      RETURNING id INTO v_org_id;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      v_suffix := v_suffix + 1;
      IF v_suffix > 50 THEN
        RAISE EXCEPTION 'Impossibile creare slug organizzazione';
      END IF;
    END;
  END LOOP;

  INSERT INTO org_members (org_id, user_id, role)
  VALUES (v_org_id, auth.uid(), 'owner');

  INSERT INTO workspaces (org_id, name, brand_color, deck_values, logo_emoji)
  VALUES (v_org_id, 'Default', '#5c6b42', '[]'::jsonb, '🍹')
  RETURNING id INTO v_ws_id;

  UPDATE user_profiles
  SET active_org_id = v_org_id, updated_at = now()
  WHERE id = auth.uid();

  RETURN json_build_object(
    'org_id', v_org_id,
    'workspace_id', v_ws_id,
    'slug', (SELECT slug FROM organizations WHERE id = v_org_id)
  );
END;
$$;

CREATE OR REPLACE FUNCTION list_my_organizations()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;

  RETURN (
    SELECT COALESCE(json_agg(row ORDER BY joined_at), '[]'::json)
    FROM (
      SELECT json_build_object(
        'id', o.id,
        'name', o.name,
        'slug', o.slug,
        'role', m.role::TEXT,
        'plan_tier', effective_org_plan_tier(o.id)::TEXT,
        'joined_at', m.joined_at
      ) AS row,
      m.joined_at
      FROM org_members m
      JOIN organizations o ON o.id = m.org_id
      WHERE m.user_id = auth.uid()
      ORDER BY m.joined_at
    ) sub
  );
END;
$$;

CREATE OR REPLACE FUNCTION set_active_organization(p_org_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM assert_org_member(p_org_id, 'member');

  UPDATE user_profiles
  SET active_org_id = p_org_id, updated_at = now()
  WHERE id = auth.uid();

  RETURN json_build_object('active_org_id', p_org_id);
END;
$$;

CREATE OR REPLACE FUNCTION get_active_organization()
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_org_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT active_org_id INTO v_org_id FROM user_profiles WHERE id = auth.uid();
  IF v_org_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM org_members WHERE org_id = v_org_id AND user_id = auth.uid()
  ) THEN
    RETURN NULL;
  END IF;

  RETURN (
    SELECT json_build_object(
      'id', o.id,
      'name', o.name,
      'slug', o.slug,
      'role', m.role::TEXT,
      'plan_tier', effective_org_plan_tier(o.id)::TEXT
    )
    FROM organizations o
    JOIN org_members m ON m.org_id = o.id AND m.user_id = auth.uid()
    WHERE o.id = v_org_id
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- #94 Invites
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_org_invite(p_org_id UUID, p_email TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_token TEXT;
  v_invite_id UUID;
BEGIN
  PERFORM assert_org_member(p_org_id, 'admin');

  IF p_email IS NULL OR position('@' IN trim(p_email)) = 0 THEN
    RAISE EXCEPTION 'Email non valida';
  END IF;

  v_token := encode(gen_random_bytes(24), 'hex');

  INSERT INTO org_invites (org_id, email, token, expires_at, invited_by)
  VALUES (
    p_org_id,
    lower(trim(p_email)),
    v_token,
    now() + interval '7 days',
    auth.uid()
  )
  RETURNING id INTO v_invite_id;

  RETURN json_build_object(
    'invite_id', v_invite_id,
    'token', v_token,
    'expires_at', (SELECT expires_at FROM org_invites WHERE id = v_invite_id)
  );
END;
$$;

CREATE OR REPLACE FUNCTION accept_org_invite(p_token TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_invite org_invites%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Accesso richiesto';
  END IF;

  SELECT * INTO v_invite
  FROM org_invites
  WHERE token = trim(p_token) AND accepted_at IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invito non valido o già usato';
  END IF;

  IF v_invite.expires_at < now() THEN
    RAISE EXCEPTION 'Invito scaduto';
  END IF;

  INSERT INTO org_members (org_id, user_id, role)
  VALUES (v_invite.org_id, auth.uid(), 'member')
  ON CONFLICT (org_id, user_id) DO NOTHING;

  UPDATE org_invites SET accepted_at = now() WHERE id = v_invite.id;

  UPDATE user_profiles
  SET active_org_id = v_invite.org_id, updated_at = now()
  WHERE id = auth.uid();

  RETURN json_build_object('org_id', v_invite.org_id);
END;
$$;

-- ---------------------------------------------------------------------------
-- #92 Workspaces RPCs
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION list_workspaces(p_org_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM assert_org_member(p_org_id, 'member');

  RETURN (
    SELECT COALESCE(json_agg(json_build_object(
      'id', w.id,
      'org_id', w.org_id,
      'name', w.name,
      'brand_color', w.brand_color,
      'deck_values', w.deck_values,
      'logo_emoji', w.logo_emoji,
      'updated_at', w.updated_at
    ) ORDER BY w.updated_at DESC), '[]'::json)
    FROM workspaces w
    WHERE w.org_id = p_org_id
  );
END;
$$;

CREATE OR REPLACE FUNCTION upsert_workspace(
  p_org_id UUID,
  p_name TEXT,
  p_brand_color TEXT DEFAULT NULL,
  p_deck_values JSONB DEFAULT '[]'::jsonb,
  p_logo_emoji TEXT DEFAULT NULL,
  p_workspace_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_row workspaces%ROWTYPE;
  v_count INT;
  v_tier commercial_plan_tier;
BEGIN
  PERFORM assert_org_member(p_org_id, 'admin');
  v_tier := effective_org_plan_tier(p_org_id);

  IF char_length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Nome workspace troppo corto';
  END IF;

  IF p_workspace_id IS NULL THEN
    SELECT count(*) INTO v_count FROM workspaces WHERE org_id = p_org_id;
    IF v_count >= 1 AND plan_tier_rank(v_tier) < plan_tier_rank('team'::commercial_plan_tier) THEN
      RAISE EXCEPTION 'Piano Team richiesto per workspace multipli';
    END IF;
    IF v_count >= 8 THEN
      RAISE EXCEPTION 'Limite workspace raggiunto';
    END IF;

    INSERT INTO workspaces (org_id, name, brand_color, deck_values, logo_emoji)
    VALUES (
      p_org_id,
      trim(p_name),
      NULLIF(trim(p_brand_color), ''),
      COALESCE(p_deck_values, '[]'::jsonb),
      NULLIF(trim(p_logo_emoji), '')
    )
    RETURNING * INTO v_row;
  ELSE
    UPDATE workspaces
    SET
      name = trim(p_name),
      brand_color = NULLIF(trim(p_brand_color), ''),
      deck_values = COALESCE(p_deck_values, deck_values),
      logo_emoji = COALESCE(NULLIF(trim(p_logo_emoji), ''), logo_emoji),
      updated_at = now()
    WHERE id = p_workspace_id AND org_id = p_org_id
    RETURNING * INTO v_row;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Workspace non trovato';
    END IF;
  END IF;

  RETURN json_build_object(
    'id', v_row.id,
    'org_id', v_row.org_id,
    'name', v_row.name,
    'brand_color', v_row.brand_color,
    'deck_values', v_row.deck_values,
    'logo_emoji', v_row.logo_emoji,
    'updated_at', v_row.updated_at
  );
END;
$$;

CREATE OR REPLACE FUNCTION import_local_workspaces(p_org_id UUID, p_payload JSONB)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_item JSONB;
  v_count INT := 0;
BEGIN
  PERFORM assert_org_member(p_org_id, 'admin');

  IF p_payload IS NULL OR jsonb_typeof(p_payload) != 'array' THEN
    RETURN 0;
  END IF;

  FOR v_item IN SELECT value FROM jsonb_array_elements(p_payload)
  LOOP
    INSERT INTO workspaces (org_id, name, brand_color, deck_values, logo_emoji)
    VALUES (
      p_org_id,
      left(trim(v_item->>'name'), 80),
      NULLIF(trim(v_item->>'brand_color'), ''),
      COALESCE(v_item->'deck_values', '[]'::jsonb),
      NULLIF(trim(v_item->>'logo_emoji'), '')
    );
    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

-- ---------------------------------------------------------------------------
-- #95 Entitlements
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_org_entitlements(p_org_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tier commercial_plan_tier;
  v_rank INT;
BEGIN
  IF auth.uid() IS NOT NULL THEN
    PERFORM assert_org_member(p_org_id, 'member');
  END IF;

  v_tier := effective_org_plan_tier(p_org_id);
  v_rank := plan_tier_rank(v_tier);

  RETURN json_build_object(
    'org_id', p_org_id,
    'plan_tier', v_tier::TEXT,
    'can_use_executive_report', v_rank >= plan_tier_rank('pro'::commercial_plan_tier),
    'can_use_advanced_kpi', v_rank >= plan_tier_rank('pro'::commercial_plan_tier),
    'can_use_ops_health', v_rank >= plan_tier_rank('pro'::commercial_plan_tier),
    'can_use_multi_workspace', v_rank >= plan_tier_rank('team'::commercial_plan_tier),
    'can_use_audit_trail', v_rank >= plan_tier_rank('team'::commercial_plan_tier),
    'can_use_external_sync', v_rank >= plan_tier_rank('team'::commercial_plan_tier)
  );
END;
$$;

CREATE OR REPLACE FUNCTION check_entitlement(
  p_org_id UUID,
  p_feature TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v JSON;
BEGIN
  v := get_org_entitlements(p_org_id);
  RETURN COALESCE((v ->> p_feature)::BOOLEAN, false);
END;
$$;

CREATE OR REPLACE FUNCTION set_org_plan_tier(
  p_org_id UUID,
  p_tier commercial_plan_tier
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM assert_org_member(p_org_id, 'owner');

  UPDATE organizations
  SET
    plan_tier = p_tier,
    grace_until = now() + interval '24 hours',
    subscription_status = COALESCE(subscription_status, 'demo')
  WHERE id = p_org_id;

  RETURN get_org_entitlements(p_org_id);
END;
$$;

CREATE OR REPLACE FUNCTION apply_org_billing_update(
  p_org_id UUID,
  p_tier commercial_plan_tier,
  p_subscription_status TEXT,
  p_stripe_customer_id TEXT DEFAULT NULL,
  p_grace_until TIMESTAMPTZ DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE organizations
  SET
    plan_tier = p_tier,
    subscription_status = p_subscription_status,
    stripe_customer_id = COALESCE(p_stripe_customer_id, stripe_customer_id),
    grace_until = p_grace_until
  WHERE id = p_org_id;
END;
$$;

-- ---------------------------------------------------------------------------
-- Audit (#97)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION append_audit_event(
  p_room_id UUID,
  p_participant_id UUID,
  p_kind audit_event_kind,
  p_summary TEXT,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO audit_events (
    room_id, participant_id, actor_user_id, kind, summary, metadata
  )
  VALUES (
    p_room_id,
    p_participant_id,
    auth.uid(),
    p_kind,
    left(trim(p_summary), 500),
    COALESCE(p_metadata, '{}'::jsonb)
  );
END;
$$;

CREATE OR REPLACE FUNCTION get_room_audit_events(
  p_room_id UUID,
  p_limit INT DEFAULT 100
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_limit INT := LEAST(GREATEST(COALESCE(p_limit, 100), 1), 200);
BEGIN
  RETURN (
    SELECT COALESCE(json_agg(payload ORDER BY created_at DESC), '[]'::json)
    FROM (
      SELECT
        json_build_object(
          'id', ae.id,
          'kind', ae.kind::TEXT,
          'summary', ae.summary,
          'metadata', ae.metadata,
          'created_at', ae.created_at,
          'participant_id', ae.participant_id,
          'actor_user_id', ae.actor_user_id,
          'actor_display_name', COALESCE(up.display_name, '')
        ) AS payload,
        ae.created_at
      FROM audit_events ae
      LEFT JOIN user_profiles up ON up.id = ae.actor_user_id
      WHERE ae.room_id = p_room_id
      ORDER BY ae.created_at DESC
      LIMIT v_limit
    ) sub
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- create_room (+ org / workspace) & rate limit per user (#96)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS create_room(TEXT, TEXT, TEXT, TEXT, TEXT);

CREATE OR REPLACE FUNCTION create_room(
  p_name TEXT,
  p_nickname TEXT,
  p_pin TEXT DEFAULT NULL,
  p_workspace_name TEXT DEFAULT NULL,
  p_brand_color TEXT DEFAULT NULL,
  p_org_id UUID DEFAULT NULL,
  p_workspace_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_room_id UUID;
  v_participant_id UUID;
  v_code TEXT;
  v_attempts INT := 0;
  v_pin_hash TEXT;
  v_ws workspaces%ROWTYPE;
  v_org_id UUID;
  v_rate_key TEXT;
BEGIN
  v_rate_key := CASE
    WHEN auth.uid() IS NOT NULL THEN 'create_room_user_' || auth.uid()::TEXT
    ELSE 'create_room'
  END;
  PERFORM check_rate_limit(v_rate_key, 20, interval '1 hour');

  IF char_length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Nome locale troppo corto';
  END IF;
  IF char_length(trim(p_nickname)) < 2 THEN
    RAISE EXCEPTION 'Nickname troppo corto';
  END IF;

  v_org_id := p_org_id;
  IF v_org_id IS NULL AND auth.uid() IS NOT NULL THEN
    SELECT active_org_id INTO v_org_id FROM user_profiles WHERE id = auth.uid();
  END IF;

  IF v_org_id IS NOT NULL AND auth.uid() IS NOT NULL THEN
    PERFORM assert_org_member(v_org_id, 'member');
  END IF;

  IF p_workspace_id IS NOT NULL THEN
    SELECT * INTO v_ws FROM workspaces WHERE id = p_workspace_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Workspace non trovato';
    END IF;
    IF v_org_id IS NOT NULL AND v_ws.org_id != v_org_id THEN
      RAISE EXCEPTION 'Workspace non appartiene all''organizzazione';
    END IF;
    v_org_id := COALESCE(v_org_id, v_ws.org_id);
    p_workspace_name := COALESCE(p_workspace_name, v_ws.name);
    p_brand_color := COALESCE(p_brand_color, v_ws.brand_color);
  END IF;

  IF p_pin IS NOT NULL AND trim(p_pin) != '' THEN
    IF trim(p_pin) !~ '^[0-9]{4,6}$' THEN
      RAISE EXCEPTION 'PIN deve essere di 4-6 cifre';
    END IF;
    v_pin_hash := crypt(trim(p_pin), gen_salt('bf'::TEXT));
  END IF;

  LOOP
    v_code := generate_room_code();
    BEGIN
      INSERT INTO rooms (
        code, name, join_pin_hash, workspace_name, brand_color, org_id, workspace_id
      )
      VALUES (
        v_code,
        trim(p_name),
        v_pin_hash,
        NULLIF(trim(p_workspace_name), ''),
        NULLIF(trim(p_brand_color), ''),
        v_org_id,
        p_workspace_id
      )
      RETURNING id INTO v_room_id;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      v_attempts := v_attempts + 1;
      IF v_attempts > 10 THEN
        RAISE EXCEPTION 'Impossibile generare codice stanza';
      END IF;
    END;
  END LOOP;

  INSERT INTO participants (
    room_id, nickname, is_facilitator, is_observer, role, user_id
  )
  VALUES (
    v_room_id, trim(p_nickname), true, false, 'facilitator'::participant_role, auth.uid()
  )
  RETURNING id INTO v_participant_id;

  RETURN json_build_object(
    'room_id', v_room_id,
    'participant_id', v_participant_id,
    'code', v_code
  );
END;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
GRANT EXECUTE ON FUNCTION create_organization(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION list_my_organizations() TO authenticated;
GRANT EXECUTE ON FUNCTION set_active_organization(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_active_organization() TO authenticated;
GRANT EXECUTE ON FUNCTION create_org_invite(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION accept_org_invite(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION list_workspaces(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION upsert_workspace(UUID, TEXT, TEXT, JSONB, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION import_local_workspaces(UUID, JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION get_org_entitlements(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION check_entitlement(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION set_org_plan_tier(UUID, commercial_plan_tier) TO authenticated;
GRANT EXECUTE ON FUNCTION apply_org_billing_update(UUID, commercial_plan_tier, TEXT, TEXT, TIMESTAMPTZ) TO service_role;
GRANT EXECUTE ON FUNCTION create_room(TEXT, TEXT, TEXT, TEXT, TEXT, UUID, UUID) TO anon, authenticated;
