# SpritzPlanning — Roadmap miglioramenti



Piano di evoluzione: punti **1–9** completati (fasi 1–4); punti **11–20** completati (fasi 5–7); punti **21–30** pianificati (fasi 8–10, DX / agent / toolchain).



## Panoramica fasi



```mermaid

flowchart LR

  P1[Fase1_Sicurezza_CI]

  P2[Fase2_Affidabilita]

  P3[Fase3_Features_UX]

  P4[Fase4_Qualita_PWA]

  P5[Fase5_Produzione]

  P6[Fase6_Sessione]

  P7[Fase7_Reach]
  P8[Fase8_AgentDocs]
  P9[Fase9_Toolchain]
  P10[Fase10_Quality]

  P1 --> P2 --> P3 --> P4 --> P5 --> P6 --> P7 --> P8 --> P9
  P8 --> P10
  P9 -.-> P10

```



| Fase | Punti | Durata stimata | Branch suggerito | Documento |

|------|-------|----------------|------------------|-----------|

| 1 | #1, #9, #3 | 3–5 giorni | `feat/security-and-ci` | [phase-1-security-ci.md](plans/phase-1-security-ci.md) |

| 2 | #2 | 2–3 giorni | `feat/realtime-resilience` | [phase-2-realtime.md](plans/phase-2-realtime.md) |

| 3 | #4, #7, #8 | 4–6 giorni | `feat/lobby-voting-ux` | [phase-3-lobby-voting-ux.md](plans/phase-3-lobby-voting-ux.md) |

| 4 | #5, #6 | 4–5 giorni | `feat/e2e-and-pwa` | [phase-4-quality-pwa.md](plans/phase-4-quality-pwa.md) |

| 5 | #17, #15 | 3–5 giorni | `feat/observability-and-export` | [phase-5-production-value.md](plans/phase-5-production-value.md) |

| 6 | #13, #14, #19 | 6–9 giorni | `feat/session-ux` | [phase-6-session-ux.md](plans/phase-6-session-ux.md) |

| 7 | #11, #12, #16, #18, #20 | 10–14 giorni | `feat/reach-and-polish` | [phase-7-reach-polish.md](plans/phase-7-reach-polish.md) |
| 8 | #21, #22, #27, #28 | 2–3 giorni | `chore/agent-docs-dx` | [phase-8-agent-docs.md](plans/phase-8-agent-docs.md) |
| 9 | #23, #24, #25, #30 | 3–5 giorni | `chore/dev-toolchain` | [phase-9-dev-toolchain.md](plans/phase-9-dev-toolchain.md) |
| 10 | #26, #29 | 2–4 giorni | `chore/quality-gates` | [phase-10-quality-gates.md](plans/phase-10-quality-gates.md) |



## Lista miglioramenti v1 (#1–10)



Vedi [IMPROVEMENTS.md](IMPROVEMENTS.md).



| # | Miglioramento | Fase | Stato |

|---|-------------|------|-------|

| 1 | Sicurezza RLS e RPC | 1 | Completata |

| 2 | Realtime resiliente | 2 | Completata |

| 3 | Cleanup stanze | 1 | Completata |

| 4 | Trasferimento Barman | 3 | Completata |

| 5 | Test E2E votazione | 4 | Completata |

| 6 | PWA | 4 | Completata |

| 7 | QR codice bancone | 3 | Completata |

| 8 | Dashboard votazione | 3 | Completata |

| 9 | CI/CD GitHub Actions | 1 | Completata |

| 10 | i18n (originale) | → #11 Fase 7 | Pianificata |



## Lista miglioramenti v2 (#11–20)



Vedi [IMPROVEMENTS-NEXT.md](IMPROVEMENTS-NEXT.md).



| # | Miglioramento | Fase |

|---|-------------|------|

| 11 | Internazionalizzazione (EN) | 7 |

| 12 | Dark mode | 7 |

| 13 | Menu avanzato (edit, riordino) | 6 |

| 14 | Timer votazione + alert | 6 |

| 15 | Export / report stime | 5 |

| 16 | Deep link Android | 7 |

| 17 | Sentry + errori UI | 5 |

| 18 | Performance / Lighthouse | 7 |

| 19 | Kick cliente / AFK | 6 |

| 20 | Deck personalizzabile | 7 |



## Ordine di esecuzione



**Completate:** fasi 1–4 (sicurezza → realtime → UX lobby → qualità/PWA).



**Prossime (v3 — DX / agent / toolchain):**



8. **Fase 8** — documentazione e contesto agent allineati ([IMPROVEMENTS-DX.md](IMPROVEMENTS-DX.md))

9. **Fase 9** — FVM, bootstrap dev, hook, dev container

10. **Fase 10** — analyze severo + integration test documentati



## Lista miglioramenti v3 (#21–30)



Vedi [IMPROVEMENTS-DX.md](IMPROVEMENTS-DX.md).



| # | Miglioramento | Fase |
|---|-------------|------|
| 21 | Allineamento documentazione | 8 |
| 22 | Rimozione codice morto i18n | 8 |
| 23 | Pin Flutter FVM + version check | 9 |
| 24 | Bootstrap dev one-command | 9 |
| 25 | Pre-commit / pre-push | 9 |
| 26 | Analyze più severo + CI fatal | 10 |
| 27 | Agent playbook | 8 |
| 28 | Skill phase delivery + regole Cursor | 8 |
| 29 | Loop integration test | 10 |
| 30 | Dev Container | 9 |



## Stato implementazione



| Fase | Stato | PR / commit |

|------|-------|-------------|

| 1 | Completata | migrations 002–004, `.github/workflows/ci.yml` |

| 2 | Completata | `RealtimeConnectionManager`, `ConnectionBanner` |

| 3 | Completata | transfer barman, QR join, vote summary |

| 4 | Completata | integration test, PWA manifest, install banner |

| 5 | Completata | Sentry, session report export |

| 6 | Completata | menu avanzato, timer, kick (migrations 006–008) |

| 7 | Completata | PR #2 — i18n, dark, deep link, deck custom (migration 009) |

| 8 | Completata | PR #3 — `ff71c34` |

| 9 | Non iniziata | — |

| 10 | Non iniziata | — |



## Riferimenti codice



- Schema DB: [`supabase/migrations/`](../supabase/migrations/)

- Data layer: [`lib/data/`](../lib/data/)

- UI: [`lib/features/`](../lib/features/)

- Deploy: [`vercel.json`](../vercel.json), [`scripts/vercel-build.sh`](../scripts/vercel-build.sh)


