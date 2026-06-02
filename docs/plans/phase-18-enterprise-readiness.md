# Fase 18 — Enterprise readiness

**Punti:** #80 Workspace + branding · #83 Sync Jira/ADO bidirezionale · #85 Audit trail · #86 Health dashboard · #88 Piano commerciale  
**Branch suggerito:** `feat/enterprise-readiness`  
**Durata stimata:** 10–14 giorni  
**Dipende da:** [Fase 17](phase-17-business-foundations.md) · [Fase 16](phase-16-session-depth.md)

Elenco riepilogativo: [IMPROVEMENTS-V9.md](../IMPROVEMENTS-V9.md).

## Obiettivo

Preparare SpritzPlanning per contesti aziendali più maturi: organizzazioni multi-team, integrazioni operative, tracciabilità, affidabilità osservabile e base per monetizzazione.

---

## Ordine di implementazione

| Sprint | Punti | Focus |
|--------|-------|--------|
| 1 | #80, #85 | Workspace/branding + audit trail |
| 2 | #83 | Sync bidirezionale Jira/ADO (MVP) |
| 3 | #86, #88 | Health dashboard + piano commerciale in-app |

**Migration SQL** (timestamp Supabase, `supabase migration new …`):

1. `workspaces_and_room_mapping` — entità workspace e relazione stanze (#80)
2. `audit_events` — log eventi principali (#85)
3. `external_sync_map` — mapping story ↔ issue esterna (#83)

Aggiornare [supabase/README.md](../../supabase/README.md) per nuove migration.

---

## #80 Workspace team con branding base

Supportare più team locali sotto un contenitore workspace:

- nome workspace
- logo opzionale
- colore brand secondario
- default deck/template

### Modifiche previste

| Area | Modifica |
|------|----------|
| `models.dart` | `Workspace` e riferimenti |
| `home_screen.dart` | selezione workspace attivo |
| `theme/` | override colore brand per workspace |

### Verifica

- [ ] Cambio workspace senza perdita sessione corrente
- [ ] Branding applicato in home/report/share

---

## #83 Integrazione Jira/ADO bidirezionale (MVP)

Estendere #74 (import) con sincronizzazione minima:

- push final estimate verso issue esterna
- pull stato issue per aggiornamenti basici
- mapping locale story-id ↔ external-id

### Implementazione proposta

- fase 1: webhook/manual sync su action esplicita
- fase 2: sincronizzazione schedulata (fuori scope)

### Verifica

- [ ] Sync idempotente su retry
- [ ] Gestione errori rete con retry/backoff
- [ ] Nessun secret nel client (solo endpoint server-side)

---

## #85 Audit trail e compliance log

Registrare eventi chiave:

- cambio ruolo
- reveal voti
- final estimate modificata
- chiusura sessione
- sync esterna eseguita

### Modifiche previste

| Area | Modifica |
|------|----------|
| `supabase/migrations/` | tabella `audit_events` + index temporali |
| `room_repository.dart` | append evento su azioni critiche |
| `session_report.dart` | sezione "Audit summary" opzionale |

### Verifica

- [ ] Eventi ordinabili per timestamp
- [ ] Nessun payload con PII non necessario

---

## #86 Health dashboard + alerting operativo

Dashboard operativa minima:

- uptime endpoint principali
- error rate RPC
- latenza media action core
- indicatore stato realtime

Alert di base:

- soglia error rate alta
- latency spike prolungato

### Verifica

- [ ] Metriche visibili in pagina operativa dedicata
- [ ] Alert testabili in ambiente preview

---

## #88 Piano commerciale in-app

Preparare il prodotto a tiering senza bloccare i flussi core:

- Free: base room/voting/report
- Pro: KPI avanzati, report executive completi
- Team: workspace multipli, audit, sync avanzato

### Verifica

- [ ] Feature flags per tier
- [ ] UX chiara su limiti e upgrade
- [ ] Nessun lock inatteso su funzionalità già disponibili

---

## Criteri di done fase

- [ ] #80, #83, #85, #86, #88 implementati e verificati
- [ ] `flutter test` + `flutter analyze --fatal-infos` verdi
- [ ] Migration applicate e documentate
- [ ] Checklist sicurezza integrazioni esterne completata
- [ ] Nessuna regressione su create/join/vote/report
