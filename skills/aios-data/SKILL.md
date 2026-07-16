---
name: aios-data
description: Costruisce il livello Dati (DataOS) di un AIOS aziendale. Fa discovery guidata delle sorgenti dati (Google Sheet, CSV, CRM, API), crea un database SQLite locale, script di connessione per sorgente e un refresh che rigenera un key-metrics.md autogenerato (letto dal comando /prime del livello Contesto). Aggiunge un comando /refresh-data on-demand e istruzioni per schedulare l'aggiornamento. Usa quando l'utente vuole collegare le metriche/dati della sua azienda all'AIOS, tracciare numeri chiave (fatturato, clienti, conversion rate), o dopo aver costruito il livello Contesto con aios-context.
argument-hint: "Nome azienda (opzionale)"
---

# AIOS — Livello 2: DataOS

Colleghi a Claude i dati reali dell'azienda. Ogni volta che si apre una sessione
(via `/prime`) Claude sa qual è lo stato attuale dei numeri e può interrogare il
database per analisi e rielaborazioni. Lavori **sulla cartella corrente**.

Questo è un **workshop di discovery guidato**, non un'installazione muta:
intervista, suggerisci, presenta un piano, poi costruisci.

Leggi `references/discovery-guide.md` prima dell'intervista e
`references/build-guide.md` prima di generare schema e script.

## Flusso

### 1. Prerequisiti
- **Contesto (Livello 1).** Verifica che esista `.claude/context/`. Se manca,
  avvisa che DataOS lavora meglio dopo `aios-context` e chiedi se procedere lo
  stesso o costruire prima il contesto. Se esiste, **leggi i file di contesto**
  (soprattutto `strategia.md` e `dati-correnti.md`): dicono quali metriche
  contano davvero per questa azienda.
- **Python.** `python --version` (o `python3`). Se manca, guida all'install per
  l'OS dell'utente (Windows: `winget install Python.Python.3.13`).
- **Modalità update.** Se esiste già `data/database.db`, non ricostruire: leggi
  lo schema esistente e chiedi cosa aggiungere/cambiare.

### 2. Discovery
Segui `references/discovery-guide.md`. Per ogni metrica che conta:
- chiedi **dove vive il dato** (Google Sheet, CSV, CRM, gestionale, pagamenti…);
- scegli **caso per caso** l'approccio: import Sheet/CSV, inserimento manuale via
  comando, oppure connettore API **solo se** la sorgente lo supporta e l'utente
  ha già le chiavi;
- copri il funnel: top (come ti trovano) / middle (come interagiscono) / bottom
  (come e quando convertono).
Non dare per scontate le sorgenti: chiedi.

### 3. Piano
Prima di scrivere codice, presenta:
- l'elenco delle **sorgenti** e per ognuna l'approccio scelto;
- lo **schema del database** (tabelle e colonne) derivato dalle metriche reali;
- i **file** che creerai.
Ottieni conferma.

### 4. Costruzione
Segui `references/build-guide.md`. Crea nella working dir:

```
data/
  database.db            # SQLite
  connectors/<sorgente>.py   # uno per sorgente
  refresh.py             # aggrega tutte le sorgenti → DB → rigenera key-metrics.md
.claude/
  context/key-metrics.md     # AUTOGENERATO — non modificarlo a mano
  commands/refresh-data.md   # comando /refresh-data
.env                     # chiavi API/segreti (git-ignorato)
```

- **Schema flessibile**, non fisso: modella le tabelle sulle metriche emerse.
- **Segreti** solo in `.env`. Mai chiavi API in file committati, nel DB o nel
  contesto. Se non esiste, crea/aggiorna `.gitignore` con `.env`.
- **key-metrics.md** è rigenerato da `refresh.py` a partire dal DB: contiene le
  metriche chiave in forma leggibile. Il `/prime` del Livello 1 lo carica già.
  `refresh.py` scrive/aggiorna anche il frontmatter (`created:` la prima
  volta, `updated:` ad ogni rigenerazione — stessa convenzione di
  `aios-context`).

### 5. Refresh
- `refresh.py`: esegue tutti i connettori, aggiorna il DB, **rigenera
  key-metrics.md**.
- Comando `/refresh-data` (in `.claude/commands/`): esegue `refresh.py`
  on-demand.
- **Scheduling:** genera lo script e **spiega** come schedularlo (Windows Task
  Scheduler / cron su Mac) senza toccare lo scheduler di sistema. Vedi
  build-guide.

### 6. Verifica e chiusura
- Esegui `refresh.py` una volta e mostra il `key-metrics.md` risultante come
  prova che la pipeline funziona.
- Fai una query di esempio sul DB (es. crescita % del fatturato mese su mese) per
  dimostrare che Claude può interrogare i dati.
- Ricorda all'utente: `/prime` a inizio sessione carica anche le metriche;
  `/refresh-data` quando vuole aggiornarle.
- Appendi una riga a `.claude/log.md`:
  `- YYYY-MM-DD · aios-data · Livello 2 Dati costruito (N sorgenti)` (o, per un
  refresh con cambi di schema, una riga equivalente).
- Se l'utente usa InfraOS (Livello 1), suggerisci un `/commit`.

Contenuti generati per aziende italiane: **in italiano**.

## Feedback di processo

Se durante questo livello l'utente segnala che **una domanda o uno step è
superfluo, confuso o sbagliato** (attrito nell'uso di AIOS, non un fatto sul suo
business), **invoca la skill `aios-learn`**: registra la frizione in
`.claude/aios-feedback-prodotto.md` per la revisione del maintainer. `aios-learn`
classifica e chiede conferma prima di scrivere — non è una lezione di business e
non va in `lezioni.md`.
