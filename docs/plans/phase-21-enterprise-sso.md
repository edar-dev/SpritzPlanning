# Fase 21 — SSO enterprise (SAML/OIDC)

**Punto:** #98 SSO enterprise  
**Branch suggerito:** `feat/enterprise-sso`  
**Durata stimata:** 5–8 giorni  
**Dipende da:** [Fase 19](phase-19-identity-auth.md) · [Fase 20](phase-20-organizations-entitlements.md)

Elenco: [IMPROVEMENTS-V10.md](../IMPROVEMENTS-V10.md).

## Obiettivo

Permettere alle organizzazioni **Team/Enterprise** di autenticare i membri tramite identity provider aziendale (Azure AD, Okta, Google Workspace SAML) usando [Supabase SSO](https://supabase.com/docs/guides/auth/enterprise-sso), senza rompere il percorso ospite per i partecipanti esterni alla stanza.

---

## Scope

| In scope | Fuori scope |
|----------|-------------|
| SAML 2.0 per org con piano Team+ | SCIM user provisioning |
| Dominio email verificato → org auto-join | Login social consumer-only |
| Admin UI: “Configura SSO” (istruzioni + metadata URL) | Multi-IdP per stessa org (v2) |

---

## Implementazione proposta

1. **Supabase Dashboard:** abilitare SSO per progetto; registrare IdP per org (o per tenant slug).
2. **Tabella `org_sso_config`:** `org_id`, `domain`, `idp_metadata_url`, `enabled`, `enforced` (boolean: blocca login password per dominio).
3. **Flutter:** pulsante “Accedi con SSO aziendale” → `signInWithSSO` con `domain` o `organization_slug`.
4. **Post-login:** stesso flusso #90 link participant; membership org da claim o regola dominio.

---

## Verifica

- [ ] Login SAML in ambiente test IdP (Azure AD test tenant)
- [ ] `enforced=true`: utenti `@azienda.it` non possono usare magic link
- [ ] Partecipante ospite a stanza con codice: ancora senza SSO

---

## Criteri di done

- [ ] #98 documentato per admin org
- [ ] Runbook in [AGENT-PLAYBOOK.md](../AGENT-PLAYBOOK.md) per setup IdP
- [ ] Nessuna regressione auth Fase 19
