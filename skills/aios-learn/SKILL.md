---
name: aios-learn
description: Motore interno di apprendimento dell'AIOS. Trasforma correzioni ed errori in regole permanenti per quel cliente (lezioni.md) o in feedback di processo sul prodotto AIOS (aios-feedback-prodotto.md), promuove i contributi degli operatori (/contribuisci) nello strato lezioni con contradiction-gate, e ad ogni /prime genera prospettive proattive. NON è un comando esposto all'utente: è invocata internamente da altre skill/comandi (challenge, debrief, datapyx, i livelli AIOS, prime, contribuisci, rivedi-proposte). Usa quando un touchpoint segnala una correzione/frizione, quando un operatore invia un contributo, o quando /prime chiede le prospettive.
---

# AIOS — aios-learn (motore di apprendimento)

Skill **interna**, invocata da altre skill/comandi sullo stesso principio con cui
l'orchestratore `aios` invoca `aios-context`/`aios-data`/ecc. Non compare in
`/aios-help` come azione primaria e non ha un comando slash dedicato. Contiene
*tutta* la logica di apprendimento: se un criterio o un formato cambia, si edita
solo questo file — i touchpoint restano puntatori stabili.

Lavori **sulla cartella corrente** (l'AIOS del cliente).

## Due lane — non confondere mai

| Lane | Contenuto | File | Chi lo legge |
|---|---|---|---|
| **Lezione cliente** | Regola/pattern su quel business specifico | `.claude/context/lezioni.md` (o `.claude/context/lezioni/` se split) | `/prime`, ogni sessione |
| **Feedback prodotto** | Frizione di processo su AIOS stesso (domanda superflua, step confuso) | `.claude/aios-feedback-prodotto.md` | Il maintainer del plugin, in revisione manuale — **mai** letto da `/prime`, **mai** promosso automaticamente nel codice del plugin |

Dati di business restano isolati per cliente; segnali sul funzionamento di AIOS
non modificano mai automaticamente il codice del plugin.

## Due modalità — riconosci sempre in quale sei

| | **Consulente** (sincrona) | **Operatore** (async) |
|---|---|---|
| Chi ti invoca | `challenge`, `debrief`, `datapyx`, i 4 livelli, `/prime` | `/contribuisci` |
| Umano presente | Sì, in sessione | No: headless, tipicamente dalla dashboard |
| Gate prima di scrivere | **HITL** su ogni cattura (sotto) | **Contradiction-gate** — leggi `references/operator-mode.md` |

Il cardine "mai scrittura silenziosa" resta **integro in modalità consulente**. In
modalità operatore non c'è nessuno da cui ottenere conferma in tempo reale: l'HITL
non si elimina, **si sposta** sulle sole contraddizioni — il contributo che non
contraddice il core è implicitamente approvato ed entra da solo; quello che
contraddice va in coda e aspetta un umano. Nel dubbio, coda.

`/rivedi-proposte` è il momento in cui quell'umano arriva: è la revisione
**sincrona** della coda col curatore, quindi lì vale l'HITL come sempre — una
proposta alla volta, nessuna scritta senza la sua scelta.

## Responsabilità

1. **Classifica il segnale** — lezione di business (→ `lezioni.md`) o frizione di
   processo (→ `aios-feedback-prodotto.md`). Criteri e formati: leggi
   `references/capture-guide.md`. Vale in **entrambe** le modalità.
2. **Protocollo HITL (obbligatorio in modalità consulente)** — vedi sotto. Mai
   scrittura silenziosa quando l'umano è in sessione.
3. **Scrittura append-only** — mai riscrivere o cancellare entry precedenti
   (stesso pattern di `history.md`/`log.md`).
4. **Split dinamico di `lezioni.md`** — su soglia, su conferma. Vedi
   `references/capture-guide.md`.
5. **Prospettive proattive per `/prime`** — leggi `references/perspectives-guide.md`.
6. **Contributi degli operatori (modalità operatore)** — classifica,
   contradiction-check, poi auto-promuovi nello strato lezioni o metti in coda
   (`enrichment/proposals/`). Include la revisione della coda e la segnalazione
   delle **proposte in attesa** quando sei invocata da `/prime`. Leggi
   `references/operator-mode.md`.

**Mai nel core strategico.** `azienda.md`, `strategia.md`, `procedure.md` restano
scrivibili solo dal curatore con HITL: l'enrichment automatico atterra sempre e
solo sullo strato lezioni, progettato per crescere.

## Protocollo HITL (cardine — modalità consulente)

Vale per ogni **cattura** (responsabilità 1, 3, 4) quando l'umano è in sessione.
In modalità operatore il gate equivalente è il contradiction-check
(`references/operator-mode.md`), non questo.

1. Classifica il segnale e prepara **il testo esatto** della entry + il **file di
   destinazione**.
2. Mostralo all'utente e **attendi conferma esplicita**. Non scrivere prima.
3. Alla conferma → scrivi in **append** (mai sovrascrivere).
4. Al rifiuto → scarta e **non riproporre lo stesso segnale nella sessione
   corrente**.

In modalità consulente non ci sono eccezioni: la cattura non è mai silenziosa. Le
**prospettive** (responsabilità 5) NON sono una cattura — sono output mostrato,
non passano dal protocollo HITL. Nemmeno la segnalazione delle proposte in attesa
lo è.

## Contesto standalone

Se manca `.claude/context/` (non sei dentro un AIOS) non c'è nulla da imparare né
un `/prime` da arricchire: non fare nulla e segnalalo a chi ti ha invocata.
