# Fase 24 — Lean tool (semplificazione)

**Branch suggerito:** `feat/lean-simplification`  
**North star:** apri una stanza e stima in 60 secondi, senza account.

## Obiettivo

Riposizionare SpritzPlanning come **planning poker leggero**: nickname + codice stanza, flusso votazione, export minimo. Rimuovere dalla UI tutto ciò che appartiene al percorso business/enterprise (org, workspace, piani, auth, ops, integrazioni avanzate).

Il codice backend (migration 019–020, tabelle org/auth) **resta** ma non è esposto in UI finché non serve un cliente enterprise.

## Core da mantenere

| Area | Feature |
|------|---------|
| Home | Apri locale, Entra al bancone, stanze recenti, resume |
| Stanza | Menu ordini, voto, reveal, stima, QR/invito |
| Barman | Add/edit/remove ordini, transfer, kick, timer, auto-reveal |
| Utilità | Import paste, deck preset, template locale, duplica stanza, report CSV |
| Preferenze | Lingua, tema, proiettore, notifiche browser, suoni |

## Rimosso dalla UI (lean)

| Feature | Motivo |
|---------|--------|
| Auth / profilo / sign-in | Attrito; guest è il percorso felice |
| Org, workspace, piani, Stripe | Piattaforma team, non poker leggero |
| Ops health (`/ops/health`) | Solo operatori |
| Business onboarding | Duplicato e orientato B2B |
| Feedback dialog automatico in home | Interrompe il primo utilizzo |
| Confidence vote | Nicchia, complessità in votazione |
| Story di riferimento (relative sizing) | Nicchia |
| Commenti pubblici su ordine | Rumore in backlog |
| Sync esterno Jira/ADO | Enterprise |
| Export multipli (Jira, ADO, Linear, GitHub, PDF executive, audit) | Report semplice: CSV + Markdown |
| Push PWA (VAPID) | Tenere solo notifiche browser |
| Inviti org (`/invite/:token`) | Enterprise |
| Auth callback route | Nessun login in UI |

## Sprint

### S24.1 — Home e join (questo PR)

- Home: due bottoni primari + recenti + template/archivio secondari
- Join: osservatore sotto «Opzioni avanzate»
- Creazione stanza senza workspace/org branding
- Barra preferenze: help + impostazioni (no account)

### S24.2 — Stanza

- App bar: menu unico «Strumenti» al posto di 4+ icon
- Azioni ordine: Servi + menu ⋯ (modifica, elimina, spike)
- Nessun prompt «collega account»

### S24.3 — Report e votazione

- Report: lista stime + copia CSV + copia/condividi Markdown
- Rimuovere confidence vote e reference sizing hint

### S24.4 — Pulizia codice ✅

- Rimossi file UI morti (`features/auth`, `features/org`, `ops_health_screen`, export executive, confidence, sync esterno)
- Rimossi provider auth/org/workspace/plan dalla UI
- Landing e pagina funzionalità allineate al posizionamento lean
- Backend org/auth (migration) resta per eventuale riattivazione enterprise

## Metriche

- Time-to-first-vote < 90s (nuovo utente)
- Tap barman per ciclo completo ≤ 4
- Zero dialog obbligatori prima del primo voto

## Test plan

Vedi checklist produzione: [LEAN-SMOKE.md](../LEAN-SMOKE.md).

- [x] HTTP smoke automatizzato (`deploy-smoke.yml`)
- [ ] Flusso E2E stanza in produzione (manuale)
- [x] `flutter analyze --fatal-infos` e `flutter test`
