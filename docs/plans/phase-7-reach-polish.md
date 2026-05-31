# Fase 7 — Reach, polish e personalizzazione

**Punti:** #11 i18n · #12 Dark mode · #16 Deep link Android · #18 Lighthouse · #20 Deck custom  
**Branch suggerito:** `feat/reach-and-polish`  
**Durata stimata:** 10–14 giorni  
**Dipende da:** [Fase 5](phase-5-production-value.md) (errori UI), [Fase 6](phase-6-session-ux.md) (menu/timer)

## Obiettivo

Allargare audience (EN, Android link), migliorare percezione qualità (dark, performance), adattare il deck al team.

---

## #11 Internazionalizzazione (EN)

### Setup

```yaml
# pubspec.yaml
flutter:
  generate: true
```

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_it.arb
output-localization-file: app_localizations.dart
```

File: `lib/l10n/app_it.arb`, `lib/l10n/app_en.arb` — migrare tutte le stringhe da `app_strings.dart`.

### Flutter

| File | Modifica |
|------|----------|
| `app.dart` | `localizationsDelegates`, `supportedLocales: [it, en]` |
| `app_strings.dart` | Deprecare → thin wrapper o rimuovere gradualmente |
| `home_screen.dart` | Dropdown lingua (persist `Locale` in SharedPreferences) |

### Verifica

- [ ] Switch IT/EN senza restart app
- [ ] Plurali e placeholder (`confermaPassaBancone`) in ARB
- [ ] CI: `flutter gen-l10n` + analyze

---

## #12 Dark mode

### Flutter

| File | Modifica |
|------|----------|
| `app_colors.dart` | Token dark (surface, text, border) |
| `app_theme.dart` | `ThemeData darkTheme` |
| `app.dart` | `themeMode` da provider |
| `lib/core/theme/theme_mode_provider.dart` | Riverpod + SharedPreferences |
| Home / AppBar | Toggle icona luna/sole |

### Verifica

- [ ] Contrasto card votazione e banner connessione
- [ ] QR sheet e report export leggibili
- [ ] Preferenza persistita

---

## #16 Deep link Android nativo

### Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https"
        android:host="spritz-planning.vercel.app"
        android:pathPrefix="/" />
</intent-filter>
```

Opzionale scheme custom: `spritzplanning://join?code=SPRT-XXXX`

### Flutter

| File | Modifica |
|------|----------|
| `app_links` (già in transitive) o `uni_links` | Listen initial + stream URI |
| `router.dart` / `home_screen.dart` | Stesso parsing `?code=` della web |

### Verifica

- [ ] `adb shell am start -a android.intent.action.VIEW -d "https://spritz-planning.vercel.app/?code=SPRT-TEST"`
- [ ] QR da `RoomCodeDisplay` apre APK se installato

---

## #18 Performance web e Lighthouse

### Audit baseline

```bash
flutter build web --release --dart-define-from-file=env.json
npx lighthouse https://spritz-planning.vercel.app --view
```

### Interventi tipici

| Area | Azione |
|------|--------|
| `web/index.html` | `theme-color`, preconnect Supabase |
| `app.dart` | `DeferredWidget` / split voting panel se bundle grande |
| Icone | `Icon` Material only where possible; evitare asset pesanti |
| `vercel.json` | gzip/brotli già da Vercel; cache asset hashed |
| Build | `--wasm` solo se team vuole sperimentare (non obbligatorio) |

### Documentazione

`docs/PERFORMANCE.md` — score target, comandi audit, before/after.

### Obiettivi

- [ ] PWA Lighthouse ≥ 80
- [ ] Performance mobile ≥ 70
- [ ] Accessibility ≥ 90

---

## #20 Deck e regole personalizzabili

### Migration: `supabase/migrations/009_room_deck_settings.sql`

```sql
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS deck_values JSONB
  DEFAULT '["0","½","1","2","3","5","8","13","21","?","☕"]'::jsonb;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS allow_coffee_break BOOLEAN DEFAULT true;

CREATE OR REPLACE FUNCTION set_room_deck(
  p_participant_id UUID,
  p_deck_values JSONB,
  p_allow_coffee_break BOOLEAN DEFAULT true
) RETURNS VOID ...
```

Aggiornare `cast_vote`: validare contro `rooms.deck_values` della stanza (non array hardcoded).

Preset suggeriti in app (non DB):

| Preset | Valori |
|--------|--------|
| Fibonacci (default) | 0, ½, 1, 2, 3, 5, 8, 13, 21, ?, ☕ |
| Solo numeri | 1, 2, 3, 5, 8, 13 |
| T-shirt | XS, S, M, L, XL |

### Flutter

| File | Modifica |
|------|----------|
| `models.dart` `Room` | `List<String> deckValues`, `allowCoffeeBreak` |
| `deck_values.dart` | `DeckValues.forRoom(Room room)` |
| `voting_panel.dart` | Griglia da deck room |
| Lobby barman | Sheet “Impostazioni locale” (solo pre-votazione o in lobby) |

### Verifica

- [ ] Voto rifiutato se valore non nel deck
- [ ] Nuovi join vedono deck aggiornato
- [ ] Default invariato per stanze esistenti (migration backfill)

---

## Criteri di done — Fase 7

- [ ] IT + EN completi
- [ ] Dark mode + deep link Android
- [ ] Lighthouse documentato con score target raggiunti
- [ ] Almeno 2 preset deck + custom base
- [ ] Migration 009 applicata

## Rischi

| Rischio | Mitigazione |
|---------|-------------|
| i18n refactor ampio | Migrare per feature (home → lobby → voting) |
| App Links verification Android | `assetlinks.json` su Vercel se HTTPS verified |
| Deck custom invalid JSON | RPC valida array non vuoto, max 20 valori |
| Lighthouse flaky in CI | Audit manuale documentato, non gate CI |

## Ordine interno consigliato

1. #16 Deep link (1 giorno, quick win Android)
2. #12 Dark mode
3. #18 Lighthouse (iterativo)
4. #11 i18n (parallelizzabile)
5. #20 Deck custom (ultimo — tocca DB + voting core)
