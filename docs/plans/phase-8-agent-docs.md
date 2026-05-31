# Fase 8 — Agent DX e documentazione allineata

**Punti:** #21 Doc sync · #22 Dead code i18n · #27 Agent playbook · #28 Skill e regole Cursor  
**Branch suggerito:** `chore/agent-docs-dx`  
**Durata stimata:** 2–3 giorni  
**Dipende da:** [Fase 7](phase-7-reach-polish.md) completata (i18n, l10n, migration 009)

## Obiettivo

Un’unica “fonte di verità” per umani e agenti AI: niente riferimenti a `AppStrings`/italiano-only, playbook operativo per Supabase/Vercel/PR, skill Cursor che guidano il delivery per fasi.

---

## #21 Allineamento documentazione

### File da aggiornare

| File | Modifica |
|------|----------|
| `AGENTS.md` | Stack post–F7: l10n IT/EN, dark mode, deep link; comandi con `flutter gen-l10n`; migration fino 009; link a `docs/AGENT-PLAYBOOK.md` |
| `README.md` | Sezione setup → punta a `scripts/dev-setup` (Fase 9); elenco migration 001–009 |
| `supabase/README.md` | Tabella migration 006–009 (`story_management`, `voting_timer`, `remove_participant`, `room_deck_settings`) |
| `docs/ROADMAP.md` | Fasi 5–7 completate; link fasi 8–10 |
| `docs/IMPROVEMENTS-NEXT.md` | Banner in cima: #11–#20 completati; link a `IMPROVEMENTS-DX.md` |
| `docs/PERFORMANCE.md` | Verifica coerenza con build Vercel (Flutter 3.35.6) |

### Contenuto minimo `AGENTS.md`

```markdown
## UI e stringhe
- Testi: `lib/l10n/app_it.arb`, `app_en.arb` → `context.l10n` (`lib/core/l10n/l10n_extensions.dart`)
- NON usare `app_strings.dart` (rimosso in Fase 8)
- Tema bar/spritz; terminologia bancone (vedi skill domain)

## Supabase
- Progetto: eyvfsgzbrdibheyejikf (eu-central-1)
- Migration: 001 … 009 in ordine
```

### Verifica

- [ ] `rg app_strings` nel repo → solo piani storici con nota “deprecato”
- [ ] `rg "solo italiano"` in `.cursor/` e `AGENTS.md` → zero (o “default IT, EN disponibile”)
- [ ] Tabella migration in `supabase/README.md` completa

---

## #22 Rimozione codice morto post-i18n

### Flutter

| Azione | Dettaglio |
|--------|-----------|
| Eliminare | `lib/core/constants/app_strings.dart` |
| Grep | `AppStrings`, `app_strings` in `lib/` → 0 match |
| Export barrel | Se `lib/core/constants/` ha solo quel file, rimuovere cartella o lasciare README inline |

### Documentazione storica

Non riscrivere tutti i piani fase 1–7. Aggiungere in ciascun file che cita `app_strings.dart` (opzionale, batch):

```markdown
> **Nota (post–Fase 7):** le stringhe UI sono in `lib/l10n/*.arb`; `app_strings.dart` rimosso in Fase 8.
```

File prioritari: `.cursor/plans/*.plan.md` solo se ancora referenziati da agent.

### Verifica

- [ ] `flutter analyze` verde
- [ ] `flutter test` verde
- [ ] Nessun import rotto in `lib/`

---

## #27 Playbook operativo agent

### Nuovo file: `docs/AGENT-PLAYBOOK.md`

Struttura obbligatoria:

1. **Prima di iniziare** — leggere `AGENTS.md`, piano fase in `docs/plans/`, branch `feat/` o `chore/`
2. **Ambiente locale** — `env.json` da `env.json.example`; `flutter gen-l10n`; FVM 3.35.6 (Fase 9)
3. **Database** — ordine migration; `supabase db push` o MCP Supabase `execute_sql` / apply migration; mai schema “a mano” senza file in `supabase/migrations/`
4. **Verifica pre-PR** — `flutter test`, `flutter analyze`, screenshot/note se UI
5. **Vercel** — Preview env `SUPABASE_URL`, `SUPABASE_ANON_KEY` su **tutti** i branch Preview; build via `scripts/vercel-build.sh` (Flutter pin)
6. **Produzione** — merge su `main` → deploy automatico; controllare deployment READY
7. **Android deep link** — `web/.well-known/assetlinks.json` SHA256 release da aggiornare
8. **Handoff** — cosa includere nel messaggio commit/PR (migration applicata sì/no, env, link preview)

### Riferimenti da non duplicare

- Deploy dettagli: `vercel.json`, `scripts/vercel-build.sh`
- Performance: `docs/PERFORMANCE.md`
- Testing: `docs/TESTING.md` (creato in Fase 10)

### Verifica

- [ ] Playbook linkato da `AGENTS.md` e README
- [ ] Checklist pre-PR copiabile in template PR (opzionale `.github/pull_request_template.md`)

---

## #28 Skill e regole Cursor

### Nuova skill: `.cursor/skills/phase-delivery/SKILL.md`

Contenuto:

- Quando usarla: nuova fase roadmap, PR multi-commit, deploy
- Workflow: branch → piano → implementazione → migration → test → PR → verifica Vercel
- Branch naming: `feat/`, `chore/`, `fix/`
- Non committare senza richiesta esplicita utente

### Aggiornare: `.cursor/skills/spritz-planning-domain/SKILL.md`

| Sezione | Modifica |
|---------|----------|
| UI copy | IT default, EN opzionale; glossario → ARB + esempi `context.l10n` |
| Riferimenti | Rimuovere `app_strings.dart`; puntare `lib/l10n/app_it.arb` |
| Deck | Preset + custom per locale (Fase 7) |

### Aggiornare: `.cursor/rules/spritz-theme.mdc`

```markdown
## Copy UI
- Lingue: IT (default), EN — `context.l10n`, file ARB
- Terminologia bar (no Scrum in UI)
- Esempio: Text(context.l10n.startVoting)
```

### Opzionale: `.cursor/rules/l10n.mdc`

```yaml
globs: lib/**/*.dart
description: Usare flutter gen-l10n, mai stringhe hardcoded in UI
```

### Aggiornare skill esistente: `.cursor/skills/supabase-migrations/SKILL.md`

- Elenco file 001–009 con una riga di scopo ciascuno
- Progetto ID e regione

### Verifica

- [ ] Skill `phase-delivery` referenziata in `AGENTS.md`
- [ ] Regola theme non menziona `AppStrings`

---

## Criteri di done — Fase 8

- [x] `AGENTS.md` e playbook coerenti con repo attuale
- [x] `app_strings.dart` rimosso, analyze/test verdi
- [x] `supabase/README.md` con migration 001–009
- [x] Skill domain + regole Cursor aggiornate
- [ ] PR `chore/agent-docs-dx` mergiata

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Agent continuano a citare vecchi piani | Banner in `IMPROVEMENTS-NEXT.md` + grep periodico |
| Rimozione `app_strings` rompe import nascosti | `flutter analyze` + test prima del merge |
| Playbook diventa obsoleto | Sezione “ultimo aggiornamento” con data in cima al file |

## Ordine interno consigliato

1. #21 Aggiornare `AGENTS.md` + `supabase/README.md` (base per tutto)
2. #22 Rimuovere `app_strings.dart`
3. #28 Skill e regole Cursor
4. #27 Scrivere `AGENT-PLAYBOOK.md` (incorpora le decisioni delle fasi 8–10)
