---
description: "Aiuto e orientamento sul plugin AIOS: cosa fa, i 5 livelli, tutti i comandi, e come approfondire con la guida dettagliata. Accetta un argomento per andare dritto a un tema (es. /aios-help dati)."
argument-hint: "Tema su cui vuoi aiuto (opzionale): installazione, contesto, dati, intelligence, automazioni, dashboard, datapyx, challenge, giornata"
---

L'utente ha chiesto aiuto sul plugin **AIOS**. Il tuo compito è **orientarlo**, in
italiano, con parole semplici (potrebbe non aver mai usato un terminale).

## Se ha passato un tema

Argomento: **$ARGUMENTS**

Se sopra c'è un tema, salta il menu e dai **subito** la spiegazione mirata di
quel tema (cosa fa, quale comando lancia, cosa gli verrà chiesto), poi rimanda
alla sezione corrispondente della guida dettagliata. Mappa tema → sezione:

- installazione → §1 · contesto/brand → §3.2 · dati → §3.3 · intelligence → §3.4
- automazioni → §3.5 · dashboard → §3.6 · datapyx → §4 · challenge → §4 · giornata → §5

## Se NON ha passato un tema — mostra questo orientamento

Presenta, in forma chiara e discorsiva:

**Cos'è l'AIOS** — il "cervello operativo" di un'azienda: Claude smette di essere
generico e conosce a fondo un cliente specifico (chi è, i suoi numeri, le riunioni)
e sa fare alcune operazioni al posto tuo. Si costruisce a livelli; anche solo il
primo è già utile.

**Come si parte** — crea una cartella per il cliente, apri Claude lì dentro, e
scrivi `/aios`. Da lì ti guido livello per livello.

**I 5 livelli**
1. Contesto + Brand (`aios-context`) — chi è l'azienda, strategia, colori/logo
2. Dati (`aios-data`) — i numeri veri in un database
3. Intelligence (`aios-intel`) — le riunioni: decisioni e action item
4. Automazioni (`aios-automation`) — compiti ripetitivi fatti in un comando
5. Dashboard (`aios-dashboard`) — un pannello con bottoni, per chi non usa il terminale

**Comandi principali** (i `/comando` dei livelli compaiono man mano che li costruisci)

| Comando | A cosa serve |
|---|---|
| `/aios` | Avvia/riprende la costruzione dell'AIOS |
| `/prime` | A inizio sessione: ricarica contesto + numeri |
| `/client-brief <cliente>` | Brief pre-call: timeline, promesse vs consegne, pendenze, agenda |
| `/refresh-data` | Riaggiorna i numeri nel database |
| `/collect-meetings` · `/catchup` | Scarica riunioni · riassunto delle recenti |
| `/datapyx` | Diagnosi guidata di una sfida del cliente |
| `/challenge` | "Avvocato del diavolo": stressa una diagnosi/decisione prima di agire |
| `/dashboard` | Apre il pannello visivo |
| `/debrief` | A fine sessione: consolida i progressi del giorno nel contesto |
| `/contribuisci <chi sei>: <cosa hai notato>` | Per gli operatori: aggiunge al cervello dell'AIOS ciò che si impara sul campo |
| `/rivedi-proposte` | Per il curatore: rivede i contributi in disaccordo col contesto |
| `/commit` | Salva e versiona (se InfraOS attivo) |
| `/aios-help` | Questo aiuto |

**Il ritmo quotidiano** — `/prime` → lavori → `/debrief` → `/commit`.

**Le due discipline** — le automazioni (DOE) rendono affidabile ciò che *fai*;
`/challenge` rende rigoroso ciò che *decidi*.

## Poi: offri la guida completa

Chiudi sempre offrendo l'approfondimento:

> Vuoi la guida passo-passo completa, con un esempio costruito dall'inizio alla
> fine? Dimmi il tema e te la apro (es. "aiuto sui dati"), oppure la trovi qui:
> https://github.com/CinaWeb/AIOS-Datapyx/blob/main/GUIDE.md

Se l'utente chiede il dettaglio di una sezione, **leggi il file**
`${CLAUDE_PLUGIN_ROOT}/GUIDE.md` e riportane la parte pertinente. Se quel percorso
non è accessibile, recupera la guida dall'URL GitHub qui sopra (raw/blob) e
riassumi la sezione richiesta. Non inventare passaggi: attieniti al contenuto
della guida.

## Regole
- Italiano, tono cordiale e concreto. Niente gergo tecnico non spiegato.
- Non eseguire azioni di costruzione: questo è solo un comando di aiuto.
