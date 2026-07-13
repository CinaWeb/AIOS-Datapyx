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
- **Bind solo su `127.0.0.1`.** Mai `0.0.0.0` di default.
- **Allowlist**: costruisci la lista dei comandi leggendo `.claude/commands/*.md`
  all'avvio. `/run` accetta **solo** un indice/nome presente in quella lista. Non
  passare mai a shell input libero dell'utente come comando. Se aggiungi un campo
  follow-up, invialo come **argomento/prompt** a `claude -p` (che è l'AI del
  cliente), non concatenato in una shell: usa `subprocess.run([...], shell=False)`
  con lista di argomenti, mai `shell=True`.
- Scegli una porta locale libera (es. 8787) e comunicala.

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
