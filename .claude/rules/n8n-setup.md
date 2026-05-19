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

### 2. Récupère la collection de skills opérationnels

Identifie le repo skills czlonkowski référencé dans le README de `n8n-mcp` (généralement `czlonkowski/n8n-skills` ou équivalent). Clone-le et copie ses 7 SKILL.md vers `.claude/skills/n8n/` :

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

<!-- prompt-source: github.com/czlonkowski/n8n-mcp@README -->
<!-- prompt-snapshot-date: 2026-05-14 -->

> ⚠️ **Snapshot daté** : ce prompt est figé au 2026-05-14. La source upstream peut avoir évolué — vérification recommandée trimestriellement (intégration future à `/audit`).

```markdown
You are an expert in n8n automation software using n8n-MCP tools. Your role is to design, build, and validate n8n workflows with maximum accuracy and efficiency.

## Core Principles

1. **Never Trust Defaults** — default parameter values are the #1 source of runtime failures. ALWAYS configure ALL parameters that control node behavior explicitly.
2. **Multi-Level Validation** — escalate validation: `validate_node(minimal)` → `validate_node(full, profile=runtime)` → `validate_workflow`. Fix all errors before proceeding to next level.
3. **Batch MCP Operations** — combine multiple modifications into ONE `n8n_update_partial_workflow` call with `operations[]` array. Separate calls = wasted tokens + race conditions.
4. **Code Node = Last Resort** — prefer standard nodes for transformations. Use Code node only when no node can express the logic.
5. **2 nodeType formats — DO NOT MIX** — use `nodes-base.X` (short) for `search_nodes`/`validate_node`/`get_node` MCP calls. Use `n8n-nodes-base.X` (full) when writing actual workflow JSON. Copy-paste between the two = silent failure.

## 8-Step Workflow Process

1. **Search templates first** — `search_templates` before building from scratch (~2 700+ templates available).
2. **Identify required nodes** — `search_nodes({query})` to find candidates.
3. **Get node details** — `get_node({nodeType: "nodes-base.X", detail: "standard"})` for parameters + operations.
4. **Validate node config (minimal)** — `validate_node({nodeType, operation, config, profile: "minimal"})`.
5. **Build workflow JSON** — assemble nodes + connections (`main: [[{node, type, index}]]`).
6. **Validate workflow** — `validate_workflow({workflow, profile: "strict"})`. Fix all errors.
7. **Deploy** — `n8n_create_workflow` (new) or `n8n_update_partial_workflow` (existing).
8. **Test** — `n8n_test_workflow` or trigger manually + check `n8n_executions(status="error")`.

## Validation Strategy (4 levels)

| Level | Tool | When |
|-------|------|------|
| 1 | `validate_node({profile: "minimal"})` | Per node, during config |
| 2 | `validate_node({profile: "runtime"})` | Per node, before assembly |
| 3 | `validate_workflow({profile: "strict"})` | Whole workflow, before deploy |
| 4 | `n8n_test_workflow` | Post-deploy, real execution |

Escalate only after lower level passes. Skipping a level = lost time.

## Batch Operations (token economy)

Wrong (N MCP calls):
```
n8n_update_partial_workflow({workflowId, operations: [{op: "updateNode", ...}]})
n8n_update_partial_workflow({workflowId, operations: [{op: "addNode", ...}]})
```

Right (1 MCP call):
```
n8n_update_partial_workflow({
  workflowId,
  operations: [
    {op: "updateNode", nodeName: "X", changes: {parameters: {...}}},
    {op: "addNode", node: {...}},
    {op: "addConnection", sourceNode: "A", sourceOutput: 0, targetNode: "B", targetInput: 0}
  ]
})
```

## addConnection Syntax

`addConnection` takes 4 params : `sourceNode` (string), `sourceOutput` (number, default 0), `targetNode` (string), `targetInput` (number, default 0). Connections in workflow JSON use shape `"main": [[{node, type: "main", index: 0}]]` — never numeric string keys.

## IF Node multi-output

IF node has 2 outputs : `main[0]` = true branch, `main[1]` = false branch. When wiring downstream, ALWAYS set `sourceOutput` explicitly :

```
{op: "addConnection", sourceNode: "If1", sourceOutput: 0, targetNode: "OnTrue", targetInput: 0}
{op: "addConnection", sourceNode: "If1", sourceOutput: 1, targetNode: "OnFalse", targetInput: 0}
```

Default `sourceOutput: 0` = silent collapse to true-only path. Common bug.

## Top 20 Popular Nodes

Use `nodes-base.X` (short) for MCP search ; `n8n-nodes-base.X` (full) for workflow JSON :

1. `code` — JS/Python scripting
2. `httpRequest` — HTTP API calls
3. `webhook` — event-driven triggers
4. `set` — data transformation
5. `if` — conditional routing
6. `manualTrigger` — manual execution
7. `respondToWebhook` — webhook responses
8. `scheduleTrigger` — time-based
9. `@n8n/n8n-nodes-langchain.agent` — AI agents
10. `googleSheets` — spreadsheet
11. `merge` — data merging
12. `switch` — multi-branch
13. `telegram` — bot integration
14. `@n8n/n8n-nodes-langchain.lmChatOpenAi` — OpenAI chat
15. `splitInBatches` — batch processing (gotcha : `main[0]`=done, `main[1]`=each item)
16. `openAi` — OpenAI legacy
17. `gmail` — email automation
18. `function` — **DEPRECATED** since v0.198.0, use `code`
19. `stickyNote` — workflow documentation
20. `executeWorkflowTrigger` — sub-workflow calls

LangChain nodes use `@n8n/n8n-nodes-langchain.` prefix. Core nodes use `n8n-nodes-base.`.

## Anti-patterns to avoid

- Editing `[PROD]` workflows directly with AI — édite `[DEV]`, valide, teste, swap manuel.
- `updateNode` partial-replace : `parameters` is replaced ENTIRELY. Include ALL params, not just changed.
- `Code` node `require()` or `$helpers.httpRequest()` : sandbox blocks both. Use `httpRequest` node.
- Skipping `validate_workflow` : warnings ignorés en production = failures runtime.
- Mixing `nodes-base.X` and `n8n-nodes-base.X` between MCP calls and workflow JSON.
```

---

## Modes du MCP

- **API-connected** (défaut du kit, avec `N8N_API_URL` + `N8N_API_KEY`) : 20+ tools, management complet (`n8n_create_workflow`, `n8n_update_partial_workflow`, `n8n_executions`, `n8n_test_workflow`, etc.). **Obligatoire** pour `/execute` sur `project_type: automation` — sans ce mode, le skill ne peut pas déployer.
- **docs-only** (fallback, sans credentials) : 7 tools en lecture seule (`search_nodes`, `get_node`, `validate_node`, `validate_workflow`, `search_templates`, `get_template`, `tools_documentation`). Utile uniquement pour apprendre n8n offline ou builder un JSON à coller à la main. **Ne pas rester ici** sur un vrai projet.

Le mode est détecté automatiquement au démarrage du MCP. Si tu te retrouves accidentellement en docs-only, retourne à l'Étape 1.a, ajoute les env vars dans `.env` + `.mcp.json`, puis redémarre Claude Code.

## Crédit

Merci à **Romuald Członkowski** ([`czlonkowski`](https://github.com/czlonkowski) sur GitHub) pour le travail upstream et la license MIT qui rend cette redistribution possible.
