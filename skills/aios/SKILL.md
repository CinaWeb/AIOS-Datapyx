---
name: aios
description: Punto di ingresso unico per costruire l'AIOS (AI Operating System) di un'azienda/cliente. Orchestra in sequenza tutti e 5 i livelli (Contesto+brand, Dati, Intelligence, Automazioni, Dashboard) invocando le skill aios-context, aios-data, aios-intel, aios-automation, aios-dashboard, offre il diagnostico DataPyx (skill datapyx) dopo il Contesto, e traccia il progresso in una checklist persistente così nessuno step viene dimenticato e il processo è riprendibile tra sessioni. Usa quando l'utente vuole creare, continuare o completare l'AIOS di un cliente ("costruiamo l'AIOS", "riprendi l'AIOS", "a che punto è l'AIOS").
argument-hint: "Nome cliente (opzionale)"
---

# AIOS — Orchestratore

Costruisci l'AIOS di un'azienda **livello per livello, in ordine**, senza
dimenticare passaggi. Lavori **sulla cartella corrente** (la working dir del
cliente). Tu non reimplementi i livelli: **invochi le skill dedicate** e tieni
il conto di cosa è fatto in una checklist persistente.

## I 5 livelli (in ordine)
1. **Contesto** → skill `aios-context` (include brand/design e InfraOS opzionale)
2. **Dati** → skill `aios-data`
3. **Intelligence** → skill `aios-intel`
4. **Automazioni** → skill `aios-automation`
5. **Dashboard** → skill `aios-dashboard`

Ogni livello dipende (idealmente) dai precedenti, ma ognuno funziona anche
standalone e in modalità update.

**Diagnostica trasversale → skill `datapyx`.** Dopo il Contesto è disponibile
DataPyx, l'assistente diagnostico che aiuta a leggere la sfida del cliente
(problema reale, punti di leva, scenari, monitoraggio). Non è un livello di build
— non genera infrastruttura — ma è il cuore analitico dell'AIOS: proponilo dopo
il Livello 1 e tienilo disponibile in ogni momento, incluso il monitoraggio
continuo (Fase 5 di DataPyx) quando il consulente torna con aggiornamenti.

## Flusso

### 1. Checklist persistente
Leggi/crea `.claude/aios-build.md` nella working dir: è lo stato del build.
- Se non esiste, crealo dalla struttura in fondo a questo file.
- Se esiste, è una ripresa: leggilo per sapere dove eri rimasto.

### 2. Rileva lo stato reale
Non fidarti solo della checklist: verifica gli artefatti sul disco e allinea le
spunte.
- Livello 1 fatto se esiste `.claude/context/` con file + `CLAUDE.md`
- Livello 2 fatto se esiste `data/database.db` + `.claude/context/key-metrics.md`
- Livello 3 fatto se nel DB c'è la tabella `meetings`
- Livello 4 avviato se esiste `automations/roadmap.md` (audit fatto); completato
  se almeno un'automazione è `✅`
- Livello 5 fatto se esiste `dashboard/server.py`
Aggiorna `.claude/aios-build.md` di conseguenza.

### 3. Mostra il punto e proponi il prossimo
Presenta la checklist aggiornata e indica **il primo livello non completato**.
Chiedi se procedere con quello. Rispetta il ritmo dell'utente: **un livello alla
volta**, chiedendo conferma prima di iniziare e prima di passare al successivo.
Se l'utente chiede di andare fino in fondo, procedi in sequenza fermandoti solo
dove le singole skill richiedono input.

### 4. Esegui il livello
Invoca la skill corrispondente (`aios-context`, `aios-data`, …) e lascia che
conduca la sua intervista/costruzione. Non anticipare il suo lavoro.

### 5. Aggiorna e continua
Al termine di ogni livello:
- spunta il livello in `.claude/aios-build.md` con data (`YYYY-MM-DD`) e una riga
  su cosa è stato prodotto;
- se l'utente usa InfraOS, suggerisci `/commit`;
- **appena completato il Contesto (Livello 1), proponi la diagnosi con `datapyx`**
  prima di procedere ai Dati: aiuta a mettere a fuoco la sfida reale del cliente e
  a capire quali dati/automazioni serviranno davvero. È opzionale e ripetibile;
- **chiedi se procedere con il livello successivo** o fermarsi qui (si potrà
  riprendere semplicemente rieseguendo questa skill).

### 6. Completamento
Quando tutti e 5 i livelli sono spuntati, dillo esplicitamente e ricorda il
flusso operativo quotidiano del cliente: `/prime` a inizio sessione,
`/refresh-data` e `/collect-meetings` per aggiornare i dati, `/catchup` per le
riunioni, **`datapyx` per diagnosticare/monitorare la sfida del cliente**,
`/dashboard` per il pannello, `/commit` a fine sessione (se InfraOS).

## Template `.claude/aios-build.md`

```markdown
# AIOS build — {{cliente}}

Stato di costruzione dell'AIOS. Aggiornato dall'orchestratore `aios`.

- [ ] 1. Contesto (aios-context) — contesto + brand + /prime
- [ ] (opz.) Diagnosi sfida cliente (datapyx) — trasversale, ripetibile
- [ ] 2. Dati (aios-data) — SQLite + key-metrics + /refresh-data
- [ ] 3. Intelligence (aios-intel) — meeting + /catchup
- [ ] 4. Automazioni (aios-automation) — roadmap + automazioni
- [ ] 5. Dashboard (aios-dashboard) — pannello localhost

## Log
<!-- una riga per livello completato: data + cosa prodotto -->
```

Contenuti generati per aziende italiane: **in italiano**.
