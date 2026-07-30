# AIOS — Roadmap

Idee e lavori futuri, non ancora implementati. L'ordine non è vincolante.

## Agenti specialisti per DataPyx (rimandato)
Il prompt di DataPyx prevede di **coordinare e attivare agenti specialisti**
(routing autonomo / su proposta / su richiesta). Il primo esiste — il gate
epistemologico `/challenge`, agente *Cognitos* — ma gli altri no: quando DataPyx
propone "attivo l'agente X", quell'agente non c'è.

Da fare: creare gli agenti specialisti come skill/subagent collegati, es.
- ricerca di mercato
- analisi competitor
- Jobs To Be Done (JTBD)
- analisi cicli di feedback / dinamiche sistemiche
- ricerca dati quantitativi a supporto (ancoraggio dei dati qualitativi)

Ognuno riceve dal PM (DataPyx) un incarico mirato e restituisce un report
strutturato con qualità del dato dichiarata (fonte/freschezza/Q+/Q−/affidabilità).

## Apprendimento e multi-operatore

Il motore `aios-learn` e l'arricchimento multi-operatore che ci sta sopra sono
costruiti. Restano da fare, su questo filone:
- **Collaudo multi-operatore su un cliente reale**: il flusso è scritto ma non è
  ancora girato con più persone su una cartella condivisa.
- **Deployment di riferimento**: il design è host-agnostico (contratto storage +
  compute always-on); manca una ricetta concreta provata su un host (NAS/VM).

## Divario architetturale

Il plugin è al 100% prompt: sotto le skill non c'è nessuno strato deterministico.
Confronto fatto il 2026-07-30 con un sistema di memoria LLM maturo; i principi
sono gli stessi, manca l'impianto. In ordine di peso:

1. **Nessun retrieval.** `/prime` carica l'intero `.claude/context/`. Regge oggi
   perché i file sono pochi, ma `lezioni.md` è progettato per crescere (lo split
   per settore è già scritto in `capture-guide.md`) e `/contribuisci` ci appende
   in automatico. Rimedio a costo basso: FTS5 sul SQLite che `aios-data` già crea
   — non serve un motore esterno. È il primo passo: sblocca anche i punti 4 e 6.
2. **Trust boundary assente.** Quattro superfici di ingest di contenuto esterno
   (documenti del cliente, transcript dei meeting, righe CRM, `/contribuisci`
   headless) e in nessun punto di `skills/` o `commands/` è scritto che quel
   contenuto è *dato da sintetizzare*, mai *istruzione da eseguire*. Il
   contradiction-check guarda la coerenza col core, non l'injection.
3. **Multi-writer senza regola di conflitto.** `enrichment/proposals/` è un file
   per conflitto, corretto. Ma `lezioni.md` è un file solo in append da più
   operatori: su Git è un merge conflict che un operatore non tecnico non sa
   risolvere, su cartella di rete è una scrittura persa.
4. **Modello dati piatto.** Solo `created:`/`updated:`. La promessa di report
   "con qualità del dato dichiarata (fonte/freschezza/affidabilità)" fatta agli
   agenti specialisti non ha uno schema in cui atterrare: va progettato **prima**
   di costruirli.
5. **Nessuna autorità sui numeri.** `dati-correnti.md` (intervista) e
   `key-metrics.md` (autogenerato dal DB) possono divergere sullo stesso
   fatturato senza che nessuna regola dica chi vince. È una riga in
   `aios-context`.
6. **Riflessione non schedulata.** Le prospettive proattive partono solo se
   qualcuno lancia `/prime`. Manca l'equivalente di un hook con throttle — e i
   presidi che dipendono dal punto 4 (decadimento della confidence, link
   suggeriti) non sono nemmeno esprimibili.
7. **Zero toolchain di manutenzione.** Gli script che AIOS produce servono il
   cliente, non l'AIOS: se un frontmatter si rompe, un `updated:` resta indietro
   o `connessioni.md` diverge dalla realtà, non se ne accorge nessuno.

## Backlog / candidati
- **Persistenza della diagnosi**: salvare l'output DataPyx (problema reale, leve,
  scenari, segnalpost) in un file del cliente, così `/prime` lo ricarica e la
  dashboard lo mostra; abilita la Fase 5 (monitoraggio) a ripartire dallo stato.
  *(Parzialmente coperto da `/debrief`, che consolida decisioni e stato a fine
  giornata; manca la persistenza strutturata dello specifico output DataPyx.)*
- **Collaudo end-to-end**: le skill sono scritte ma non ancora eseguite su un
  caso reale dall'inizio alla fine.
- **Visibilità repo**: verificare pubblica/privata a seconda di chi deve
  installare il plugin.
