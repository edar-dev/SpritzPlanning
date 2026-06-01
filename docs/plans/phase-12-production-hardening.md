# Fase 12 — Production hardening e UI polish

**Punti:** #34 UI ottimistica + retry · #36 CI stretta + smoke · #37 Accessibilità / proiettore · #40 Osservabilità operativa  
**UI:** UI-G, UI-H  
**Branch suggerito:** `chore/production-hardening`  
**Durata stimata:** 6–9 giorni  
**Dipende da:** [Fase 11](phase-11-session-productivity.md) consigliata (test E2E più ricchi)

## Obiettivo

Rendere l’app **resiliente alla rete**, **osservabile in produzione**, **verificabile in CI** e **usabile in sala riunioni** (a11y, loading, PWA).

---

## #34 UI ottimistica + retry RPC

### Repository

- `lib/data/repositories/room_repository.dart`:
  - `castVote`: aggiornamento ottimistico opzionale via callback o layer `RoomStateNotifier`
- `lib/data/providers/providers.dart` — `roomStateProvider.notifier`:
  - Metodo `castVoteOptimistic` che applica voto locale, poi RPC; rollback su errore

### Retry

- `lib/core/network/rpc_retry.dart` — `Future<T> withRpcRetry(Future<T> Function() fn, {int maxAttempts = 2})`
- Solo su errori rete / 5xx / timeout; **non** su 4xx business (nickname corto, ecc.)

### Errori

- Estendere `lib/core/errors/user_facing_error.dart` — codici `PGRST`, rate limit testo italiano/EN

### Verifica

- [ ] Throttle rete DevTools: voto mostrato subito, poi confermato o rollback + snackbar
- [ ] Doppio tap card: un solo RPC

---

## #36 CI stretta + smoke post-deploy

### Integration su PR

`.github/workflows/ci.yml` — job `integration-pr`:

```yaml
if: contains(github.event.pull_request.labels.*.name, 'integration')
```

Secrets già presenti (`SUPABASE_URL_TEST`, `SUPABASE_ANON_KEY_TEST`).

Documentare in `docs/TESTING.md`: label `integration` sul PR.

### Smoke deploy (opzionale)

`.github/workflows/deploy-smoke.yml`:

```yaml
on:
  deployment_status:
    types: [success]
# oppure workflow_dispatch dopo merge
```

Steps:

- `curl -f https://spritz-planning.vercel.app/`
- `curl -f https://spritz-planning.vercel.app/.well-known/assetlinks.json`
- `curl -f https://spritz-planning.vercel.app/manifest.json` (se path noto)

### Golden / widget (scope minimo)

- `test/voting_panel_golden_test.dart` — 1 golden reveal + 1 voting (opzionale `golden_toolkit` o `matchesGoldenFile` Flutter standard)

### Verifica

- [ ] PR con label `integration` → job verde
- [ ] Smoke manuale documentato in PR template

---

## #37 Accessibilità + modalità proiettore

### Semantics

- `SpritzCard`, `ParticipantAvatar`, FAB lobby: `Semantics(label: …, button: true)`
- `VotingPanel`: annunciare fase (`liveRegion` su reveal)

### Modalità sala

- `lib/core/preferences/app_preferences.dart` — `projectorMode` bool
- `lib/core/theme/app_theme.dart` — `textTheme` scale 1.25x quando attivo; card min size maggiore
- Toggle: home AppBar o sheet impostazioni minimo (accanto dark/language)

### Motion

- `MediaQuery.disableAnimationsOf(context)` rispettato su animazione reveal

### Verifica

- [ ] TalkBack / VoiceOver: card voto annunciata con valore
- [ ] Modalità sala: testo leggibile a 3m (test manuale)
- [ ] Lighthouse Accessibility ≥ 90 (documentare in `docs/PERFORMANCE.md`)

---

## #40 Osservabilità operativa

### Sentry

- `lib/core/monitoring/error_reporter.dart`:
  - Tag: `room_phase`, `is_facilitator`, `platform` (web/android)
  - **Mai** `room_code`, `nickname`, `participant_id` nei tag
- Breadcrumb su RPC fallita: solo `function` name + `code`

### Release

- `scripts/vercel-build.sh` o CI: passare `--dart-define=GIT_SHA=$GITHUB_SHA` (opzionale)
- `main.dart`: `SentryFlutter.init` → `release: gitSha`

### Dashboard

- Documentare in `docs/AGENT-PLAYBOOK.md`: link progetto Sentry `flutter`, alert consigliato su regressioni `PostgrestException`

### Verifica

- [ ] Test exception (dev only) appare in Sentry con tag phase
- [ ] Nessun PII nei eventi campione

---

## UI mirate — Fase 12

### UI-G — Skeleton `RoomScreen`

- `lib/features/lobby/room_screen.dart`: sostituire `CircularProgressIndicator` full-screen con `RoomScreenSkeleton` (shimmer o placeholder box sidebar + cards)
- File: `lib/shared/widgets/room_screen_skeleton.dart`

### UI-H — PWA dopo prima sessione

- `lib/core/preferences/app_preferences.dart`: `hasCompletedSession`
- Set true quando barman fa `nextStory` su ultima story o leave dopo ≥1 story `done`
- `lib/shared/widgets/pwa_install_banner.dart`: mostra solo se `hasCompletedSession && !installed`

---

## Ordine interno consigliato

1. #40 Osservabilità (basso rischio, valore subito)
2. UI-G Skeleton
3. #34 Ottimistico + retry
4. #36 CI
5. #37 A11y + modalità sala
6. UI-H PWA

---

## Criteri di done — Fase 12

- [ ] Retry e rollback voto documentati in `TESTING.md` (scenario manuale)
- [ ] Label `integration` su PR documentata
- [ ] Sentry tag senza PII verificato
- [ ] Skeleton su load room; PWA banner logic aggiornata
- [ ] `flutter analyze --fatal-infos` + `flutter test` verdi

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Ottimistico desync Realtime | Realtime event sovrascrive stato; version counter opzionale |
| Integration flaky su ogni PR | Solo con label esplicita |
| Golden flaky font | `flutter_test_config` + font stable |

## Follow-up fuori scope

- #35 Progetto Supabase staging dedicato
- Coverage threshold CI
- `custom_lint` / riverpod_lint
