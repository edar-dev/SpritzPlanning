# Miglioramenti UX lean — post Fase 25

Panoramica dei miglioramenti UX proposti dopo **Fase 25** (help crawlable, lista compatta ordini in votazione). Allineati al north star lean: **apri stanza → primo voto < 90 s**, **ciclo barman ≤ 4 tap**, **zero dialog obbligatori pre-voto**.

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  #109, #110, #111, #112, #120
Impatto alto + sforzo medio:  #113, #114, #115, #116, #121, #124
Impatto medio + sforzo medio: #117, #118, #119, #122, #123
Impatto medio + sforzo basso: #125, #126
```

## Tabella riepilogativa

| ID | Miglioramento | Tipo | Fase | Durata |
|----|---------------|------|------|--------|
| #109 | Timer: ricorda ultima scelta | Barman / attrito | 26 | 0.5–1 g |
| #110 | Sticky «Servizio!» su mobile | Barman / voting | 26 | 1 g |
| #111 | Banner condividi codice post-creazione | Onboarding stanza | 26 | 0.5–1 g |
| #112 | Stato attesa cliente per fase | Cliente / chiarezza | 26 | 1 g |
| #113 | Partecipanti in sidebar durante votazione | Facilitatore | 26 | 1–2 g |
| #114 | Auto «prossimo ordine» (opt-in) | Barman / flusso | 27 | 2 g |
| #115 | «Salta ordine» nel menu Strumenti | Barman | 27 | 0.5 g |
| #116 | Primo ordine guidato (empty state) | Onboarding stanza | 27 | 1–2 g |
| #117 | Banner «Riprendi sessione» in home | Home / retention | 27 | 1 g |
| #118 | Feedback voto (tap / cambio carta) | Cliente / voting | 27 | 1–2 g |
| #119 | Proiettore auto (viewport / toggle) | Sala remota | 28 | 2 g |
| #120 | Reveal teatrale opt-in (3-2-1) | Sala remota | 28 | 1–2 g |
| #121 | Notifica «tocca a te» su start voting | Cliente / background | 28 | 1–2 g |
| #122 | Chiusura sessione con riepilogo | Post-sessione | 29 | 1–2 g |
| #123 | Archivio sessioni actionable | Retention | 29 | 2 g |
| #124 | Smoke E2E documentato + checklist | Ops / QA | 29 | 1 g |
| #125 | Messaggi errore RPC umani (audit) | Qualità | 29 | 1 g |
| #126 | Coda voti offline / reconnect | Affidabilità | 29 | 2–3 g |

## Piani di fase

| Fase | Documento | Branch | Focus |
|------|-----------|--------|--------|
| 26 | [phase-26-ux-barman-cycle.md](plans/phase-26-ux-barman-cycle.md) | `feat/ux-barman-cycle` | Ciclo barman e visibilità in votazione |
| 27 | [phase-27-ux-session-flow.md](plans/phase-27-ux-session-flow.md) | `feat/ux-session-flow` | Flusso sessione, home, primo utilizzo |
| 28 | [phase-28-ux-remote-room.md](plans/phase-28-ux-remote-room.md) | `feat/ux-remote-room` | Proiettore, reveal, notifiche |
| 29 | [phase-29-ux-quality-retention.md](plans/phase-29-ux-quality-retention.md) | `feat/ux-quality-retention` | Chiusura, archivio, errori, offline |

## Ordine consigliato

1. **Fase 26** — massimo ROI, nessuna migration DB, complementa lista compatta (#28 PR)
2. **Fase 27** — flusso end-to-end e retention; #114 può richiedere preferenza + piccolo aggiustamento RPC (opzionale client-only)
3. **Fase 28** — utile se il team usa spesso TV/proiettore in call
4. **Fase 29** — hardening e post-sessione; #126 il più costoso, può essere ultimo sotto-fase

## Metriche di successo (aggregate)

| Metrica | Baseline | Target post Fase 27 |
|---------|----------|---------------------|
| Tap barman ciclo completo | ≤ 4 (obiettivo Fase 24) | ≤ 3 con timer memorizzato + auto-next opt-in |
| Dialog obbligatori pre-voto | 0 | 0 |
| Time-to-first-vote (nuovo utente) | < 90 s | < 60 s con primo ordine guidato |
| Bounce «non capisco cosa fare» (qualitativo) | — | ↓ via stati attesa cliente (#112) |

## Fuori scope (lean)

- Confidence vote, commenti story, sync Jira/ADO
- Auth / org / workspace in UI
- Onboarding multi-step pesante o tooltip ovunque
- Feature social o gamification

## Riferimenti

- North star: [phase-24-simplification.md](plans/phase-24-simplification.md)
- Smoke: [LEAN-SMOKE.md](LEAN-SMOKE.md)
- Produttività legacy (#31–39): [IMPROVEMENTS-PROD.md](IMPROVEMENTS-PROD.md)
