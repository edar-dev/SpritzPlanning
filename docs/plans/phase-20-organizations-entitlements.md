# Fase 20 — Organizzazioni, workspace cloud e entitlements

**Punti:** #92 Workspace server-side · #93 Organizzazioni · #94 Inviti org · #95 Billing/entitlements · #97 Audit identità  
**Branch suggerito:** `feat/organizations-entitlements`  
**Durata stimata:** 12–18 giorni  
**Dipende da:** [Fase 19](phase-19-identity-auth.md)

Elenco: [IMPROVEMENTS-V10.md](../IMPROVEMENTS-V10.md).

## Obiettivo

Spostare su database ciò che oggi è **locale** (workspace #80, piano #88) e abilitare team strutturati con membership, inviti e diritti d’uso verificati server-side. Collegare monetizzazione reale (Stripe) agli entitlements. Rafforzare audit trail con identità verificata.

---

## Ordine di implementazione

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #93, #94 | Schema `organizations`, `org_members`, inviti email |
| 2 | #92 | `workspaces` server-side, migrazione da prefs locali |
| 3 | #95 | `org_subscriptions`, webhook Stripe, gate RPC |
| 4 | #97, #96 (resto) | Audit `user_id`, RLS room per org admin |

**Migration SQL:**

1. `organizations`, `org_members`, `org_invites`
2. `workspaces` (org_id, name, brand_color, default_deck, …)
3. `rooms.org_id` / `rooms.workspace_id` (nullable per stanze ospite legacy)
4. `org_entitlements` o colonne su `organizations` (plan_tier, seats, features)
5. Estensione `audit_events` con `actor_user_id`

**Edge Functions** (nuovo cartella `supabase/functions/`):

- `stripe-webhook` — aggiorna entitlements (secret in Supabase, non in Flutter)
- `send-org-invite` (opzionale) — email via Resend/SMTP configurato in dashboard

---

## #93 Organizzazioni e membership

### Schema (bozza)

| Tabella | Campi chiave |
|---------|----------------|
| `organizations` | `id`, `name`, `slug`, `created_by`, `plan_tier`, `created_at` |
| `org_members` | `org_id`, `user_id`, `role` (`owner` / `admin` / `member`), `joined_at` |
| `org_invites` | `org_id`, `email`, `token`, `expires_at`, `invited_by` |

### Regole business

- Un utente può appartenere a **N** org.
- Creazione org: primo membro = `owner`.
- Stanza creata da utente autenticato: default `org_id` = org attiva in UI.

### Verifica

- [ ] Switch org attiva in home (simile a workspace sheet oggi)
- [ ] Solo `admin`+ possono invitare e cambiare branding org

---

## #94 Inviti org

### Flusso

1. Admin inserisce email → RPC `create_org_invite` → link `/invite/{token}`
2. Utente apre link → se non loggato, auth (#89) → `accept_org_invite`
3. Token monouso, scadenza 7 giorni

### Verifica

- [ ] Invito scaduto rifiutato con messaggio chiaro (l10n)
- [ ] Utente già membro: idempotente

---

## #92 Workspace server-side

### Migrazione da locale (Fase 18)

| Oggi (`workspace_storage.dart`) | Dopo |
|----------------------------------|------|
| Lista workspace in SharedPreferences | Tabella `workspaces` filtrata per `org_id` |
| `brand_color` locale | Colonna + sync su `create_room` |
| Default deck/template | Colonne JSON o FK template |

### RPC

- `list_workspaces(p_org_id)`
- `upsert_workspace(...)` — richiede `org_members.role` admin+
- `create_room` — accetta `p_workspace_id` invece di solo stringhe libere

### Verifica

- [ ] Import one-shot da prefs locali al primo login (opzionale, feature flag)
- [ ] Piano Team (#88): multi-workspace enforced server-side

---

## #95 Entitlements e billing (Stripe)

### Sostituzione piano demo locale

| Piano | Enforcement |
|-------|-------------|
| Free | RPC `check_entitlement('executive_report')` → false |
| Pro | Stripe subscription `price_xxx` |
| Team | Subscription + seat count |

### Componenti

| Componente | Ruolo |
|------------|-------|
| Stripe Checkout / Customer Portal | UI upgrade (web link o in-app browser) |
| Webhook `customer.subscription.updated` | Aggiorna `organizations.plan_tier` |
| `lib/core/plan/plan_gate.dart` | Legge entitlements da provider remoto, fallback locale solo offline demo |

### Verifica

- [ ] Upgrade Pro sblocca export executive senza toggle debug
- [ ] Downgrade/cancel: grace period 24h configurabile
- [ ] Nessuna chiave Stripe nel client Flutter

---

## #97 Audit con identità verificata

Estendere `append_audit_event` / lettura report:

- `actor_user_id` da `auth.uid()` quando presente
- Display in UI: `display_name` profilo, non email
- Retention policy documentata (es. 90 giorni) — configurazione Supabase/cron

### Verifica

- [ ] Eventi post-login mostrano nome profilo in audit list
- [ ] Eventi ospite: solo nickname (come oggi)

---

## #96 Hardening (completamento)

Oltre al MVP Fase 19:

- `create_room`: rate limit per `auth.uid()` (oltre IP globale)
- `rooms`: policy SELECT per membri org su stanze `org_id`
- Sync Jira (#83): token in `org_integration_secrets` — solo Edge Function

---

## Feature collegate (matrice)

| Feature esistente | Con auth + org |
|-------------------|----------------|
| Ruoli stanza (#79) | Facilitatore può essere vincolato a `org_members.role >= admin` (opzionale) |
| Executive report (#82) | Gate Pro server-side |
| KPI / archivio (#81) | Archivio cloud per org (backlog #99+) |
| Ops health (#86) | Route protetta `authenticated` + claim `ops_admin` |
| Sync esterno (#83) | OAuth Jira/ADO per org, non per device |
| SSO (#98) | Fase 21 (posticipata, on demand) |

---

## Criteri di done fase

- [ ] #92–#95, #97 implementati
- [ ] Migrazione prefs workspace → cloud documentata
- [ ] Webhook Stripe testato in preview
- [ ] `flutter test` + analyze verdi
- [ ] Playbook deploy: secret Stripe solo su Supabase/Vercel server

---

## Fuori scope (backlog v10+)

- Archivio sessioni cloud multi-device (#61 esteso)
- SCIM provisioning
- Fatturazione multi-valuta / invoice PDF
- Room “pubblica internet” con moderazione

SSO (#98): vedi [phase-21-enterprise-sso.md](phase-21-enterprise-sso.md) — posticipato fino a necessità reale.
