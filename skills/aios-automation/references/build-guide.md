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

## Anatomia di un'automazione
```
.claude/commands/<nome>.md     # cosa fa il comando, quali argomenti accetta, che script chiama
automations/<nome>/*.py        # logica (solo se serve: PDF, chiamate API, calcoli)
data/database.db               # tabelle nuove se l'automazione conserva/legge dati strutturati
.env                           # eventuali segreti (git-ignorato, non toccare chiavi esistenti)
```
Automazioni banali (solo prompt/lettura DB) non hanno bisogno di script Python:
il comando può bastare. Non creare script per il gusto di farlo.

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
