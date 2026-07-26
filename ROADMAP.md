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
