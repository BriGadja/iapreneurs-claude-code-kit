# CLAUDE.md — Template à adapter

> Ce fichier est un **template**. Tu le copies dans ton projet, tu adaptes les 5 couches du début à ton cas, tu gardes les 4 règles de comportement à la fin (elles s'appliquent à n'importe quel projet).

> **À l'ouverture d'une nouvelle session** : tape `/start` — le skill te guide pour cadrer le projet, sécuriser tes credentials, vérifier ton outillage (MCP + plugin), et te router vers la bonne suite (`/brainstorm` ou `/architect`). Si tu reviens sur un projet existant après une absence, tape `/recap` pour reprendre où tu en étais.

## Glossaire

Quatre mots reviennent sans cesse dans ce kit :

- **Phase** — un palier macro du projet, défini dans le `PRD.md` (ex : "Phase 1 — Formulaire public + stockage Supabase"). Une phase contient plusieurs tâches. Marquée `✅ Terminée` par `/close` une fois validée.
- **Tâche** — une étape concrète et vérifiable d'une phase, listée dans `phase-N-plan.md` (ex : "Créer la route `POST /api/leads` qui insert dans `leads`"). Cochée `[x]` par `/execute` au fil de l'eau.
- **Critère "Fait quand"** — la définition de done d'une tâche, écrite avant de commencer ("la route renvoie 201 avec l'`id` créé sur payload valide, 400 sur payload invalide"). Sans ce critère, tu ne sais pas quand t'arrêter.
- **Critères de succès** — la définition de done d'une phase entière (ex : "10 leads insérés en BDD via formulaire public, 0 erreur Supabase"). Vérifiés par `/validate`.

---

# {Nom de ton projet}

> Tout ce qui suit est à adapter à TON projet. Les sections marquées `<!-- skill:nom -->` sont mises à jour par les skills correspondants — garde les ancres HTML, sinon le skill ne sait plus où écrire.

## Identité

<!-- start:identité -->
{En 2-3 phrases : ce qu'est ton projet, à qui il s'adresse, et le résultat qu'il livre. Cette section est remplie par `/start` après ses 3 questions de cadrage. Exemple final : "Application web qui automatise la génération de devis pour un freelance français. Le client final reçoit des demandes via formulaire, un moteur n8n qualifie + calcule + stocke le devis, le pro relit et envoie."}

project_type: {site | webapp | automation}
<!-- /start:identité -->

> **Variable `project_type`** : déterminée par `/start` selon ton cas d'usage. Trois valeurs possibles :
> - `site` — site vitrine 1-5 pages (Next.js minimal, pas de BDD, optionnellement Resend pour formulaire de contact)
> - `webapp` — app web SaaS avec auth + BDD (Next.js + Supabase + shadcn)
> - `automation` — workflow n8n pur, pas d'UI front (n8n + intégrations externes)
>
> Les skills `/architect` (Étape 6), `/livrer`, `/plan` et `/design` branchent sur cette variable. **Si elle est absente ou invalide**, les skills qui en dépendent stoppent avec un message demandant de relancer `/start`.

## Stack

<!-- architect:stack -->
{Liste des technos. Remplie par `/architect` après que tu as validé la proposition. Exemple final :
- Frontend : Next.js (App Router) + Tailwind + shadcn/ui
- Backend : n8n (moteur de génération) + Supabase (stockage + auth)
- Hosting : Vercel pour le frontend, n8n self-hosted ou cloud
- Langue : français uniquement (interface, contenus, mentions légales)}
<!-- /architect:stack -->

## Conventions

{Conventions de code et fichiers, écrites au fil de l'eau. Si tu accumules > 20 lignes sur un domaine précis (ex: React, n8n), déporte vers `.claude/rules/{domaine}.md` — voir `## Comment ce CLAUDE.md est entretenu` plus bas. Exemple :}

- Fichiers : kebab-case (`formulaire-devis.tsx`, pas `FormulaireDevis.tsx`)
- Commit : conventionnel (`feat:`, `fix:`, `chore:`)
- Format date : JJ/MM/AAAA
- Devises : EUR uniquement, format `1 234,56 EUR`

## Instructions

{Instructions spécifiques à ton projet, écrites au fil de l'eau. Exemple :}

- Jamais de pop-ups JavaScript (`alert`, `confirm`) : utiliser des toasts (sonner)
- Toujours valider les téléphones au format français (`+33` ou `06/07`)
- TVA par défaut : 20% (configurable en base)

## Design system (si web app)

<!-- design:summary -->
{Résumé du design system, écrit par `/design` après sa première exécution. 3-5 lignes max : palette principale (couleurs primaire + neutres), famille typographique, philosophie UI (épuré/dense, formel/casual). Sert de référence rapide sans devoir relire `DESIGN.md` à chaque fois. Exemple : "Palette : violet `#6855F8` primaire + neutres chauds. Typo Inter (sans-serif). UI épurée, formel mais pas froid, beaucoup de blanc. Voir `DESIGN.md` pour les tokens complets."}
<!-- /design:summary -->

## Production

<!-- ship:url -->
{Écrit par `/livrer` après le premier déploiement réussi + smoke test ✅. Contient l'URL prod, l'hosting détecté, le type de déploiement, la date de livraison, le dernier smoke test. Exemple : "- **URL production** : https://mon-projet.vercel.app — **Hosting** : Vercel — **Type** : webapp — **Livré le** : 2026-05-15 — **Dernier smoke test** : ✅ 2026-05-15 14:32"}
<!-- /ship:url -->

## Création UI (si web app) — division du travail `/design` vs `/frontend-design`

Deux skills travaillent en duo pour l'UI. Ils sont **complémentaires**, pas concurrents :

- **`/design`** (skill du kit) — **définit le système** 1 fois après `/architect`. Sortie : `DESIGN.md` (palette, typo, composants, tokens). Invoqué explicitement par toi.
- **`/frontend-design`** (plugin Anthropic) — **construit les composants** à chaque création UI. Sortie : code TSX prêt-à-l'emploi. Auto-déclenché par Claude sur tout frontend work.

Métaphore : `/design` dessine les plans (architecte), `/frontend-design` monte les murs en suivant les plans (constructeur).

**Règle non-négociable** : avant de créer ou modifier un composant UI, un layout, ou une page → **lire `DESIGN.md` à la racine** pour récupérer les tokens. Si `DESIGN.md` n'existe pas et que la tâche touche à l'UI, **stop** et propose à l'utilisateur de lancer `/design` d'abord — sans design system, le rendu sera incohérent d'une page à l'autre.

`DESIGN.md` suit la **spec officielle Google open-source** (`version: alpha`, publiée par l'équipe Stitch — `https://stitch.withgoogle.com/docs/design-md/overview/`) : YAML front matter avec tokens (`colors`, `typography`, `rounded`, `spacing`, `components`) + 8 sections markdown canoniques (Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts). Références cross-sections via `{colors.primary}`, `{typography.body-md}`, etc.

Quand le plugin `frontend-design@claude-code-plugins` est invoqué (auto ou explicite), référence toujours `DESIGN.md` dans le prompt envoyé au plugin pour qu'il consomme les tokens. Lint optionnel : `npx @google/design.md lint DESIGN.md` (valide structure, refs de tokens, contrastes WCAG AA).

## Contexte métier

{Le vocabulaire et les règles métier propres à ton domaine, écrits au fil de l'eau. Exemple :}

- Un "devis" = document commercial avec mentions légales obligatoires (SIRET, RCS, TVA, conditions de paiement)
- Statuts : `brouillon` → `en_revue` → `envoye` → `accepte` / `refuse`
- Le devis n'est JAMAIS envoyé automatiquement. Le pro doit valider chaque envoi. C'est non-négociable.

---

## Règles de comportement

### 1. Réfléchir avant de coder

- Énonce tes hypothèses explicitement. Si tu n'es pas sûr, demande.
- Si plusieurs interprétations sont possibles, présente-les. Ne choisis pas en silence.
- Si une approche plus simple existe, dis-le.
- Si quelque chose n'est pas clair, arrête-toi. Nomme ce qui te pose problème. Demande.

### 2. Simplicité d'abord

- Le minimum de code qui résout le problème. Rien de spéculatif.
- Pas de feature au-delà de ce qui est demandé.
- Pas d'abstraction pour du code qui ne sert qu'une fois.
- Pas de "flexibilité" ou de "configurabilité" non demandée.
- Pas de gestion d'erreur pour des scénarios impossibles.
- Si tu écris 200 lignes et que ça peut tenir en 50, refais.

### 3. Modifications chirurgicales

- Touche uniquement aux fichiers que tu dois toucher.
- N'améliore pas le code adjacent qui n'est pas cassé.
- Garde le style existant, même si tu ferais autrement.
- Si tu vois du code mort sans rapport avec ta tâche, mentionne-le, ne le supprime pas.
- Test : chaque ligne modifiée doit tracer directement à la demande utilisateur.

### 4. Exécution orientée but

- Définis le critère de succès avant de commencer.
- Boucle jusqu'à ce que ce critère soit vérifié.
- Reformule la tâche en objectif vérifiable :
  - "Ajoute une validation" devient "Écris des tests pour les inputs invalides, puis fais-les passer"
  - "Corrige le bug" devient "Écris un test qui reproduit le bug, puis fais-le passer"
  - "Refactor X" devient "Vérifie que les tests passent avant et après"

### 5. Bug = test de régression d'abord, fix ensuite

Quand un bug est rapporté ou détecté en prod :

1. **Reproduire** le bug de manière déterministe (commande / clic / requête qui échoue à coup sûr).
2. **Écrire un test** qui reproduit le bug → ce test doit **échouer** sur le code actuel.
3. **Fixer** le code → le test doit maintenant **passer**.
4. **Vérifier** que les autres tests passent toujours (pas de régression croisée).

Pour cette étape, tu peux utiliser `/debug` (built-in Claude Code) pour la phase de root cause analysis. Mais le test de régression est **non-négociable** — sans, le bug peut revenir silencieusement à la prochaine modif.

### 6. Auto-évaluation : tu vérifies AVANT de dire "done"

Ne jamais annoncer "c'est bon", "ça marche", "tâche terminée" sans avoir vérifié programmatiquement ou visuellement le résultat. La règle dépend du `project_type` :

| project_type | Modif touche... | Vérification obligatoire |
|--------------|----------------|--------------------------|
| `webapp` ou `site` | UI (`.tsx`, `.css`, page, layout) | **Playwright MCP** : `browser_navigate({url})` + `browser_snapshot()` ou `browser_take_screenshot()` (screenshot dans `tmp/`). Compare au résultat attendu décrit dans la tâche. |
| `webapp` | API route / handler | `curl` ou fetch direct → vérifier status code + payload de réponse |
| `webapp` | BDD / migration | Query directe (psql / MCP) pour vérifier que la table existe, les colonnes attendues, RLS active |
| `automation` | Workflow n8n | Exécuter via `n8n_test_workflow` MCP ou `curl` sur le webhook → vérifier output + status d'exécution |
| Tout type | Tests automatisés ajoutés | Lancer le runner (`npm test` / `vitest` / etc.) → vérifier 0 failure |

**Exemple typique (webapp + modif UI)** : tu viens de modifier le formulaire de contact. Avant de marquer la tâche `[x]` :
1. Lance `npm run dev` si pas déjà actif.
2. `mcp__playwright__browser_navigate({ url: "http://localhost:3000/contact" })`
3. `mcp__playwright__browser_take_screenshot({ filename: "tmp/contact-form-modif.png" })`
4. Compare visuellement à ce que la tâche demandait. Si écart → corrige et re-vérifie.
5. Supprime le screenshot une fois la vérification consignée (le `tmp/` est gitignored mais on ne laisse pas traîner).

**Règle générale** : si tu n'arrives pas à raconter à l'utilisateur **exactement ce que tu as vérifié et observé**, tu n'as pas auto-évalué. Une supposition ("ça devrait marcher") n'est pas une vérification.

Les fichiers temporaires (screenshots, dumps, snapshots DOM) vont dans `tmp/` (gitignored par défaut). Nettoie après usage.

---

## Request Classification (LITE / STANDARD / FULL)

Le kit s'adapte à la taille du projet. Trois niveaux, proposés par `/start` Phase 4 et figés dans ce fichier :

| Niveau | Profil projet | Ce qui change |
|--------|---------------|---------------|
| **LITE** | Site vitrine 1-5 pages, automation n8n simple (1 workflow), MVP weekend | `/architect` produit un **mini-PRD 3 sections** (Identité + 1-2 Phases + Hors-MVP) au lieu du PRD complet 7 sections. `/challenge` est skippé par défaut. `/plan` peut grouper plusieurs petites tâches en une. |
| **STANDARD** | Web app SaaS classique, automation n8n multi-étapes, projet 2-5 phases | Comportement par défaut. PRD 7 sections complet, `/challenge` optionnel, `/plan` détaille tâche par tâche. |
| **FULL** | Web app complexe 5+ phases, projet client critique, sécurité / RLS / multi-tenant strict | `/challenge` est **systématique** après chaque `/plan`. `/architect` exige des AC scorés (pas juste binary). `/validate` inclut audit RLS Supabase obligatoire si données clients. |

**Niveau choisi pour ce projet** : `{LITE | STANDARD | FULL}` *(écrit par `/start` Phase 4 après ta validation)*

Si tu veux changer de niveau plus tard (ex : un projet LITE qui grossit), édite cette ligne et relance `/architect` — le kit s'adapte sans casser l'existant.

---

## Mémoire persistante

Le kit construit progressivement le **cerveau** de ton projet : gotchas, décisions d'architecture, patterns réutilisables, learnings par session. À chaque nouvelle session, `/start` et `/recap` chargent `MEMORY.md` → Claude arrive avec le contexte projet déjà compris, sans que tu aies à le relire à la main.

### Structure (créée à l'init du kit)

| Fichier / dossier | Contient | Écrit par |
|-------------------|----------|-----------|
| `MEMORY.md` (racine) | Index 1-ligne par entrée — lu en intro de chaque `/start` et `/recap` | `/close` (à chaque clôture de phase) |
| `memory/learnings/{YYYY-MM-DD}.md` | Récap **automatique** par session : commits, fichiers modifiés, durée approx. Pas de question | `/close` (toujours, low-friction) |
| `memory/topics/{domaine}.md` | Cumul par domaine (auth, n8n, deploy, bugs, etc.). Append-only | `/close` (opt-in via 3 questions ciblées : décision arch ? gotcha ? pattern ?) |
| `memory/decisions.md` | Log des choix d'arch durables (BDD, hosting, framework, etc.) | `/close` (opt-in via la 1ère question harvest) |

### Règle d'or — l'utilisateur ne touche pas à la mémoire à la main

**Tout est écrit par `/close` après chaque phase validée**. Le harvest est court :
1. Auto-récap session (toujours, pas de question) → `memory/learnings/{date}.md`
2. Question 1 : *"Une décision d'arch notable ?"* → si oui, `memory/decisions.md`
3. Question 2 : *"Un gotcha technique ?"* → si oui, `memory/topics/{domaine}.md`
4. Question 3 : *"Un pattern réutilisable ?"* → si oui, `memory/topics/{domaine}.md`
5. Si "rien" à toutes les questions → skip, pas de friction.

Au démarrage d'une nouvelle session, `/start` lit `MEMORY.md` et affiche : *"Mémoire projet : 3 topics ({liste}), dernière session il y a 4 jours"*. Toi tu décides si tu plonges (`cat memory/topics/...`) ou continues.

### Mini-glossaire mémoire

- **learnings** (par session, daté) : "ce qui s'est passé". Auto-écrit, pas de prise de décision.
- **topics** (cumulatif, par domaine) : "ce qu'on a appris sur X". Tu y reviens quand tu retouches le domaine.
- **decisions** (choix d'arch durables) : "ce qu'on a tranché et pourquoi". Utile pour les revues 6 mois plus tard.

---

## Comment ce CLAUDE.md est entretenu

### Séquencement des skills (3 parcours typiques)

**Parcours 1 — Création (premier projet)**

```
/start              ← cadrage + outillage + project_type + Request Classification
   ↓
/brainstorm         ← (optionnel) si idée floue
   ↓
/architect          ← produit PRD.md + Étape 6 scaffold le repo selon project_type + provisioning credentials
   ↓
/design             ← SI webapp : produit DESIGN.md (sinon skip)
   ↓
/plan Phase 1       ← découpe une phase en tâches
   ↓
/challenge          ← (optionnel) devil's advocate avant exécution
   ↓
/execute            ← coche les tâches une par une
   ↓
/validate           ← verdict réel "ça marche / ça marche pas"
   ↓
/close              ← mandatory : ✅ Terminée dans PRD + commit conventionnel + harvest learnings
   ↓
/plan Phase 2 → ... (boucle jusqu'à la dernière phase)
   ↓
/livrer             ← déploie en production selon ## Stack (hosting détecté, jamais hardcode)
```

**Parcours 2 — Reprise (tu reviens après quelques jours/semaines)**

```
/recap              ← lit PRD.md + plans + git log + MEMORY.md → "tu as Phase 1 ✅, Phase 2 en cours, action suggérée : /execute"
   ↓
{action proposée}   ← /execute, /plan Phase N+1, /livrer, /evoluer... selon l'état détecté
```

**Parcours 3 — Évolution (projet livré, tu veux ajouter une feature)**

```
/recap              ← détecte projet livré → propose /evoluer
   ↓
/evoluer            ← parse PRD existant + 3 questions cadrage feature + insère Phase N+1 sans écraser
   ↓
/plan Phase N+1     ← reprend le flux standard
   ↓
/execute → /validate → /close → /livrer
```

**Conditionnels** :
- `/architect` Étape 2b demande les **providers favoris** (hosting / BDD / email) avant de figer la stack. Défauts si l'utilisateur n'a pas d'avis : Vercel + Supabase + Resend (couverts par la communauté IAPreneurs).
- `/architect` Étape 6 (Provisioning & Scaffold) branche sur `project_type` ET la stack retenue : `site` = framework minimal + optionnel email, `webapp` = framework + BDD init + .env, `automation` = dossier `workflows/` + test n8n MCP.
- `/design` skip si `project_type` ∈ {automation, site simple} ou si le projet n'a pas d'UI custom.
- `/brainstorm` skip si l'idée est déjà claire après `/start`.
- `/challenge` skip si Request Classification = LITE.
- Pour un bug → `/debug` (built-in Claude Code natif) + écrire un test de régression avant le fix (règle TDD).
- Pour capturer un learning → c'est `/close` qui le fait via 3 questions ciblées en fin de phase. Tu n'édites jamais `memory/` à la main.

### Qui écrit quelle section de ce fichier

| Section | Écrit par | Quand |
|---------|-----------|-------|
| `## Identité` | `/start` | Au démarrage, après les 3 questions de cadrage |
| `## Stack` | `/architect` | Après ta validation de la stack proposée |
| `## Conventions` | Toi (manuel) | Au fil de l'eau, quand tu vois Claude faire l'inverse de ce que tu veux |
| `## Instructions` | Toi (manuel) | Au fil de l'eau |
| `## Contexte métier` | Toi (manuel) | Au fil de l'eau, dès que tu utilises du vocabulaire métier que Claude doit comprendre |

Le fichier `DESIGN.md` (produit par `/design` si web app) vit à part, à la racine, et est lu automatiquement par Claude pour toute création UI (voir section "Création UI" plus bas).

Les ancres `<!-- skill:nom -->` ... `<!-- /skill:nom -->` délimitent les zones d'écriture des skills. Ne les supprime pas. Si tu veux retirer le contenu sans casser le skill, laisse les ancres vides.

### Garder ce fichier court : déporter vers `.claude/rules/`

Quand `## Conventions` ou `## Instructions` dépasse **20 lignes pour un seul domaine** (ex: 20 règles React, 15 règles n8n), déporte vers un fichier `.claude/rules/{domaine}.md` avec un frontmatter `paths:` qui dit quand le fichier doit être chargé :

```markdown
---
paths: src/**/*.{ts,tsx}
---

# Règles frontend
- Toujours utiliser shadcn/ui pour les boutons (jamais <button> brut)
- Toujours sonner (pas alert/confirm)
- ...
```

Claude chargera ce fichier **automatiquement** quand il touchera un fichier qui match `paths:` (ici n'importe quel `.ts`/`.tsx` dans `src/`). Ton `CLAUDE.md` reste court — il devient un index, plus une encyclopédie.

Voir `.claude/rules/README.md` pour le détail du pattern + 1 exemple prêt à l'emploi (`frontend.md`).

---

## Skills disponibles dans ce kit

**Table principale — 10 commandes du cycle de vie projet** *(certaines arrivent en v2.0.0 GA — voir colonne "Statut")* :

| Skill | Pour quoi | Quand | Statut |
|-------|-----------|-------|--------|
| `/start` | Cadrage projet + sécurisation credentials + vérif outillage + routage. Détecte aussi projet existant et bifurque vers `/recap`. | 1x à l'ouverture d'une nouvelle session | ✅ |
| `/brainstorm` | Clarifier une idée vague en 3 questions | Si l'idée n'est pas claire après `/start` | ✅ |
| `/architect` | Produire un `PRD.md` structuré (mini-3-sections en LITE, 7 sections en STANDARD/FULL) + **Étape 6 Provisioning & Scaffold** (scaffold le repo selon `project_type` + providers retenus + écriture `.env`) | Une fois l'idée claire | ✅ |
| `/design` | Produire `DESIGN.md` (palette, typo, composants) lu par `frontend-design` | Après `/architect`, **uniquement si project_type = webapp** | ✅ |
| `/plan` | Découper UNE phase du PRD en tâches numérotées (adapte les questions selon `project_type`) | Avant d'exécuter une phase | ✅ |
| `/execute` | Exécuter le plan tâche par tâche, coche les `[x]` au fil de l'eau | Après `/plan` (et éventuellement `/challenge`) | ✅ |
| `/validate` | Vérifier que la phase marche pour de vrai (Playwright / n8n / curl / audit policy d'accès BDD) | Après `/execute` | ✅ |
| `/close` | Clôturer la phase : ✅ Terminée dans PRD + commit conventionnel + harvest learnings + suggestion next | **Mandatory** après `/validate ✅` | ✅ |
| `/livrer` | Déployer en production selon `## Stack` (hosting/BDD/email détectés depuis CLAUDE.md, jamais hardcode) + checklist policy d'accès advisory + smoke test | Quand la dernière phase est `/close` | ✅ |
| `/evoluer` | Ajouter une nouvelle feature à un projet livré : insère Phase N+1 dans PRD existant sans écraser (regex parse + 3 questions + idempotent) | Sur projet livré, quand tu veux scaler | ✅ |

**Skills optionnels avancés** :

| Skill | Pour quoi | Quand |
|-------|-----------|-------|
| `/challenge` | Devil's advocate sur un plan : 3 risques + 3 hypothèses + GO/REWORK/STOP | Avant `/execute`, systématique en Request Classification FULL |

**Notes hors table** :
- Tu reviens après une pause ? Tape `/recap` — lit PRD/plans/git log/MEMORY.md et propose la suite.
- Pour debugger un bug → tape `/debug` (built-in Claude Code natif). Règle de comportement : **écris d'abord un test de régression qui reproduit le bug, puis fais-le passer** (TDD).
- **Mémoire persistante** : `/close` maintient automatiquement `memory/learnings/`, `memory/topics/`, `memory/decisions.md`, et `MEMORY.md` (index) à chaque clôture de phase. **Tu n'éditeras jamais ces fichiers à la main** — c'est `/close` qui pose 3 questions ciblées (décision arch ? gotcha ? pattern réutilisable ?) et écrit les réponses dans le bon fichier. Voir `## Mémoire persistante` plus bas.

**Skills `n8n-*`** : 7 skills officiels [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT) dans `.claude/skills/n8n/`. Auto-invoqués quand tu touches à n8n.

## Sous-agent

- `research-delegate` — sous-agent read-only invoqué automatiquement par `/brainstorm` (recherche web), `/plan` (scout codebase anti-doublons), `/execute` (lecture doc API quand bloqué), `/validate` (parallélisation phases multi-dimensions). Lit jusqu'à 15 sources et renvoie une synthèse en 3-10 bullets. Garde ta fenêtre de contexte propre.

Tu n'as pas besoin de l'invoquer manuellement — les skills le font quand pertinent. Voir `.claude/agents/research-delegate.md`.

---

## Sécurité des credentials

**Règle non-négociable** : aucune clé API, token, mot de passe ne doit finir en clair dans un fichier committé.

Pattern recommandé (Anthropic-officiel) :

1. **`.env`** à la racine — vraies valeurs, **gitignored** (vérifié par `/start`)
2. **`.env.example`** committé — placeholders pour les futurs forkers/collègues
3. **`.mcp.json`** committé avec syntaxe `${VAR}` (env var expansion) — pas de valeur en dur :
   ```json
   {
     "mcpServers": {
       "n8n": {
         "command": "npx", "args": ["-y", "n8n-mcp@latest"],
         "env": { "N8N_API_KEY": "${N8N_API_KEY}" }
       }
     }
   }
   ```
   Le `-y` dans `args` évite que npx te bloque sur un prompt "install ?" au premier lancement du MCP.
4. **Charger `.env` dans le shell** avant `claude` : `set -a && source .env && set +a` (ou installer `direnv` pour le faire automatiquement)

Si tu vois un secret en clair quelque part dans le repo, **stop immédiatement** et déplace-le dans `.env`. Re-write l'historique git si nécessaire (`git filter-repo` ou re-création du repo si récent).

---

## MCP & plugin à installer

Le kit fournit un `.mcp.json` quasi-vide. `/start` te guide pour ajouter ceux-ci proprement (avec sécurisation des credentials) :

| Outil | Pour quoi | Credentials nécessaires |
|-------|-----------|--------------------------|
| **Playwright MCP** | `/validate` option A : navigateur, snapshot DOM | Aucune |
| **n8n MCP** (czlonkowski) | Créer / valider / debugger des workflows n8n | `N8N_API_URL` + `N8N_API_KEY` → `.env` |
| **Plugin `frontend-design`** (Anthropic) | Composants UI propres (shadcn/Tailwind) au lieu de HTML générique | Aucune |

Commandes brutes si tu préfères installer sans passer par `/start` :

```bash
# Playwright (aucun credential)
claude mcp add playwright -- npx -y @playwright/mcp@latest

# n8n — les single-quotes (') sont OBLIGATOIRES autour de N8N_API_URL=${N8N_API_URL}.
# Avec des double-quotes ("), ton shell développerait ${N8N_API_URL} immédiatement au moment du
# `claude mcp add` (souvent à vide si .env pas encore sourcé) → la valeur en dur serait stockée
# dans .mcp.json. Avec single-quotes, la chaîne ${N8N_API_URL} est stockée littéralement et
# résolue plus tard par Claude au lancement du MCP. Le -y évite le prompt npx.
claude mcp add n8n -e 'N8N_API_URL=${N8N_API_URL}' -e 'N8N_API_KEY=${N8N_API_KEY}' -- npx -y n8n-mcp@latest

# Plugin frontend-design
claude plugin install frontend-design@claude-code-plugins
```

Puis : `claude mcp list` et `claude plugin list` pour vérifier.
