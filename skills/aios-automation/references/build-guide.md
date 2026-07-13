# Guida alla costruzione — AutomationOS

Come costruire UNA automazione dopo che l'utente ha confermato. Ogni automazione
è un mattone piccolo e focalizzato: un comando che fa una cosa bene.

## Passi generali
1. **Domande di rito** — chiarisci input/output, formato, vincoli, on-demand vs
   schedulata, casi limite. Non assumere.
2. **Approccio** — presenta cosa serve: librerie Python (installa solo il
   necessario), nuove tabelle nel DB, script, template. Conferma.
3. **Costruisci** — comando + script + tabelle. Riusa `data/database.db` e i file
   di contesto invece di duplicare dati.
4. **Testa davvero** — esegui l'automazione con dati reali/di prova e mostra
   l'output.
5. **Roadmap** — marca l'automazione `✅ fatta` in `automations/roadmap.md`.

## Anatomia di un'automazione (mapping DOE)
```
.claude/commands/<nome>.md     # DIRETTIVA — cosa fa, quali argomenti accetta, che script chiama
   └─ Claude che esegue        # ORCHESTRAZIONE — raccoglie input, chiama lo script, gestisce gli errori
automations/<nome>/*.py        # ESECUZIONE — logica deterministica (PDF, API, calcoli, DB)
data/database.db               # tabelle nuove se l'automazione conserva/legge dati strutturati
.env                           # eventuali segreti (git-ignorato, non toccare chiavi esistenti)
```
I tre livelli della Three-Layer Architecture (DOE): la **direttiva** è la SOP
markdown del comando, l'**orchestrazione** è Claude che decide e chiama, l'
**esecuzione** è lo script deterministico. L'LLM decide *cosa* fare con *quali
input*; la logica ripetibile la fa lo **script**, mai la chat.

Automazioni banali (solo prompt/lettura DB) non hanno bisogno di script Python:
il comando può bastare. Non creare script per il gusto di farlo — ma qualunque
cosa sia **deterministica e ripetibile** (numerazioni, calcoli, formattazione,
chiamate API) va nello script, non improvvisata a mano.

## Esempio canonico: generazione fatture
Dal video, come riferimento di pattern completo.

**Tabelle nel DB:**
- `clienti(id, nome, partita_iva, codice_fiscale, indirizzo, email,
  tipo_pacchetto, imponibile, attivo)`
- `fatture(numero, data, cliente_id, descrizione, importo, ...)` — `numero`
  **progressivo** (leggi il max esistente + 1).

**Script (`automations/fatture/`):**
- gestione anagrafica clienti (crea/aggiorna record);
- creazione fattura: prende cliente dal DB, calcola il numero progressivo,
  inserisce descrizione e importo, genera il PDF da un template (libreria PDF
  Python), restituisce il percorso/link del file;
- eventuale aggiornamento del fatturato tracciato in DataOS.

**Comando `/crea-fattura`:** accetta cliente + descrizione + importo; se mancano
dati anagrafici (partita IVA, indirizzo…), li chiede; genera la fattura con
numerazione progressiva e restituisce il PDF.

**Test:** "crea una fattura per Marco Bianchi, call di strategia, €150" → trova/
crea il cliente, numera progressivo, produce il PDF, lo mostra.

## Principi
- Una automazione = uno scopo chiaro. Meglio tante piccole che una monolitica.
- Fallire in modo pulito: input mancanti → chiedi, non crashare.
- Segreti solo in `.env`. Numerazioni/contatori sempre derivati dal DB, mai
  hardcoded.
- **Determinismo nello script (DOE):** la logica ripetibile sta nel Python, non
  nell'LLM. Riduce l'accumulo di errore sui passi concatenati.
- **Auto-correzione (DOE):** script fallisce → correggi lo script *e* la direttiva,
  ri-testa, `/commit`. Ogni errore rende il sistema più robusto; non aggirarlo a mano.
