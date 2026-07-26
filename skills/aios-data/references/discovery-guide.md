# Guida alla discovery — DataOS

Workshop guidato per capire **quali dati** contano e **dove vivono**, prima di
scrivere qualsiasi script. Una domanda alla volta, mai assunzioni.

## Punto di partenza: il contesto
Leggi prima `.claude/context/strategia.md` e `.claude/context/dati-correnti.md`.
Le metriche chiave sono spesso già lì (fatturato, clienti attivi, conversion
rate, obiettivi). Parti da quelle: non richiedere ciò che sai già, conferma.

## Per ogni metrica
1. **Dove vive il dato?** Google Sheet, CSV esportato, CRM, gestionale,
   piattaforma pagamenti (Stripe/PayPal), tool analytics.
2. **Come si aggiorna?** Manualmente, esportabile, o via API.
3. **Approccio (scegli caso per caso):**
   - **Import Sheet/CSV** — la sorgente è un foglio o un file esportabile.
   - **Inserimento manuale** — nessuna sorgente digitale (es. fatture/bonifici a
     mano): crea un comando/flow per registrare il dato nel DB.
   - **Connettore API** — solo se la piattaforma espone API *e* l'utente ha già
     le chiavi. Se le API sono complesse o mancano le chiavi, ripiega su
     import/manuale e segnalalo. Quando guidi la generazione della chiave,
     chiedila **in sola lettura**: DataOS legge e basta, la scrittura non gli
     serve. Se la piattaforma non separa gli scope (chiave unica con pieni
     poteri), dillo all'utente e annotalo nelle note della connessione.

## Il funnel
Molte metriche hanno senso solo nel contesto del funnel. Indaga i tre stadi:
- **Top** — come i clienti ti trovano (referral, eventi, Instagram, YouTube,
  Google Analytics, ads…).
- **Middle** — come interagiscono (chiamate discovery, preventivi, demo…).
- **Bottom** — come e quando convertono (accordi chiusi, conversion rate).

Non serve coprire tutto subito: mappa ciò che l'azienda già misura, lascia il
resto come estensione futura.

## Domande di chiusura
- Con che frequenza vuole vedere i dati aggiornati? (per dimensionare il refresh)
- Ci sono dati sensibili tra questi? (per assicurarsi che restino fuori da git)

## Registra la connessione

Per ogni sorgente esterna che colleghi scrivi una riga in
`.claude/context/connessioni.md`:

```markdown
| Sheet vendite | aios-data | lettura | 2026-07-26 | export CSV |
```

Se il file non esiste, crealo con il frontmatter `created:`/`updated:`, la
sezione `## Sorgenti collegate` con l'intestazione di tabella
`| Sorgente | Usata da | Scope | Dal | Note |`, e una sezione
`## Deroghe all'invio automatico` con la riga `- Nessuna.` (struttura canonica:
skill `aios-context`, § connessioni esterne). Se esiste già, aggiungi la riga e
aggiorna `updated:`.

Poi passa al **Piano** (step 3 della skill): sorgenti + schema + file, con conferma.
