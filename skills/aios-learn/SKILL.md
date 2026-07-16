---
name: aios-learn
description: Motore interno di apprendimento dell'AIOS. Trasforma correzioni ed errori in regole permanenti per quel cliente (lezioni.md) o in feedback di processo sul prodotto AIOS (aios-feedback-prodotto.md), e ad ogni /prime genera prospettive proattive. NON è un comando esposto all'utente: è invocata internamente da altre skill/comandi (challenge, debrief, datapyx, i livelli AIOS, prime). Usa quando un touchpoint segnala una correzione/frizione o quando /prime chiede le prospettive.
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

## Responsabilità

1. **Classifica il segnale** — lezione di business (→ `lezioni.md`) o frizione di
   processo (→ `aios-feedback-prodotto.md`). Criteri e formati: leggi
   `references/capture-guide.md`.
2. **Protocollo HITL (obbligatorio)** — vedi sotto. Mai scrittura silenziosa.
3. **Scrittura append-only** — mai riscrivere o cancellare entry precedenti
   (stesso pattern di `history.md`/`log.md`).
4. **Split dinamico di `lezioni.md`** — su soglia, su conferma. Vedi
   `references/capture-guide.md`.
5. **Prospettive proattive per `/prime`** — leggi `references/perspectives-guide.md`.

## Protocollo HITL (cardine)

Vale per ogni **cattura** (responsabilità 1, 3, 4):

1. Classifica il segnale e prepara **il testo esatto** della entry + il **file di
   destinazione**.
2. Mostralo all'utente e **attendi conferma esplicita**. Non scrivere prima.
3. Alla conferma → scrivi in **append** (mai sovrascrivere).
4. Al rifiuto → scarta e **non riproporre lo stesso segnale nella sessione
   corrente**.

Nessuna eccezione: la cattura non è mai silenziosa. Le **prospettive**
(responsabilità 5) NON sono una cattura — sono output mostrato, non passano dal
protocollo HITL.

## Contesto standalone

Se manca `.claude/context/` (non sei dentro un AIOS) non c'è nulla da imparare né
un `/prime` da arricchire: non fare nulla e segnalalo a chi ti ha invocata.
