# CLAUDE.md — Template à adapter

> Ce fichier est un **template**. Tu le copies dans ton projet, tu adaptes les 5 couches du début à ton cas, tu gardes les 4 règles de comportement à la fin (elles s'appliquent à n'importe quel projet).

> **À l'ouverture d'une nouvelle session** : tape `/start` — le skill te guide pour cadrer le projet, sécuriser tes credentials, vérifier ton outillage (MCP + plugin), et te router vers la bonne suite (`/brainstorm` ou `/architect`).

---

# {Nom de ton projet}

> Tout ce qui suit est à adapter à TON projet. Les sections marquées `<!-- skill:nom -->` sont mises à jour par les skills correspondants — garde les ancres HTML, sinon le skill ne sait plus où écrire.

## Identité

<!-- start:identité -->
{En 2-3 phrases : ce qu'est ton projet, à qui il s'adresse, et le résultat qu'il livre. Cette section est remplie par `/start` après ses 3 questions de cadrage. Exemple final : "Application web qui automatise la génération de devis pour un freelance français. Le client final reçoit des demandes via formulaire, un moteur n8n qualifie + calcule + stocke le devis, le pro relit et envoie."}
<!-- /start:identité -->

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

## Création UI (si web app)

Avant de créer ou modifier un composant UI, un layout, ou une page : **lire `DESIGN.md` à la racine** pour récupérer les tokens (palette, typographie, composants définis). Si `DESIGN.md` n'existe pas et que la tâche touche à l'UI, **stop** et propose à l'utilisateur de lancer `/design` d'abord — sans design system, le rendu sera incohérent d'une page à l'autre.

`DESIGN.md` suit la **spec officielle Google open-source** (`version: alpha`, publiée par l'équipe Stitch — `https://stitch.withgoogle.com/docs/design-md/overview/`) : YAML front matter avec tokens (`colors`, `typography`, `rounded`, `spacing`, `components`) + 8 sections markdown canoniques (Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts). Références cross-sections via `{colors.primary}`, `{typography.body-md}`, etc.

Cette règle s'applique aussi quand le plugin `frontend-design@claude-code-plugins` est invoqué : référence `DESIGN.md` dans le prompt envoyé au plugin. Lint optionnel : `npx @google/design.md lint DESIGN.md` (valide structure, refs de tokens, contrastes WCAG AA).

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

---

## Comment ce CLAUDE.md est entretenu

### Séquencement des skills (workflow type)

```
/start                  ← 1x au démarrage (cadrage + outillage + routage)
   ↓
/brainstorm             ← si idée floue (skippé sinon)
   ↓
/architect              ← produit PRD.md (source de vérité pour tout ce qui suit)
   ↓
/design                 ← SI web app : produit DESIGN.md (palette, typo, composants)
   ↓
/plan Phase 1           ← découpe une phase en tâches (lit DESIGN.md si phase UI)
   ↓
/challenge (optionnel)  ← devil's advocate avant exécution
   ↓
/execute Phase 1        ← coche les tâches une par une
   ↓
/validate Phase 1       ← verdict réel "ça marche / ça marche pas"
   ↓
/plan Phase 2 → ... (boucle)
```

`/design` est conditionnel (skip si pas d'UI : script CLI, automation n8n pure, API). `/challenge` est optionnel — à ajouter quand tu sens que `/plan` te laisse partir avec des angles morts.

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

| Skill | Pour quoi | Quand |
|-------|-----------|-------|
| `/start` | Cadrage projet + sécurisation credentials + vérif outillage + routage | 1x à l'ouverture d'une nouvelle session |
| `/brainstorm` | Clarifier une idée vague en 3 questions | Si l'idée n'est pas claire après `/start` |
| `/architect` | Produire un `PRD.md` structuré (7 sections) | Une fois l'idée claire |
| `/design` | Produire `DESIGN.md` (palette, typo, composants) lu par `frontend-design` | Après `/architect`, **uniquement si web app** |
| `/plan` | Découper UNE phase du PRD en tâches numérotées (lit `DESIGN.md` si phase UI) | Avant d'exécuter une phase |
| `/challenge` *(optionnel)* | Devil's advocate sur un plan : 3 risques + 3 hypothèses + GO/REWORK/STOP | Avant `/execute`, quand tu veux un dernier crible |
| `/execute` | Exécuter le plan tâche par tâche | Après `/plan` (et éventuellement `/challenge`) |
| `/validate` | Vérifier que la phase marche pour de vrai (Playwright / n8n / autre) | Après `/execute` |
| 7 skills `n8n-*` | Créer / valider / debugger des workflows n8n | Auto-invoqués quand tu touches à n8n |

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
         "command": "npx", "args": ["n8n-mcp@latest"],
         "env": { "N8N_API_KEY": "${N8N_API_KEY}" }
       }
     }
   }
   ```
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

# n8n (les ${VAR} restent littéraux grâce aux quotes simples — expansion au lancement de claude)
claude mcp add n8n -e 'N8N_API_URL=${N8N_API_URL}' -e 'N8N_API_KEY=${N8N_API_KEY}' -- npx n8n-mcp@latest

# Plugin frontend-design
claude plugin install frontend-design@claude-code-plugins
```

Puis : `claude mcp list` et `claude plugin list` pour vérifier.
