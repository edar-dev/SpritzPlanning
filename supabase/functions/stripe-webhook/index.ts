import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.49.1';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type, stripe-signature',
};

type PlanTier = 'free' | 'pro' | 'team';

function mapStripeStatus(status: string | undefined): string {
  if (status === 'active' || status === 'trialing') return status;
  if (status === 'canceled' || status === 'unpaid') return 'canceled';
  return 'inactive';
}

function tierFromMetadata(meta: Record<string, string> | undefined): PlanTier {
  const raw = meta?.plan_tier?.toLowerCase();
  if (raw === 'pro' || raw === 'team') return raw;
  return 'pro';
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !serviceKey) {
    return new Response('Missing Supabase env', { status: 500 });
  }

  const admin = createClient(supabaseUrl, serviceKey);

  try {
    const body = await req.json();
    let orgId: string | undefined;
    let tier: PlanTier = 'pro';
    let status = 'active';
    let customerId: string | undefined;
    let graceUntil: string | null = null;

    if (body.type?.startsWith('customer.subscription')) {
      const sub = body.data?.object;
      orgId = sub?.metadata?.org_id;
      tier = tierFromMetadata(sub?.metadata);
      status = mapStripeStatus(sub?.status);
      customerId = sub?.customer;
      if (sub?.cancel_at_period_end && sub?.current_period_end) {
        graceUntil = new Date(sub.current_period_end * 1000).toISOString();
      }
    } else if (body.type === 'checkout.session.completed') {
      const session = body.data?.object;
      orgId = session?.metadata?.org_id;
      tier = tierFromMetadata(session?.metadata);
      customerId = session?.customer;
      status = 'active';
    } else if (body.org_id) {
      orgId = body.org_id;
      tier = tierFromMetadata(body);
      status = body.subscription_status ?? 'active';
      customerId = body.stripe_customer_id;
    }

    if (!orgId) {
      return new Response(JSON.stringify({ ok: false, reason: 'no org_id' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const { error } = await admin.rpc('apply_org_billing_update', {
      p_org_id: orgId,
      p_tier: tier,
      p_subscription_status: status,
      p_stripe_customer_id: customerId ?? null,
      p_grace_until: graceUntil,
    });

    if (error) {
      return new Response(JSON.stringify({ ok: false, error: error.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
