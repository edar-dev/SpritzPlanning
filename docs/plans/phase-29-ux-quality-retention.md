# Fase 29 — UX qualità, chiusura sessione e retention

**Punti:** #122 Chiusura gentile · #123 Archivio actionable · #124 Smoke E2E · #125 Errori umani · #126 Coda voti offline  
**Branch suggerito:** `feat/ux-quality-retention`  
**Durata stimata:** 6–9 giorni  
**Dipende da:** Fasi 26–27 consigliate

## Obiettivo

Chiudere il cerchio **post-sessione**, aumentare **affidabilità percepita** (errori, offline) e formalizzare **QA manuale** lean.

**Migration DB:** nessuna (salvo audit opzionale).

---

## #122 Chiusura sessione con riepilogo

### Stato attuale

`SessionCloseSheet` — verificare contenuto minimo.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/features/lobby/session_close_sheet.dart` | Step finale: card riepilogo **3 metriche** |
| `lib/core/export/session_report_stats.dart` | Helper `SessionStats`: ordini stimati, durata sessione, partecipanti max |
| `lib/l10n/app_*.arb` | `closeSummaryTitle`, `closeSummaryStories`, `closeSummaryDuration`, `closeSummaryParticipants` |

### UI post-chiusura (sheet o dialog)

```
Serata chiusa 🍹
• 8 ordini stimati
• 42 minuti al bancone
• 6 clienti
[Copia report] [Duplica locale]
```

- **Duplica locale** → RPC `duplicate_room` esistente (barman).
- **Copia report** → apre `SessionReportSheet` o clipboard Markdown.

### Verifica

- [ ] Chiusura da menu Strumenti → riepilogo visibile
- [ ] Metriche coerenti con report CSV
- [ ] Leave senza close: nessun riepilogo forzato

---

## #123 Archivio sessioni actionable

### Stato attuale

`SessionArchiveStorage` + `session_archive_sheet.dart` — archivio locale post-sessione.

### Miglioramenti

| File | Modifica |
|------|----------|
| `lib/features/home/session_archive_sheet.dart` | Per entry: **Copia report** · **Usa come template** (titoli ordini) · **Elimina** |
| `lib/core/preferences/session_archive_storage.dart` | Persistere snapshot report Markdown (già parziale?) — estendere se manca |
| `lib/features/home/room_template_sheet.dart` | Import da archivio → prefill template |
| `lib/l10n/app_*.arb` | `archiveCopyReport`, `archiveUseTemplate` |

### Comportamento

- Archivio = lista sessioni chiuse localmente (non cloud).
- Tap entry → preview 3 righe + azioni.
- **Usa come template**: crea nuova stanza con stessi titoli ordini (pending), no stime.

### Verifica

- [ ] Chiudi sessione → compare in archivio home
- [ ] Template da archivio → nuova stanza con N ordini pending
- [ ] Elimina entry → sparisce da storage

---

## #124 Smoke E2E documentato

### Obiettivo

Portare `[ ] Flusso E2E stanza` in [LEAN-SMOKE.md](../LEAN-SMOKE.md) a checklist **ripetibile** con esito datato.

### Implementazione

| File | Modifica |
|------|----------|
| `docs/LEAN-SMOKE.md` | Sezione E2E espansa: passi numerati, expected, tempo max |
| `docs/plans/phase-24-simplification.md` | Segnare checkbox E2E quando completato |
| `.github/workflows/deploy-smoke.yml` | Opzionale: commento in summary con link a LEAN-SMOKE |

### Checklist E2E (contenuto)

1. Home → Apri locale (< 30 s)
2. Aggiungi 2 ordini
3. Condividi codice (copia)
4. Incognito join + voto
5. Reveal + stima + prossimo ordine
6. Report CSV copiato
7. **Nuovo:** switch ordine lista compatta (#28)
8. **Nuovo:** sticky Servizio mobile (#110, se Fase 26 done)

### Verifica

- [ ] Documento revisionato post Fase 26–28
- [ ] Una run manuale registrata (data + esito in LEAN-SMOKE)

---

## #125 Messaggi errore RPC umani (audit)

### Stato attuale

`lib/core/errors/user_facing_error.dart` — mapping PostgREST / RPC exceptions.

### Implementazione

| File | Modifica |
|------|----------|
| `lib/core/errors/user_facing_error.dart` | Audit completo messaggi `RAISE EXCEPTION` da migrations |
| `lib/l10n/app_*.arb` | Chiavi per errori frequenti: nickname taken, room not found, not facilitator, invalid vote |
| `test/user_facing_error_test.dart` | **Nuovo**: table-driven test su codici/messaggi |

### Errori prioritari

| RPC / caso | Copy IT lean |
|------------|--------------|
| Nickname occupato | «Questo nickname è già al bancone. Esci dall'altra sessione o attendi ~2 min.» |
| Stanza scaduta | «Locale chiuso. Chiedi un nuovo codice al barman.» |
| Non barman | «Solo il barman può fare questa azione.» |
| Voto invalido deck | «Quella dose non è nel menu della stanza.» |

### Verifica

- [ ] Test unitari ≥ 8 casi
- [ ] Nessuna stringa SQL grezza in snackbar
- [ ] EN parity

---

## #126 Coda voti offline / reconnect

### Problema

Rete instabile: `cast_vote` fallisce; utente non sa se il voto è arrivato.

### Implementazione (incrementale)

| File | Modifica |
|------|----------|
| `lib/core/network/vote_outbox.dart` | **Nuovo**: coda locale `storyId + value + participantId`; persist SharedPreferences |
| `lib/data/repositories/room_repository.dart` | `castVote`: on failure retriable → enqueue; on success flush outbox |
| `lib/features/lobby/room_screen.dart` o `connection_banner.dart` | Banner «Voto in invio…» / «Voto sincronizzato» |
| `lib/data/providers/room_state_provider.dart` | On `ConnectionStatus.connected` → flush outbox |

### Regole

- Max 1 voto pending per story per participant (overwrite).
- Flush in ordine FIFO; stop on permanent error (400).
- UI ottimistica: carta selezionata subito (allinea #118).

### Scope MVP

- Solo `cast_vote` — non generalizzare a tutte le RPC.
- Nessuna migration.

### Verifica

- [ ] DevTools offline → tap carta → online → voto registrato
- [ ] Doppio voto stesso story: ultimo vince
- [ ] Errore 400 deck invalid: outbox scartato + messaggio #125

---

## Sprint suggerito

| Sprint | Contenuto |
|--------|-----------|
| S29.1 | #122 close summary + #123 archivio |
| S29.2 | #125 error audit + test |
| S29.3 | #126 vote outbox + banner |
| S29.4 | #124 doc E2E + run manuale |

## Test plan

- [ ] Integration test opzionale: error mapping
- [ ] Manuale offline vote (Chrome DevTools)
- [ ] Sessione completa → archivio → template nuova stanza
- [ ] `flutter analyze --fatal-infos` + `flutter test`

## Metriche fase

- Zero snackbar con testo SQL grezzo in scenari smoke
- Vote outbox: 100% recovery in test offline controllato

## Criteri di done

- [ ] LEAN-SMOKE E2E checkbox `[x]` con data
- [ ] #126 behind feature flag o sempre on con test
- [ ] ROADMAP fasi 26–29 segnate in progress/done per sotto-deliverable

## Ops opzionali (non blocking)

- `SENTRY_DSN` su Vercel per errori reali post-release (#40 legacy)
- Android `assetlinks.json` fingerprint
