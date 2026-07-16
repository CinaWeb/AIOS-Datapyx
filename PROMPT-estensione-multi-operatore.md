# PROMPT — Estensione Multi-Operatore sopra `aios-learn` (handoff completo)

> **File di handoff/lavoro.** Non fa parte del rilascio del plugin: aggiungilo a
> `.gitignore` o cancellalo dopo l'uso — NON includerlo nella PR.
>
> **Chi sei:** una sessione Claude Code fresca che lavora in questo repo locale
> `C:\Users\M.Macelloni\Desktop\Progetti\_asernet\AIOS-Datapyx` (repo **LOCALE, non
> su Google Drive** → git qui è stabile). Questo documento ti dà **tutto** il
> contesto per implementare l'estensione "arricchimento multi-operatore" senza
> ripartire da zero. **Leggilo interamente prima di agire.**

---

## 0. Obiettivo

Implementare l'estensione **arricchimento multi-operatore** SOPRA la skill
`aios-learn` già esistente (v0.5.0, già in questo repo sul branch `feat/aios-learn`).

**La behavior è GIÀ DECISA** (vedi §3). Il design concettuale è chiuso: due domande
aperte risolte in due sessioni precedenti. Il tuo compito **NON** è ri-brainstormare
la behavior — è:

1. **Crystallizzare** il design deciso in file/comandi/formati concreti → una spec
   *buildable* in `docs/superpowers/specs/`.
2. Scrivere il **piano** in `docs/superpowers/plans/`.
3. **Implementarlo** e integrarlo via PR con bump versione.

Se ti ritrovi a chiedere all'utente "come deve comportarsi il multiutente?", **fermati**:
è già deciso qui sotto. Le uniche domande legittime sono sui *concreti* di §5 (nomi,
formati) — e anche lì proponi tu una soluzione seguendo i pattern del codebase, non
interrogare l'utente su cose derivabili.

---

## 1. Come lavorare (processo e vincoli)

- **Medium:** questo è un plugin di **skill/comandi in MARKDOWN** per Claude Code.
  NON è codice eseguibile, NON c'è pytest. La "verifica" di ogni modifica è:
  **check strutturali con `rg`/grep + walkthrough di scenario** (rileggere il file
  prodotto contro uno scenario concreto: "dato il segnale X, la skill instrada a Y").
  NON inventare un finto harness pytest: non testa il comportamento di un prompt.
- **Lingua:** tutti i contenuti generati per l'utente/clienti in **italiano**.
- **Processo (superpowers):**
  1. `superpowers:brainstorming` — usalo **solo** per crystallizzare il design deciso
     in una spec buildable (formati, nomi, quale file toccare). Le decisioni di §3
     sono **INPUT approvati**, non domande da riaprire.
  2. `superpowers:writing-plans` — piano no-placeholder (contenuto verbatim, path
     esatti, verifica = `rg` + walkthrough).
  3. `superpowers:subagent-driven-development` — esegui task per task (implementer +
     reviewer). Per la trascrizione di contenuto già scritto nel piano usa modelli
     economici.
- **Rilascio:** il plugin è **condiviso via Claude Cowork**. **NIENTE push diretto su
  `main`.** Flusso: branch → PR con **bump versione** in `.claude-plugin/plugin.json`
  (`feat` = minor, quindi **0.5.0 → 0.6.0**) → merge. Cowook sincronizza la marketplace
  solo al merge di una PR con bump. Vedi la memoria §7.
- **Git:** questo repo NON è su Google Drive → nessun hazard di lock. (La copia su
  Drive `G:\Il mio Drive\Progetti\aios-plugin` invece corrompe git nelle operazioni
  multi-step: NON usarla per push/PR.)

---

## 2. Cosa è GIÀ FATTO — `aios-learn` (v0.5.0)

Il **motore di apprendimento** su cui poggia questa estensione. È già in questo repo.
Leggi i file reali: `skills/aios-learn/SKILL.md`, `skills/aios-learn/references/capture-guide.md`,
`skills/aios-learn/references/perspectives-guide.md`.

In sintesi, `aios-learn`:
- È una **skill interna** (nessun comando slash, invocata per nome da altre skill/comandi).
- Ha **due lane mai fuse**:
  - **Lezione di business** → `.claude/context/lezioni.md` (con frontmatter
    `created:`/`updated:`), letto da `/prime` ogni sessione.
  - **Frizione di processo** → `.claude/aios-feedback-prodotto.md` (senza frontmatter,
    stile `log.md`), per il maintainer del plugin — **mai** letto da `/prime`, **mai**
    promosso automaticamente nel codice del plugin.
- **Protocollo HITL OBBLIGATORIO su ogni cattura**: mostra il testo esatto + il file
  di destinazione, attende conferma esplicita, poi scrive in append. **Mai scrittura
  silenziosa.** (⚠️ QUESTO è il punto che l'estensione deve estendere — vedi §4.)
- **Scrittura append-only**; **split** di `lezioni.md` per settore su soglia (~15-20
  entry), su conferma.
- **Prospettive proattive** ad ogni `/prime` (output mostrato, NON una cattura, NO HITL).
- **Touchpoint** (solo puntatori, sanno solo *quando* chiamare): `commands/challenge.md`
  (verdetto 🔴/🟡), `commands/debrief.md` (contraddizione confermata), `skills/datapyx/SKILL.md`
  (correzione a diagnosi), e i 4 livelli (`aios-context/data/intel/automation`) per le
  frizioni di processo.

**Documentazione già aggiornata:** README.md (§"Motore interno", §"Memoria persistente"
con la memoria procedurale) e GUIDE.md (§"L'AIOS impara dai tuoi feedback").

---

## 3. Design DECISO dell'estensione (NON riaprire — è l'input approvato)

Fonte: `docs/superpowers/specs/2026-07-15-aios-learn-design.md` §"Estensione:
arricchimento multi-operatore" (in questo repo) + le decisioni prese in sessione.

**Problema:** AIOS come brain aziendale condiviso da più **operatori** (comunicazione,
lead, post) che devono anche **arricchirlo**, senza che tante mani rompano il core
curato né creino silos.

**Modello a 3 zone di scrittura (non una sola folder):**
1. **Core strategico curato** (`.claude/context/azienda.md`, `strategia.md`,
   `procedure.md` — ciò che `/prime` carica come identità). Poche entità, alta coerenza.
   **Sola lettura per tutti; scrivibile SOLO dal curatore.** L'enrichment automatico
   **NON entra qui** (lo diluirebbe).
2. **Zona arricchimento append-only** (output automazioni + tabelle DB). Gli operatori
   **non editano file a mano**: lanciano comandi via **dashboard**. L'output va in file
   timestampati (`automations/<nome>/output/AAAA-MM-GG-autore-*.md`) o come riga in
   `data/database.db`. **AIOS lo fa GIÀ** → un file per output = zero collisioni. Non
   tocca il core.
3. **Inbox conflitti** (`enrichment/proposals/`, NUOVO). Con la promozione automatica
   (sotto), si restringe alla **sola coda delle contraddizioni**, non è la coda di tutto.

**Le 6 decisioni (chiuse):**
1. **Chi contribuisce:** operatori, via **comandi lanciati dal dashboard** (non
   editano file a mano).
2. **Motore:** la promozione **NON è un comando nuovo di validazione** — è lo **stesso
   `aios-learn`** con una **nuova sorgente di segnale** (i contributi degli operatori),
   oltre a challenge/debrief/datapyx.
3. **Regola (contradiction-gated):** contributo che **non contraddice** il core →
   promosso **in automatico** nello strato lezioni; contributo che **contraddice** →
   messo in **coda conflitti** per revisione **asincrona** del curatore.
4. **HITL spostato:** da "conferma su OGNI scrittura" a "conferma **solo sulle
   contraddizioni**". In multi-utenza asincrona nessuno è presente a confermare in
   tempo reale → il non-contraddittorio fluisce da solo (mantiene il "filone" vivo),
   solo il contraddittorio va in coda.
5. **Dove atterra:** **strato lezioni** (`.claude/context/lezioni.md` → `lezioni/`),
   che è **progettato per crescere** (ha già lo split-by-sector). **Mai** il core
   strategico.
6. **Deployment host-agnostico:** il design NON sceglie l'host (NAS con snapshot,
   server aziendale, VM). Contratto = due ruoli (stessa macchina o separati):
   **Storage** (cartella AIOS in un'unica copia viva + backup/snapshot) e **Compute**
   (processo always-on che esegue l'engine headless e serve la dashboard in rete).
   Backup a due livelli complementari: snapshot filesystem (disaster recovery) + git
   sotto `/commit` (rollback logico + attribution). **Unico requisito sul CODICE:**
   rendere host/porta di bind della dashboard **configurabile** (oggi hardcoded
   `127.0.0.1`). Il resto è configurazione di deployment.

**Ruolo del "curatore":** quasi sparisce. Resta solo come **revisore asincrono della
coda conflitti** + detentore di `/commit`/rollback (InfraOS). Una sola istanza viva
condivisa, non cloni per macchina.

**⚠️ Alternativa già CONSIDERATA E SCARTATA:** usare **branch/PR di Git come meccanismo
di promozione** (curatore = reviewer della PR). Scartata perché gli operatori sono
**non tecnici**: parlare di git/PR a chi arricchisce è un rischio tecnico e di
esposizione. Il design è **evoluto** in inbox + promozione automatica, più adatta.
NON riproporre la via PR-come-promozione: è stata valutata e superata.

---

## 4. Il delta di design chiave: modalità operatore/async di `aios-learn`

Questo è il punto che tocca ciò che è già costruito, ed è la parte più delicata.

`aios-learn` **oggi** opera in **modalità consulente/sincrona**: invocato da un
touchpoint *dentro la sessione del consulente*, con **HITL obbligatorio** (mostra,
attende conferma, scrive). Il consulente è presente, la conferma è a costo zero.

Il multi-operatore richiede una **modalità operatore/async** (nuova) in cui:
- l'invocazione avviene **headless**, senza umano presente a confermare;
- **classifica** il contributo (lezione business vs frizione processo — stessa logica
  di `capture-guide.md`);
- **controlla la contraddizione** col core (legge `.claude/context/`, confronta);
- **path non-contraddittorio** → **auto-promuove**: append in `lezioni.md` con
  **attribuzione autore+data**, SENZA conferma (è il "HITL spostato" del §3.4);
- **path contraddittorio** → **NON** scrive in `lezioni.md`; scrive un file nella
  **coda conflitti** (`enrichment/proposals/`) con il contributo proposto, l'autore,
  e *quale parte del core contraddice*, per la revisione del curatore;
- **frizione di processo** → `aios-feedback-prodotto.md` come oggi.

Quindi in `skills/aios-learn/SKILL.md` (o in una reference dedicata tipo
`references/operator-mode.md`) va aggiunta esplicitamente questa **seconda modalità**,
mantenendo intatta quella sincrona/HITL esistente. Il cardine "mai scrittura
silenziosa" resta vero **per la modalità consulente**; in modalità operatore la
"conferma" è sostituita dal **contradiction-gate** (il non-contraddittorio è
implicitamente approvato; il contraddittorio è l'unica cosa che aspetta un umano).
Renderlo esplicito nel SKILL.md è essenziale per non introdurre un'incoerenza col
testo attuale.

---

## 5. Concreti da definire nella spec (scelte di IMPLEMENTAZIONE, non di behavior)

Proposte di partenza (seguono i pattern del codebase; conferma/raffina in
brainstorming-per-concreti, NON re-interrogare l'utente sulla behavior):

- **Comando di submit operatore:** un comando che il dashboard lancia headless con il
  contributo + l'identità dell'operatore, che invoca `aios-learn` in modalità
  operatore. Valuta se plugin-level o generato per-cliente in `.claude/commands/`
  (coerente con come nascono gli altri comandi cliente). Nome proposto: `/contribuisci`
  o `/enrich`.
- **Struttura coda conflitti:** `enrichment/proposals/AAAA-MM-GG-autore-slug.md`, un
  file per conflitto, con: contributo proposto, autore+data, regola che ne deriverebbe,
  e il riferimento del core che contraddice. Append-only per costruzione (un file per
  conflitto = zero collisioni).
- **Comando di revisione curatore:** es. `/review-proposals` — elenca i conflitti
  pendenti, il curatore per ciascuno decide (promuovi in `lezioni.md` / rifiuta /
  modifica). Valuta se agganciarlo a `/prime` (segnalazione "ci sono N proposte in
  attesa") o tenerlo separato.
- **Contradiction-check:** definisci COSA confronta `aios-learn` (il contributo vs
  `.claude/context/` strategico + `lezioni.md` esistenti) e come decide "contraddice
  sì/no" (giudizio LLM esplicitato con criteri, come per la classificazione).
- **Dashboard LAN + attribuzione:** in `skills/aios-dashboard/` rendere host/porta di
  bind **configurabile** (default `127.0.0.1`, opt-in LAN/host); catturare **quale
  operatore** sta agendo per l'attribuzione (identità passata al comando di submit).
- **Aggiornamento touchpoint/doc:** eventuale nuovo touchpoint dal dashboard verso il
  comando di submit; aggiornare README/GUIDE con la modalità multi-operatore.

---

## 6. Fuori scope (non introdurre)

- **Non** far entrare l'enrichment automatico nel **core strategico** (`context/azienda.md`,
  `strategia.md`, `procedure.md`) — solo strato lezioni.
- **Niente scheduling/cron** per la promozione: è **sincrona al submit** (il comando
  lanciato dal dashboard fa girare `aios-learn` subito). Coerente con la regola
  "no scheduling" già in `aios-learn`.
- **Niente** meccanismo di validazione/contraddizioni *ad-hoc* separato da `aios-learn`:
  si riusa il motore.
- **Niente** via PR-come-promozione (vedi §3, scartata per operatori non tecnici).
- **Niente** quantificazione ore/€/ROI da nessuna parte (vedi memoria §7,
  `feedback-datapyx-no-roi`).

---

## 7. MEMORIA DI PROGETTO (integrale — questo è il "brain" del progetto)

> Questi sono i fatti persistenti del progetto `aios-plugin`. Il repo su Desktop ha una
> memoria auto separata (path diverso); questi sono trascritti qui perché tu li abbia.

### 7.1 — Rilascio via PR con bump versione (feedback)
Prima di (o insieme a) pushare su `main`, aggiorna sempre `version` in
`.claude-plugin/plugin.json`. **Why:** senza bump, `/plugin marketplace update aios`
non rileva differenze — le modifiche restano invisibili a chi ha già il plugin.
**Cowork:** i push diretti su `main` NON triggerano il sync della marketplace; solo il
**merge di una PR con version bump** lo fa. **Decisione stabile:** il plugin è condiviso
via Cowork → **niente push diretto su main, sempre branch + PR + merge**. Semver: `fix`
→ patch, `feat`/nuove funzionalità → minor. Più feature accumulate senza rilascio
intermedio = un unico bump minor che le copre.

### 7.2 — `datapyx` niente ROI/ore (feedback)
Non proporre per `datapyx` (o per AIOS in generale) quantificazione ore/€ risparmiati,
inventari rosso/giallo/verde, calcoli di ROI/costo annuo del lavoro manuale. **Why:**
l'utente ha respinto esplicitamente questa direzione ("non mi serve capire costi tempo
ecc") — `datapyx` è diagnostico sistemico (reframe, JTBD, punti di leva, scenari), non
business-case/ROI accounting. **Applica:** scarta a priori componenti basate su
quantificazione tempo/denaro; per prioritizzare automazioni resta su criteri
qualitativi (frequenza, standardizzabilità, valore).

### 7.3 — Bozza "Company Brain" superata (progetto)
Il documento "Company Brain — Concept & Architettura" (2026-05-21) era una bozza
pre-AIOS, quasi tutta già coperta dai 5 livelli. L'unico pezzo non coperto era il
**domain brain per contributor** (più persone, ognuna con un sotto-dominio, promosso
al centrale via validazione) → **è esattamente ciò che questa estensione multi-operatore
realizza.** Nota storica: un vecchio promemoria suggeriva di usare Git-branch/PR come
promozione — ma quella via è stata **valutata e scartata** a favore di inbox +
promozione automatica (operatori non tecnici). Vedi §3.

### 7.4 — AIOS multi-operatore: modello 3 zone (progetto) — LA FONTE DI QUESTA ESTENSIONE
Discussione di design (2026-07-15/16) su AIOS come brain condiviso da molti operatori
che devono arricchirlo senza rompere il core né creare silos. **Entrambe le domande
aperte risolte:**
- **Q1 (promozione):** AUTOMATICA, contradiction-gated, via lo stesso motore
  `aios-learn` sullo strato lezioni. HITL spostato sulle sole contraddizioni. (§3-4)
- **Q2 (dove vive l'istanza):** host-agnostico — il design specifica il **contratto**
  (storage + compute always-on in rete, bind configurabile), non l'host. (§3.6)
Stato: SOLO DISCUSSIONE fino ad ora, nessun codice dell'estensione scritto. Questa è
l'implementazione.

### 7.5 — Git su Google Drive: hazard (progetto)
La copia del repo su `G:\Il mio Drive\Progetti\aios-plugin` è su **Google Drive**: il
`.git` si resetta e i lock bloccano git nelle operazioni multi-step (rebase/merge si
rompono con "Permission denied"). **Regola:** rebase/merge/push/PR **solo da clone
pulito fuori Drive** — cioè **questo repo** (`Desktop\Progetti\_asernet\AIOS-Datapyx`).
Il lavoro `aios-learn` è stato consegnato come patch e integrato qui via PR #2 (v0.5.0).

---

## 8. Riferimenti nel repo (leggili)

- `docs/superpowers/specs/2026-07-15-aios-learn-design.md` — spec di aios-learn +
  §"Estensione: arricchimento multi-operatore" (il design che stai crystallizzando).
- `docs/superpowers/plans/2026-07-16-aios-learn-implementation.md` — il piano di
  aios-learn (usalo come **modello di stile** per il tuo piano: header, global
  constraints, task bite-sized, verifica = `rg` + walkthrough, no placeholder).
- `skills/aios-learn/SKILL.md` + `references/` — il motore da estendere.
- `skills/aios-dashboard/SKILL.md` — per il bind LAN e il lancio comandi headless.
- `README.md` / `GUIDE.md` — doc da aggiornare a fine lavoro.

---

## 9. Sequenza consigliata

1. Leggi §2-8 e i file di riferimento del repo.
2. `superpowers:brainstorming` → crystallizza §3-5 in una **spec buildable**
   (`docs/superpowers/specs/AAAA-MM-GG-multi-operatore-design.md`). Behavior = input
   approvato; decidi solo i concreti. Presenta all'utente e ottieni approvazione.
3. `superpowers:writing-plans` → piano no-placeholder.
4. `superpowers:subagent-driven-development` → esegui.
5. Bump `0.5.0 → 0.6.0` in `.claude-plugin/plugin.json`, branch + PR + merge.
6. Cancella/gitignora questo file di handoff (non va nel rilascio).
