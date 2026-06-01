# Miglioramenti v7 — Discoverability e chiusura sessione (#59–68)

Elenco successivo alla **Fase 14** ([IMPROVEMENTS-V6.md](IMPROVEMENTS-V6.md)).  
Focus: **onboarding**, **guida in-app**, **condivisione stanza**, **chiusura sessione**, **export esteso** — sempre **senza login** (nickname + codice stanza).

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stim. |
|---|---------------|------|------------|-------------|--------------|
| 59 | Help page / guida feature | Onboarding / docs | Alta | Media | 2–3 giorni |
| 60 | Tour guidato al primo accesso | Onboarding | Media | Bassa–Media | 1–2 giorni |
| 61 | Archivio sessioni locali | Valore / export | Media | Media | 2 giorni |
| 62 | Preset deck ufficiali | Produttività | Media | Bassa | 1 giorno |
| 63 | Invito «smart» (share testo + link) | Reach | Alta | Bassa | 1 giorno |
| 64 | Voto anonimo pre-reveal | UX / psicologia | Media | Media | 2 giorni |
| 65 | Chiusura sessione + mini-retro | Facilitatore | Alta | Media | 2–3 giorni |
| 66 | Open Graph / anteprima link join | Reach / marketing | Media | Bassa–Media | 1 giorno |
| 67 | Export Linear / GitHub Issues | Integrazione | Media | Bassa | 1 giorno |
| 68 | Feedback post-sessione | Product discovery | Bassa | Bassa | 1 giorno |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  63
Impatto alto + sforzo medio:  59, 65
Impatto medio + sforzo basso:  62, 67, 68
Impatto medio + sforzo medio:  60, 61, 64, 66
```

## Fase suggerita: 15 — Discoverability

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #59, #60, #66 | Help page, tour, meta link join |
| 2 | #61, #65, #68 | Archivio locale, chiusura sessione, feedback |
| 3 | #62, #63, #67 | Preset deck, invito smart, export extra |
| 4 | #64 | Voto anonimo pre-reveal (DB + UI) |

**Branch suggerito:** `feat/discoverability`  
**Piano di fase:** [phase-15-discoverability.md](plans/phase-15-discoverability.md)  
**Durata stimata:** 8–12 giorni

---

## Dettaglio per punto (sintesi)

Vedi sezioni complete in [phase-15-discoverability.md](plans/phase-15-discoverability.md).

### #59 — Help page / guida feature

Route `/help` con catalogo feature, ruoli, flusso planning, FAQ e shortcut. Link da home e footer tour (#60).

### #60 — Tour guidato al primo accesso

Overlay 3–5 step sulla home al primo avvio; flag `has_seen_onboarding` in prefs. CTA finale verso `/help`.

### #61 — Archivio sessioni locali

Salvataggio snapshot report + stats al leave (max ~20 sessioni). Home → lista «Sessioni passate» con re-export.

### #62 — Preset deck ufficiali

Chip Fibonacci, T-shirt, Powers of 2, SAFe in deck settings; applica `setRoomDeck` senza digitare valori.

### #63 — Invito smart

Share testo multilingua: codice, URL join (`?code=`), hint PIN, link help. Estende share già presente in lobby.

### #64 — Voto anonimo pre-reveal

Setting stanza: nasconde badge «ha votato» su avatar fino al reveal; resta contatore N/M.

### #65 — Chiusura sessione + mini-retro

Wizard barman: KPI, note retro (export), skip pending opzionale, CTA duplica stanza (#58).

### #66 — Open Graph / anteprima link

Meta tag web per URL join: titolo app, codice stanza, immagine; anteprima ricca in Slack/Teams.

### #67 — Export Linear / GitHub Issues

Formati testo aggiuntivi nel report sheet (tab-separated Linear, checklist Markdown GitHub).

### #68 — Feedback post-sessione

Dialog leggero dopo prima sessione completata: 👍/👎 + link GitHub Discussions/Issues opzionale.

---

## Fuori scope v7

- Login / workspace multi-tenant
- API live Linear/GitHub con OAuth
- Push notification con app chiusa (VAPID)
- Progetto Supabase staging (#35)
- Video / audio call
- Analytics third-party obbligatori

---

## Riferimenti

- Help content: feature già in app (Fasi 6–14)
- Report export: Fase 5 `#15`, Fase 14 `#53` `#57`
- Duplica stanza: Fase 14 `#58`
- PWA install: Fase 4 `#6`, UI-H Fase 12

---

**Successivo (v8 — session depth):** [IMPROVEMENTS-V8.md](IMPROVEMENTS-V8.md) · Fase 16
