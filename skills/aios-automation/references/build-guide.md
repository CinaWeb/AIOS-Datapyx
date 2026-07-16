# Guida alla costruzione — AutomationOS

Come costruire UNA automazione dopo che l'utente ha confermato. Ogni automazione
è un mattone piccolo e focalizzato: un comando che fa una cosa bene.

## Passi generali
1. **Domande di rito** — chiarisci input/output, formato, vincoli, on-demand vs
   schedulata, casi limite. Non assumere.
2. **Approccio** — presenta cosa serve: librerie Python (installa solo il
   necessario), nuove tabelle nel DB, script, template. Conferma.
3. **Verifica connessioni esterne (se presenti)** — se l'automazione dipende da
   un'API o un servizio esterno (email, gestionale, Stripe, calendario...), prima
   di scrivere la logica completa testa la connessione con uno script minimale
   (probe): credenziali valide, endpoint raggiungibile, risposta come atteso.
   **Collegamento rotto o credenziale mancante → fermati** e segnalalo
   all'utente invece di costruire sopra un'integrazione non verificata. Salta
   questo passo per automazioni che lavorano solo su `data/database.db` e file
   locali.
4. **Costruisci** — comando + script + tabelle. Riusa `data/database.db` e i file
   di contesto invece di duplicare dati.
5. **Testa davvero** — esegui l'automazione con dati reali/di prova e mostra
   l'output.
6. **Roadmap** — marca l'automazione `✅ fatta` in `automations/roadmap.md`.

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

## Automazioni di contenuto (blog, newsletter, social, comunicazioni esterne)
Qui l'errore non è tecnico ma "fuori brand": testo generico, tono sbagliato,
target mancato. La direttiva (`.claude/commands/<nome>.md`) deve istruire a
leggere, **prima di ogni generazione**:
- `brand/` (cartella top-level, non dentro `.claude/context/`) — colori, font,
  tono di voce (se presente in `brand-identity.md`);
- `.claude/context/azienda.md` — settore, prodotti, clienti target;
- `.claude/context/decisioni.md`, se esiste — punti di leva/priorità dalla
  diagnosi, utili a scegliere temi rilevanti;
- gli **output precedenti della stessa automazione**, per continuità di stile
  (vedi sotto).

Se il target nel contesto è troppo generico per scrivere contenuti mirati
(manca tono di voce preferito, pain point, cosa evitare), chiedilo ora invece
di assumere — non generare a vuoto.

**Storico come memoria di stile:** lo script salva ogni output generato in
`automations/<nome>/output/` (es. `2026-07-15-post-blog.md`). Non serve un
sistema di memoria a parte: la direttiva stessa istruisce a leggere gli ultimi
2-3 file di quella cartella prima di generarne uno nuovo, così il tono resta
coerente nel tempo senza richiedere ogni volta le stesse informazioni.

## Principi
- Una automazione = uno scopo chiaro. Meglio tante piccole che una monolitica.
- Fallire in modo pulito: input mancanti → chiedi, non crashare.
- Segreti solo in `.env`. Numerazioni/contatori sempre derivati dal DB, mai
  hardcoded.
- **Determinismo nello script (DOE):** la logica ripetibile sta nel Python, non
  nell'LLM. Riduce l'accumulo di errore sui passi concatenati.
- **Auto-correzione (DOE):** script fallisce → correggi lo script *e* la direttiva,
  ri-testa, `/commit`. Ogni errore rende il sistema più robusto; non aggirarlo a mano.
