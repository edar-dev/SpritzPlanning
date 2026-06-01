# Miglioramenti v4 — Produttività sessione e production-ready (#31–40, UI)

Elenco successivo ai punti **21–30** ([IMPROVEMENTS-DX.md](IMPROVEMENTS-DX.md)).  
Focus: **velocità del facilitatore in planning**, **affidabilità in produzione**, **UI operative** (non nuove feature social/auth).

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stimata |
|---|---------------|------|------------|-------------|----------------|
| 31 | Import backlog (paste / CSV) | Feature | Alta | Media | 2–3 giorni |
| 32 | Shortcut barman + barra azioni rapide | UX / produttività | Alta | Bassa–Media | 1–2 giorni |
| 33 | Ripresa sessione robusta | Affidabilità | Alta | Bassa | 1 giorno |
| 34 | UI ottimistica + retry RPC | Affidabilità | Alta | Media | 2–3 giorni |
| 36 | CI stretta + smoke post-deploy | Ops / QA | Alta | Media | 1–2 giorni |
| 37 | Accessibilità + modalità proiettore | UX / a11y | Media | Media | 2 giorni |
| 38 | Presenza e stato voto in tempo reale | UX / produttività | Alta | Media | 1–2 giorni |
| 39 | Auto-flow consenso (suggerimenti / opt-in) | UX / produttività | Media | Media–Alta | 2–3 giorni |
| 40 | Osservabilità operativa (Sentry contesto) | Ops | Alta | Bassa–Media | 1 giorno |

### UI mirate (quick wins)

| ID | Miglioramento | Schermata | Fase |
|----|---------------|-----------|------|
| UI-A | Ricorda ultimo nickname + stanze recenti (locale) | Home | 11 |
| UI-B | Progress backlog (“12/20 stimate”) | Lobby | 11 |
| UI-C | Drag handle ordini più evidente (mobile) | Lobby | 11 |
| UI-D | Long-press conferma voto; outlier evidenziati pre-reveal | Voting | 11 |
| UI-E | Export JSON/Markdown + copia tabella | Report | 11 |
| UI-F | Empty state backlog vuoto (import + aggiungi) | Lobby | 11 |
| UI-G | Skeleton loading `RoomScreen` | Globale | 12 |
| UI-H | Prompt PWA dopo prima sessione completata | Home / PWA | 12 |

> **#35** (progetto Supabase staging dedicato) resta fuori scope v4 — limite org free / branch Pro; vedi [TESTING.md](TESTING.md).

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  33, 40, UI-A, UI-F
Impatto alto + sforzo medio:  31, 32, 34, 36, 38, UI-B, UI-D, UI-G
Impatto medio + sforzo medio: 37, 39, UI-C, UI-E, UI-H
```

## Ordine suggerito (fasi 11–12)

| Fase | Punti | Focus | Piano |
|------|-------|--------|-------|
| 11 | #31–33, #38–39, UI-A–F | Produttività facilitatore e lobby/voting | [phase-11-session-productivity.md](plans/phase-11-session-productivity.md) |
| 12 | #34, #36–37, #40, UI-G–H | Rete, CI, a11y, osservabilità | [phase-12-production-hardening.md](plans/phase-12-production-hardening.md) |

**Dipendenze:** Fase 11 prima di 12 consigliata (import backlog e presenza voti semplificano test E2E). Fase 12 può partire in parallelo su CI (#36) se team diviso.

---

## Riferimenti rapidi per punto

| # | Deliverable chiave |
|---|-------------------|
| 31 | RPC batch o loop documentato; sheet import; ARB |
| 32 | `Shortcuts` / `CallbackShortcuts` web; bottom bar mobile barman |
| 33 | `SessionStorage` + nickname/code; stati stanza scaduta/kick |
| 34 | Voto ottimistico; retry; mapping errori PostgREST |
| 36 | Integration su label PR; smoke deploy; golden opzionali |
| 37 | `Semantics`; toggle “modalità sala”; `disableAnimations` |
| 38 | Badge avatar; contatore “N/M votato” |
| 39 | Suggerimento consenso da `VoteStats`; opt-in auto-reveal |
| 40 | Tag Sentry senza PII; release ↔ commit Vercel |

Vedi i piani di fase per task file-by-file e criteri di done.
