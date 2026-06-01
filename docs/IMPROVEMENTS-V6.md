# Miglioramenti v6 — Sessione avanzata e collaborazione (#49–58)

Elenco successivo alla **Fase 13** ([IMPROVEMENTS-UI-A11Y.md](IMPROVEMENTS-UI-A11Y.md)).  
Focus: **facilitatore più veloce**, **stanze più sicure**, **integrazione con tool esterni**, **feedback in tempo reale** — sempre **senza login** (nickname + codice stanza).

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stim. |
|---|---------------|------|------------|-------------|--------------|
| 49 | Auto-reveal quando tutti hanno votato | UX / produttività | Alta | Media | 1–2 giorni |
| 50 | Ruolo osservatore (guarda, non vota) | Feature | Alta | Media | 2 giorni |
| 51 | PIN stanza opzionale | Sicurezza | Media | Bassa–Media | 1 giorno |
| 52 | Note facilitatore per story | UX | Media | Bassa | 1 giorno |
| 53 | Export Jira / Azure DevOps / CSV | Integrazione | Alta | Media | 1–2 giorni |
| 54 | Template stanza (deck + backlog seed) | Produttività | Media | Media | 2 giorni |
| 55 | Notifiche browser (reveal, timer) | PWA | Media | Media | 2 giorni |
| 56 | Story «spike» / salta stima | Feature | Media | Bassa | 1 giorno |
| 57 | Report sessione arricchito (stats + grafico) | UX / valore | Alta | Media | 2 giorni |
| 58 | Duplica stanza / «stessa serata» | Produttività | Media | Bassa–Media | 1 giorno |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  —
Impatto alto + sforzo medio:  49, 50, 53, 57
Impatto medio + sforzo basso: 52, 56, 58
Impatto medio + sforzo medio: 51, 54, 55
```

## Fase suggerita: 14 — Sessione avanzata

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #49, #56 | Flusso votazione automatico + tipi story |
| 2 | #50, #51 | Partecipanti osservatori + PIN join |
| 3 | #53, #57 | Export tool esterni + report visivo |
| 4 | #52, #54, #55, #58 | Note, template, notifiche, duplica stanza |

**Branch suggerito:** `feat/session-advanced`  
**Piano di fase:** [phase-14-session-advanced.md](plans/phase-14-session-advanced.md)  
**Durata stimata:** 10–14 giorni

---

## Dettaglio per punto (sintesi)

Vedi sezioni complete in [phase-14-session-advanced.md](plans/phase-14-session-advanced.md).

### #49 — Auto-reveal quando tutti hanno votato

Flag stanza + reveal in `cast_vote` quando tutti gli attivi (non osservatori) hanno votato.

### #50 — Ruolo osservatore

`is_observer` su join; esclusi da quorum e `cast_vote`.

### #51 — PIN stanza opzionale

`join_pin_hash` (bcrypt); join con PIN 4–6 cifre.

### #52 — Note facilitatore per story

Colonna `facilitator_note`; visibili/export solo barman.

### #53 — Export Jira / Azure DevOps / CSV

- Estendere sheet report (#15): formati
  - **CSV** (titolo, stima, descrizione, note)
  - **Jira** tab-separated: `Summary`, `Story Points`, `Description`
  - **Azure DevOps**: `Title`, `Story Points`, `Description`
- Copia negli appunti + download blob web.
- Nessuna API cloud: solo formato testo.

### #54 — Template stanza

Template locali (deck + titoli); crea stanza in un flusso.

### #55 — Notifiche browser (reveal, timer)

Web Notifications opt-in; reveal e timer a 30s se tab in background.

### #56 — Story «spike» / salta stima

Tipo `spike`, done senza votazione, stima `—`.

### #57 — Report sessione arricchito

Media, mediana, grafico barre, export PNG.

### #58 — Duplica stanza / «stessa serata»

RPC `duplicate_room`: nuovo codice, stesso backlog.

---

## Fuori scope v6

- Login / team workspace multi-tenant
- Integrazione API Jira/Linear live (OAuth)
- Progetto Supabase staging dedicato (#35)
- i18n lingue aggiuntive oltre IT/EN
- Video / audio call

---

## Riferimenti

- Follow-up #39: [phase-11-session-productivity.md](plans/phase-11-session-productivity.md)
- Report export: Fase 5 `#15`
- PWA: Fase 4 `#6`, UI-H Fase 12
