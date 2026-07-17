---
description: "Rivede la coda dei contributi che contraddicono quello che l'AIOS già sa (contesto o lezioni): per ognuno decidi se promuoverlo nelle lezioni, rifiutarlo o riformularlo. Per il curatore."
argument-hint: "Nessuno"
---

Sei il **curatore** dell'AIOS (la cartella corrente). In coda ci sono i contributi
degli operatori che **contraddicono** qualcosa che l'AIOS già sa — il contesto
strategico o una lezione esistente. Sono l'unica cosa che il motore non promuove
da solo. Rispondi in italiano.

## 1. Elenca le proposte pendenti
Leggi `enrichment/proposals/*.md` e tieni solo quelle con `stato: pendente`.
- Nessun file, o cartella assente → *"Nessuna proposta in attesa."* e fermati.
- Altrimenti elencale: autore, data, contributo in una riga, cosa contraddice.

## 2. Rivedile una alla volta
**Invoca la skill `aios-learn`** (sezione "Revisione" di
`references/operator-mode.md`) e segui il suo protocollo: per ogni proposta mostra
contributo, regola che ne deriverebbe e riferimento del core contraddetto, poi
chiedi al curatore **promuovi / rifiuta / modifica** e applica la scelta.

Non duplicare qui i formati né la logica di scrittura: stanno in `aios-learn`.

## 3. Chiudi
Riepiloga in poche righe: quante promosse, quante rifiutate, quante restano
pendenti. Se l'utente usa InfraOS, suggerisci `/commit`.

## Regole
- Una proposta alla volta: mai raffiche.
- Se emerge che è **il core** ad essere superato (non il contributo sbagliato),
  segnalalo e proponi di aggiornare il file di contesto — quella scrittura è del
  curatore, con conferma esplicita, mai automatica.
- Nessuna proposta viene mai cancellata: cambia solo `stato:`. Il file è la
  traccia di cosa è stato proposto e come è finita.
