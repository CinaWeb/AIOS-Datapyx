# Guida alla costruzione — DataOS

Come generare schema, script, key-metrics e refresh dopo che il piano è stato
approvato. Usa `sqlite3` (nella stdlib Python: nessuna dipendenza extra per il
DB). Aggiungi librerie solo se un connettore le richiede davvero.

## Schema (SQLite, flessibile)
Modella le tabelle sulle **metriche reali** emerse in discovery, non su uno
schema fisso. Pattern tipici:
- `pipeline_mensile(mese, clienti_attivi, fatturato, nuovi_clienti,
  clienti_persi, chiamate, conversioni, conversion_rate)`
- Una tabella per sorgente se i dati grezzi vanno conservati.
Usa tipi appropriati (INTEGER/REAL/TEXT) e una chiave sensata (es. `mese` come
`YYYY-MM`). Se il DB esiste già, fai `ALTER TABLE`/aggiungi tabelle, non ricreare.

## Connettori (`data/connectors/<sorgente>.py`)
Uno script per sorgente, ognuno espone una funzione che ritorna righe pronte per
il DB. Approcci:
- **CSV** — leggi il file (path relativo alla working dir) e normalizza.
- **Google Sheet** — se pubblico/esportabile, scarica come CSV via URL export; se
  privato, usa API con credenziali da `.env`.
- **Manuale** — nessun fetch: fornisci una funzione/comando per inserire righe.
- **API** — leggi le chiavi da `.env` con `os.getenv`; gestisci errori di rete e
  risposte vuote senza crashare la pipeline.
Ogni connettore deve fallire in modo pulito (log dell'errore, ritorna vuoto) così
che una sorgente rotta non blocchi le altre.

## refresh.py
Orchestratore in `data/refresh.py`:
1. importa ed esegue tutti i connettori;
2. fa upsert delle righe nel DB (`INSERT ... ON CONFLICT` sulla chiave);
3. **rigenera `.claude/context/key-metrics.md`** interrogando il DB.
Deve essere idempotente e ri-eseguibile a mano senza effetti collaterali.

## key-metrics.md (autogenerato)
Header chiaro che avvisa di NON modificarlo a mano ("file autogenerato da
refresh.py — YYYY-MM-DD HH:MM"). Contenuto: le metriche chiave in forma leggibile
(clienti attivi, fatturato mensile, nuovi clienti del mese, conversion rate…),
più eventuale trend recente. È il file che il `/prime` del Livello 1 carica ogni
sessione.

## /refresh-data (`.claude/commands/refresh-data.md`)
Comando che esegue `python data/refresh.py`, poi conferma le metriche aggiornate
mostrando l'header e i valori chiave di `key-metrics.md`.

## Segreti
- Tutte le chiavi/token in `.env` (mai in file committati, DB o contesto).
- Assicura `.env` in `.gitignore` (crealo/aggiornalo).
- In `.env` metti solo placeholder commentati se non hai le chiavi vere, così
  l'utente sa cosa compilare.

## Scheduling (script + istruzioni, non toccare lo scheduler)
Genera lo script e **spiega** come pianificarlo, senza modificare l'OS:
- **Windows (Task Scheduler):**
  `schtasks /Create /SC DAILY /ST 06:00 /TN "AIOS refresh <azienda>" /TR "python \"<path>\data\refresh.py\""`
- **macOS/Linux (cron):** `0 6 * * * cd <path> && python data/refresh.py`
Presenta il comando pronto ma lascia che sia l'utente a eseguirlo. Ricorda che
`/refresh-data` resta sempre disponibile per l'aggiornamento manuale.

## Nota utile per l'utente
Per ispezionare il DB in VS Code, l'estensione "SQLite Viewer" permette di aprire
`data/database.db` e sfogliare le tabelle. Menzionalo, non installarlo tu.
