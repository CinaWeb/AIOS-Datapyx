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

