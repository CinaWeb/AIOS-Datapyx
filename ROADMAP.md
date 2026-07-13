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

## Backlog / candidati
- **Persistenza della diagnosi**: salvare l'output DataPyx (problema reale, leve,
  scenari, segnalpost) in un file del cliente, così `/prime` lo ricarica e la
  dashboard lo mostra; abilita la Fase 5 (monitoraggio) a ripartire dallo stato.
- **Collaudo end-to-end**: le skill sono scritte ma non ancora eseguite su un
  caso reale dall'inizio alla fine.
- **Visibilità repo**: verificare pubblica/privata a seconda di chi deve
  installare il plugin.
