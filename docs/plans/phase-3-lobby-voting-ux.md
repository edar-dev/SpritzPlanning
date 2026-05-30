# Fase 3 — Feature UX lobby e votazione

**Punti:** #4 Barman · #7 QR · #8 Dashboard voti  
**Branch suggerito:** `feat/lobby-voting-ux`  
**Durata stimata:** 4–6 giorni  
**Dipende da:** [Fase 2](phase-2-realtime.md) (consigliata per UX multi-client)

---

## #4 Trasferimento Barman

### Migration: `supabase/migrations/004_transfer_facilitator.sql`

```sql
CREATE OR REPLACE FUNCTION transfer_facilitator(
  p_from_participant_id UUID,
  p_to_participant_id UUID
) RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
-- Solo barman corrente (p_from) può trasferire
-- Entrambi nella stessa room
-- SET is_facilitator = false per tutti, true solo per p_to
$$;
```

`GRANT EXECUTE ... TO anon, authenticated;`

### Flutter

| File | Modifica |
|------|----------|
| `room_repository.dart` | `transferFacilitator(fromId, toId)` |
| `room_screen.dart` / `participant_avatar.dart` | Menu contestuale su cliente |
| `app_strings.dart` | `passaBancone`, `confermaPassaBancone` |

### UX

1. Barman tap/long-press su altro cliente
2. Dialog: "Passa il ruolo di Barman a **{nickname}**?"
3. Conferma → RPC → Realtime aggiorna badge

### Verifica

- [ ] Nuovo barman può aggiungere ordini e fare Servizio!
- [ ] Ex-barman diventa cliente normale

---

## #7 QR codice bancone

### Dipendenza

```yaml
# pubspec.yaml
dependencies:
  qr_flutter: ^4.1.0
```

### Payload QR

Preferenza URL web (funziona da camera telefono):

```
https://spritz-planning.vercel.app/?code=SPRT-XXXX
```

Alternativa custom scheme: `spritzplanning://join?code=SPRT-XXXX`

### File

| File | Modifica |
|------|----------|
| `room_code_display.dart` | `QrImageView` in espansione / bottom sheet |
| `router.dart` | Redirect `/?code=` → Home in modalità join |
| `home_screen.dart` | `initState`: leggere query param, precompilare campo codice |

### Android deep link (opzionale, step 2)

`AndroidManifest.xml` — intent-filter per host/path.

### Verifica

- [ ] QR generato in lobby
- [ ] Scan da telefono apre app/web con codice precompilato
- [ ] Join funziona senza digitare codice

---

## #8 Dashboard stato votazione

### Nuovo: `lib/core/voting/vote_stats.dart`

```dart
class VoteStats {
  final Map<String, int> distribution;
  final String? suggestedConsensus;  // valore più frequente (escl. ?, ☕)
  final List<String> numericOutliers;
  final int votedCount;
  final int participantCount;
}

VoteStats fromVotes(List<Vote> votes, List<Participant> participants);
```

**Logica consenso:** valore con >50% dei voti numerici.  
**Outlier:** valore numerico che devia > 1 livello Fibonacci dal mediano.

### Nuovo: `lib/features/voting/vote_summary_panel.dart`

- Barre orizzontali per distribuzione (`8: ████ 3`)
- Chip "Consenso suggerito: **5**"
- Lista outlier evidenziati
- Solo visibile dopo reveal (o parzialmente al barman pre-reveal)

### Integrazione

| Dove | Cosa |
|------|------|
| `voting_panel.dart` → `_RevealSection` | `VoteSummaryPanel` sotto carte voti |
| `room_screen.dart` (barman, fase voting) | `LinearProgressIndicator` "3/5 dosi scelte" |

### Stringhe

Aggiungere in `app_strings.dart`: `consensoSuggerito`, `distribuzioneVoti`, `dosiScelte`.

### Verifica

- [ ] Con voti 3,5,5,8 → consenso 5, outlier 8
- [ ] Barra progresso aggiornata in Realtime

---

## Criteri di done — Fase 3

- [ ] Migration 004 applicata
- [ ] QR + deep link web funzionanti
- [ ] Transfer barman testato con 2 utenti
- [ ] Summary voti visibile post-reveal
- [ ] Test widget opzionali su `VoteStats`

## Ordine interno consigliato

1. #4 Barman (sblocca team)
2. #8 Dashboard (valore sessione poker)
3. #7 QR (nice-to-have join rapido)
