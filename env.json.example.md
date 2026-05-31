# env.json — configurazione locale

Copia `env.json.example` in `env.json` (già in `.gitignore`). Non committare `env.json`.

| Chiave | Obbligatoria | Dove trovarla |
|--------|--------------|---------------|
| `SUPABASE_URL` | Sì | Supabase Dashboard → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Sì | Stessa pagina → `anon` `public` key |
| `SENTRY_DSN` | No | Sentry project → DSN (solo produzione / debug errori) |

Progetto SpritzPlanning: `eyvfsgzbrdibheyejikf` — https://supabase.com/dashboard/project/eyvfsgzbrdibheyejikf

## Esempio

```json
{
  "SUPABASE_URL": "https://eyvfsgzbrdibheyejikf.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "SENTRY_DSN": ""
}
```

Run / build:

```bash
flutter run --dart-define-from-file=env.json
```

Con FVM: `fvm flutter run …` oppure `scripts/flutter.sh run …`
