# Dev Container — SpritzPlanning

Flutter **3.35.6** (stesso pin di FVM, CI e Vercel).

## Uso

1. Cursor / VS Code → **Dev Containers: Reopen in Container**
2. Monta `env.json` nella root del workspace (copia da `env.json.example` sul host — il file è in `.gitignore`)
3. `postCreateCommand` esegue `scripts/dev-setup.sh` automaticamente

## Comandi

```bash
bash scripts/flutter.sh test
bash scripts/flutter.sh run -d web-server --web-port=8080 --dart-define-from-file=env.json
```

Porta **8080** è inoltrata per debug web.

## Note

- `env.json` non è nell’immagine: crearlo sul host prima di aprire il container o copiarlo dopo il mount del workspace.
- Per Supabase CLI: installare nel container se serve `supabase db push` (opzionale).
