# AIOS — Guida d'uso dettagliata

Guida passo-passo pensata per **chi non ha mai usato un terminale**. Ti prende per
mano dall'installazione fino all'uso quotidiano, costruendo insieme, come esempio,
l'AIOS di un'azienda inventata: **Studio Rossi**, una piccola agenzia di
comunicazione da 3 persone.

> Se cerchi solo la panoramica veloce (cosa contiene, comandi principali), sta nel
> [README](README.md). Questa guida è il *lungo*: ogni passaggio spiegato.

---

## Indice

- [0. Prima di iniziare: le 4 parole da conoscere](#0-prima-di-iniziare-le-4-parole-da-conoscere)
- [1. Installazione passo-passo](#1-installazione-passo-passo)
- [2. I concetti in 2 minuti](#2-i-concetti-in-2-minuti)
- [3. Walkthrough: costruiamo l'AIOS di "Studio Rossi"](#3-walkthrough-costruiamo-laios-di-studio-rossi)
  - [3.0 Apri la cartella del cliente](#30-apri-la-cartella-del-cliente)
  - [3.1 `/aios` — l'avvio](#31-aios--lavvio)
  - [3.2 Livello 1 — Contesto + Brand](#32-livello-1--contesto--brand)
  - [3.3 Livello 2 — Dati](#33-livello-2--dati)
  - [3.4 Livello 3 — Intelligence (riunioni)](#34-livello-3--intelligence-riunioni)
  - [3.5 Livello 4 — Automazioni](#35-livello-4--automazioni)
  - [3.6 Livello 5 — Dashboard](#36-livello-5--dashboard)
- [4. DataPyx: leggere una sfida + il gate `/challenge`](#4-datapyx-leggere-una-sfida--il-gate-challenge)
- [5. La giornata tipo](#5-la-giornata-tipo)
- [6. Aggiornare, riprendere, più macchine](#6-aggiornare-riprendere-più-macchine)
- [7. Problemi frequenti (FAQ)](#7-problemi-frequenti-faq)
- [8. Mappa dei file creati](#8-mappa-dei-file-creati)

---

## 0. Prima di iniziare: le 4 parole da conoscere

Se questi termini ti sono nuovi, leggi qui. Sono gli unici che servono.

- **Terminale** — una finestra dove scrivi comandi con la tastiera invece di
  cliccare. Su **Windows** si chiama *Terminale* o *PowerShell*; su **Mac** si
  chiama *Terminale* (lo trovi cercandolo con la lente in alto a destra). Scrivi
  una riga, premi **Invio**, il computer esegue.
- **Claude Code** — è Claude che vive nel terminale (o nell'app desktop) e può
  leggere/scrivere file sul tuo computer. È il "motore" su cui gira questo plugin.
  Se non ce l'hai ancora, installalo da [claude.com/code](https://claude.com/code).
- **Plugin** — un pacchetto di capacità aggiuntive che insegni a Claude Code una
  volta sola. **AIOS** è un plugin.
- **Comando slash** — un'istruzione che inizia con `/`, es. `/aios` o `/prime`.
  La scrivi in chat con Claude e lui esegue una procedura già pronta.

> **Non devi programmare.** Il plugin scrive lui il codice quando serve. Il tuo
> lavoro è **rispondere alle domande** che Claude ti fa e **confermare** prima che
> costruisca.

---

## 1. Installazione passo-passo

**Ti serve prima:** Claude Code installato e funzionante (vedi sopra). Gli altri
prerequisiti (Python, Git) te li chiede il plugin *solo quando servono* e ti guida
a installarli — non pensarci ora.

### Se usi Claude Code nel terminale o nell'app desktop

1. Apri Claude Code (scrivi `claude` nel terminale, oppure apri l'app).
2. In chat, scrivi questa riga e premi Invio:
   ```
   /plugin marketplace add CinaWeb/AIOS-Datapyx
   ```
   (Stai dicendo a Claude *dove* trovare il plugin: la repository su GitHub.)
3. Poi scrivi:
   ```
   /plugin install aios@aios
   ```
   (Stai *installando* il plugin.)
4. **Verifica:** scrivi `/plugin` e controlla che `aios` risulti installato e
   abilitato.

### Se usi Cowork (Claude nel browser/app)

1. Apri il menu **Customize** nella barra laterale.
2. Vai al tab **Plugins**.
3. In **Personal plugins**, clicca **"+" → Add marketplace**.
4. Scegli **Add from a repository** e incolla `CinaWeb/AIOS-Datapyx`.
5. Quando è sincronizzato, cerca **aios** nel catalogo e clicca **Install**.

### Come capisci che ha funzionato

Digita `/` in chat: fra i comandi disponibili devono comparire `aios`, `datapyx`,
`challenge`, ecc. Se li vedi, sei pronto.

> 💡 **Da qualunque punto, scrivi `/aios-help`** per un riepilogo veloce di cosa
> fa il plugin e di tutti i comandi. `/aios-help dati` (o un altro tema) va dritto
> all'argomento e ti rimanda alla sezione giusta di questa guida.

> **Aggiornare in futuro:** quando esce una versione nuova, basta
> `/plugin marketplace update aios`.

---

## 2. I concetti in 2 minuti

Un **AIOS** ("AI Operating System") è il **cervello operativo** di un'azienda:
Claude smette di essere generico e sa *chi è* quel cliente, *quali numeri* ha,
*cosa si è detto* nelle riunioni, e sa *fare* alcune operazioni al posto tuo.

Si costruisce a **5 livelli**, uno sopra l'altro:

| # | Livello | In parole semplici |
|---|---------|--------------------|
| 1 | **Contesto + Brand** | Chi è l'azienda, la sua strategia, i suoi colori/logo |
| 2 | **Dati** | I numeri veri (fatturato, clienti…) in un piccolo database |
| 3 | **Intelligence** | Le riunioni: decisioni, chi ha detto cosa |
| 4 | **Automazioni** | Compiti ripetitivi che Claude fa da solo (es. fatture) |
| 5 | **Dashboard** | Un pannello con i numeri e dei bottoni, per chi non usa il terminale |

Più due strumenti trasversali:

- **DataPyx** — il "consulente diagnostico": ti aiuta a capire *il problema vero*
  di un cliente, non solo i sintomi.
- **`/challenge`** — un "avvocato del diavolo": prende una tua diagnosi o
  decisione importante e prova a demolirla, così scopri i punti deboli *prima* di
  sbagliare.

Non devi costruire tutti i livelli subito: anche solo il Livello 1 è già utile.

---

## 3. Walkthrough: costruiamo l'AIOS di "Studio Rossi"

> **Studio Rossi** — agenzia di comunicazione, 3 persone, a Bologna. Segue ~12
> clienti con pacchetti mensili. Vuole che Claude conosca lo studio, tenga
> traccia di fatturato e clienti, ricordi le riunioni e generi le fatture.

Tutti gli esempi di dialogo qui sotto sono **realistici ma illustrativi**: il
tuo caso avrà numeri e domande diversi. Le tue risposte sono in `> corsivo`.

### 3.0 Apri la cartella del cliente

**Regola d'oro:** *una cartella = un cliente*. Quella cartella diventerà l'AIOS di
Studio Rossi. Nel terminale:

```
mkdir "Studio Rossi"
cd "Studio Rossi"
claude
```

- `mkdir "Studio Rossi"` crea la cartella.
- `cd "Studio Rossi"` ci entra ("cd" = *change directory*, cambia cartella).
- `claude` avvia Claude Code **dentro** quella cartella.

Da qui in poi lavori in chat con Claude.

### 3.1 `/aios` — l'avvio

Scrivi in chat:

```
/aios
```

Claude si presenta **come DataPyx** (è la "faccia" con cui parli all'AIOS) e ti
chiede da dove partire:

```
Ciao. Sono DataPyx. Ti aiuto a costruire e mantenere il cervello operativo
della tua azienda o del tuo cliente — contesto, brand, dati, riunioni e
automazioni. Per quale cliente lavoriamo? Partiamo da zero o riprendiamo?

> Partiamo da zero. Il cliente è Studio Rossi.
```

Dietro le quinte, `/aios` crea un file-promemoria (`.claude/aios-build.md`) dove
segna a che punto sei. Così, se chiudi tutto e torni domani, riprende da dove
eravate. Poi ti accompagna al **Livello 1**.

> **Puoi anche saltare l'orchestratore** e lanciare un singolo livello a mano, es.
> `/aios-context`. `/aios` serve a farli tutti in ordine senza dimenticarne.

### 3.2 Livello 1 — Contesto + Brand

È il livello più importante: se qui l'informazione è sbagliata, tutto il resto lo
sarà. Per questo Claude fa **l'intervistatore** e ti fa **una domanda alla volta**,
senza dare nulla per scontato.

Prima ti chiede *come* vuoi dargli le informazioni (puoi combinarle):

- **Intervista** — rispondi alle sue domande in chat;
- **Incolla testo** — gli passi il testo del vostro sito, un profilo LinkedIn, un
  brief;
- **Indica file** — metti un PDF/presentazione nella cartella e glielo fai leggere.

Esempio di intervista:

```
Claude: Partiamo dall'essenziale. In una frase, di cosa si occupa Studio Rossi?
> Comunicazione e social media per piccole imprese del food.

Claude: Chi sono le 3 persone e chi fa cosa?
> Anna (titolare, strategia), Luca (grafica), Sara (social & copy).

Claude: Come guadagnate — pacchetti, a progetto, a ore?
> Pacchetti mensili: Base 500€, Plus 900€, Premium 1500€.

Claude: Quanti clienti attivi oggi e con quale mix di pacchetti?
> 12 clienti: 5 Base, 5 Plus, 2 Premium.
```

Qui scatta una cosa importante: Claude **controlla che i numeri tornino**. Se dici
"fatturato 20.000€/mese" ma i pacchetti × clienti fanno 11.300€, si ferma e te lo
fa notare invece di scrivere un dato sbagliato.

Quando ha abbastanza, ti mostra un **riepilogo** e l'**elenco dei file** che sta
per creare, e aspetta il tuo **ok**. Poi genera dentro la cartella:

- `.claude/context/` — i file che descrivono l'azienda (chi è, strategia, numeri
  attuali, team…);
- `CLAUDE.md` — le istruzioni che Claude rileggerà a ogni sessione;
- il comando **`/prime`** — lo userai ogni mattina per "ricaricare" tutto il
  contesto (vedi §5);
- l'**identità di brand** (colori, tipografia, logo, stack): la *estrae* dal vostro
  sito se gliene dai l'indirizzo, oppure la *crea da zero*.

**InfraOS (opzionale ma consigliato).** Claude ti propone di attivare il
"salvataggio con storico": ogni volta che scrivi **`/commit`**, fa una fotografia
del lavoro e la salva (via Git/GitHub). Se non sai cos'è Git, va bene lo stesso:
di' di sì, ci pensa lui. Ti servirà solo `/commit` a fine giornata.

> ✅ **Traguardo:** da adesso, aprendo Claude in questa cartella e scrivendo
> `/prime`, lui *sa* cos'è Studio Rossi.

> 💡 **Dietro le quinte:** ogni file di contesto porta in testa una data di
> creazione e ultimo aggiornamento (non devi farci nulla, ci pensa Claude), e
> Claude tiene un piccolo registro (`.claude/log.md`) di cosa è stato costruito
> e quando — vedi [§5](#5-la-giornata-tipo) per i dettagli.

### 3.3 Livello 2 — Dati

Serve a portare i **numeri veri** dentro l'AIOS, in un piccolo database, così puoi
chiedere a Claude *"quanti clienti Premium ho?"* e ottenere la risposta dai dati.

Questo livello usa **Python** (un programma che fa girare gli script). Se non ce
l'hai, Claude te lo dice e ti dà il comando esatto per installarlo (es. su Windows
`winget install Python.Python.3.13`). Copia, incolla, Invio: fatto.

Poi fa un **workshop di discovery**: ti chiede *dove vivono* i tuoi dati.

```
Claude: Il fatturato e i clienti oggi dove li tieni?
> In un Google Sheet.

Claude: I pagamenti passano da uno strumento con API (Stripe, PayPal)?
> No, bonifici. Registro tutto a mano nel foglio.
```

In base alle risposte sceglie l'approccio (importa il Google Sheet, oppure crea un
comando per inserire i dati a mano, ecc.), ti mostra **lo schema del database** e i
file che creerà, e aspetta conferma. Poi costruisce:

- `data/database.db` — il database (un singolo file);
- `data/connectors/…` — gli script che riempiono il database dalle tue sorgenti;
- `data/refresh.py` + il comando **`/refresh-data`** — per riaggiornare i numeri
  quando cambiano;
- `.claude/context/key-metrics.md` — un riepilogo dei numeri chiave **generato
  automaticamente**, che `/prime` carica ogni volta. *(Non modificarlo a mano:
  si rigenera.)*

> ✅ **Traguardo:** ora `/prime` carica anche i numeri aggiornati, e puoi
> interrogare i dati a parole.

### 3.4 Livello 3 — Intelligence (riunioni)

Porta dentro l'AIOS i **transcript delle riunioni**, così Claude ricorda decisioni
e action item anche a settimane di distanza.

Claude ti chiede quale strumento usi per registrare/trascrivere i meeting
(Fireflies, Fathom, Zoom, Google Meet…). Cosa importante: **prima cerca la
documentazione tecnica** di quello strumento per verificare che sia collegabile.
Se il tuo non ha un modo pratico di collegarsi, ti **suggerisce l'alternativa
migliore** e ti spiega perché, lasciandoti decidere.

Costruisce poi:

- una tabella `meetings` dentro lo stesso `data/database.db`;
- `.claude/commands/collect-meetings.md` → il comando **`/collect-meetings`**
  (scarica le riunioni nuove);
- `.claude/commands/catchup.md` → il comando **`/catchup`** (ti fa il riassunto
  delle riunioni recenti: decisioni, cose da fare, con chi hai parlato).

Esempio d'uso, più avanti nel tempo:

```
> /catchup
Claude: Nelle ultime 3 riunioni: deciso di alzare il pacchetto Base a 550€ da
gennaio (con Anna); Sara segue il nuovo cliente "Forno Aurora"; azione aperta:
inviare preventivo a "Bar Centrale" entro venerdì.
```

> ✅ **Traguardo:** le riunioni non si perdono più. Chiedi *"cosa avevamo deciso
> sul cliente X?"* e Claude risponde.

### 3.5 Livello 4 — Automazioni

Qui insegni all'AIOS a **fare** compiti ripetitivi. Claude fa un **audit** area per
area (marketing, vendite, clienti, fatturazione, operations) e scrive una lista
prioritizzata in `automations/roadmap.md`. Per ognuna ti chiede: *la costruiamo
ora o la lasciamo per dopo?* Non costruisce nulla senza il tuo ok.

**Esempio classico: la fattura.**

```
Claude: Prima opportunità: generare le fatture mensili con numerazione
progressiva, leggendo i clienti dal database. La costruiamo?
> Sì.

Claude: (domande di rito) Che dati vuoi in fattura? IVA 22%? Da che numero
riparte la numerazione quest'anno?
> Sì IVA 22%, si riparte da 1.
```

Poi costruisce il comando **`/crea-fattura`** + lo script che genera il PDF, e fa
un **test vero** davanti a te:

```
> /crea-fattura per Forno Aurora, pacchetto Plus di novembre
Claude: Fattura n. 007 del 30/11 — Forno Aurora — €900 + IVA = €1.098.
PDF generato: automations/fatture/2025/fattura-007.pdf ✅
```

**Come sono fatte le automazioni (la disciplina "DOE").** Ogni automazione è
divisa in tre parti, per essere **affidabile**:

1. **il comando** (`/crea-fattura`) dice *cosa* fare;
2. **Claude** decide e raccoglie i dati mancanti (te li chiede);
3. **uno script** fa il lavoro esatto e ripetibile (numerazione, calcolo IVA, PDF).

La regola: **i calcoli veri li fa lo script, non Claude a mano** — così il numero
di fattura non "salta" mai. E se qualcosa va storto, Claude **corregge lo script**
(non aggira il problema) e la volta dopo è più robusto.

> ✅ **Traguardo:** operazioni ripetitive fatte in un comando, con numeri sempre
> giusti.

### 3.6 Livello 5 — Dashboard

L'ultimo livello crea un **pannello visivo** che gira sul tuo computer, con i
numeri chiave e dei **bottoni** per lanciare i comandi — pensato per chi *non*
vuole usare il terminale (es. un collega).

Scrivi:

```
/dashboard
```

Claude avvia un piccolo server locale e apre il browser su un indirizzo tipo
`http://127.0.0.1:8787`. Vedrai: riepilogo azienda, metriche, funnel, stato delle
automazioni, ultime riunioni, e un bottone per ogni comando (es. *"Aggiorna dati"*,
*"Catch-up riunioni"*). Clicchi il bottone → Claude esegue → l'output compare nella
pagina.

Claude ti chiede anche se la dashboard **la userai solo tu o anche altri**. Se è
condivisa, aggiunge un riquadro **"Contribuisci"** dove i colleghi scrivono chi
sono e cosa hanno notato sul campo (vedi §5).

> **È sicuro?** Di default sì: il pannello è visibile **solo sul tuo computer**
> (`127.0.0.1`), non su internet, e i bottoni possono lanciare **solo** i comandi
> del tuo AIOS, niente di arbitrario. Se lo apri agli altri
> (`AIOS_DASHBOARD_HOST`, vedi §5) allora chiunque raggiunga quella pagina sulla
> rete può lanciare quei comandi: va bene sulla rete dell'ufficio, non su una rete
> aperta o un WiFi pubblico.

> ✅ **Traguardo:** anche un collega non tecnico usa l'AIOS con un click.

---

## 4. DataPyx: leggere una sfida + il gate `/challenge`

Finora hai *costruito* l'AIOS. **DataPyx** serve invece a *ragionare*: quando un
cliente ha un problema e vuoi capire cosa succede davvero.

Lancialo con:

```
/datapyx
```

Ti chiede *"qual è la sfida?"* e poi ti guida in 5 fasi: ascolta, mappa il sistema,
**ri-formula il problema vero** (spesso diverso dal sintomo), propone i punti su
cui agire e degli scenari, e infine ti accompagna nel monitoraggio nel tempo. Fa
**una domanda alla volta** e ti dice sempre *quanto è sicuro* di ogni conclusione.

Esempio, in breve:

```
> /datapyx
Claude: Qual è la sfida che devi affrontare?
> Un cliente pasticceria perde fatturato e vuole aprire un e-commerce nazionale.

Claude: (dopo alcune domande) Attenzione: "aprire l'e-commerce" è già una
soluzione, non il problema. Prima capiamo perché cala il negozio.
…
```

Alla fine della diagnosi, DataPyx **non butta via il lavoro**: salva il
riepilogo (problema reale, punti di leva, prossimo passo) in
`.claude/context/decisioni.md`. La sessione successiva `/prime` lo ricarica
automaticamente — non ripartite mai da zero — e quando arrivi al Livello 4
(Automazioni), Claude usa quei punti di leva per capire *quali* automazioni
contano davvero, invece di proporne una lista generica.

### Il gate `/challenge` — l'avvocato del diavolo

Quando DataPyx arriva a una **diagnosi importante** (una decisione costosa, difficile
da tornare indietro), *prima di agire* conviene stressarla. Scrivi:

```
/challenge
```

`/challenge` prende l'ultima diagnosi e prova a **demolirla**: costruisce il
contro-argomento più forte, elenca le **assunzioni fragili**, immagina *come*
potrebbe andare male, e chiude con un **verdetto**:

- 🟢 **Regge** — puoi procedere, i rischi sono noti;
- 🟡 **Da rinforzare** — l'idea tiene ma manca qualcosa (te lo dice) da colmare prima;
- 🔴 **Da rivedere** — il contro-argomento è più forte: ripensala;
- ⚪ **Ambiguo** — troppo vaga per giudicarla, va chiarita.

Esempio reale di output:

```
> /challenge
Verdetto: 🟡 Da rinforzare — la diagnosi poggia su un dato aggregato (-12%
totale) mai scomposto. Prima di agire servono: (a) il calo per singolo negozio
(è concentrato in uno solo?), (b) volumi vs prezzo (hai solo alzato i prezzi?).
Confidenza del verdetto: Alta.
```

> **Quando usarlo:** solo per decisioni ad alta posta o quando la confidenza è
> "Media/Ipotesi". Non su ogni frase — è un *freno di emergenza*, non un tic.

**In due parole:** le automazioni (DOE) rendono affidabile ciò che **fai**;
`/challenge` rende rigoroso ciò che **decidi**.

---

## 5. La giornata tipo

Una volta costruito l'AIOS, il lavoro di ogni giorno è semplice:

| Quando | Scrivi | Cosa succede |
|--------|--------|--------------|
| **Apri la sessione** | `/prime` | Claude ricarica contesto + numeri chiave: sa tutto di nuovo |
| Prima di una call cliente | `/client-brief <nome>` | Brief in 5 min: storia, promesse vs consegne, pendenze, 3 punti d'agenda |
| Ti servono i numeri freschi | `/refresh-data` | Riaggiorna il database |
| Nuove riunioni da importare | `/collect-meetings` | Le scarica |
| "Cosa mi sono perso?" | `/catchup` | Riassunto riunioni recenti |
| Capire una sfida cliente | `/datapyx` | Diagnosi guidata |
| Stressare una decisione | `/challenge` | Red-team + verdetto |
| Fare un'operazione | `/<automazione>` | Es. `/crea-fattura` |
| Il pannello visivo | `/dashboard` | Apre la dashboard |
| Un collega ha notato qualcosa | `/contribuisci <chi sei>: <cosa>` | Lo aggiunge alle lezioni, o lo mette in coda se contraddice (di solito si fa dal riquadro della dashboard) |
| `/prime` dice "2 proposte in attesa" | `/rivedi-proposte` | Le vedi una alla volta e decidi: promuovi, rifiuta, riscrivi |
| **Chiudi la giornata** | `/debrief` | Claude ti fa qualche domanda e aggiorna il contesto coi progressi del giorno |
| Salva/versiona | `/commit` | Mette al sicuro il lavoro (se hai InfraOS) |

Il ritmo è sempre lo stesso: **`/prime` → lavori → `/debrief` → `/commit`**.
`/prime` la mattina ti fa ripartire dallo stato di ieri; `/debrief` la sera
registra cosa è successo oggi, così quello stato resta sempre aggiornato.

### Il registro dei lavori (`.claude/log.md`)

Ogni volta che una skill finisce un lavoro (costruisce un livello, chiude una
diagnosi, crea un'automazione…), aggiunge una riga a un piccolo registro:

```
- 2026-07-15 · aios-context · Livello 1 Contesto costruito (+ brand)
- 2026-07-15 · datapyx · Diagnosi conclusa — problema reale: calo concentrato
  nel negozio via Roma, non generalizzato
- 2026-07-20 · aios-automation · Automazione /crea-fattura costruita
```

Non è la conoscenza dell'azienda (quella vive nei file di contesto e non si
tocca), è solo la cronologia di *cosa è stato fatto e quando* — utile se torni
dopo mesi e vuoi ricordare a che punto eri senza rileggere tutto.

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

### Più persone che arricchiscono lo stesso AIOS

Se l'AIOS è il cervello di un'azienda, chi ci lavora dentro (chi segue la
comunicazione, chi i lead, chi i post) sa cose che tu non sai. Farli scrivere nei
file a mano sarebbe il modo più veloce per rompere tutto. Quindi non lo fanno:
**dalla dashboard c'è un riquadro "Contribuisci"** dove scrivono chi sono e cosa
hanno notato (*"i lead da fiera vanno richiamati entro 48h o si raffreddano"*), e
il resto lo fa Claude.

Cosa succede al contributo:

- **Se non contraddice** quello che l'AIOS già sa → finisce **subito** nelle
  lezioni, firmato con nome e data. Nessuno deve approvare niente: l'operatore ha
  aggiunto un pezzo e via.
- **Se contraddice** il contesto (dice il contrario della strategia, di un numero,
  di una procedura) → **non entra**. Va in una coda (`enrichment/proposals/`) e
  aspetta te. A ogni `/prime` Claude ti dice *"2 proposte in attesa"*, e con
  **`/rivedi-proposte`** le vedi una alla volta: per ognuna scegli se promuoverla,
  rifiutarla o riscriverla meglio.

Il tuo lavoro si riduce a quello: guardare i disaccordi. Tutto il resto scorre da
solo. E il **core** — chi è l'azienda, la strategia, le procedure — non lo tocca
mai nessun contributo automatico: quello resta roba tua.

A volte il conflitto ti dirà che ad avere ragione è l'operatore e non il file:
succede, vuol dire che la strategia è cambiata e nessuno l'ha scritto. Claude te
lo fa notare e ti propone di aggiornare il contesto.

**La dashboard va aperta agli altri.** Di default sta su `127.0.0.1`, cioè la vedi
solo tu su quel computer. Per farla raggiungere dagli altri in ufficio, chi la
avvia imposta `AIOS_DASHBOARD_HOST=0.0.0.0` (e volendo `AIOS_DASHBOARD_PORT`).
Attenzione: chiunque arrivi a quella pagina può lanciare i comandi dell'AIOS — va
bene sulla rete dell'ufficio, non su una rete aperta. E perché la cosa funzioni
davvero, la cartella dev'essere **una sola, viva, in un posto sempre acceso** (un
NAS, un server, una VM): non una copia per computer, o tornano i silos.

---

## 6. Aggiornare, riprendere, più macchine

- **Aggiornare il plugin:** `/plugin marketplace update aios`. Se il comando nuovo
  non compare subito, chiudi e riapri Claude Code.
- **Riprendere un AIOS a metà:** riapri Claude nella cartella del cliente e scrivi
  `/aios`. Legge il promemoria `.claude/aios-build.md` e riparte da dove eri.
- **Aggiornare le informazioni** (nuovi numeri, nuovo cliente): rilancia il livello
  giusto (es. `/aios-context` per un cambio strategia, `/refresh-data` per i
  numeri). Le skill capiscono da sole che è un *aggiornamento*, non ricreano tutto.
- **Più computer:** installa il plugin su ognuno (§1). La cartella del cliente la
  sposti/sincronizzi tu come un normale insieme di file (es. cartella cloud o Git
  se usi InfraOS).
- **Più persone sullo stesso AIOS:** è un caso diverso dal precedente. Lì non
  vuoi *copie* sincronizzate ma **una sola cartella viva** in un posto sempre
  acceso, con gli altri che la usano dalla dashboard (§5). Copie per persona =
  silos, cioè il problema che l'AIOS dovrebbe risolvere.

---

## 7. Problemi frequenti (FAQ)

**"Non vedo i comandi `/aios`, `/challenge`…"**
Il plugin non è installato/abilitato in questa finestra. Controlla con `/plugin`.
Se l'hai appena aggiornato, chiudi e riapri Claude Code.

**"Mi dice che manca Python."**
Normale: serve dal Livello 2 in poi. Claude ti dà il comando esatto per la tua
macchina — copia, incolla nel terminale, Invio. Poi riprendi.

**"Ho sbagliato una risposta nell'intervista."**
Diglielo in chat ("correggi: i clienti Premium sono 3, non 2"). In fase di recap,
prima che scriva i file, puoi correggere tutto. Dopo, rilancia `/aios-context` in
modalità aggiornamento.

**"Devo saper programmare?"**
No. Rispondi alle domande e conferma prima che costruisca. Il codice lo scrive lui.

**"I numeri/output degli esempi di questa guida sono reali?"**
No, sono illustrativi per farti vedere il *tipo* di interazione. Il plugin è
giovane: su un caso vero le domande e i file possono variare. Se qualcosa non
torna, dillo a Claude in chat: si adatta.

**"Dove finiscono i miei segreti (password, chiavi API)?"**
In un file `.env` nella cartella, che è escluso dal versionamento (`.gitignore`).
Non vengono condivisi con `/commit`.

**"Posso costruire solo un livello?"**
Sì. Anche solo il Contesto (Livello 1) è utile. Aggiungi gli altri quando vuoi.

**"Il registro `.claude/log.md` si riempie all'infinito?"**
No: a ogni `/prime` Claude controlla se ci sono voci più vecchie di 3 mesi e,
solo in quel caso, ti chiede se archiviarle o eliminarle. Non lo fa mai senza
chiedertelo prima.

**"Se do la dashboard ai miei collaboratori, possono rovinare l'AIOS?"**
No. Non toccano i file: scrivono nel riquadro *Contribuisci* e il resto lo fa
Claude. Quello che aggiungono finisce nelle **lezioni**, mai nel contesto
strategico (chi è l'azienda, la strategia, le procedure) — quello resta tuo. E se
un contributo contraddice qualcosa che l'AIOS già sa, non entra affatto: aspetta te
in coda (§5).

**"Due persone che contribuiscono nello stesso momento si sovrascrivono?"**
No: ogni contributo è una voce in append o un file suo, mai una riscrittura di
quello che c'era. Per questo gli operatori non editano i file a mano — è proprio
lì che nascerebbero i conflitti.

**"Ho aggiornato il plugin: devo rifare qualcosa negli AIOS già costruiti?"**
No. `/contribuisci` e `/rivedi-proposte` arrivano col plugin, e la segnalazione
delle proposte in attesa passa da `/prime` che ce l'ha già. Niente da rigenerare.

---

## 8. Mappa dei file creati

Man mano che costruisci i livelli, nella cartella del cliente compaiono queste
cose (i livelli non fatti semplicemente non esistono):

```
Studio Rossi/                        ← la cartella = l'AIOS del cliente
├── CLAUDE.md                        # chi è l'azienda + istruzioni per Claude
├── history.md                       # diario delle sessioni (se usi InfraOS)
├── .claude/
│   ├── aios-build.md                # promemoria: a che punto è la costruzione
│   ├── log.md                       # registro lavori: cosa è stato fatto e quando
│   ├── aios-feedback-prodotto.md    # frizioni sull'uso di AIOS (per chi sviluppa il plugin)
│   ├── context/                     # azienda, strategia, team, key-metrics,
│   │                                 #   decisioni.md (diagnosi DataPyx), lezioni.md (cose imparate)…
│   └── commands/                    # /prime, /refresh-data, /catchup, /crea-fattura, /dashboard…
├── brand/                           # colori, tipografia, logo, asset
├── data/
│   ├── database.db                  # il database (numeri + riunioni)
│   ├── connectors/                  # script che riempiono il database
│   └── refresh.py
├── automations/
│   ├── roadmap.md                   # elenco automazioni + stato
│   └── <nome>/                      # gli script di ogni automazione
├── enrichment/
│   └── proposals/                   # contributi in disaccordo col contesto, in attesa
│                                      #   che tu li riveda (/rivedi-proposte)
├── dashboard/                       # server.py + index.html (il pannello)
└── .env                             # password e chiavi (mai condiviso)
```

Non devi toccare questi file a mano: li gestisce Claude tramite i comandi. Sapere
che esistono ti aiuta solo a capire *dove* vive il tuo AIOS.

---

> Hai un dubbio che questa guida non copre? Aprilo come *issue* sulla
> [repository](https://github.com/CinaWeb/AIOS-Datapyx), oppure chiedilo
> direttamente a Claude in chat mentre usi il plugin.
