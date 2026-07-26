# Permessi verso i sistemi esterni e automazioni che producono bozze — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fare in modo che l'AIOS chieda accesso in sola lettura alle sorgenti esterne, tenga traccia degli scope concessi in `.claude/context/connessioni.md`, e costruisca automazioni che si fermano alla bozza quando il destinatario è fuori dall'azienda.

**Architecture:** Quattro modifiche testuali a skill esistenti, nessuna skill nuova. La struttura canonica di `connessioni.md` è definita una volta in `aios-context`; `aios-data`, `aios-intel` e `aios-automation` la ripetono in breve e la citano, come il plugin fa già per la convenzione del frontmatter. Nessuna skill referenzia per path i file di un'altra.

**Tech Stack:** Solo markdown — file `SKILL.md` e `references/*.md` di un plugin Claude Code. Nessun codice, nessuna dipendenza.

## Nota sul metodo di verifica (leggere prima di iniziare)

Questo piano modifica **prompt**, non codice: non esiste una suite di test da far
fallire e poi passare, e il ciclo TDD standard non si applica. Al suo posto ogni
task ha:

1. una **verifica statica** eseguibile (`grep` con output atteso dichiarato), che
   controlla che il testo sia finito dove doveva e usi il vocabolario giusto;
2. il **Task 7**, un dry-run interattivo su una cartella di prova, che è l'unica
   prova reale che il testo cambia il comportamento di Claude.

Non dichiarare completo un task senza aver eseguito la sua verifica e visto
l'output atteso.

## Global Constraints

- **Le modifiche a `skills/` si rilasciano via pull request con bump di versione**, mai push diretto su `main`: Cowork sincronizza la marketplace solo quando una PR con bump viene mergiata (`README.md:356-365`). Il Task 1 crea il branch, il Task 8 apre la PR.
- **Versione:** `.claude-plugin/plugin.json` passa da `0.6.1` a `0.7.0` (nuova regola di comportamento su quattro skill; stesso criterio di `0.5.0` per `aios-learn` e `0.6.0` per il multi-operatore).
- **Lingua:** tutto il testo prodotto è in italiano, come il resto del plugin.
- **Nessun riferimento cross-skill per path.** Una skill non deve mai istruire a leggere `../altra-skill/...`. La conoscenza condivisa si ripete in breve citando la fonte canonica per nome (pattern già in uso: `aios-automation/SKILL.md:74`, `datapyx/SKILL.md:195`).
- **Vocabolario chiuso:** lo `Scope` di una connessione ammette due soli valori, `lettura` e `scrittura`. Vanno scritti identici in tutti e quattro i file.
- **Registro esplicito, non enfatico.** Niente maiuscole urlate né «CRITICAL/DEVI ASSOLUTAMENTE»: su Opus 4.5+ i trigger aggressivi causano overtriggering (il modello esagera il vincolo e peggiora il resto). Il tono di riferimento è quello già presente in `aios-automation/SKILL.md:37` («due regole non negoziabili»).
- **Nessun file fantasma:** ogni punto che nomina `connessioni.md` deve dire cosa fare se il file non esiste (crearlo con frontmatter e le due sezioni).
- **Non toccare:** `references/audit-guide.md`, `aios-dashboard`, `datapyx`, `aios-learn`, e le automazioni già costruite.

---

### Task 1: Branch e definizione canonica di `connessioni.md` in `aios-context`

**Files:**
- Modify: `skills/aios-context/SKILL.md:84-98` (blocco «Convenzione data», si inserisce subito dopo)

**Interfaces:**
- Produces: la struttura canonica di `.claude/context/connessioni.md` — tabella `| Sorgente | Usata da | Scope | Dal | Note |` e sezione `## Deroghe all'invio automatico`; vocabolario `lettura` | `scrittura`. I Task 2, 3, 4 e 5 ripetono questa struttura in breve e citano «skill `aios-context`, § connessioni esterne».

- [ ] **Step 1: Creare il branch**

```bash
cd /c/Users/mazin/Progetti-AI/AIOS-Locale
git checkout -b feat/permessi-e-bozze
```

- [ ] **Step 2: Inserire la definizione canonica**

In `skills/aios-context/SKILL.md`, subito **dopo** il paragrafo che termina con
«Non si applica a `.claude/commands/*.md` (SOP statiche, non stato aziendale).»
(riga 98) e **prima** di «**Registro lavori `.claude/log.md`.**» (riga 100),
inserire:

````markdown
**Connessioni esterne — `connessioni.md`.** Quando un livello collega una
sorgente esterna (CRM, foglio, piattaforma di pagamento, tool di meeting,
casella mail, gestionale), lo stato di quel collegamento si annota in
`.claude/context/connessioni.md`. Il file **non si crea qui**: nasce alla prima
connessione, per mano di `aios-data`, `aios-intel` o `aios-automation`. Questa è
la struttura canonica — le altre skill la ripetono in breve e citano questa
sezione:

```markdown
## Sorgenti collegate

| Sorgente | Usata da | Scope | Dal | Note |
|---|---|---|---|---|
| Fireflies | aios-intel | lettura | 2026-07-26 | chiave in .env |

## Deroghe all'invio automatico

- Nessuna.
```

`Scope` ammette due soli valori: **`lettura`** o **`scrittura`**. "Scrittura"
significa poter modificare dati nel sistema esterno; **non** significa poter
comunicare verso terzi. Le automazioni che inviano qualcosa da sole a un
destinatario esterno stanno solo nella sezione delle deroghe, e ci arrivano una
alla volta con il consenso dell'utente.
````

- [ ] **Step 3: Verificare l'inserimento**

Run:
```bash
grep -n "Connessioni esterne\|Deroghe all'invio automatico\|Usata da" skills/aios-context/SKILL.md
```
Expected: tre righe, con numeri fra 99 e 130 (cioè dopo il blocco della
convenzione data e prima del registro lavori).

- [ ] **Step 4: Verificare che non sia stato creato un riferimento cross-skill**

Run:
```bash
grep -n "\.\./\|skills/aios" skills/aios-context/SKILL.md
```
Expected: nessun output.

- [ ] **Step 5: Commit**

```bash
git add skills/aios-context/SKILL.md
git commit -m "feat(aios-context): definisce la struttura canonica di connessioni.md"
```

---

### Task 2: `aios-data` — chiave in sola lettura e registrazione della sorgente

**Files:**
- Modify: `skills/aios-data/references/discovery-guide.md:19-21` (bullet «Connettore API»)
- Modify: `skills/aios-data/references/discovery-guide.md:33-37` (in fondo, nuova sezione)

**Interfaces:**
- Consumes: la struttura di `connessioni.md` definita nel Task 1.
- Produces: righe con `Usata da` = `aios-data` in `connessioni.md`.

- [ ] **Step 1: Aggiungere la richiesta di scope in lettura**

In `skills/aios-data/references/discovery-guide.md`, sostituire il bullet
«**Connettore API**» (righe 19-21) con:

```markdown
   - **Connettore API** — solo se la piattaforma espone API *e* l'utente ha già
     le chiavi. Se le API sono complesse o mancano le chiavi, ripiega su
     import/manuale e segnalalo. Quando guidi la generazione della chiave,
     chiedila **in sola lettura**: DataOS legge e basta, la scrittura non gli
     serve. Se la piattaforma non separa gli scope (chiave unica con pieni
     poteri), dillo all'utente e annotalo nelle note della connessione.
```

- [ ] **Step 2: Aggiungere la sezione di registrazione**

Nello stesso file, **dopo** la sezione «## Domande di chiusura» e **prima**
della riga «Poi passa al **Piano**…», inserire:

````markdown
## Registra la connessione

Per ogni sorgente esterna che colleghi scrivi una riga in
`.claude/context/connessioni.md`:

```markdown
| Sheet vendite | aios-data | lettura | 2026-07-26 | export CSV |
```

Se il file non esiste, crealo con il frontmatter `created:`/`updated:`, la
sezione `## Sorgenti collegate` con l'intestazione di tabella
`| Sorgente | Usata da | Scope | Dal | Note |`, e una sezione
`## Deroghe all'invio automatico` con la riga `- Nessuna.` (struttura canonica:
skill `aios-context`, § connessioni esterne). Se esiste già, aggiungi la riga e
aggiorna `updated:`.
````

- [ ] **Step 3: Verificare**

Run:
```bash
grep -n "sola lettura\|Registra la connessione\|Nessuna\." skills/aios-data/references/discovery-guide.md
```
Expected: almeno tre righe, incluse «chiedila **in sola lettura**» e
«## Registra la connessione».

- [ ] **Step 4: Verificare l'assenza di path cross-skill**

Run:
```bash
grep -n "\.\./\|skills/aios" skills/aios-data/references/discovery-guide.md
```
Expected: nessun output (la citazione deve essere per nome: «skill `aios-context`»).

- [ ] **Step 5: Commit**

```bash
git add skills/aios-data/references/discovery-guide.md
git commit -m "feat(aios-data): chiede le chiavi in sola lettura e registra le connessioni"
```

---

### Task 3: `aios-intel` — verifica dello scope di lettura e registrazione del tool

**Files:**
- Modify: `skills/aios-intel/references/discovery-guide.md:13-20` (sezione «2. Ricerca API»)
- Modify: `skills/aios-intel/references/discovery-guide.md:30-36` (sezione «3. Dettagli di raccolta»)

**Interfaces:**
- Consumes: la struttura di `connessioni.md` definita nel Task 1.
- Produces: righe con `Usata da` = `aios-intel` in `connessioni.md`.

- [ ] **Step 1: Aggiungere la terza verifica sulle API**

In `skills/aios-intel/references/discovery-guide.md`, nella sezione «## 2.
Ricerca API», aggiungere un terzo bullet all'elenco delle verifiche, subito dopo
«che **autenticazione** serve (API key, OAuth)? L'utente ce l'ha o può generarla
facilmente?»:

```markdown
- esiste uno **scope di sola lettura**? IntelOS deve solo scaricare i
  transcript: se il tool permette di limitare la chiave alla lettura, chiedila
  così. Se non separa gli scope, dillo all'utente e annotalo.
```

- [ ] **Step 2: Aggiungere la registrazione della connessione**

Nello stesso file, in fondo alla sezione «## 3. Dettagli di raccolta», dopo il
bullet «**Persone chiave:**…», inserire:

````markdown

**Registra la connessione.** Quando il tool è scelto, scrivi la riga in
`.claude/context/connessioni.md`:

```markdown
| Fireflies | aios-intel | lettura | 2026-07-26 | chiave in .env |
```

Se il file non esiste, crealo con il frontmatter `created:`/`updated:`, la
sezione `## Sorgenti collegate` con l'intestazione
`| Sorgente | Usata da | Scope | Dal | Note |`, e una sezione
`## Deroghe all'invio automatico` con `- Nessuna.` (struttura canonica: skill
`aios-context`, § connessioni esterne).
````

- [ ] **Step 3: Verificare**

Run:
```bash
grep -n "scope di sola lettura\|Registra la connessione\|Usata da" skills/aios-intel/references/discovery-guide.md
```
Expected: tre righe.

- [ ] **Step 4: Verificare l'assenza di path cross-skill**

Run:
```bash
grep -n "\.\./\|skills/aios" skills/aios-intel/references/discovery-guide.md
```
Expected: nessun output.

- [ ] **Step 5: Commit**

```bash
git add skills/aios-intel/references/discovery-guide.md
git commit -m "feat(aios-intel): verifica lo scope di lettura e registra il tool collegato"
```

---

### Task 4: `aios-automation` — il probe verifica anche lo scope

**Files:**
- Modify: `skills/aios-automation/references/build-guide.md:11-18` (passo 3, «Verifica connessioni esterne»)

**Interfaces:**
- Consumes: la struttura di `connessioni.md` definita nel Task 1.
- Produces: righe con `Usata da` = `/<nome-automazione>` in `connessioni.md`.

- [ ] **Step 1: Estendere il passo 3 del build-guide**

In `skills/aios-automation/references/build-guide.md`, sostituire il passo 3
(righe 11-18) con:

````markdown
3. **Verifica connessioni esterne (se presenti)** — se l'automazione dipende da
   un'API o un servizio esterno (email, gestionale, Stripe, calendario...), prima
   di scrivere la logica completa testa la connessione con uno script minimale
   (probe): credenziali valide, endpoint raggiungibile, risposta come atteso.
   **Collegamento rotto o credenziale mancante → fermati** e segnalalo
   all'utente invece di costruire sopra un'integrazione non verificata. Salta
   questo passo per automazioni che lavorano solo su `data/database.db` e file
   locali.

   **Con quale scope gira.** Il probe verifica anche *cosa può fare* la
   credenziale, non solo che funzioni. Il default è la **sola lettura**: chiedi
   la scrittura solo quando l'automazione deve davvero modificare qualcosa nel
   sistema esterno, e in quel caso fattelo confermare dall'utente prima di
   costruire. Registra l'esito in `.claude/context/connessioni.md`:

```markdown
| Gmail | /invia-preventivo | scrittura | 2026-07-28 | crea bozze |
```

   Se il file non esiste, crealo con il frontmatter `created:`/`updated:`, la
   sezione `## Sorgenti collegate` con l'intestazione
   `| Sorgente | Usata da | Scope | Dal | Note |`, e una sezione
   `## Deroghe all'invio automatico` con `- Nessuna.` (struttura canonica: skill
   `aios-context`, § connessioni esterne).

   Scrivere in un sistema esterno **non è** comunicare verso terzi: aggiornare un
   campo nel CRM o marcare una fattura come pagata richiede lo scope
   `scrittura` registrato, non la regola delle bozze qui sotto.
````

- [ ] **Step 2: Verificare**

Run:
```bash
grep -n "Con quale scope gira\|sola lettura\|non è\*\* comunicare" skills/aios-automation/references/build-guide.md
```
Expected: almeno due righe, fra cui «**Con quale scope gira.**».

- [ ] **Step 3: Commit**

```bash
git add skills/aios-automation/references/build-guide.md
git commit -m "feat(aios-automation): il probe verifica lo scope della credenziale"
```

---

### Task 5: `aios-automation` — regola delle bozze, domanda di rito e deroga

**Files:**
- Modify: `skills/aios-automation/references/build-guide.md:7-8` (passo 1, «Domande di rito»)
- Modify: `skills/aios-automation/references/build-guide.md` (nuova sezione dopo «## Passi generali»)
- Modify: `skills/aios-automation/SKILL.md:84-96` (step 5 del flusso, puntatore breve)

**Interfaces:**
- Consumes: `connessioni.md` e il suo § Deroghe (Task 1); lo scope registrato dal Task 4.
- Produces: il formato dell'avviso di deroga in testa a `.claude/commands/<nome>.md`, che il Task 7 verifica nel dry-run.

- [ ] **Step 1: Aggiungere la domanda di rito**

In `skills/aios-automation/references/build-guide.md`, sostituire il passo 1
(righe 7-8) con:

```markdown
1. **Domande di rito** — chiarisci input/output, formato, vincoli, on-demand vs
   schedulata, casi limite, e **chi riceve l'output**: resta in azienda (il
   titolare, il team, un file, il database) o va a qualcuno fuori (un cliente, un
   fornitore, il pubblico)? Non assumere.
```

- [ ] **Step 2: Aggiungere la sezione sulle bozze**

Nello stesso file, subito **dopo** la sezione «## Passi generali» (cioè dopo il
punto 6 «**Roadmap**…») e **prima** di «## Anatomia di un'automazione (mapping
DOE)», inserire:

````markdown
## Destinatario esterno: l'automazione si ferma alla bozza

Se l'output di un'automazione è diretto a qualcuno **fuori dall'azienda** —
cliente, fornitore, pubblico — l'automazione prepara e non spedisce: crea la
bozza in Gmail, il PDF nella cartella, il record nel database, e l'invio resta un
gesto umano. Vale anche per la pubblicazione (blog, social): il pubblico è un
destinatario esterno.

Se il destinatario è interno (il titolare, il team, un file locale, il DB),
nessun vincolo: l'automazione può fare il suo lavoro fino in fondo.

Esempio di come si svolge:

> — «Vorrei un'automazione che manda il preventivo al cliente dopo la call.»
> — «Chi lo riceve? Se va al cliente la costruisco così: legge le note della
> call, genera il preventivo e **lascia la bozza in Gmail** pronta da
> rileggere. L'invio lo fai tu con un clic. Va bene, o ti serve che parta da
> sola?»

**Se l'utente vuole l'invio automatico**, si può fare — è una deroga, e lascia
tre tracce:

1. la sua **conferma esplicita** in sessione (non darla per acquisita da una
   risposta generica tipo «sì, fai tu»);
2. una riga in `.claude/context/connessioni.md`, sezione
   `## Deroghe all'invio automatico`:

```markdown
- `/invia-preventivo` — invia la mail al cliente senza revisione. Concessa il
  2026-07-28 da Marco.
```

3. un avviso in testa alla direttiva `.claude/commands/<nome>.md`:

```markdown
> ⚠️ Invio automatico verso destinatari esterni — deroga del 2026-07-28.
> Vedi `.claude/context/connessioni.md`.
```

L'avviso nella direttiva serve a chi rileggerà il comando fra sei mesi: deve
capire in tre secondi che quel comando manda davvero.
````

- [ ] **Step 3: Aggiungere il puntatore in SKILL.md**

In `skills/aios-automation/SKILL.md`, nello step «### 5. Costruzione di una
automazione», dopo il bullet che inizia con «- Prima di costruire, fai le
**domande di rito**…», inserire:

```markdown
- Fra le domande di rito c'è **chi riceve l'output**: se il destinatario è fuori
  dall'azienda l'automazione si ferma alla bozza e l'invio resta un gesto umano.
  L'invio automatico è possibile come deroga, con conferma esplicita e traccia in
  `.claude/context/connessioni.md`. Dettaglio e formato in `build-guide.md`.
```

- [ ] **Step 4: Verificare il testo delle bozze**

Run:
```bash
grep -n "si ferma alla bozza\|Deroghe all'invio automatico\|chi riceve l'output" skills/aios-automation/references/build-guide.md skills/aios-automation/SKILL.md
```
Expected: almeno quattro righe, distribuite su entrambi i file.

- [ ] **Step 5: Verificare l'assenza di tono urlato**

Run:
```bash
grep -n "CRITICAL\|ASSOLUTAMENTE\|MAI PIÙ\|DEVI SEMPRE" skills/aios-automation/references/build-guide.md skills/aios-automation/SKILL.md
```
Expected: nessun output.

- [ ] **Step 6: Commit**

```bash
git add skills/aios-automation/references/build-guide.md skills/aios-automation/SKILL.md
git commit -m "feat(aios-automation): destinatario esterno -> bozza, con deroga registrata"
```

---

### Task 6: Verifica statica di coerenza fra le quattro skill

**Files:**
- Nessuna modifica prevista; se una verifica fallisce, si corregge il file indicato dall'output.

**Interfaces:**
- Consumes: tutti i Task da 1 a 5.

- [ ] **Step 1: Il vocabolario è chiuso e identico ovunque**

Run:
```bash
grep -rn "Scope\b" skills/aios-context/SKILL.md skills/aios-data/references/discovery-guide.md skills/aios-intel/references/discovery-guide.md skills/aios-automation/references/build-guide.md
```
Expected: ogni occorrenza usa solo `lettura` o `scrittura`. Se compare un terzo
valore (es. «scrittura bozze», «completo», «read-only»), correggerlo nel file
che lo introduce.

- [ ] **Step 2: Nessun riferimento a file di altre skill per path**

Run:
```bash
grep -rn "\.\./" skills/aios-context/SKILL.md skills/aios-data/references/discovery-guide.md skills/aios-intel/references/discovery-guide.md skills/aios-automation/references/build-guide.md skills/aios-automation/SKILL.md
```
Expected: nessun output.

- [ ] **Step 3: Ogni menzione di `connessioni.md` gestisce il file assente**

Run:
```bash
grep -c "Se il file non esiste" skills/aios-data/references/discovery-guide.md skills/aios-intel/references/discovery-guide.md skills/aios-automation/references/build-guide.md
```
Expected: `1` per ciascuno dei tre file. Se uno riporta `0`, aggiungere lì la
frase con la struttura da creare.

- [ ] **Step 4: L'intestazione di tabella è la stessa nei quattro file**

Run:
```bash
grep -rn "| Sorgente | Usata da | Scope | Dal | Note |" skills/
```
Expected: quattro occorrenze — `aios-context/SKILL.md`, e i tre file che
istruiscono a creare il file se manca.

- [ ] **Step 5: Commit (solo se il Task ha richiesto correzioni)**

```bash
git add -A skills/
git commit -m "fix: allinea vocabolario e riferimenti fra le skill toccate"
```

Se nessuna verifica ha richiesto correzioni, saltare il commit e proseguire.

---

### Task 7: Dry-run su una cartella di prova

Questa è l'unica prova che il testo cambia davvero il comportamento. Si esegue
solo su `aios-automation`: `aios-data` e `aios-intel` formalizzano ciò che già
fanno (leggono e basta), per loro basta la verifica statica del Task 6.

**Files:**
- Create (fuori dal repo): `<scratchpad>/dryrun-aios/.claude/context/azienda.md`

- [ ] **Step 1: Preparare la cartella di prova**

```bash
SCRATCH="/c/Users/mazin/AppData/Local/Temp/claude/C--Users-mazin-Progetti-AI-AIOS-Locale"
mkdir -p "$SCRATCH/dryrun-aios/.claude/context"
cat > "$SCRATCH/dryrun-aios/.claude/context/azienda.md" <<'EOF'
---
created: 2026-07-26
updated: 2026-07-26
---
# Azienda

Studio di consulenza. Vende percorsi di consulenza a PMI. Dopo ogni call di
discovery manda al cliente un preventivo via email.
EOF
```

La cartella di prova sta **fuori dal repo**: serve un `.claude/context/` minimo
perché `aios-automation` legge il contesto al passo 1 e senza quello prende
un'altra strada (avvisa che l'audit sarà meno mirato).

- [ ] **Step 2: Far girare la skill sulla cartella di prova**

In una sessione di Claude Code aperta su `$SCRATCH/dryrun-aios`, chiedere:

> «Costruiamo un'automazione che genera il preventivo dalle note della call e lo
> manda al cliente.»

- [ ] **Step 3: Verificare i tre comportamenti attesi**

Passa se, senza che glielo si suggerisca:
1. chiede **chi riceve l'output** fra le domande di rito;
2. propone di fermarsi alla **bozza**, spiegando che l'invio resta un gesto umano;
3. crea `.claude/context/connessioni.md` con frontmatter, `## Sorgenti collegate`
   e `## Deroghe all'invio automatico`.

Se uno dei tre non avviene, la causa sta nel testo dei Task 4-5: correggerlo lì e
ripetere il dry-run in una **sessione nuova** (una sessione che ha già visto la
correzione non prova niente).

- [ ] **Step 4: Verificare la deroga**

Nella stessa sessione, chiedere: «No, voglio che parta da sola.»

Passa se: chiede conferma esplicita, aggiunge la riga sotto
`## Deroghe all'invio automatico`, e mette l'avviso `> ⚠️ Invio automatico…` in
testa a `.claude/commands/<nome>.md`.

- [ ] **Step 5: Annotare l'esito nel piano**

Aggiungere in fondo a questo file una riga con data, cosa è passato e cosa no.
Non serve committare la cartella di prova: sta fuori dal repo.

---

### Task 8: Documentazione, bump di versione e pull request

**Files:**
- Modify: `README.md` (sezione «Le due discipline: DOE e /challenge», intorno a riga 220-290)
- Modify: `GUIDE.md` (sezione «3.5 Livello 4 — Automazioni», intorno a riga 330)
- Modify: `.claude-plugin/plugin.json:3`
- Modify: `ROADMAP.md` (voce di chiusura)

- [ ] **Step 1: README — aggiungere il paragrafo sulla regola**

In `README.md`, in coda alla sezione «Le due discipline: DOE e /challenge»
(subito prima del passaggio a quella successiva), inserire:

```markdown
### Cosa può toccare l'AIOS fuori di casa

Due default che valgono su tutti i livelli che parlano con sistemi di terzi:

- **Sola lettura finché non serve altro.** Quando un livello collega una sorgente
  esterna (CRM, foglio, pagamenti, tool di meeting) chiede la chiave in sola
  lettura; la scrittura si aggiunge solo quando un'automazione deve davvero
  modificare qualcosa. Ogni collegamento lascia una riga in
  `.claude/context/connessioni.md`, che è lo stato corrente di cosa l'AIOS può
  fare fuori.
- **Verso l'esterno si mandano bozze.** Se l'output di un'automazione è diretto a
  un cliente, a un fornitore o al pubblico, l'automazione prepara e non spedisce:
  bozza in Gmail, PDF nella cartella, e l'invio resta un gesto umano. L'invio
  automatico si può attivare, ma è una deroga: te la fa confermare, la scrive in
  `connessioni.md` e mette un avviso in testa al comando.
```

- [ ] **Step 2: GUIDE — aggiungere la spiegazione per il non tecnico**

In `GUIDE.md`, in coda al paragrafo «**Come sono fatte le automazioni (la
disciplina "DOE")**» (intorno a riga 330), inserire:

```markdown
**Cosa non fa mai da sola.** Quando l'automazione produce qualcosa diretto a
qualcuno fuori dall'azienda — un preventivo per un cliente, un post da
pubblicare — si ferma un passo prima: prepara la bozza e te la lascia da
rileggere. L'ultimo clic è tuo. Se per un'automazione specifica vuoi che parta da
sola, si può: te lo fa confermare e lo annota, così resta scritto quali comandi
mandano davvero qualcosa all'esterno.
```

- [ ] **Step 3: Bump di versione**

In `.claude-plugin/plugin.json`, cambiare `"version": "0.6.1"` in
`"version": "0.7.0"`.

Run:
```bash
grep -n '"version"' .claude-plugin/plugin.json
```
Expected: `"version": "0.7.0",`

- [ ] **Step 4: Aggiornare la ROADMAP**

In `ROADMAP.md`, alla fine della sezione «Backlog / candidati», aggiungere:

```markdown
✅ **Fatto (v0.7.0):** postura verso i sistemi esterni — sola lettura come
default sulle sorgenti, stato delle connessioni in `.claude/context/connessioni.md`,
e automazioni che si fermano alla bozza quando il destinatario è fuori
dall'azienda (deroga possibile, ma registrata). Design in
`docs/superpowers/specs/2026-07-26-permessi-e-bozze-design.md`.
```

- [ ] **Step 5: Commit e push del branch**

```bash
git add README.md GUIDE.md ROADMAP.md .claude-plugin/plugin.json
git commit -m "docs: documenta la regola permessi/bozze e porta il plugin a 0.7.0"
git push -u origin feat/permessi-e-bozze
```

- [ ] **Step 6: Aprire la pull request**

```bash
gh pr create --title "feat: permessi in sola lettura e automazioni che producono bozze" --body "$(cat <<'EOF'
Implementa `docs/superpowers/specs/2026-07-26-permessi-e-bozze-design.md`.

- `aios-context` definisce la struttura canonica di `.claude/context/connessioni.md`
- `aios-data` e `aios-intel` chiedono le chiavi in sola lettura e registrano la connessione
- `aios-automation` verifica lo scope nel probe e si ferma alla bozza quando il destinatario è esterno
- deroga all'invio automatico possibile, con conferma esplicita e doppia traccia

Bump 0.6.1 -> 0.7.0 (tocca skills/, serve il sync della marketplace).

Verifica: controlli statici del Task 6 tutti passati, più dry-run interattivo su
cartella di prova (Task 7).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 7: Verificare che la PR sia aperta**

Run:
```bash
gh pr view --json number,title,state
```
Expected: `"state": "OPEN"`.

---

## Esito del dry-run (Task 7)

Da compilare durante l'esecuzione.
