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

## Notifiche browser (Fase 28 #121)

| Browser | Reveal / timer | Inizio votazione |
|---------|----------------|------------------|
| Chrome / Edge desktop | Sì (tab in background + permesso) | Sì, throttle 30 s |
| Firefox desktop | Come Chrome | Come Chrome |
| Safari macOS | Limitato; può richiedere interazione utente | Degradazione silenziosa |
| iOS (qualsiasi browser) | Non supportato (WebKit) | Non supportato |

Abilitare in **Impostazioni → Notifiche browser**; il cliente riceve «Tocca a te!» quando il barman avvia la votazione (non il barman stesso).

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
