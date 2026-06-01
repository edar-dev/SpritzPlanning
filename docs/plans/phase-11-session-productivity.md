# Fase 11 — Produttività sessione e UI operative

**Punti:** #31 Import backlog · #32 Shortcut barman · #33 Ripresa sessione · #38 Presenza voti · #39 Auto-flow consenso  
**UI:** UI-A, UI-B, UI-C, UI-D, UI-E, UI-F  
**Branch suggerito:** `feat/session-productivity`  
**Durata stimata:** 8–12 giorni  
**Dipende da:** [Fase 10](phase-10-quality-gates.md) (integration test verde)

## Obiettivo

Ridurre click e attesa per il **barman** durante planning: backlog veloce, azioni da tastiera, visibilità su chi ha votato, ripresa dopo refresh, export ricco.

---

## #31 Import backlog (paste / CSV)

### Backend

**Opzione A (preferita):** RPC `add_stories(p_participant_id UUID, p_titles TEXT[])` — loop interno su `add_story`, stesso controllo ruolo.

**Opzione B:** loop client `add_story` con progress (nessuna migration; più lento, rate limit).

Migration: `010_bulk_add_stories.sql` se Opzione A.

### UI

- File: `lib/features/lobby/story_import_sheet.dart`
- Sheet da lobby (barman): textarea “una riga = titolo” + tab CSV opzionale
- Anteprima max 50 righe; trim; righe vuote ignorate
- Progress `LinearProgressIndicator` durante import
- ARB: `importStories`, `importPasteHint`, `importSuccess(n)`, errori

### Verifica

- [ ] 20 righe incollate → 20 stories in lobby
- [ ] Solo barman può importare
- [ ] Integration test opzionale: import 2 titoli + start vote

---

## #32 Shortcut barman + barra azioni rapide

### Web / desktop

- `lib/features/voting/facilitator_shortcuts.dart` — `CallbackShortcuts` o `Shortcuts` widget wrapper su `RoomScreen` quando `isFacilitator`
- Mappa iniziale:

| Tasto | Azione (fase voting) |
|-------|----------------------|
| `R` | Reveal |
| `N` | Next story (post-stima) |
| `V` | Start voting (lobby, story selezionata) |
| `Esc` | Chiudi dialog |

- Tooltip AppBar: icona `keyboard` → dialog scorciatoie

### Mobile

- `lib/features/voting/facilitator_action_bar.dart` — `BottomAppBar` o barra sopra deck con icone: Reveal, Next, Timer (se già presente)

### Verifica

- [ ] Chrome: `R` reveal senza focus su TextField
- [ ] Mobile: barra visibile solo barman in voting

---

## #33 Ripresa sessione robusta

### Storage

Estendere `lib/core/storage/session_storage.dart`:

```dart
// Chiavi aggiuntive (opzionali)
nickname, roomCode, roomName, savedAt
```

### Router / home

- `lib/app/router.dart`: se `/room/:id` senza sessione valida → redirect `/` con query `?rejoin=CODE` o banner
- `lib/features/home/home_screen.dart`: card “Riprendi *nickname* in *locale*” se `loadSession()` ok + fetch room ok
- Se kick / stanza cleanup: messaggio dedicato + codice copiabile

### Verifica

- [ ] Refresh su `/room/uuid` → rientro senza re-digitare nickname
- [ ] Dopo kick → home con messaggio chiaro

---

## #38 Presenza e stato voto

### UI

- `lib/shared/widgets/participant_avatar.dart`: badge overlay (grigio = no vote, verde = votato, outline = facilitatore)
- `lib/features/voting/voting_panel.dart` o header: `Text(context.l10n.votesProgress(n, total))` — es. “3/5 hanno votato”
- Realtime: già su `votes`; aggiornare solo presentation layer

### ARB

- `votesProgress`, `participantVoted`, `participantPending`

### Verifica

- [ ] 2 tab: voto su tab1 → badge tab2 aggiornato entro 2s
- [ ] Reveal: badge coerente con voti rivelati

---

## #39 Auto-flow consenso (opt-in)

### Logica

- Usare `lib/core/voting/vote_stats.dart` — se `consensusValue` e spread basso → `ConsensusSuggestion` model
- **Non** auto-apply senza tap barman (v1)

### UI

- Dopo reveal (o snackbar “tutti votati”): `Banner` / `Card` “Consenso su **5** — Applica e prossimo?”
- Toggle in impostazioni stanza (barman): `autoRevealWhenAllVoted` — richiede migration `rooms` flag + RPC `start_voting`/`reveal` opzionale (fase 11b se troppo grande; altrimenti solo suggerimento UI)

### Scope minimo Fase 11

- [ ] Suggerimento consenso + CTA singolo tap
- [ ] Auto-reveal (opzionale follow-up migration 011)

### Verifica

- [ ] Voti 5,5,5,8 → suggerimento 5, outlier 8 menzionato (UI-D)

---

## UI mirate — Fase 11

### UI-A — Home: nickname + stanze recenti

- `AppPreferences`: `lastNickname`, `recentRooms` JSON (max 5): `{code, name, at}`
- Precompilare nickname; lista tile “Entra di nuovo in …”

### UI-B — Progress backlog

- Lobby header: `LinearProgressIndicator(value: done/total)` + label l10n

### UI-C — Drag handle mobile

- `ReorderableListView` — leading `Icons.drag_handle` sempre visibile; `theme.dividerColor` contrast

### UI-D — Voting UX

- `SpritzCard`: `onLongPress` → conferma dialog prima di `castVote`
- Pre-reveal: `VoteSummaryPanel` — bordo rosso/arancio su outlier (usa stats esistenti)

### UI-E — Report export

- `session_report_sheet.dart`: pulsanti CSV (esistente), **JSON**, **Markdown**; `Clipboard.setData` per tab TSV

### UI-F — Empty backlog

- `_LobbyPanel`: se `stories.isEmpty` → illustrazione + “Importa” + “Aggiungi ordine”

---

## Ordine interno consigliato

1. UI-A, UI-F (home/empty — sblocco percepito)
2. #31 Import
3. #38 Presenza voti
4. #32 Shortcut + UI-B, UI-C
5. #33 Ripresa sessione
6. #39 + UI-D, UI-E

---

## Criteri di done — Fase 11

- [ ] Migration 010 applicata (se RPC batch)
- [ ] Barman: import ≥10 storie, shortcut reveal, vede progress voti
- [ ] Refresh browser non perde sessione valida
- [ ] `flutter analyze --fatal-infos` + `flutter test` verdi
- [ ] ARB IT/EN aggiornati
- [ ] `docs/IMPROVEMENTS-PROD.md` e ROADMAP aggiornati a “In corso” / “Completata” al merge

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Import spam / rate limit | Max 50 righe; messaggio rate limit |
| Shortcut conflitto focus TextField | `Shortcuts` scope solo quando nessun dialog aperto |
| Auto-flow confusione team | Solo suggerimento + tap esplicito in v1 |
