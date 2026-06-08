---
name: spritz-planning-domain
description: Domain knowledge for SpritzPlanning — Scrum poker with spritz/bar theme, room flows, barman rules, IT/EN UI via l10n. Use when implementing features, UX, voting logic, or spritz terminology.
---

# SpritzPlanning Domain

## Scopo

App Scrum poker leggera per team dev. Nessun login in UI — accesso via codice + nickname.

## Flusso

1. **Apri locale** → creatore diventa Barman
2. **Entra al bancone** → codice + nickname (deep link Android: `https://spritz-planning.vercel.app/join?code=…`)
3. Barman aggiunge **ordini** al menu (edit/riordino — Fase 6)
4. Barman **serve l'ordine** → votazione attiva (timer opzionale)
5. Clienti scelgono **dose** (deck della stanza)
6. Barman **Servizio!** → reveal voti
7. Barman conferma **stima finale** → prossimo ordine

## Deck

Default Fibonacci: `0, ½, 1, 2, 3, 5, 8, 13, 21, ?, ☕`

Per locale (migration 009): preset o valori custom via `DeckValues.forRoom(room)` — validati in RPC `set_room_deck` / `cast_vote`.

## Regole barman

- Solo barman: add/edit/remove ordini, start voting, reveal, reset, confirm estimate, next, transfer barman, kick cliente
- Creatore stanza = barman iniziale

## UI copy

- Lingue: **IT** (default), **EN** — `context.l10n`, file `lib/l10n/app_it.arb` / `app_en.arb`
- Terminologia **bar** in UI (no "story", "sprint", "poker" visibili)
- Tema spritz + dark mode

## Edge cases

- Nickname min 2 char
- Voto modificabile fino al reveal; valore deve essere nel deck della stanza
- Reset = nuovo giro stesso ordine
- Session restore via SharedPreferences

## Riferimenti

- Stringhe UI: `lib/l10n/app_it.arb`
- Modelli: `lib/data/models/models.dart`
- Delivery: `.cursor/skills/phase-delivery/SKILL.md`
