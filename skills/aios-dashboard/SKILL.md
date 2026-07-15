---
name: aios-dashboard
description: Costruisce il livello Controllo (Dashboard) di un AIOS aziendale. Genera nella cartella del cliente una dashboard localhost riepilogativa che mostra lo stato dell'AIOS (metriche chiave, funnel, stato automazioni, ultimi meeting, overview azienda) e offre bottoni per lanciare i comandi/automazioni via Claude Code headless, mostrando l'output in pagina. Condivisibile con collaboratori non tecnici. Usa quando l'utente vuole un pannello di controllo/riepilogo del cliente, o come ultimo livello dopo aver costruito Contesto/Dati/Intelligence/Automazioni.
argument-hint: "Nome cliente (opzionale)"
---

# AIOS — Livello 5: Dashboard (Controllo)

Generi **nella cartella del cliente** una dashboard localhost che riassume lo
stato del suo AIOS e permette di lanciare i comandi con un bottone, senza usare
il terminale. Pensata anche per collaboratori non tecnici. È un artefatto
per-cliente: rispecchia i livelli già costruiti in quella cartella.

Leggi `references/build-guide.md` prima di costruire.

## Flusso

### 1. Rileva lo stato dell'AIOS
Ispeziona la working dir per capire quali livelli esistono (mostra solo ciò che
c'è, ometti il resto):
- `.claude/context/` → overview azienda + `key-metrics.md` (se presente)
- `data/database.db` → funnel/pipeline, tabella `meetings` (se presenti)
- `automations/roadmap.md` → stato automazioni
- `.claude/commands/*.md` → comandi da esporre come bottoni
- **Prereq:** verifica che `claude` sia nel PATH (serve al launcher) e Python
  (`python --version`) per il server. Se `data/database.db` non esiste, salta le
  sezioni che ne dipendono.

### 2. Costruisci la dashboard
Segui `references/build-guide.md`. Crea:

```
dashboard/
  server.py               # server localhost (Python stdlib): serve la pagina + endpoint /run
  index.html              # riepilogo + bottoni comandi (può essere generato dal server)
.claude/commands/
  dashboard.md            # /dashboard → avvia il server e apre il browser
```

- **Riepilogo**: sezioni popolate leggendo i file/DB del cliente (metriche,
  funnel, automazioni, ultimi meeting, overview). Sezioni assenti → omesse.
- **Launcher**: un bottone per ogni comando in `.claude/commands/`. Al click
  esegue `claude -p "<comando>"` nella cartella del cliente e mostra l'output.
- **Sicurezza (non negoziabile):** il server ascolta solo su `127.0.0.1`; il
  campo dei comandi eseguibili è una **allowlist** dei comandi scoperti in
  `.claude/commands/`, mai input arbitrario dall'esterno. Vedi build-guide.

### 3. Avvia e verifica
- Avvia il server (`python dashboard/server.py`), apri `http://127.0.0.1:<porta>`
  e verifica che il riepilogo si popoli.
- Testa **un** bottone (es. `/prime` o `/catchup`) e conferma che l'output
  compaia in pagina.
- Spiega all'utente come avviarla (`/dashboard` o `python dashboard/server.py`) e
  che è condivisibile con collaboratori sulla stessa macchina/rete locale.
- Appendi una riga a `.claude/log.md`:
  `- YYYY-MM-DD · aios-dashboard · Livello 5 Dashboard costruito`.
- Se l'utente usa InfraOS, suggerisci `/commit`.

Contenuti generati per aziende italiane: **in italiano**.
