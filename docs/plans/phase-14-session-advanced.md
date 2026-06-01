# Fase 14 — Sessione avanzata

**Punti:** #49 Auto-reveal · #50 Osservatore · #51 PIN stanza · #52 Note barman · #53 Export Jira/ADO · #54 Template · #55 Notifiche · #56 Spike · #57 Report stats · #58 Duplica stanza  
**Branch suggerito:** `feat/session-advanced`  
**Durata stimata:** 10–14 giorni  
**Dipende da:** [Fase 11](phase-11-session-productivity.md) · [Fase 13](phase-13-ui-a11y-polish.md)

Elenco riepilogativo: [IMPROVEMENTS-V6.md](../IMPROVEMENTS-V6.md).

## Obiettivo

Sessioni planning più veloci e sicure: quorum voti corretto (osservatori/assenti), reveal automatico opzionale, stanza protetta da PIN, note e export verso tool esterni, template e duplicazione per serate ricorrenti, notifiche PWA in background.

---

## Ordine di implementazione

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #56, #50, #49 | Tipi story, osservatori, auto-reveal (DB + voting) |
| 2 | #51, #52, #53 | PIN, note, formati export |
| 3 | #57, #58 | Report arricchito, duplica stanza |
| 4 | #54, #55 | Template (solo client), notifiche web |

**Migration SQL** (timestamp Supabase, `supabase migration new …`):

1. `story_kind` + `mark_story_spike` (#56)
2. `is_observer` + `join_room` (#50)
3. `auto_reveal_when_all_voted` + refactor `perform_reveal` (#49)
4. `join_pin_hash` + `set_room_pin` + `get_room_join_info` (#51)
5. `facilitator_note` + `update_story` (#52)
6. `duplicate_room` (#58)

#53, #54, #55: nessuna migration. Aggiornare [supabase/README.md](../../supabase/README.md).

---

## #56 Story spike / salta stima

### Migration

```sql
CREATE TYPE story_kind AS ENUM ('story', 'spike');
ALTER TABLE stories ADD COLUMN kind story_kind NOT NULL DEFAULT 'story';
```

### RPC `mark_story_spike(p_participant_id, p_story_id)`

- Solo barman; story `pending`
- `kind = spike`, `status = done`, `final_estimate = '—'`
- `start_voting` rifiuta se `kind = spike`

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` | `StoryKind`, `Story.kind` |
| `room_repository.dart` | `markStorySpike` |
| `room_screen.dart` | Menu «Segna come spike», badge bolt |
| `session_report.dart` | Spike in export, esclusi da mediana (#57) |

### Verifica

- [ ] Spike non avvia votazione
- [ ] Progress backlog conta spike tra completate

---

## #50 Ruolo osservatore

### Migration

```sql
ALTER TABLE participants ADD COLUMN is_observer BOOLEAN NOT NULL DEFAULT false;
```

### RPC

- `join_room(..., p_observer BOOLEAN DEFAULT false)`
- `cast_vote` → errore se `is_observer`
- Facilitator mai osservatore; transfer → target `is_observer = false`

### Flutter

| File | Modifica |
|------|----------|
| `home_screen.dart` | Checkbox «Solo osservazione» |
| `room_screen.dart` | Badge sidebar |
| `voting_panel.dart` | Deck nascosto, messaggio dedicato |
| `RoomState` | Quorum voti: solo non-osservatori attivi (>120s `last_seen_at`) |

### Verifica

- [ ] Observer non può votare
- [ ] «N/M votato» esclude osservatori

---

## #49 Auto-reveal quando tutti hanno votato

Completamento follow-up #39 (oggi solo suggerimento consenso).

### Migration

```sql
ALTER TABLE rooms ADD COLUMN auto_reveal_when_all_voted BOOLEAN NOT NULL DEFAULT false;
```

### RPC

- Estrarre `perform_reveal(v_room_id)` da `reveal_votes`
- In `cast_vote`: se flag on e tutti gli **attivi non-osservatori** hanno votato → `perform_reveal`
- RPC `set_room_settings(p_participant_id, p_auto_reveal)` (o estensione settings esistente)

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` | `Room.autoRevealWhenAllVoted` |
| `room_deck_settings_sheet.dart` / settings | Switch opt-in (default off) |
| `RoomState.allActiveParticipantsVoted` | Sostituisce/affina `allParticipantsVoted` |

### Verifica

- [ ] Flag off → comportamento invariato
- [ ] Flag on + 2 votanti → reveal senza tap barman
- [ ] Assente non blocca reveal se altri hanno votato

---

## #51 PIN stanza opzionale

### Migration

```sql
ALTER TABLE rooms ADD COLUMN join_pin_hash TEXT;
-- pgcrypto: crypt(p_pin, gen_salt('bf'))
```

### RPC

- `set_room_pin(p_participant_id, p_pin)` — 4–6 cifre; `NULL` rimuove PIN
- `create_room` — param opzionale `p_pin`
- `join_room` — `p_pin`; errore `PIN non valido`
- `get_room_join_info(p_code)` → `{ requires_pin, room_name }` (pubblico)

**Non** copiare PIN in query QR (solo codice stanza).

### Flutter

| File | Modifica |
|------|----------|
| `home_screen.dart` | Campo PIN condizionale dopo codice |
| Settings stanza | Imposta/rimuovi PIN |
| `user_facing_error.dart` | Messaggio PIN |

### Verifica

- [ ] Stanza protetta → join senza PIN fallisce
- [ ] Hash in DB, mai plaintext

---

## #52 Note facilitatore per story

### Migration

```sql
ALTER TABLE stories ADD COLUMN facilitator_note TEXT NOT NULL DEFAULT '';
```

### RPC

- `update_story` + param `p_facilitator_note` (max ~2000 char, trim)

### Flutter

| File | Modifica |
|------|----------|
| Dialog edit story | Campo note (solo barman) |
| `session_report.dart` | Colonna note in export se facilitatore |

### Verifica

- [ ] Cliente non vede note in UI
- [ ] Note in CSV/Markdown export barman

---

## #53 Export Jira / Azure DevOps / CSV

Estende report Fase 5 (#15). Nessuna migration.

### Formati

| Formato | Uso |
|---------|-----|
| CSV | `title,estimate,description,note` |
| Jira | Tab-separated: Summary, Story Points, Description |
| Azure DevOps | Tab-separated: Title, Story Points, Description |

### Flutter

| File | Modifica |
|------|----------|
| `session_report.dart` | `toCsv()`, `toJira()`, `toAzureDevOps()` |
| `session_report_sheet.dart` | Tab o chip formato; copia + download blob web |

### Verifica

- [ ] CSV apribile in Excel
- [ ] Incolla Jira bulk create (manuale)
- [ ] Spike/note gestiti (#52, #56)

---

## #57 Report sessione arricchito

### Dominio

Nuovo `lib/core/export/session_report_stats.dart`:

- Media / mediana solo stime Fibonacci numeriche (`isNumericDeckValue`)
- Spike e `?` esclusi da media/mediana
- Lista barre per grafico (titolo + stima)

### Flutter

| File | Modifica |
|------|----------|
| `session_report_sheet.dart` | KPI + grafico (`fl_chart` o `CustomPainter`) |
| | Export PNG via `RepaintBoundary` (web) |
| `Semantics` | Riepilogo testuale KPI |

### Verifica

- [ ] Unit test mediana [3,5,8] → 5
- [ ] Grafico con 10+ story scrollabile

---

## #58 Duplica stanza («stessa serata»)

### RPC `duplicate_room(p_participant_id, p_source_room_id)`

- Solo barman della source
- Nuovo `rooms` + codice; copia deck/settings (**non** PIN)
- Copia stories come `pending` (titolo, descrizione, note, sort_order)
- Solo chiamante come facilitatore nel nuovo room
- Return JSON come `create_room`

### Flutter

| File | Modifica |
|------|----------|
| `room_repository.dart` | `duplicateRoom` |
| `room_screen.dart` | Menu «Nuova serata» + dialog conferma |
| `providers.dart` | Redirect nuovo `roomId`, aggiorna session/recent |

### Verifica

- [ ] Integration: 2 stories → duplicate → nuovo code, 2 pending, 0 voti
- [ ] Non-facilitator → errore

---

## #54 Template stanza (deck + backlog)

Solo client — `lib/core/preferences/room_template_storage.dart`.

```dart
// max 5 template: name, deckValues, allowCoffeeBreak, storyTitles[]
```

### UI

- `room_template_sheet.dart` — lista, crea, elimina
- `room_template_editor_sheet.dart` — editor + paste titoli (#31)
- Home: «Crea da template» → `createRoom` + `setRoomDeck` + `addStories`
- Opzionale: import/export JSON `spritz-template/1`

### Verifica

- [ ] Template con 10 titoli → lobby con 10 pending
- [ ] Cap 5 template in prefs

---

## #55 Notifiche browser (reveal, timer)

Web only — `lib/core/notifications/browser_notifications_*.dart` (conditional export).

### Preferenze

- `notifications_enabled` (default false)
- Toggle in `home_settings_sheet.dart` + `Notification.requestPermission()`

### Trigger (solo `document.hidden`)

| Evento | Azione |
|--------|--------|
| `votesRevealed` false→true | «Voti rivelati» |
| Timer < 30s | «Tempo quasi scaduto» |

MVP: notifiche dal main isolate (tab in background), non push SW.

### Verifica

- [ ] Permesso negato → nessun crash
- [ ] Foreground → nessuna notifica duplicata

---

## Criteri di done fase

- [ ] Tutti i punti #49–58 con checkbox verifica soddisfatti
- [ ] `flutter test` + integration principale verdi
- [ ] Migration applicate su cloud; CI `supabase-migrations` verde
- [ ] ARB IT/EN aggiornati
- [ ] Nessuna regressione join/rejoin (`20260601131912_join_room_rejoin.sql`)

## Fuori scope fase

- Login / workspace multi-tenant
- API Jira/Linear live
- Push notification con app chiusa (VAPID)
- Progetto Supabase staging (#35)
