---
description: "Brief di intelligence prima di una call con un cliente: timeline, promesse vs consegne, pendenze, ultima conversazione e 3 punti d'agenda. Riusa contesto + riunioni + dati dell'AIOS."
argument-hint: "Nome del cliente su cui preparare il brief"
---

Prepara un **brief pre-call di 5 minuti** su un cliente, leggendo tutto ciò che
l'AIOS sa di lui. Serve al consulente per arrivare alla riunione preparato.
Rispondi in italiano, denso e scremato — è un brief, non un report.

Cliente: **$ARGUMENTS**
Se non è stato indicato un cliente, chiedi **solo** il nome e fermati.

## 1. Raccogli tutto ciò che l'AIOS sa del cliente
Nella working dir, cerca il cliente in ogni sorgente disponibile (usa quelle che
esistono, ignora le assenti):

- **Contesto** — `.claude/context/`: note su questo cliente, pacchetto, storia,
  priorità dichiarate, referenti.
- **Riunioni** — tabella `meetings` in `data/database.db`: riunioni il cui
  titolo/partecipanti citano il cliente. Interessano data, riassunto, **action
  items** e decisioni.
- **Dati** — `data/database.db`: record del cliente (pacchetto, importi, fatture,
  stato pipeline) se presente.
- **Automazioni/documenti** — eventuali file collegati (preventivi, fatture in
  `automations/`).

Se non trovi nulla su quel nome, dillo esplicitamente e chiedi se il nome è
scritto diversamente, invece di inventare.

## 2. Segnala la qualità del quadro
In testa al brief, una riga onesta: su cosa ti basi e cosa manca.
Es.: `Basato su: 3 riunioni + scheda cliente. Manca: dati di fatturato.`

## 3. Produci il brief — questo formato
**Cliente** — nome · pacchetto/relazione in una riga · da quando è cliente (se noto)

**Timeline della relazione** — 3-5 tappe chiave in ordine, dalla prima traccia a oggi.

**Promesse vs consegne** — cosa è stato promesso al cliente (o da lui) e cosa è
stato effettivamente fatto. Evidenzia gli scostamenti.

**Pendenze aperte** — action items non ancora chiusi (da chi, da quando).
Ordina per urgenza.

**Ultima conversazione** — data + sintesi in 2-3 righe di cosa ci si è detti
l'ultima volta e cosa era rimasto in sospeso.

**Priorità dichiarate dal cliente** — cosa gli sta a cuore, con parole sue se le hai.

**Segnali di attenzione** — rischi o tensioni (ritardi, promesse non mantenute,
silenzi, pagamenti) — solo se emergono dai dati, senza allarmismi inventati.

**3 punti da mettere in agenda** — le tre cose più utili da affrontare in questa
call, derivate da pendenze + priorità + scostamenti sopra.

## Regole
- Ogni affermazione deve poggiare su un dato trovato: se inferisci, marcalo come
  ipotesi. Mai inventare fatti su un cliente reale.
- Brevità: il consulente lo legge in 5 minuti prima di entrare in call.
- Non proporre strategie elaborate: il brief orienta, non decide. Per stressare
  una decisione emersa, rimanda a `/challenge`.
