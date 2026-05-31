---
name: phase-delivery
description: Delivery workflow for SpritzPlanning roadmap phases — branch, plan, migrations, tests, PR, Vercel. Use when starting a new phase, multi-step feature, or production deploy verification.
---

# Phase Delivery — SpritzPlanning

## Quando usare

- Nuova voce in [docs/ROADMAP.md](../../../docs/ROADMAP.md) o piano in `docs/plans/phase-*.md`
- PR con migration Supabase, deploy Vercel, o più aree (UI + DB)
- Verifica post-merge produzione

## Workflow

1. **Leggere** [AGENTS.md](../../../AGENTS.md) + piano fase + [AGENT-PLAYBOOK.md](../../../docs/AGENT-PLAYBOOK.md)
2. **Branch** — `feat/<nome>` o `chore/<nome>` da `main` aggiornato
3. **Implementare** — seguire tabelle file nel piano; stringhe in ARB + `context.l10n`
4. **Migration** — nuovo file numerato in `supabase/migrations/`; aggiornare `supabase/README.md`
5. **Applicare DB** — `supabase db push` o MCP; annotare nel PR
6. **Verifica** — `flutter gen-l10n`, `flutter analyze`, `flutter test`
7. **PR** — checklist playbook; CI verde
8. **Deploy** — merge `main` → Vercel READY; Preview env Supabase su tutti i branch

## Branch naming

| Prefisso | Uso |
|----------|-----|
| `feat/` | Feature prodotto |
| `chore/` | Doc, toolchain, refactor senza feature |
| `fix/` | Bugfix |

## Git

- **Non** commit/push senza richiesta esplicita dell’utente
- Messaggi commit: frasi complete sul *perché*

## Checklist rapida pre-PR

```
[ ] Piano fase rispettato
[ ] ARB + gen-l10n se UI
[ ] Migration + README supabase se DB
[ ] flutter analyze + test
[ ] PR descrive migration applicata e test
```

## Riferimenti

- Playbook: `docs/AGENT-PLAYBOOK.md`
- Migrations skill: `.cursor/skills/supabase-migrations/SKILL.md`
- Domain: `.cursor/skills/spritz-planning-domain/SKILL.md`
