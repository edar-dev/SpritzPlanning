# Fase 16 — Session depth e PWA avanzata

**Punti:** #69 OG dinamico · #70 Template custom · #71 Story riferimento · #72 Commenti story · #73 Confidence vote · #74 Import Jira/ADO · #75 Push PWA · #76 Suoni/haptic · #77 Lighthouse CI · #78 Cronologia stime  
**Branch suggerito:** `feat/session-depth`  
**Durata stimata:** 10–14 giorni  
**Dipende da:** [Fase 15](phase-15-discoverability.md) · [Fase 14](phase-14-session-advanced.md) · [Fase 11](phase-11-session-productivity.md)

Elenco riepilogativo: [IMPROVEMENTS-V8.md](../IMPROVEMENTS-V8.md).

## Obiettivo

Approfondire la **facilitazione in sessione** (riferimento, commenti, confidence), completare il **round-trip import/export** con tool esterni, portare la **PWA al livello successivo** (push VAPID), e aggiungere **quality gate Lighthouse** — senza account o API cloud live.

---

## Ordine di implementazione

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #69, #76, #77 | OG dinamico, suoni/haptic, Lighthouse CI |
| 2 | #70, #74 | Template custom, import Jira/ADO |
| 3 | #71, #72, #73 | Riferimento, commenti, confidence vote |
| 4 | #75, #78 | Push PWA, cronologia stime |

**Migration SQL** (timestamp Supabase, `supabase migration new …`):

1. `story_reference_and_public_comment` — colonne `is_reference`, `public_comment` (#71, #72)
2. `story_estimate_history` — colonna JSONB o tabella eventi (#78)

#69, #70, #74, #76, #77: nessuna migration (web static, client locale, CI).  
#73 MVP: stato sessione client-side; migration opzionale fase 2 se serve persistenza cross-device.  
#75: Edge Function o endpoint VAPID (Supabase Edge / Vercel serverless); nessuna migration tabelle app.

Aggiornare [supabase/README.md](../../supabase/README.md) per migration #71/#72/#78.

**Regola RPC:** quando si estende una firma esistente, `DROP FUNCTION` della versione precedente prima del `CREATE OR REPLACE` (lezione da `20260604120000_drop_rpc_overloads.sql`).

---

## #69 Open Graph dinamico per codice stanza

Completamento MVP #66: meta statici in `index.html` → anteprima **per codice** quando si condivide un link join.

### Web static

| File | Modifica |
|------|----------|
| `web/join.html` | **Nuovo** — legge `?code=` da URL, imposta `<meta property="og:*">` via script inline minimo |
| `vercel.json` | Rewrite `{ "source": "/j/:code", "destination": "/join.html?code=:code" }` |
| `lib/core/share/room_invite_text.dart` | Opzionale: URL share `…/j/SPRT-XXX` oltre a `/?code=` |

Alternativa senza pagina dedicata: SSR/edge che inietta meta — fuori scope MVP; preferire `join.html` statico + redirect JS verso app Flutter.

### Flusso

1. Crawler Slack/WhatsApp legge `join.html` → meta con codice e titolo generico «Unisciti a SpritzPlanning»
2. Utente umano → redirect a `/?code=XXX` (comportamento join attuale)

Fase 2 (opzionale): fetch nome stanza via RPC pubblico `get_room_join_info` per `og:title` con nome locale (richiede CORS/crawler-friendly endpoint).

### Verifica

- [ ] [opengraph.xyz](https://www.opengraph.xyz) su `/j/SPRT-TEST` mostra titolo + immagine
- [ ] Tap link apre join Flutter come oggi
- [ ] Invito smart (#63) può usare URL `/j/:code`

---

## #70 Template stanza personalizzati (locale)

Estende template built-in (#54) con preset **salvati dal barman** sul device.

### Storage

Nuovo `lib/core/preferences/custom_room_templates_storage.dart`:

```dart
// max 10 template: name, deckValues, storyTitles[], settings snapshot
```

### UI

| File | Modifica |
|------|----------|
| `lib/features/lobby/room_template_sheet.dart` | Tab «Salvati» + «Salva corrente» (barman) |
| `home_screen.dart` | Creazione stanza da template custom |

Snapshot settings: `autoReveal`, `hideVotersUntilReveal`, deck — no PIN (sicurezza).

### Verifica

- [ ] Salva template da stanza attiva (deck + backlog titoli)
- [ ] Crea nuova stanza da template custom
- [ ] Cap 10; elimina singolo template
- [ ] Nessun dato su Supabase (solo locale)

---

## #71 Story di riferimento (relative sizing)

Una story per stanza marcata come **ancora** per relative sizing.

### Migration

```sql
ALTER TABLE stories
  ADD COLUMN is_reference BOOLEAN NOT NULL DEFAULT false;
```

RPC `set_reference_story(p_participant_id, p_story_id)` — barman only; unset altre reference nella stessa room.

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` | `Story.isReference` |
| `room_screen.dart` / story tile | Badge «Riferimento»; menu barman «Imposta come riferimento» |
| `voting_panel.dart` | Se reference ha `finalEstimate`, hint «~N× riferimento» sulle altre (solo post-prima-stima reference) |

Hint = rapporto mediana voti corrente / punti reference (solo numerici deck).

### Verifica

- [ ] Una sola reference per stanza
- [ ] Hint non blocca voto; solo informativo
- [ ] Export report indica story di riferimento

---

## #72 Commenti / domande su story

Note **pubbliche** visibili a tutti (≠ note facilitatore #52, private/export).

### Migration

```sql
ALTER TABLE stories
  ADD COLUMN public_comment TEXT NOT NULL DEFAULT '';
```

Estendere `update_story` con param opzionale `p_public_comment TEXT DEFAULT NULL`.

### Flutter

| File | Modifica |
|------|----------|
| `story_detail_sheet.dart` o tile | Campo commento editabile da qualsiasi partecipante (o solo barman — decidere MVP: tutti) |
| `session_report.dart` | Sezione commenti in Markdown se non vuoti |

MVP: tutti possono commentare (collaborazione); max 500 char; sanitizzazione trim.

### Verifica

- [ ] Commento visibile in realtime agli altri clienti
- [ ] Distinto da `facilitatorNote` (#52)
- [ ] Export opzionale include commenti pubblici

---

## #73 Secondo round «confidence vote»

Dopo reveal con spread alto (es. max/min ≥ 2 livelli Fibonacci), barman propone confidence vote.

### MVP (client + RPC leggero)

Opzione A — **solo UI sessione:** stato locale `confidenceByParticipant`; non persistito.  
Opzione B — tabella `confidence_votes(story_id, participant_id, value)` + RPC `cast_confidence_vote`.

Preferire **Opzione B** se integration test deve coprire il flusso.

```sql
CREATE TABLE confidence_votes (
  story_id UUID REFERENCES stories(id) ON DELETE CASCADE,
  participant_id UUID REFERENCES participants(id) ON DELETE CASCADE,
  value SMALLINT CHECK (value BETWEEN 1 AND 5),
  PRIMARY KEY (story_id, participant_id)
);
```

### Flutter

| File | Modifica |
|------|----------|
| `lib/features/voting/confidence_panel.dart` | **Nuovo** — slider 1–5 o stelle |
| `room_screen.dart` | CTA barman «Confidence?» post-reveal se spread alto |
| `voting_panel.dart` | Barra progress «4/6 confidenti» |

Non modifica `finalEstimate`; chiusura manuale o auto dopo timeout 60s.

### Verifica

- [ ] Solo dopo reveal; non sostituisce planning poker
- [ ] Observer esclusi (#50)
- [ ] Skip/chiudi torna a lobby normale

---

## #74 Import backlog da export Jira/ADO

Round-trip con export #53: incolla output tool esterni.

### Parser

Nuovo `lib/core/import/jira_ado_parser.dart`:

| Formato | Heuristic |
|---------|-----------|
| Jira CSV export | Colonna Summary / Story Points |
| ADO CSV | Title, Story Points |
| Tab-separated | Stessa logica di `toJira()` / `toAdo()` invertita |

### UI

| File | Modifica |
|------|----------|
| `lib/features/lobby/backlog_import_sheet.dart` | Tab «Jira/ADO export» accanto a paste (#31) |
| Preview righe + stima opzionale prima di `add_stories` |

### Verifica

- [ ] Export #53 → re-import stesso file → titoli + stime coerenti
- [ ] Righe malformate skippate con messaggio
- [ ] Max 50 stories (come #31)

---

## #75 Push notification PWA (VAPID)

Estende notifiche in-tab (#55) con **Web Push** quando app in background.

### Architettura

| Componente | Ruolo |
|------------|-------|
| Service worker | `push` event → `showNotification` |
| Flutter web | `push_subscribe` dopo opt-in; salva subscription in `participants.push_subscription JSONB` (migration) o tabella dedicata |
| Edge Function | Invia push su eventi: reveal, «ultimo a votare», timer scaduto |

Migration minima:

```sql
ALTER TABLE participants
  ADD COLUMN push_subscription JSONB;
```

RPC `register_push_subscription(p_participant_id, p_subscription JSONB)`.

Trigger push lato server su `reveal_votes` / hook — MVP: chiamata da RPC esistente via `pg_net` o Edge Function invocata post-RPC.

### Flutter

| File | Modifica |
|------|----------|
| `lib/core/notifications/web_push_service.dart` | **Nuovo** — permesso, subscribe, register |
| `room_deck_settings_sheet.dart` o prefs | Toggle «Notifiche push» (opt-in) |

Secret repo: `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`.

### Verifica

- [ ] Opt-in esplicito; revoca funziona
- [ ] Push ricevuta con tab in background (Chrome/Edge)
- [ ] Nessuna push senza subscription
- [ ] iOS Safari: documentare limitazioni PWA

---

## #76 Suoni e haptic opt-in

Feedback sensoriale su eventi chiave; **off** di default.

### Preferenze

```dart
static const _soundEffectsEnabledKey = 'sound_effects_enabled';
static const _hapticEnabledKey = 'haptic_enabled';
```

### Eventi

| Evento | Suono | Haptic |
|--------|-------|--------|
| Reveal voti | soft chime | medium |
| Timer scaduto (#14) | alert breve | heavy |
| Consenso suggerito (#39) | optional | light |

| File | Modifica |
|------|----------|
| `lib/core/feedback/session_feedback.dart` | **Nuovo** — wrapper `HapticFeedback` + `AudioPlayer` asset leggeri |
| `home_screen.dart` prefs bar | Toggle suoni / haptic |
| `room_screen.dart` | Hook su reveal, timer |

Asset: `assets/sounds/reveal.mp3` (< 50 KB); rispettare mute di sistema.

### Verifica

- [ ] Default off; prefs persistono
- [ ] Web: solo suono (no haptic); mobile: entrambi se abilitati
- [ ] Nessun autoplay prima di interazione utente (policy browser)

---

## #77 Lighthouse CI su preview Vercel

Quality gate automatico allineato a [PERFORMANCE.md](../PERFORMANCE.md).

### Workflow

Nuovo `.github/workflows/lighthouse.yml`:

- Trigger: `deployment_status` success su preview Vercel (o comment PR con URL)
- Action: `treosh/lighthouse-ci-action` o script `npx lighthouse`
- Assert: Accessibility ≥ 90; Performance ≥ 70 (warning, non block iniziale)

| File | Modifica |
|------|----------|
| `.github/workflows/lighthouse.yml` | **Nuovo** |
| `docs/PERFORMANCE.md` | Link workflow + soglie |

### Verifica

- [ ] Run su PR con preview Vercel
- [ ] Report artifact o comment PR
- [ ] Fallimento solo su regressioni a11y critiche (configurabile)

---

## #78 Cronologia stime e revisioni story

Audit trail quando una story viene ri-stimata o la stima cambia.

### Migration

```sql
ALTER TABLE stories
  ADD COLUMN estimate_history JSONB NOT NULL DEFAULT '[]'::jsonb;
```

Append in RPC `set_final_estimate` (e opz. `mark_story_spike`):

```json
[{"estimate":"8","at":"2026-06-01T19:00:00Z","by":"facilitator"}]
```

Oppure tabella `story_estimate_events` se query/analytics future.

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` | `Story.estimateHistory` |
| `session_report.dart` | Colonna «Revisioni» in Markdown/CSV |
| `session_archive_sheet.dart` | Mostra history in preview |

### Verifica

- [ ] Prima stima → history con 1 entry
- [ ] Cambio stima → append (non overwrite)
- [ ] Spike → entry con label `spike`
- [ ] Export archivio #61 include history se presente

---

## Criteri di done fase

- [ ] Tutti i punti #69–78 con checkbox verifica soddisfatti
- [ ] `flutter test` + `flutter analyze --fatal-infos` verdi
- [ ] Migration applicate; CI `supabase-migrations` verde
- [ ] Nessun overload RPC duplicato (pattern DROP + CREATE)
- [ ] ARB IT/EN aggiornati (commenti, confidence, template custom, push opt-in)
- [ ] Lighthouse workflow operativo su preview
- [ ] Nessuna regressione join/rejoin, export Fase 14–15

## Fuori scope fase

- Login / workspace multi-tenant
- API live Jira/Linear/GitHub con OAuth
- CMS esterno per help
- Progetto Supabase staging (#35)
- Video / audio call
- Chat realtime multi-thread
- OG dinamico con fetch nome stanza per crawler (fase 2 #69)
