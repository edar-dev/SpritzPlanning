# Fase 27 — UX flusso sessione e primo utilizzo

**Punti:** #114 Auto prossimo ordine · #115 Salta ordine · #116 Primo ordine guidato · #117 Riprendi sessione · #118 Feedback voto  
**Branch suggerito:** `feat/ux-session-flow`  
**Durata stimata:** 5–8 giorni  
**Dipende da:** [Fase 26](phase-26-ux-barman-cycle.md) consigliata (timer + sticky)

## Obiettivo

Accelerare **prima sessione**, **ritorno utente** e **ciclo backlog lungo** senza togliere controllo al barman (tutto opt-in o confermato).

**Migration DB:** opzionale per #114 (vedi sotto); default **client-only**.

---

## #114 Auto «prossimo ordine» (opt-in)

### Problema

Dopo conferma stima la stanza torna in lobby; il barman deve tap «Servi» sul successivo — rumore su backlog lunghi.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/core/preferences/app_preferences.dart` | `loadAutoStartNextOrder()` / `saveAutoStartNextOrder(bool)` — default `false` |
| `lib/features/voting/voting_panel.dart` | Dopo `setFinalEstimate` success: se opt-in, trova primo `StoryStatus.pending` per `sortOrder`, chiama `startVoting` |
| `lib/features/lobby/room_deck_settings_sheet.dart` o `home_settings_sheet.dart` | Toggle «Servi automaticamente il prossimo ordine» |
| `lib/l10n/app_*.arb` | `autoNextOrderTitle`, `autoNextOrderSubtitle` |

### Regole

- Solo **barman**; solo se esiste almeno un `pending` non-spike.
- Se ultimo ordine → comportamento attuale (resta in lobby / invita a chiudere sessione).
- **Nessuna migration** se logica interamente client (RPC `start_voting` già idempotente).

### Verifica

- [ ] Toggle off: comportamento invariato
- [ ] Toggle on: dopo conferma stima parte votazione ordine successivo
- [ ] Spike esclusi dall'auto-start

---

## #115 «Salta ordine» nel menu Strumenti

### Problema

Switch ordine via lista compatta richiede scoperta UI; voce esplicita nel menu ⋮ aumenta findability.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/lobby/room_screen.dart` | `PopupMenuButton` actions: voce «Torna al menu» / «Salta ordine corrente» visibile se `phase == voting \|\| revealed` |
| `lib/features/lobby/room_screen.dart` | Handler: conferma → `nextStory` RPC (già esiste) |
| `lib/l10n/app_*.arb` | `skipCurrentOrder`, `skipCurrentOrderConfirm` |

### Comportamento

- Equivalente a «Prossimo ordine» pre-reveal: annulla votazione corrente, torna lobby **sen** confermare stima.
- Dialog: «I voti su «X» verranno annullati. Tornare al menu?»

### Verifica

- [ ] Voce visibile solo barman in voting/revealed
- [ ] Mid-vote: ordine torna pending, voti cancellati (allineato a `next_story` + story status)

### Nota backend

Verificare che `next_story` resetti story `voting` → `pending`. Se gap, migration piccola in Fase 26/27:

```sql
-- In next_story: UPDATE stories SET status = 'pending'
-- WHERE room_id = v_room_id AND status IN ('voting', 'revealed');
```

---

## #116 Primo ordine guidato (empty state)

### Problema

Stanze nuove: empty state statico; nuovo barman non sa la sequenza minima.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/lobby/room_screen.dart` | `_LobbyPanel` empty state: sostituire con **3 step inline** (non wizard modale) |
| `lib/l10n/app_*.arb` | `guidedStep1Add`, `guidedStep2Share`, `guidedStep3Serve` |

### UI lean

```
① Aggiungi il primo ordine     [+ Aggiungi ordine]
② Condividi il codice bancone  [Copia] [QR]
③ Servi l'ordine per votare    (disabilitato fino a step 1)
```

- Step 2 attivo dopo step 1; step 3 = hint testuale finché non c'è pending.
- **Nessun** overlay blocking; scompare quando `stories.isNotEmpty` e almeno una votazione avviata (preferenza `guidedRoomDismissed` opzionale).

### Verifica

- [ ] Nuova stanza barman: checklist visibile
- [ ] Dopo primo ordine: step 2 azionabile
- [ ] Stanza con import bulk: empty state classico o checklist già completata

---

## #117 Banner «Riprendi sessione» in home

### Problema

`StoredSession` esiste ma il resume può passare inosservato rispetto ai recenti.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/home/home_screen.dart` | Se `_storedSession != null` e stanza ancora valida (RPC `get_room_by_code` o join probe): `Card` prominente sopra recenti |
| `lib/core/storage/session_storage.dart` | Esporre `roomName`, `code`, `savedAt` per copy |
| `lib/l10n/app_*.arb` | `resumeSessionTitle`, `resumeSessionAction`, `resumeSessionDismiss` |

### UI

- «Riprendi *Nome locale* (SPRT-XXXX)» — CTA primaria **Entra** · secondaria **Ignora** (clear storage).
- Nascondere se session scaduta o participant kickato (già gestito da join flow).

### Verifica

- [ ] Leave room → home mostra banner
- [ ] Ignora → storage cleared, banner sparisce
- [ ] Entra → naviga a `/app/room/:id`

---

## #118 Feedback voto più leggero

### Problema

Tap carta può sentirsi «muto»; long-press conferma poco discoverable.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/shared/widgets/spritz_card.dart` | Animazione scale 95→100 on select; `HapticFeedback.lightImpact()` |
| `lib/features/voting/voting_panel.dart` | Secondo tap su altra carta = cambio voto (già supportato da RPC — verificare UX copy) |
| `lib/core/feedback/session_feedback.dart` | Suono soft opt-in (preferenza suoni esistente) |
| `lib/l10n/app_*.arb` | `voteChanged` se si mostra snackbar breve |

### Regole lean

- **No** dialog conferma voto su tap singolo (attrito).
- Long-press resta per «conferma esplicita» opzionale o rimuovere se ridondante (decisione in PR).

### Verifica

- [ ] Tap carta: feedback visivo + haptic (mobile)
- [ ] Cambio carta prima del reveal: aggiorna voto senza errori
- [ ] `Semantics` su carta selezionata per a11y

---

## Sprint suggerito

| Sprint | Contenuto |
|--------|-----------|
| S27.1 | #115 + #114 (skip + auto-next) |
| S27.2 | #116 guided empty + #117 resume banner |
| S27.3 | #118 vote feedback |

## Test plan

- [ ] Backlog 5 ordini, auto-next on: ciclo continuo senza tornare lobby
- [ ] Nuovo utente: guided empty → primo voto < 60 s (manuale cronometro)
- [ ] Resume banner dopo refresh browser
- [ ] Widget test opzionale su `SpritzCard` animation

## Metriche fase

- Time-to-first-vote nuovo barman: **< 60 s**
- Backlog 10 ordini: tap barman per ordine **≤ 3** con auto-next

## Criteri di done

- [x] Toggle auto-next default **off**
- [x] Migration `next_story` reset story status (#115)
- [ ] ROADMAP + IMPROVEMENTS-UX-LEAN aggiornati (in PR)
