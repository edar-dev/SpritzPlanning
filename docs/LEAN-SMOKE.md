# Lean smoke test — produzione

Checklist manuale post-deploy su https://spritz-planning.vercel.app (fase 24).

## Automatizzabile (CI `deploy-smoke.yml`)

| URL | Atteso |
|-----|--------|
| `/` | 200, copy «planning poker» |
| `/robots.txt`, `/sitemap.xml` | 200 |
| `/help`, `/en/help` | 200 |
| `/app/` | 200 |
| `/app/manifest.json` | 200 |
| `/icons/Icon-512.png` | 200 |

## Flusso utente (manuale, ~5 min)

1. **Home** — `/app/`: visibili «Apri locale» e «Entra al bancone» senza scroll eccessivo
2. **Crea stanza** — nickname + nome locale → entra in `/app/room/...`
3. **Ordine** — barman aggiunge story, avvia votazione
4. **Voto** — cliente sceglie carta, barman reveal + conferma stima
5. **Report** — riepilogo → copia CSV o Markdown
6. **Join** — secondo browser/incognito: stesso codice stanza, join ok
7. **Deep link** — `/j/CODICE` apre join con codice precompilato

## Metriche fase 24

| Metrica | Target |
|---------|--------|
| Time-to-first-vote | < 90 s (nuovo utente) |
| Dialog obbligatori pre-voto | 0 |
| Tap barman ciclo completo | ≤ 4 |

## Ultima verifica tecnica

**Data:** 2026-06-08  
**Esito HTTP:** tutti gli URL sopra 200 su produzione.  
**Flusso E2E stanza:** da ripetere manualmente dopo ogni change significativo su room/voting.
