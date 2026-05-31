# Miglioramenti possibili — priorità

Elenco dei 10 miglioramenti valutati per SpritzPlanning. Il **punto 10 (i18n)** non è incluso nella roadmap attuale.

## Tabella riepilogativa

| # | Miglioramento | Importanza | Complessità | Fase |
|---|---------------|------------|-------------|------|
| 1 | Sicurezza RLS e RPC | Alta | Media | 1 |
| 2 | Realtime resiliente | Alta | Media | 2 |
| 3 | Cleanup stanze abbandonate | Media | Bassa | 1 |
| 4 | Trasferimento Barman | Alta | Bassa–Media | 3 |
| 5 | Test E2E flusso votazione | Media | Media | 4 |
| 6 | PWA installabile | Media | Media | 4 |
| 7 | QR codice bancone | Media | Bassa | 3 |
| 8 | Dashboard stato votazione | Alta | Media | 3 |
| 9 | CI/CD GitHub Actions | Media | Bassa–Media | 1 |
| 10 | Internazionalizzazione (EN) | Bassa | Media | — |

## Dettaglio per punto

### 1. Sicurezza RLS e RPC

Restringere policy permissive, validare `participant_id` su ogni mutazione, rate limit su `create_room`. Il linter Supabase segnala RLS “always true” e RPC `SECURITY DEFINER` esposte ad `anon`.

### 2. Realtime resiliente

Banner riconnessione, retry con backoff, fallback polling, pulsante aggiorna manuale.

### 3. Cleanup stanze abbandonate

Job Supabase (pg_cron) che elimina room con `last_activity_at` > 24h.

### 4. Trasferimento Barman

RPC `transfer_facilitator` + UI “Passa il bancone” se il barman esce.

### 5. Test end-to-end votazione

Integration test: create → vote → reveal → stima finale.

### 6. PWA

Service worker, manifest, prompt installazione su web.

### 7. QR codice bancone

Generazione QR in lobby + deep link `?code=SPRT-XXXX` sulla home.

### 8. Dashboard stato votazione

Distribuzione voti, consenso suggerito, outlier, barra progresso pre-reveal per il barman.

### 9. CI/CD GitHub Actions

`flutter analyze` + `flutter test` su ogni push/PR.

### 10. i18n (non in roadmap)

`flutter gen-l10n` — rinviato.

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  3, 4, 7, 9
Impatto alto + sforzo medio:  1, 2, 8
Impatto medio + sforzo medio: 5, 6
```

Piani di implementazione: [ROADMAP.md](ROADMAP.md) (fasi 1–4 completate).

**Prossimi 10 miglioramenti (11–20):** [IMPROVEMENTS-NEXT.md](IMPROVEMENTS-NEXT.md).
