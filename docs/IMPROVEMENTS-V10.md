# Miglioramenti v10 — Identità e autenticazione (#89–98)

Elenco successivo alla **Fase 18** ([IMPROVEMENTS-V9.md](IMPROVEMENTS-V9.md)).  
Focus: integrazione opzionale di **Supabase Auth**, identità persistente e feature enterprise che oggi sono solo locali o debolmente attribuite.

## Contesto attuale

| Oggi | Limite |
|------|--------|
| Nessun login; nickname + codice stanza | Nessuna identità verificabile cross-device |
| `participant_id` come “capability token” nelle RPC | Chi conosce l’UUID può agire (mitigato da RLS read-only + SECURITY DEFINER) |
| Workspace / piano commerciale in **prefs locali** | Nessun enforcement server-side, niente billing reale |
| Audit trail con `participant_id` | Attribuzione debole in contesti compliance |
| Sync Jira/ADO MVP manuale | Secret e token OAuth richiedono identità + backend |

**Principio guida (ereditato da v9):** il flusso **ospite** resta il default; l’accesso con account **aggiunge** capacità, non blocca create/join/vote/report esistenti.

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stim. |
|---|---------------|------|------------|-------------|--------------|
| 89 | Supabase Auth (email magic link + OAuth social) | Foundation | Alta | Media | 3–4 giorni |
| 90 | Modalità ospite + collegamento account a sessione attiva | UX / Adoption | Alta | Media | 2–3 giorni |
| 91 | Profilo utente persistente (display name, avatar, preferenze) | Identity | Media | Bassa | 1–2 giorni |
| 92 | Workspace server-side legati all’account | Data model | Alta | Alta | 3–5 giorni |
| 93 | Organizzazioni e membership (team aziendale) | Enterprise | Alta | Alta | 4–6 giorni |
| 94 | Inviti org e ruoli org (admin / member) | Governance | Media | Media | 2–3 giorni |
| 95 | Entitlements server-side + integrazione billing (Stripe) | Monetization | Alta | Alta | 4–6 giorni |
| 96 | Hardening RPC/RLS con `auth.uid()` (modello ibrido) | Security | Alta | Alta | 4–5 giorni |
| 97 | Audit trail con identità verificata | Compliance | Media | Media | 2 giorni |
| 98 | SSO enterprise (SAML/OIDC via Supabase) | Enterprise | Media | Alta | 3–5 giorni (fase dedicata) |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  —
Impatto alto + sforzo medio: 89, 90, 91, 94, 97
Impatto alto + sforzo alto:   92, 93, 95, 96, 98
Impatto medio + sforzo medio: 94
```

## Piani consigliati

| Fase | Punti | Focus |
|------|-------|-------|
| 19 | #89, #90, #91, #96 (MVP) | Auth Supabase, ospite→account, profilo, prime RPC legate a utente |
| 20 | #92, #93, #94, #95, #97 | Workspace/org server-side, inviti, billing/entitlements, audit forte |
| 21 | #98 | SSO enterprise (opzionale, dopo 19–20) |

Piani di dettaglio:

- [phase-19-identity-auth.md](plans/phase-19-identity-auth.md)
- [phase-20-organizations-entitlements.md](plans/phase-20-organizations-entitlements.md)
- [phase-21-enterprise-sso.md](plans/phase-21-enterprise-sso.md) (bozza minima)

## Dipendenze con fasi precedenti

| Fase precedente | Cosa sblocca per l’auth |
|---------------|-------------------------|
| 17 (#79) | Ruoli in stanza → mappabili su membership org |
| 18 (#80, #85, #88) | Workspace locale, audit, piano demo → da portare server-side |
| 18 (#83) | Sync esterno → token in Edge Function legati a `user_id` / org |

## Metriche di successo

- % sessioni create ancora in modalità ospite (target: non calare >10% post-lancio)
- % utenti che collegano account entro 7 giorni dal primo utilizzo
- Riduzione abusi `create_room` (rate limit per `auth.uid()` vs IP anonimo)
- Conversione trial → piano pagato (quando #95 attivo)

## Note strategiche

- **Supabase Auth** è la scelta naturale (stesso progetto, JWT, `authenticated` role già nei GRANT).
- Provider iniziali consigliati: **magic link email**, **Google**, **Microsoft** (team IT).
- **Non** obbligare login per partecipare a una stanza con codice; obbligo solo per azioni org/admin/billing.
- Documentare in AGENTS.md il passaggio da “nessun login” a “login opzionale” quando la Fase 19 è in produzione.
