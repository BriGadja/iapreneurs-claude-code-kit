---
name: architect
description: Utiliser pour transformer un fichier brainstorm (ou une idée claire) en Product Requirements Document structuré (PRD.md). Définit la stack et l'architecture du projet via 1-2 questions ciblées sur le type d'output. Ne PAS utiliser si l'idée est encore floue — passer par /brainstorm d'abord. Ne PAS utiliser pour ajouter une feature à un PRD existant — éditer directement le PRD.
---

# Skill /architect — définir l'architecture et produire le PRD

## Pour quoi faire

Transformer une idée (claire ou issue d'un `/brainstorm`) en **PRD** : un fichier `PRD.md` qui définit l'architecture du projet (stack, frontières techniques, phases) et sert de référence pour toute la suite (`/plan`, `/execute`, `/validate`). Le PRD est lu en début de chaque skill suivant.

## Sections obligatoires du PRD (format v2.2 — 8 sections, vivant)

Pas de PRD complet sans ces 8 sections, dans cet ordre. **Cap 100 lignes hard** — au-delà, c'est qu'il y a du contenu à déporter vers `docs/specs/SPEC-*.md` (évolutions) ou `STRUCTURE.md` (arbo) ou `memory/decisions.md` (rationales arch).

1. **Vision** — 1-3 phrases : ce que le projet livre, à qui, pour quel résultat
2. **Personas** — 1-3 personas courts (rôle / contexte / douleur)
3. **Scope actuel (V_n)** — checkboxes Core + Technique de la version courante. Mis à jour par `/evoluer` (déplace `[x]` Hors scope → ici)
4. **Hors scope (différé)** — checkboxes des features volontairement reportées
5. **Constraints non-négociables** — contraintes métier/légales/perf qui ne bougent pas
6. **Success Criteria** — critères mesurables au niveau projet entier
7. **Implementation Phases** — historique chronologique V1, V_n en cours, V_n+1 envisagé. Append-only par `/evoluer` Étape 5e
8. **Risks & Mitigations** — risques identifiés + mitigations prévues

**Référence template** : `templates/PRD-template.md` à la racine du kit. `/architect` Étape 4 lit ce template puis génère un PRD personnalisé en respectant la structure et le cap 100 lignes.

**Compat ancien format v2.1.x** : si un PRD existant utilise l'ancien format 7 sections (`## Sommaire / ## Phases / ## Stack technique / ...`), `/evoluer` + `/prime` + `/close` détectent et fonctionnent en mode legacy. Pour migrer manuellement : voir `docs/MIGRATION-v2.1-to-v2.2.md`.

## Comment procéder

### Étape 1 — lire la source

Si l'utilisateur a passé un **brief de brainstorm en argument** (chemin `docs/brainstorms/{date}-{slug}.md` ou ancien format `brainstorm-{sujet}.md`), lis-le en entier. Le brief contient déjà l'idée en 1 phrase, le besoin clarifié (pour qui, pour quoi), les contraintes connues, la direction recommandée et les hypothèses à valider. **Utilise ces données pour pré-remplir tes questions Étape 2-3** au lieu de partir de zéro : tu proposes les réponses extraites du brief, l'utilisateur confirme ou amende.

Si pas de fichier en argument, lire ce que dit l'utilisateur dans le chat et lui poser **2-3 questions de clarification** sur les sections manquantes (utilisateurs, MVP, stack).

### Étape 2 — déterminer la nature du projet, puis proposer la stack

**2a — Comprendre la nature** : avant de proposer une stack, pose 1-2 questions ciblées :

- "Où l'utilisateur final voit-il le résultat — dans son navigateur, par mail, dans une notification, dans un fichier exporté ?"
- "Y a-t-il un output qui doit s'afficher en temps réel (streaming, progression visible) ? Ou peut-il être livré quelques secondes plus tard (mail, PDF, notification) ?"

Ces questions déterminent les choix techniques **avant** de figer la stack :
- **Output live à l'écran (streaming)** → SDK direct (Anthropic, OpenAI) dans une API route ; n8n ne sait pas streamer vers un navigateur.
- **Output asynchrone (PDF, email, BDD, intégration externe)** → workflow n8n + callback de notification.
- **Mix des deux** → frontière explicite : SDK pour le live, n8n pour le reste.

**2b — Demander les providers favoris** (avant de proposer une stack par défaut) :

> *"Tu as des providers de référence que tu utilises déjà ? Hosting (Vercel/Netlify/Cloudflare/GitHub Pages/autre), BDD (Supabase/Neon/PlanetScale/autre/aucune), Email (Resend/Postmark/autre/aucun). Dis-moi ce que tu sais, je remplis les trous avec mes défauts."*

**Défauts si "pas d'avis"** — alignés sur la communauté IAPreneurs : Hosting → **Vercel**, BDD → **Supabase** (RLS native), Email → **Resend**, Automation runtime → **n8n self-hosted** ou **n8n cloud**.

**2c — Proposer la stack complète**, alignée avec la nature du projet **ET** les providers retenus :

- **App web (CRUD + auth)** : Next.js (App Router) + Tailwind + shadcn/ui + `{BDD retenue}` + `{Hosting retenu}`
- **App web avec génération IA visible** : ci-dessus + Anthropic SDK dans une API route Next.js
- **App web avec génération IA async (PDF, email)** : ci-dessus + workflow n8n via webhook + callback `{BDD}` Realtime
- **Automatisation pure (pas d'UI front)** : n8n + `{BDD}` (stockage / état) + intégrations externes
- **Voix** : Vapi (provider voice IAPreneurs community-friendly)
- **Scripts ponctuels** : Python ou TypeScript Node

Toujours **demander confirmation** : "Je propose **{stack complète avec providers retenus}**. Ça te va ou tu veux changer un truc ?"

Si l'utilisateur ne sait pas trancher entre SDK direct et n8n, ré-explique brièvement : "tokens qui doivent défiler à l'écran = SDK ; PDF ou email qui peut arriver dans 20 secondes = n8n".

### Étape 3 — proposer le niveau Request Classification + découpe en phases

**3.1 — Proposer le niveau Request Classification** (LITE / STANDARD / FULL).

> *"Calibrons l'effort avant la découpe. **LITE** : site vitrine 1-5 pages ou automation simple ou MVP weekend (PRD 3 sections, `/challenge` skip). **STANDARD** *(défaut)* : web app classique 2-5 phases (PRD 7 sections, `/challenge` optionnel). **FULL** : projet client critique 5+ phases (AC scorés, `/challenge` systématique, audit policy d'accès BDD obligatoire). Quel niveau ?"*

Stocke le niveau. Tu l'écriras dans le PRD (header) ET dans `CLAUDE.md` section `## Request Classification` (ligne "Niveau choisi pour ce projet").

**3.2 — Découpe en phases** selon le niveau retenu :

- **LITE** : 1 à 2 phases max. Souvent : Phase 1 — MVP. Optionnel Phase 2 — Polish.
- **STANDARD** : **3 à 5 phases max**. Pas plus. Si t'as 7 phases, c'est trop large : faut un PRD parent + plusieurs sous-PRDs.
- **FULL** : 5 à 8 phases max. Au-delà → PRD parent + sous-PRDs.

Exemple de découpe STANDARD pour une web app :
- Phase 1 — Squelette + 1 feature critique end-to-end
- Phase 2 — Compléments features
- Phase 3 — Authentification / multi-utilisateur
- Phase 4 — Déploiement + tests utilisateurs

### Étape 4 — écrire le brouillon, lire à voix haute

Lis `templates/PRD-template.md` (référence du kit), génère un PRD personnalisé en remplissant les 8 sections avec les réponses des Étapes 1-3. **Cap 100 lignes hard** : si tu dépasses, vois ce qui peut être déporté (sections trop longues = candidats `docs/specs/` futurs ou `STRUCTURE.md`).

**Affiche-le entier dans le chat** et demande validation **avant** de sauvegarder le fichier.

> "Voilà le PRD que je propose. Tu valides ou tu veux qu'on change un truc ?"

Itère jusqu'à ce que l'utilisateur dise oui.

### Étape 5 — sauvegarder

Sauvegarder dans `PRD.md` à la racine du projet uniquement après validation explicite.

### Étape 5b — propager la Stack dans CLAUDE.md (pattern DISCOVER + ANALYZE → GENERATE)

**5b.1 — DISCOVER** : si le projet a déjà du code (rare en /architect post-/start, possible si /architect est rejoué sur projet existant), scan les fichiers signaux :
- `package.json` → identifier dépendances réelles (frameworks, libs, scripts)
- `next.config.{js,ts}`, `vite.config.*`, `tsconfig.json`, `.mcp.json`, `supabase/config.toml` → configs présentes
- `pnpm-lock.yaml` / `package-lock.json` / `yarn.lock` → manager de paquets
- Fichiers `.env.example` → services tiers attendus

**5b.2 — ANALYZE** : si codebase non-vide, extraire les patterns observés :
- **Naming** : kebab-case fichiers ? camelCase ? PascalCase ?
- **Errors** : `try/catch` partout ? `Result<T, E>` ? throw remontant ?
- **Types** : Zod aux frontières ? TypeScript strict ? `any` toléré ?
- **Tests** : co-located `*.test.ts` ? dossier `__tests__/` ? Vitest ? Jest ?

Si codebase vide (cas standard) : skip 5b.1+5b.2, passer direct à 5b.3 GENERATE.

**5b.3 — GENERATE** : ouvre `CLAUDE.md` et trouve le bloc :

```
<!-- architect:stack -->
{...placeholder ou contenu précédent...}
<!-- /architect:stack -->
```

Remplace le contenu entre les deux ancres par la **section Stack du PRD** (juste les bullets, pas le titre `## Stack technique`). **Garde les ancres**, **ne touche à aucune autre partie du `CLAUDE.md`**.

Si les ancres `<!-- architect:stack -->` / `<!-- /architect:stack -->` ne sont pas trouvées (CLAUDE.md trop ancien ou template modifié) :
1. Cherche le heading `## Stack` à la racine du fichier
2. Si trouvé, remplace son contenu placeholder par les bullets du PRD + ajoute les ancres autour pour les futures sessions
3. Si pas trouvé non plus, dis à l'utilisateur : *"Pas d'ancre `<!-- architect:stack -->` ni de section `## Stack` dans CLAUDE.md. Je n'écris pas pour ne pas casser ta structure. Tu veux que je l'ajoute en bas du fichier ?"*

Annonce à l'utilisateur : *"Stack synchronisée dans `CLAUDE.md ## Stack`. Future Claude saura quelle techno tu utilises sans relire le PRD entier."*

### Étape 6 — Provisioning & Scaffold

Une fois `PRD.md` et `CLAUDE.md ## Stack` à jour, on **scaffold le repo concrètement** et on **provisionne les credentials externes** — sans ça, l'utilisateur a un PRD mais un repo vide et `/plan Phase 1` commence dans le mur.

**6.1 — Lire `project_type`** depuis `<!-- start:identité -->` dans `CLAUDE.md`. Si la variable est absente ou invalide (∉ `{site, webapp, automation}`) :
- Demande **une fois** : *"Quel type de projet : (a) site vitrine 1-5 pages, (b) web app SaaS avec auth+BDD, (c) automatisation n8n pure ?"*
- Écris la réponse dans `<!-- start:identité -->` (`project_type: webapp` par exemple)
- Continue. **Pas de re-demande ensuite.**

**6.2 — Proposer la séquence de commandes shell** (jamais auto-exécutées sans validation explicite, **jamais** de destructive `rm -rf`/`--force`/`--no-verify` automatiquement) :

| `project_type` | Commandes proposées |
|---------------|---------------------|
| `site` | `npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*"` + optionnel `npm i resend` (si formulaire contact prévu) |
| `webapp` | `npx create-next-app@latest . --typescript --tailwind --app --src-dir --import-alias "@/*"` + `npm i @supabase/supabase-js @supabase/ssr` + `npx supabase init` (génère `supabase/config.toml`) |
| `automation` | `mkdir -p workflows` + créer `workflows/.gitkeep` + tester connexion n8n MCP via `claude mcp list` (vérifier que n8n est listé) |

Affiche le bloc commandes complet, **demande confirmation explicite** : *"J'exécute cette séquence ? (oui / modifie / skip)"*. Si "modifie", l'utilisateur édite, tu re-affiches. Si "skip", tu passes à 6.3. Si "oui", tu exécutes ligne par ligne en montrant l'output.

**6.3 — Provisioning credentials externes** (interactif, jamais en clair dans le repo) :

- **Supabase** (si `webapp`) : guide l'utilisateur — *"Va sur supabase.com/dashboard, crée un projet, copie-colle l'URL et la `anon key` ici"*. Tu récupères les 2 valeurs, tu les écris dans `.env` au format `NEXT_PUBLIC_SUPABASE_URL=...` + `NEXT_PUBLIC_SUPABASE_ANON_KEY=...`.
- **Vercel** (si `webapp` ou `site`) : *"Tu veux lier ton repo à Vercel maintenant ou plus tard (au `/livrer`) ? Si maintenant, tape `vercel link` dans un autre terminal puis colle le `.vercel/project.json` créé"*. Si l'utilisateur skip, note dans le PRD que Vercel est reporté à `/livrer`.
- **n8n** (si `webapp` async ou `automation`) : vérifie que `.env` contient `N8N_API_URL` + `N8N_API_KEY`. Si absent, demande à l'utilisateur de les fournir (ou de skipper si pas de besoin immédiat). Teste la connexion via le MCP n8n (`claude mcp list` doit montrer `n8n`).

**6.4 — Écrire `.env` depuis `.env.example` + vérifier `.gitignore`** :
1. Si `.env.example` existe à la racine, fais `cp .env.example .env` (uniquement si `.env` n'existe pas — **jamais** d'écrasement).
2. Écris les credentials récupérées en 6.3 dans `.env`.
3. Vérifie que `.gitignore` contient `.env` et `.env.local` et `.env.*.local`. Si absent, ajoute (sans toucher au reste du `.gitignore`).
4. **Test final** : `git check-ignore .env` doit retourner `.env`. Si non, alerte l'utilisateur — sécurité critique.

**6.5 — Écrire STRUCTURE.md (carte d'architecture initiale)** :

Si `STRUCTURE.md` n'existe pas à la racine, le créer en remplissant les **7 ancres** : 4 `<!-- architect:* -->` (directories, patterns, tests, conventions) + 3 `<!-- structure:* -->` (integrations, key-files, evolutions-summary). Si `STRUCTURE.md` existe déjà (utilisateur l'a édité), **ne pas écraser** — append une section `## Modifications post-scaffold` datée si tu détectes des changements d'arbo importants.

**Les 3 ancres `structure:*` à initialiser** (peuvent être quasi-vides à l'init, seront enrichies par `/evoluer`) :
- `<!-- structure:integrations -->` : services tiers branchés (APIs, BDD, MCP, webhooks). À l'init : liste les providers retenus en Étape 2b.
- `<!-- structure:key-files -->` : fichiers critiques pour l'agent (entrées principales, configs, schémas BDD). À l'init : liste les fichiers scaffoldés en 6.2.
- `<!-- structure:evolutions-summary -->` : 1 ligne par évolution livrée, lien vers `docs/specs/SPEC-{date}-{slug}.md`. **Vide à l'init** (pas encore d'évolutions). Maintenu par `/evoluer`.

**Templates selon `project_type`** :

- **`webapp`** :
  - `<!-- architect:directories -->` : `src/app/` (routes Next.js App Router), `src/components/ui/` (shadcn), `src/lib/` (helpers), `src/types/` (types globaux), `supabase/` (migrations, config)
  - `<!-- architect:patterns -->` : RSC pour les pages, Server Actions pour les mutations, `@supabase/ssr` côté serveur, validation Zod aux frontières
  - `<!-- architect:tests -->` : co-located `*.test.ts` à côté du fichier source, lancement `npm test`
  - `<!-- architect:conventions -->` : kebab-case pour les fichiers, PascalCase pour les composants React, `use client` uniquement quand nécessaire

- **`site`** :
  - `<!-- architect:directories -->` : `app/` (pages Next.js), `components/` (UI), `public/` (assets statiques), `content/` (markdown ou MDX si présent)
  - `<!-- architect:patterns -->` : Static generation par défaut, Server Components partout, formulaire contact via Server Action + Resend
  - `<!-- architect:tests -->` : tests E2E Playwright pour les parcours critiques (formulaire contact, navigation), pas de tests unitaires sauf utils
  - `<!-- architect:conventions -->` : kebab-case fichiers, contenu éditable en `content/` si MDX

- **`automation`** :
  - `<!-- architect:directories -->` : `workflows/` (fichiers `.workflow.json` exportés depuis n8n), `scripts/` (utilitaires CLI), `docs/` (procédures opérationnelles)
  - `<!-- architect:patterns -->` : 1 fichier `.workflow.json` par workflow n8n, versionnés git, push via MCP `n8n_create_workflow` ou `n8n_update_full_workflow`
  - `<!-- architect:tests -->` : tests via `n8n_test_workflow` MCP avec payload type, ou exécution manuelle dans l'UI n8n
  - `<!-- architect:conventions -->` : nommage workflows `[ENV] {scope}-{action}` (ex : `[PROD] rss-veille-quotidienne`)

Après écriture, affiche : *"📐 STRUCTURE.md créé. Sera lu par `/prime` à chaque session pour recharger le contexte d'architecture."*

**6.6 — Initialiser `memory/decisions.md` avec ADR-001 fondateur** :

Lis `memory/decisions.md`. Si la zone ADR (entre la section `## ADR — Architecture Decision Records` et `---`) est vide ou ne contient aucun `ADR-NNN`, append l'ADR fondateur :

```markdown
### ADR-001 — Stack initiale : {résumé court}

- **Status** : Accepted
- **Date** : {YYYY-MM-DD}
- **Context** : {1 ligne — source brainstorm/idée + project_type retenu}
- **Decision** : {2-3 lignes — providers Q2b retenus + stack Q2c décidée}
- **Consequences** : {1 ligne — impact futur, ce que ça verrouille / débloque}
```

**Idempotent** : si un `ADR-NNN` existe déjà dans la zone, **skip entièrement** (pas d'écrasement). C'est `/evoluer` Étape 5f qui appendera les ADR suivants (ADR-002, ADR-003...) au fil des évolutions arch.

Annonce : *"📋 ADR-001 fondateur écrit dans `memory/decisions.md`. Les choix arch initiaux sont tracés. Future Claude saura POURQUOI cette stack a été choisie sans relire le brainstorm."*

Annonce finale à l'utilisateur : *"Repo scaffold + credentials provisionnées + STRUCTURE.md initial + ADR-001 fondateur. `.env` est gitignored. Prêt pour `/plan Phase 1`."*

## Format du PRD

Le format canonique est défini dans [`templates/PRD-template.md`](../../../templates/PRD-template.md) (66 lignes, 8 sections numérotées, cap 100 lignes). Lis ce template à l'Étape 4 pour générer le PRD du projet. Ne duplique jamais le format ici — la source unique évite la dérive entre skills.

## Risque #1 — sauvegarder sans validation humaine

**Jamais** sauvegarder le PRD sans que l'utilisateur ait dit "oui c'est bon" explicitement. Le PRD est lu par tous les skills suivants — si t'as une erreur dedans, tu la propages partout. Toujours afficher → attendre validation → sauvegarder.

## Quand ne PAS utiliser ce skill

- Idée encore floue → `/brainstorm` d'abord
- **Ajouter une feature à un projet livré (PRD existant + phases ✅ Terminée)** → `/evoluer` (jamais d'édition manuelle du PRD)
- Projet très petit (1-2 fichiers, fix rapide) → pas besoin de PRD

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "architect", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Affiche à l'utilisateur :

```
✅ PRD créé : PRD.md

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /{design,plan} (selon project_type) — Phase 1
```

**Prochaine étape** : `/close → /clear → /{design,plan} (selon project_type) — Phase 1` — voir le rituel dans `docs/KIT.md § STATUS.md & rituel`.
