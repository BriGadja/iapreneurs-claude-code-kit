# Kit IAPreneurs Claude Code — doc de référence

> Doc de référence complète du kit. **Lue à la demande, pas à chaque session.** Pour démarrer un projet : tape `/start`. Le `CLAUDE.md` à la racine ne contient que ce qui sert à *chaque* session — tout le reste vit ici.

## Skills du kit

### Table principale — 10 commandes du cycle de vie projet

| Skill | Pour quoi | Quand | Statut |
|-------|-----------|-------|--------|
| `/start` | Cadrage projet + sécurisation credentials + vérif outillage + routage. Détecte aussi projet existant et bifurque vers `/prime`. Écrit `project_type` ∈ `{webapp, site, automation}` dans CLAUDE.md `## Identité`. | 1x à l'ouverture d'une nouvelle session | ✅ |
| `/brainstorm` | Clarifier une idée vague en 3 questions. Route 2 délègue à `research-delegate` pour explorer projets similaires. | Si l'idée n'est pas claire après `/start` | ✅ |
| `/architect` | Produire un `PRD.md` structuré (mini-3-sections en LITE, 7 sections en STANDARD/FULL) + **Étape 2b providers favoris** (hosting/BDD/email) + **Étape 6 Provisioning & Scaffold** (scaffold le repo selon `project_type` + retenus + écriture `.env`). Écrit `## Stack` dans CLAUDE.md. | Une fois l'idée claire | ✅ |
| `/design` *(webapp uniquement)* | Définit le design system au format **DESIGN.md officiel Google** (open-source, spec alpha). Template fourni. **Complémentaire** au plugin Anthropic `frontend-design`. | Après `/architect`, **uniquement si project_type = webapp** | ✅ |
| `/plan` | Découper UNE phase du PRD en tâches numérotées avec critères "Fait quand". Adapte ses questions selon `project_type`. | Avant d'exécuter une phase | ✅ |
| `/execute` | Exécuter le plan tâche par tâche, coche les `[x]` au fil de l'eau. Délègue à `research-delegate` si bloqué par une doc API externe. | Après `/plan` (et éventuellement `/challenge`) | ✅ |
| `/validate` | Vérifier que la phase marche pour de vrai (Playwright / n8n / curl / **audit policy d'accès BDD** si données clients). Jamais "ça devrait marcher". | Après `/execute` | ✅ |
| `/close` | Clôturer la phase : ✅ Terminée dans PRD + commit conventionnel + harvest learnings (3 questions ciblées) + suggestion next. | **Mandatory** après `/validate ✅` | ✅ |
| `/livrer` | Déployer en production selon `## Stack` (hosting/BDD/email **détectés depuis CLAUDE.md, jamais hardcode** — Vercel/Netlify/Cloudflare/GitHub Pages/autre) + checklist policy d'accès advisory + smoke test. | Quand la dernière phase est `/close` | ✅ |
| `/evoluer` | Ajouter une nouvelle feature à un projet livré : insère Phase N+1 dans PRD existant sans écraser (regex parse + 3 questions + idempotent). | Sur projet livré, quand tu veux scaler | ✅ |

### Skills optionnels avancés

| Skill | Pour quoi | Quand |
|-------|-----------|-------|
| `/challenge` | Devil's advocate sur un plan : 3 risques + 3 hypothèses non vérifiées + verdict GO/REWORK/STOP. | Avant `/execute`, systématique en Request Classification FULL |

### Hors table — built-in & utilitaires

- **`/prime`** — rituel d'entrée de session sur un projet existant (matin, après pause, reprise J+15). Lit `PRD.md` + `STRUCTURE.md` + plans (`docs/plans/` priorité, fallback `plans/` puis racine) + git log + `MEMORY.md` et propose 1-3 actions concrètes. `/start` détecte automatiquement les projets existants et bifurque vers `/prime`. *(Note : ce `/prime` est custom au kit IAPreneurs — ne pas confondre avec d'autres outils tiers homonymes.)*
- **`/debug`** (built-in Claude Code natif) — pour debugger un bug. **Règle de comportement** : écris d'abord un test de régression qui reproduit le bug, puis fais-le passer (TDD).
- **`/start` Phase 4** — propose le niveau Request Classification (LITE / STANDARD / FULL). Stocké dans `CLAUDE.md ## Request Classification`.

### Skills `n8n-*` — 7 skills tiers

7 skills officiels [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT) dans `.claude/skills/n8n/` :
- `n8n-mcp-tools-expert`
- `n8n-workflow-patterns`
- `n8n-validation-expert`
- `n8n-node-configuration`
- `n8n-expression-syntax`
- `n8n-code-javascript`
- `n8n-code-python`

Auto-invoqués quand tu touches à n8n. Attribution dans `.claude/skills/n8n/LICENSE-czlonkowski`.

---

## 3 parcours typiques

### Parcours 1 — Création (premier projet)

```
/start              ← cadrage + outillage + project_type + Request Classification
   ↓
/brainstorm         ← (optionnel) si idée floue
   ↓
/architect          ← PRD.md + Étape 2b providers + Étape 6 scaffold + provisioning
   ↓
/design             ← SI webapp : produit DESIGN.md (sinon skip)
   ↓
/plan Phase 1       ← découpe une phase en tâches
   ↓
/challenge          ← (optionnel) devil's advocate avant exécution
   ↓
/execute            ← coche les [x] une par une
   ↓
/validate           ← verdict réel "ça marche / ça marche pas"
   ↓
/close              ← MANDATORY : ✅ Terminée + commit + harvest learnings
   ↓
/plan Phase 2 → ... (boucle jusqu'à la dernière phase)
   ↓
/livrer             ← deploy prod selon ## Stack (hosting détecté, jamais hardcode)
```

### Parcours 2 — Reprise (tu reviens après quelques jours/semaines)

```
/prime              ← lit PRD.md + plans + git log + MEMORY.md → "tu as Phase 1 ✅, Phase 2 en cours, action suggérée : /execute"
   ↓
{action proposée}   ← /execute, /plan Phase N+1, /livrer, /evoluer... selon l'état détecté
```

### Parcours 3 — Évolution (projet livré, tu veux ajouter une feature)

```
/prime              ← détecte projet livré → propose /evoluer
   ↓
/evoluer            ← parse PRD existant + 3 questions cadrage feature + insère Phase N+1 sans écraser
   ↓
/plan Phase N+1     ← reprend le flux standard
   ↓
/execute → /validate → /close → /livrer
```

---

## Qui écrit quelle section du CLAUDE.md

| Section | Ancre HTML | Écrit par | Quand |
|---------|-----------|-----------|-------|
| `## Identité` | `<!-- start:identité -->` | `/start` | Au démarrage, après les 3 questions de cadrage. Inclut `project_type:`. |
| `## Stack` | `<!-- architect:stack -->` | `/architect` | Après ta validation de la stack proposée |
| `## Design system` | `<!-- design:summary -->` | `/design` | Après création de `DESIGN.md` (webapp uniquement) |
| `## Production` | `<!-- ship:url -->` | `/livrer` | Après premier déploiement réussi + smoke test |
| `## Request Classification` | (heading) | `/architect` Étape 3.1 | Après ta validation du niveau LITE/STANDARD/FULL |
| `## Conventions` | — | Toi (manuel) | Au fil de l'eau, quand tu vois Claude faire l'inverse |
| `## Instructions` | — | Toi (manuel) | Au fil de l'eau |
| `## Contexte métier` | — | Toi (manuel) | Au fil de l'eau, dès que tu utilises du vocabulaire métier |

**Règle d'or** : les ancres `<!-- skill:nom -->` ... `<!-- /skill:nom -->` délimitent les zones d'écriture des skills. **Ne les supprime pas.** Si tu veux retirer le contenu sans casser le skill, laisse les ancres vides.

Le fichier `DESIGN.md` (produit par `/design` si webapp) vit à part, à la racine, et est lu automatiquement par Claude pour toute création UI (voir CLAUDE.md `## Création UI`).

---

## Conditionnels — quand skip un skill

- **`/architect` Étape 2b** demande les **providers favoris** (hosting / BDD / email) avant de figer la stack. Défauts si l'utilisateur n'a pas d'avis : Vercel + Supabase + Resend (couverts par la communauté IAPreneurs).
- **`/architect` Étape 6** (Provisioning & Scaffold) branche sur `project_type` ET la stack retenue : `site` = framework minimal + optionnel email, `webapp` = framework + BDD init + .env, `automation` = dossier `workflows/` + test n8n MCP.
- **`/design` skip** si `project_type` ∈ {automation, site simple} ou si le projet n'a pas d'UI custom.
- **`/brainstorm` skip** si l'idée est déjà claire après `/start`.
- **`/challenge` skip** si Request Classification = LITE. Systématique en FULL.
- **Pour un bug** → `/debug` (built-in Claude Code natif) + écrire un test de régression avant le fix (règle TDD).
- **Pour capturer un learning** → c'est `/close` qui le fait via 3 questions ciblées en fin de phase. Tu n'édites jamais `memory/` à la main.

---

## Sous-agent `research-delegate`

Sous-agent read-only invoqué automatiquement par :
- `/brainstorm` (recherche web)
- `/plan` (scout codebase anti-doublons)
- `/execute` (lecture doc API quand bloqué)
- `/validate` (parallélisation phases multi-dimensions)

Lit jusqu'à 15 sources et renvoie une synthèse en 3-10 bullets. Garde ta fenêtre de contexte propre. Tu n'as pas besoin de l'invoquer manuellement — les skills le font quand pertinent. Voir `.claude/agents/research-delegate.md`.

---

## MCP & plugin — installation détaillée

Le kit fournit un `.mcp.json` quasi-vide. `/start` te guide pour ajouter ceux-ci proprement (avec sécurisation des credentials) :

| Outil | Pour quoi | Credentials nécessaires |
|-------|-----------|--------------------------|
| **Playwright MCP** | `/validate` option A : navigateur, snapshot DOM | Aucune |
| **n8n MCP** (czlonkowski) | Créer / valider / debugger des workflows n8n. Deux modes (voir ci-dessous) | 3 env vars MCP **obligatoires** + (optionnel) `N8N_API_URL` + `N8N_API_KEY` |
| **Plugin `frontend-design`** (Anthropic) | Composants UI propres (shadcn/Tailwind) au lieu de HTML générique | Aucune |

### n8n MCP — deux modes selon ton besoin

Le MCP czlonkowski tourne dans 2 modes, déterminés uniquement par la présence (ou non) de `N8N_API_URL` + `N8N_API_KEY` :

- **Docs-only (7 tools)** — `search_nodes`, `get_node_documentation`, `search_templates`, `get_template`, `validate_workflow_json`, etc. Aucun credential n8n requis. Parfait pour **apprendre** n8n ou **prototyper** un workflow en local avant d'avoir une instance.
- **API-connected (20 tools)** — les 7 docs + 13 management : `n8n_create_workflow`, `n8n_update_full_workflow`, `n8n_test_workflow`, `n8n_executions`, `n8n_audit_instance`, etc. Nécessite une instance n8n active + sa clé API.

**Les 3 env vars MCP suivantes sont obligatoires** dans les deux modes (sinon le canal stdio se pollue et Claude voit des JSON parse errors) :
- `MCP_MODE=stdio`
- `LOG_LEVEL=error`
- `DISABLE_CONSOLE_OUTPUT=true`

### Commandes brutes (si tu préfères installer sans `/start`)

```bash
# Playwright (aucun credential)
claude mcp add playwright -- npx -y @playwright/mcp@latest

# n8n MCP — mode docs-only (sans instance n8n, 7 tools, marche immédiatement)
# Les 3 env vars MCP_MODE/LOG_LEVEL/DISABLE_CONSOLE_OUTPUT sont OBLIGATOIRES.
claude mcp add n8n-mcp \
  -e MCP_MODE=stdio \
  -e LOG_LEVEL=error \
  -e DISABLE_CONSOLE_OUTPUT=true \
  -- npx -y n8n-mcp@latest

# n8n MCP — mode API-connected (20 tools)
# Les single-quotes (') sont OBLIGATOIRES autour de ${N8N_API_*}. Avec des double-quotes ("),
# ton shell développerait ${N8N_API_URL} immédiatement au moment du `claude mcp add` (souvent
# à vide si .env pas encore sourcé) → la valeur en dur serait stockée dans .mcp.json. Avec
# single-quotes, la chaîne ${N8N_API_URL} est stockée littéralement et résolue plus tard par
# Claude au lancement du MCP.
claude mcp add n8n-mcp \
  -e MCP_MODE=stdio \
  -e LOG_LEVEL=error \
  -e DISABLE_CONSOLE_OUTPUT=true \
  -e 'N8N_API_URL=${N8N_API_URL}' \
  -e 'N8N_API_KEY=${N8N_API_KEY}' \
  -- npx -y n8n-mcp@latest

# Plugin frontend-design
claude plugin install frontend-design@claude-code-plugins
```

Puis : `claude mcp list` et `claude plugin list` pour vérifier.

> **Pin de version recommandé** — `n8n-mcp@latest` te donne le dernier release (czlonkowski ship souvent : `2.51.x` actuellement). Pour la reproductibilité, pinne une version explicite dans `.mcp.json` (ex : `n8n-mcp@2.51.3`) et bump volontairement après avoir lu le CHANGELOG.

### Pattern Anthropic-officiel pour les credentials

1. **`.env`** à la racine — vraies valeurs, **gitignored** (vérifié par `/start`)
2. **`.env.example`** committé — placeholders pour les futurs forkers/collègues
3. **`.mcp.json`** committé avec syntaxe `${VAR}` (env var expansion) — pas de valeur en dur :
   ```json
   {
     "mcpServers": {
       "n8n-mcp": {
         "command": "npx",
         "args": ["-y", "n8n-mcp@latest"],
         "env": {
           "MCP_MODE": "stdio",
           "LOG_LEVEL": "error",
           "DISABLE_CONSOLE_OUTPUT": "true",
           "N8N_API_URL": "${N8N_API_URL}",
           "N8N_API_KEY": "${N8N_API_KEY}"
         }
       }
     }
   }
   ```
   Le `-y` dans `args` évite que npx te bloque sur un prompt "install ?" au premier lancement du MCP. Si tu veux le mode docs-only, retire les 2 dernières lignes `N8N_API_*`.
4. **Charger `.env` dans le shell** avant `claude` : `set -a && source .env && set +a` (ou installer `direnv` pour le faire automatiquement)

### Directives système (Silent Execution, Templates-First, Validate Before Deploy)

Le créateur du MCP prescrit 4 directives pour utiliser l'outil correctement. Elles sont consignées dans **`.claude/rules/n8n.md`** (auto-chargées sur `.workflow.json`, `.mcp.json`, et tout fichier du dossier `.claude/skills/n8n/`). En résumé : `search_templates` avant de coder, `validate_workflow` avant de déployer, jamais d'édition AI directe sur `[PROD]`, exécution silencieuse des outils.

Si tu vois un secret en clair quelque part dans le repo, **stop immédiatement** et déplace-le dans `.env`. Re-write l'historique git si nécessaire (`git filter-repo` ou re-création du repo si récent).

---

## Aller plus loin

- `.claude/rules/README.md` — pattern des règles auto-chargées par chemin (paths-scoped)
- `memory/README.md` — système mémoire persistante (learnings / topics / decisions)
- `.claude/skills/{skill}/SKILL.md` — détail d'un skill spécifique
- `examples/` — 3 exemples remplis (site, webapp, automation)
