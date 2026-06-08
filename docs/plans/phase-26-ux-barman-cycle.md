# Fase 26 — UX ciclo barman e votazione

**Punti:** #109 Timer memorizzato · #110 Sticky Servizio · #111 Banner condividi · #112 Stato attesa cliente · #113 Partecipanti in sidebar  
**Branch suggerito:** `feat/ux-barman-cycle`  
**Durata stimata:** 4–6 giorni  
**Dipende da:** Fase 25 completata (lista compatta ordini — PR #28)

## Obiettivo

Ridurre tap e scroll per il **barman** durante la votazione e dare **contesto chiaro** a clienti e facilitatore senza ripristinare il menu pieno in fase voting.

**Migration DB:** nessuna (preferenze locali + UI).

---

## #109 Timer: ricorda ultima scelta

### Problema

Ogni «Servi l'ordine» apre `_showStartVotingDialog` con scelta timer — attrito ripetuto sul ciclo barman.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/core/preferences/app_preferences.dart` | `loadLastVotingTimerSeconds()` / `saveLastVotingTimerSeconds(int?)` — `null` = senza timer |
| `lib/features/lobby/room_screen.dart` | `_showStartVotingDialog`: pre-seleziona ultima scelta; al confirm salva preferenza |
| `lib/features/home/home_settings_sheet.dart` | Opzionale: voce «Timer predefinito votazione» (None / 2 / 5 / 10 min) |
| `lib/l10n/app_*.arb` | `defaultVotingTimer`, hint se aggiunto in settings |

### Comportamento

- **Tap «Servi l'ordine»** su tile: se preferenza salvata ≠ «chiedi sempre», avvia votazione **senza dialog** (usa ultima scelta).
- **Long-press** o voce menu ⋯ «Servi con timer…» → dialog timer (power user).
- Alternativa più semplice (MVP): dialog resta ma ultima scelta **pre-selezionata** + checkbox «Usa sempre» nel dialog.

### Verifica

- [ ] Prima votazione: dialog o default «senza timer»
- [ ] Seconda votazione: nessun dialog se «Usa sempre» attivo
- [ ] Cambio timer in settings riflette prossimo avvio

---

## #110 Sticky «Servizio!» su mobile

### Problema

Su viewport stretta, con lista compatta sopra il deck, il barman scrolla per trovare «Servizio!» quando tutti hanno votato.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/voting/voting_panel.dart` | Estrarre barra azioni barman; su `!isWide && isFacilitator && isVoting && !revealed` mostrare `bottomNavigationBar` o `SafeArea` sticky |
| `lib/features/lobby/room_screen.dart` | `Scaffold.extendBody` / padding bottom se barra sticky sovrappone contenuto |

### UI

- Barra fissa in basso: pulsante primario **Servizio!** (disabilitato finché non `allParticipantsVoted` — o sempre attivo con hint «non tutti hanno votato» come oggi).
- Opzionale: contatore «3/5 dosi scelte» nella barra.

### Verifica

- [ ] Mobile (< 800px): Servizio visibile senza scroll quando tutti votato
- [ ] Desktop: nessuna regressione (barra inline esistente)
- [ ] Safe area iOS / notch rispettata

---

## #111 Banner condividi codice post-creazione

### Problema

Dopo creazione stanza il team remoto non vede subito come invitare altri.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/lobby/room_screen.dart` | Flag locale `_sharePromptShown`; dopo primo `add_story` success (barman) → `MaterialBanner` o `SnackBar` con azioni |
| `lib/shared/widgets/room_code_display.dart` | Riutilizzare callback `onShare` / copia |
| `lib/l10n/app_*.arb` | `shareRoomPrompt`, `shareRoomPromptAction` |

### Comportamento

- Mostra **una volta per sessione** (non ogni ordine).
- Azioni: **Copia codice** · **Mostra QR** · **Invita** (share sheet).
- Dismiss persistente fino a leave room.

### Verifica

- [ ] Barman aggiunge primo ordine → banner appare
- [ ] Secondo ordine → banner non ripete
- [ ] Cliente non vede banner

---

## #112 Stato attesa cliente per fase

### Problema

Il cliente in lobby vede «In attesa dell'aperitivo…» generico; poco distinto da «vota ora».

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/lobby/room_screen.dart` | `_LobbyPanel`: messaggio per `!canModerate && !canEditBacklog` basato su `room.phase` e presenza ordini |
| `lib/features/voting/voting_panel.dart` | Header cliente: sottotitolo fase se non facilitatore |
| `lib/l10n/app_*.arb` | `waitingBarmanMenu`, `waitingVotingStart`, `yourTurnVote` |

### Copy suggerito (IT)

| Stato | Messaggio |
|-------|-----------|
| Lobby, menu vuoto | «Il barman prepara il menu…» |
| Lobby, ordini presenti, nessuna votazione | «In attesa che il barman serva un ordine» |
| Voting, non hai votato | «Scegli la dose — tocca una carta» |
| Voting, hai votato | Esistente: «Dose scelta! In attesa degli altri…» |

### Verifica

- [ ] Cliente in lobby con ordini vede messaggio distinto da voting
- [ ] IT + EN via ARB

---

## #113 Partecipanti in sidebar durante votazione

### Problema

Su desktop, in votazione la sidebar mostra codice + lista compatta ma **nasconde** chi ha votato (prima visibile in lobby).

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/lobby/room_screen.dart` | `_Sidebar`: se `showCompactOrders`, sotto `CompactOrderList` aggiungere sezione collassabile «Clienti al bancone» |
| `lib/shared/widgets/bar_participants_strip.dart` | Nessuna modifica se già supporta `showVoteStatus` |
| `lib/l10n/app_*.arb` | `participantsCompactTitle` (opzionale, può riusare esistente) |

### UI

- `ExpansionTile` default **aperto** su desktop wide; chiuso su sidebar stretta se serve spazio.
- `BarParticipantsStrip` con `showVoteStatus: room.phase == voting && !votesRevealed`.

### Verifica

- [ ] Desktop + votazione: pallini stato voto visibili sotto lista ordini
- [ ] Mobile: strip orizzontale sopra deck (già parzialmente presente) — allineare copy #112

---

## Sprint suggerito

| Sprint | Contenuto | PR |
|--------|-----------|-----|
| S26.1 | #109 timer memorizzato | 1 PR |
| S26.2 | #110 sticky + #112 stati cliente | 1 PR |
| S26.3 | #111 banner share + #113 sidebar partecipanti | 1 PR |

Oppure **un solo PR** se team piccolo.

## Test plan

- [ ] `flutter analyze --fatal-infos` + `flutter test`
- [ ] Manuale: ciclo barman mobile — servi → vota team → Servizio sticky → stima → prossimo
- [ ] Manuale: cliente join — messaggi fase corretti
- [ ] Regressione: lista compatta switch ordine (PR #28)

## Metriche fase

- Tap «Servi» → reveal → conferma → prossimo: **≤ 3 tap** con timer memorizzato
- Zero nuovi dialog obbligatori per avviare votazione (default path)

## Criteri di done

- [x] Tutti e 5 i punti #109–#113 implementati (#109–#113 in PR feat/ux-barman-cycle)
- [x] ARB IT/EN + `gen-l10n`
- [x] Aggiornato [IMPROVEMENTS-UX-LEAN.md](../IMPROVEMENTS-UX-LEAN.md) stato
