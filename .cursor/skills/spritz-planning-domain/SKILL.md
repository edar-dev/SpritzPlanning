---
name: spritz-planning-domain
description: Domain knowledge for SpritzPlanning — Scrum poker with spritz/bar theme, room flows, barman rules, Italian UI copy. Use when implementing features, UX, voting logic, or spritz terminology.
---

# SpritzPlanning Domain

## Scopo

App Scrum poker per team dev. Stanze senza login, accesso via codice + nickname.

## Flusso

1. **Apri locale** → creatore diventa Barman
2. **Entra al bancone** → codice + nickname
3. Barman aggiunge **ordini** al menu
4. Barman **serve l'ordine** → votazione attiva
5. Clienti scelgono **dose** (deck Fibonacci)
6. Barman **Servizio!** → reveal voti
7. Barman conferma **stima finale** → prossimo ordine

## Deck

`0, ½, 1, 2, 3, 5, 8, 13, 21, ?, ☕`

## Regole barman

- Solo barman: add/remove ordini, start voting, reveal, reset, confirm estimate, next
- Creatore stanza = barman iniziale

## Edge cases

- Nickname min 2 char
- Voto modificabile fino al reveal
- Reset = nuovo giro stesso ordine
- Session restore via SharedPreferences

## Riferimenti

- Glossario UI: `lib/core/constants/app_strings.dart`
- Modelli: `lib/data/models/models.dart`
