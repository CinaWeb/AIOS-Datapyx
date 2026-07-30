# aios-learn Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere ad AIOS il motore di apprendimento `aios-learn` — una skill interna che trasforma correzioni/errori in regole permanenti per il cliente (`lezioni.md`) o in feedback di processo sul prodotto (`aios-feedback-prodotto.md`), e genera prospettive proattive ad ogni `/prime`.

**Architecture:** Una nuova skill `skills/aios-learn/` contiene *tutta* la logica (classificazione, HITL, formati, split, prospettive). Le skill/comandi esistenti ricevono solo **puntatori** che dicono *quando* invocarla, mai *come*. `prime.md` (generato per cliente da `aios-context`) resta un wrapper sottile: la logica delle prospettive vive in `aios-learn` e si risolve a runtime, così i miglioramenti futuri si applicano a tutti i clienti senza rigenerare nulla.

**Tech Stack:** Markdown puro (skill + comandi del plugin Claude Code). Nessun codice eseguibile, nessuna dipendenza nuova.

## Verifica — leggi prima di iniziare

Questo repo è un **plugin di skill/comandi in markdown**, non software eseguibile. Non esiste pytest, non esiste una suite. La verifica di ogni task è di due tipi, entrambi reali:

1. **Check strutturale** (runnable): `rg`/grep per confermare che i puntatori risolvano, i file esistano, il frontmatter sia presente. Comandi esatti in ogni task.
2. **Walkthrough di scenario** (manuale): leggere il file prodotto contro uno scenario concreto ("dato il segnale X, la skill instrada a Y") e confermare che le istruzioni producano il comportamento voluto. È l'equivalente onesto di un test per un artefatto-prompt: l'unico vero test è eseguire la skill.

**Non** scrivere test pytest o harness che "parsano" i markdown — sarebbe un framework inventato che nessuno ha chiesto e che non testa il comportamento reale di un prompt.

## Global Constraints

- **Lingua:** tutti i contenuti generati in **italiano**.
- **Append-only sempre:** mai riscrivere o cancellare entry esistenti in `lezioni.md`, `aios-feedback-prodotto.md`, `log.md`, `history.md`.
- **HITL obbligatorio / niente scrittura silenziosa:** ogni cattura mostra il testo esatto + il file di destinazione e attende conferma esplicita prima di scrivere.
- **Due lane mai fuse:** dati di business del cliente → `lezioni.md` (letto da `/prime`). Feedback di processo sul prodotto AIOS → `aios-feedback-prodotto.md` (revisione manuale del maintainer, **mai** letto da `/prime`, **mai** promosso automaticamente nel codice del plugin).
- **`aios-learn` è interna:** invocata da altre skill/comandi via il tool Skill, per nome. Non ha un comando slash e non compare in `/aios-help` come azione primaria.
- **I touchpoint sono solo puntatori:** nessun file esistente duplica criteri o formati — sanno solo *quando* chiamare `aios-learn`.
- **Frontmatter data:** `lezioni.md` è un file di contesto → porta `created:`/`updated:` (convenzione `aios-context`). `aios-feedback-prodotto.md` sta fuori da `context/` → nessun frontmatter, stile `log.md` (header + append).

## File Structure

| File | Responsabilità | Task |
|---|---|---|
| `skills/aios-learn/references/capture-guide.md` | Classificazione segnale, formati file, logica di split | 1 |
| `skills/aios-learn/references/perspectives-guide.md` | Logica prospettive proattive per `/prime` | 2 |
| `skills/aios-learn/SKILL.md` | Orchestrazione + protocollo HITL + puntatori alle reference | 3 |
| `commands/challenge.md` (mod) | Touchpoint: dopo verdetto 🔴/🟡 → invoca aios-learn | 4 |
| `commands/debrief.md` (mod) | Touchpoint: contraddizione confermata → invoca aios-learn | 4 |
| `skills/datapyx/SKILL.md` (mod) | Touchpoint: correzione esplicita a diagnosi → invoca aios-learn | 4 |
| `skills/aios-context/SKILL.md` (mod) | Touchpoint frizione + template `prime.md` (prospettive + migrazione) | 5, 6 |
| `skills/aios-data/SKILL.md` (mod) | Touchpoint frizione di processo | 5 |
| `skills/aios-intel/SKILL.md` (mod) | Touchpoint frizione di processo | 5 |
| `skills/aios-automation/SKILL.md` (mod) | Touchpoint frizione di processo | 5 |
| `README.md` (mod) | Panoramica: aios-learn come motore interno, memoria, file tree | 7 |
| `GUIDE.md` (mod) | Walkthrough: "l'AIOS impara" + mappa file | 7 |

**Fuori scope di questo piano:** l'estensione arricchimento multi-operatore (promozione automatica, 3 zone, deployment host-agnostico). Poggia su `aios-learn` e va pianificata separatamente **dopo** che questo piano è completo. Vedi `docs/superpowers/specs/2026-07-15-aios-learn-design.md` §"Estensione: arricchimento multi-operatore".

---

### Task 1: Reference di cattura (`capture-guide.md`)

**Files:**
- Create: `skills/aios-learn/references/capture-guide.md`

**Interfaces:**
- Produces: il documento a cui `SKILL.md` (Task 3) punta per classificazione, formati e split. Nomi file citati: `.claude/context/lezioni.md`, `.claude/context/lezioni/`, `.claude/aios-feedback-prodotto.md`.

- [ ] **Step 1: Scrivi il file**

Crea `skills/aios-learn/references/capture-guide.md` con esattamente:

````markdown
# aios-learn — Guida alla cattura

Dettaglio di classificazione, formati e split per le responsabilità 1, 3 e 4 di
`aios-learn`. Il protocollo HITL sta in `SKILL.md` e vale sempre.

## Classificazione del segnale

Chiediti: **il segnale riguarda il business del cliente o il funzionamento di
AIOS come strumento?**

- **Lezione di business** → un fatto/pattern/regola su *questo* cliente che
  cambierà come lavori per lui in futuro. Esempi: "il cliente rifiuta setup >2
  settimane", "il churn è concentrato sul segmento retail", "le proposte vanno
  sempre validate col socio prima dell'invio". Va in `lezioni.md`.
- **Frizione di processo** → un attrito nell'uso di AIOS stesso: una domanda
  superflua, uno step confuso, un ordine illogico. Esempi: "la domanda su
  capacità del team arriva prima di parlare dei clienti attivi", "il recap di
  aios-data è troppo verboso". Va in `aios-feedback-prodotto.md`.

Nel dubbio: se la regola aiuta *il consulente a servire il cliente*, è business;
se aiuta *chi mantiene AIOS a migliorare il tool*, è processo.

## Formato — `.claude/context/lezioni.md`

Il file inizia con frontmatter (è un file di contesto, convenzione `aios-context`):

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
# Lezioni apprese — {{cliente}}

## [YYYY-MM-DD] fonte: /challenge
Il cliente rifiuta sempre proposte con setup >2 settimane, anche se il ROI è alto.
→ Non proporre roadmap lunghe senza una milestone intermedia entro 2 settimane.
```

- `created:` alla prima creazione del file; `updated:` ad ogni nuova entry.
- Ogni entry cita la **fonte** (skill o comando) per rintracciarne la provenienza.
- Corpo: il fatto/pattern, poi una riga `→` con la regola operativa che ne deriva.

## Formato — `.claude/aios-feedback-prodotto.md`

Non è un file di contesto (sta fuori da `context/`): niente frontmatter
`created:`/`updated:`, stesso stile di `log.md` — header + append-only.

```
# Feedback di prodotto AIOS — {{cliente}}
Frizioni di processo sul funzionamento di AIOS. Letto in revisione manuale dal
maintainer del plugin. Non letto da /prime, mai promosso automaticamente.

## [YYYY-MM-DD] skill: aios-data
L'utente ha segnalato che la domanda su "capacità del team" arriva troppo presto,
prima di aver parlato di clienti attivi — confuso l'ordine logico.
```

## Split di `lezioni.md` per settore

- **Default**: singolo file `.claude/context/lezioni.md`.
- **Soglia**: quando il file diventa difficile da scorrere (indicativamente
  15-20 entry), **proponi** lo split: *"lezioni.md sta crescendo — vuoi che lo
  divida per settore?"*. Mai split automatico senza conferma.
- **Alla conferma**: crea `.claude/context/lezioni/`, classifica le entry
  esistenti in file per settore. I settori sono un set **flessibile** che emerge
  dal contenuto reale (come i file di contesto in `aios-context`), non una
  tassonomia fissa — esempi tipici: `relazione-cliente.md`, `dati-numeri.md`,
  `automazioni-processi.md`, `decisioni-strategiche.md`. Ogni file di settore
  porta lo stesso frontmatter `created:`/`updated:`.
- **Da lì in poi**: ogni nuova lezione va nel file di settore giusto, o in uno
  nuovo se emerge un settore inedito.
- `prime.md` non cambia: legge tutto `.claude/context/` (quindi anche
  `lezioni/`), lo split è invisibile al comando.
````

- [ ] **Step 2: Verifica strutturale**

Run: `rg -n "lezioni\.md|aios-feedback-prodotto\.md|Split di" "skills/aios-learn/references/capture-guide.md"`
Expected: match su entrambi i formati file e sulla sezione Split.

- [ ] **Step 3: Walkthrough di scenario**

Leggi il file e verifica su due segnali:
- "Il cliente ha rifiutato la roadmap perché troppo lunga" → la guida lo classifica come **lezione di business** (aiuta a servire il cliente) → `lezioni.md`. ✅
- "La domanda sul team è arrivata troppo presto in aios-data" → **frizione di processo** → `aios-feedback-prodotto.md`. ✅
Se uno dei due non è classificabile senza ambiguità dalla guida, correggi il testo.

- [ ] **Step 4: Commit**

```bash
git add skills/aios-learn/references/capture-guide.md
git commit -m "feat(aios-learn): guida alla cattura (classificazione, formati, split)"
```

---

### Task 2: Reference delle prospettive (`perspectives-guide.md`)

**Files:**
- Create: `skills/aios-learn/references/perspectives-guide.md`

**Interfaces:**
- Produces: il documento a cui `SKILL.md` (Task 3) e `prime.md` (Task 6) puntano per la logica delle prospettive proattive.

- [ ] **Step 1: Scrivi il file**

Crea `skills/aios-learn/references/perspectives-guide.md` con esattamente:

````markdown
# aios-learn — Guida alle prospettive proattive

Responsabilità 5 di `aios-learn`. Invocata da `prime.md` **dopo** il riepilogo di
sessione. **Nessun protocollo HITL**: le prospettive sono output mostrato a
schermo, non scritture su file.

## Cosa leggere

- `.claude/context/lezioni.md` oppure `.claude/context/lezioni/` (se split)
- `.claude/context/decisioni.md` (sintesi DataPyx, se presente)
- `.claude/context/key-metrics.md` (se presente)
- riunioni recenti (`data/database.db`, tabella `meetings`, se presente)
- il focus della sessione corrente (cosa l'utente ha appena chiesto/aperto)

## Cosa produrre

2-3 osservazioni **concrete**, ognuna di uno di questi tipi:
- un **angolo nuovo** su qualcosa di già noto;
- un **rischio non ancora nominato** che emerge dai fatti;
- una **connessione** tra fatti già noti ma mai collegati esplicitamente.

Non sono anomalie nei dati né alert operativi: servono ad aiutare il consulente a
pensare fuori dagli schemi.

## Regole

- **Non forzare.** Se non emerge nulla di genuino, **ometti** del tutto la
  sezione. Meglio niente che un'osservazione ovvia o inventata.
- **Separa dai fatti.** Mostra le osservazioni sotto un'etichetta esplicita
  **"Prospettive"**, distinta dal riepilogo fattuale di `/prime`, così non si
  confondono con dati verificati.
- Frasi brevi, in italiano.
````

- [ ] **Step 2: Verifica strutturale**

Run: `rg -n "Prospettive|Non forzare|Cosa leggere" "skills/aios-learn/references/perspectives-guide.md"`
Expected: match su etichetta "Prospettive", regola "Non forzare", sezione "Cosa leggere".

- [ ] **Step 3: Walkthrough di scenario**

Verifica che la guida imponga i due vincoli-cardine della spec: (a) **omissione** se non emerge nulla di genuino; (b) **etichetta separata** dai fatti. Se manca uno dei due, correggi.

- [ ] **Step 4: Commit**

```bash
git add skills/aios-learn/references/perspectives-guide.md
git commit -m "feat(aios-learn): guida alle prospettive proattive"
```

---

### Task 3: Skill orchestratrice (`SKILL.md`)

**Files:**
- Create: `skills/aios-learn/SKILL.md`

**Interfaces:**
- Consumes: `references/capture-guide.md` (Task 1), `references/perspectives-guide.md` (Task 2) — devono già esistere perché i puntatori risolvano.
- Produces: la skill `aios-learn` invocabile per nome dal tool Skill. È il target di tutti i touchpoint dei Task 4-6.

- [ ] **Step 1: Scrivi il file**

Crea `skills/aios-learn/SKILL.md` con esattamente:

````markdown
---
name: aios-learn
description: Motore interno di apprendimento dell'AIOS. Trasforma correzioni ed errori in regole permanenti per quel cliente (lezioni.md) o in feedback di processo sul prodotto AIOS (aios-feedback-prodotto.md), e ad ogni /prime genera prospettive proattive. NON è un comando esposto all'utente: è invocata internamente da altre skill/comandi (challenge, debrief, datapyx, i livelli AIOS, prime). Usa quando un touchpoint segnala una correzione/frizione o quando /prime chiede le prospettive.
---

# AIOS — aios-learn (motore di apprendimento)

Skill **interna**, invocata da altre skill/comandi sullo stesso principio con cui
l'orchestratore `aios` invoca `aios-context`/`aios-data`/ecc. Non compare in
`/aios-help` come azione primaria e non ha un comando slash dedicato. Contiene
*tutta* la logica di apprendimento: se un criterio o un formato cambia, si edita
solo questo file — i touchpoint restano puntatori stabili.

Lavori **sulla cartella corrente** (l'AIOS del cliente).

## Due lane — non confondere mai

| Lane | Contenuto | File | Chi lo legge |
|---|---|---|---|
| **Lezione cliente** | Regola/pattern su quel business specifico | `.claude/context/lezioni.md` (o `.claude/context/lezioni/` se split) | `/prime`, ogni sessione |
| **Feedback prodotto** | Frizione di processo su AIOS stesso (domanda superflua, step confuso) | `.claude/aios-feedback-prodotto.md` | Il maintainer del plugin, in revisione manuale — **mai** letto da `/prime`, **mai** promosso automaticamente nel codice del plugin |

Dati di business restano isolati per cliente; segnali sul funzionamento di AIOS
non modificano mai automaticamente il codice del plugin.

## Responsabilità

1. **Classifica il segnale** — lezione di business (→ `lezioni.md`) o frizione di
   processo (→ `aios-feedback-prodotto.md`). Criteri e formati: leggi
   `references/capture-guide.md`.
2. **Protocollo HITL (obbligatorio)** — vedi sotto. Mai scrittura silenziosa.
3. **Scrittura append-only** — mai riscrivere o cancellare entry precedenti
   (stesso pattern di `history.md`/`log.md`).
4. **Split dinamico di `lezioni.md`** — su soglia, su conferma. Vedi
   `references/capture-guide.md`.
5. **Prospettive proattive per `/prime`** — leggi `references/perspectives-guide.md`.

## Protocollo HITL (cardine)

Vale per ogni **cattura** (responsabilità 1, 3, 4):

1. Classifica il segnale e prepara **il testo esatto** della entry + il **file di
   destinazione**.
2. Mostralo all'utente e **attendi conferma esplicita**. Non scrivere prima.
3. Alla conferma → scrivi in **append** (mai sovrascrivere).
4. Al rifiuto → scarta e **non riproporre lo stesso segnale nella sessione
   corrente**.

Nessuna eccezione: la cattura non è mai silenziosa. Le **prospettive**
(responsabilità 5) NON sono una cattura — sono output mostrato, non passano dal
protocollo HITL.

## Contesto standalone

Se manca `.claude/context/` (non sei dentro un AIOS) non c'è nulla da imparare né
un `/prime` da arricchire: non fare nulla e segnalalo a chi ti ha invocata.
````

- [ ] **Step 2: Verifica strutturale — frontmatter e puntatori risolvono**

Run: `rg -n "name: aios-learn|references/capture-guide.md|references/perspectives-guide.md" "skills/aios-learn/SKILL.md"`
Expected: 3 match. Poi conferma che i target esistano:
Run: `ls skills/aios-learn/references/capture-guide.md skills/aios-learn/references/perspectives-guide.md`
Expected: entrambi i file presenti (creati nei Task 1-2).

- [ ] **Step 3: Walkthrough di scenario**

Verifica che `SKILL.md` imponga i tre invarianti globali: (a) due lane mai fuse, (b) HITL su ogni cattura ma non sulle prospettive, (c) standalone = non fare nulla se manca `.claude/context/`. Se uno manca, correggi.

- [ ] **Step 4: Commit**

```bash
git add skills/aios-learn/SKILL.md
git commit -m "feat(aios-learn): skill orchestratrice con protocollo HITL"
```

---

### Task 4: Touchpoint di cattura (challenge, debrief, datapyx)

Tre puntatori verso `aios-learn` sui segnali di **correzione**. Nessuna logica: solo *quando* chiamare.

**Files:**
- Modify: `commands/challenge.md`
- Modify: `commands/debrief.md`
- Modify: `skills/datapyx/SKILL.md`

**Interfaces:**
- Consumes: la skill `aios-learn` (Task 3) deve esistere.

- [ ] **Step 1: Edit `commands/challenge.md`**

Inserisci una sezione di cattura dopo il verdetto, prima delle Regole.

Old string:
```
**Confidenza del verdetto** — Alta / Media / Bassa, con la ragione in mezza riga.

## Regole
```

New string:
```
**Confidenza del verdetto** — Alta / Media / Bassa, con la ragione in mezza riga.

## Cattura (dopo il verdetto)

Se il verdetto è 🔴 (o 🟡 con una lacuna netta), **invoca la skill `aios-learn`**
per valutare se catturare una lezione: il motivo per cui la tesi non ha retto è
spesso un pattern sul cliente che vale la pena ricordare. `aios-learn` decide se è
una lezione di business o una frizione di processo e chiede conferma prima di
scrivere. Non scrivere tu direttamente: passa il segnale ad `aios-learn`.

## Regole
```

- [ ] **Step 2: Edit `commands/debrief.md`**

Old string:
```
Una domanda alla volta, brevi. Sfida ciò che non torna (una decisione che
contraddice la strategia nei file → chiedi conferma prima di registrarla).
```

New string:
```
Una domanda alla volta, brevi. Sfida ciò che non torna (una decisione che
contraddice la strategia nei file → chiedi conferma prima di registrarla). Se la
contraddizione è **confermata** dall'utente, **invoca la skill `aios-learn`**: può
essere una lezione da ricordare (la strategia sta cambiando, o è emersa una regola
implicita). `aios-learn` classifica e chiede conferma prima di scrivere — non
scrivere tu direttamente in `lezioni.md`.
```

- [ ] **Step 3: Edit `skills/datapyx/SKILL.md`**

Aggiungi una regola nella sezione REGOLE. Old string (attenzione: le righe vuote contengono un singolo spazio, come nel file):
```
· Se la situazione è ancora confusa dopo la diagnosi, dillo esplicitamente
 
· Frasi brevi e precise · Usa il "tu" con il consulente
```

New string:
```
· Se la situazione è ancora confusa dopo la diagnosi, dillo esplicitamente
 
· Se il consulente **corregge esplicitamente** una diagnosi (il problema reale non era quello, un punto di leva era sbagliato), **invoca la skill `aios-learn`**: la correzione è spesso una lezione sul cliente. `aios-learn` classifica e chiede conferma prima di scrivere — non scrivere tu direttamente in `lezioni.md`.
 
· Frasi brevi e precise · Usa il "tu" con il consulente
```

- [ ] **Step 4: Verifica strutturale**

Run: `rg -n "aios-learn" commands/challenge.md commands/debrief.md skills/datapyx/SKILL.md`
Expected: almeno un match per ciascuno dei tre file.

- [ ] **Step 5: Walkthrough di scenario**

Per ciascun file, verifica che il puntatore sia **condizionato al segnale giusto** (verdetto 🔴/🟡; contraddizione confermata; correzione esplicita a diagnosi) e che deleghi la scrittura ad `aios-learn` senza scrivere direttamente. Se un touchpoint scrive da sé invece di delegare, correggi.

- [ ] **Step 6: Commit**

```bash
git add commands/challenge.md commands/debrief.md skills/datapyx/SKILL.md
git commit -m "feat(aios-learn): touchpoint di cattura su challenge, debrief, datapyx"
```

---

### Task 5: Touchpoint frizione di processo (i 4 livelli)

Un puntatore identico verso `aios-learn` per i segnali di **frizione di processo** nei quattro livelli costruttivi. Va in `aios-feedback-prodotto.md`, non in `lezioni.md`.

**Files:**
- Modify: `skills/aios-context/SKILL.md`
- Modify: `skills/aios-data/SKILL.md`
- Modify: `skills/aios-intel/SKILL.md`
- Modify: `skills/aios-automation/SKILL.md`

**Interfaces:**
- Consumes: la skill `aios-learn` (Task 3) deve esistere.

Il blocco da inserire (identico nei quattro file):
```
## Feedback di processo

Se durante questo livello l'utente segnala che **una domanda o uno step è
superfluo, confuso o sbagliato** (attrito nell'uso di AIOS, non un fatto sul suo
business), **invoca la skill `aios-learn`**: registra la frizione in
`.claude/aios-feedback-prodotto.md` per la revisione del maintainer. `aios-learn`
classifica e chiede conferma prima di scrivere — non è una lezione di business e
non va in `lezioni.md`.
```

- [ ] **Step 1: Edit `skills/aios-context/SKILL.md`**

Aggiungi il blocco in fondo al file. Old string:
```
Dì all'utente di **aprire una nuova sessione e lanciare `/prime`** per caricare
il contesto. Se ha attivato InfraOS, ricordagli il flusso: `/prime` a inizio
sessione, `/commit` a fine sessione.
```
New string:
```
Dì all'utente di **aprire una nuova sessione e lanciare `/prime`** per caricare
il contesto. Se ha attivato InfraOS, ricordagli il flusso: `/prime` a inizio
sessione, `/commit` a fine sessione.

## Feedback di processo

Se durante questo livello l'utente segnala che **una domanda o uno step è
superfluo, confuso o sbagliato** (attrito nell'uso di AIOS, non un fatto sul suo
business), **invoca la skill `aios-learn`**: registra la frizione in
`.claude/aios-feedback-prodotto.md` per la revisione del maintainer. `aios-learn`
classifica e chiede conferma prima di scrivere — non è una lezione di business e
non va in `lezioni.md`.
```

- [ ] **Step 2: Edit `skills/aios-data/SKILL.md`**

Old string:
```
Contenuti generati per aziende italiane: **in italiano**.
```
New string:
```
Contenuti generati per aziende italiane: **in italiano**.

## Feedback di processo

Se durante questo livello l'utente segnala che **una domanda o uno step è
superfluo, confuso o sbagliato** (attrito nell'uso di AIOS, non un fatto sul suo
business), **invoca la skill `aios-learn`**: registra la frizione in
`.claude/aios-feedback-prodotto.md` per la revisione del maintainer. `aios-learn`
classifica e chiede conferma prima di scrivere — non è una lezione di business e
non va in `lezioni.md`.
```

- [ ] **Step 3: Edit `skills/aios-intel/SKILL.md`**

Old string:
```
Contenuti generati per aziende italiane: **in italiano**.
```
New string:
```
Contenuti generati per aziende italiane: **in italiano**.

## Feedback di processo

Se durante questo livello l'utente segnala che **una domanda o uno step è
superfluo, confuso o sbagliato** (attrito nell'uso di AIOS, non un fatto sul suo
business), **invoca la skill `aios-learn`**: registra la frizione in
`.claude/aios-feedback-prodotto.md` per la revisione del maintainer. `aios-learn`
classifica e chiede conferma prima di scrivere — non è una lezione di business e
non va in `lezioni.md`.
```

- [ ] **Step 4: Edit `skills/aios-automation/SKILL.md`**

Old string:
```
Contenuti generati per aziende italiane: **in italiano**.
```
New string:
```
Contenuti generati per aziende italiane: **in italiano**.

## Feedback di processo

Se durante questo livello l'utente segnala che **una domanda o uno step è
superfluo, confuso o sbagliato** (attrito nell'uso di AIOS, non un fatto sul suo
business), **invoca la skill `aios-learn`**: registra la frizione in
`.claude/aios-feedback-prodotto.md` per la revisione del maintainer. `aios-learn`
classifica e chiede conferma prima di scrivere — non è una lezione di business e
non va in `lezioni.md`.
```

- [ ] **Step 5: Verifica strutturale**

Run: `rg -c "Feedback di processo" skills/aios-context/SKILL.md skills/aios-data/SKILL.md skills/aios-intel/SKILL.md skills/aios-automation/SKILL.md`
Expected: `1` per ciascuno dei quattro file (nessun doppione).

- [ ] **Step 6: Walkthrough di scenario**

Scenario: durante `aios-data` l'utente dice "questa domanda sul team è inutile qui". Verifica che ogni file instradi questo segnale ad `aios-learn` → `aios-feedback-prodotto.md`, **non** a `lezioni.md`. Se un file confonde la destinazione, correggi.

- [ ] **Step 7: Commit**

```bash
git add skills/aios-context/SKILL.md skills/aios-data/SKILL.md skills/aios-intel/SKILL.md skills/aios-automation/SKILL.md
git commit -m "feat(aios-learn): touchpoint frizione di processo sui 4 livelli"
```

---

### Task 6: Template `prime.md` — prospettive + migrazione

`prime.md` è generato da `aios-context` nella cartella di ogni cliente. Va aggiornato il **template di generazione** dentro `aios-context/SKILL.md`, non un `prime.md` statico. Il comando resta un wrapper sottile: punta ad `aios-learn`, non incorpora la logica.

**Files:**
- Modify: `skills/aios-context/SKILL.md:113-117` (descrizione di `prime.md`)

**Interfaces:**
- Consumes: la skill `aios-learn` (Task 3) e `references/perspectives-guide.md` (Task 2).

- [ ] **Step 1: Edit la descrizione di `prime.md`**

Old string:
```
**prime.md** deve leggere tutti i file in `.claude/context/` (incluso
`.claude/context/key-metrics.md` del livello Dati/DataOS, se presente) e produrre
un riepilogo sintetico di chi è l'utente, cosa fa l'azienda, priorità e numeri
chiave. Scrivi le istruzioni del comando così che restino valide anche quando i
file di contesto crescono (nuovi file di contesto, `history.md` di InfraOS…).
```

New string:
```
**prime.md** deve leggere tutti i file in `.claude/context/` (incluso
`.claude/context/key-metrics.md` del livello Dati/DataOS, se presente, e
`.claude/context/lezioni.md` o `.claude/context/lezioni/` se presenti) e produrre
un riepilogo sintetico di chi è l'utente, cosa fa l'azienda, priorità e numeri
chiave. Scrivi le istruzioni del comando così che restino valide anche quando i
file di contesto crescono (nuovi file di contesto, `history.md` di InfraOS…).

**prime.md — prospettive proattive.** Come **ultimo passo**, dopo il riepilogo, il
comando deve **invocare la skill `aios-learn`** per valutare se emergono
prospettive proattive (angoli nuovi, rischi non ancora nominati, connessioni tra
fatti noti). NON scrivere nel comando *come* si generano le prospettive: quella
logica vive in `aios-learn` (`references/perspectives-guide.md`) ed è risolta a
runtime, così un miglioramento futuro si applica a tutti i clienti senza
rigenerare `prime.md`. Il comando contiene solo il puntatore. Se `aios-learn` non
produce nulla di genuino, il passo è silenziosamente vuoto.

**Clienti esistenti (migrazione).** Un `prime.md` generato prima di questa
funzione non ha il puntatore ad `aios-learn`. In modalità *update* (§1),
segnalalo esplicitamente e proponi di rigenerare/aggiornare `prime.md` per
aggiungere il passo prospettive. Non è una modifica silenziosa.
```

- [ ] **Step 2: Verifica strutturale**

Run: `rg -n "prospettive proattive|Clienti esistenti \(migrazione\)|lezioni\.md o" skills/aios-context/SKILL.md`
Expected: match sul passo prospettive, sulla nota migrazione, e sulla lettura di `lezioni.md`.

- [ ] **Step 3: Walkthrough di scenario**

Verifica il principio-cardine della spec: il template dice al `prime.md` generato di **puntare** ad `aios-learn`, mai di incorporare la logica delle prospettive. Se il testo descrive *come* generare le prospettive dentro `prime.md`, riscrivilo come puntatore. Verifica anche che la nota migrazione sia legata alla modalità *update* del §1.

- [ ] **Step 4: Commit**

```bash
git add skills/aios-context/SKILL.md
git commit -m "feat(aios-learn): prime.md invoca aios-learn per le prospettive + nota migrazione"
```

---

### Task 7: Documentazione (README + GUIDE)

Riflette `aios-learn` nella documentazione pubblica. `aios-learn` è invisibile come comando, ma introduce due comportamenti che l'utente vede: le correzioni diventano **lezioni ricordate** e `/prime` aggiunge **prospettive proattive**. Vanno documentati.

**Files:**
- Modify: `README.md`
- Modify: `GUIDE.md`

**Interfaces:**
- Consumes: i Task 1-6 (il comportamento descritto deve esistere).

- [ ] **Step 1: README — conteggio skill**

Old string:
```
**8 skill + 4 comandi (`/challenge`, `/aios-help`, `/debrief`, `/client-brief`).** Entry point:
```
New string:
```
**9 skill + 4 comandi (`/challenge`, `/aios-help`, `/debrief`, `/client-brief`).** Entry point:
```
Nota: `8` → `9` è il delta corretto per l'aggiunta di `aios-learn`. Se al conteggio reale (`ls skills/` in Step 6) il numero risultasse già diverso, allinea a *conteggio_reale* — il punto è che `aios-learn` sia incluso.

- [ ] **Step 2: README — descrizione del motore interno**

Old string:
```
Dipendenze di brand (incluse per self-containment):
```
New string:
```
Motore interno (non esposto come comando):
- **`aios-learn`** — apprendimento dell'AIOS: trasforma correzioni ed errori in
  regole permanenti per quel cliente (`.claude/context/lezioni.md`, letto da
  `/prime`) o in feedback di processo sul prodotto
  (`.claude/aios-feedback-prodotto.md`, per il maintainer), e ad ogni `/prime`
  genera **prospettive proattive**. Invocato internamente da `challenge`,
  `debrief`, `datapyx`, dai livelli e da `/prime` — mai scrittura silenziosa
  (chiede sempre conferma).

Dipendenze di brand (incluse per self-containment):
```

- [ ] **Step 3: README — grafo dipendenze**

Old string:
```
aios ─(offre dopo il Contesto)→ datapyx   [diagnostica trasversale, ripetibile]
```
New string:
```
aios ─(offre dopo il Contesto)→ datapyx   [diagnostica trasversale, ripetibile]
challenge, debrief, datapyx, i 5 livelli, /prime ─→ aios-learn   [motore interno]
```

- [ ] **Step 4: README — Memoria persistente (due → tre meccanismi + bullet)**

Prima edit. Old string:
```
Due meccanismi trasversali, indipendenti da InfraOS/Git, tengono l'AIOS coerente
tra una sessione e l'altra:
```
New string:
```
Tre meccanismi trasversali, indipendenti da InfraOS/Git, tengono l'AIOS coerente
tra una sessione e l'altra:
```

Seconda edit (aggiunge il terzo bullet). Old string:
```
- **Frontmatter datato** — ogni file di stato/conoscenza (`.claude/context/*.md`,
  `brand/*.md`, `automations/roadmap.md`, `.claude/aios-build.md`) porta in testa
  `created:`/`updated:` in YAML, aggiornati dalla skill che lo scrive.
```
New string:
```
- **Frontmatter datato** — ogni file di stato/conoscenza (`.claude/context/*.md`,
  `brand/*.md`, `automations/roadmap.md`, `.claude/aios-build.md`) porta in testa
  `created:`/`updated:` in YAML, aggiornati dalla skill che lo scrive.
- **Apprendimento (`aios-learn`)** — le correzioni ripetute diventano regole
  permanenti in `.claude/context/lezioni.md` (lette da `/prime`); le frizioni sul
  prodotto vanno in `.claude/aios-feedback-prodotto.md` (revisione del maintainer,
  mai promosse automaticamente). Ad ogni `/prime`, `aios-learn` propone anche
  **prospettive proattive** — angoli nuovi e rischi non ancora nominati, distinti
  dai fatti. Ogni cattura chiede conferma: mai scrittura silenziosa.
```

- [ ] **Step 5: README — file tree**

Old string:
```
│   ├── aios-build.md               # stato costruzione (checklist, con created:/updated:)
│   ├── log.md                      # registro lavori trasversale (per-skill, con data)
│   ├── context/                    # azienda, personale, strategia, key-metrics,
│   │                                #   decisioni.md (DataPyx) — tutti con created:/updated:
│   └── commands/                   # /prime, /refresh-data, /catchup, /dashboard, …
```
New string:
```
│   ├── aios-build.md               # stato costruzione (checklist, con created:/updated:)
│   ├── log.md                      # registro lavori trasversale (per-skill, con data)
│   ├── aios-feedback-prodotto.md   # frizioni di processo su AIOS (per il maintainer)
│   ├── context/                    # azienda, personale, strategia, key-metrics,
│   │                                #   decisioni.md (DataPyx), lezioni.md (aios-learn) — con created:/updated:
│   └── commands/                   # /prime, /refresh-data, /catchup, /dashboard, …
```

- [ ] **Step 6: GUIDE — sottosezione "L'AIOS impara" in §5**

Old string:
```
**Non cresce all'infinito.** A ogni `/prime`, Claude controlla la voce più
vecchia: se supera i **3 mesi**, te lo segnala e chiede se vuoi archiviarla
(spostata in `.claude/log-archivio.md`, senza perderla) o eliminarla. Non lo
fa mai da solo senza chiedere.

---

## 6. Aggiornare, riprendere, più macchine
```
New string:
```
**Non cresce all'infinito.** A ogni `/prime`, Claude controlla la voce più
vecchia: se supera i **3 mesi**, te lo segnala e chiede se vuoi archiviarla
(spostata in `.claude/log-archivio.md`, senza perderla) o eliminarla. Non lo
fa mai da solo senza chiedere.

### L'AIOS impara dai tuoi feedback

Man mano che lo usi, l'AIOS **ricorda le correzioni**. Se dici a Claude che una
diagnosi era sbagliata, o che il cliente rifiuta sempre un certo tipo di proposta,
lui te lo propone come **lezione** da salvare (in `.claude/context/lezioni.md`):
tu confermi, e da quel momento `/prime` la ricarica ogni volta. Non scrive mai
niente senza chiedertelo.

In più, ad ogni `/prime`, dopo il riepilogo Claude può aggiungere qualche
**"Prospettiva"**: un angolo nuovo, un rischio che nessuno ha ancora nominato, un
collegamento tra cose che sapevi ma non avevi messo insieme. Sono spunti per
pensare, tenuti separati dai fatti — se non ha nulla di utile da dire, non li
mostra.

---

## 6. Aggiornare, riprendere, più macchine
```

- [ ] **Step 7: GUIDE — mappa file in §8**

Old string:
```
│   ├── log.md                       # registro lavori: cosa è stato fatto e quando
│   ├── context/                     # azienda, strategia, team, key-metrics,
│   │                                 #   decisioni.md (diagnosi DataPyx)…
│   └── commands/                    # /prime, /refresh-data, /catchup, /crea-fattura, /dashboard…
```
New string:
```
│   ├── log.md                       # registro lavori: cosa è stato fatto e quando
│   ├── aios-feedback-prodotto.md    # frizioni sull'uso di AIOS (per chi sviluppa il plugin)
│   ├── context/                     # azienda, strategia, team, key-metrics,
│   │                                 #   decisioni.md (diagnosi DataPyx), lezioni.md (cose imparate)…
│   └── commands/                    # /prime, /refresh-data, /catchup, /crea-fattura, /dashboard…
```

- [ ] **Step 8: Verifica strutturale**

Run: `rg -c "aios-learn" README.md && rg -c "L'AIOS impara|lezioni\.md" GUIDE.md`
Expected: README con più match di `aios-learn`; GUIDE con match su "L'AIOS impara" e `lezioni.md`.
Run: `ls skills/ | wc -l`
Expected: usa il conteggio reale per confermare/allineare il numero in Step 1.

- [ ] **Step 9: Walkthrough di scenario**

Leggi le due sezioni modificate come le leggerebbe un utente nuovo: capisce che (a) le correzioni diventano lezioni ricordate con conferma, (b) `/prime` può mostrare "Prospettive" separate dai fatti, (c) i due nuovi file esistono nella mappa. Se un concetto resta oscuro, chiarisci.

- [ ] **Step 10: Commit**

```bash
git add README.md GUIDE.md
git commit -m "docs(aios-learn): documenta apprendimento e prospettive in README e GUIDE"
```

---

### Task 8: Verifica d'integrazione + stato spec

Chiude il cerchio: conferma che tutti i puntatori risolvano e aggiorna lo stato della spec.

**Files:**
- Modify: `docs/superpowers/specs/2026-07-15-aios-learn-design.md:4` (riga Stato)

**Interfaces:**
- Consumes: tutti i task precedenti.

- [ ] **Step 1: Verifica che ogni touchpoint punti a una skill esistente**

Run: `rg -l "aios-learn" commands skills | sort`
Expected (7 file, oltre alla SKILL.md stessa): `commands/challenge.md`, `commands/debrief.md`, `skills/aios-automation/SKILL.md`, `skills/aios-context/SKILL.md`, `skills/aios-data/SKILL.md`, `skills/aios-intel/SKILL.md`, `skills/aios-learn/SKILL.md`, `skills/datapyx/SKILL.md`.

Poi conferma che il target esista:
Run: `ls skills/aios-learn/SKILL.md`
Expected: presente.

- [ ] **Step 2: Verifica assenza di scritture dirette nei touchpoint**

Run: `rg -n "scriv|append" commands/challenge.md commands/debrief.md`
Expected: ogni occorrenza è nel contesto "non scrivere tu / delega ad aios-learn", non un'istruzione a scrivere direttamente in `lezioni.md`. Se un touchpoint istruisce a scrivere da sé, torna al task relativo e correggi.

- [ ] **Step 3: Aggiorna lo stato della spec**

Old string:
```
Stato: approvato, in attesa di piano di implementazione
```
New string:
```
Stato: approvato · piano di implementazione: docs/superpowers/plans/2026-07-16-aios-learn-implementation.md
```

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/specs/2026-07-15-aios-learn-design.md
git commit -m "docs(aios-learn): collega la spec al piano di implementazione"
```

---

## Self-Review

**1. Copertura spec** (contro `2026-07-15-aios-learn-design.md`):
- Skill `aios-learn` punto d'ingresso unico → Task 3. ✅
- Classificazione segnale (2 lane) → Task 1 + Task 3. ✅
- Protocollo HITL obbligatorio → Task 3. ✅
- Scrittura append-only → Global Constraints + Task 3. ✅
- Split dinamico di `lezioni.md` → Task 1. ✅
- Prospettive proattive → Task 2 + Task 6. ✅
- Formati file (`lezioni.md`, `aios-feedback-prodotto.md`) → Task 1. ✅
- Touchpoint (challenge, debrief, datapyx, 4 livelli) → Task 4 + Task 5. ✅
- `prime.md` wrapper sottile + migrazione → Task 6. ✅
- Documentazione (README + GUIDE) allineata al nuovo comportamento → Task 7. ✅
- Fuori scope (no auto-promozione feedback prodotto, no comando manuale, no scheduling, no retention) → rispettato: nessun task li introduce. ✅
- Estensione multi-operatore → esplicitamente fuori scope di questo piano, rimandata a un piano separato. ✅

**2. Placeholder scan:** nessun "TBD/TODO/handle edge cases". Ogni step ha contenuto reale o comando esatto.

**3. Consistenza nomi:** `aios-learn`, `.claude/context/lezioni.md`, `.claude/aios-feedback-prodotto.md`, `references/capture-guide.md`, `references/perspectives-guide.md` usati identici in tutti i task.
