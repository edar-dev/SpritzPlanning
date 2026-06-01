# Miglioramenti v8 — Session depth e PWA avanzata (#69–78)

Elenco successivo alla **Fase 15** ([IMPROVEMENTS-V7.md](IMPROVEMENTS-V7.md)).  
Focus: **facilitazione avanzata in sessione**, **import/export round-trip**, **PWA push**, **qualità CI** — sempre **senza login** (nickname + codice stanza).

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stim. |
|---|---------------|------|------------|-------------|--------------|
| 69 | Open Graph dinamico per codice | Reach | Alta | Bassa–Media | 1–2 giorni |
| 70 | Template stanza personalizzati (locale) | Produttività | Alta | Media | 2 giorni |
| 71 | Story di riferimento (relative sizing) | Facilitazione | Alta | Media | 2 giorni |
| 72 | Commenti / domande su story | Collaborazione | Media | Media | 2 giorni |
| 73 | Secondo round «confidence vote» | UX planning | Media | Media | 2 giorni |
| 74 | Import backlog da export Jira/ADO | Integrazione | Alta | Media | 2–3 giorni |
| 75 | Push notification PWA (VAPID) | PWA | Alta | Alta | 3–4 giorni |
| 76 | Suoni e haptic opt-in | UX / a11y | Bassa | Bassa | 1 giorno |
| 77 | Lighthouse CI su preview Vercel | Ops / qualità | Media | Bassa | 1 giorno |
| 78 | Cronologia stime e revisioni story | Report / audit | Media | Media | 2 giorni |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  —
Impatto alto + sforzo medio:  69, 70, 71, 74
Impatto alto + sforzo alto:   75
Impatto medio + sforzo basso: 76, 77
Impatto medio + sforzo medio: 72, 73, 78
```

## Fase suggerita: 16 — Session depth

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #69, #76, #77 | Reach OG dinamico, polish sensoriale, quality gate |
| 2 | #70, #74 | Template custom locali, import round-trip Jira/ADO |
| 3 | #71, #72, #73 | Facilitazione: riferimento, commenti, confidence |
| 4 | #75, #78 | Push PWA + audit trail stime |

**Branch suggerito:** `feat/session-depth`  
**Piano di fase:** [phase-16-session-depth.md](plans/phase-16-session-depth.md)  
**Durata stimata:** 10–14 giorni

---

## Dettaglio per punto (sintesi)

Vedi sezioni complete in [phase-16-session-depth.md](plans/phase-16-session-depth.md).

### #69 — Open Graph dinamico per codice stanza

Completamento di #66: pagina `/j/:code` o meta dinamici via query; anteprima Slack/Teams con nome locale e codice quando si condivide l’invito smart (#63).

### #70 — Template stanza personalizzati (locale)

Estende #54: salvataggio template custom (deck + backlog + impostazioni) in prefs locali; riuso «La nostra serata Scrum» senza account.

### #71 — Story di riferimento (relative sizing)

Il barman marca una story come ancora (es. «Login = 5 pt»); hint visivo sulle altre story basato sul rapporto con la mediana voti.

### #72 — Commenti / domande su story

Note pubbliche per story (distinte dalle note facilitatore #52); visibili a tutti in lobby; incluse in export opzionale.

### #73 — Secondo round «confidence vote»

Dopo reveal con spread alto: mini-round «Quanto siete sicuri?» (1–5); indicatore visivo, non modifica la stima finale.

### #74 — Import backlog da export Jira/ADO

Round-trip con #53: incolla CSV/tab export Jira o ADO → parsing → `add_stories`; complemento all’import paste (#31).

### #75 — Push notification PWA (VAPID)

Estende #55: notifiche con app in background («Reveal effettuato», «Sei l’ultimo a votare»); service worker + opt-in esplicito.

### #76 — Suoni e haptic opt-in

Feedback sonoro/haptic su reveal, timer scaduto (#14), consenso (#39); disattivato di default (coerente con Fase 6).

### #77 — Lighthouse CI su preview Vercel

Workflow Lighthouse su ogni PR (Performance, Accessibility, PWA); soglia a11y ≥ 90 come in [PERFORMANCE.md](PERFORMANCE.md).

### #78 — Cronologia stime e revisioni story

Traccia revisioni stima (es. 8 → 5); visibile in report, archivio (#61) e export Markdown.

---

## Fuori scope v8

- Login / workspace multi-tenant
- API live Jira/Linear/GitHub con OAuth
- Video / audio call
- Progetto Supabase staging (#35)
- Chat realtime / thread illimitati
- Analytics third-party obbligatori

---

## Riferimenti

- Template built-in: Fase 14 `#54`
- Export Jira/ADO: Fase 14 `#53`
- Archivio sessioni: Fase 15 `#61`
- Notifiche in-tab: Fase 14 `#55`
- Open Graph statico: Fase 15 `#66`
- Import paste: Fase 11 `#31`
