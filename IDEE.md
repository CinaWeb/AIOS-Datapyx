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

