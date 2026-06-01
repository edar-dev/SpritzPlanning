# Miglioramenti v5 — UI, usabilità e accessibilità

Elenco successivo alle fasi **11–12** ([IMPROVEMENTS-PROD.md](IMPROVEMENTS-PROD.md)).  
Focus: **leggibilità**, **contrasto**, **navigazione da tastiera/screen reader**, **coerenza visiva** su tutte le schermate — senza nuove feature di prodotto.

**Trigger:** feedback visivo (home EN) — tagline, label «Language», icone tema/proiettore e sottotitoli delle action tile sono difficili da leggere sul gradiente chiaro.

---

## Problemi osservati (home)

| Elemento | Problema probabile | File / nota |
|----------|-------------------|-------------|
| Tagline («Estimate user stories at the bar») | `bodyLarge` usa `textSecondary` (#78716C) — rapporto ~4.5:1 su bianco, peggiore su gradiente pesca | `home_screen.dart`, `app_theme.dart` |
| Label «Language» | `labelMedium` senza colore esplicito, su **sfondo gradiente** (non sulla card bianca) | `_HomePreferencesBar` |
| Icona tema / proiettore | `IconButton` senza `color` → `IconTheme` default, basso contrasto su #FFEDE4–#F7F5F2 | `_HomePreferencesBar` |
| Sottotitoli tile («Create a room…») | `textSecondary` + chevron a 60% opacità | `spritz_action_tile.dart` |
| Dropdown IT/EN | Stile Material default su sfondo chiaro — testo menu poco marcato | `DropdownButton` |

> Obiettivo minimo: **WCAG 2.1 livello AA** — testo normale ≥ **4.5:1**, testo grande ≥ **3:1**, componenti UI e grafica ≥ **3:1**.

---

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stim. |
|---|---------------|------|------------|-------------|--------------|
| 41 | Audit contrasto + token colore testo | A11y / design system | Alta | Media | 1–2 giorni |
| 42 | Home: barra preferenze leggibile (surface/bar) | UX / a11y | Alta | Bassa | 0.5 giorno |
| 43 | Tipografia secondaria e icone UI | UX / a11y | Alta | Bassa | 0.5–1 giorno |
| 44 | Pannello impostazioni (lingua, tema, proiettore) | UX | Media | Bassa | 1 giorno |
| 45 | Focus visibile + ordine tab (web/desktop) | A11y | Alta | Media | 1–2 giorni |
| 46 | Target touch ≥ 48×48 dp | A11y / mobile | Media | Bassa | 0.5 giorno |
| 47 | Gate Lighthouse a11y in CI (soglia documentata) | Ops / QA | Media | Media | 1 giorno |
| 48 | Percorso screen reader end-to-end | A11y | Alta | Media | 1–2 giorni |

### UI mirate (per schermata)

| ID | Miglioramento | Schermata | Priorità |
|----|---------------|-----------|----------|
| UI-I | Tagline e testi card home: colore `onSurface` / peso maggiore | Home | P0 |
| UI-J | Barra lingua/tema su `surface` con bordo (non sul gradiente nudo) | Home | P0 |
| UI-K | Chevron e icone secondarie ≥ 3:1; tooltip su tutte le icon-only | Home, Room | P0 |
| UI-L | `FocusNode` + bordo focus su `SpritzActionTile` e card voto | Home, Voting | P1 |
| UI-M | Form create/join: label sempre visibili, errori sotto il campo | Home | P1 |
| UI-N | Lobby: contrasto stati story, testo sidebar, empty state | Room | P1 |
| UI-O | Voto: stato selezionato non solo colore (bordo + icona check) | Voting | P1 |
| UI-P | Errori critici: banner oltre snackbar (config Supabase, room) | Globale | P2 |
| UI-Q | `MediaQuery.disableAnimations` su tutte le animazioni non essenziali | Globale | P2 |
| UI-R | Test widget: almeno home + tile con `textContrast` / golden | Test | P2 |
| UI-S | Modalità scura: verificare `textSecondary` su `darkSurface` | Tema | P1 |
| UI-T | Report / sheet: scroll e heading semantics per export | Report | P2 |

---

## Dettaglio per punto

### #41 — Audit contrasto + design tokens

- Mappare tutti gli usi di `textSecondary`, `onSurfaceVariant`, opacità su icone.
- Introdurre token espliciti, es. `textMuted` (solo large text / hint) vs `textSecondary` (≥ AA su surface).
- Strumenti: [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/), Lighthouse, Flutter DevTools.
- Deliverable: tabella colori in `app_colors.dart` + nota in [PERFORMANCE.md](PERFORMANCE.md).

### #42 — Home: barra preferenze

- Spostare `_HomePreferencesBar` dentro una strip `surface` (padding, `borderRadius`, ombra leggera) sopra la card.
- Colore esplicito per label e `IconTheme` (`textPrimary` / `onSurface`).
- Opzionale: nascondere label «Language» ridondante e usare solo dropdown accessibile con `Semantics(label: …)`.

### #43 — Tipografia e icone

- Tagline: `bodyLarge` con `color: textPrimary` e opzionale `fontWeight: w500`, oppure `titleSmall`.
- `SpritzActionTile` subtitle: passare a `textPrimary` con opacità 0.75 **solo se** il contrasto resta ≥ 4.5:1, altrimenti colore dedicato `#57534E`.
- Chevron: minimo `textSecondary` senza ulteriore alpha, o `iconTheme` dedicato.

### #44 — Pannello impostazioni

- Unificare lingua, tema chiaro/scuro/sistema, modalità proiettore in bottom sheet / dialog «Impostazioni» con testi chiari.
- Riduce icon-only sparse in header; migliora discoverability su mobile.

### #45 — Focus e tastiera

- `Shortcuts` già presenti per barman; estendere **Tab** su home (tile, resume, recent rooms).
- `FocusDecoration` / `OutlineInputBorder` coerente col primary su web.
- Verificare che `DropdownButton` sia raggiungibile e annunciato.

### #46 — Target touch

- `IconButton` con `constraints: BoxConstraints(minWidth: 48, minHeight: 48)`.
- Padding minimo su chip, story list trailing, card voto (già grandi in proiettore — uniformare in modalità normale).

### #47 — Lighthouse in CI

- Script `npm` o action che esegue Lighthouse su preview Vercel (o URL staging).
- Soglia iniziale: **Accessibility ≥ 90** (come da piano Fase 12); fallimento = warning, poi error.
- Documentare esclusioni (terze parti, canvas).

### #48 — Screen reader

- Home: annunciare ordine logico (titolo app → azioni principali → recenti).
- Room: heading per sezioni «Clienti», «Ordini», story corrente.
- Voting: già parziale (`Semantics` card, `liveRegion` reveal) — completare form stima finale e FAB lobby.

---

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  42, 43, UI-I, UI-J, UI-K
Impatto alto + sforzo medio:  41, 45, 48, UI-L, UI-O
Impatto medio + sforzo basso:  46, UI-M, UI-S
Impatto medio + sforzo medio: 44, 47, UI-N, UI-Q, UI-R
```

---

## Fase suggerita: 13 — UI polish & accessibility

| Ordine | Punti | Note |
|--------|-------|------|
| 1 | #41, #42, #43, UI-I–K | Fix home e token (quick win visibile) |
| 2 | UI-L, #45, #46, UI-M, UI-O | Focus, form, voting |
| 3 | #44, UI-N, UI-S | Impostazioni + room + dark |
| 4 | #47, #48, UI-P, UI-Q, UI-R | CI, audit SR, test |

**Branch suggerito:** `feat/ui-a11y-polish`  
**Piano dettagliato:** [phase-13-ui-a11y-polish.md](plans/phase-13-ui-a11y-polish.md)  
**Durata stimata:** 5–8 giorni

---

## Fuori scope (per ora)

- Redesign completo brand / illustrazioni
- Font custom (caricamento e golden)
- i18n RTL
- Alto contrasto OS (separato da dark mode)

---

## Riferimenti

- [WCAG 2.1 Contrast (Minimum)](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Material 3 — Accessibility](https://m3.material.io/foundations/accessible-design)
- Codice tema: `lib/core/theme/app_theme.dart`, `app_colors.dart`
- Widget home: `lib/features/home/home_screen.dart`, `lib/shared/widgets/spritz_action_tile.dart`
