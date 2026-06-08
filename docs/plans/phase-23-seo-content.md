# Fase 23 — Contenuti SEO e hreflang

**Punti:** #103–#105, #104, #106 (ops)  
**Branch:** `feat/seo-content`  
**Dipende da:** Fase 22 (landing, sitemap base)

## Obiettivo

Pagine marketing indicizzabili allineate al posizionamento **lean tool**, con coppie IT/EN e sitemap hreflang complete.

## Deliverable

| # | File / azione |
|---|----------------|
| 103 | `web/faq.html`, `web/faq-en.html`, `web/features-en.html` |
| 104 | `hreflang` su tutte le pagine marketing + `sitemap.xml` alternates |
| 105 | Link `<noscript>` e nav HTML su landing/FAQ |
| 106 | Checklist Search Console in [docs/SEO-OPS.md](../SEO-OPS.md) |

## Follow-up (#105–#108)

- **#105** — ✅ `web/help.html`, `web/help-en.html` + rewrite `/help`, `/en/help` (fase 25)
- **#107** — ✅ parziale: preload CSS + icona OG su landing/help
- **#108** — ✅ injection Plausible + Google verification via env Vercel

## Test plan

- [ ] `/faq`, `/en/faq`, `/en/features` rispondono 200 in preview Vercel
- [ ] `sitemap.xml` valido (validator XML)
- [ ] Rich Results Test su FAQ (FAQPage JSON-LD)
- [ ] Nav e footer coerenti IT/EN
