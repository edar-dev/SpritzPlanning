# Fase 13 — UI polish e accessibilità

**Punti:** #41–48 · **UI:** UI-I–UI-T  
**Branch suggerito:** `feat/ui-a11y-polish`  
**Durata stimata:** 5–8 giorni  
**Dipende da:** Fase 12 (Semantics base, modalità proiettore)

## Obiettivo

Rendere l’app **leggibile per tutti** (contrasto AA), **navigabile da tastiera e screen reader**, con verifica **ripetibile** (Lighthouse / test).

Elenco completo: [IMPROVEMENTS-UI-A11Y.md](../IMPROVEMENTS-UI-A11Y.md).

---

## Sprint 1 — Home e design tokens (P0)

### #41 + #43 + UI-I + UI-K

- `app_colors.dart`: documentare rapporti contrasto; eventuale `textMuted` vs `textSecondary`.
- `app_theme.dart`: tagline / `bodyLarge` su home non forzato a `onSurfaceVariant` ovunque.
- `spritz_action_tile.dart`: subtitle e chevron con contrasto AA.
- `home_screen.dart`: tagline con stile dedicato leggibile.

### #42 + UI-J

- `_HomePreferencesBar`: wrapper `Material`/`DecoratedBox` surface sopra gradiente.
- `IconTheme` e testo label con `AppColors.textPrimary`.
- `Semantics` su dropdown lingua e menu tema.

**Verifica**

- [x] Tagline e barra preferenze leggibili (surface + textPrimary)
- [x] Contrast checker: textSecondary #57534E su bianco
- [ ] Screenshot prima/dopo in PR

---

## Sprint 2 — Interazione e voting (P1)

### #45 + UI-L + #46

- Focus visible su `SpritzActionTile`, `SpritzCard`, pulsanti room.
- `IconButton` minimum size 48dp dove sotto soglia.

### UI-M + UI-O

- Form home: `InputDecoration` + error text persistente.
- Card voto selezionata: bordo + `Semantics(selected: true)` + indicatore non solo colore arancione.

### UI-N

- `room_screen.dart`: stati story, testi sidebar, lista ordini.

**Verifica**

- [x] Focus ring su tile e card (`AppFocusBorder`)
- [x] Check icon su card voto selezionata (non solo colore)
- [ ] Tab attraversa home senza trap (test manuale web)
- [ ] TalkBack/VoiceOver: tile e card annunciate correttamente

---

## Sprint 3 — Impostazioni, tema, QA (P1–P2)

### #44

- [x] Sheet «Impostazioni» da icona ingranaggio (lingua, tema, proiettore).

### UI-S

- Passaggio dark: secondary text su `darkSurface`.

### #47 + UI-R

- Lighthouse su preview (workflow o doc manuale con soglia 90).
- Test widget home con localizzazioni.

### #48 + UI-P + UI-Q

- Journey SR documentato in TESTING.md.
- Animazioni ridotte oltre reveal voting.
- Banner errore persistente dove oggi solo snackbar.

---

## Criteri di done — Fase 13

- [x] Token contrasto e barra preferenze home su surface
- [x] Form home con errorText per campo
- [x] Focus visibile su tile e card voto
- [ ] Nessun testo interattivo sotto WCAG AA — verifica completa room (manuale)
- [ ] Lighthouse Accessibility ≥ 90 su URL preview (documentato)
- [ ] `flutter analyze --fatal-infos` + `flutter test` verdi

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| Estetica «più scura» del mockup originale | Mantenere gerarchia: primary bold, secondary solo per hint non critici |
| Lighthouse flaky in CI | Soglia warning prima; URL preview stabile |
| Regressione dark mode | Screenshot o test su entrambi i temi |
