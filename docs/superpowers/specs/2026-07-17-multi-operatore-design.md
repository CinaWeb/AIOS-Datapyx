# Arricchimento multi-operatore — Spec buildable

Data: 2026-07-17
Stato: approvato · piano: docs/superpowers/plans/2026-07-17-multi-operatore-implementation.md
Fonte behavior (input approvato, non riaperto): `2026-07-15-aios-learn-design.md`
§"Estensione: arricchimento multi-operatore".

## Cosa aggiunge

Più operatori (comunicazione, lead, post) arricchiscono l'AIOS senza toccare il
core curato e senza creare silos. Il canale di promozione **è `aios-learn`** con
una nuova sorgente di segnale: i contributi degli operatori. Nessun secondo
motore, nessuna validazione ad-hoc.

Delta rispetto ad oggi: `aios-learn` acquisisce una **seconda modalità**
(operatore/async) accanto a quella consulente/sincrona esistente, che resta
intatta.

| | Modalità consulente (esistente) | Modalità operatore (nuova) |
|---|---|---|
| Invocata da | challenge, debrief, datapyx, i 4 livelli | `/contribuisci` (headless, dalla dashboard) |
| Umano presente | Sì | No |
| Gate prima della scrittura | **HITL** su ogni cattura | **Contradiction-gate** |
| Non contraddittorio | conferma → append | append automatico, con attribuzione |
| Contraddittorio | conferma → append | **coda conflitti**, mai `lezioni.md` |

L'invariante "mai scrittura silenziosa" resta vero *per la modalità consulente*.
In modalità operatore la conferma è sostituita dal contradiction-gate: il
non-contraddittorio è implicitamente approvato, il contraddittorio è l'unica cosa
che aspetta un umano. Va scritto esplicitamente in `SKILL.md` per non lasciare
un'incoerenza col testo attuale.

## Concreti decisi

### 1. Comando di submit: `/contribuisci` — **plugin-level**, non per-cliente

`commands/contribuisci.md`, argument-hint `"<autore>: <contributo>"`. Invoca
`aios-learn` in modalità operatore sulla cartella corrente.

Perché plugin-level e non generato in `.claude/commands/`: i clienti esistenti lo
ottengono con l'update del plugin, senza rigenerazione né migrazione; la logica
vive in un file solo. È lo stesso pattern di `/challenge` e `/debrief`, già
plugin-level e già operanti sulla cartella del cliente.

Costo: la dashboard scopre i bottoni da `.claude/commands/*.md` e non vedrebbe un
comando plugin-level → la build-guide della dashboard lo aggiunge **esplicitamente**
all'allowlist come bottone dedicato (con campo contributo + campo autore).

### 2. Coda conflitti: `enrichment/proposals/`

Un file per conflitto → zero collisioni per costruzione.
Path: `enrichment/proposals/AAAA-MM-GG-autore-slug.md` (top-level nella cartella
cliente, sorella di `automations/`).

```markdown
---
autore: Marco
data: 2026-07-17
stato: pendente
---
# Proposta — i lead da fiera non chiudono

## Contributo
Testo del contributo, come arrivato dall'operatore.

## Regola che ne deriverebbe
→ La regola operativa che finirebbe in lezioni.md.

## Contraddice
`.claude/context/strategia.md` — "le fiere sono il canale di acquisizione
primario". Il contributo dice il contrario.
```

`stato:` passa a `promossa` o `rifiutata` alla revisione — il file **resta dov'è**
(traccia storica, niente move, niente cartella archivio). `/rivedi-proposte`
elenca solo `stato: pendente`.

### 3. Revisione curatore: `/rivedi-proposte` — plugin-level

Elenca le proposte pendenti; per ciascuna il curatore sceglie **promuovi** (append
in `lezioni.md` via `aios-learn`, `stato: promossa`) / **rifiuta** (`stato:
rifiutata`, con motivo) / **modifica** (riformula, poi promuovi).

**Segnalazione in `/prime`: nessuna modifica a `prime.md`.** `prime.md` è generato
per-cliente: toccarne il template lascerebbe indietro i clienti esistenti. Ma
`prime.md` **invoca già `aios-learn`** per le prospettive, e quella logica si
risolve a runtime → la segnalazione "N proposte in attesa → `/rivedi-proposte`"
diventa una responsabilità di `aios-learn` quando è invocata da `/prime`. Zero
migrazione, funziona su tutti i clienti esistenti.

### 4. Contradiction-check: cosa confronta e come decide

Confronta il contributo contro, in quest'ordine:
1. **Core strategico** — `.claude/context/*.md` (in particolare `azienda.md`,
   `strategia.md`, `procedure.md`);
2. **Lezioni esistenti** — `.claude/context/lezioni.md` o `lezioni/`.

Contraddice se afferma il **contrario** di qualcosa di esplicito (fatto, regola,
priorità) in quei file. Non contraddice se aggiunge, precisa o copre un caso non
trattato. Giudizio LLM con criteri espliciti, come la classificazione — dettaglio
in `references/operator-mode.md`.

Nel dubbio → **coda conflitti**. Il costo di una proposta in coda è una revisione
in più; il costo di un auto-append sbagliato è il core diluito.

### 5. Dashboard: bind configurabile + attribuzione

- Bind: default **invariato** `127.0.0.1`. Opt-in esplicito via env
  `AIOS_DASHBOARD_HOST` / `AIOS_DASHBOARD_PORT` (o flag `--host`/`--port`). Aprire
  in LAN è una scelta di deployment, mai il default.
- Attribuzione: la dashboard chiede **chi sei** (campo operatore, ricordato nel
  browser) e lo passa a `/contribuisci` come `<autore>`.
- Il bottone "Contribuisci" resta nell'allowlist: il testo dell'operatore è un
  **argomento** di `claude -p`, mai concatenato in shell (`shell=False` già in
  build-guide).

### 6. Attribuzione in `lezioni.md`

Le entry promosse dagli operatori citano autore e data nell'header, sulla riga
`fonte:` già esistente:

```
## [2026-07-17] fonte: /contribuisci · autore: Marco
```

## Fuori scope (non introdurre)

- Enrichment automatico nel **core strategico** — solo strato lezioni.
- Scheduling/cron: la promozione è **sincrona al submit**.
- Meccanismo di validazione separato da `aios-learn`.
- Git branch/PR come promozione (valutata e scartata: operatori non tecnici).
- Quantificazione ore/€/ROI.
- Scelta dell'host (NAS/server/VM): il design impone solo il contratto
  storage + compute always-on e il bind configurabile.

## File coinvolti

| File | Tipo | Cosa |
|---|---|---|
| `skills/aios-learn/references/operator-mode.md` | nuovo | modalità operatore: classificazione, contradiction-check, formati, coda |
| `skills/aios-learn/SKILL.md` | mod | due modalità esplicite + responsabilità 6 (proposte in attesa) |
| `commands/contribuisci.md` | nuovo | submit operatore |
| `commands/rivedi-proposte.md` | nuovo | revisione curatore |
| `skills/aios-dashboard/SKILL.md` | mod | bind configurabile, bottone contribuisci, identità operatore |
| `skills/aios-dashboard/references/build-guide.md` | mod | idem, dettaglio implementativo |
| `README.md`, `GUIDE.md` | mod | multi-operatore documentato |
| `.claude-plugin/plugin.json` | mod | 0.5.1 → 0.6.0 |
