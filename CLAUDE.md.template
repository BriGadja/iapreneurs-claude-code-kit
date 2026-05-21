# CLAUDE.md — Template à adapter

> Ce fichier est un **template**. Tu adaptes les sections projet en haut, tu gardes les règles de comportement en bas. La méta-doc complète du kit (skills, parcours, MCP) est dans [`docs/KIT.md`](docs/KIT.md).

> **À l'ouverture d'une nouvelle session** : tape `/start` — il cadre le projet, sécurise tes credentials, vérifie l'outillage, et te route vers `/brainstorm` ou `/architect`. Si tu reprends une session de travail sur un projet existant (matin, après pause, ou retour J+15), tape `/prime` (couvre aussi la reprise après absence).

> **Rituel par feature (boucle interne PIV)** : `/prime` (recharge contexte depuis `STATUS.md`) → `/plan` (cadre la feature) → `/execute` (implémente) → `/validate` (vérifie) → `/close` (commit + mémoire + `STATUS.md`) → `/clear` (contexte propre) → retour à `/prime` ou `/plan` Phase suivante. Tape `/start` uniquement à la première session sur un projet neuf.
>
> **Suivi d'état** : `STATUS.md` à la racine résume où tu en es (Dernière étape, Prochaine étape recommandée, Historique récent). Maintenu UNIQUEMENT par `/close`. À la reprise de session, `/prime` le lit en premier. Voir [`docs/KIT.md § STATUS.md & rituel`](docs/KIT.md#statusmd--rituel-close--clear--next).

## Glossaire

Quatre mots reviennent sans cesse dans ce kit :

- **Phase** — palier macro du projet, défini dans `PRD.md` (ex : "Phase 1 — Formulaire public + stockage Supabase"). Contient plusieurs tâches. Marquée `✅ Terminée` par `/close` une fois validée.
- **Tâche** — étape concrète et vérifiable d'une phase, listée dans `phase-N-plan.md`. Cochée `[x]` par `/execute` au fil de l'eau.
- **Critère "Fait quand"** — définition de done d'une tâche, écrite avant de commencer. Sans ce critère, tu ne sais pas quand t'arrêter.
- **Critères de succès** — définition de done d'une phase entière. Vérifiés par `/validate`.

---

# {Nom de ton projet}

> Tout ce qui suit est à adapter à TON projet. Les sections marquées `<!-- skill:nom -->` sont mises à jour par les skills correspondants — garde les ancres HTML, sinon le skill ne sait plus où écrire.

## Identité

<!-- start:identité -->
{En 2-3 phrases : ce qu'est ton projet, à qui il s'adresse, et le résultat qu'il livre. Cette section est remplie par `/start` après ses 3 questions de cadrage.}

project_type: {site | webapp | automation}
<!-- /start:identité -->

> **Variable `project_type`** : déterminée par `/start`. Trois valeurs : `site` (vitrine 1-5 pages), `webapp` (SaaS auth + BDD), `automation` (workflow n8n pur). Les skills `/architect` (Étape 6), `/livrer`, `/plan` et `/design` branchent dessus. Si absente ou invalide, ils stoppent avec un message demandant de relancer `/start`.

## Stack

<!-- architect:stack -->
{Liste des technos. Remplie par `/architect` après que tu as validé la proposition. Exemple : Next.js + Supabase + n8n + Vercel.}
<!-- /architect:stack -->

## Conventions

{Conventions de code et fichiers, écrites au fil de l'eau. Si tu accumules > 20 lignes sur un domaine précis (ex: React, n8n), déporte vers `.claude/rules/{domaine}.md` avec frontmatter `paths:` — voir `.claude/rules/README.md`. Exemple :}

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
{Résumé du design system, écrit par `/design` après sa première exécution. 3-5 lignes max : palette principale, famille typographique, philosophie UI. Voir `DESIGN.md` pour les tokens complets.}
<!-- /design:summary -->

## Production

<!-- ship:url -->
{Écrit par `/livrer` après le premier déploiement réussi + smoke test ✅. Contient l'URL prod, l'hosting détecté, le type de déploiement, la date de livraison, le dernier smoke test.}
<!-- /ship:url -->

## Contexte métier

{Le vocabulaire et les règles métier propres à ton domaine, écrits au fil de l'eau. Exemple :}

- Un "devis" = document commercial avec mentions légales obligatoires (SIRET, RCS, TVA)
- Statuts : `brouillon` → `en_revue` → `envoye` → `accepte` / `refuse`
- Le devis n'est JAMAIS envoyé automatiquement. Le pro doit valider. Non-négociable.

## Création UI (si web app)

**Règle non-négociable** : avant de créer ou modifier un composant UI, un layout, ou une page → **lire `DESIGN.md` à la racine** pour récupérer les tokens. Si `DESIGN.md` n'existe pas et que la tâche touche à l'UI, **stop** et propose `/design`. Sans design system, le rendu sera incohérent.

Détail (spec Google DESIGN.md alpha, duo `/design` ⇄ plugin `frontend-design`, lint optionnel) : voir `.claude/skills/design/SKILL.md`.

<!-- n8n-section -->
{Décommenté par `.claude/rules/n8n-setup.md` si `/start` Q4 = oui (`project_uses_n8n: true`). Sinon : section absente, le kit n'embarque pas la collection n8n par défaut. Voir `.claude/rules/n8n-setup.md` pour activer.}
<!-- /n8n-section -->

## Cycle de vie d'un projet

Le kit distingue **création** (projet neuf) et **maintenance** (projet livré qui évolue). `/prime` détecte le mode via `count(docs/specs/SPEC-*.md)` :

| Mode | Trigger | Skills clés | Artefacts touchés |
|------|---------|-------------|-------------------|
| Création | `count_specs == 0` | `/start` → `/architect` → `/plan` → `/execute` → `/validate` → `/close` → `/livrer` | `PRD.md`, `STRUCTURE.md`, `memory/decisions.md` ADR-001, `docs/plans/` |
| Maintenance | `count_specs ≥ 1` | `/prime` → `/evoluer` → `/plan` → `/execute` → `/validate` → `/close` | `docs/specs/SPEC-{date}-{slug}.md`, PRD checkbox flip, `decisions.md` ADR append |

**PRD vivant** : 8 sections, cap 100 lignes, mis à jour par `/evoluer` (déplace checkboxes Hors scope → Scope actuel, append Implementation Phases). Jamais réécrit destructivement.

---

## Règles de comportement

### 1. Réfléchir avant de coder

- Énonce tes hypothèses explicitement. Si tu n'es pas sûr, demande.
- Si plusieurs interprétations sont possibles, présente-les. Ne choisis pas en silence.
- Si une approche plus simple existe, dis-le.
- Si quelque chose n'est pas clair, arrête-toi. Nomme ce qui te pose problème. Demande.

### 2. Simplicité d'abord

- Le minimum de code qui résout le problème. Rien de spéculatif.
- Pas de feature, abstraction, ou "configurabilité" au-delà de ce qui est demandé.
- Si tu écris 200 lignes et que ça peut tenir en 50, refais.

### 3. Modifications chirurgicales

- Touche uniquement aux fichiers que tu dois toucher.
- N'améliore pas le code adjacent qui n'est pas cassé.
- Garde le style existant, même si tu ferais autrement.
- Test : chaque ligne modifiée doit tracer directement à la demande utilisateur.

### 4. Exécution orientée but

- Définis le critère de succès avant de commencer. Boucle jusqu'à ce qu'il soit vérifié.
- Reformule la tâche en objectif vérifiable :
  - "Ajoute une validation" → "Écris des tests pour les inputs invalides, puis fais-les passer"
  - "Corrige le bug" → "Écris un test qui reproduit le bug, puis fais-le passer"

### 5. Bug = test de régression d'abord, fix ensuite

1. **Reproduire** le bug de manière déterministe.
2. **Écrire un test** qui reproduit le bug → il doit **échouer** sur le code actuel.
3. **Fixer** le code → le test doit maintenant **passer**, sans casser les autres.

`/debug` (built-in Claude Code) aide pour la root cause analysis. Le test de régression reste **non-négociable**.

### 6. Auto-évaluation : tu vérifies AVANT de dire "done"

> **Vocabulaire** : à chaque feature tu fais une **boucle interne** (PIV : `/prime` → `/plan` → `/execute` → `/validate` → `/close`). Quand un bug ship malgré la PIV, tu fais une **boucle externe** : tu corriges le système qui l'a laissé passer (règle dans `.claude/rules/`, étape dans un skill, assertion dans `scripts/validate-kit-v2.sh`).

Ne jamais annoncer "c'est bon", "ça marche", "tâche terminée" sans avoir vérifié programmatiquement ou visuellement le résultat. La vérification dépend du `project_type` :

| project_type | Modif touche... | Vérification obligatoire |
|--------------|----------------|--------------------------|
| `webapp` / `site` | UI (`.tsx`, `.css`, page, layout) | **Playwright MCP** : `browser_navigate` + `browser_snapshot` ou `browser_take_screenshot` (screenshot dans `tmp/`, supprime après) |
| `webapp` | API / BDD | `curl` (status + payload) ou query directe (table, colonnes, RLS) |
| `automation` | Workflow n8n | `n8n_test_workflow` MCP ou `curl` webhook → vérifier output + status |
| Tout type | Tests automatisés | `npm test` / `vitest` → 0 failure |

Si tu n'arrives pas à raconter à l'utilisateur **exactement ce que tu as vérifié et observé**, tu n'as pas auto-évalué. "Ça devrait marcher" n'est pas une vérification. Les fichiers temporaires vont dans `tmp/` (gitignored) — nettoie après usage.

---

## Request Classification (LITE / STANDARD / FULL)

Le kit s'adapte à la taille du projet. Trois niveaux, proposés par `/architect` Étape 3.1 et figés ici :

- **LITE** — Site vitrine 1-5 pages, automation simple, MVP weekend. PRD mini 3 sections, `/challenge` skippé, `/plan` peut grouper.
- **STANDARD** (défaut) — Web app SaaS classique, automation multi-étapes, 2-5 phases. PRD 7 sections, `/challenge` optionnel, `/plan` tâche par tâche.
- **FULL** — Web app complexe 5+ phases, projet client critique, RLS/multi-tenant strict. `/challenge` systématique, AC scorés, `/validate` inclut audit RLS si données clients.

**Niveau choisi pour ce projet** : `{LITE | STANDARD | FULL}` *(écrit par `/architect` Étape 3.1)*

Pour changer plus tard, édite cette ligne et relance `/architect`.

---

## Mémoire persistante

Le kit construit progressivement le **cerveau** de ton projet : gotchas, décisions d'arch, patterns réutilisables, learnings par session. À chaque nouvelle session, `/start` et `/prime` chargent `MEMORY.md` → Claude arrive avec le contexte projet déjà compris.

**Tu n'édites jamais `memory/` à la main.** C'est `/close` qui pose 3 questions ciblées en fin de phase (décision arch ? gotcha ? pattern ?) et écrit les réponses dans le bon fichier. Détail : [`memory/README.md`](memory/README.md).

---

## Sécurité

**Règle non-négociable** : aucune clé API, token ou mot de passe en clair dans un fichier committé. Pattern : `.env` (gitignored), `.env.example` (committé, placeholders), `.mcp.json` (syntaxe `${VAR}`). `/start` Étape 5b vérifie tout ça. Si tu vois un secret en clair, **stop** et déplace-le dans `.env`. Détail : [`docs/KIT.md` § MCP & plugin](docs/KIT.md#mcp--plugin--installation-détaillée).

---

## Où vivent les fichiers

Le kit applique une convention simple pour rester rangé :

**À la racine du projet** (fichiers meta + config, peu nombreux) :
- `PRD.md` (écrit par `/architect`)
- `CLAUDE.md`, `MEMORY.md`, `STRUCTURE.md` (meta, contiennent des ancres lues par les skills)
- `DESIGN.md` (écrit par `/design` — reste racine pour compat plugin `frontend-design`)
- `.env`, `.env.example`, `.gitignore`, `.mcp.json` (config)
- `README.md`, `LICENSE`

**Sous `docs/{sous-dossier}/`** (outputs des skills, peuvent être nombreux) :
- `docs/plans/phase-N-plan.md` — écrits par `/plan` et `/evoluer`
- `docs/brainstorms/{YYYY-MM-DD}-{sujet}.md` — écrits par `/brainstorm`

**Inchangés** (infra Claude Code) :
- `.claude/skills/`, `.claude/rules/`, `.claude/agents/`
- `memory/learnings/`, `memory/topics/`, `memory/decisions.md`

> **Compat projets pré-v2.1.0** : si tu as des plans en racine ou dans `plans/`, les skills consommateurs (`/prime`, `/execute`, `/validate`, `/challenge`, `/evoluer`, `/close`, `/start`) les lisent toujours en fallback. La migration manuelle vers `docs/plans/` n'est pas bloquante.

---

## Comment ce CLAUDE.md est entretenu

> **Note** : pour l'architecture détaillée du projet (arbo, patterns, tests), voir [`STRUCTURE.md`](STRUCTURE.md) — fichier séparé pour garder ce CLAUDE.md slim.

Mini-table des sections automatiquement écrites :

| Section | Écrite par | Quand |
|---------|-----------|-------|
| `## Identité` (+ `project_type`) | `/start` | À l'onboarding |
| `## Stack` | `/architect` | Après validation stack |
| `## Production` | `/livrer` | Après deploy + smoke test |
| `STRUCTURE.md` (fichier séparé) | `/architect` Étape 6.5 | Après scaffold |

Les sections `## Conventions`, `## Instructions`, `## Contexte métier` sont éditées par toi au fil de l'eau. Quand tu accumules > 20 lignes sur un seul domaine, déporte vers `.claude/rules/{domaine}.md` avec frontmatter `paths:` (voir `.claude/rules/README.md`).

Détail complet (parcours, table skills, conditionnels, sous-agent, MCP install) : [`docs/KIT.md`](docs/KIT.md).

---

**Comprendre le kit complet** → [`docs/KIT.md`](docs/KIT.md) • **Démarrer une session** → `/start`
