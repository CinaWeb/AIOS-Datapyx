---
description: "Debrief di fine giornata: Claude fa qualche domanda sui progressi e aggiorna il contesto dell'AIOS (context + history.md). Chiude il ciclo /prime → lavoro → /debrief."
argument-hint: "Nota rapida sulla giornata (opzionale)"
---

È fine sessione. Il tuo compito è **consolidare i progressi della giornata**
nell'AIOS del cliente (la cartella corrente), così domani `/prime` riparte dallo
stato aggiornato e non da dove eravamo ieri. Rispondi in italiano.

Nota libera dell'utente (se presente): **$ARGUMENTS**

## 1. Carica lo stato attuale (silenzioso)
Prima di chiedere, leggi cosa esiste nella working dir per fare domande mirate,
non generiche:
- `.claude/context/` — chi è l'azienda, strategia, stato clienti/progetti, numeri;
- `history.md` — le ultime entry (cos'era in sospeso ieri);
- `data/database.db` — se presente, lo stato di pipeline/clienti;
- eventuali `automations/roadmap.md`.
Se manca `.claude/context/`, avvisa che il debrief sarà più povero e chiedi se
procedere lo stesso.

## 2. Intervista di debrief — UNA domanda alla volta
Non aspettare che l'utente racconti: **fai tu le domande**, mirate sullo stato che
hai appena letto. Copri (adatta all'AIOS reale, salta il non pertinente):

1. **Cosa è avanzato oggi?** — progetti/clienti che si sono mossi e come.
2. **Cosa si è bloccato o è in ritardo?** — e perché.
3. **Decisioni prese** — scelte che cambiano strategia, prezzi, priorità.
4. **Novità sui numeri/persone** — nuovi clienti, importi, cambi nel team.
5. **Azioni aperte** — cosa resta da fare, con eventuale scadenza.

Una domanda alla volta, brevi. Sfida ciò che non torna (una decisione che
contraddice la strategia nei file → chiedi conferma prima di registrarla).

## 3. Recap prima di scrivere
Prima di toccare qualsiasi file, mostra **cosa hai capito** e **l'elenco preciso
delle modifiche** che stai per fare (quali file, quali righe/valori). Ottieni
conferma. Non riscrivere interi file: aggiorna solo ciò che è cambiato.

## 4. Aggiorna l'AIOS
Dopo conferma:
- **`history.md`** — appendi una entry datata (`## [YYYY-MM-DD] debrief`) con:
  avanzamenti, decisioni, azioni aperte. Append-only: non modificare entry
  precedenti. Se `history.md` non esiste (InfraOS non attivo), proponi di crearlo.
- **File di stato in `.claude/context/`** — aggiorna quelli pertinenti (es.
  `dati-correnti.md`, stato clienti/progetti) con i nuovi fatti. **Non** toccare
  `key-metrics.md` (è autogenerato da `/refresh-data`): se sono cambiati i numeri
  di sorgente, ricorda all'utente di lanciare `/refresh-data`.

## 5. Chiusura
- Riepiloga in 3 righe cosa hai registrato.
- Se sono emerse azioni aperte con scadenza, elencale come promemoria per domani.
- Se l'utente usa **InfraOS**, suggerisci **`/commit`** per versionare il debrief.

## Regole
- Sei un archivista, non un esecutore: qui **non** costruisci automazioni né
  affronti nuove sfide. Registri e basta.
- Mai inventare progressi: se l'utente non risponde a una domanda, salta quel punto.
- Confidenza: se un dato riferito è incerto, segnalalo nel testo che scrivi.
