# Guida alla costruzione — Dashboard

Come generare la dashboard riepilogativa per-cliente. Stack: **Python stdlib**
(`http.server` + `subprocess`), zero dipendenze, cross-platform. Se l'utente
preferisce Node, adatta di conseguenza mantenendo gli stessi principi.

## server.py
Un piccolo server HTTP che:
1. **Serve la pagina** (`GET /`) — HTML con le sezioni di riepilogo e i bottoni.
   Puoi generare l'HTML lato server leggendo lo stato ad ogni load, così i dati
   sono sempre freschi.
2. **Espone lo stato** (opzionale `GET /state` in JSON) — metriche, funnel,
   automazioni, ultimi meeting.
3. **Esegue i comandi** (`POST /run`) — riceve un identificativo di comando,
   verifica che sia nell'**allowlist**, esegue `claude -p "<comando>"` nella
   working dir del cliente con `subprocess`, ritorna stdout/stderr.

### Sicurezza (obbligatoria)
- **Bind su `127.0.0.1` di default**, mai `0.0.0.0` come default. L'apertura in
  rete è **opt-in esplicito** di chi avvia il server, non una scelta tua:
  ```python
  host = os.environ.get("AIOS_DASHBOARD_HOST", "127.0.0.1")
  port = int(os.environ.get("AIOS_DASHBOARD_PORT", "8787"))
  ```
  Se `host` non è `127.0.0.1`, stampa all'avvio una riga che avvisa che la
  dashboard è raggiungibile in rete e che chiunque la raggiunga può lanciare i
  comandi dell'AIOS. Nessuna autenticazione: il perimetro è la rete (LAN
  aziendale), non il server.
- **Allowlist**: costruisci la lista dei comandi leggendo `.claude/commands/*.md`
  all'avvio, e aggiungi **`/contribuisci`** solo se costruisci il blocco
  Contribuisci (comando plugin-level: non sta in `.claude/commands/` ma è
  eseguibile da `claude -p` perché il plugin è installato). `/run` accetta **solo**
  un indice/nome presente in quella lista. Non
  passare mai a shell input libero dell'utente come comando. Se aggiungi un campo
  follow-up, invialo come **argomento/prompt** a `claude -p` (che è l'AI del
  cliente), non concatenato in una shell: usa `subprocess.run([...], shell=False)`
  con lista di argomenti, mai `shell=True`.
- Scegli una porta locale libera (es. 8787) e comunicala.

### Blocco "Contribuisci" (dashboard condivisa)
Se il cliente ha più operatori (vedi SKILL.md §2b):
- campo **operatore** ("chi sei", salvato in `localStorage`, non richiesto ogni
  volta) + **textarea** del contributo;
- al submit: `subprocess.run(["claude", "-p", f"/contribuisci {operatore}: {testo}"],
  cwd=..., shell=False)`. Il testo dell'operatore resta un **argomento**, mai
  concatenato in una shell;
- mostra l'output in pagina: l'operatore deve vedere se il contributo è stato
  promosso o messo in coda, altrimenti scrive nel vuoto.

### Esecuzione comando
`subprocess.run(["claude", "-p", comando], cwd=<working_dir>, capture_output=True,
text=True, timeout=...)`. Claude Code eredita `CLAUDE.md` e i comandi del
progetto dalla working dir. Gestisci timeout ed errori mostrando un messaggio
chiaro in pagina, senza far crashare il server.

## index.html (sezioni di riepilogo)
Leggi le fonti già prodotte dagli altri livelli; ometti le sezioni assenti:
- **Overview azienda** — da `.claude/context/azienda.md` / `personale.md`
- **Metriche chiave** — da `.claude/context/key-metrics.md` (DataOS)
- **Funnel / pipeline** — query su `data/database.db` (tabella pipeline)
- **Automazioni** — da `automations/roadmap.md`: elenco con stato ✅/⬜
- **Ultimi meeting** — query sulla tabella `meetings` (IntelOS): titolo, data,
  action items
- **Comandi** — un bottone per ogni `.claude/commands/*.md`, con nome e descrizione
  presi dal file

Design semplice, leggibile, adatto a non tecnici: intestazioni chiare, una
sezione per blocco, output dei comandi in un'area dedicata sotto i bottoni.

## /dashboard (`.claude/commands/dashboard.md`)
Comando che avvia `python dashboard/server.py` e apre il browser sulla porta
scelta. Indica come fermarlo (Ctrl+C).

## Discovery dei comandi
Per ogni file in `.claude/commands/`:
- nome comando = nome file senza estensione (es. `catchup.md` → `/catchup`);
- descrizione = prima riga utile / frontmatter del file.
Rigenera la lista ad ogni avvio del server, così i nuovi comandi/automazioni
compaiono automaticamente.

## Verifica
Avvia, controlla che il riepilogo si popoli, testa un bottone e conferma che
l'output appaia. Non lasciare la dashboard senza aver eseguito almeno una volta
un comando end-to-end.
