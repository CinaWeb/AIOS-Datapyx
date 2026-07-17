# AIOS — Roadmap

Idee e lavori futuri, non ancora implementati. L'ordine non è vincolante.

## Agenti specialisti per DataPyx (rimandato)
Il prompt di DataPyx prevede di **coordinare e attivare agenti specialisti**
(routing autonomo / su proposta / su richiesta), ma questi agenti **non esistono
ancora**. Oggi DataPyx fa la diagnosi ma, quando propone "attivo l'agente X", non
c'è un agente X da lanciare.

Da fare: creare gli agenti specialisti come skill/subagent collegati, es.
- ricerca di mercato
- analisi competitor
- Jobs To Be Done (JTBD)
- analisi cicli di feedback / dinamiche sistemiche
- ricerca dati quantitativi a supporto (ancoraggio dei dati qualitativi)

Ognuno riceve dal PM (DataPyx) un incarico mirato e restituisce un report
strutturato con qualità del dato dichiarata (fonte/freschezza/Q+/Q−/affidabilità).

✅ **Fatto (v0.2.0):** il primo specialista è il gate epistemologico `/challenge`
(agente *Cognitos*) — red-team di una diagnosi prima di agirci. Presidia la metà
probabilistica dell'AIOS; complemento speculare della disciplina DOE sulle
automazioni (metà deterministica). Gli altri specialisti (mercato, competitor,
JTBD, feedback loop, dati Q+) restano da fare.

✅ **Fatto (v0.3.0):** chiuso il ciclo quotidiano con **`/debrief`** (consolida i
progressi del giorno in `context` + `history.md`) e aggiunto **`/client-brief`**
(intelligence pre-call). Restano da fare gli agenti specialisti sopra.

## Apprendimento e multi-operatore

✅ **Fatto (v0.5.0):** motore interno **`aios-learn`** — le correzioni diventano
lezioni permanenti del cliente (`.claude/context/lezioni.md`) o feedback di
processo sul prodotto; prospettive proattive ad ogni `/prime`.

✅ **Fatto (v0.6.0):** **arricchimento multi-operatore** sopra `aios-learn` —
seconda modalità (operatore/async) con promozione automatica contradiction-gated,
coda conflitti `enrichment/proposals/`, comandi `/contribuisci` e
`/rivedi-proposte`, dashboard con bind configurabile e attribuzione. Chiude il
"domain brain per contributor" che la vecchia bozza *Company Brain* lasciava
scoperto.

Restano da fare, su questo filone:
- **Collaudo multi-operatore su un cliente reale**: il flusso è scritto ma non è
  ancora girato con più persone su una cartella condivisa.
- **Deployment di riferimento**: il design è host-agnostico (contratto storage +
  compute always-on); manca una ricetta concreta provata su un host (NAS/VM).

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
