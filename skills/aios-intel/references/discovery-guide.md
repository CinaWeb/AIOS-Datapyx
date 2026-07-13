# Guida alla discovery — IntelOS (meeting)

Obiettivo: capire con quale tool l'azienda registra le riunioni e se ha un'API
utilizzabile, prima di scrivere il connettore. Una domanda alla volta.

## 1. Quale tool
Chiedi con cosa registra/trascrive i meeting:
- Note-taker dedicati: **Fireflies**, **Fathom**, **Otter**, **tl;dv**
- Piattaforme call con trascrizione: **Zoom**, **Google Meet**, **Microsoft
  Teams**, **ClickUp**
Se ne usa più di uno, parti dal principale.

## 2. Ricerca API (fallo davvero, non a memoria)
Per il tool scelto, **cerca la documentazione API aggiornata** (WebSearch e/o
WebFetch della pagina developer). Verifica:
- esiste un endpoint per **elencare i meeting** e uno per **scaricare il
  transcript**?
- che **autenticazione** serve (API key, OAuth)? L'utente ce l'ha o può
  generarla facilmente?
- ci sono limiti (rate limit, piano a pagamento richiesto)?

Riporta all'utente cosa hai trovato in modo sintetico, poi decidi:
- **API valida e chiavi disponibili** → procedi con quel tool.
- **API assente/complessa o niente chiavi** → **suggerisci l'alternativa
  migliore** (spesso **Fireflies**, API semplice e ben documentata) spiegando
  perché, e lascia scegliere l'utente. Non forzare: se vuole restare sul suo
  tool, valuta un ripiego (es. export manuale dei transcript in una cartella che
  il connettore legge).

## 3. Dettagli di raccolta
- **Frequenza:** ogni quanto raccogliere nuovi meeting (giornaliera tipica).
- **Storico:** vuole importare anche i meeting passati o solo da oggi in avanti?
- **Persone chiave:** chi sono i collaboratori/clienti ricorrenti? (migliora
  classificazione e sintesi — puoi anche ricavarli da `.claude/context/`).

Poi passa al **Piano** (step 3 della skill): tool, schema, file, `.env`.
