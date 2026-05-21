# n8n MCP — install + sécurisation credentials (Étape 5b)

> **Lis ce fichier uniquement si** `/start` Étape 5b doit installer le MCP n8n (`project_uses_n8n: true`).
>
> **Mode API-connected par défaut, non-négociable** (cf. `.claude/rules/n8n-setup.md`) : sans ce mode, `/execute` ne peut PAS déployer un workflow n8n, ce qui casse le cas d'usage `project_type: automation`.
>
> **Pattern credentials canonique du kit** : **valeurs en clair dans `.mcp.json` gitignored** (cf. `.claude/rules/n8n-setup.md` Étape 1.b). On évite délibérément le pattern `${VAR}` + `.env` qui est piégeux côté Claude Code (le shell parent ne source pas `.env` automatiquement → résolution `${VAR}` à vide → erreur silencieuse).

## Vue d'ensemble

Cette procédure couvre 5 étapes :
- 5b.1 — Vérifier `.gitignore` (inclut `.mcp.json` ET `.env*` pour défense en profondeur)
- 5b.2 — Préparer `.env.example` (doc pour les futurs forkers, pas de creds)
- 5b.3 — Recommander le mode API-connected (1 question)
- 5b.4 — Éditer `.mcp.json` (valeurs en clair + gitignored)
- 5b.5 — Lancer la procédure complète `.claude/rules/n8n-setup.md` (skills czlonkowski + rule path-scoped + activation section CLAUDE.md + sanity check)

## Étape 5b.1 — Vérifier `.gitignore`

Lis `.gitignore` à la racine. Vérifie qu'il contient (ajoute si manquants) :
```
.env
.env.local
.env.*.local
.mcp.json
```

Le `.mcp.json` est ajouté pour la défense en profondeur (le pattern canonique met les valeurs en clair dedans). Les lignes `.env*` restent pour le cas où l'utilisateur stockerait quand même des secrets dans un `.env` pour un usage applicatif (Stripe, OpenAI, etc.).

Si pas de `.gitignore` du tout → crée-le avec ces lignes + une ligne de courtoisie pour les artefacts courants :
```
# Secrets
.env
.env.local
.env.*.local
.mcp.json

# Node
node_modules/
.next/
dist/
build/

# OS
.DS_Store
Thumbs.db
```

## Étape 5b.2 — Préparer `.env.example`

Lis `.env.example`. Si absent ou vide → crée-le avec les placeholders pour les services applicatifs que l'utilisateur va utiliser (PAS les credentials n8n MCP — ceux-là vont dans `.mcp.json` directement) :

```
# Anthropic SDK (si tu construis une app qui appelle Claude)
ANTHROPIC_API_KEY=sk-ant-...

# Autres services applicatifs au fur et à mesure (Stripe, Resend, OpenAI, ...)
```

`.env.example` est **committé** (sert de doc pour les futurs forkers/collègues). `.env` ne l'est jamais. Les credentials n8n MCP ne passent PAS par `.env` dans le pattern canonique du kit — ils vont en clair dans `.mcp.json` (gitignored).

## Étape 5b.3 — Recommandation mode API-connected

Le MCP n8n (czlonkowski) a 2 modes. **La recommandation par défaut est Mode B (API-connected)** — il débloque 13 tools de management en plus des 7 docs (création/update workflows, exécutions, audit instance) et c'est ce dont tu auras besoin dès que tu construis un vrai workflow. Mode A (docs-only) n'est un bon choix QUE si tu n'as pas encore d'instance n8n.

Pose UNE seule question pour trancher :

> *"Tu as une instance n8n avec accès API (n8n Cloud, self-hosted, ou autre) ? (oui / pas encore)"*

**Si "oui"** → bascule en **Mode B** sans repasser par un menu A/B. Annonce : *"Parfait, on configure le MCP en API-connected (20 tools dispo)."*

**Si "pas encore"** → fallback **Mode A** (docs-only). Annonce : *"OK, on configure en docs-only — tu auras les 7 tools de recherche + validation locale, suffisant pour apprendre n8n. Dès que tu auras une instance, ajoute `N8N_API_URL` + `N8N_API_KEY` dans `.mcp.json` et tu passes en mode B sans rien d'autre à toucher."*

**Anti-pattern à éviter** : si l'utilisateur t'a déjà dit qu'il a une instance n8n (par exemple en Étape 3 Q1/Q2 ou plus tôt dans la session), **ne lui repose pas la question** — vas directement Mode B. Et si tu vois un `.mcp.json` à la racine au démarrage avec un bloc `n8n-mcp` rempli, **mentionne-le** : *"Je vois un MCP n8n déjà configuré — je vérifie le mode avec un health check."*

## Étape 5b.4 — Éditer `.mcp.json` (valeurs en clair, gitignored)

Lis `.mcp.json`. Édite-le pour ajouter l'entrée `n8n-mcp` avec les 3 env vars OBLIGATOIRES (`MCP_MODE`, `LOG_LEVEL`, `DISABLE_CONSOLE_OUTPUT` — sans elles, le canal stdio se pollue et Claude voit des JSON parse errors).

### Si Mode A (docs-only)

```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["-y", "n8n-mcp@latest"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true"
      }
    }
  }
}
```

### Si Mode B (API-connected)

Demande à l'utilisateur les 2 valeurs (l'utilisateur les récupère dans Settings → API de son instance n8n). **N'echo / log / répète JAMAIS la valeur de `N8N_API_KEY` dans la conversation.** Tu confirmes juste *"Clé écrite dans `.mcp.json`."*

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
        "N8N_API_URL": "<URL réelle, ex: https://n8n.tondomaine.com/api/v1>",
        "N8N_API_KEY": "<JWT réel>"
      }
    }
  }
}
```

⚠️ **N'inclus jamais `/api` sans le `/v1`** : sans `/api/v1`, tous les appels MCP renvoient 404. Format correct : `https://n8n.exemple.com/api/v1` ou `https://{workspace}.app.n8n.cloud/api/v1`.

**Préserve les autres entrées MCP éventuellement déjà présentes** — fusion, pas remplacement.

Puis sécurise et publie un exemple propre :

```bash
# Vérifie que .mcp.json est gitignored (déjà ajouté en 5b.1)
git check-ignore .mcp.json && echo "OK gitignored"

# Commit un exemple sans creds pour tes coéquipiers
cp .mcp.json .mcp.json.example
# Édite .mcp.json.example pour remplacer la clé par "REPLACE_ME"
# Puis git add .mcp.json.example .gitignore
```

**Pin de version** : `n8n-mcp@latest` te donne le dernier release. Pour la reproductibilité, l'utilisateur peut remplacer par `n8n-mcp@2.51.3` (ou la version observée via `npm view n8n-mcp version`). Mentionne-le mais ne le force pas.

## Étape 5b.5 — Déclencher la procédure complète n8n-setup.md

Aucune commande de shell magique n'est nécessaire — **redémarre simplement Claude Code** (sortir avec `Ctrl+C` ou `exit`, puis relancer `claude`) pour qu'il relise `.mcp.json`. Le `${VAR}` n'est PAS utilisé dans le pattern canonique, donc pas de `set -a && source .env` à faire.

Annonce : *"Je lance maintenant l'install n8n complète selon `.claude/rules/n8n-setup.md` — collection skills czlonkowski + rule path-scoped + activation section CLAUDE.md + sanity check du mode API-connected."* Puis suis les 5 étapes de `.claude/rules/n8n-setup.md` (Étape 1.c verification → 2 skills czlonkowski → 3 rule path-scoped → 4 activation CLAUDE.md → 5 verify bout-en-bout).

## Retour au SKILL.md

Une fois `.claude/rules/n8n-setup.md` complété (5 étapes), retourne à l'Étape 5c du SKILL.md (plugin frontend-design).
