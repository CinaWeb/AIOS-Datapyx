---
name: aios-automation
description: Costruisce il livello Automazioni (AutomationOS) di un AIOS aziendale. Fa un audit dei task ripetitivi area per area (marketing, vendite, clienti, finanza, operations, dati) partendo dai file di contesto, produce una roadmap prioritizzata delle opportunità di automazione, e per ognuna chiede se costruirla ora (comando slash + script + eventuali tabelle nel database) o rimandarla come task futuro. Esempio tipico: generazione fatture con numerazione progressiva. Usa quando l'utente vuole automatizzare task operativi, mappare cosa automatizzare, o dopo aver costruito i livelli Contesto/Dati/Intelligence.
argument-hint: "Nome azienda o automazione da creare (opzionale)"
---

# AIOS — Livello 4: AutomationOS

Mappi i task ripetitivi dell'azienda e li trasformi in automazioni richiamabili.
È il livello più su misura: ogni automazione combina i moduli precedenti
(contesto, database, meeting) per snellire un'operatività concreta. Lavori
**sulla cartella corrente**.

Leggi `references/audit-guide.md` prima dell'audit e `references/build-guide.md`
prima di costruire un'automazione.

## Due ingressi

- **Audit → build** (default): mappi le opportunità area per area, poi costruisci
  una automazione alla volta.
- **On-request**: se l'utente (o l'argomento della skill) indica già cosa
  automatizzare, salta l'audit e vai diretto alla costruzione di quella.

## Flusso

### 1. Contesto
Leggi `.claude/context/`. Ti dice di cosa si occupa l'azienda e su quali aree ha
senso automatizzare. Se manca, avvisa che l'audit sarà meno mirato e chiedi se
procedere o costruire prima il contesto (`aios-context`).

### 2. Audit area per area
Segui `references/audit-guide.md`. Per ogni area (marketing, vendite, gestione
clienti, operations, finanza, dati) individua i **task ripetitivi** e le
**opportunità di automazione**. Una domanda alla volta, mai assunzioni.

### 3. Roadmap
Scrivi/aggiorna `automations/roadmap.md`: elenco **prioritizzato** delle
opportunità, ognuna con area, descrizione, valore atteso e **stato**
(`⬜ da fare` / `✅ fatta`). È il documento strategico persistente: se esiste già,
aggiornalo senza perdere le voci precedenti.

### 4. Per ogni automazione — chiedi conferma
Partendo dalla più prioritaria, **chiedi all'utente se costruirla ora**:
- **Sì** → costruiscila (step 5). Al termine marca `✅ fatta` nella roadmap.
- **No** → **salta**, lasciala `⬜ da fare` come task futuro nella roadmap, passa
  alla successiva.
Non costruire nulla senza conferma esplicita.

### 5. Costruzione di una automazione
Segui `references/build-guide.md`. Un'automazione tipicamente è:

```
.claude/commands/<nome>.md     # slash command /<nome> che la lancia
automations/<nome>/*.py        # script di supporto (se serve logica/PDF/API)
data/database.db               # nuove tabelle se l'automazione le richiede
.env                           # segreti eventuali (git-ignorato)
```

- Prima di costruire, fai le **domande di rito** sull'automazione (formato,
  vincoli, on-demand vs schedulata) e presenta l'approccio (librerie, tabelle,
  script). Conferma, poi costruisci.
- Riusa i moduli esistenti: leggi/scrivi il `data/database.db` di DataOS, usa i
  meeting di IntelOS se rilevante.
- Segreti solo in `.env`; assicura `.env` in `.gitignore`.

### 6. Verifica e chiusura
Per ogni automazione costruita fai un **test reale** e mostra l'output (es.
genera una fattura di prova e mostra il PDF/i dati). Aggiorna la roadmap. Se
l'utente usa InfraOS, suggerisci `/commit`.

Contenuti generati per aziende italiane: **in italiano**.
