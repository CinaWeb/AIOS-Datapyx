# AIOS — Idee sparse

Appunti al volo su possibili miglioramenti ad AIOS, presi così come vengono in
mente — senza filtro, senza struttura obbligata. Non sono impegni né design:
è materiale grezzo da rivedere e, quando matura, trasformare in un
brainstorming vero (`superpowers:brainstorming`) o promuovere a
[ROADMAP.md](ROADMAP.md).

Formato libero: data + idea in una o due righe. Aggiungi in fondo, non
riordinare.

---

## 2026-07-15

- **Multiaccesso ai file AIOS da più utenti** — gestione di più utenti/persone
  che lavorano sullo stesso AIOS. ✅ Design completo (2026-07-16): modello a 3
  zone di scrittura, promozione automatica contradiction-gated che riusa il
  motore `aios-learn` sullo strato lezioni, deployment host-agnostico. Vedi
  `docs/superpowers/specs/2026-07-15-aios-learn-design.md` §"Estensione:
  arricchimento multi-operatore". Prossimo passo: piano d'implementazione
  di `aios-learn` (prerequisito), poi l'estensione sopra.
- **BrandKit — evoluzione via questionario** — integrare in AIOS un sistema
  per la generazione del brand basato su un questionario strutturato. Esiste
  già un documento con la struttura del questionario da porre (materiale
  pronto, da recuperare). Nota: esiste già la skill `brandkit` nel plugin —
  valutare se questa idea la estende o la sostituisce.
- **Neuromarketing per la generazione di contenuti** — sezione/skill che
  sfrutta tecniche di neuromarketing nella realizzazione di contenuti.
  Materiale già disponibile da riutilizzare.
- **Analisi SEO siti web / ecommerce** — nuova sezione che analizza SEO
  incrociando dati dal sito live e scansioni fatte con ScreamingFrog.

## 2026-07-20

- **«L'Impronta» come percorso separato del Livello 1 (Contesto)** — aggiungere
  l'intervista «L'Impronta» (5 file: `identita`, `offerta`, `clienti`,
  `tono-di-voce`, `come-lavoriamo`) come **skill standalone** (`/impronta`), NON
  integrata dentro `aios-context`. Motivi: il registro caldo/rassicurante è
  incompatibile con l'interviewer rigoroso attuale (che *sfida i numeri* per il
  DataOS); serve un utente più leggero ("un'AI che scrive come me") senza
  strategia/KPI/dati; riempie il buco dell'**identità verbale** — oggi il Contesto
  ha solo quella visiva (brandkit) e quella operativa (aios-context). Idea di
  forma: skill autonoma ~15 min, offerta dall'orchestratore come **bivio** al
  Livello 1 (percorso completo vs Impronta), componibile; `tono-di-voce.md` letto
  da `/prime` e `aios-automation`. Due decisioni da chiudere prima (via
  `superpowers:brainstorming`): (1) **namespace file** — `identita/offerta/clienti`
  si sovrappongono ad `azienda.md`, decidere casa unica per evitare
  duplicati/contraddizioni (`tono-di-voce.md` e `come-lavoriamo.md` sono netti
  nuovi); (2) **ownership della voce** — `tono-di-voce.md` è core strategico (solo
  curatore) o zona lezioni (arricchibile dagli operatori)? impatto multi-operatore.
  Il prompt sorgente di riferimento è «L'Impronta» (fornito da M.). Stato: in
  decisione, non ancora avviato.
- **Rename globale di AIOS (cambio di tutti i nomi)** — rinominare il
  prodotto/plugin cambiando tutti i nomi. Nuovo naming **da definire** (e se anche
  "DataPyx" cambia). Ambito da mappare quando si parte: `.claude-plugin/plugin.json`
  + `marketplace.json`; nomi skill (`aios`, `aios-context`, `aios-data`,
  `aios-intel`, `aios-automation`, `aios-dashboard`, `aios-learn`) e namespace
  `aios:*`; comandi (`/aios`, `/aios-help`, …); doc (README, GUIDE, ROADMAP, IDEE);
  riferimenti incrociati skill-to-skill e path `.claude/aios-build.md`,
  `aios-feedback-prodotto.md`, ecc.; nome repo GitHub `CinaWeb/AIOS-Datapyx`.
  Coordinare con l'item precedente: decidere se fare prima il rename (così
  «L'Impronta» nasce già col nome nuovo) o dopo, per non rinominare due volte.
  Stato: in decisione, non ancora avviato.

## 2026-07-25

Le tre voci qui sotto vengono da un confronto fatto in FullBrain fra l'AIOS di
Fontanel (da cui questo plugin parte) e quattro fonti sull'Agentic OS ingerite il
2026-07-25 — Chase AI (4 livelli), Jack Roberts (5), Nufar Gaspar (7), paper
agiresearch. Riferimento: `wiki/queries/aios-fontanel-vs-altre-fonti.md`.

- **Postura sui permessi verso i sistemi esterni (livello «Connections»)** — oggi
  assente: cercando `MCP`, `read-only`, `permessi` nel plugin non c'è nulla, a
  parte le tre zone di scrittura del multi-operatore (che è governance fra
  operatori, non sicurezza verso l'esterno). Eppure `aios-intel` chiama le API dei
  tool di meeting, `aios-data` legge CRM/Sheet/PayPal e le automazioni scrivono.
  La gestione dei **segreti** è già corretta (`.env` git-ignorato, mai in chat o
  nel DB); manca la scelta degli **scope**: chiedere prima accesso in sola
  lettura, aggiungere la scrittura solo dopo aver osservato il comportamento.
  Da aggiungere anche in `aios-automation` la regola che un'automazione produce
  **bozze da rivedere** e non output che partono verso terzi senza approvazione
  (caso concreto: `invoice create` che manda la fattura al cliente). Costo:
  testo nei prompt di 2-3 skill, nessuna infrastruttura. Fonte: Gaspar (livello 5
  e 7). Stato: da valutare.

- **`/aios-check` — verifica di salute dell'AIOS** — `/challenge` fa red-team di
  un *giudizio*, ma nulla controlla lo stato del **sistema**. Gaspar: senza audit
  periodico un agent OS ha una vita utile di ~8 settimane. I dati per farlo ci
  sono già e non vengono mai riletti: `.claude/log.md`, gli stati `⬜`/`✅` di
  `automations/roadmap.md`, il frontmatter `created:`/`updated:` su tutti i file,
  `lezioni.md`. Domande da coprire: quali automazioni non sono mai state lanciate?
  quali file di contesto non si toccano da mesi? quali voci di roadmap sono ferme?
  quali lezioni si contraddicono? Alto valore, costo basso (quasi solo lettura di
  artefatti esistenti). Valutare se comando a sé o estensione di `/debrief`.
  Stato: da valutare.

- **Terza via per l'audit dei task: leggere i log invece di chiedere** — oggi
  `aios-automation` fa l'audit solo per intervista area per area. Chase AI: le
  persone non sanno rispondere a "cosa fai ripetutamente", quindi conviene
  leggere le sessioni passate ed estrarre i task realmente ricorrenti. Il
  materiale c'è già (`.claude/log.md` per cliente, più la history di sessione di
  Claude Code). Da aggiungere in `references/audit-guide.md` come terza opzione
  **accanto** all'intervista, non al posto suo. Stato: da valutare.

## 2026-07-26

Le cinque voci qui sotto vengono dal **workshop Company Brain di Michele Cotti**
(4 serate, 20-23 luglio 2026), ingerito in FullBrain il 2026-07-25. Riferimenti:
`wiki/sources/workshop-company-brain-cotti.md` e i concept `dream-cycle`,
`ai-act-adempimenti-deployer`, `orbit-framework`. ⚠️ La fonte è una trascrizione
ASR rumorosa di un webinar commerciale (`confidence: medium`): si prendono le
idee architetturali, **non** numeri, citazioni o riferimenti normativi.

- **Le procedure devono essere il binario delle automazioni** — è il buco più
  netto. `procedure.md` esiste ma è opzionale e nasce nel Livello 1
  (`aios-context/SKILL.md:74`); `aios-automation` **non lo nomina mai** (nessun
  match su "procedur" in `SKILL.md`, `audit-guide.md`, `build-guide.md`):
  l'audit reintervista da zero cose già scritte. Due interventi distinti:
  (a) `aios-automation` step 1 legge anche `procedure.md` e ci fa partire
  l'audit; (b) se un task da automatizzare **non ha** procedura scritta, la si
  scrive prima di costruire lo script (è lo strumento "Il Primo Ingranaggio"
  della serata 3: da "come si fa" parlato a procedura scritta).
  ⚠️ **Decisione architetturale da chiudere**: Cotti mette la logica nel markdown
  letto a runtime («cambio una riga in italiano e l'automazione si aggiorna»),
  la disciplina DOE del plugin la vuole deterministica **nello script**
  (`aios-automation/SKILL.md:39`). Riconciliazione proposta: la logica
  deterministica resta in Python, ma la **direttiva** (`.claude/commands/<n>.md`)
  deriva da `procedure.md` e lo cita — cambiare la procedura cambia la SOP senza
  toccare lo script. Da validare prima di implementare. Stato: da valutare.

- **Dream Cycle — manutenzione periodica del brain (confluisce in `/aios-check`)**
  — si sovrappone alla voce `/aios-check` del 25/7 (fonte Gaspar) ma aggiunge
  tre cose che quella non ha: (1) una **tassonomia già fatta** in 6 funzioni —
  riordino, arricchimento selettivo, riparazione/fusione duplicati, ricerca
  contraddizioni, auto-ottimizzazione, agenda del giorno dopo; (2) un **criterio
  meccanico di arricchimento**: un nome citato una volta resta una riga, se
  ricorre 3-4 volte in giorni diversi diventa una scheda completa;
  (3) l'**auto-ottimizzazione** — dove il sistema ha faticato si scrive una
  regola nuova. Oggi `aios-learn` impara **solo** quando un touchpoint la invoca
  con l'umano in sessione: nessuno rilegge mai `log.md`, gli stati `⬜/✅` di
  `automations/roadmap.md` o i `updated:` del frontmatter.
  Cautela dichiarata dalla fonte: demo commerciale, codice mai mostrato, "il
  brain decide da solo cosa è importante" è facile da raccontare e difficile da
  rendere stabile. Proposta: implementare le funzioni deterministiche (3, 4, 6)
  come lettura + report, e trattare 2 e 5 come **proposte in HITL**, coerenti col
  cardine "mai scrittura silenziosa" di `aios-learn`. Da decidere anche il
  regime: on-demand (come `/debrief`) o schedulato. Stato: da valutare.

- **Livello compliance come deliverable per il cliente** — buco totale nel
  plugin: `gdpr`/`ai act`/`compliance` compaiono solo in `brandkit`, per altro.
  La serata 4 è stata aggiunta fuori programma proprio perché la conformità è
  **l'obiezione numero uno delle PMI**: qui è insieme un adempimento e un pezzo
  vendibile. Artefatti da produrre per il cliente: registro di alfabetizzazione
  AI (art. 4), policy interna di una pagina (chi usa l'AI, con quale account, per
  cosa), riga sul registro dei trattamenti, elenco degli usi ad alto rischio da
  non fare. Dettaglio degli obblighi e delle modifiche al plugin nel blocco
  «Conformità normativa» più sotto. Stato: da valutare.

- **Ingest grezzo — abbassare il costo d'ingresso del Livello 1** — strato 1 di
  Cotti: *nessuna pre-organizzazione richiesta*, i documenti si buttano dentro
  disordinati ed è l'AI a leggerli e ordinarli. Serve a rimuovere l'obiezione che
  blocca tutti ("prima dovrei sistemare 20 anni di roba"). Oggi `aios-context`
  entra per **intervista** (+ import documenti): un percorso "svuota la cartella
  qui, poi ti chiedo solo quello che manca" produce una prima bozza dei file di
  contesto e riduce l'intervista alle lacune. Si combina con «L'Impronta» (voce
  del 20/7): sono due bivi diversi dello stesso Livello 1 — identità verbale vs
  raccolta grezza. Stato: da valutare.

- **Il brain che obietta (interconnessione ai punti di decisione)** — l'esempio
  più efficace del workshop: alla richiesta di un'offerta il brain **si ferma** —
  "questo cliente ha due fatture aperte, manda l'offerta dopo il saldo" — senza
  che nessuno glielo abbia chiesto. Nel plugin le prospettive proattive di
  `aios-learn` esistono ma scattano a `/prime` (apertura sessione) e leggono
  `lezioni.md`, non il DB. Serve un check **nel momento della decisione**, che
  incrocia DataOS (insoluti, pagamenti, storico) col contesto prima che
  un'automazione produca un output verso il cliente. Si aggancia alla voce del
  25/7 sulle "bozze da rivedere". Stato: da valutare.

**Minori dallo stesso workshop** (non aprono voci proprie): *routing per costo* —
modelli leggeri per il lavoro meccanico e voluminoso, modello che ragiona solo per
giudizio e sintesi; il plugin non dice nulla sulla scelta del modello e diventa
rilevante se si costruisce il ciclo di manutenzione, è ciò che lo rende
sostenibile. *Alimentazione continua* — "ogni mail e preventivo nuovo entra da
solo": oggi `aios-intel` porta dentro solo i meeting e `aios-data` solo metriche,
mail e documenti non entrano mai. *Conferma indipendente sui permessi* — lo strato
4 nomina esplicitamente MCP, sola lettura vs scrittura e accessi per operatore: la
voce del 25/7 ha ora due fonti indipendenti, priorità da alzare.

**Da non cercare**: **ORBIT** (il framework di automazione dell'autore) è uno stub
deliberato nel wiki — citato più volte, mai esposto in nessuna delle 4 serate, il
contenuto sta dietro il pass a pagamento. Non c'è niente da prendere.

## 2026-07-26 — conformità normativa dell'AIOS

Ricognizione delle pagine normative in FullBrain (`wiki/concepts/`: `gdpr`,
`gdpr-basi-giuridiche`, `eu-ai-act`, `trasparenza-art-50-ai-act`,
`ai-act-adempimenti-deployer`, `nis2-directive`, `compliance-adattiva`) applicata
a **cosa deve fare il plugin**. Le pagine GDPR/AI Act/NIS2/art. 50 sono
`confidence: high` su testi ufficiali; `ai-act-adempimenti-deployer` e la
L. 132/2025 vengono dal workshop Cotti (`medium`, ASR) e vanno riverificate.

⚠️ **Scadenza vicina**: il 2 agosto 2026 scatta l'**applicazione generale**
dell'AI Act e l'obbligo di trasparenza dell'**art. 50**. L'art. 4
(alfabetizzazione) è invece in vigore **dal 2 febbraio 2025** — già scaduto da
oltre un anno.

### Il punto di partenza: che ruolo ha chi usa AIOS

L'AI Act (art. 3) distingue **fornitore** (chi costruisce e immette sul mercato)
da **deployer** (chi usa il sistema nella propria attività). Il cliente che usa
l'AIOS sui propri documenti è deployer: regime leggero, un solo adempimento
generale (art. 4). Le sanzioni finora hanno colpito fornitori, non aziende per
l'uso ordinario.

⚠️ **Domanda aperta, non risolta**: distribuire AIOS come plugin pubblico e
installarlo presso i clienti fa diventare **fornitore** chi lo pubblica? L'AIOS
non è un modello, è orchestrazione di un sistema di terzi — ma la definizione di
"sistema di AI immesso sul mercato con il proprio nome" va letta sul testo prima
di dare per scontato il regime leggero. **Da chiarire prima del rename globale e
prima di decidere la visibilità del repo** (entrambe già in backlog).

### Obblighi che ricadono davvero sull'AIOS di un cliente

- **Art. 4 AI Act — alfabetizzazione** (dal 2 feb 2025): unico adempimento
  generale del deployer. Non servono corsi accreditati, serve poter
  **dimostrare** che la formazione c'è stata (registro interno di date,
  contenuti, partecipanti). Affidarsi alle sole istruzioni d'uso rischia di non
  bastare.
- **GDPR — registro dei trattamenti e informativa**: quando l'AI lavora su dati
  personali serve la riga sul registro (documento che il GDPR chiede da anni) e
  una riga in più sull'informativa. La mappatura completa degli usi AI **non è
  imposta oggi** — consigliata, non obbligatoria (attenzione a chi la vende come
  obbligo).
- **GDPR art. 5 — minimizzazione**: nei prompt solo i dati che servono; per molte
  analisi il nome vero del cliente non serve affatto.
- **Tipo di account, non modello**: account consumer → i contenuti possono essere
  usati dal fornitore, addestramento incluso; account di lavoro (Team/Enterprise)
  → per contratto non possono, input e output restano del cliente. In termini
  GDPR il fornitore AI è **responsabile del trattamento** (art. 28) con DPA,
  stesso schema di posta e gestionale in cloud.
- **Art. 50(4) — trasparenza sui contenuti** (dal 2 ago 2026): il deployer deve
  dichiarare artificiali deep fake e **testi di interesse pubblico**, salvo
  **doppia condizione cumulativa**: revisione umana sostanziale **e**
  responsabilità editoriale pubblicamente identificabile. Riguarda direttamente
  le automazioni che generano articoli e contenuti social.
- **GDPR art. 22 + alto rischio AI Act**: usare l'AI per **decidere sulle
  persone** (screening CV, valutazione o sorveglianza dei dipendenti) fa scattare
  un regime pesante. Fuori scope per l'AIOS: va rifiutato, non gestito.
- **L. 132/2025 (Italia)**: informazione ai lavoratori sull'uso dell'AI che li
  riguarda e — rilevante per il target di AIOS — **dovere dei professionisti
  (avvocati, commercialisti, consulenti) di comunicare al cliente in linguaggio
  chiaro l'impiego di sistemi di AI**. ⚠️ Fonte unica e indiretta, nessuna pagina
  wiki propria: da verificare su testo ufficiale.
- **NIS2**: non riguarda l'AI ma il cliente. Se è soggetto essenziale/importante
  (Allegato I/II, ≥50 dipendenti **o** >10M€), l'AIOS entra nella sua supply
  chain ICT e ne eredita i requisiti verso i fornitori. Va **rilevato**, non
  gestito dal plugin.

### Modifiche concrete al plugin

- **`aios-context`** — al setup chiedere e registrare: (a) con che **account**
  lavora il cliente (consumer vs Team/Enterprise) e avvisare se mette dati di
  clienti in un account personale; (b) screening NIS2 in una domanda (settore +
  soglia dimensionale); (c) se il cliente è un professionista ordinistico
  (L. 132/2025). Genera `.claude/context/compliance.md` con l'esito.
- **`aios-data`** — `references/discovery-guide.md` oggi chiede solo cose
  tecniche. Aggiungere per **ogni sorgente**: contiene dati personali? con quale
  finalità e base giuridica? per quanto si conservano? CRM e PayPal sono
  certamente sì. È il materiale che alimenta la riga del registro dei
  trattamenti.
- **`aios-intel`** — i transcript dei meeting sono dati personali **di terzi**
  che spesso non hanno acconsentito alla registrazione, e oggi finiscono nella
  tabella `meetings` senza limite di conservazione. Serve una policy di
  retention esplicita e una domanda al setup.
- **`aios-automation` / `audit-guide.md`** — tre aggiunte: (1) **lista di usi
  fuori scope** (decisioni sulle persone) che fanno fermare l'audit invece di
  entrare in roadmap; (2) per ogni automazione di outreach o scoring, chiedere e
  registrare la **base giuridica** — il consenso non è l'unica né sempre la più
  appropriata, e *segmentazione ≠ profilazione* (la seconda ricade nell'art. 22);
  (3) le automazioni che **generano contenuti pubblicabili** producono bozze con
  **revisione umana registrata** — che è esattamente la condizione di esenzione
  dell'art. 50(4), oltre che buon senso. Questo dà una **ragione giuridica**, non
  solo prudenziale, alla voce "bozze da rivedere" del 25/7.
- **Regola trasversale sulla minimizzazione** — nei prompt di `datapyx`,
  `aios-data` e `aios-intel`: usare identificativi al posto dei nomi quando
  l'analisi non richiede la persona reale.
- **Deliverable per il cliente** (la voce «livello compliance» sopra): registro
  formazione art. 4, policy interna di una pagina, riga per il registro dei
  trattamenti, riga per l'informativa. Quattro artefatti brevi, generabili dal
  contesto già raccolto.

### Come implementarla — principio di design

`concepts/compliance-adattiva` dà l'indicazione più utile: la compliance reale è
una **proprietà emergente del sistema**, non un documento. Tradotto qui: **non**
fare una skill-checklist che produce un PDF che nessuno legge, ma mettere i gate
dentro il flusso dove la decisione avviene (la domanda sull'account al setup, la
base giuridica al momento in cui si costruisce l'automazione di outreach, la
revisione umana prima della pubblicazione) — così il percorso conforme è quello
naturale. Stato: da valutare, insieme alla voce «livello compliance».

## 2026-07-26 — follow-up dalla review di v0.7.0

Rilievi emersi dalla review finale del branch `feat/permessi-e-bozze` (PR #9,
mergiata) e giudicati **non bloccanti** per il rilascio. I cinque problemi seri
sono stati corretti prima del merge; questi restano. Non sono bug: sono punti in
cui la regola è scritta in modo che potrebbe non scattare, o in cui il testo dice
meno di quanto servirebbe.

### Dove la regola potrebbe non scattare

- **`aios-automation`, sezione «Automazioni di contenuto»** — è il capitolo che
  Claude legge proprio quando costruisce le automazioni a destinatario esterno
  (blog, newsletter, social, comunicazioni esterne), e non rimanda alla nuova
  sezione sulle bozze. Mezza riga di rimando nel punto di massima resa.
- **Il carve-out sul test reale sta solo nel blocco deroga** — il passo che
  impone il «test reale» (`aios-automation/SKILL.md` §6 e `build-guide.md` passo
  5) non lo richiama. Stessa dinamica «scritto due passi prima» già corretta
  altrove, in forma più tenue.
- **Il fallback «se il file non esiste» sta dentro il passo 3, che è saltabile**
  («salta questo passo per automazioni che lavorano solo su `database.db` e file
  locali»). La seconda menzione di `connessioni.md`, nel blocco deroga, non ha
  fallback. Il controllo `grep -c` della verifica statica conta per file, non per
  menzione: maschera esattamente questo caso.

### Dove il testo dice meno di quanto servirebbe

- **«Il probe verifica *cosa può fare* la credenziale» non dice come.** Per la
  maggior parte delle API lo scope non è ispezionabile da uno script: non c'è un
  endpoint di introspezione. Così com'è, l'istruzione invita a un'asserzione non
  verificabile — proprio ciò che la disciplina DOE del plugin vieta. Da
  riformulare: chiedilo all'utente, verificalo solo se l'API lo permette, e
  annota che è dichiarato.
- **Canali senza il concetto di «bozza»** — WhatsApp, Slack esterno, un webhook
  verso un partner, un blog. La sezione enumera bozza Gmail / PDF / record, ma
  non definisce il fallback: produrre il contenuto in file o record e lasciare
  l'invio come secondo gesto.
- **Effetto collaterale della regola sugli scope non separabili** — una chiave a
  pieni poteri usata in sola lettura ora si registra come `scrittura`, quindi la
  frase «chiedi la scrittura solo quando serve, e fattelo confermare» può
  scattare a vuoto su quella sorgente. Da chiarire.
- **La struttura canonica in `aios-context` è più povera di ciò che le tre skill
  istruiscono a creare**: non mostra frontmatter né titolo, e non definisce le
  colonne `Usata da` e `Dal` — che infatti contengono cose eterogenee (nomi di
  skill per i livelli 2 e 3, nomi di comando per il livello 4). Chi crea il file
  leggendo solo la sezione canonica produce un artefatto diverso da chi legge una
  delle tre fette.

### Idea nuova emersa dalla review

- **La dashboard non distingue i comandi con deroga.** `aios-dashboard` genera un
  bottone per ogni `.claude/commands/*.md`: un `/invia-preventivo` con invio
  automatico attivo appare come qualunque altro bottone, cliccabile da un
  collaboratore non tecnico. Era fuori scope dichiarato del design, ma è il
  candidato naturale per `/aios-check` (voce del 25/7): «quali comandi mandano
  davvero qualcosa all'esterno, e chi può premerli».

### Cosmetici

`connessioni.md` non compare negli schemi di cartella di README e GUIDE, pur
essendo presentato nel README come «lo stato corrente di cosa l'AIOS può fare
fuori» · le date d'esempio sono letterali (`2026-07-26`, `2026-07-28`) mentre il
resto del plugin usa il placeholder `YYYY-MM-DD`, con un piccolo rischio di copia
alla lettera · `aios-automation/SKILL.md` cita `build-guide.md` come nome nudo
dove altrove usa `references/build-guide.md` · la sezione nuova del README è
finita sotto il titolo «Le due discipline», che di discipline ne annuncia due ·
il titolo in GUIDE «**Cosa non fa mai da sola**» dice «mai» mentre il corpo
ammette subito la deroga, ed è l'unica riga che un lettore non tecnico si
ricorderà.

