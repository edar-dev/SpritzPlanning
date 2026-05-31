# Fase 10 — Quality gates e integration test

**Punti:** #26 Analyze severo · #29 Loop integration test  
**Branch suggerito:** `chore/quality-gates`  
**Durata stimata:** 2–4 giorni  
**Dipende da:** [Fase 9](phase-9-dev-toolchain.md) consigliata (script test, env example)

## Obiettivo

Bloccare in CI regressioni lint incrementali; rendere eseguibile e documentato il flusso `integration/room_flow_integration_test.dart` con env dedicato e job CI opzionale.

---

## #26 `analysis_options` più severo

### Strategia a scalini

**Step 1 — CI (subito):**

```yaml
# .github/workflows/ci.yml
- run: flutter analyze --fatal-infos
```

**Step 2 — `analysis_options.yaml`:**

```yaml
linter:
  rules:
    prefer_single_quotes: true
    always_declare_return_types: true
    avoid_redundant_argument_values: true
```

Abilitare una regola per PR se il diff è grande.

**Step 3 — Riverpod (opzionale):**

- `custom_lint` + `riverpod_lint` in `dev_dependencies`
- `analysis_options.yaml` → `plugins: - custom_lint`

### Pulizia exclude

| Path | Azione |
|------|--------|
| `integration/**` | Valutare rimozione exclude dopo fix test imports |
| `lib/core/pwa/pwa_install_listener_web.dart` | Mantenere solo se necessario per conditional import |

### Fix attesi

- Quote doppie → singole in `lib/` (batch o per directory)
- Return types espliciti su API pubbliche repository/providers

### Verifica

- [ ] `flutter analyze --fatal-infos` verde su `main`
- [ ] Nessun `// ignore` nuovo senza commento motivazione

---

## #29 Integration test loop

### Stato attuale

- File: `integration/room_flow_integration_test.dart`
- Richiede Supabase reale o progetto test con anon key

### Nuovo: `docs/TESTING.md`

Sezioni:

1. **Unit/widget** — `flutter test`
2. **Integration** — prerequisiti rete, `env.test.json`
3. **CI** — job manuale / nightly, secrets GitHub
4. **Agent** — non creare stanze spam; usare codice room fixture se documentato

### `env.test.json.example`

```json
{
  "SUPABASE_URL": "https://YOUR_TEST_PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "your-test-anon-key"
}
```

- Progetto dedicato **consigliato** (non production `eyvfsgzbrdibheyejikf`)
- Documentare in playbook: mai committare `env.test.json`

### Script: `scripts/run-integration.ps1`

```powershell
# Pseudocodice piano
if (-not (Test-Path env.test.json)) { Copy-Item env.test.json.example env.test.json; exit 1 }
fvm flutter test integration/room_flow_integration_test.dart -d chrome `
  --dart-define-from-file=env.test.json
```

### Script: `scripts/run-integration.sh`

- Equivalente per CI/Linux

### Seed / cleanup (opzionale)

- RPC o SQL documentato per eliminare room test prefix `TEST-`
- Oppure test crea room e cleanup in `tearDown` via repository

### CI: workflow opzionale

File: `.github/workflows/integration.yml`

```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: '0 6 * * 1'  # settimanale
```

Secrets: `SUPABASE_TEST_URL`, `SUPABASE_TEST_ANON_KEY`

**Non** gate obbligatorio su ogni PR finché flaky/rete non stabilizzati.

### Verifica

- [ ] `docs/TESTING.md` linkato da README e `AGENT-PLAYBOOK.md`
- [ ] Integration test passa localmente con `env.test.json`
- [ ] Almeno un run manuale CI `workflow_dispatch` documentato nel PR

---

## Criteri di done — Fase 10

- [ ] CI: `flutter analyze --fatal-infos`
- [ ] Almeno 3 regole lint nuove attive senza eccezioni massicce
- [ ] `docs/TESTING.md` + `env.test.json.example` + script run-integration
- [ ] Job integration opzionale (dispatch o schedule) configurato o issue follow-up esplicita nel PR

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| `--fatal-infos` blocca CI per centinaia di info | Abilitare a scalini; PR dedicato solo analyze |
| Integration flaky (Realtime) | Retry documentato; job non su ogni push |
| Test contro production DB | Progetto Supabase test separato obbligatorio in doc |

## Ordine interno consigliato

1. #29 Documentazione + script locale (valore immediato)
2. #26 Fatal infos in CI dopo fix batch quote/return types
3. #29 Job CI nightly (ultimo)

---

## Follow-up opzionale (fuori scope fase)

- `golden_toolkit` per widget critici (voting panel)
- Coverage threshold in CI
- `melos` solo se il monorepo cresce
