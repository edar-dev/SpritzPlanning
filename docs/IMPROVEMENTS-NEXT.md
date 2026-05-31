# Prossimi 10 miglioramenti — SpritzPlanning (v2)

Elenco successivo ai punti **1–9** già implementati ([IMPROVEMENTS.md](IMPROVEMENTS.md), [ROADMAP.md](ROADMAP.md)).  
Numerazione **11–20** per continuità con la lista originale (il vecchio #10 i18n diventa #11).

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stimata |
|---|---------------|------|------------|-------------|----------------|
| 11 | Internazionalizzazione (EN) | Feature | Media | Media | 3–4 giorni |
| 12 | Dark mode | Ottimizzazione UX | Media | Bassa–Media | 1–2 giorni |
| 13 | Gestione menu avanzata (edit, riordino) | Feature | Alta | Media | 3–4 giorni |
| 14 | Timer votazione e alert “tutti hanno votato” | Feature | Alta | Bassa–Media | 2–3 giorni |
| 15 | Export / report stime sessione | Feature | Alta | Bassa–Media | 2–3 giorni |
| 16 | Deep link Android nativo | Ottimizzazione | Media | Bassa | 1 giorno |
| 17 | Osservabilità (Sentry + errori UI) | Ottimizzazione | Alta | Bassa | 1–2 giorni |
| 18 | Performance web e Lighthouse | Ottimizzazione | Media | Media | 2–3 giorni |
| 19 | Rimozione cliente / kick AFK | Feature | Media | Media | 2 giorni |
| 20 | Deck e regole personalizzabili per locale | Feature | Media | Media–Alta | 4–5 giorni |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  15, 17
Impatto alto + sforzo medio:  13, 14
Impatto medio + sforzo basso: 16
Impatto medio + sforzo medio: 11, 12, 18, 19
Impatto medio + sforzo alto:   20
```

## Ordine suggerito (fasi 5–7)

| Fase | Punti | Focus | Piano |
|------|-------|--------|-------|
| 5 | #17, #15 | Affidabilità in produzione + valore per retro | [phase-5-production-value.md](plans/phase-5-production-value.md) |
| 6 | #13, #14, #19 | UX sessione poker più completa | [phase-6-session-ux.md](plans/phase-6-session-ux.md) |
| 7 | #11, #12, #16, #18, #20 | Reach, polish, personalizzazione | [phase-7-reach-polish.md](plans/phase-7-reach-polish.md) |

---

## Dettaglio per punto

### 11. Internazionalizzazione (EN)

**Perché:** team misti IT/EN; le stringhe sono già centralizzate in `app_strings.dart`.

**Cosa fare:**
- `flutter gen-l10n` con ARB `it` + `en`
- Migrare `AppStrings` → delegate l10n
- Selettore lingua in home (opzionale, default sistema)

**Verifica:** switch lingua senza restart; tutte le schermate tradotte.

---

### 12. Dark mode

**Perché:** uso serale / proiettore in sala riunioni.

**Cosa fare:**
- `ThemeMode` in `MaterialApp` + palette scura in `app_theme.dart`
- Persistenza preferenza (`shared_preferences`)
- Toggle in AppBar home o impostazioni minime

**Verifica:** contrasto WCAG su card votazione; nessun testo illeggibile su reveal.

---

### 13. Gestione menu avanzata (edit, riordino)

**Perché:** backlog reale cambia ordine e titoli durante la sessione.

**Cosa fare:**
- RPC `update_story`, `reorder_stories` (solo barman)
- UI: long-press ordine → modifica titolo/descrizione
- Drag-and-drop `ReorderableListView` in lobby (barman)

**Verifica:** ordine persistito; Realtime aggiorna tutti i client.

---

### 14. Timer votazione e alert “tutti hanno votato”

**Perché:** sessioni lunghe; il barman non deve guardare solo la barra progresso.

**Cosa fare:**
- Timer opzionale per ordine (es. 2/5/10 min) avviato dal barman
- Snackbar / suono leggero (web) quando `allParticipantsVoted`
- Opzione auto-reveal disabilitata di default (solo notifica)

**Verifica:** timer visibile a tutti; nessun reveal automatico senza conferma barman.

---

### 15. Export / report stime sessione

**Perché:** output della planning poker va in Jira/Confluence.

**Cosa fare:**
- Schermata o sheet “Riepilogo serata” con ordini `done` + stima finale
- Export CSV e `Share` testo/Markdown
- Opzionale: copia tabella negli appunti

**Verifica:** CSV apribile in Excel; include codice locale e timestamp.

---

### 16. Deep link Android nativo

**Perché:** QR oggi apre web; su Android l’APK non intercetta `?code=`.

**Cosa fare:**
- `AndroidManifest.xml` intent-filter per `https://spritz-planning.vercel.app` e/o `spritzplanning://join`
- Parsing codice in `main.dart` / router (come home web)
- Documentazione in README

**Verifica:** scan QR → app Android con codice precompilato.

---

### 17. Osservabilità (Sentry + errori UI)

**Perché:** errori RPC/Realtime in produzione oggi solo in console.

**Cosa fare:**
- Integrazione `sentry_flutter` (DSN in env, non in repo)
- Cattura errori `RoomRepository` e banner connessione prolungato
- Widget errore user-friendly al posto di `SnackBar` con `Exception: ...`

**Verifica:** evento di test in Sentry; nessun secret nel bundle pubblico oltre DSN anon.

---

### 18. Performance web e Lighthouse

**Perché:** PWA installabile ma LCP/FCP migliorabili su mobile.

**Cosa fare:**
- Audit Lighthouse (Performance, PWA, Accessibility)
- `font-display: swap`, tree-shake icone, lazy load pannelli pesanti
- Verifica dimensione bundle post-`vercel-build.sh`
- Meta `theme-color` allineato in `index.html`

**Obiettivo:** PWA ≥ 80, Performance ≥ 70 su mobile simulato.

---

### 19. Rimozione cliente / kick AFK

**Perché:** nickname fantasma o collega uscito senza chiudere tab.

**Cosa fare:**
- RPC `remove_participant` (barman, non sé stesso, non durante voto attivo del target)
- UI: long-press cliente → “Rimuovi dal bancone”
- Affinare `heartbeat` + indicatore “assente” (> 2 min senza heartbeat)

**Verifica:** kick aggiorna lista; voti del rimosso non bloccano reveal.

---

### 20. Deck e regole personalizzabili per locale

**Perché:** team usano scale diverse (T-shirt, potenze di 2, solo 1–13).

**Cosa fare:**
- Tabella `room_settings` o colonne su `rooms`: `deck_values JSON`, `allow_coffee_break`
- Validazione `cast_vote` allineata al deck della stanza
- UI barman: preset deck (Fibonacci, T-shirt, custom)

**Verifica:** join + voto con deck custom; reject valori fuori deck.

---

## Esplicitamente fuori scope (per ora)

| Idea | Motivo |
|------|--------|
| Offline completo / coda voti | Complessità sync conflitti |
| Push notification cross-platform | Richiede FCM + permessi + backend |
| Login / account utente | Contrario al MVP anonimo |
| Video / audio in stanza | Non core poker |
| AI stima automatica | Nice-to-have distante |

---

## Riferimenti

- Completati: [ROADMAP.md](ROADMAP.md) fasi 1–4  
- Piani v2: [phase-5](plans/phase-5-production-value.md) · [phase-6](plans/phase-6-session-ux.md) · [phase-7](plans/phase-7-reach-polish.md)  
- Lista originale: [IMPROVEMENTS.md](IMPROVEMENTS.md)  
- Deploy: [README.md](../README.md)
