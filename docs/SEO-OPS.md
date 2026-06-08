# SEO operativo — Search Console e monitoraggio

Checklist post-deploy per la Fase 23 (#106). Eseguire su **produzione** (`https://spritz-planning.vercel.app`).

## 1. Verifica tecnica (5 min)

PowerShell:

```powershell
$urls = @(
  'https://spritz-planning.vercel.app/robots.txt',
  'https://spritz-planning.vercel.app/sitemap.xml',
  'https://spritz-planning.vercel.app/faq',
  'https://spritz-planning.vercel.app/en/faq',
  'https://spritz-planning.vercel.app/en/features',
  'https://spritz-planning.vercel.app/help',
  'https://spritz-planning.vercel.app/en/help'
)
foreach ($u in $urls) {
  (Invoke-WebRequest -Uri $u -Method Head -UseBasicParsing).StatusCode
}
```

Atteso: `200` per tutti.

Verifica sitemap (UTF-8, non UTF-16):

```powershell
curl.exe -s "https://spritz-planning.vercel.app/sitemap.xml" --output sitemap.bin
python -c "import xml.etree.ElementTree as ET; ET.parse('sitemap.bin'); print('sitemap XML OK')"
```

Atteso: `sitemap XML OK`. Se il parse fallisce, il file non è UTF-8 valido.

## 2. Variabili Vercel (opzionali)

Impostare su **Production** (e opzionalmente Preview) nel progetto Vercel:

| Variabile | Uso |
|-----------|-----|
| `GOOGLE_SITE_VERIFICATION` | Solo il **token** dal pannello Google (es. `abc123…`), non l’intero tag `<meta …>` |
| `PLAUSIBLE_DOMAIN` | Dominio Plausible, es. `spritz-planning.vercel.app` |

Iniettate in build su tutte le pagine marketing via `<!-- SEO_INJECT -->` in `scripts/vercel-build.sh`. Senza variabili, le pagine restano senza tag aggiuntivi.

## 3. Google Search Console

1. Apri [Google Search Console](https://search.google.com/search-console)
2. Proprietà: **Prefisso URL** → `https://spritz-planning.vercel.app/`
3. Verifica: copia il token in `GOOGLE_SITE_VERIFICATION` su Vercel → redeploy
4. **Sitemap** → Elimina eventuali invii falliti (⋮ → Elimina), poi aggiungi:
   `https://spritz-planning.vercel.app/sitemap.xml`
   - Se resta «Impossibile leggere/recuperare», prova `https://spritz-planning.vercel.app/sitemap.xml/` (slash finale forza un nuovo fetch)
   - La sitemap è XML semplice (hreflang resta nelle pagine HTML, non nel file XML)
5. **Ispezione URL** → Richiedi indicizzazione per `/`, `/faq`, `/features`
6. Attendi stato sitemap **Operazione riuscita** (minuti–48 h)

## 4. Bing Webmaster Tools (opzionale)

1. [Bing Webmaster](https://www.bing.com/webmasters)
2. Importa da Search Console o verifica URL
3. Invia la stessa sitemap

## 5. Rich Results

- [Rich Results Test](https://search.google.com/test/rich-results) su `/` e `/faq`
- Verificare `WebApplication`, `Organization`, `FAQPage` senza errori critici

## 6. Baseline metriche (settimana 0)

Annotare in Search Console → Prestazioni:

| Metrica | Valore iniziale | Target 3 mesi |
|---------|-----------------|---------------|
| Impressioni/giorno | — | +20% |
| Pagine indicizzate | — | `/`, `/en`, `/features`, `/en/features`, `/faq`, `/en/faq` |
| CTR medio | — | monitorare |

## 7. Manutenzione

- Dopo ogni nuova pagina marketing: aggiornare `web/sitemap.xml` e `robots.txt`
- Dopo deploy lean/SEO: richiedi **Indicizzazione URL** per home e FAQ
- Plausible: dashboard su [plausible.io](https://plausible.io) dopo aver impostato `PLAUSIBLE_DOMAIN`

## Riferimenti

- Sitemap: [`web/sitemap.xml`](../web/sitemap.xml)
- Piano Fase 23: [phase-23-seo-content.md](plans/phase-23-seo-content.md)
