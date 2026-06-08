# Fase 28 — UX sala remota e proiettore

**Punti:** #119 Proiettore auto · #120 Reveal teatrale · #121 Notifica «tocca a te»  
**Branch suggerito:** `feat/ux-remote-room`  
**Durata stimata:** 4–6 giorni  
**Dipende da:** Fase 26 (#110 sticky) opzionale

## Obiettivo

Migliorare l'esperienza in **call remote** e **sala con proiettore/TV**: leggibilità a distanza, energia al reveal, richiamo clienti con tab in background.

**Migration DB:** nessuna.

---

## #119 Modalità proiettore auto (viewport / toggle)

### Stato attuale

`AppPreferences` + toggle «Modalità sala / proiettore» in settings; scala testo e card.

### Miglioramenti

| File | Modifica |
|------|----------|
| `lib/core/preferences/app_preferences.dart` | `loadProjectorAutoEnable()` — auto se larghezza > 1200 **o** `MediaQuery.textScaler` sistema grande |
| `lib/core/theme/app_theme.dart` o `lib/core/theme/projector_extensions.dart` | Token: `deckCardSize`, `voteRevealFontSize`, `appBarHeight` moltiplicati ×1.25 quando proiettore |
| `lib/features/voting/voting_panel.dart` | Deck `Wrap` spacing maggiore; numeri reveal più grandi |
| `lib/features/home/home_settings_sheet.dart` | Toggle esistente + sotto-voce «Attiva automaticamente su schermi larghi» |
| `lib/l10n/app_*.arb` | `projectorAutoTitle`, `projectorAutoSubtitle` |

### Comportamento

- **Auto**: all'ingresso stanza, se viewport wide → applica theme proiettore (override locale `Theme` wrapper su `RoomScreen`).
- Toggle manuale resta master: utente può disattivare auto per quella sessione (`sessionProjectorOverride` in memoria).

### Verifica

- [ ] Browser full HD: deck visibile a 2–3 m (test qualitativo)
- [ ] Mobile: proiettore auto **non** attivo
- [ ] Toggle settings: immediate apply

---

## #120 Reveal teatrale opt-in (3-2-1)

### Problema

Reveal istantaneo funziona ma in retro remoto manca «momento» di attenzione.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/core/preferences/app_preferences.dart` | `loadTheatricalReveal()` — default `false` |
| `lib/features/voting/voting_panel.dart` | Su tap «Servizio!»: se opt-in, overlay countdown 3-2-1 poi `_reveal()` |
| `lib/features/home/home_settings_sheet.dart` | Toggle «Countdown prima del reveal» |
| `lib/l10n/app_*.arb` | `revealCountdown`, `revealGo` |

### UI

- Overlay fullscreen semi-trasparente; numero grande al centro; suono/haptic opzionali (preferenza suoni).
- **Skip**: tap anywhere o tasto `R` (facilitator) salta countdown.
- Rispettare `MediaQuery.disableAnimationsOf` → skip countdown.

### Verifica

- [ ] Toggle off: reveal immediato (regressione zero)
- [ ] Toggle on: countdown poi carte visibili
- [ ] `disableAnimations`: nessun countdown

---

## #121 Notifica browser «tocca a te»

### Stato attuale

`lib/core/notifications/browser_notifications.dart` — verificare hook su cambio fase.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/core/notifications/browser_notifications.dart` | `notifyVotingStarted(roomName, storyTitle)` — richiede permesso |
| `lib/features/lobby/room_screen.dart` | Listener `roomStateProvider`: transizione `lobby → voting` per **non-barman** |
| `lib/features/home/home_settings_sheet.dart` | Toggle «Avvisami quando inizia la votazione» (legato a permesso Notification API) |
| `lib/l10n/app_*.arb` | `notificationVotingTitle`, `notificationVotingBody` |

### Regole

- Solo se permesso `Notification` granted e preferenza on.
- **Non** notificare il barman che ha avviato lui la votazione.
- Throttle: max 1 notifica / 30 s per evitare spam su switch ordine (#28 lista compatta).

### Web constraint

- Safari / iOS: permessi limitati — degradare silenziosamente.
- Documentare in [LEAN-SMOKE.md](../LEAN-SMOKE.md) § browser support.

### Verifica

- [ ] Cliente tab background: notifica su start voting
- [ ] Switch ordine rapido: no flood notifiche
- [ ] Permesso negato: nessun crash

---

## Sprint suggerito

| Sprint | Contenuto |
|--------|-----------|
| S28.1 | #119 proiettore auto + theme tokens |
| S28.2 | #120 countdown reveal |
| S28.3 | #121 notifiche voting start |

## Test plan

- [ ] Chrome desktop 1920×1080: sessione con 5 partecipanti mock — deck leggibile
- [ ] Countdown + skip
- [ ] Notifica: 2 browser, cliente in tab 2, barman avvia voto in tab 1
- [ ] Lighthouse a11y: contrasto reveal countdown

## Metriche fase

- Feedback qualitativo retro: «si legge dal proiettore» (team interno)
- Notifiche: ≥1 delivery riuscita su Chrome desktop in test

## Criteri di done

- [ ] Tutte le feature **opt-in** o auto disattivabili
- [ ] Nessuna regressione performance animazioni (60 fps deck)
- [ ] Documentazione browser notifiche
