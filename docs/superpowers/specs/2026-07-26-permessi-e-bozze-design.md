# Permessi verso i sistemi esterni e automazioni che producono bozze

- **Data:** 2026-07-26
- **Stato:** design approvato, da implementare
- **Origine:** `IDEE.md` §2026-07-25 (voce «postura sui permessi»), rafforzata dal
  §2026-07-26 (strato 4 del workshop Cotti) e dal blocco «conformità normativa»
  (art. 50(4) AI Act).

## Problema

Il plugin oggi non dice nulla su **cosa può toccare** l'AIOS nei sistemi di terzi.
`aios-intel` chiama le API dei tool di meeting, `aios-data` legge CRM/Sheet/
piattaforme di pagamento, `aios-automation` costruisce integrazioni che possono
scrivere e inviare. La gestione dei **segreti** è già corretta (`.env`
git-ignorato, mai in chat o nel DB); manca la scelta degli **scope** e manca una
regola su cosa può partire verso terzi senza che un umano l'abbia visto.

Tre ragioni convergono sulla stessa modifica: prudenza operativa (fonte Gaspar),
lo strato 4 del workshop Cotti (fonte indipendente), e la condizione di esenzione
dell'art. 50(4) dell'AI Act, che per i contenuti destinati al pubblico richiede
revisione umana sostanziale più responsabilità editoriale identificabile.

## Decisioni prese

| # | Domanda | Decisione |
|---|---|---|
| 1 | Quanto vincola la regola sulle bozze? | **Default forte con deroga registrata.** Di norma l'automazione si ferma alla bozza; l'invio automatico è possibile solo su richiesta esplicita dell'utente e lascia una traccia scritta. |
| 2 | Cosa fa scattare l'obbligo di bozza? | **Il destinatario è esterno all'azienda** (cliente, fornitore, pubblico). Interno (titolare, team, file locale, DB) → invio libero. Copre anche la pubblicazione, che è un destinatario pubblico. |
| 3 | Gli scope lasciano traccia? | **Sì, file dedicato `.claude/context/connessioni.md`.** Dà lo stato corrente delle connessioni, che oggi non esiste da nessuna parte. |
| 4 | Dove vive la regola? | **Formato canonico in `aios-context`, fette operative nelle tre skill che collegano o costruiscono.** Nessuna skill nuova. |

### Perché non una skill interna condivisa

`aios-learn` è il precedente per la logica trasversale, ma giustifica il proprio
costo con classificazione, HITL, contradiction-gate e modalità operatore. Qui il
volume è di circa una pagina, e le fette sono **diverse fra loro**: `aios-data` e
`aios-intel` hanno bisogno della parte «scope in lettura», `aios-automation` di
quella «bozze e deroghe». L'unica cosa che va definita una volta sola è il
*formato* di `connessioni.md`.

Vincolo tecnico verificato: **nessuna skill del plugin referenzia per path i file
di un'altra** (zero occorrenze di `../` o `skills/aios…` in `skills/*/SKILL.md` e
`skills/*/references/*.md`). Il pattern esistente per la conoscenza condivisa è la
**ripetizione breve con citazione della fonte canonica**: `aios-automation/SKILL.md:74`
e `datapyx/SKILL.md:195` ripetono la convenzione del frontmatter e scrivono
«stessa convenzione di `aios-context`». Questo design applica la stessa forma, così
ogni skill resta autosufficiente a runtime.

Se in futuro la regola cresce (retention, basi giuridiche, registro dei
trattamenti dal blocco compliance), si promuove a skill interna senza buttare
niente: le fette restano dove sono, si sposta solo il formato.

## L'artefatto: `.claude/context/connessioni.md`

Frontmatter standard `created:`/`updated:` come ogni file di `.claude/context/`.

```markdown
---
created: 2026-07-26
updated: 2026-07-26
---

# Connessioni esterne

Stato delle sorgenti collegate a questo AIOS: cosa può leggere, cosa può
scrivere, e quali automazioni hanno una deroga all'invio automatico.
Aggiornato da `aios-data`, `aios-intel`, `aios-automation`.

## Sorgenti collegate

| Sorgente | Usata da | Scope | Dal | Note |
|---|---|---|---|---|
| Fireflies | aios-intel | lettura | 2026-07-26 | chiave in .env |
| Sheet vendite | aios-data | lettura | 2026-07-26 | export CSV |
| Gmail | /invia-preventivo | scrittura | 2026-07-28 | crea bozze |

## Deroghe all'invio automatico

- Nessuna.
```

Tre vincoli sul formato:

- **Vocabolario chiuso a due valori:** `lettura` | `scrittura`. "Scrittura"
  significa modificare dati nel sistema esterno e **non** implica poter comunicare
  verso terzi: quello sta solo nelle deroghe. Due assi separati, così «ho dato
  accesso in scrittura a Gmail» non viene letto come «può mandare mail ai clienti».
- **Il file nasce quando serve.** `aios-context` ne definisce il formato ma non lo
  crea vuoto al Livello 1, perché la skill ha già la regola «non creare file vuoti
  o riempitivi» (`aios-context/SKILL.md:82`). Lo crea la prima skill che collega
  una sorgente. Ogni fetta deve quindi dire *cosa fare se il file non esiste*
  (crearlo col formato qui sopra), per non lasciare un riferimento a un file
  fantasma.
- **Niente colonna «dati personali»** in questa iterazione: la vorrebbe il blocco
  compliance, che non è approvato. Aggiungerla dopo costa una colonna; metterla
  adesso lega questo lavoro a una voce ancora aperta.

## Le quattro fette

### `aios-context` — definizione canonica

Nella sezione della convenzione data (`SKILL.md:84-98`) si aggiunge la definizione
di `connessioni.md`: formato della tabella, vocabolario chiuso, nota che il file
nasce alla prima connessione. Nessun'altra modifica al Livello 1: non si aggiunge
una domanda all'intervista, non si crea il file.

### `aios-data` — scope in lettura sulle sorgenti

Aggancio: `references/discovery-guide.md:19-21`, il punto in cui si sceglie il
connettore API. Si aggiunge che, quando si guida la generazione della chiave, la
si chiede **in sola lettura**; se la piattaforma non separa gli scope, lo si dice
e lo si annota nelle note della riga. Poi si scrive la riga in `connessioni.md`.

Costo reale quasi nullo: DataOS legge e basta, quindi la sola lettura è già ciò
che serve. La regola formalizza il comportamento naturale invece di aggiungere
attrito.

### `aios-intel` — scope in lettura sui tool di meeting

Aggancio: `references/discovery-guide.md:13-20`, la verifica delle API. Oggi
controlla endpoint e autenticazione; si aggiunge come terza verifica «esiste uno
scope di sola lettura?». La riga in `connessioni.md` si scrive accanto alla
gestione dei segreti (`SKILL.md:54`). Anche qui il livello è read-only per natura.

### `aios-automation` — dove la regola morde

1. **Scope**, in `references/build-guide.md:11-18` (il probe delle connessioni
   esterne): oggi verifica che la credenziale sia valida, deve verificare anche
   **con quale scope** gira. Se l'automazione ha bisogno di scrivere su un sistema
   esterno → conferma esplicita e riga in `connessioni.md`.
2. **Bozze**, nuova sottosezione subito dopo il probe: se l'output ha un
   destinatario esterno, l'automazione si ferma alla bozza — crea la bozza Gmail,
   il file, il record — e l'invio resta un gesto umano. La domanda «il destinatario
   è interno o esterno?» entra nelle *domande di rito* (`build-guide.md:7-8`), dove
   l'utente sta già rispondendo su formato e vincoli.

   Caso da non confondere: **scrivere in un sistema esterno non è comunicare verso
   terzi**. Un'automazione che aggiorna un campo nel CRM o marca una fattura come
   pagata richiede scope `scrittura` registrato in `connessioni.md`, non la bozza —
   non ha un destinatario. La bozza scatta quando l'output è *diretto a qualcuno*
   fuori dall'azienda.
3. **Deroga**: se l'utente vuole l'invio automatico, servono tre cose — conferma
   esplicita, riga in `connessioni.md §Deroghe all'invio automatico`, e un avviso
   in testa alla direttiva del comando:

   ```
   > ⚠️ Invio automatico verso destinatari esterni — deroga del 2026-07-28.
   > Vedi `.claude/context/connessioni.md`.
   ```

   L'avviso nella direttiva serve perché fra sei mesi chi rilegge
   `/invia-preventivo` deve capire in tre secondi che quel comando manda davvero.

## Come si scrive il testo dei prompt

Principi presi da `wiki/concepts/claude-skills.md`, `prompt-engineering.md`,
`context-engineering.md` e `sources/claude-skills-5-errori.md` della knowledge base
personale, tenuti solo dove cambiano davvero cosa scriviamo:

1. **Esplicito, non enfatico.** Le tre leve primarie per Claude 4.x+ sono essere
   espliciti, aggiungere contesto, curare gli esempi. I trigger aggressivi
   («CRITICAL: you MUST…») causano *overtriggering* su Opus 4.5+, cioè esagerazione
   del vincolo a scapito della qualità. La regola si scrive come default operativo
   con la domanda concreta da porre, non come divieto urlato. Il registro esistente
   del plugin («due regole non negoziabili», `aios-automation/SKILL.md:37`) è già la
   misura giusta: si resta lì.
2. **Un esempio vale più della regola astratta.** Accanto al vincolo va uno scambio
   concreto (automazione che manda un preventivo → domanda sul destinatario →
   bozza), non solo il principio.
3. **Progressive disclosure.** Il dettaglio sta nei `references/`, il puntatore
   breve in `SKILL.md`. È già il pattern del plugin e conferma la collocazione
   scelta.
4. **Nessun riferimento a file fantasma.** Ogni punto che nomina `connessioni.md`
   dice cosa fare se non esiste. È uno dei cinque errori tipici delle skill.
5. **Coerenza di forma.** Markdown e tabelle come nel resto del plugin; niente tag
   XML introdotti solo qui, anche se sono una tecnica raccomandata in generale — la
   coerenza interna vale più della tecnica isolata.

## Verifica

Sono modifiche a prompt: non esiste una suite che le possa provare, e «ho scritto
il testo» non è una verifica.

**Statico (sempre).** Rileggere i quattro file e controllare che: ogni fetta sia
autosufficiente (nessun rimando per path a file di altre skill); il vocabolario
`lettura`/`scrittura` sia identico nei quattro punti; l'esempio di tabella in
`aios-context` combaci con quello che le altre skill scrivono davvero; ogni
menzione di `connessioni.md` gestisca il caso «file assente».

**Dry-run (una volta, su `aios-automation`).** Cartella di prova nello scratchpad
con un `.claude/context/` minimale; si costruisce un'automazione che manda un
preventivo a un cliente. Passa se: pone la domanda sul destinatario, propone la
bozza senza che glielo si chieda, e scrive `connessioni.md` creandolo. Poi si
chiede l'invio automatico e si verifica che pretenda la conferma e lasci entrambe
le tracce (riga nelle deroghe + avviso nella direttiva).

Il dry-run si fa solo su `aios-automation` perché è l'unica fetta che cambia un
comportamento: `aios-data` e `aios-intel` formalizzano ciò che già fanno.

## Fuori scope

- `references/audit-guide.md` non si tocca: l'audit mappa opportunità, la regola
  scatta in costruzione.
- Le automazioni già costruite non si rileggono: non ce ne sono, il plugin non è
  ancora girato end-to-end (vedi `ROADMAP.md`, «collaudo end-to-end»).
- Registro dei trattamenti, basi giuridiche, retention, tipo di account: sono del
  blocco «conformità normativa» di `IDEE.md`, non di questo lavoro.
- Nessuna modifica a `aios-dashboard`, `datapyx`, `aios-learn`.

## Rischi noti

- **Il formato è documentato in una skill diversa da quelle che ci scrivono.** È il
  contro accettato dell'approccio scelto: chi modificherà `aios-data` deve sapere
  che la struttura canonica sta in `aios-context`. Mitigazione: ogni fetta cita la
  fonte canonica per nome, come già fa il plugin per il frontmatter.
- **La deroga può diventare la norma.** Se l'utente risponde «invio automatico»
  ogni volta, la regola si svuota. Non si mitiga con più attrito (spingerebbe solo
  a deroghe in blocco): la traccia scritta serve proprio a rendere visibile quante
  deroghe ci sono, ed è materiale per il futuro `/aios-check`.
- **Il dry-run costa una sessione.** È l'unica prova reale che il testo cambia il
  comportamento; senza, resta un'asserzione.
