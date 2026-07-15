---
name: aios-intel
description: Costruisce il livello Intelligence (IntelOS) di un AIOS aziendale. Fa discovery del tool di registrazione meeting (Fireflies, Fathom, Zoom, Google Meet...), ne verifica le API cercandone la documentazione, e crea uno script che raccoglie i transcript delle riunioni in una tabella meetings del database SQLite (lo stesso di DataOS). Auto-classifica i meeting, li rende interrogabili in chat e aggiunge i comandi /collect-meetings e /catchup. Usa quando l'utente vuole portare le riunioni/comunicazioni nell'AIOS, ritrovare decisioni prese nei meeting, o dopo aver costruito i livelli Contesto e Dati.
argument-hint: "Nome azienda (opzionale)"
---

# AIOS — Livello 3: IntelOS (solo meeting)

Porti i transcript delle riunioni dentro l'AIOS, in una tabella interrogabile.
Claude può così ritrovare decisioni prese, action items e con chi hai parlato,
anche a settimane di distanza. Lavori **sulla cartella corrente**.

Workshop di discovery guidato, non installazione muta. Punto chiave: prima di
scegliere un connettore, **cerca la documentazione API** del tool per capire se è
davvero utilizzabile.

Leggi `references/discovery-guide.md` prima dell'intervista e
`references/build-guide.md` prima di costruire.

## Flusso

### 1. Prerequisiti
- **Python.** `python --version`; se manca, guida all'install.
- **Database.** IntelOS usa `data/database.db` di DataOS. Se **non esiste**,
  crealo tu (IntelOS funziona anche standalone). Se esiste già la tabella
  `meetings`, modalità update: non ricreare, aggiungi solo i nuovi.
- **Contesto (opzionale).** Se esiste `.claude/context/`, leggilo per conoscere
  team e persone: aiuta la classificazione e le sintesi.

### 2. Discovery + ricerca API
Segui `references/discovery-guide.md`:
- chiedi **quale tool** usa per registrare i meeting (Fireflies, Fathom, Zoom,
  Google Meet, ClickUp…);
- **cerca la documentazione API** di quel tool (WebSearch/WebFetch): verifica che
  esista un'API per elencare meeting e scaricare transcript, e come si autentica;
- se le API mancano o sono impraticabili, **suggerisci l'alternativa migliore**
  (es. Fireflies) spiegando il perché, e lascia decidere all'utente;
- chiedi la **frequenza di raccolta** (giornaliera tipica).

### 3. Piano
Prima di scrivere codice presenta: tool scelto, schema della tabella `meetings`,
file da creare, e cosa serve in `.env`. Ottieni conferma.

### 4. Costruzione
Segui `references/build-guide.md`. Crea:

```
data/
  database.db                     # tabella meetings (creala se manca)
  connectors/meetings.py          # scarica i transcript nel DB
.claude/commands/
  collect-meetings.md             # /collect-meetings (raccolta on-demand)
  catchup.md                      # /catchup (sintesi meeting recenti)
.env                              # chiave API del tool (git-ignorato)
```

- **Tabella `meetings`**: id, sorgente, titolo, data, ora inizio, durata,
  partecipanti (con email), transcript, riassunto, action items, url, e un campo
  **classificazione** (categorie flessibili: vendite/prodotto/marketing/generale).
- **Segreti** solo in `.env`, senza toccare chiavi esistenti; assicura `.env` in
  `.gitignore`.
- Il connettore deve fallire in modo pulito e non duplicare meeting già presenti
  (dedup per id).

### 5. Comandi + scheduling
- `/collect-meetings`: esegue lo script e riporta quanti meeting nuovi sono
  entrati.
- `/catchup`: interroga i meeting recenti e sintetizza **decisioni prese, action
  items aperti, con chi hai parlato**. Vedi build-guide per il dettaglio.
- **Scheduling:** genera lo script e **spiega** come pianificarlo (Windows Task
  Scheduler / cron), senza toccare lo scheduler di sistema. La raccolta manuale
  resta sempre via `/collect-meetings`.

### 6. Verifica e chiusura
- Esegui una raccolta e mostra i meeting entrati nel DB.
- Fai una **query di prova** (es. "elenca in ordine di priorità le decisioni
  dell'ultimo meeting") per dimostrare l'interrogabilità.
- Ricorda: i meeting NON entrano nel `/prime` (troppo voluminosi); si interrogano
  a voce libera o con `/catchup`.
- Appendi una riga a `.claude/log.md`:
  `- YYYY-MM-DD · aios-intel · Livello 3 Intelligence costruito (connettore <tool>)`.
  Anche `/collect-meetings` appende una riga quando porta nuovi meeting
  significativi (non per ogni singolo meeting).
- Se l'utente usa InfraOS, suggerisci un `/commit`.

Contenuti generati per aziende italiane: **in italiano**.
