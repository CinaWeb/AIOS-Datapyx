# aios-learn — Guida alle prospettive proattive

Responsabilità 5 di `aios-learn`. Invocata da `prime.md` **dopo** il riepilogo di
sessione. **Nessun protocollo HITL**: le prospettive sono output mostrato a
schermo, non scritture su file.

## Cosa leggere

- `.claude/context/lezioni.md` oppure `.claude/context/lezioni/` (se split)
- `.claude/context/decisioni.md` (sintesi DataPyx, se presente)
- `.claude/context/key-metrics.md` (se presente)
- riunioni recenti (`data/database.db`, tabella `meetings`, se presente)
- il focus della sessione corrente (cosa l'utente ha appena chiesto/aperto)

## Cosa produrre

2-3 osservazioni **concrete**, ognuna di uno di questi tipi:
- un **angolo nuovo** su qualcosa di già noto;
- un **rischio non ancora nominato** che emerge dai fatti;
- una **connessione** tra fatti già noti ma mai collegati esplicitamente.

Non sono anomalie nei dati né alert operativi: servono ad aiutare il consulente a
pensare fuori dagli schemi.

## Regole

- **Non forzare.** Se non emerge nulla di genuino, **ometti** del tutto la
  sezione. Meglio niente che un'osservazione ovvia o inventata.
- **Separa dai fatti.** Mostra le osservazioni sotto un'etichetta esplicita
  **"Prospettive"**, distinta dal riepilogo fattuale di `/prime`, così non si
  confondono con dati verificati.
- Frasi brevi, in italiano.
