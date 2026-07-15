# InfraOS — versionamento dell'AIOS (opzionale)

Aggiunge tracciabilità, backup su cloud e storia tra sessioni all'AIOS.
**Assumi che l'utente possa non aver mai usato Git/GitHub**: guidalo nel modo più
semplice possibile, un passo alla volta, spiegando cosa fa ogni comando.

## Prerequisiti
Verifica cosa è già presente prima di installare qualcosa:
- `git --version` — se manca, guida all'installazione per il suo OS (Windows: `winget install Git.Git`).
- `gh --version` (GitHub CLI) — serve solo per il backup remoto; se manca e l'utente lo vuole, guida con `winget install GitHub.cli` e `gh auth login`.

## Passi

### 1. Init locale
Nella working dir:
- `git init`
- Crea `.gitignore` che escluda segreti e rumore: `.env`, chiavi API, `*.db` se
  in futuro ci sarà un database con dati sensibili, cartelle temporanee.
- Primo commit con tutto lo stato dell'AIOS (contesto, CLAUDE.md, comandi).

### 2. history.md
Crea `history.md` nella root: un **diario append-only** delle sessioni. Ogni
entry: data (`YYYY-MM-DD`), cosa è stato fatto, perché. Serve a riprendere il
lavoro in sessioni successive senza ricominciare.

Non confonderlo con `.claude/log.md`: quest'ultimo è il registro trasversale
per-skill (sempre presente, indipendente da InfraOS), `history.md` è il
diario di sessione legato ai commit. Se InfraOS è attivo, `/commit` versiona
anche `.claude/log.md` come qualunque altro file — non serve logica aggiuntiva.

### 3. Comando /commit
Crea `.claude/commands/commit.md`. Il comando deve:
1. Scansionare i file modificati nella working dir (`git status`).
2. Scrivere un messaggio di commit che riassume **cosa** è stato fatto e **perché**.
3. Aggiungere una entry in cima a `history.md`.
4. `git add -A && git commit`.
5. Se è configurato un remote, `git push`.

Termina i messaggi di commit con la co-authorship se richiesto dalle convenzioni
globali dell'utente.

### 4. Backup remoto (opzionale, dentro l'opzionale)
Chiedi se vuole salvare anche su GitHub (repo **privata** di default):
- `gh repo create <nome> --private --source . --push`
- Suggerisci un nome (es. `aios-<slug-azienda>`).

### 5. Aggiorna /prime
Aggiorna `prime.md` perché, a inizio sessione, legga anche `history.md` e
riepiloghi cosa è stato fatto nelle sessioni precedenti.

## Flusso risultante da comunicare all'utente
- **Inizio sessione:** `/prime` (carica contesto + storia)
- **Durante:** lavori normalmente
- **Fine sessione:** `/commit` (salva, documenta, e fa backup se configurato)
