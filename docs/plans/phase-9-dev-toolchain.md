# Fase 9 — Toolchain dev riproducibile

**Punti:** #23 FVM + version check · #24 Bootstrap one-command · #25 Pre-commit · #30 Dev Container  
**Branch suggerito:** `chore/dev-toolchain`  
**Durata stimata:** 3–5 giorni  
**Dipende da:** [Fase 8](phase-8-agent-docs.md) (doc aggiornata; opzionale parallelizzare dopo #21)

## Obiettivo

Stesso Flutter in locale, CI e Vercel; setup nuovo clone in un comando; hook che evitano PR con l10n/formattazione dimenticata; ambiente containerizzato per agent e contributor.

---

## #23 Pin Flutter (FVM) + check versione

### File

| File | Contenuto |
|------|-----------|
| `.fvm/fvm_config.json` | `{ "flutter": "3.35.6" }` |
| `.fvmrc` o `.gitignore` | Ignorare `.fvm/flutter_sdk` se symlink locale |
| `README.md` | Install FVM, `fvm use`, `fvm flutter pub get` |

### Script: `scripts/check-flutter-version.ps1`

- Legge versione da `.fvm/fvm_config.json` o da `FLUTTER_VERSION=3.35.6` in CI
- Confronta `flutter --version` (prima riga)
- Exit 1 con messaggio se mismatch

### Script: `scripts/check-flutter-version.sh`

- Equivalente bash per CI Linux / devcontainer

### CI (opzionale in questa fase)

In `.github/workflows/ci.yml`, step prima di `flutter pub get`:

```yaml
- name: Verify Flutter version
  run: bash scripts/check-flutter-version.sh
```

Allineamento esplicito con:

- `.github/workflows/ci.yml` → `flutter-version: '3.35.6'`
- `scripts/vercel-build.sh` → stesso pin

### Verifica

- [ ] `fvm flutter --version` → 3.35.6
- [ ] Script check passa in CI
- [ ] README documenta fallback senza FVM (“usa Flutter 3.35.6 manualmente”)

---

## #24 Bootstrap dev one-command

### Script: `scripts/dev-setup.ps1`

Sequenza:

1. Verifica `flutter` / `fvm flutter` disponibile
2. Se manca `env.json`, copia da `env.json.example` e avvisa di compilare chiavi
3. `flutter pub get` (via fvm se presente)
4. `flutter gen-l10n`
5. Stampa Supabase project id e URL dashboard
6. Se `supabase` CLI in PATH: suggerire `supabase link` + `db push` (non forzare)

### Script: `scripts/dev-setup.sh`

- Stessa logica per Linux/macOS/devcontainer

### README

Sezione **Quick start**:

```powershell
.\scripts\dev-setup.ps1
fvm flutter run -d chrome --dart-define-from-file=env.json
```

### `env.json.example`

Commenti per ogni chiave:

```json
{
  "//": "Copia in env.json — non committare",
  "SUPABASE_URL": "https://xxxx.supabase.co",
  "SUPABASE_ANON_KEY": "eyJ...",
  "SENTRY_DSN": ""
}
```

(JSON con commenti: usare file `.md` companion `env.json.example.md` se il parser JSON strict fallisce — preferire documentazione in README + valori placeholder validi.)

### Verifica

- [ ] Clone fresco + script → `gen-l10n` eseguito, `pub get` ok
- [ ] Messaggio chiaro se `env.json` mancante

---

## #25 Pre-commit / pre-push

### Scelta tool

**Consigliato:** [lefthook](https://github.com/evilmartians/lefthook) (`lefthook.yml` in root).

Alternativa: script `scripts/pre-push.ps1` documentato senza tool esterno (minimo viable).

### Hook `pre-commit`

| Step | Comando |
|------|---------|
| Format | `dart format --set-exit-if-changed lib test integration` |
| L10n | `flutter gen-l10n` poi `git diff --exit-code lib/l10n/` **solo se** policy = commit file generati |

**Policy l10n (scegliere una e documentare in README):**

- **A)** Committare output `lib/l10n/app_localizations*.dart` → hook verifica diff dopo gen
- **B)** Solo ARB committati → CI esegue `gen-l10n` prima di analyze (già in `vercel-build.sh`)

Allineare con stato attuale repo prima di implementare.

### Hook `pre-push` (leggero)

- `flutter analyze` (senza fatal se Fase 10 non completata)
- oppure solo reminder: “esegui flutter test”

### Documentazione

`docs/CONTRIBUTING.md` (nuovo, breve): install lefthook, `lefthook install`, bypass solo in emergenza (`LEFTHOOK=0`).

### Verifica

- [ ] Commit con ARB non rigenerato → hook fallisce (se policy A)
- [ ] `dart format` applicato automaticamente o errore esplicito

---

## #30 Dev Container

### `.devcontainer/devcontainer.json`

- Immagine base con Flutter **3.35.6** (feature devcontainer ufficiale o Dockerfile custom)
- Estensioni: Dart, Flutter
- `postCreateCommand`: `bash scripts/dev-setup.sh`
- Forward port 8080 per web debug

### `.devcontainer/Dockerfile` (se necessario)

- Pin SDK Flutter uguale a FVM/CI

### VS Code / Cursor

| File | Modifica |
|------|----------|
| `.vscode/launch.json` | Mantieni Chrome/Android con `env.json` |
| Nuova config | `"SpritzPlanning (Chrome, no secrets)"` — solo analyze/test, o messaggio pre-launch task |

### `devcontainer.json` — secrets

- `env.json` non in immagine: mount da host o `containerEnv` da devcontainer `secrets` (documentare)

### Verifica

- [ ] Dev Container: `flutter test` passa con `env.json` montato
- [ ] `flutter analyze` verde nel container

---

## Criteri di done — Fase 9

- [x] FVM 3.35.6 documentato e script version check in CI
- [x] `dev-setup` funziona su Windows (PowerShell) e Linux (bash)
- [x] Hook pre-commit configurati (lefthook.yml + CONTRIBUTING)
- [x] Dev Container avviabile con istruzioni in README
- [x] Nessuna modifica funzionale app in `lib/features/`
- [ ] PR `chore/dev-toolchain` mergiata

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| FVM non installato su Windows team | README con path Flutter SDK manuale + check script |
| Hook rallentano commit | Solo format + l10n; analyze solo pre-push opzionale |
| Devcontainer image Flutter obsoleta | Pin esplicito + rebuild doc |

## Ordine interno consigliato

1. #23 FVM + check (sblocca coerenza)
2. #24 dev-setup (usa FVM)
3. #25 Hook (dipende da policy l10n chiarita)
4. #30 Dev Container (incapsula 23+24)
