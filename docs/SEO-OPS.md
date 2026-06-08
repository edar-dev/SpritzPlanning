# SEO operativo — Search Console e monitoraggio

Checklist post-deploy per la Fase 23 (#106). Eseguire su **produzione** (`https://spritz-planning.vercel.app`).

## 1. Verifica tecnica (5 min)

```bash
curl -sI https://spritz-planning.vercel.app/robots.txt
curl -sI https://spritz-planning.vercel.app/sitemap.xml
curl -sI https://spritz-planning.vercel.app/faq
curl -sI https://spritz-planning.vercel.app/en/features
```

Atteso: status `200` per tutti.

## 2. Google Search Console

1. Apri [Google Search Console](https://search.google.com/search-console)
2. Proprietà: **Prefisso URL** → `https://spritz-planning.vercel.app/`
3. Verifica dominio (DNS TXT su Vercel o file HTML se necessario)
4. **Sitemap** → Aggiungi: `https://spritz-planning.vercel.app/sitemap.xml`
5. Attendi stato **Success** (può richiedere 24–48 h)

## 3. Bing Webmaster Tools (opzionale)

1. [Bing Webmaster](https://www.bing.com/webmasters)
2. Importa da Search Console o verifica URL
3. Invia la stessa sitemap

## 4. Rich Results

- [Rich Results Test](https://search.google.com/test/rich-results) su `/` e `/faq`
- Verificare `WebApplication`, `Organization`, `FAQPage` senza errori critici

## 5. Baseline metriche (settimana 0)

Annotare in Search Console → Prestazioni:

| Metrica | Valore iniziale | Target 3 mesi |
|---------|-----------------|---------------|
| Impressioni/giorno | — | +20% |
| Pagine indicizzate | — | `/`, `/en`, `/features`, `/en/features`, `/faq`, `/en/faq` |
| CTR medio | — | monitorare |

## 6. Manutenzione

- Dopo ogni nuova pagina marketing: aggiornare `web/sitemap.xml` e `robots.txt`
- Dopo deploy lean/SEO: richiedi **Indicizzazione URL** per home e FAQ (Search Console → Ispezione URL)

## Riferimenti

- Sitemap: [`web/sitemap.xml`](../web/sitemap.xml)
- Piano Fase 23: [phase-23-seo-content.md](plans/phase-23-seo-content.md)
