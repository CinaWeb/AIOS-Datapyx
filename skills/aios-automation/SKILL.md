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

## Disciplina DOE — affidabilità del layer deterministico

Le automazioni sono la **metà deterministica** dell'AIOS: qui l'errore si accumula
(`90% per passo = 59% su 5 passi`). Per questo ogni automazione segue la
**Three-Layer Architecture (DOE)** — l'AIOS la implementa già, questa è la regola
che la rende esplicita:

| Livello DOE | Nell'automazione |
|---|---|
| **Direttiva** (cosa fare) | `.claude/commands/<nome>.md` — la SOP del comando |
| **Orchestrazione** (decidere) | Claude che legge la direttiva, raccoglie input, chiama lo script |
| **Esecuzione** (fare) | `automations/<nome>/*.py` — script **deterministico** |

Due regole non negoziabili che DOE aggiunge:

1. **La business logic deterministica va nello script, mai improvvisata dall'LLM.**
   Numerazioni, calcoli, formattazione PDF, chiamate API, letture/scritture DB →
   sempre codice Python chiamato dal comando. L'LLM decide *cosa* e *con quali
   input*, non *esegue a mano* il lavoro ripetibile. (Automazioni banali di solo
   prompt/lettura DB non hanno script: vedi build-guide.)
2. **Auto-correzione:** se uno script fallisce, correggi lo **script** e aggiorna la
   **direttiva** (il comando) con quello che hai imparato — non aggirare l'errore a
   mano nella chat. Ogni fallimento rende il sistema più robusto. Chiudi con
   `/commit` (InfraOS) così la correzione è versionata.

Il gate epistemologico `/challenge` è il complemento speculare: DOE presidia ciò
che *esegui*, `/challenge` ciò che *giudichi*.

## Flusso

### 1. Contesto
Leggi **tutto** `.claude/context/` e, se esiste, la cartella `brand/` in root
(colori, font, tono di voce) — è top-level, sorella di `.claude/`, non dentro
`context/`. Leggi anche `.claude/context/decisioni.md` se presente (punti di
leva dalla diagnosi DataPyx — orientano quali aree scavare per prime
nell'audit). Ti dice di cosa si
occupa l'azienda, su quali aree ha senso automatizzare e, se già diagnosticata,
dove intervenire con priorità. Se manca, avvisa che l'audit sarà meno mirato e
chiedi se procedere o costruire prima il contesto (`aios-context`).

### 2. Audit area per area
Segui `references/audit-guide.md`. Per ogni area (marketing, vendite, gestione
clienti, operations, finanza, dati) individua i **task ripetitivi** e le
**opportunità di automazione**. Una domanda alla volta, mai assunzioni.

### 3. Roadmap
Scrivi/aggiorna `automations/roadmap.md`: elenco **prioritizzato** delle
opportunità, ognuna con area, descrizione, valore atteso e **stato**
(`⬜ da fare` / `✅ fatta`). È il documento strategico persistente: se esiste già,
aggiornalo senza perdere le voci precedenti. Il file inizia con frontmatter
`created:`/`updated:` (stessa convenzione di `aios-context`); aggiorna
`updated:` ad ogni modifica della roadmap.

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
genera una fattura di prova e mostra il PDF/i dati). Se il test fallisce, applica
l'**auto-correzione DOE**: correggi lo script e aggiorna la direttiva (il comando),
poi ri-testa — non aggirare il problema a mano. Aggiorna la roadmap (`updated:`
incluso). Appendi una riga a `.claude/log.md`:
`- YYYY-MM-DD · aios-automation · Automazione /<nome> costruita e testata`.
Se l'utente usa InfraOS, suggerisci `/commit` per versionare automazione e
correzioni.

Contenuti generati per aziende italiane: **in italiano**.
