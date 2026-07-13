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
- [Cosa viene creato nella cartella del cliente](#cosa-viene-creato-nella-cartella-del-cliente)
- [Aggiornare il plugin](#aggiornare-il-plugin)
- [Origine delle skill](#origine-delle-skill)

---

## Cosa contiene

**8 skill.** Entry point:
- **`aios`** — orchestratore: rileva lo stato, mantiene una checklist persistente
  (`.claude/aios-build.md`), esegue i 5 livelli in ordine invocando le skill sotto.

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

Dipendenze di brand (incluse per self-containment):
- **`client-project-kickoff`** — scaffolding + brand identity (estrae da sito o
  **crea da zero via brandkit**)
- **`brandkit`** — generazione premium di logo/palette/tipografia/brand-board

### Grafo dipendenze
```
aios → aios-context, aios-data, aios-intel, aios-automation, aios-dashboard
aios-context → client-project-kickoff → brandkit
aios ─(offre dopo il Contesto)→ datapyx   [diagnostica trasversale, ripetibile]
```
Le skill si richiamano **per nome/descrizione**: funzionano anche namespaced come
`aios:aios-context`.

---

## Installazione

Su qualsiasi macchina con Claude Code, dopo aver pubblicato questa repo su GitHub:

```
/plugin marketplace add <tuo-user>/aios-plugin
/plugin install aios@aios
```

Sostituisci `<tuo-user>/aios-plugin` con lo slug/URL della tua repo GitHub.

**Verifica:** `/plugin` → il plugin `aios` deve risultare installato e abilitato.
Le skill compaiono come `aios`, `aios-context`, … (o namespaced `aios:*`).

**Prerequisiti** (installati/verificati dalle skill quando servono):
- Python 3 — per i livelli Dati, Intelligence, Automazioni, Dashboard
- Git + (opzionale) GitHub CLI `gh` — per InfraOS (versionamento dell'AIOS)
- `claude` nel PATH — per il launcher della dashboard

---

## Guida d'uso

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
progressiva.

**5 · Dashboard — `aios-dashboard`**
Pannello localhost riepilogativo del cliente: metriche, funnel, stato automazioni,
ultimi meeting — più bottoni che lanciano i comandi e mostrano l'output.
Condivisibile con collaboratori non tecnici. Avvio con `/dashboard`.

### Flusso operativo quotidiano

Una volta costruito l'AIOS, il lavoro di tutti i giorni nella cartella del cliente:

| Quando | Comando | Cosa fa |
|---|---|---|
| Inizio sessione | `/prime` | Carica contesto + metriche chiave |
| Aggiornare i dati | `/refresh-data` | Riscarica le metriche nel database |
| Aggiornare le riunioni | `/collect-meetings` | Scarica i nuovi meeting |
| Riprendere il filo | `/catchup` | Sintesi meeting recenti (decisioni, action item) |
| Diagnosi/monitoraggio sfida | `datapyx` | Diagnostico sistemico: problema reale, leve, scenari, monitoraggio |
| Automazioni | `/<nome-automazione>` | Es. `/crea-fattura` |
| Pannello | `/dashboard` | Apre la dashboard localhost |
| Fine sessione | `/commit` | Salva e versiona l'AIOS (se InfraOS attivo) |

---

## Cosa viene creato nella cartella del cliente

```
<cartella-cliente>/
├── CLAUDE.md                       # identità azienda, import brand, istruzioni
├── history.md                      # diario sessioni (se InfraOS)
├── .claude/
│   ├── context/                    # azienda, personale, strategia, key-metrics…
│   └── commands/                   # /prime, /refresh-data, /catchup, /dashboard, …
├── brand/                          # brand-identity, colors, typography, logo, assets/
├── data/
│   ├── database.db                 # SQLite: pipeline, meetings, clienti…
│   ├── connectors/                 # script per sorgente
│   └── refresh.py
├── automations/
│   ├── roadmap.md                  # opportunità + stato
│   └── <nome>/                     # script delle automazioni
├── dashboard/                      # server.py + index.html
└── .env                            # chiavi API/segreti (git-ignorato)
```
Le sezioni compaiono man mano che costruisci i livelli: quelle dei livelli non
ancora fatti semplicemente non esistono.

---

## Aggiornare il plugin

Modifica le skill in `skills/`, poi:
```
# bump della versione in .claude-plugin/plugin.json, quindi:
git add -A && git commit -m "…" && git push
```
Sulle altre macchine:
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
