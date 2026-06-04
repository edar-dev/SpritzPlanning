# Fase 17 — Business foundations

**Punti:** #79 Permessi leggeri · #81 KPI delivery · #82 Executive report · #84 Template business · #87 Onboarding guidato  
**Branch suggerito:** `feat/business-foundations`  
**Durata stimata:** 8–12 giorni  
**Dipende da:** [Fase 16](phase-16-session-depth.md) · [Fase 15](phase-15-discoverability.md)

Elenco riepilogativo: [IMPROVEMENTS-V9.md](../IMPROVEMENTS-V9.md).

## Obiettivo

Rendere SpritzPlanning più adatto a contesti professionali: ruoli chiari, KPI leggibili per PM/manager, report condivisibili e onboarding orientato al valore in pochi minuti.

---

## Ordine di implementazione

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #79, #84 | Ruoli base e template professionali |
| 2 | #81 | KPI su storico sessioni |
| 3 | #82, #87 | Executive report + onboarding business |

**Migration SQL** (timestamp Supabase, `supabase migration new …`):

1. `room_member_roles` — ruolo per partecipante stanza (#79)
2. `session_metrics_snapshot` (opzionale) — cache KPI per report veloci (#81/#82)

Aggiornare [supabase/README.md](../../supabase/README.md) per nuove migration.

---

## #79 Ruoli e permessi leggeri

Definire ruoli minimi senza introdurre account completi:

- `facilitator`: gestione story, reveal, final estimate, impostazioni room
- `editor`: modifica backlog e commenti
- `viewer`: sola partecipazione al voto/lettura

### Modifiche previste

| Area | Modifica |
|------|----------|
| `supabase/migrations/` | colonna `role` su `room_participants` + policy RPC |
| `lib/data/models/models.dart` | enum `RoomRole` |
| `room_repository.dart` | validazione permessi lato client + RPC |
| `room_screen.dart` | azioni UI condizionate dal ruolo |

### Verifica

- [ ] Viewer non può cambiare stato story
- [ ] Editor non può chiudere sessione
- [ ] Facilitator mantiene pieno controllo operativo

---

## #81 KPI delivery nello storico

KPI minimi in archivio sessione:

- stories completate
- stima media/mediana
- varianza stime (dispersione)
- percentuale revisioni stima (da #78)
- tempo medio per story stimata

### Modifiche previste

| Area | Modifica |
|------|----------|
| `lib/core/export/session_report.dart` | arricchimento statistiche |
| `lib/features/archive/` | card KPI per sessione archiviata |
| `lib/data/` | helper di aggregazione KPI |

### Verifica

- [ ] KPI coerenti con report sessione
- [ ] Nessun dato personale sensibile esposto

---

## #82 Executive report automatico

Output standard "manager-ready":

- Markdown (già esistente, esteso)
- CSV business
- PDF (web print-friendly, fase 1)

Contenuti:

- overview sessione
- KPI principali
- top story per incertezza
- decisioni prese / azioni suggerite

### Verifica

- [ ] Export in 1 click da schermata report
- [ ] Layout leggibile in IT/EN
- [ ] Nessun blocco UI su dataset medi

---

## #84 Template di sessione business

Aggiungere preset professionali oltre ai template tecnici:

- Product Discovery
- Delivery Refinement
- Incident/Maintenance Fast Track

Ogni preset include deck, regole reveal, ordine attività suggerito.

### Verifica

- [ ] Preset disponibili in creazione stanza
- [ ] Descrizione use case in UI (IT/EN)

---

## #87 Onboarding guidato orientato al valore

Percorso "first value in 5 minuti":

1. Crea room
2. Importa backlog (paste/Jira)
3. Invita team
4. Prima stima e report

### Verifica

- [ ] Tasso completamento onboarding misurabile
- [ ] Possibilità di saltare il tour

---

## Criteri di done fase

- [ ] #79, #81, #82, #84, #87 implementati e verificati
- [ ] `flutter test` + `flutter analyze --fatal-infos` verdi
- [ ] ARB IT/EN aggiornati e `flutter gen-l10n` eseguito
- [ ] Migration documentate in `supabase/README.md`
- [ ] Nessuna regressione su flusso base create/join/vote/reveal
