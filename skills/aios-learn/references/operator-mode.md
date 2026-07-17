# aios-learn — Modalità operatore (async)

Come si comporta `aios-learn` quando il segnale arriva da un **operatore** via
`/contribuisci` (tipicamente lanciato dalla dashboard, headless) invece che dal
consulente dentro una sessione.

Differenza in una riga: **nessun umano è presente a confermare**, quindi il
protocollo HITL di `SKILL.md` non è applicabile così com'è. Non sparisce: si
sposta sulle sole **contraddizioni**. Il non-contraddittorio è implicitamente
approvato ed entra da solo; il contraddittorio è l'unica cosa che aspetta un
umano.

La modalità consulente (HITL su ogni cattura) **non cambia**: se sei lì, quella
resta la regola.

## Flusso

Ricevi **autore** + **contributo** (testo libero dell'operatore).

1. **Classifica** — lezione di business o frizione di processo? Stessi criteri di
   `capture-guide.md`, nessuna variante.
   - **Frizione di processo** → append in `.claude/aios-feedback-prodotto.md` come
     sempre, citando l'autore. Non passa dal contradiction-gate: quel file non è
     il core di nessuno.
   - **Lezione di business** → prosegui al passo 2.
2. **Contradiction-check** — vedi sotto.
3. **Non contraddice** → **append automatico** nello strato lezioni
   (`.claude/context/lezioni.md`, o il file di settore giusto se già splittato),
   con attribuzione. Nessuna conferma.
4. **Contraddice** → **non scrivere in `lezioni.md`**. Crea un file nella coda
   conflitti (formato sotto). Il curatore lo risolve con `/rivedi-proposte`.
5. Rispondi all'operatore dicendo cosa è successo: promosso (e dove) o messo in
   coda (e cosa contraddice). L'operatore non deve restare al buio.

**Dove atterra, sempre:** lo **strato lezioni**. L'enrichment automatico non
scrive **mai** nel core strategico (`.claude/context/azienda.md`, `strategia.md`,
`procedure.md`): quello resta curatore-only. Le lezioni sono progettate per
crescere — hanno già lo split per settore — il core no: diluirlo è il danno che
questo gate esiste per evitare.

## Contradiction-check

Confronta il contributo contro, in quest'ordine:

1. **Core strategico** — `.claude/context/*.md`, in particolare `azienda.md`,
   `strategia.md`, `procedure.md`.
2. **Lezioni esistenti** — `.claude/context/lezioni.md` o `.claude/context/lezioni/`.

**Contraddice** se afferma il **contrario** di qualcosa di esplicito in quei file:
- nega un fatto dichiarato ("il churn è sul retail" vs `dati-correnti.md` che dice
  enterprise);
- inverte una priorità o una strategia ("le fiere non portano niente" vs
  `strategia.md` che le chiama canale primario);
- prescrive un metodo incompatibile con `procedure.md` ("i preventivi li mando
  direttamente" vs "sempre validati dal socio").

**Non contraddice** se:
- aggiunge un fatto su un'area non trattata;
- precisa/dettaglia qualcosa di già noto senza ribaltarlo;
- riguarda un caso particolare che convive con la regola generale.

**Nel dubbio → coda.** Il costo di una proposta in coda è una revisione in più; il
costo di un append sbagliato è il core che perde coerenza senza che nessuno se ne
accorga. L'asimmetria è voluta.

## Formato — entry promossa in `lezioni.md`

Identico a quello di `capture-guide.md`, con l'autore sulla riga `fonte:`:

```
## [2026-07-17] fonte: /contribuisci · autore: Marco
I lead da fiera vanno richiamati entro 48h o si raffreddano.
→ Pianificare il richiamo in agenda il giorno stesso della fiera.
```

Aggiorna `updated:` nel frontmatter, come per ogni append.

## Formato — coda conflitti

Un file per conflitto → zero collisioni, anche con più operatori in parallelo.
Path: `enrichment/proposals/AAAA-MM-GG-autore-slug.md` (cartella top-level della
working dir, sorella di `automations/`; creala se non esiste).

```markdown
---
autore: Marco
data: 2026-07-17
stato: pendente
---
# Proposta — i lead da fiera non chiudono

## Contributo
I lead raccolti in fiera non chiudono quasi mai, ci perdiamo tempo.

## Regola che ne deriverebbe
→ Ridurre l'investimento sulle fiere e spostarlo su referral.

## Contraddice
`.claude/context/strategia.md` — "le fiere sono il canale di acquisizione
primario per il 2026". Il contributo afferma il contrario.
```

- `stato:` è `pendente` alla creazione; diventa `promossa` o `rifiutata` alla
  revisione. Il file **resta dov'è**: è la traccia storica di cosa è stato
  proposto e come è finita.
- Non modificare mai il campo `Contributo` di una proposta esistente: se il
  curatore riformula, la riformulazione va nella entry di `lezioni.md`, e la
  proposta si chiude come `promossa`.

## Revisione (invocata da `/rivedi-proposte`)

Per ogni file con `stato: pendente`, mostra al curatore contributo, regola
derivata e cosa contraddice, poi applica la sua scelta:

- **Promuovi** → append in `lezioni.md` (formato sopra, `fonte: /contribuisci ·
  autore: X`), poi `stato: promossa`.
- **Rifiuta** → `stato: rifiutata`, aggiungendo in fondo al file una sezione
  `## Esito` con il motivo in una riga. Niente append in `lezioni.md`.
- **Modifica** → riformula con il curatore, poi come "promuovi": in `lezioni.md`
  va il testo riformulato, la proposta si chiude come `promossa`.

Se la contraddizione rivela che è **il core** ad essere superato (non il
contributo ad essere sbagliato), dillo esplicitamente e proponi al curatore di
aggiornare il file di contesto: quella scrittura è sua, con HITL, mai automatica.

## Proposte in attesa (segnalazione da `/prime`)

Quando `aios-learn` è invocata da `/prime`, conta i file `stato: pendente` in
`enrichment/proposals/`. Se ce n'è almeno uno, aggiungi una riga sotto il
riepilogo:

```
2 proposte in attesa di revisione → /rivedi-proposte
```

Se non ce ne sono, o se `enrichment/` non esiste, non dire nulla. È una
segnalazione, non una cattura: nessun HITL.
