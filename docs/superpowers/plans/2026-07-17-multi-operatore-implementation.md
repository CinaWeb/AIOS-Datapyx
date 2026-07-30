# Arricchimento multi-operatore — Implementation Plan

**Goal:** Estendere `aios-learn` con una **modalità operatore/async** che promuove
in automatico i contributi non contraddittori nello strato lezioni e mette in coda
i contraddittori, più i due comandi (`/contribuisci`, `/rivedi-proposte`) e il bind
configurabile della dashboard.

**Architecture:** Nessun motore nuovo. `aios-learn` acquisisce una seconda
modalità; la logica sta in `references/operator-mode.md`, `SKILL.md` orchestra. I
due comandi sono **plugin-level** (come `/challenge`, `/debrief`) → nessuna
migrazione per i clienti esistenti. La segnalazione delle proposte pendenti passa
da `aios-learn` invocata da `/prime`, non dal template di `prime.md` → zero
rigenerazione.

**Tech Stack:** Markdown puro. L'unica eccezione è la build-guide della dashboard,
che descrive codice Python stdlib generato per-cliente.

## Verifica — leggi prima di iniziare

Plugin di skill/comandi in markdown: niente pytest, niente suite. Verifica =
(1) **check strutturale** con `rg`/`ls`, (2) **walkthrough di scenario** contro un
segnale concreto. Non inventare harness che parsano markdown.

## Global Constraints

- **Lingua:** italiano.
- **Append-only:** mai riscrivere/cancellare entry in `lezioni.md`,
  `aios-feedback-prodotto.md`, `log.md`.
- **La modalità consulente non cambia:** HITL su ogni cattura resta valido lì.
  Ogni testo nuovo deve dire *quale modalità* descrive.
- **Il core strategico non si tocca mai** da enrichment automatico: solo lezioni.
- **Nel dubbio sul contradiction-check → coda**, mai append.
- **Bind default `127.0.0.1`:** la LAN è opt-in esplicito, mai il default.
- **Due lane mai fuse:** business → `lezioni.md`; frizione di processo →
  `aios-feedback-prodotto.md`.

---

### Task 1: `references/operator-mode.md` (nuovo)

**Files:** Create `skills/aios-learn/references/operator-mode.md`

- [ ] **Step 1: Scrivi il file** (contenuto verbatim nella sezione "Contenuti" §1)
- [ ] **Step 2: Verifica strutturale**
  `rg -n "contraddice|enrichment/proposals|stato: pendente|Nel dubbio" skills/aios-learn/references/operator-mode.md`
  Expected: match su tutti e quattro.
- [ ] **Step 3: Walkthrough**
  - "I lead da fiera non chiudono mai" + `strategia.md` dice "fiere = canale primario" → **contraddice** → coda. ✅
  - "I lead da fiera vanno richiamati entro 48h" (non trattato) → **non contraddice** → append con attribuzione. ✅
  - "La domanda X del wizard è confusa" → frizione di processo → `aios-feedback-prodotto.md`. ✅
- [ ] **Step 4: Commit** `feat(aios-learn): modalità operatore (contradiction-gate, coda conflitti)`

### Task 2: `SKILL.md` — due modalità + responsabilità 6

**Files:** Modify `skills/aios-learn/SKILL.md`

- [ ] **Step 1:** aggiungi la tabella delle due modalità e il puntatore a
  `references/operator-mode.md`; riformula il cardine HITL come "vale per la
  modalità consulente", con il contradiction-gate come suo equivalente async.
- [ ] **Step 2:** responsabilità 6 — segnala le proposte pendenti quando invocata
  da `/prime`.
- [ ] **Step 3: Verifica** `rg -n "operator-mode|modalità consulente|modalità operatore|proposte in attesa" skills/aios-learn/SKILL.md`
- [ ] **Step 4: Walkthrough** — un lettore capisce (a) quale gate vale in quale
  modalità, (b) che la consulente non è cambiata, (c) che il contraddittorio non
  entra mai in `lezioni.md` senza umano.
- [ ] **Step 5: Commit** `feat(aios-learn): SKILL.md dichiara le due modalità`

### Task 3: `/contribuisci` + `/rivedi-proposte`

**Files:** Create `commands/contribuisci.md`, `commands/rivedi-proposte.md`

- [ ] **Step 1-2:** scrivi i due comandi (puntatori ad `aios-learn`, nessuna logica
  duplicata).
- [ ] **Step 3: Verifica** `rg -n "aios-learn" commands/contribuisci.md commands/rivedi-proposte.md`
- [ ] **Step 4: Walkthrough** — `/contribuisci Marco: i lead da fiera non chiudono`
  arriva ad `aios-learn` in modalità operatore con autore e testo separati.
- [ ] **Step 5: Commit** `feat(multi-operatore): comandi /contribuisci e /rivedi-proposte`

### Task 4: Dashboard — bind configurabile + attribuzione

**Files:** Modify `skills/aios-dashboard/SKILL.md`, `skills/aios-dashboard/references/build-guide.md`

- [ ] **Step 1:** SKILL.md — bind default `127.0.0.1`, LAN opt-in via env;
  bottone Contribuisci con campo operatore.
- [ ] **Step 2:** build-guide — dettaglio: `AIOS_DASHBOARD_HOST`/`PORT`, allowlist
  che include il comando plugin-level, testo operatore come argomento (`shell=False`).
- [ ] **Step 3: Verifica** `rg -n "AIOS_DASHBOARD_HOST|127.0.0.1|contribuisci" skills/aios-dashboard/SKILL.md skills/aios-dashboard/references/build-guide.md`
- [ ] **Step 4: Walkthrough** — senza env la dashboard resta locale come oggi; con
  env ascolta in LAN. L'operatore che clicca Contribuisci finisce attribuito.
- [ ] **Step 5: Commit** `feat(aios-dashboard): bind configurabile e contributo operatore`

### Task 5: Documentazione + bump

**Files:** Modify `README.md`, `GUIDE.md`, `.claude-plugin/plugin.json`

- [ ] **Step 1:** README — conteggio comandi, motore interno (modalità operatore),
  grafo dipendenze, file tree (`enrichment/proposals/`).
- [ ] **Step 2:** GUIDE — sezione "Più persone arricchiscono l'AIOS", mappa file.
- [ ] **Step 3:** bump `0.5.1` → `0.6.0`.
- [ ] **Step 4: Verifica** `rg -c "contribuisci" README.md GUIDE.md` + `rg -n '"version"' .claude-plugin/plugin.json`
- [ ] **Step 5: Commit** `docs(multi-operatore): documenta l'arricchimento multi-operatore + bump 0.6.0`

### Task 6: Integrazione

- [ ] `rg -l "aios-learn" commands skills | sort` → include i due comandi nuovi.
- [ ] Nessun touchpoint scrive direttamente in `lezioni.md`.
- [ ] PR con bump → merge (Cowork sincronizza solo al merge di una PR con bump).

## Self-Review

- Nuova sorgente-segnale dentro `aios-learn`, non motore nuovo → Task 1-2. ✅
- Promozione automatica contradiction-gated, HITL spostato → Task 1-2. ✅
- Atterra su lezioni, mai sul core strategico → Global Constraints + Task 1. ✅
- Coda conflitti un-file-per-conflitto → Task 1. ✅
- Comandi operatore/curatore → Task 3. ✅
- Bind configurabile + attribuzione → Task 4. ✅
- Doc + bump → Task 5. ✅
- Fuori scope (core, cron, PR-come-promozione, ROI, scelta host) → nessun task li
  introduce. ✅
