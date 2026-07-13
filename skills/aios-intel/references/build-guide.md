# Guida alla costruzione — IntelOS (meeting)

Come generare tabella, connettore e comandi dopo l'approvazione del piano. Usa
`sqlite3` dalla stdlib. Aggiungi librerie solo se l'API del tool lo richiede
(es. `requests`).

## Tabella `meetings` (SQLite)
Nel DB `data/database.db` (crealo se manca). Colonne tipiche:
- `id TEXT PRIMARY KEY` — id del meeting dalla sorgente (per dedup)
- `sorgente TEXT` — tool (fireflies, zoom…)
- `titolo TEXT`
- `data TEXT` — `YYYY-MM-DD`
- `ora_inizio TEXT`
- `durata_min INTEGER`
- `partecipanti TEXT` — nomi + email (JSON o testo)
- `transcript TEXT` — testo integrale
- `riassunto TEXT`
- `action_items TEXT`
- `url TEXT` — link alla registrazione
- `classificazione TEXT` — categoria (vendite/prodotto/marketing/generale)
Se la tabella esiste già, non ricrearla: aggiungi solo i meeting nuovi.

## Connettore `data/connectors/meetings.py`
- Legge la chiave API da `.env` (`os.getenv`).
- Chiama l'API del tool per **elencare i meeting** (dalla data desiderata) e per
  ognuno scaricare **transcript, riassunto, action items, partecipanti, url**.
- **Dedup:** salta gli id già presenti (`INSERT OR IGNORE` sull'id).
- **Classificazione:** assegna una categoria in base a titolo/partecipanti/
  contenuto. Categorie flessibili, adattate all'azienda; default "generale" se
  incerto. Può essere una semplice euristica su parole chiave, oppure lasciata a
  Claude in fase di lettura — mantienila semplice e trasparente.
- Fallisce in modo pulito (log dell'errore, nessun crash) se l'API non risponde.

## /collect-meetings (`.claude/commands/collect-meetings.md`)
Esegue `python data/connectors/meetings.py` e riporta **quanti meeting nuovi**
sono stati aggiunti e il periodo coperto.

## /catchup (`.claude/commands/catchup.md`)
Comando di sintesi. Deve:
1. interrogare i meeting recenti nel DB (default ultimi 7 giorni, o accettare un
   argomento tipo "questa settimana" / "da lunedì");
2. produrre una sintesi con: **decisioni prese**, **action items aperti** (chi/
   cosa, se ricavabile), **con chi hai parlato** e su cosa;
3. ordinare per priorità/rilevanza.
Il comando legge il DB, non i file di contesto: i dati sono nella tabella
`meetings`.

## Segreti
- Chiave API del tool solo in `.env` (mai committata, mai nel DB o nel contesto).
- Assicura `.env` in `.gitignore`; non sovrascrivere chiavi già presenti (es.
  quelle di DataOS).
- Se l'utente non ha ancora la chiave, metti un placeholder commentato in `.env`
  e spiega dove generarla (dalla ricerca API fatta in discovery).

## Scheduling (script + istruzioni, non toccare lo scheduler)
Come DataOS: genera lo script e **spiega** come pianificarlo, senza modificare
l'OS.
- **Windows:** `schtasks /Create /SC DAILY /ST 07:00 /TN "AIOS meetings <azienda>" /TR "python \"<path>\data\connectors\meetings.py\""`
- **macOS/Linux:** `0 7 * * * cd <path> && python data/connectors/meetings.py`
Raccolta manuale sempre disponibile via `/collect-meetings`.

## Nota
I transcript possono essere lunghi: non caricarli nel `/prime`. Restano
interrogabili on-demand (query libere) e riassumibili con `/catchup`.
