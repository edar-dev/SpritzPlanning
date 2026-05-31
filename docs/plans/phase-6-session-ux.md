# Fase 6 — UX sessione poker

> **Nota (post–Fase 7/8):** le stringhe UI sono in `lib/l10n/*.arb`; `app_strings.dart` è stato rimosso.

**Punti:** #13 Menu avanzato · #14 Timer votazione · #19 Kick cliente  
**Branch suggerito:** `feat/session-ux`  
**Durata stimata:** 6–9 giorni  
**Dipende da:** [Fase 3](phase-3-lobby-voting-ux.md) (barman, dashboard voti)

## Obiettivo

Sessioni planning più fluide: backlog modificabile, ritmo votazione, stanza senza clienti fantasma.

---

## #13 Gestione menu avanzata (edit, riordino)

### Migration: `supabase/migrations/006_story_management.sql`

```sql
CREATE OR REPLACE FUNCTION update_story(
  p_participant_id UUID,
  p_story_id UUID,
  p_title TEXT,
  p_description TEXT DEFAULT ''
) RETURNS VOID ...

CREATE OR REPLACE FUNCTION reorder_stories(
  p_participant_id UUID,
  p_story_ids UUID[]  -- ordine desiderato
) RETURNS VOID ...
```

Regole RPC:
- Solo barman (`is_facilitator`)
- Story nella stessa room del barman
- Non modificare ordini in stato `voting` / `revealed` (solo `pending` / `done`)

### Flutter

| File | Modifica |
|------|----------|
| `room_repository.dart` | `updateStory`, `reorderStories` |
| `room_screen.dart` `_LobbyPanel` | `ReorderableListView` se barman |
| Dialog edit | Riutilizzare pattern `_showAddStoryDialog` |
| `app_strings.dart` | `modificaOrdine`, `salvaOrdine` |

### UX

1. Barman trascina ordine → debounce 300ms → RPC `reorder_stories`
2. Tap icona edit su card → dialog titolo/descrizione
3. Clienti vedono lista aggiornata via Realtime (read-only)

### Verifica

- [ ] Riordino persistito dopo refresh
- [ ] Cliente non può editare
- [ ] Impossibile riordinare ordine in votazione attiva

---

## #14 Timer votazione e alert

### Migration: `supabase/migrations/007_voting_timer.sql`

Colonne su `rooms` (o JSON `room_settings`):

```sql
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS voting_deadline_at TIMESTAMPTZ;
```

RPC `start_voting`: accetta opzionale `p_duration_seconds INT` → set `voting_deadline_at = now() + duration`.

RPC `clear_voting_timer` su reveal/reset/next (o trigger in funzioni esistenti).

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` `Room` | `DateTime? votingDeadlineAt` |
| `voting_panel.dart` | Countdown `Ticker` visibile a tutti |
| `room_screen.dart` | Snackbar/haptic quando `allParticipantsVoted` (barman) |
| Dialog start voting | Chip durata: 2 / 5 / 10 min / nessun timer |

### Comportamento alert

- Quando `allParticipantsVoted` passa `false → true`: snackbar “Tutti hanno scelto!” (solo barman)
- **No auto-reveal** — barman decide sempre
- Timer scaduto: banner “Tempo scaduto” + suggerimento reveal (non automatico)

### Verifica

- [ ] Countdown sincronizzato su 2 tab (via Realtime su `rooms`)
- [ ] Timer azzerato su reveal/next
- [ ] Nessun suono invasivo di default (opt-in in settings futuri)

---

## #19 Rimozione cliente / kick AFK

### Migration: `supabase/migrations/008_remove_participant.sql`

```sql
CREATE OR REPLACE FUNCTION remove_participant(
  p_barman_id UUID,
  p_target_id UUID
) RETURNS VOID ...
```

Regole:
- Solo barman
- Non rimuovere sé stesso
- Non rimuovere durante voto attivo del target su story corrente (opzionale: cancellare voto e procedere)
- `DELETE` participant → cascade votes; `touch_room`

### Flutter

| File | Modifica |
|------|----------|
| `room_repository.dart` | `removeParticipant` |
| `participant_avatar.dart` / `room_screen.dart` | Long-press barman → “Rimuovi dal bancone” (oltre passa bancone) |
| `Participant` UI | Badge “Assente” se `lastSeenAt < now() - 2 min` |

### Heartbeat

Già ogni 30s in `RoomStateNotifier`. Affinare soglia assenza a **120s** (costante condivisa).

### Verifica

- [ ] Kick rimuove avatar e voti del cliente
- [ ] `allParticipantsVoted` ricalcolato senza il rimosso
- [ ] Cliente rimosso reindirizzato a home (session invalid → fetch fallisce o RPC dedicata opzionale)

---

## Criteri di done — Fase 6

- [ ] Migration 006–008 applicate su Supabase
- [ ] Barman: edit, riordino, timer, kick funzionanti
- [ ] Test manuali 2 client + 1 barman
- [ ] `flutter analyze` e `test` verdi

## Rischi

| Rischio | Mitigazione |
|---------|-----------|
| Race reorder + start voting | Bloccare reorder se `phase != lobby` |
| Kick durante reveal | Consentire solo in lobby o post-reveal |
| Timer drift client | Fonte verità server (`voting_deadline_at`) |

## Ordine interno consigliato

1. #13 Menu (base operativa sessione)
2. #19 Kick (pulizia partecipanti)
3. #14 Timer (nice polish)
