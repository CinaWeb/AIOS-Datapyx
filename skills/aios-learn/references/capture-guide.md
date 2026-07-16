# aios-learn — Guida alla cattura

Dettaglio di classificazione, formati e split per le responsabilità 1, 3 e 4 di
`aios-learn`. Il protocollo HITL sta in `SKILL.md` e vale sempre.

## Classificazione del segnale

Chiediti: **il segnale riguarda il business del cliente o il funzionamento di
AIOS come strumento?**

- **Lezione di business** → un fatto/pattern/regola su *questo* cliente che
  cambierà come lavori per lui in futuro. Esempi: "il cliente rifiuta setup >2
  settimane", "il churn è concentrato sul segmento retail", "le proposte vanno
  sempre validate col socio prima dell'invio". Va in `lezioni.md`.
- **Frizione di processo** → un attrito nell'uso di AIOS stesso: una domanda
  superflua, uno step confuso, un ordine illogico. Esempi: "la domanda su
  capacità del team arriva prima di parlare dei clienti attivi", "il recap di
  aios-data è troppo verboso". Va in `aios-feedback-prodotto.md`.

Nel dubbio: se la regola aiuta *il consulente a servire il cliente*, è business;
se aiuta *chi mantiene AIOS a migliorare il tool*, è processo.

## Formato — `.claude/context/lezioni.md`

Il file inizia con frontmatter (è un file di contesto, convenzione `aios-context`):

```
---
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
# Lezioni apprese — {{cliente}}

## [YYYY-MM-DD] fonte: /challenge
Il cliente rifiuta sempre proposte con setup >2 settimane, anche se il ROI è alto.
→ Non proporre roadmap lunghe senza una milestone intermedia entro 2 settimane.
```

- `created:` alla prima creazione del file; `updated:` ad ogni nuova entry.
- Ogni entry cita la **fonte** (skill o comando) per rintracciarne la provenienza.
- Corpo: il fatto/pattern, poi una riga `→` con la regola operativa che ne deriva.

## Formato — `.claude/aios-feedback-prodotto.md`

Non è un file di contesto (sta fuori da `context/`): niente frontmatter
`created:`/`updated:`, stesso stile di `log.md` — header + append-only.

```
# Feedback di prodotto AIOS — {{cliente}}
Frizioni di processo sul funzionamento di AIOS. Letto in revisione manuale dal
maintainer del plugin. Non letto da /prime, mai promosso automaticamente.

## [YYYY-MM-DD] skill: aios-data
L'utente ha segnalato che la domanda su "capacità del team" arriva troppo presto,
prima di aver parlato di clienti attivi — confuso l'ordine logico.
```

## Split di `lezioni.md` per settore

- **Default**: singolo file `.claude/context/lezioni.md`.
- **Soglia**: quando il file diventa difficile da scorrere (indicativamente
  15-20 entry), **proponi** lo split: *"lezioni.md sta crescendo — vuoi che lo
  divida per settore?"*. Mai split automatico senza conferma.
- **Alla conferma**: crea `.claude/context/lezioni/`, classifica le entry
  esistenti in file per settore. I settori sono un set **flessibile** che emerge
  dal contenuto reale (come i file di contesto in `aios-context`), non una
  tassonomia fissa — esempi tipici: `relazione-cliente.md`, `dati-numeri.md`,
  `automazioni-processi.md`, `decisioni-strategiche.md`. Ogni file di settore
  porta lo stesso frontmatter `created:`/`updated:`.
- **Da lì in poi**: ogni nuova lezione va nel file di settore giusto, o in uno
  nuovo se emerge un settore inedito.
- `prime.md` non cambia: legge tutto `.claude/context/` (quindi anche
  `lezioni/`), lo split è invisibile al comando.
