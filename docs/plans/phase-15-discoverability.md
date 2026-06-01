# Fase 15 — Discoverability e chiusura sessione

**Punti:** #59 Help · #60 Tour · #61 Archivio · #62 Preset deck · #63 Invito smart · #64 Voto anonimo · #65 Chiusura sessione · #66 Open Graph · #67 Export Linear/GitHub · #68 Feedback  
**Branch suggerito:** `feat/discoverability`  
**Durata stimata:** 8–12 giorni  
**Dipende da:** [Fase 14](phase-14-session-advanced.md) · [Fase 11](phase-11-session-productivity.md)

Elenco riepilogativo: [IMPROVEMENTS-V7.md](../IMPROVEMENTS-V7.md).

## Obiettivo

Rendere SpritzPlanning **scopribile e comprensibile** per nuovi utenti (help, tour, share), **memorabile** tra una serata e l’altra (archivio locale), e **completo** nel ciclo di vita della sessione (chiusura, retro, feedback) — senza introdurre account o API cloud.

---

## Ordine di implementazione

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #59, #60, #66 | Help page, onboarding tour, meta join |
| 2 | #61, #65, #68 | Archivio locale, chiusura sessione, feedback |
| 3 | #62, #63, #67 | Preset deck, invito smart, export extra |
| 4 | #64 | Voto anonimo pre-reveal (migration + UI) |

**Migration SQL** (timestamp Supabase, `supabase migration new …`):

1. `hide_voters_until_reveal` + estensione `set_room_settings` (#64)

#59–#63, #65–#68, #66: nessuna migration (client o static web). Aggiornare [supabase/README.md](../../supabase/README.md) solo se #64.

---

## #59 Help page / guida feature

### Route e navigazione

| File | Modifica |
|------|----------|
| `lib/app/router.dart` | `GoRoute(path: '/help', …)` |
| `lib/features/help/help_screen.dart` | **Nuovo** — scrollable, sezioni espandibili |
| `home_screen.dart` | IconButton `?` → `/help` (barra preferenze o AppBar) |

### Contenuto (IT/EN via ARB)

Sezioni consigliate:

1. **Cos’è SpritzPlanning** — planning poker, tema spritz, no account
2. **Ruoli** — barman, cliente, osservatore (#50)
3. **Flusso serata** — crea/join → backlog → voto → reveal → stima → report
4. **Catalogo feature** — tabella o card con icona + «dove trovarla»:
   - Template (#54), import backlog (#31), spike (#56), PIN (#51), auto-reveal (#49)
   - Duplica stanza (#58), report Jira/ADO (#53), notifiche (#55), proiettore (#37)
   - Shortcut barman (#32), ripresa sessione (#33)
5. **FAQ** — nickname duplicato, rejoin, PIN errato, osservatore
6. **Scorciatoie tastiera** — tabella (web/desktop)

### Implementazione contenuti

- Preferire stringhe in `app_it.arb` / `app_en.arb` (prefisso `help…`) per i18n
- Opzionale: `lib/features/help/help_sections.dart` con dati strutturati (id, icon, titleKey, bodyKey, routeHint)

### Verifica

- [ ] `/help` accessibile senza sessione attiva
- [ ] Link da home; back torna a home
- [ ] IT/EN completi; screen reader legge titoli sezione
- [ ] Nessun PII nel contenuto statico

---

## #60 Tour guidato al primo accesso

### Preferenze

```dart
// AppPreferences
static const _hasSeenOnboardingKey = 'has_seen_onboarding';
```

### UI

| File | Modifica |
|------|----------|
| `lib/features/home/onboarding_overlay.dart` | **Nuovo** — `OverlayEntry` o package leggero (no dipendenze pesanti se possibile) |
| `home_screen.dart` | Dopo first frame: se `!hasSeenOnboarding` → mostra tour |

Step suggeriti (3–5):

1. Benvenuto + tagline
2. «Apri locale» / «Entra al bancone»
3. Codice stanza e QR (#7)
4. «Scopri tutte le funzioni» → `/help`

### Verifica

- [ ] Tour mostrato una sola volta
- [ ] Skip chiude e marca completato
- [ ] Non blocca join con `?code=` in URL

---

## #61 Archivio sessioni locali

### Storage

Nuovo `lib/core/preferences/session_archive_storage.dart`:

```dart
// max 20 entry: roomName, code, completedAt, reportJson, statsJson
```

### Trigger

| Evento | Azione |
|--------|--------|
| `_leaveAndGoHome` con ≥1 story `done` | `SessionArchiveStorage.add(...)` |

### UI

| File | Modifica |
|------|----------|
| `lib/features/home/session_archive_sheet.dart` | **Nuovo** — lista, tap → preview + export |
| `home_screen.dart` | Tile «Sessioni passate» se archivio non vuoto |

### Verifica

- [ ] Leave con 0 done → nessuna entry
- [ ] Cap 20: la più vecchia viene rimossa
- [ ] Re-export CSV/Markdown da archivio

---

## #62 Preset deck ufficiali

### Preset (costanti)

| Nome | Valori |
|------|--------|
| Fibonacci (default) | `0, ½, 1, 2, 3, 5, 8, 13, 21, ?, ☕` |
| T-shirt | `XS, S, M, L, XL, XXL, ?, ☕` |
| Powers of 2 | `0, 1, 2, 4, 8, 16, 32, ?, ☕` |
| SAFe | `1, 2, 3, 5, 8, 13, 21, ?, ☕` |

### Flutter

| File | Modifica |
|------|----------|
| `lib/core/constants/deck_presets.dart` | **Nuovo** |
| `room_deck_settings_sheet.dart` | Chip preset → popola editor + `setRoomDeck` |

### Verifica

- [ ] Preset applicato in stanza attiva
- [ ] Custom deck ancora modificabile manualmente

---

## #63 Invito smart (share testo + link)

### Formato messaggio (ARB template)

```
🍹 Unisciti a «{roomName}» su SpritzPlanning!
Codice: {code}
{pinLine}
Apri: {joinUrl}
Guida: {helpUrl}
```

### Flutter

| File | Modifica |
|------|----------|
| `lib/core/share/room_invite_text.dart` | **Nuovo** — builder IT/EN |
| `room_screen.dart` | Estende share esistente: QR + testo invito (#63) |

`joinUrl`: origine web + `/?code=SPRT-XXX`  
`helpUrl`: origine + `/help`

### Verifica

- [ ] Share include PIN line solo se stanza protetta (info da room state / join info)
- [ ] Testo leggibile incollato in Slack mobile

---

## #64 Voto anonimo pre-reveal

Complementa presenza voti (#38): oggi gli avatar mostrano chi ha votato prima del reveal.

### Migration

```sql
ALTER TABLE rooms
  ADD COLUMN hide_voters_until_reveal BOOLEAN NOT NULL DEFAULT false;
```

### RPC

Estendere `set_room_settings`:

```sql
set_room_settings(
  p_participant_id UUID,
  p_auto_reveal_when_all_voted BOOLEAN,
  p_hide_voters_until_reveal BOOLEAN DEFAULT NULL  -- NULL = non cambiare
)
```

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` | `Room.hideVotersUntilReveal` |
| `room_deck_settings_sheet.dart` | Switch «Nascondi chi ha votato fino al reveal» |
| `room_screen.dart` / `participant_avatar.dart` | `showVoteStatus: revealed \|\| !hideVotersUntilReveal` |
| `voting_panel.dart` | Contatore N/M sempre visibile |

### Verifica

- [ ] Flag off → comportamento attuale
- [ ] Flag on pre-reveal → nessun badge voto su avatar; post-reveal invariato
- [ ] Observer esclusi dal conteggio N/M (come #50)

---

## #65 Chiusura sessione + mini-retro

### Flusso

Menu barman (lobby o post-voting) → «Chiudi serata»:

1. Riepilogo KPI (#57) inline
2. Campo note retro (testo libero, solo export)
3. Checkbox «Segna ordini pending come saltati» (opzionale — RPC batch o loop `mark_story_spike` / nuovo `skip_story` se necessario; MVP: solo note + export)
4. Pulsanti: Export report · Duplica stanza (#58) · Esci

### Flutter

| File | Modifica |
|------|----------|
| `lib/features/lobby/session_close_sheet.dart` | **Nuovo** |
| `session_report.dart` | `toMarkdown(retroNotes: …)` |
| `room_screen.dart` | Voce menu / AppBar |

MVP senza migration: note retro solo in export Markdown/JSON del wizard, non persistite su DB.

### Verifica

- [ ] Solo barman vede «Chiudi serata»
- [ ] Export include sezione retro se compilata
- [ ] Duplica da wizard funziona

---

## #66 Open Graph / anteprima link join

### Web static

| File | Modifica |
|------|----------|
| `web/index.html` | Meta OG default (titolo app, description, image) |
| `web/join.html` o Vercel rewrite | Pagina leggera con meta dinamici via query `?code=` (opzionale fase 2) |

MVP: meta statici migliorati in `index.html` + `og:image` asset in `web/icons/`.

Rewrite Vercel (se utile):

```json
{ "source": "/j/:code", "destination": "/?code=:code" }
```

### Verifica

- [ ] [opengraph.xyz](https://www.opengraph.xyz) o Slack debugger mostra titolo + immagine
- [ ] Link `/?code=XXX` apre join come oggi

---

## #67 Export Linear / GitHub Issues

Estensione [session_report.dart](../../lib/core/export/session_report.dart):

| Formato | Output |
|---------|--------|
| **Linear** | Tab-separated: Title, Estimate, Description, Labels |
| **GitHub Issues** | Markdown checklist `- [ ] **Title** (points: N)` |

### Flutter

| File | Modifica |
|------|----------|
| `session_report.dart` | `toLinear()`, `toGitHubIssues()` |
| `session_report_sheet.dart` | Due pulsanti export aggiuntivi |

### Verifica

- [ ] Copia negli appunti; spike con stima `—`
- [ ] Note facilitatore incluse se flag report (#52)

---

## #68 Feedback post-sessione

### Trigger

Dopo `AppPreferences.markSessionCompleted()` (già UI-H), mostra dialog una tantum:

- 👍 / 👎
- Link opzionale «Lascia un suggerimento» → URL GitHub Issues/Discussions (costante in app)

### Preferenze

```dart
static const _hasSubmittedFeedbackKey = 'has_submitted_feedback';
```

### Verifica

- [ ] Mostrato al massimo una volta
- [ ] Decline / submit marca flag; nessun crash offline

---

## Criteri di done fase

- [ ] Tutti i punti #59–68 con checkbox verifica soddisfatti
- [ ] `flutter test` + `flutter analyze --fatal-infos` verdi
- [ ] Migration #64 applicata; CI `supabase-migrations` verde
- [ ] ARB IT/EN aggiornati (help + invito + preset + chiusura sessione)
- [ ] Nessuna regressione join/rejoin e export Fase 14

## Fuori scope fase

- Login / workspace multi-tenant
- API Linear/GitHub live
- CMS esterno per help (MVP = ARB in repo)
- A/B test o analytics obbligatori
- Progetto Supabase staging (#35)
