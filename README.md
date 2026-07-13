# AIOS — plugin Claude Code

Costruisce un **AI Operating System** personalizzato per un'azienda/cliente,
livello per livello, direttamente in Claude Code. Ispirato al framework AIOS a 5
livelli (Contesto, Dati, Intelligence, Automazioni, Controllo).

## Cosa contiene (8 skill)

Entry point:
- **`aios`** — orchestratore: rileva lo stato, mantiene una checklist persistente
  (`.claude/aios-build.md`), esegue i 5 livelli in ordine invocando le skill sotto.

I 5 livelli:
1. **`aios-context`** — Contesto: intervista → `.claude/context/`, `CLAUDE.md`,
   `/prime`. Include Brand/Design (via `client-project-kickoff`) e InfraOS
   opzionale (Git/GitHub, `/commit`, `history.md`).
2. **`aios-data`** — Dati: sorgenti → SQLite `data/database.db`, `refresh.py`,
   `key-metrics.md`, `/refresh-data`.
3. **`aios-intel`** — Intelligence (meeting): tabella `meetings`,
   `/collect-meetings`, `/catchup`.
4. **`aios-automation`** — Automazioni: audit → `automations/roadmap.md` →
   automazioni (comando + script + tabelle).
5. **`aios-dashboard`** — Controllo: dashboard localhost (riepilogo + launcher).

Dipendenze di brand (incluse per self-containment):
- **`client-project-kickoff`** — scaffolding progetto + brand identity (estrae da
  sito esistente o **crea da zero via `brandkit`**).
- **`brandkit`** — generazione premium di logo/palette/tipografia/brand-board.

### Grafo dipendenze
```
aios → aios-context, aios-data, aios-intel, aios-automation, aios-dashboard
aios-context → client-project-kickoff → brandkit
```
Le skill si richiamano **per nome/descrizione**, quindi restano valide anche
namespaced come `aios:aios-context`.

## Installazione su una macchina nuova

```
/plugin marketplace add <tuo-user>/aios-plugin
/plugin install aios@aios
```
(sostituisci `<tuo-user>/aios-plugin` con l'URL/slug della repo GitHub dove
pubblichi questo bundle.)

Poi, nella cartella di un cliente, invoca la skill **aios** per partire.

## Origine delle skill

- `aios*` — create per questo plugin (2026-07).
- `client-project-kickoff` — skill personale preesistente, estesa qui con il
  percorso di *creazione* brand via brandkit e il file `brand/logo.md`.
- `brandkit` — copia della skill personale (originariamente in
  `~/.agents/skills/brandkit`), inclusa per rendere il plugin autonomo.

## Aggiornare il plugin

Modifica le skill in `skills/`, bump `version` in `.claude-plugin/plugin.json`,
commit e push. Sulle altre macchine: `/plugin marketplace update aios` +
reinstalla se necessario.

> Nota: le skill sono scritte ma non ancora collaudate end-to-end. Per provarle,
> apri Claude Code in una cartella-azienda di prova e lancia `aios`.
