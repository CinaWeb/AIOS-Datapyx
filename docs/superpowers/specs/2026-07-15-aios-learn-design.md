# AIOS Self-Learning & Prospettive Proattive — Design

Data: 2026-07-15
Stato: approvato · piano di implementazione: docs/superpowers/plans/2026-07-16-aios-learn-implementation.md

## Contesto e obiettivo

AIOS oggi è reattivo: costruisce e mantiene il "cervello operativo" di un
cliente (5 livelli + DataPyx), ma non impara sistematicamente dai propri errori
o correzioni, e non propone nulla di sua iniziativa — risponde solo a comando.

Ricerca nel wiki FullBrain ha individuato pattern compatibili con l'architettura
markdown/skill di AIOS (nessun training ML, solo memoria e regole persistenti):
**Self-Annealing** (BLAST Framework — ogni errore diventa regola permanente),
**Memory Consolidation Tiers** (Working→Episodic→Semantic→Procedural) e **Task
Assignment Paradigm** (agente che propone senza essere invocato).

Obiettivo di questo design: aggiungere ad AIOS un meccanismo che (A) impara
dagli errori/correzioni trasformandoli in regole permanenti per quel cliente, e
(B) ad ogni `/prime` propone prospettive fresche basate su tutto ciò che l'AIOS
sa — non per segnalare anomalie nei dati, ma per aiutare il consulente a
pensare fuori dagli schemi.

## Due lane, non confondere

| Lane | Contenuto | Dove vive | Chi lo legge |
|---|---|---|---|
| **Lezioni cliente** | Regole/pattern su quel business specifico | `.claude/context/lezioni.md` (o `.claude/context/lezioni/` se split) | `/prime` del cliente, ad ogni sessione |
| **Feedback prodotto** | Frizioni di processo su AIOS stesso (domanda superflua, step confuso) | `.claude/aios-feedback-prodotto.md` | Il maintainer del plugin, in revisione manuale periodica — **non** letto da `/prime`, **non** promosso automaticamente nel plugin |

La distinzione è intenzionale: dati di business restano isolati per cliente;
segnali sul funzionamento di AIOS come prodotto non modificano mai
automaticamente il codice del plugin (rischio troppo alto per una scrittura
silenziosa cross-cliente) — restano un log che il maintainer legge quando
lavora sul repo `aios-plugin`.

## Architettura: punto di ingresso unico

**Nuova skill `skills/aios-learn/SKILL.md`.** Non è un comando esposto
all'utente (non compare in `/aios-help` come azione primaria): è invocata
**internamente** da altre skill, sullo stesso principio con cui l'orchestratore
`aios` invoca `aios-context`/`aios-data`/ecc. Contiene *tutta* la logica —
criteri, formati, protocollo di conferma, logica di split, logica delle
prospettive. Se in futuro cambia un criterio o un formato, si edita solo
questo file: i touchpoint restano puntatori stabili.

### Responsabilità di `aios-learn`

1. **Classificazione del segnale** — capire se ciò che arriva è una lezione di
   business (→ `lezioni.md`) o una frizione di processo (→
   `aios-feedback-prodotto.md`).
2. **Protocollo HITL obbligatorio** — mostra sempre il testo esatto della
   lezione proposta + file di destinazione, attende conferma esplicita, poi
   scrive. Mai scrittura silenziosa. Se l'utente rifiuta, scarta e non richiede
   di nuovo per lo stesso segnale nella sessione corrente.
3. **Scrittura append-only** — mai riscrivere o cancellare entry precedenti
   (stesso pattern di `history.md`).
4. **Gestione dinamica di `lezioni.md`** — vedi sezione dedicata sotto.
5. **Generazione delle prospettive proattive per `/prime`** — vedi sezione
   dedicata sotto.

## Touchpoint — modifiche minime alle skill esistenti

Ogni touchpoint riceve solo un puntatore, non la logica:

| File | Segnale | Modifica |
|---|---|---|
| `commands/challenge.md` | Verdetto 🔴 | Dopo il verdetto: invoca `aios-learn` per valutare la cattura |
| `commands/debrief.md` | Contraddizione confermata nel passo "sfida ciò che non torna" (§2) | Stesso puntatore |
| `skills/datapyx/SKILL.md` | Correzione esplicita a una diagnosi | Stesso puntatore |
| `skills/aios-context/SKILL.md`, `aios-data/SKILL.md`, `aios-intel/SKILL.md`, `aios-automation/SKILL.md` | L'utente segnala che una domanda/step è superfluo, confuso o sbagliato | Invoca `aios-learn` (frizione di processo) |

Nessuno di questi file duplica criteri o formati: sanno solo *quando* chiamare.

## Formato dei file

`.claude/context/lezioni.md`:

```markdown
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
# Lezioni apprese — {{cliente}}

## [YYYY-MM-DD] fonte: /challenge
Il cliente rifiuta sempre proposte con setup >2 settimane, anche se il ROI è alto.
→ Non proporre roadmap lunghe senza una milestone intermedia entro 2 settimane.
```

`.claude/aios-feedback-prodotto.md`:

```markdown
## [YYYY-MM-DD] skill: aios-data
L'utente ha segnalato che la domanda su "capacità del team" arriva troppo presto,
prima di aver parlato di clienti attivi — confuso l'ordine logico.
```

Ogni entry cita la fonte (skill o comando) per rintracciarne la provenienza.

## Gestione dinamica di `lezioni.md` (split per settore)

- **Default**: singolo file `.claude/context/lezioni.md`.
- **Soglia di split**: quando `aios-learn` nota che il file sta diventando
  difficile da scorrere (indicativamente 15-20 entry), propone esplicitamente:
  *"lezioni.md sta crescendo — vuoi che lo divida per settore?"*. Mai split
  automatico senza conferma.
- **Alla conferma**: crea `.claude/context/lezioni/`, classifica le entry
  esistenti per settore in file separati. I settori sono un **set flessibile**
  che emerge dal contenuto reale (stesso principio dei file di contesto in
  `aios-context`), non una tassonomia fissa — esempi tipici: relazione
  cliente, dati/numeri, automazioni/processi, decisioni strategiche.
- **Da quel momento**: ogni nuova lezione viene classificata direttamente nel
  file di settore giusto, o in uno nuovo se emerge un settore inedito.
- **`prime.md` non cambia** — vedi sotto: la scoperta dei file è dinamica, lo
  split è invisibile al template.

## `prime.md` — wrapper sottile, nessuna logica embedded

`prime.md` è generato da `aios-context` dentro la cartella di ogni cliente
(non è un comando statico del plugin). Punto critico del design: **quanta
logica ci scriviamo dentro determina quanto i clienti esistenti restano
indietro**.

`prime.md` generato contiene solo:
1. Leggi tutto ciò che trovi in `.claude/context/` (inclusa `lezioni/` o
   `lezioni.md` se presenti), `key-metrics.md`, riunioni recenti.
2. Produci il riepilogo di sessione (comportamento già esistente, invariato).
3. Invoca la skill `aios-learn` per valutare se emergono prospettive proattive.

Nessuna istruzione su *come* valutare le prospettive vive nel file generato:
quella logica sta in `aios-learn`, risolta a runtime ad ogni invocazione. Un
miglioramento futuro alla logica delle prospettive si applica quindi
automaticamente a tutti i clienti, vecchi e nuovi, senza rigenerare nulla.

**Unico caso che richiede rigenerazione di `prime.md`:** se cambia l'insieme
dei *file* che `prime.md` deve leggere (es. un nuovo tipo di file di contesto
introdotto nel plugin che i clienti esistenti non hanno mai avuto motivo di
popolare) — evento raro, non legato a modifiche della logica di
apprendimento/prospettive.

### Logica delle prospettive (dentro `aios-learn`)

Dopo il riepilogo di `/prime`: legge `lezioni.md`/`lezioni/`, `decisioni.md`
(sintesi DataPyx), `key-metrics.md`, riunioni recenti, focus della sessione
corrente. Produce 2-3 osservazioni concrete (angolo nuovo, rischio non ancora
nominato, connessione tra fatti già noti) — **non forzate**: se non emerge
nulla di genuino, la sezione viene omessa. Le prospettive vengono mostrate
separate dal riepilogo fattuale, etichettate esplicitamente ("Prospettive")
per non essere confuse con fatti verificati.

## Regole di sicurezza / edge case

- **Rifiuto alla conferma** → scarta, non ripropone lo stesso segnale nella
  sessione corrente.
- **Crescita illimitata** → nessuna retention automatica per ora (a differenza
  di `log.md`, che ha già archiviazione a 3 mesi in `prime.md`); se diventa un
  problema si applica lo stesso pattern, non lo si costruisce preventivamente.
- **`aios-feedback-prodotto.md` e InfraOS** → versionato con `/commit` come
  tutto il resto in `.claude/`, nessuna eccezione: è meta-informazione sul
  tool, non dato sensibile del cliente.
- **Nessuna scrittura silenziosa** in nessun caso.

## Migrazione clienti esistenti

- Clienti con `prime.md` generato prima di questa modifica non ricevono il
  wrapper automaticamente.
- Da segnalare esplicitamente quando si riapre un AIOS esistente: serve
  rigenerare/aggiornare `prime.md` (ri-eseguendo il passo di `aios-context`
  relativo, o un aggiornamento mirato) per ottenere il puntatore ad
  `aios-learn`. Non è una modifica silenziosa.

## Estensione: arricchimento multi-operatore (design 2026-07-16)

AIOS come brain aziendale condiviso da più operatori (comunicazione, lead, post)
che devono anche **arricchirlo**, senza che tante mani rompano il core curato né
creino silos. Questa estensione **riusa il motore `aios-learn`** come canale di
promozione: non introduce un secondo meccanismo di apprendimento in parallelo.

### Tre zone di scrittura (non una sola folder)

1. **Core curato** — sola lettura per tutti, scrivibile SOLO dal curatore. È il
   pezzo fragile. Va distinto in due strati (vedi sotto): strategico vs lezioni.
2. **Zona arricchimento append-only** — output automazioni + tabelle DB. Gli
   operatori NON editano file a mano: lanciano comandi via dashboard, l'output va
   in `automations/<nome>/output/AAAA-MM-GG-autore-*.md` o come riga in
   `data/database.db`. AIOS lo fa già → un file per output col timestamp/autore =
   zero collisioni per costruzione, non tocca il core.
3. **Inbox conflitti** (`enrichment/proposals/`) — vedi promozione automatica: si
   restringe alla sola coda delle contraddizioni, non è la coda di tutto.

### Promozione automatica, contradiction-gated

La promozione dall'inbox è **`aios-learn` con una nuova sorgente di segnale** (i
contributi degli operatori, oltre a `/challenge`, `/debrief`, correzioni
datapyx). Il motore fa già classificazione + controllo contraddizioni +
append-only.

Conciliazione con la regola **HITL obbligatorio / niente scrittura silenziosa**:
l'HITL non si elimina, **si sposta** da "conferma su ogni scrittura" a "conferma
SOLO sulle contraddizioni". In multi-utenza asincrona nessuno è presente a
confermare in tempo reale, quindi:

- Contributo che **non contraddice** il core → promosso in automatico (mantiene
  il filone self-learning vivo).
- Contributo che **contraddice** → unica cosa in coda per revisione asincrona.

Il ruolo "curatore" quasi sparisce: resta solo revisore asincrono della coda
conflitti + detentore di `/commit`/rollback.

### Dove atterra l'enrichment: strato lezioni, non core strategico

Distinzione critica dentro il "core curato":

- **Core strategico** (`context/azienda.md`, `strategia.md`, `procedure.md`,
  caricato da `/prime`) = poche entità, alta coerenza → resta curatore-only/HITL.
  L'enrichment automatico NON entra qui (lo diluirebbe).
- **Strato lezioni** (`lezioni.md` → `lezioni/` per settore) = progettato per
  crescere, già dotato di split-by-sector → è QUI che atterra l'enrichment
  automatico.

`aios-learn` possiede già `lezioni.md`, la contraddizione-awareness e lo split →
estenderlo agli operatori è un delta minimo, non un sistema nuovo.

### Deployment: host-agnostico

Il design NON sceglie l'host (NAS con snapshot, server aziendale con policy,
VM...): è scelta di deployment decisa col cliente. Contratto che qualsiasi host
deve soddisfare — due ruoli, stessa macchina o separati:

- **Storage**: la cartella AIOS in un'unica copia viva, con backup/snapshot.
- **Compute**: processo sempre attivo che esegue l'engine headless e serve la
  dashboard in rete.

Due livelli di backup complementari: snapshot filesystem = disaster recovery;
git sotto `/commit` = rollback logico + attribution. Piani diversi.

**Unico requisito concreto imposto al codice:** rendere host/porta di bind della
dashboard configurabile (LAN/host), oggi hardcoded a `127.0.0.1`. Tutto il resto
è configurazione di deployment.

### Ordine di implementazione

Questa estensione poggia su `skills/aios-learn/`, che non esiste ancora.
Costruire prima `aios-learn` (motore base), poi l'estensione multi-operatore
sopra: nuova sorgente-segnale operatori + promozione automatica, poi dashboard su
LAN + bind configurabile.

## Fuori scope (per ora)

- Nessuna promozione automatica del feedback di prodotto in modifiche reali al
  plugin — resta un log per revisione manuale del maintainer.
- Nessun comando manuale `/aios-lesson` per cattura esplicita — solo
  rilevamento automatico dai segnali elencati.
- Nessuno scheduling/monitoraggio fuori sessione (cron, cloud routine) — le
  prospettive proattive vivono solo dentro `/prime`, dentro una sessione
  attiva.
- Nessuna retention/archiviazione automatica di `lezioni.md` — solo split per
  settore su richiesta, quando cresce troppo.

## File coinvolti (riepilogo implementazione)

- **Nuovo**: `skills/aios-learn/SKILL.md` (+ eventuale `references/` per
  esempi/criteri dettagliati)
- **Modificati**: `commands/challenge.md`, `commands/debrief.md`,
  `skills/datapyx/SKILL.md`, `skills/aios-context/SKILL.md` (touchpoint +
  template `prime.md`), `skills/aios-data/SKILL.md`, `skills/aios-intel/SKILL.md`,
  `skills/aios-automation/SKILL.md`
