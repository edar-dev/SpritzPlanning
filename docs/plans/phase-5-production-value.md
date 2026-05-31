# Fase 5 — Produzione e valore retro

**Punti:** #17 Osservabilità · #15 Export stime  
**Branch suggerito:** `feat/observability-and-export`  
**Durata stimata:** 3–5 giorni  
**Dipende da:** [Fase 4](phase-4-quality-pwa.md) (CI e PWA base)

## Obiettivo

Capire cosa fallisce in produzione e dare al team un output concreto a fine sessione (CSV/Markdown).

---

## #17 Osservabilità (Sentry + errori UI)

### Dipendenza

```yaml
# pubspec.yaml
dependencies:
  sentry_flutter: ^8.0.0  # verificare ultima compatibile con SDK progetto
```

### Configurazione

| Dove | Cosa |
|------|------|
| `env.json.example` | `SENTRY_DSN` (opzionale) |
| Vercel env | `SENTRY_DSN` Production |
| `lib/main.dart` | `SentryFlutter.init` prima di `runApp` se DSN presente |
| `lib/data/supabase/supabase_client.dart` | No secret oltre DSN pubblico |

### Cattura errori

| Area | Azione |
|------|--------|
| `RoomRepository` | Wrapper su RPC: `Sentry.captureException` su failure |
| `RealtimeConnectionManager` | Breadcrumb su transizione `connected` → `disconnected` |
| `RoomStateNotifier` | Report `AsyncError` con tag `room_id` (no nickname) |
| SnackBar attuali | Sostituire testo grezzo `Exception:` con messaggio da `AppStrings` |

### Nuovo: `lib/core/errors/user_facing_error.dart`

```dart
String userFacingMessage(Object error) {
  // Mappa PostgrestException / messaggi RPC italiani → copy UI
}
```

### Nuovo: `lib/shared/widgets/error_snackbar.dart`

Helper `showUserError(context, error)` usato da lobby/voting/home.

### Verifica

- [ ] Evento test inviato a Sentry dashboard
- [ ] App funziona senza `SENTRY_DSN` (no-op)
- [ ] Nessun PII (nickname, codice stanza) nei tag Sentry di default

---

## #15 Export / report stime sessione

### Flutter (no migration DB)

I dati sono già in `RoomState.stories` con `status == done` e `finalEstimate`.

| File | Modifica |
|------|----------|
| `lib/core/export/session_report.dart` | `SessionReport.fromRoomState(RoomState)` → CSV + Markdown |
| `lib/features/lobby/session_report_sheet.dart` | Bottom sheet “Riepilogo serata” |
| `room_screen.dart` | Voce menu AppBar (barman) o pulsante in sidebar |
| `app_strings.dart` | `riepilogoSerata`, `exportCsv`, `exportMarkdown`, `copiaReport` |

### Formato CSV

```csv
locale,codice,ordine,stima_finale,completato_il
Bar Team Alpha,SPRT-A3K9,Login OAuth,5,2026-05-29T14:30:00Z
```

### Formato Markdown (share)

```markdown
# SpritzPlanning — Riepilogo
**Locale:** Bar Team Alpha (`SPRT-A3K9`)

| Ordine | Stima |
|--------|-------|
| Login OAuth | 5 |
```

Usare `share_plus` + `Clipboard` per copia.

### Verifica

- [ ] Sheet mostra solo ordini `done` con stima
- [ ] CSV apribile in Excel/LibreOffice
- [ ] Share funziona su web e Android

---

## Criteri di done — Fase 5

- [ ] Sentry opzionale configurato su Vercel
- [ ] Errori RPC mostrano messaggio italiano user-friendly
- [ ] Export report disponibile al barman
- [ ] `flutter analyze` e `test` verdi

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Sentry quota free | Sample rate 0.2 in prod; filtrare errori noti |
| Export vuoto (nessun ordine done) | Empty state “Nessuna stima ancora confermata” |
| DSN esposto nel bundle web | Accettabile (DSN è public); no auth token |

## Ordine interno consigliato

1. #17 Sentry + errori UI (prima di nuove feature)
2. #15 Export (valore immediato per il team)
