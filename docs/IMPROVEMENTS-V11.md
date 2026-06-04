# Miglioramenti v11 — Discoverability e SEO (#99–108)

Elenco successivo alla **Fase 20** ([IMPROVEMENTS-V10.md](IMPROVEMENTS-V10.md)).  
Focus: **essere trovati su Google/Bing** (landing marketing, contenuti indicizzabili, fondamenta tecniche SEO), senza sacrificare il flusso app Flutter esistente.

> **Nota:** se intendevi **SSO enterprise** (login IdP aziendale), quello resta il punto **#98** in [phase-21-enterprise-sso.md](plans/phase-21-enterprise-sso.md) — **posticipato**. Questo documento tratta **SEO** (Search Engine Optimization).

## Contesto attuale

| Oggi | Limite per i motori di ricerca |
|------|--------------------------------|
| `web/index.html` con meta base + OG | Una sola pagina “vista” dai crawler; app Flutter = client-side rendering |
| Home app = create/join stanza | Poca copy marketing, keyword limitate, nessun funnel “scoperta → prova” |
| `/help` in Flutter | Contenuto utile ma difficile da indicizzare senza HTML statico o prerender |
| `join.html` + `/j/:code` | Buon modello per link condivisi; non copre homepage e pagine prodotto |
| Lighthouse CI (Performance, A11y) | Ottimo per qualità, non sostituisce sitemap, Search Console, structured data |

**Principio:** separare **pagine marketing indicizzabili** (HTML leggero o prerender) dall’**app operativa** (Flutter), come già fatto per `join.html`.

## Tabella riepilogativa

| # | Miglioramento | Tipo | Importanza | Complessità | Durata stim. |
|---|---------------|------|------------|-------------|--------------|
| 99 | Landing page marketing (IT/EN) | Growth | Alta | Media | 3–5 giorni |
| 100 | Fondamenta SEO tecniche (`robots.txt`, `sitemap.xml`, canonical) | SEO | Alta | Bassa | 0.5–1 giorno |
| 101 | Meta e titoli per route pubbliche (home, help, join) | SEO | Alta | Media | 1–2 giorni |
| 102 | Structured data JSON-LD (`WebApplication`, `Organization`) | SEO | Media | Bassa | 0.5–1 giorno |
| 103 | Pagine contenuto statiche (funzionalità, confronto, FAQ SEO) | Content | Alta | Media | 2–4 giorni |
| 104 | `hreflang` IT/EN + URL canonici coerenti | SEO i18n | Media | Bassa | 0.5–1 giorno |
| 105 | Shell crawlable / noscript + link interni in HTML | SEO tech | Alta | Media | 1–2 giorni |
| 106 | Search Console + Bing Webmaster + metriche ricerca | Ops | Alta | Bassa | 0.5 giorno |
| 107 | Performance SEO (LCP landing, immagini OG assolute) | Performance | Media | Bassa | 1 giorno |
| 108 | Analytics privacy-friendly (Plausible / GA4 opt-in) | Growth | Media | Bassa | 0.5–1 giorno |

## Matrice impatto × sforzo

```
Impatto alto + sforzo basso:  100, 102, 106
Impatto alto + sforzo medio:  99, 101, 103, 105
Impatto medio + sforzo basso: 104, 107, 108
```

## Piano consigliato

| Fase | Punti | Focus |
|------|-------|-------|
| 22 | #99–#102, #106 | MVP indicizzazione: landing, sitemap, meta, JSON-LD, Search Console |
| 23 | #103–#105, #104, #107–#108 | Contenuti, hreflang, performance e analytics (opzionale) |

Piano di dettaglio Fase 22: [phase-22-seo-landing-discoverability.md](plans/phase-22-seo-landing-discoverability.md)

## Keyword target (bozza)

| Lingua | Intent | Esempi query |
|--------|--------|--------------|
| IT | Planning poker online | planning poker gratis, stima story agile, poker planning team |
| IT | Alternative / tool | strumento stima sprint, scrum poker online |
| EN | Same | online planning poker, scrum poker free, story pointing tool |

Copy prodotto: mantenere tema **bar/spritz** e terminologia **bancone/locale** dove possibile; evitare jargon Scrum puro in titoli H1 se non serve al ranking.

## Metriche di successo

- Proprietà verificata in Google Search Console
- `sitemap.xml` inviato senza errori
- Pagine `/` (landing) e `/features` (o equivalente) in indice entro 4–8 settimane
- Impressioni/clic organici misurabili (baseline → +20% a 3 mesi, obiettivo indicativo)
- Lighthouse Performance landing ≥ 90 (mobile), Accessibility ≥ 90

## Dipendenze

| Area | Nota |
|------|------|
| Vercel | Nuovi file statici in `web/` o `public/`; rewrite non devono rompere Flutter SPA |
| i18n | Landing IT default + EN; allineare a `app_it.arb` / `app_en.arb` per tono |
| Privacy | Cookie/analytics solo se necessario; preferire analytics senza cookie |

## Fuori scope (v11)

- Blog editoriale lungo termine (fase successiva)
- Local SEO / Google Business (prodotto SaaS globale)
- SSO enterprise (#98)
- App store ASO (Android) — trattabile in voce separata
