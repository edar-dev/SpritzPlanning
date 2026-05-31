# Contributing — SpritzPlanning

## Prerequisiti

- **Flutter 3.35.6** (pin del repo) — consigliato [FVM](https://fvm.app):
  ```bash
  fvm install
  fvm use
  ```
  Senza FVM: installa manualmente Flutter 3.35.6 e verifica con `scripts/check-flutter-version.ps1`.
- `env.json` da `env.json.example` (vedi [env.json.example.md](../env.json.example.md))

## Quick start

**Windows (PowerShell):**

```powershell
.\scripts\dev-setup.ps1
.\scripts\flutter.ps1 run -d chrome --dart-define-from-file=env.json
```

**Linux / macOS / Dev Container:**

```bash
bash scripts/dev-setup.sh
bash scripts/flutter.sh run -d chrome --dart-define-from-file=env.json
```

## Localizzazione (policy A)

I file generati in `lib/l10n/` sono **committati** insieme agli ARB.

Dopo ogni modifica a `lib/l10n/*.arb`:

```bash
flutter gen-l10n   # oppure scripts/flutter.sh gen-l10n
```

CI e Vercel eseguono `gen-l10n` prima di analyze/build.

## Git hooks (lefthook)

```bash
# macOS: brew install lefthook
# Windows: scoop install lefthook  — vedi https://lefthook.dev/installation/
lefthook install
```

| Hook | Azione |
|------|--------|
| pre-commit | `dart format`, `gen-l10n`, verifica diff `lib/l10n/` |
| pre-push | `flutter analyze` |

Bypass solo in emergenza: `LEFTHOOK=0 git commit …`

## Verifica prima di una PR

```bash
bash scripts/check-flutter-version.sh
bash scripts/flutter.sh pub get
bash scripts/flutter.sh gen-l10n
bash scripts/flutter.sh analyze --fatal-infos
bash scripts/flutter.sh test
```

Integration (opzionale): [TESTING.md](TESTING.md) — `env.test.json` + `scripts/run-integration.sh`

Template PR: [.github/pull_request_template.md](../.github/pull_request_template.md)

## Dev Container

Apri il repo in VS Code / Cursor → **Reopen in Container**. Monta `env.json` dal host (non committare).

Vedi [.devcontainer/README.md](../.devcontainer/README.md).

## Agenti AI

[AGENTS.md](../AGENTS.md) · [AGENT-PLAYBOOK.md](AGENT-PLAYBOOK.md)
