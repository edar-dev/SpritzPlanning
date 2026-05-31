# Miglioramenti v3 — Tech debt, dev environment, agent DX (#21–30)

Elenco successivo ai punti **11–20** ([IMPROVEMENTS-NEXT.md](IMPROVEMENTS-NEXT.md)).  
Focus: **debito tecnico documentale**, **toolchain locale riproducibile**, **flusso di sviluppo con Cursor Agent**.

Non richiedono nuove feature prodotto; preparano il repo per manutenzione a lungo termine e sessioni agent affidabili.

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stimata |
|---|---------------|------|------------|-------------|----------------|
| 21 | Allineamento documentazione “fonte di verità” | Tech debt | Alta | Bassa | 0,5–1 giorno |
| 22 | Rimozione codice morto post-i18n | Tech debt | Alta | Bassa | 2–4 ore |
| 23 | Pin Flutter (FVM) + check versione CI/Vercel | Dev env | Alta | Bassa | 0,5 giorno |
| 24 | Bootstrap dev one-command | Dev env | Alta | Bassa–Media | 1 giorno |
| 25 | Pre-commit / pre-push (l10n, format) | Dev env | Media | Bassa–Media | 0,5–1 giorno |
| 26 | `analysis_options` più severo + CI fatal | Tech debt | Media | Media | 1–2 giorni |
| 27 | Playbook operativo agent (`AGENT-PLAYBOOK.md`) | Agent DX | Alta | Media | 1 giorno |
| 28 | Skill “phase delivery” + aggiornamento regole Cursor | Agent DX | Alta | Bassa–Media | 0,5–1 giorno |
| 29 | Loop integration test documentato + script | Dev env / QA | Media | Media | 1–2 giorni |
| 30 | Dev Container + launch profile agent-safe | Dev env | Media | Media | 1–2 giorni |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  21, 22, 23, 28
Impatto alto + sforzo medio:  24, 27, 30
Impatto medio + sforzo basso: 25
Impatto medio + sforzo medio: 26, 29
```

## Ordine suggerito (fasi 8–10)

| Fase | Punti | Focus | Piano |
|------|-------|--------|-------|
| 8 | #21, #22, #27, #28 | Contesto agent aggiornato, zero riferimenti obsoleti | [phase-8-agent-docs.md](plans/phase-8-agent-docs.md) |
| 9 | #23, #24, #25, #30 | Toolchain locale identica a CI/Vercel | [phase-9-dev-toolchain.md](plans/phase-9-dev-toolchain.md) |
| 10 | #26, #29 | Gate qualità e test integrazione ripetibili | [phase-10-quality-gates.md](plans/phase-10-quality-gates.md) |

**Dipendenze:** Fase 8 prima di 9–10 (gli agent leggono doc aggiornata). Fase 9 e 10 sono parallelizzabili dopo la 8.

---

## #21 Allineamento documentazione

**Perché:** `AGENTS.md`, skill domain, regole Cursor e `supabase/README.md` descrivono ancora UI solo IT, `app_strings.dart` e migration fino alla 005.

**Deliverable:** doc allineati a post–Fase 7 (l10n IT/EN, dark mode, deep link, deck custom, migration 001–009).

---

## #22 Rimozione codice morto post-i18n

**Perché:** `lib/core/constants/app_strings.dart` non è più usato; confonde umani e agent.

**Deliverable:** file rimosso, grep pulito, piani storici con nota “completato in Fase 7”.

---

## #23 Pin Flutter (FVM) + check versione

**Perché:** CI e Vercel usano **3.35.6**; locale può divergere (es. 3.44) e generare diff su lockfile/l10n.

**Deliverable:** `.fvm/fvm_config.json`, README, script check opzionale in CI.

---

## #24 Bootstrap dev one-command

**Perché:** setup frammentato (`env.json`, `pub get`, `gen-l10n`, Supabase).

**Deliverable:** `scripts/dev-setup.ps1` (+ variante bash se utile), target documentati in README.

---

## #25 Pre-commit / pre-push

**Perché:** ARB e file generati possono divergere; formatting inconsistente.

**Deliverable:** hook (lefthook o equivalente) per `dart format` + verifica l10n.

---

## #26 Analyze più severo

**Perché:** solo `flutter_lints` base; warning non bloccano merge.

**Deliverable:** regole lint incrementali, `flutter analyze --fatal-infos` in CI quando pulito.

---

## #27 Playbook agent

**Perché:** know-how operativo (MCP Supabase/Vercel, env Preview, PR) non è centralizzato.

**Deliverable:** `docs/AGENT-PLAYBOOK.md` con checklist pre-PR e deploy.

---

## #28 Skill e regole Cursor

**Perché:** skill domain e `spritz-theme.mdc` obsoleti.

**Deliverable:** skill `phase-delivery`, regole l10n/theme aggiornate, `AGENTS.md` come indice.

---

## #29 Integration test loop

**Perché:** esiste `integration/room_flow_integration_test.dart` ma manca guida env/seed.

**Deliverable:** `docs/TESTING.md`, `env.test.json.example`, `scripts/run-integration.ps1`.

---

## #30 Dev Container

**Perché:** ambienti host diversi per agent shell e nuovi contributor.

**Deliverable:** `.devcontainer/devcontainer.json`, launch profile con messaggio chiaro se manca `env.json`.
