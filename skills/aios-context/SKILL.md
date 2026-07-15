---
name: aios-context
description: Costruisce il livello di Contesto di un AIOS (AI Operating System) personalizzato per un'azienda, tramite intervista guidata e/o import di documenti. Genera i file di contesto, l'identità di brand (colori, tipografia, logo, stack — riusando client-project-kickoff), un CLAUDE.md su misura e il comando /prime. Opzionalmente attiva InfraOS (versionamento Git/GitHub, /commit, history.md). Usa quando l'utente vuole creare o aggiornare un AIOS/second brain aziendale, specializzare Claude su un'azienda o un cliente, o "fare l'onboarding" di Claude su un business.
argument-hint: "Nome azienda o cliente (opzionale)"
---

# AIOS — Livello 1: ContextOS + InfraOS

Trasformi Claude da assistente generico in un'AI che conosce a fondo un'azienda
specifica — sia **chi è** (contesto testuale) sia **come si presenta** (identità
di brand: colori, tipografia, logo, stack tecnico). Lavori **sulla cartella
corrente** (la working dir è la cartella dedicata a quell'azienda/cliente). Il
tuo ruolo in questa skill è quello di un **interviewer**: curioso, che scava, che
non dà mai nulla per scontato e che mette in discussione ciò che non torna.

Leggi `references/interview-guide.md` prima di iniziare l'intervista.

## Flusso

### 1. Detect — nuovo o update?
Controlla se esiste già `.claude/context/` nella working dir.
- **Esiste** → modalità *update*: leggi i file esistenti, riepiloga cosa già
  sai, e chiedi **cosa è cambiato** (nuovi numeri, nuove priorità, nuovo team).
  Non ripartire da zero: aggiorna solo ciò che serve.
- **Non esiste** → modalità *build*: costruzione da zero.

Se l'utente ha passato un argomento, usalo come nome azienda/cliente.

### 2. Input mode
Chiedi come vuole fornire il contesto (sono combinabili):
- **Intervista** — rispondi alle mie domande in chat
- **Incolla testo** — sito web, profilo LinkedIn, brief, note libere
- **Indica file** — PDF, .md, presentazioni presenti nella cartella

### 3. Estrazione (se ha fornito testo/file)
Leggi e sintetizza il materiale. Rimanda all'utente **cosa hai capito** in forma
di riepilogo e **elenca esplicitamente i buchi** che l'intervista dovrà colmare.
Per i PDF usa lo strumento Read; se `markitdown` è disponibile puoi usarlo per
formati più complessi.

### 4. Intervista
Copri le aree in `references/interview-guide.md`. Regole:
- **Una domanda alla volta.** Mai raffiche di domande.
- **Mai assunzioni.** Se qualcosa non è chiaro, chiedi.
- **Sfida le incoerenze.** Se i numeri non tornano (es. fatturato incompatibile
  coi pacchetti e col numero clienti), fermati e chiedi chiarimenti prima di
  proseguire. Un contesto sbagliato è il peggior risultato possibile.
- Preferisci domande mirate; accetta risposte approssimative e proponi tu una
  stima ragionata da far confermare.

### 5. Recap prima di scrivere
Prima di generare qualsiasi file, presenta:
- un riepilogo del contesto raccolto;
- l'**elenco dei file** che creerai in `.claude/context/` con una riga di
  descrizione ciascuno.
Ottieni conferma. Correggi se serve.

### 6. Generazione
Crea nella working dir:

```
CLAUDE.md                    # identità azienda + istruzione a leggere il contesto e usare /prime
.claude/context/*.md         # set FLESSIBILE — vedi sotto
.claude/commands/prime.md    # slash command che carica tutti i file di contesto
.claude/log.md               # registro lavori — vedi convenzione più sotto
```

**File di contesto — set flessibile.** Parti da questi quattro e aggiungi/togli
in base a cosa è realmente emerso:
- `azienda.md` — cosa fa, cosa vende, prezzi, clienti target, storia, punto di forza
- `personale.md` — ruolo dell'utente, responsabilità, come passa il tempo, background, a cosa vuole usare l'AIOS
- `strategia.md` — priorità attuali, obiettivi, strategia di crescita, visione a lungo termine
- `dati-correnti.md` — numeri chiave: fatturato, clienti attivi, conversion rate, ostacoli, capacità del team
Aggiungi es. `team.md`, `competitor.md`, `prodotti.md` **solo se** il materiale
lo giustifica. Non creare file vuoti o riempitivi.

**Convenzione data — frontmatter su ogni file di stato/conoscenza.** Ogni file
in `.claude/context/*.md` e nella cartella `brand/*.md` (top-level, sorella di
`.claude/`, creata al passo 7) inizia con:
```yaml
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```
`created:` si scrive una sola volta, alla prima generazione del file; `updated:`
si riscrive ad ogni modifica successiva (da questa skill o da qualunque altra
che tocchi quel file — `aios-data`, `datapyx`…). Stessa convenzione si applica a
`.claude/aios-build.md` e `automations/roadmap.md` (vedi skill `aios` e
`aios-automation`). Non si applica a `.claude/commands/*.md` (SOP statiche, non
stato aziendale).

**Registro lavori `.claude/log.md`.** Se non esiste, crealo con un header
minimo (`# Log — {{cliente}}` + una riga di spiegazione: append-only, una riga
per lavoro completato). Al termine di questo livello, appendi:
`- YYYY-MM-DD · aios-context · Livello 1 Contesto costruito (+ brand se creato)`.
Ogni altra skill del plugin fa lo stesso alla fine del proprio lavoro — non
per ogni micro-step, solo per lavori conclusi.

**CLAUDE.md** deve: descrivere in breve l'azienda e il ruolo dell'utente;
istruire a leggere i file in `.claude/context/`; indicare di eseguire `/prime` a
inizio sessione. Se al passo 7 crei la cartella `brand/`, importa anche quei file
nel CLAUDE.md. Se un CLAUDE.md esiste già, integralo senza distruggere il
contenuto esistente.

**prime.md** deve leggere tutti i file in `.claude/context/` (incluso
`.claude/context/key-metrics.md` del livello Dati/DataOS, se presente) e produrre
un riepilogo sintetico di chi è l'utente, cosa fa l'azienda, priorità e numeri
chiave. Scrivi le istruzioni del comando così che restino valide anche quando i
file di contesto crescono (nuovi file di contesto, `history.md` di InfraOS…).

**prime.md — retention del log.** Il comando controlla anche la data della
voce **più vecchia** in `.claude/log.md` (non lo legge tutto, solo la prima
riga di log). Se risale a più di **3 mesi fa**, segnalalo e chiedi: *"Il log
lavori ha voci più vecchie di 3 mesi — vuoi che le archivi in
`.claude/log-archivio.md` o che le elimini?"*. Non pulire mai senza chiedere;
se l'utente non risponde o rifiuta, non insistere nella stessa sessione.

Tutti i contenuti generati per aziende italiane vanno **in italiano**.

### 7. Brand & Design (identità visiva)
Il contesto testuale non basta: un AIOS aziendale ha bisogno anche dell'identità
visiva (colori, tipografia, logo) e dello stack tecnico. Questa parte **riusa la
skill `client-project-kickoff`**, specializzata proprio in questo — non
duplicarne i template, usala come riferimento.
- Chiedi se l'azienda ha già un **brand definito** e se ha un **sito esistente**.
- **Se c'è un sito**, delega l'estrazione a **un subagent** (come fa
  client-project-kickoff): colori esatti, font, logo, piattaforma/CMS in un solo
  report strutturato, senza inquinare il contesto principale con HTML grezzo.
  Tratta i valori come da confermare con l'utente.
- **Se il brand non esiste** (o va rifatto), non fermarti a `(da definire)`:
  client-project-kickoff lo **crea da zero delegando a brandkit** (concept logo,
  palette strategica, tipografia, brand-board), salvando gli asset in
  `brand/assets/`. Conferma la direzione con l'utente prima di renderla finale.
- Genera la cartella `brand/` con `brand-identity.md`, `colors.md`,
  `typography.md`, `tech-stack.md`, `assets/`, seguendo i template di
  client-project-kickoff.
- **Non inventare mai** un hex o un font: usa `(da definire)` se non confermato.
- Collega i file `brand/` al CLAUDE.md (import) così l'identità visiva è caricata
  ogni sessione.

Salta questo passo solo se l'utente non ha e non vuole un'identità di brand (es.
uso puramente interno/analitico).

### 8. InfraOS (opzionale)
A generazione completata, chiedi se vuole **versionare l'AIOS con Git/GitHub**
(tracciabilità, backup, storia tra sessioni). Se sì → segui
`references/infraos-setup.md`.

### 9. Chiusura
Dì all'utente di **aprire una nuova sessione e lanciare `/prime`** per caricare
il contesto. Se ha attivato InfraOS, ricordagli il flusso: `/prime` a inizio
sessione, `/commit` a fine sessione.
