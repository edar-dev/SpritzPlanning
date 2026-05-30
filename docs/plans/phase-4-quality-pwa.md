# Fase 4 — Qualità e PWA

**Punti:** #5 Test E2E · #6 PWA  
**Branch suggerito:** `feat/e2e-and-pwa`  
**Durata stimata:** 4–5 giorni  
**Dipende da:** [Fase 1](phase-1-security-ci.md) (CI base)

---

## #5 Test integrazione flusso votazione

### Obiettivo

Proteggere il flusso core da regressioni: stanza → ordine → votazione → reveal → stima.

### Opzione A — Supabase test (consigliata)

1. Creare progetto Supabase **test** separato da produzione.
2. Applicare tutte le migration.
3. Secrets GitHub: `SUPABASE_URL_TEST`, `SUPABASE_ANON_KEY_TEST`.

**File:** `integration_test/room_flow_test.dart`

```dart
// Pseudocodice sequenza
final session = await repo.createRoom(name: 'Test', nickname: 'Barman');
await repo.addStory(participantId: session.participantId, title: 'US-1');
await repo.startVoting(...);
await repo.castVote(..., value: '5');
await repo.revealVotes(...);
await repo.setFinalEstimate(..., estimate: '5');
await repo.nextStory(...);
```

Eseguire con:

```bash
flutter test integration_test \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

### Opzione B — Unit + mock (più leggera)

Se non si vuole progetto test:

- `test/vote_stats_test.dart` — logica consenso/outlier
- `test/room_state_test.dart` — getter `allParticipantsVoted`, ecc.
- Mock `RoomRepository` per provider (opzionale)

### CI

Estendere `.github/workflows/ci.yml`:

```yaml
integration:
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main'
  steps:
    # ... secrets test
    - run: flutter test integration_test
```

### Verifica

- [ ] Test verdi in locale con env test
- [ ] CI verde (o job skippato se secrets assenti, documentato)

---

## #6 PWA installabile

### Obiettivo

App web installabile su home screen mobile/desktop; cache shell per caricamento rapido.

### Manifest

Verificare [`web/manifest.json`](../../web/manifest.json):

- `display: standalone`
- `theme_color`, `background_color` allineati a `AppColors`
- Icone 192/512 maskable

### Service worker

Flutter web genera `flutter_service_worker.js` al build.

Opzioni:

1. **Default Flutter** — sufficiente per molti casi
2. **`flutter_pwa`** — wrapper semplificato
3. **Workbox post-build** in `scripts/vercel-build.sh` — cache-first per assets

### Install prompt (web only)

In [`lib/features/home/home_screen.dart`](../../lib/features/home/home_screen.dart):

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
// Banner "Installa SpritzPlanning" quando beforeinstallprompt disponibile
```

Usare package `pwa_install` o JS interop minimale.

### Vercel

[`vercel.json`](../../vercel.json) — header per service worker:

```json
{
  "headers": [
    {
      "source": "/flutter_service_worker.js",
      "headers": [{ "key": "Cache-Control", "value": "no-cache" }]
    }
  ]
}
```

### Verifica

- [ ] Lighthouse PWA: installabile, manifest valido
- [ ] Install su Chrome Android / desktop
- [ ] Build APK Android **non** regressa (PWA solo web)

---

## Criteri di done — Fase 4

- [ ] Almeno un test integrazione o suite unit su `VoteStats` + documentazione
- [ ] PWA score Lighthouse ≥ 80 (categoria PWA)
- [ ] CI estesa (test + opzionale integration)
- [ ] README: sezione "Installa come app"

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Test flaky su rete | Retry, progetto test isolato |
| Service worker cache stale | `no-cache` su sw file |
| `integration_test` richiede device | Usare `flutter test` driver su web in CI |

## Non in scope

- Push notifications
- Offline completo (voti in coda)
- i18n (punto 10)
