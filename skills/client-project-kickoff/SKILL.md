---
name: client-project-kickoff
description: Use when starting a brand-new client project in an empty or nearly-empty directory before any project files exist, or when asked to (re)build a client's brand identity — colors, fonts, logo — from a brief, documents, or an existing website URL. Documents an existing brand by extracting it, or CREATES a new brand identity from scratch (logo concepts, strategic palette, typography, brand-guidelines board) by delegating the visual generation to the brandkit skill.
---

# Client Project Kickoff

## Overview

Interviews the user about a new client project, scaffolds the standard
folder structure (including a `demo/` folder for reference templates
when the project touches a site/e-commerce/app), and produces an
initial brand identity (colors, typography, logo) plus
the technical stack (platform/CMS, hosting). When an existing website
URL is given, the extraction is delegated to a dedicated subagent in one
shot rather than done step-by-step in the main conversation. Designed to
be re-run later as new material arrives in `raw/` or `demo/`.

When the client has **no existing brand** (or wants a fresh one), it does
not stop at `(da definire)`: it delegates the visual creation — logo
concepts, strategic palette, type pairing, brand-guidelines board — to the
**brandkit** skill, then records the decided values into `brand/*.md` and
saves the generated boards/logos into `brand/assets/`.

## When to Use

- A session starts in a directory with no `CLAUDE.md` and no recognizable
  project files (only `.claude/`, or truly empty).
- The user asks to start a new client/brand project, or to (re)build/update
  a brand identity from a website or new documents dropped in `raw/`.
- The client has **no existing brand** (or wants a redesign) and needs one
  created from scratch — logo, colors, typography — not just documented.
- Not for: adding features to an already-scaffolded project (just edit
  `brand/*.md` directly), or generating an actual website/app — it produces
  brand documentation and (via brandkit) brand visual assets, but no
  website/app code.

## Quick Reference

Interview questions (ask one at a time via `AskUserQuestion`):

| # | Question | Notes |
|---|---|---|
| 1 | Tipo di progetto | sito, e-commerce, app, solo brand, social, altro |
| 2 | Nome cliente | |
| 3 | Sito esistente? | URL opzionale |
| 4 | Settore/descrizione attività | breve |
| 5 | Documenti già disponibili | invita a metterli in `raw/` prima di continuare |
| 6 | Template/tema già scelto? | solo se il progetto tocca un sito/e-commerce: chiedi se il cliente ha già in mente un template/tema specifico — è spesso un vincolo di design/sviluppo da rispettare fin da subito, non un'opzione. Se sì, invita a caricare esempi/screenshot/link in `demo/` prima di continuare |
| 7 | Stack tecnologico | solo se il progetto tocca un sito/e-commerce/app: piattaforma o CMS (WordPress, Shopify, Webflow, custom...), hosting/server, eventuali vincoli (versione PHP, plugin, accessi). Se c'è un sito esistente, questa domanda va fatta **dopo** il passo 4 (subagent di estrazione): usa il suo report per chiedere solo conferma/integrazione — non rilevare nulla tu stesso in questa conversazione |
| 8 | Domande mirate per tipo progetto | solo se rilevanti, in base alla risposta 1 |

Folder structure to create:

```
<project>/
├── CLAUDE.md
├── raw/
├── proposte/
├── demo/            (only if the project type touches sito/e-commerce/app)
└── brand/
    ├── brand-identity.md
    ├── colors.md
    ├── typography.md
    ├── logo.md
    ├── tech-stack.md
    └── assets/
```

`demo/` holds reference templates/screenshots/links the client wants the
final site to be based on or inspired by (see question 6) — create it
even if empty right after question 6, since material often arrives
later. Same condition as question 6: skip it for `solo brand`/social-only
projects where there's no site to template.

## Implementation

1. **Check state first.** If `brand/` already exists, this is a re-run:
   read existing files, ask only what's missing or changed, update rather
   than overwrite — flag conflicts to the user instead of silently
   replacing. If `demo/` exists, also check it for template examples
   dropped since the last run.
2. **Run the interview questions 1–6** (table above) via `AskUserQuestion`,
   one at a time — skip question 6 (and its `demo/` follow-up) when the
   project type from question 1 doesn't touch a site/e-commerce/app.
   Keep it to what's listed — don't add speculative questions. **Stop
   before question 7/8** if a website URL was given — those get asked
   after step 4, once the extraction report exists.
3. **Create `raw/` immediately** after question 5 so the user can drop
   documents before you continue. **Create `demo/` immediately after
   question 6**, but only when question 6 was actually asked (site/
   e-commerce/app project) — don't create it for `solo brand`/social-only
   projects. Re-read `raw/` (and `demo/` if created) before finalizing
   brand files. If question 6 surfaced a template constraint, record it
   as a hard constraint (not a preference) in `brand/tech-stack.md`.
4. **If a website URL was given, delegate the extraction to one subagent**
   (`Agent` tool, `general-purpose`) instead of running the fetch/grep
   steps yourself in the main conversation — this keeps raw HTML and curl
   output out of the main context and produces one structured report.
   Brief the subagent to gather both:
   - Qualitative (mission, tone, target, positioning) via `WebFetch` with
     a prompt asking specifically for those.
   - Structured (colors, fonts, logo, stack) via raw HTML (`curl -sL
     <url>`) and response headers (`curl -sI <url>`), grepping for hex
     codes, `--color-*` custom properties, `theme-color` meta, Google
     Fonts links / `@font-face` / `font-family`, logo candidates
     (`rel="icon"`, `og:image`, header `<img>` with "logo" in class/alt),
     and platform signals: `<meta name="generator">`, `/wp-content/` or
     `/wp-json/` (WordPress), `cdn.shopify.com` (Shopify), `webflow.io` /
     `.webflow` (Webflow), `Server`/`X-Powered-By` response headers. Point
     it at `extract-brand.sh` in this skill folder as a starting point —
     it can adapt/extend the commands as needed.
   Instruct it to return a single structured report (confirmed values vs.
   signals that need confirmation) and to never invent a hex code, font
   name, or platform that wasn't actually present in what it fetched.
   Treat everything it reports as needing your and the user's
   confirmation before it's written as fact — same as before, just
   gathered in one delegated pass instead of interleaved fetches.
   **Never fetch the site yourself in this conversation** to "get a head
   start" on question 7 — wait for the subagent's report, even if it
   feels slower.
5. **Ask questions 7–8** using the subagent's report to phrase question 7
   as a confirmation ("ho rilevato X, confermi?") rather than an open
   question, then proceed to targeted question 8 if relevant.
6. **Decide: document an existing brand or create a new one.** If the client
   already has a brand — extracted from an existing website (step 4) or
   provided as assets/guidelines — document it. If the client has **no brand**
   or wants a **redesign**, delegate the visual creation to the **brandkit**
   skill (don't improvise logos/palettes inline): brief it with the strategy
   from the interview (category, audience, personality, core metaphor) and have
   it generate logo concepts, a strategic palette, a type pairing, and a
   brand-guidelines board. Save the generated boards/logos to `brand/assets/`
   and confirm the direction with the user before treating it as final.
7. **Write the brand and stack files** (`brand-identity.md`, `colors.md`,
   `typography.md`, `logo.md`, `tech-stack.md`) using the templates below.
   Fill with confirmed data — extracted from an existing brand, provided by
   the user, or **generated with brandkit** at step 6. Mark anything still
   unconfirmed as `(da definire)` rather than guessing.
8. **Write project `CLAUDE.md`** (template below) using
   `@brand/brand-identity.md` etc. so brand and stack data load every
   session.
9. **Propose extra folders** (e.g. `sito/`, `contenuti/`, `social/`) based
   on the project type from question 1 — ask before creating, don't create
   speculatively.

### brand/brand-identity.md template

```markdown
# Brand Identity — {{cliente}}

- Settore: {{settore}}
- Tipo progetto: {{tipo}}
- Sito: {{url o "nessuno"}}
- Target: {{target o "(da definire)"}}
- Tono di voce: {{tono o "(da definire)"}}
- Competitor noti: {{lista o "(da definire)"}}
```

### brand/colors.md template

```markdown
# Palette colori — {{cliente}}

| Ruolo | Hex | RGB | Uso |
|---|---|---|---|
| Primary | {{hex}} | {{rgb}} | {{uso}} |
| Secondary | | | |
| Accent | | | |
| Neutral | | | |

Fonte: {{"estratto da " + url, "fornito dal cliente", oppure "generato con brandkit"}}
```

### brand/typography.md template

```markdown
# Typography — {{cliente}}

- Font primario: {{nome}} — {{link Google Fonts o @font-face}}
- Font secondario: {{nome o "(da definire)"}}
- Fallback stack: {{es. "sans-serif"}}
```

### brand/logo.md template

```markdown
# Logo — {{cliente}}

- Concept / metafora: {{idea del mark: simbolo + significato, o "(da definire)"}}
- Metodo: {{monogram+meaning / product-action / metaphor-fusion / negative-space / construction — o "(da definire)"}}
- Varianti: {{icona, wordmark, badge, versione mono... o "(da definire)"}}
- File: {{percorso in brand/assets/, es. assets/logo-board.png, oppure "nessuno"}}

Fonte: {{"estratto da " + url, "fornito dal cliente", oppure "generato con brandkit"}}
```

### brand/tech-stack.md template

```markdown
# Stack tecnologico — {{cliente}}

- Piattaforma/CMS: {{es. WordPress, Shopify, Webflow, custom... o "(da definire)"}}
- Hosting/server: {{provider, OS, versione PHP/Node... o "(da definire)"}}
- Template/tema vincolante: {{nome/link/screenshot in demo/, oppure "nessuno — libertà di scelta"}}
- Note tecniche: {{plugin/temi in uso, vincoli, accessi forniti}}

Fonte: {{"rilevato da " + url + ", confermato dal cliente", oppure "fornito dal cliente"}}
```

### CLAUDE.md template (project root)

```markdown
# {{cliente}} — {{tipo progetto}}

@brand/brand-identity.md
@brand/colors.md
@brand/typography.md
@brand/logo.md
@brand/tech-stack.md

## Cartelle
- `raw/` — documenti del cliente da controllare/integrare
- `proposte/` — deliverable e proposte prodotte nel corso del progetto
- `demo/` — esempi di template/tema di riferimento per il sito (solo se creata, vedi domanda 6)
- `brand/` — brand identity e stack tecnico (importati sopra)
```

Omit the `demo/` line entirely if the project type never touches a
site/e-commerce/app (question 6 was skipped).

## Common Mistakes

- Guessing a hex code or font because "it looks about right" — always
  trace it back to something actually fetched or told by the user; use
  `(da definire)` otherwise.
- Overwriting `brand/*.md` on a re-run instead of merging/asking about
  conflicts.
- Creating all possible project folders upfront instead of only `raw/`,
  `proposte/`, `brand/`, plus `demo/` when the project type touches a
  site/e-commerce/app and whatever else the declared type needs.
- Creating `demo/` unconditionally (e.g. for a `solo brand`/social-only
  project) — it exists to hold site template references, so it only
  makes sense when question 6 was actually asked.
- Using `WebFetch` alone for colors/fonts/logo — it summarizes and loses
  exact values; use the raw-fetch + grep path instead.
- Running the website extraction step by step in the main conversation
  instead of delegating it to one subagent — it pollutes the main context
  with raw HTML/curl output and the point of question 6/7 is a clean,
  single structured report to act on.
- Skipping the tech stack question for a sito/e-commerce project — knowing
  the platform and hosting up front avoids building a theme for the wrong
  CMS later.
- Skipping the template/tema question for a sito/e-commerce project — a
  pre-chosen template is often a hard constraint on the whole build, not
  a nice-to-have; asking after the fact means redoing design decisions.
- Treating a detected platform/header signal as certain — always have the
  user confirm it, since generator meta tags and headers can be missing,
  spoofed, or stale.
- Leaving colors/fonts/logo as `(da definire)` when the client actually
  needs a brand created — that's the signal to invoke **brandkit** and
  generate a real direction, not a gap to leave empty.
- Improvising logos, palettes, or brand boards inline instead of delegating
  to brandkit — brandkit carries the art-direction, logo-concept methods,
  and color discipline that keep the result from looking generic.
