# Lean smoke test — produzione



Checklist manuale post-deploy su https://spritz-planning.vercel.app (fase 24 + aggiornamenti fasi 26–29).



## Automatizzabile (CI `deploy-smoke.yml`)



| URL | Atteso |

|-----|--------|

| `/` | 200, copy «planning poker» |

| `/robots.txt`, `/sitemap.xml` | 200 |

| `/help`, `/en/help` | 200 |

| `/app/` | 200 |

| `/app/manifest.json` | 200 |

| `/icons/Icon-512.png` | 200 |



Checklist E2E completa (passi 1–10): vedi sezione **Flusso E2E stanza** sotto.



## Flusso utente (manuale, ~5 min)



1. **Home** — `/app/`: visibili «Apri locale» e «Entra al bancone» senza scroll eccessivo

2. **Crea stanza** — nickname + nome locale → entra in `/app/room/...`

3. **Ordine** — barman aggiunge story, avvia votazione

4. **Voto** — cliente sceglie carta, barman reveal + conferma stima

5. **Report** — riepilogo → copia CSV o Markdown

6. **Join** — secondo browser/incognito: stesso codice stanza, join ok

7. **Deep link** — `/j/CODICE` apre join con codice precompilato



## Flusso E2E stanza (ripetibile, ~10 min)



Tempo massimo consigliato: **10 min**. Eseguire su Chrome desktop + incognito per il join cliente.



| # | Passo | Atteso | Max |

|---|--------|--------|-----|

| 1 | Home → **Apri locale** (nickname + nome) | Entra in `/app/room/...` | 30 s |

| 2 | Barman aggiunge **2 ordini** | Lista backlog con 2 pending | 30 s |

| 3 | **Condividi codice** (copia / QR) | Codice in clipboard o sheet | 15 s |

| 4 | Incognito → **Entra al bancone** stesso codice | Cliente in lista partecipanti | 45 s |

| 5 | Avvia votazione ordine 1 → cliente **vota** | Carta selezionata, progress bar | 60 s |

| 6 | Barman **Servizio!** → stima → **Prossimo ordine** | Ordine 1 done, ordine 2 pending/voting | 60 s |

| 7 | **Riepilogo serata** → copia report | Markdown/CSV in clipboard | 30 s |

| 8 | **Lista compatta ordini** (barman): switch ordine in votazione | Cambio ordine attivo senza crash | 30 s |

| 9 | Mobile viewport (DevTools): **sticky Servizio!** visibile in votazione | Pulsante reveal sempre raggiungibile | 30 s |

| 10 | **Chiudi serata** (Strumenti) → riepilogo 3 metriche | Card ordini/durata/clienti | 30 s |



### Registro run manuali



| Data | Esito | Note |

|------|-------|------|

| 2026-06-08 | HTTP smoke OK | E2E stanza: checklist aggiornata post Fase 29; run completa da ripetere pre-release |



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

**Esito HTTP:** tutti gli URL automatizzati 200 su produzione.  

**Flusso E2E stanza:** checklist espansa (#124); run completa registrata come pending in tabella sopra.


