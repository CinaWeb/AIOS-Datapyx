# AIOS — plugin Claude Code

Costruisce un **AI Operating System** personalizzato per un'azienda/cliente,
livello per livello, direttamente in Claude Code. Trasforma Claude da assistente
generico in un'AI che conosce a fondo un business: chi è, come si presenta (brand),
i suoi numeri, le sue riunioni e le sue automazioni operative.

Ispirato al framework AIOS a 5 livelli: **Contesto → Dati → Intelligence →
Automazioni → Controllo**.

---

## Indice
- [Cosa contiene](#cosa-contiene)
- [Installazione](#installazione)
- [Guida d'uso](#guida-duso)
  - [Avvio: costruire l'AIOS di un cliente](#avvio-costruire-laios-di-un-cliente)
  - [I 5 livelli, uno per uno](#i-5-livelli-uno-per-uno)
  - [Flusso operativo quotidiano](#flusso-operativo-quotidiano)
  - [Le due discipline: DOE e /challenge](#le-due-discipline-doe-e-challenge)
- [Memoria persistente](#memoria-persistente)
- [Cosa viene creato nella cartella del cliente](#cosa-viene-creato-nella-cartella-del-cliente)
- [Aggiornare il plugin](#aggiornare-il-plugin)
- [Origine delle skill](#origine-delle-skill)

---

## Cosa contiene

**9 skill + 1 motore interno (`aios-learn`) + 6 comandi (`/challenge`, `/aios-help`, `/debrief`, `/client-brief`, `/contribuisci`, `/rivedi-proposte`).** Entry point:
- **`aios`** — orchestratore: rileva lo stato, mantiene una checklist persistente
  (`.claude/aios-build.md`) e un registro lavori trasversale (`.claude/log.md`),
  esegue i 5 livelli in ordine invocando le skill sotto.

I 5 livelli:
1. **`aios-context`** — Contesto + Brand
2. **`aios-data`** — Dati (metriche → database)
3. **`aios-intel`** — Intelligence (meeting)
4. **`aios-automation`** — Automazioni operative
5. **`aios-dashboard`** — Dashboard di controllo

Diagnostica trasversale:
- **`datapyx`** — DataPyx Market Intelligence Assistant: diagnostico sistemico
  per consulenti (problema reale, punti di leva, scenari, monitoraggio). Non è un
  livello di build: è il cuore analitico, offerto dopo il Contesto e ripetibile.
  Salva la sintesi in `.claude/context/decisioni.md`, che `/prime` ricarica nelle
  sessioni successive e che `aios-automation` legge per prioritizzare l'audit.
  Include il gate epistemologico **`/challenge`** (vedi sotto).

Gate epistemologico:
- **`/challenge`** — agente *Cognitos*: sottopone una diagnosi/decisione/tesi a
  red-team (contro-argomento più forte, assunzioni fragili, scenario di fallimento,
  verdetto + confidenza). È il presidio di rigore della **metà probabilistica**
  dell'AIOS, speculare alla disciplina **DOE** che rende affidabile la metà
  **deterministica** (le automazioni). Gate on-demand per decisioni ad alta posta.

Motore interno (non esposto come comando):
- **`aios-learn`** — apprendimento dell'AIOS: trasforma correzioni ed errori in
  regole permanenti per quel cliente (`.claude/context/lezioni.md`, letto da
  `/prime`) o in feedback di processo sul prodotto
  (`.claude/aios-feedback-prodotto.md`, per il maintainer), e ad ogni `/prime`
  genera **prospettive proattive**. Invocato internamente da `challenge`,
  `debrief`, `datapyx`, dai livelli e da `/prime` — in sessione non scrive mai in
  silenzio (chiede sempre conferma).

Arricchimento multi-operatore:
- **`/contribuisci`** — un operatore (dalla dashboard, headless) invia un fatto o
  una regola vista sul campo. `aios-learn` lo classifica e lo confronta con quello
  che l'AIOS già sa (core strategico + lezioni): se **non contraddice** entra da
  solo in `.claude/context/lezioni.md`, con autore e data; se **contraddice**
  finisce in `enrichment/proposals/`, senza toccare niente.
- **`/rivedi-proposte`** — il curatore rivede la coda dei contraddittori:
  promuovi / rifiuta / riformula. È l'unico punto dell'**arricchimento** dove
  serve un umano: il resto fluisce. `/prime` segnala quante proposte sono in
  attesa.

Il core strategico (`azienda.md`, `strategia.md`, `procedure.md`) resta
scrivibile **solo dal curatore**: l'arricchimento automatico atterra sempre sullo
strato lezioni, che è progettato per crescere.

Dipendenze di brand (incluse per self-containment):
- **`client-project-kickoff`** — scaffolding + brand identity (estrae da sito o
  **crea da zero via brandkit**)
- **`brandkit`** — generazione premium di logo/palette/tipografia/brand-board

### Grafo dipendenze
```
aios → aios-context, aios-data, aios-intel, aios-automation, aios-dashboard
aios-context → client-project-kickoff → brandkit
aios ─(offre dopo il Contesto)→ datapyx   [diagnostica trasversale, ripetibile]
challenge, debrief, datapyx, i 5 livelli, /prime ─→ aios-learn   [motore interno]
/contribuisci, /rivedi-proposte ─→ aios-learn   [modalità operatore, async]
```
Le skill si richiamano **per nome/descrizione**: funzionano anche namespaced come
`aios:aios-context`.

---

## Installazione

Su qualsiasi macchina con Claude Code, dopo aver pubblicato questa repo su GitHub:

```
/plugin marketplace add CinaWeb/AIOS-Datapyx
/plugin install aios@aios
```

Funziona sia da **CLI** sia dall'**app desktop** di Claude Code (stesso sistema
di plugin).

**Verifica:** `/plugin` → il plugin `aios` deve risultare installato e abilitato.
Le skill compaiono come `aios`, `aios-context`, … (o namespaced `aios:*`).

### Installazione su Cowork (uso personale)

1. Apri il menu **Customize** nella sidebar di Claude.
2. Vai al tab **Plugins**.
3. In **Personal plugins**, clicca **"+" → Add marketplace**.
4. Scegli **Add from a repository** e incolla `CinaWeb/AIOS-Datapyx` (o l'URL
   completo `https://github.com/CinaWeb/AIOS-Datapyx`).
5. Una volta sincronizzato, cerca il plugin **aios** nel catalogo e clicca
   **Install**.

Le skill (`aios`, `aios-context`, `datapyx`, ecc.) compariranno digitando `/`
o cliccando **"+"** in chat/Cowork.

**Prerequisiti** (installati/verificati dalle skill quando servono):
- Python 3 — per i livelli Dati, Intelligence, Automazioni, Dashboard
- Git + (opzionale) GitHub CLI `gh` — per InfraOS (versionamento dell'AIOS)
- `claude` nel PATH — per il launcher della dashboard

---

## Guida d'uso

> 📖 **Sei alle prime armi o non hai mai usato un terminale?** C'è una
> [**guida d'uso dettagliata passo-passo**](GUIDE.md) che costruisce un AIOS
> d'esempio ("Studio Rossi") dall'inizio alla fine. Questa sezione è il riassunto.
> Dentro Claude Code, il comando **`/aios-help`** dà lo stesso orientamento (e
> `/aios-help <tema>` va dritto a un argomento, es. `/aios-help dati`).

### Avvio: costruire l'AIOS di un cliente

1. **Crea una cartella dedicata al cliente** e aprici Claude Code:
   ```
   mkdir "Cliente Rossi" && cd "Cliente Rossi"
   claude
   ```
   Tutte le skill lavorano **sulla cartella corrente**: quella cartella *è*
   l'AIOS di quel cliente.

2. **Invoca l'orchestratore:**
   ```
   /aios "Cliente Rossi"
   ```
   `aios` rileva a che punto sei, mostra la checklist e ti guida livello per
   livello, chiedendo conferma prima di ognuno. Puoi fermarti quando vuoi e
   riprendere in un'altra sessione: rilancia `/aios` e riparte da dove eri.

> Puoi anche invocare i singoli livelli direttamente (es. `/aios-data`) se ti
> serve solo quello: ogni skill funziona standalone e in modalità update.

### I 5 livelli, uno per uno

**1 · Contesto + Brand — `aios-context`**
Intervista guidata (o import di documenti/testo: sito, LinkedIn, brief) per
capire azienda, ruolo, strategia e numeri. Genera i file di contesto, un
`CLAUDE.md` su misura e il comando `/prime`. Cattura anche l'**identità di brand**
(colori, tipografia, logo, stack): la estrae da un sito esistente o la **crea da
zero** con brandkit. Opzionale: **InfraOS** (Git/GitHub, `/commit`, `history.md`).

**2 · Dati — `aios-data`**
Discovery delle sorgenti (Google Sheet, CSV, CRM, API…). Crea un database SQLite
locale, gli script per popolarlo e un `key-metrics.md` autogenerato (che `/prime`
carica ogni sessione). Aggiunge `/refresh-data` per aggiornare le metriche.

**3 · Intelligence — `aios-intel`**
Collega il tool di registrazione meeting (Fireflies, Fathom, Zoom…): ne verifica
le API, scarica i transcript in una tabella interrogabile. Comandi
`/collect-meetings` e `/catchup` (sintesi di decisioni, action item, con chi hai
parlato). Interroghi le riunioni a voce libera: *"cosa è stato deciso lunedì?"*

**4 · Automazioni — `aios-automation`**
Audit dei task ripetitivi area per area → `automations/roadmap.md` prioritizzata.
Per ogni automazione ti chiede se costruirla ora (comando + script + tabelle) o
rimandarla come task futuro. Esempio: generazione fatture con numerazione
progressiva. Ogni automazione segue la disciplina **DOE** (direttiva = comando,
orchestrazione = Claude, esecuzione = script deterministico) con auto-correzione:
la logica ripetibile sta nello script, non improvvisata dall'LLM.

**5 · Dashboard — `aios-dashboard`**
Pannello localhost riepilogativo del cliente: metriche, funnel, stato automazioni,
ultimi meeting — più bottoni che lanciano i comandi e mostrano l'output.
Condivisibile con collaboratori non tecnici. Avvio con `/dashboard`.

### Flusso operativo quotidiano

Una volta costruito l'AIOS, il lavoro di tutti i giorni nella cartella del cliente:

| Quando | Comando | Cosa fa |
|---|---|---|
| Inizio sessione | `/prime` | Carica contesto + metriche chiave |
| Prima di una call | `/client-brief <cliente>` | Brief pre-call: timeline, promesse vs consegne, pendenze, agenda |
| Aggiornare i dati | `/refresh-data` | Riscarica le metriche nel database |
| Aggiornare le riunioni | `/collect-meetings` | Scarica i nuovi meeting |
| Riprendere il filo | `/catchup` | Sintesi meeting recenti (decisioni, action item) |
| Diagnosi/monitoraggio sfida | `datapyx` | Diagnostico sistemico: problema reale, leve, scenari, monitoraggio |
| Sfidare una diagnosi/decisione | `/challenge` | Gate epistemologico: red-team + verdetto, prima di agire su una scelta ad alta posta |
| Automazioni | `/<nome-automazione>` | Es. `/crea-fattura` |
| Pannello | `/dashboard` | Apre la dashboard localhost |
| Fine sessione | `/debrief` | Consolida i progressi del giorno nel contesto + `history.md` |
| Salvare/versionare | `/commit` | Salva e versiona l'AIOS (se InfraOS attivo) |

### Le due discipline: DOE e /challenge

Un AIOS ha due metà con rischi opposti, e una disciplina per ciascuna:

```
              AIOS (5 livelli)
        ┌───────────┴───────────┐
   metà DETERMINISTICA     metà PROBABILISTICA
   (Automazioni)           (Contesto · Intelligence · DataPyx)
        │                       │
      [ DOE ]              [ /challenge ]
   affidabilità            rigore del
   dell'esecuzione         giudizio
```

- **DOE — affidabilità di ciò che *esegui*.** Ogni automazione segue la
  Three-Layer Architecture: **direttiva** (il comando/SOP) → **orchestrazione**
  (Claude decide e chiama) → **esecuzione** (script Python deterministico). La
  logica ripetibile — numerazioni, calcoli, PDF, API, DB — sta nello script, mai
  improvvisata dall'LLM (taglia l'accumulo d'errore sui passi concatenati). Se uno
  script fallisce, si corregge **script + direttiva** e si ri-testa: ogni errore
  rende il sistema più robusto. Vive in `aios-automation`.

- **`/challenge` — rigore di ciò che *giudichi*.** Un gate epistemologico (agente
  *Cognitos*) che fa **red-team** di una diagnosi o decisione prima di agirci:
  costruisce il contro-argomento più forte, isola le assunzioni fragili, descrive
  lo scenario di fallimento, chiude con un **verdetto** (🟢 regge / 🟡 da rinforzare
  / 🔴 da rivedere / ⚪ ambiguo) e una confidenza. È **on-demand** — per decisioni
  ad alta posta o diagnosi a confidenza Media/Ipotesi, non su ogni frase. `datapyx`
  lo propone dopo la diagnosi (FASE 4) e nel pre-mortem.

Le due sono speculari: DOE evita l'errore di *esecuzione*, `/challenge` l'errore di
*giudizio confidente*.

---

## Memoria persistente

Tre meccanismi trasversali, indipendenti da InfraOS/Git, tengono l'AIOS coerente
tra una sessione e l'altra:

- **`.claude/log.md`** — registro cronologico append-only: ogni skill vi aggiunge
  una riga (`YYYY-MM-DD · skill · lavoro completato`) quando finisce un'unità di
  lavoro. Non è lo stato (quello è `.claude/aios-build.md`), è la cronologia di
  cosa è successo. `/prime` ne controlla la voce più vecchia a ogni sessione: oltre
  i **3 mesi**, propone di archiviarla in `.claude/log-archivio.md` o eliminarla —
  mai in automatico.
- **Frontmatter datato** — ogni file di stato/conoscenza (`.claude/context/*.md`,
  `brand/*.md`, `automations/roadmap.md`, `.claude/aios-build.md`) porta in testa
  `created:`/`updated:` in YAML, aggiornati dalla skill che lo scrive.
- **Apprendimento (`aios-learn`)** — le correzioni ripetute diventano regole
  permanenti in `.claude/context/lezioni.md` (lette da `/prime`); le frizioni sul
  prodotto vanno in `.claude/aios-feedback-prodotto.md` (revisione del maintainer,
  mai promosse automaticamente). Ad ogni `/prime`, `aios-learn` propone anche
  **prospettive proattive** — angoli nuovi e rischi non ancora nominati, distinti
  dai fatti. In sessione ogni cattura chiede conferma: mai scrittura silenziosa.
  Con più operatori il gate si sposta (vedi sotto).

**Più operatori, un solo cervello.** Quando l'AIOS è condiviso, gli operatori lo
arricchiscono da `/contribuisci` (bottone della dashboard) senza mai editare file
a mano. In quella modalità nessuno è presente a confermare, quindi la conferma si
sposta dalle scritture alle sole **contraddizioni**: il contributo che non
contraddice il core entra da solo nelle lezioni con autore e data, quello che lo
contraddice va in `enrichment/proposals/` e aspetta il curatore
(`/rivedi-proposte`). Un file per contributo, mai una scrittura concorrente sullo
stesso file.

**Deployment.** Il design non sceglie l'host (NAS, server aziendale, VM): serve
solo che qualcuno faccia da **storage** (una copia viva della cartella + snapshot)
e da **compute** (processo always-on che serve la dashboard in rete). Backup a due
livelli complementari: snapshot filesystem per il disaster recovery, git sotto
`/commit` per rollback logico e attribuzione. La dashboard di default resta su
`127.0.0.1`: l'apertura in LAN è opt-in (`AIOS_DASHBOARD_HOST`).

Questi tre pezzi mappano la "memoria episodica" (log), la "memoria semantica"
(contesto datato) e la "memoria procedurale" (lezioni apprese via `aios-learn`) di
un'architettura di memoria per agenti AI a più livelli — il resto (working memory,
skill) lo gestisce Claude Code nativamente.

---

## Cosa viene creato nella cartella del cliente

```
<cartella-cliente>/
├── CLAUDE.md                       # identità azienda, import brand, istruzioni
├── history.md                      # diario sessioni (se InfraOS)
├── .claude/
│   ├── aios-build.md               # stato costruzione (checklist, con created:/updated:)
│   ├── log.md                      # registro lavori trasversale (per-skill, con data)
│   ├── aios-feedback-prodotto.md   # frizioni di processo su AIOS (per il maintainer)
│   ├── context/                    # azienda, personale, strategia, key-metrics,
│   │                                #   decisioni.md (DataPyx), lezioni.md (aios-learn) — con created:/updated:
│   └── commands/                   # /prime, /refresh-data, /catchup, /dashboard, …
├── brand/                          # brand-identity, colors, typography, logo, assets/ — idem
├── data/
│   ├── database.db                 # SQLite: pipeline, meetings, clienti…
│   ├── connectors/                 # script per sorgente
│   └── refresh.py
├── automations/
│   ├── roadmap.md                  # opportunità + stato (con created:/updated:)
│   └── <nome>/                     # script delle automazioni
├── enrichment/
│   └── proposals/                  # contributi in contraddizione col contesto, in attesa
│                                     #   del curatore (/rivedi-proposte) — un file per proposta
├── dashboard/                      # server.py + index.html
└── .env                            # chiavi API/segreti (git-ignorato)
```
Le sezioni compaiono man mano che costruisci i livelli: quelle dei livelli non
ancora fatti semplicemente non esistono.

---

## Aggiornare il plugin

Il plugin è condiviso (installato da più persone via Claude Cowork), quindi
le modifiche vanno rilasciate via **pull request**, non push diretto su
`main`: Cowork sincronizza automaticamente la marketplace solo quando una PR
che include un bump di versione viene mergiata su `main` — un push diretto
non triggera il sync, e chi ha già installato il plugin resta bloccato sulla
versione vecchia anche disinstallando/reinstallando.

```
git checkout -b feat/nome-modifica
# modifica le skill in skills/, poi bump di version in .claude-plugin/plugin.json
git add -A && git commit -m "…"
git push -u origin feat/nome-modifica
gh pr create --fill
# merge della PR su main → Cowork risincronizza da solo (fino a 30 min)
```

Se serve un aggiornamento immediato senza aspettare: Cowork →
*Organization settings → Plugins → aios → Update*.

Su Claude Code CLI (non Cowork), l'update resta manuale su ogni macchina:
```
/plugin marketplace update aios
```

---

## Origine delle skill

- `aios*` — create per questo plugin (2026-07).
- `client-project-kickoff` — skill personale preesistente, estesa qui con il
  percorso di *creazione* brand via brandkit e il file `brand/logo.md`.
- `brandkit` — copia della skill personale (originariamente in
  `~/.agents/skills/brandkit`), inclusa per rendere il plugin autonomo.

> Nota: le skill sono scritte ma non ancora collaudate end-to-end. Per provarle,
> apri Claude Code in una cartella-azienda di prova e lancia `/aios`.
