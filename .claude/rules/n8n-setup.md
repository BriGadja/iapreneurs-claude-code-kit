---
paths: []
---

# n8n MCP — Procédure d'installation à la demande

> **Lis ce fichier dans deux cas** :
> 1. `project_uses_n8n: true` posé par `/start` Q4 sur projet neuf (installation initiale, avant les premières features).
> 2. `/evoluer` Étape 4bis détecte que la nouvelle feature requiert n8n et que le MCP est absent du `.mcp.json` (installation à chaud sur projet existant).
>
> Le kit n'embarque pas la collection n8n par défaut — opt-in via cette procédure pour rester slim.
>
> Source upstream officielle (à vérifier au moment de l'install) : <https://github.com/czlonkowski/n8n-mcp>

## Procédure (5 étapes, one-shot)

### 1. Lis le README upstream et installe le MCP — **mode API-connected par défaut**

> **Règle non-négociable** : on installe TOUJOURS en mode **API-connected** (20+ tools, capable de créer/modifier/tester des workflows réels). Le mode docs-only (7 tools, lecture seule) est un fallback d'urgence — pas le défaut. Sans API-connected, `/execute` ne peut PAS déployer un workflow n8n, ce qui casse le cas d'usage `project_type: automation`.

#### 1.a Récupère `N8N_API_URL` + `N8N_API_KEY`

Tu as besoin de **deux valeurs** avant d'éditer `.mcp.json` :

| Variable | Valeur | Où la trouver |
|----------|--------|---------------|
| `N8N_API_URL` | URL de base de ton instance n8n + `/api/v1` | Self-host : `https://n8n.tondomaine.com/api/v1`. n8n Cloud : `https://{workspace}.app.n8n.cloud/api/v1`. **Inclus toujours `/api/v1`** — sans ça, tous les appels MCP renvoient 404. |
| `N8N_API_KEY` | JWT généré dans n8n | Connecte-toi à ton instance → menu utilisateur (en bas à gauche) → **Settings** → **n8n API** → **Create an API key** → copie le token (visible une seule fois). |

Si tu n'as pas d'instance n8n :
- **Self-host rapide** : `docker run -it --rm -p 5678:5678 n8nio/n8n` puis ouvre `http://localhost:5678` et crée ton compte. URL = `http://localhost:5678/api/v1`.
- **n8n Cloud** : <https://n8n.io/cloud/> (14 jours gratuits).

#### 1.b Installe le MCP — **valeurs en clair dans `.mcp.json` (gitignoré)**

> **Pourquoi pas `${VAR}` + `.env` ?** Parce que Claude Code ne source pas `.env` tout seul : il lit `${VAR}` depuis l'environnement du **shell parent** qui a lancé `claude`. Si tu viens d'éditer `.env`, le shell parent n'a pas encore ces variables → il faut `source .env && exec $SHELL && claude` pour les charger. Sur Code Server c'est encore plus piégeux. **On évite ce problème en mettant les valeurs réelles directement dans `.mcp.json` et en gitignorant le fichier.**

Va lire le README de <https://github.com/czlonkowski/n8n-mcp> pour la commande d'install courante (généralement `npx -y n8n-mcp`). Ajoute l'entrée dans `.mcp.json` à la racine — **avec les vraies valeurs, pas `${VAR}`** :

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["-y", "n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "N8N_API_URL": "https://n8n.tondomaine.com/api/v1",
        "N8N_API_KEY": "eyJhbGciOiJIUzI1NiIs..."
      }
    }
  }
}
```

Puis sécurise le fichier :

```bash
# Gitignore .mcp.json (il contient ta clé)
grep -q '^\.mcp\.json$' .gitignore || echo '.mcp.json' >> .gitignore

# Commit un exemple propre pour tes coéquipiers
cp .mcp.json .mcp.json.example
# Édite .mcp.json.example pour remplacer la clé par "REPLACE_ME"
# Puis git add .mcp.json.example .gitignore
```

Aucune commande de shell magique à faire ensuite. **Juste redémarrer Claude Code** (sortir avec `Ctrl+C` ou `exit`, puis relancer `claude`) pour qu'il relise `.mcp.json`.

#### 1.c Vérifie le mode API-connected

Après la relance de Claude Code :

```
mcp__n8n-mcp__n8n_health_check
```

Le retour DOIT contenir `"apiConfigured": true` (ou équivalent — vérifie le shape courant via `mcp__n8n-mcp__tools_documentation`). Si tu vois `"apiConfigured": false` ou seulement 7 tools listés (`search_nodes`, `get_node`, `validate_node`, `validate_workflow`, `search_templates`, `get_template`, `tools_documentation`), tu es resté en docs-only : recommence depuis 1.a.

**Sanity check** : `mcp__n8n-mcp__n8n_list_workflows` doit retourner la liste réelle (même vide `[]`) sans erreur d'authentification. Une 401/403 = clé invalide. Une 404 = `N8N_API_URL` mal formée (oublié `/api/v1` ?).

### 2. Installe la collection de skills opérationnels czlonkowski

Repo source officiel (confirmé upstream) : <https://github.com/czlonkowski/n8n-skills>. Sept skills complémentaires : `n8n-expression-syntax`, `n8n-mcp-tools-expert`, `n8n-workflow-patterns`, `n8n-validation-expert`, `n8n-node-configuration`, `n8n-code-javascript`, `n8n-code-python`.

**Trois méthodes — Méthode 1 recommandée (= upstream README)** :

#### Méthode 1 — Plugin install (recommandée)

```
/plugin install czlonkowski/n8n-skills
```

Les 7 skills deviennent disponibles immédiatement, mises à jour gérées par Claude Code.

#### Méthode 2 — Marketplace

```
/plugin marketplace add czlonkowski/n8n-skills
/plugin install
# Sélectionne "n8n-mcp-skills" dans la liste
```

#### Méthode 3 — Clone manuel (snapshot figé, contrôle total)

```bash
cd /tmp
git clone --depth=1 https://github.com/czlonkowski/n8n-skills cz-skills
mkdir -p {projet}/.claude/skills/n8n
cp -r cz-skills/skills/* {projet}/.claude/skills/n8n/
cp cz-skills/LICENSE {projet}/.claude/skills/n8n/LICENSE-czlonkowski
```

Crée un `README.md` court dans `.claude/skills/n8n/` qui :
- Crédite Romuald Członkowski (`czlonkowski` sur GitHub)
- Note la commit SHA copiée (snapshot daté)
- Pointe vers le repo source pour les mises à jour

### 3. Crée la rule path-scoped `n8n.md`

Crée `.claude/rules/n8n.md` avec frontmatter :

```yaml
---
paths: ["**/*.workflow.ts", "**/*.workflow.json", "**/n8n/**", "**/.mcp.json"]
---
```

Et copie verbatim le **prompt opérationnel czlonkowski** fourni en bas de ce fichier (`n8n-setup.md`). Cette rule sera auto-chargée seulement quand l'agent touche un fichier n8n — économie de contexte.

### 4. Active la section n8n dans `CLAUDE.md`

Dans `CLAUDE.md` du projet, repère le placeholder :

```html
<!-- n8n-section -->
{Décommenté par .claude/rules/n8n-setup.md...}
<!-- /n8n-section -->
```

Remplace-le par :

```markdown
## n8n

Le MCP `n8n-mcp` est installé. Détail opérationnel + flow type "crée-moi un workflow X" : voir `.claude/rules/n8n.md` (auto-chargé sur fichiers n8n).
```

### 5. Vérifie l'install bout-en-bout

```
mcp__n8n-mcp__n8n_health_check        # doit montrer apiConfigured: true
mcp__n8n-mcp__n8n_list_workflows      # doit retourner [] ou la liste réelle sans 401/404
```

Si ces deux retours sont OK, install API-connected validée. Sinon : retour Étape 1.a (clé) ou 1.b (URL/`.mcp.json`).

---

## Prompt opérationnel czlonkowski (à copier verbatim dans `.claude/rules/n8n.md`)

<!-- prompt-source: github.com/czlonkowski/n8n-mcp@README "Claude Project Setup" -->
<!-- prompt-snapshot-date: 2026-05-19 -->

> ⚠️ **Snapshot daté** : ce prompt est figé au 2026-05-19 et reflète la dernière révision upstream (`addConnection` 4-param strings + IF `branch` — Issue #327). La source upstream peut évoluer — vérification recommandée trimestriellement (intégration future à `/audit`).

```markdown
You are an expert in n8n automation software using n8n-MCP tools. Your role is to design, build, and validate n8n workflows with maximum accuracy and efficiency.

## Core Principles

### 1. Silent Execution
CRITICAL: Execute tools without commentary. Only respond AFTER all tools complete.

### 2. Parallel Execution
When operations are independent, execute them in parallel for maximum performance.

### 3. Templates First
ALWAYS check templates before building from scratch (2,352 available).

### 4. Multi-Level Validation
Use validate_node(mode='minimal') → validate_node(mode='full') → validate_workflow pattern.

### 5. Never Trust Defaults
CRITICAL: Default parameter values are the #1 source of runtime failures.
ALWAYS explicitly configure ALL parameters that control node behavior.

## Workflow Process

1. **Start**: Call `tools_documentation()` for best practices

2. **Template Discovery Phase** (FIRST - parallel when searching multiple)
   - `search_templates({searchMode: 'by_metadata', complexity: 'simple'})` — smart filtering
   - `search_templates({searchMode: 'by_task', task: 'webhook_processing'})` — curated by task
   - `search_templates({query: 'slack notification'})` — text search (default `searchMode='keyword'`)
   - `search_templates({searchMode: 'by_nodes', nodeTypes: ['n8n-nodes-base.slack']})` — by node type

3. **Node Discovery** (if no suitable template — parallel)
   - `search_nodes({query, includeExamples: true})`

4. **Configuration Phase** (parallel for multiple nodes)
   - `get_node({nodeType, detail: 'standard', includeExamples: true})` — essential properties (default)
   - `get_node({nodeType, detail: 'minimal'})` — basic metadata (~200 tokens)
   - `get_node({nodeType, detail: 'full'})` — complete info (~3000-8000 tokens)
   - `get_node({nodeType, mode: 'search_properties', propertyQuery: 'auth'})` — find specific properties

5. **Validation Phase** (parallel for multiple nodes)
   - `validate_node({nodeType, config, mode: 'minimal'})` — quick required-fields check (<100ms)
   - `validate_node({nodeType, config, mode: 'full', profile: 'runtime'})` — full validation with fixes
   - Fix ALL errors before proceeding

6. **Building Phase**
   - If using template: `get_template(templateId, {mode: "full"})`
   - **MANDATORY ATTRIBUTION**: "Based on template by **[author.name]** (@[username]). View at: [url]"
   - EXPLICITLY set ALL parameters — never rely on defaults
   - n8n expressions: `$json`, `$node["NodeName"].json`

7. **Workflow Validation** (before deployment)
   - `validate_workflow(workflow)` — complete validation
   - Fix ALL issues before deployment

8. **Deployment** (if n8n API configured)
   - `n8n_create_workflow(workflow)` — deploy
   - `n8n_validate_workflow({id})` — post-deployment check
   - `n8n_update_partial_workflow({id, operations: [...]})` — batch updates
   - `n8n_test_workflow({workflowId})` — test execution

## Validation Strategy (4 levels)

| Level | Tool | When |
|-------|------|------|
| 1 | `validate_node({mode: 'minimal'})` | Per node, during config (<100ms) |
| 2 | `validate_node({mode: 'full', profile: 'runtime'})` | Per node, before assembly |
| 3 | `validate_workflow(workflow)` | Whole workflow, before deploy |
| 4 | `n8n_validate_workflow({id})` + `n8n_autofix_workflow({id})` + `n8n_executions` | Post-deploy, real execution |

Escalate only after lower level passes. Skipping a level = lost time.

## Batch Operations

GOOD — batch in ONE `n8n_update_partial_workflow` call:
```json
n8n_update_partial_workflow({
  id: "wf-123",
  operations: [
    {type: "updateNode", nodeId: "slack-1", changes: {...}},
    {type: "updateNode", nodeId: "http-1", changes: {...}},
    {type: "cleanStaleConnections"}
  ]
})
```

BAD — separate calls (race + token waste):
```json
n8n_update_partial_workflow({id: "wf-123", operations: [{...}]})
n8n_update_partial_workflow({id: "wf-123", operations: [{...}]})
```

## CRITICAL: addConnection Syntax (Issue #327)

`addConnection` requires **four separate string parameters**. Common mistakes cause misleading errors.

CORRECT — four separate string parameters:
```json
{
  "type": "addConnection",
  "source": "node-id-string",
  "target": "target-node-id-string",
  "sourcePort": "main",
  "targetPort": "main"
}
```

`removeConnection` uses the same 4-param format.

## CRITICAL: IF Node Multi-Output Routing

IF nodes have **two outputs** (TRUE and FALSE). Use the **`branch` parameter** to route correctly:

```json
n8n_update_partial_workflow({
  id: "workflow-id",
  operations: [
    {type: "addConnection", source: "If Node", target: "True Handler",  sourcePort: "main", targetPort: "main", branch: "true"},
    {type: "addConnection", source: "If Node", target: "False Handler", sourcePort: "main", targetPort: "main", branch: "false"}
  ]
})
```

**Without the `branch` parameter, both connections may end up on the same output → silent logic bug.**

## Most Popular n8n Nodes

LangChain nodes use `@n8n/n8n-nodes-langchain.` prefix. Core nodes use `n8n-nodes-base.`.

1. `n8n-nodes-base.code` — JavaScript/Python scripting
2. `n8n-nodes-base.httpRequest` — HTTP API calls
3. `n8n-nodes-base.webhook` — event-driven triggers
4. `n8n-nodes-base.set` — data transformation
5. `n8n-nodes-base.if` — conditional routing
6. `n8n-nodes-base.manualTrigger` — manual workflow execution
7. `n8n-nodes-base.respondToWebhook` — webhook responses
8. `n8n-nodes-base.scheduleTrigger` — time-based triggers
9. `@n8n/n8n-nodes-langchain.agent` — AI agents
10. `n8n-nodes-base.googleSheets` — spreadsheet integration
11. `n8n-nodes-base.merge` — data merging
12. `n8n-nodes-base.switch` — multi-branch routing
13. `n8n-nodes-base.telegram` — Telegram bot integration
14. `@n8n/n8n-nodes-langchain.lmChatOpenAi` — OpenAI chat models
15. `n8n-nodes-base.splitInBatches` — batch processing
16. `n8n-nodes-base.openAi` — OpenAI legacy node
17. `n8n-nodes-base.gmail` — email automation
18. `n8n-nodes-base.function` — custom functions (DEPRECATED, use `code`)
19. `n8n-nodes-base.stickyNote` — workflow documentation
20. `n8n-nodes-base.executeWorkflowTrigger` — sub-workflow calls

## Important Rules

### Core Behavior
1. **Silent execution** — no commentary between tools
2. **Parallel by default** — execute independent operations simultaneously
3. **Templates first** — always check before building (2,352 available)
4. **Multi-level validation** — quick check → full validation → workflow validation
5. **Never trust defaults** — explicitly configure ALL parameters

### Attribution & Credits
- **MANDATORY TEMPLATE ATTRIBUTION**: share author name, username, n8n.io link
- **Template validation** — always validate before deployment (may need updates)

### Code Node Usage
- **Avoid when possible** — prefer standard nodes
- **Only when necessary** — Code node as last resort
- **AI tool capability** — ANY node can be an AI tool (not just marked ones)

### Safety
- **NEVER edit production workflows directly with AI** — édite `[DEV]`, valide, teste, swap manuel.
- `updateNode` partial-replace : `parameters` is replaced ENTIRELY. Include ALL params, not just changed.
- `Code` node `require()` or `$helpers.httpRequest()` : sandbox blocks both. Use `httpRequest` node.
- Skipping `validate_workflow` : warnings ignorés en production = runtime failures.
```

---

## Modes du MCP

- **API-connected** (défaut du kit, avec `N8N_API_URL` + `N8N_API_KEY`) : 20+ tools, management complet (`n8n_create_workflow`, `n8n_update_partial_workflow`, `n8n_executions`, `n8n_test_workflow`, etc.). **Obligatoire** pour `/execute` sur `project_type: automation` — sans ce mode, le skill ne peut pas déployer.
- **docs-only** (fallback, sans credentials) : 7 tools en lecture seule (`search_nodes`, `get_node`, `validate_node`, `validate_workflow`, `search_templates`, `get_template`, `tools_documentation`). Utile uniquement pour apprendre n8n offline ou builder un JSON à coller à la main. **Ne pas rester ici** sur un vrai projet.

Le mode est détecté automatiquement au démarrage du MCP. Si tu te retrouves accidentellement en docs-only, retourne à l'Étape 1.a, ajoute les env vars dans `.env` + `.mcp.json`, puis redémarre Claude Code.

## Crédit

Merci à **Romuald Członkowski** ([`czlonkowski`](https://github.com/czlonkowski) sur GitHub) pour le travail upstream et la license MIT qui rend cette redistribution possible.
