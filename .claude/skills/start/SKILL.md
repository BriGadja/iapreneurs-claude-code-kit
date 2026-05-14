---
name: start
description: Utiliser à l'ouverture d'une nouvelle session sur un projet basé sur ce kit. Bootstrap automatique si clone direct du kit détecté (reinit git + remote upstream + commit initial), configuration de l'identité git locale du projet (sans toucher au global), visite guidée du kit (skippable), 3 questions de cadrage qui remplissent la section Identité du CLAUDE.md, vérification de l'outillage (Playwright + n8n MCP + plugin frontend-design), puis routage vers /brainstorm (idée floue) ou /architect (idée claire). Ne PAS utiliser au milieu d'une session de travail — c'est un skill d'onboarding.
---

# Skill /start — démarrage piloté

## Pour quoi faire

Premier skill à invoquer après avoir forké/cloné le kit. Trois objectifs :
1. **Cadrer le projet** : 3 questions ciblées qui écrivent la section `## Identité` du `CLAUDE.md`.
2. **Vérifier l'outillage** : Playwright, n8n MCP, plugin `frontend-design` installés et testés.
3. **Router** : vers `/brainstorm` (idée floue) ou `/architect` (idée claire).

Sortie : un `CLAUDE.md` avec l'Identité remplie + un MCP/plugin stack fonctionnel + le bon prochain skill suggéré.

## Règle d'or

**Tu ne modifies que les zones marquées par des ancres HTML** dans le `CLAUDE.md` (`<!-- start:identité -->` ... `<!-- /start:identité -->`). Tout le reste du fichier reste intact, même s'il est encore en mode template — ce sont les autres skills (`/architect`, etc.) ou l'utilisateur qui rempliront le reste plus tard.

## Comment procéder

### Étape 0 — Détecter un clone direct du kit (5s)

Avant toute autre chose, vérifie si l'utilisateur a cloné directement le repo du kit (au lieu d'utiliser "Use this template" sur GitHub). Dans ce cas, le remote `origin` pointe encore vers le kit lui-même et tout l'historique git du kit est présent — pas adapté pour démarrer un projet personnel.

**Détection** : lance `git remote get-url origin 2>/dev/null` et grep `iapreneurs-claude-code-kit`. Si match ET que `<!-- start:identité -->` contient encore le placeholder par défaut (= projet jamais cadré), tu es dans le cas "fresh clone du kit".

**Si détecté** → propose le bootstrap automatique en UNE seule question :

> *"Je vois que tu as cloné directement le repo du kit (origin = `iapreneurs-claude-code-kit`). Pour que ton projet parte sur un historique git propre, je peux :*
> *1. Supprimer l'historique du kit (`rm -rf .git && git init`)*
> *2. Garder le kit comme remote `upstream` (pour tirer les updates futures via `git pull upstream main`)*
> *3. Faire un premier commit `chore: init from iapreneurs-claude-code-kit v{version}`*
>
> *Tu veux que je fasse ça maintenant ? (oui / non)*
>
> *💡 Alternative : utiliser le bouton "Use this template" sur GitHub la prochaine fois → tu skipperas cette étape automatiquement."*

**Si l'utilisateur dit oui** :
```bash
# Capturer l'URL et la version AVANT de supprimer .git
KIT_URL=$(git remote get-url origin)
KIT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v2.1.0")

# Reinit
rm -rf .git
git init -b main

# Ajouter le kit comme upstream (pour les updates futures)
git remote add upstream "$KIT_URL"

# Premier commit propre
git add -A
git commit -m "chore: init from iapreneurs-claude-code-kit $KIT_VERSION"
```

Annonce ensuite : *"✅ Historique git réinitialisé. Le kit est gardé comme `upstream` — `git pull upstream main` pour récupérer les futures versions. Premier commit fait. On continue le cadrage."*

**Si l'utilisateur dit non** → respecte le choix, continue sans toucher au git. Note dans ta tête que ce projet partagera l'historique du kit — ce n'est pas grave, juste un choix.

**Si pas détecté** (utilisateur a "Use this template", ou a déjà fait le bootstrap) → ne dis rien et passe à l'Étape 0.5.

### Étape 0.5 — Identité git locale (15s)

Avant d'aller plus loin, on s'assure que les commits de ce projet auront **ton** nom dessus — pas ceux de la dernière personne qui a touché au repo. Sans ça, soit les commits sont attribués au mauvais auteur, soit Claude est obligé de balancer `git -c user.name=... user.email=...` à chaque commit (lourd, pas pro).

**Détection** : lance en parallèle
- `git rev-parse --git-dir 2>/dev/null && echo HAS_REPO || echo NO_REPO`
- `git config --get user.name && git config --get user.email` (config effective = local fusionné avec global)

**Cas A — pas de repo git** (`NO_REPO`) : annonce *"Pas de repo git ici. Tu veux que j'en initialise un ? (oui / non)"*
- **Oui** → `git init -b main`, puis bascule sur Cas C (identité à régler).
- **Non** → note "mode sans-git" pour cette session. **Avertis** : *"OK, on travaille sans git. ⚠️ `/close` et `/livrer` partent du principe que git est dispo — quand ils arriveront, dis-leur de skipper les commits, sinon ils échoueront. La plupart des hostings (Vercel/Netlify) exigent git pour déployer."* Skip le reste de 0.5, passe à Étape 1.

**Cas B — repo existant, identité effective présente** (les 2 `git config --get` retournent une valeur) : annonce *"Identité git effective : `{name} <{email}>`. On l'utilise pour ce projet ? (oui / autre)"*
- **Oui** → continue Étape 1 sans rien toucher.
- **Autre** → bascule sur Cas C pour collecter de nouvelles valeurs et les écrire en **local** (override le global pour ce projet uniquement).

**Cas C — repo existant, identité absente ou à override** : annonce *"Je vais écrire une identité git **locale** pour ce projet (commande `git config --local` — ta config globale `~/.gitconfig` n'est pas touchée)."*

Demande 2 valeurs, une à la fois :
1. *"Ton nom (apparaîtra dans `git log` et sur GitHub) ?"*
2. *"Ton email (idéalement celui de ton compte GitHub pour que les commits soient liés à ton profil) ?"*

Puis lance :
```bash
git config --local user.name "{nom fourni}"
git config --local user.email "{email fourni}"
```

Vérifie : `git config --local --get user.name && git config --local --get user.email` — les 2 valeurs doivent ressortir. Confirme : *"✅ Identité locale écrite. Tes prochains commits seront signés correctement, sans override par commande."*

> **Pour la suite** : `/close` et `/livrer` commiteront avec cette identité automatiquement. Plus besoin de `git -c user.name=...` à chaque commit.

### Étape 1 — Détecter l'état du projet (10s)

**1.0 — Lire MEMORY.md** : si `MEMORY.md` existe à la racine et n'est pas vide (au-delà du template), lis-le rapidement (50 premières lignes max). Tu en extrais :
- Nombre d'entrées dans `<!-- close:topics-index -->` (compter les liens markdown)
- Date de la dernière entrée dans `<!-- close:learnings-index -->`
- Domaines présents (auth, n8n, deploy, etc.)

Si non-vide, **affiche un résumé une fois** au tout début de la session (avant les autres étapes) :
> *"📚 Mémoire projet détectée : {N} topics ({liste}), dernière session enregistrée le {date}. Tape `cat MEMORY.md` pour le détail, ou continue — je sais que ça existe."*

Si vide ou inexistant → ne dis rien (pas de bruit).

**1.1 — Lire CLAUDE.md** + vérifie 4 signaux :
1. La section `<!-- start:identité -->` contient encore le placeholder par défaut ?
2. Y a-t-il un `PRD.md` à la racine ?
3. Y a-t-il des fichiers de plan ? Cherche dans cet ordre : `docs/plans/phase-*-plan.md` (priorité, convention v2.1.0+), puis `plans/phase-*.md`, puis `phase-*-plan.md` à la racine (fallback projets pré-v2.1.0).
4. La variable `project_type:` est-elle présente dans `<!-- start:identité -->` ?

Branche selon le diagnostic :

**Cas A — Projet neuf** (placeholder identité présent, pas de PRD, pas de plans, pas de `project_type`) → tu déroules les phases 2 à 6 normalement (visite + 3 questions + écriture identité + outillage + routage).

**Cas B — Projet existant en cours** (identité remplie + PRD ou plans présents) → bifurque vers `/prime` :
> *"Projet déjà cadré et en cours ({Nom détecté de l'identité}). Trois options :*
> *(1) **Recharger le contexte de session** (continuer ce projet) — je délègue à `/prime` qui lit l'état (PRD + STRUCTURE.md + plans + git log + MEMORY.md) et te propose la suite [recommandé]*
> *(2) **Cadrer une nouvelle tâche/feature** sur ce projet — on continue en mode visite + routage*
> *(3) **Ré-onboarder complet** (efface l'identité actuelle et re-fais le cadrage) — confirmation à 3 reprises avant écrasement"*
> *Tu choisis ?"*
- Si (1) → annonce *"OK, je passe la main à `/prime`"* et stoppe (l'utilisateur lance `/prime` ou tu peux suggérer en handoff).
- Si (2) → saute à l'Étape 5 (outillage) puis 6 (routage), skip phases 2-4.
- Si (3) → demande **3 confirmations explicites** avant d'écrire (*"sûr ?" "vraiment sûr ?" "dernière chance, on écrase l'identité actuelle ?"*). Puis dérouler phases 2-6.

**Cas C — Migration v1.x → v2.0** (identité remplie MAIS pas de `project_type` dans `<!-- start:identité -->`) → ne stoppe PAS, juste un mini-patch :
> *"Ton projet utilise une version antérieure du kit (pas de variable `project_type` dans CLAUDE.md). C'est une variable que les nouveaux skills (`/architect Étape 6`, `/livrer`, `/plan` adaptatif) attendent. Je te pose une question pour la définir :*
> *Quel type de projet ?*
> *- **(a) Web app SaaS** (auth + BDD, utilisateurs, plusieurs pages) → `project_type: webapp`*
> *- **(b) Site vitrine** (1-5 pages, peu/pas de BDD) → `project_type: site`*
> *- **(c) Automatisation n8n** (workflow déclenché, pas d'UI utilisateur) → `project_type: automation`"*
- Écris la réponse dans `<!-- start:identité -->` au format `project_type: {valeur}` (sur sa propre ligne, après le paragraphe identité).
- Continue ensuite vers Étape 5 (outillage) puis 6 (routage) — pas de re-cadrage complet, le projet est déjà défini.

### Étape 2 — Visite guidée (30s, skippable)

Annonce :

> "Bienvenue. Je vais te guider en 4 phases : visite courte (skippable), 3 questions sur ton projet, vérif de ton outillage, puis routage. **Tu veux skipper la visite ?** (oui / non)"

Si **non** (visite demandée), résume en 3 lignes :

> "Le kit a **10 skills cycle de vie** (`/start`, `/brainstorm`, `/architect`, `/design`, `/plan`, `/execute`, `/validate`, `/close`, `/livrer`, `/evoluer`) + `/challenge` optionnel + 7 skills n8n tiers + 1 sous-agent `research-delegate`. Tout est coordonné pour t'amener du démarrage à un projet livré en prod, en t'adaptant au niveau (LITE / STANDARD / FULL) et au `project_type` (site / webapp / automation).
>
> Pour le détail complet (parcours, table skills, conditionnels, MCP install) → `cat docs/KIT.md` quand tu veux. Pour debugger un bug → built-in `/debug` + test de régression avant fix.
>
> On continue le cadrage ?"

Si **oui** (skip), passe direct à l'étape 3.

### Étape 3 — 3 questions de cadrage

Pose **exactement 3 questions**, une par une (pas en bloc — attendre la réponse) :

1. **Nom + une phrase** : "Ton projet s'appelle comment, et en une phrase, ça fait quoi ?"
2. **Pour qui** : "Qui va l'utiliser ? Toi tout seul, ton équipe, des clients pros, le grand public ?"
3. **Type de projet** : "Quel type de projet ?
   - **A** : web app SaaS (auth + BDD, plusieurs pages, utilisateurs connectés) → `project_type: webapp`
   - **B** : site vitrine 1-5 pages (présence en ligne, peu/pas de BDD) → `project_type: site`
   - **C** : automatisation n8n (workflow déclenché, pas d'UI utilisateur) → `project_type: automation`
   - **D** : autre / je ne sais pas → fallback `project_type: webapp` (le plus polyvalent), tu pourras changer plus tard"

Stocke les 3 réponses **et la valeur de `project_type`** correspondante (A→webapp, B→site, C→automation, D→webapp). **Ne propose pas la stack technique maintenant** — c'est `/architect` qui le fera.

#### Q4 — Usage de n8n sur ce projet (booléenne)

Pose une 4e question (sauf si `project_type == automation` → auto-set `true` sans demander) :

> *"Tu vas utiliser n8n sur ce projet ? (oui/non)"*

- Si **oui** ou si `project_type == automation` → `project_uses_n8n: true`. Tu vas devoir installer le MCP n8n + la collection skills czlonkowski via la procédure `.claude/rules/n8n-setup.md` (Étape 5b nouvelle ci-dessous).
- Si **non** → `project_uses_n8n: false`. Skip toute la section 5b (n8n MCP). Le kit reste slim.

Stocke `project_uses_n8n` (`true` ou `false`) pour les étapes 4 et 5.

### Étape 4 — Écrire la section Identité du CLAUDE.md

Compose 2-3 phrases à partir des réponses :

> "**{Nom}** est {phrase Q1}, destiné à {Q2}. {1 phrase qui décrit le résultat livré selon project_type : 'Application web avec authentification et base de données' / 'Site vitrine avec page d'accueil et formulaire de contact' / 'Workflow n8n déclenché par webhook'}."

Lis le `CLAUDE.md`, trouve le bloc :

```
<!-- start:identité -->
{...placeholder...}
<!-- /start:identité -->
```

Remplace le contenu entre les deux ancres par **ton paragraphe sur 1 ou plusieurs lignes**, suivi (ligne suivante après une ligne vide) de :

```
project_type: {webapp | site | automation}
project_uses_n8n: {true | false}
```

(valeurs exactes des Q3 et Q4 stockées en Étape 3). **Garde les ancres**. **Ne touche à aucune autre partie du fichier.**

> **Note** : le placeholder `<!-- n8n-section -->` dans `CLAUDE.md` reste intact à ce stade. Il sera décommenté par `.claude/rules/n8n-setup.md` à l'install (Étape 5b nouvelle), seulement si `project_uses_n8n: true`.

Affiche la diff à l'utilisateur : *"Voici ce que je vais écrire dans `## Identité` (paragraphe + variable `project_type`). OK ou tu veux ajuster ?"* — sauvegarde après validation.

#### 4b — Initialiser STATUS.md depuis le template

Le fichier `STATUS.md` à la racine est créé par le kit (template avec ancres `<!-- close:active -->`). À l'onboarding, fais une **substitution / search-and-replace** :

- Remplace `{Nom du projet}` (en titre `# STATUS — {Nom du projet}`) par le nom du projet validé en Étape 3 Q1.
- Si `STATUS.md` est **absent** (projet migré manuellement depuis pré-v2.2) → **crée le fichier** en repartant du contenu canonique :
  ```markdown
  # STATUS — {Nom du projet}

  > Fichier maintenu UNIQUEMENT par `/close`. Ne pas éditer à la main.

  <!-- close:active -->
  **Dernière étape** : (aucune — projet neuf, lance `/start`)
  **Prochaine étape recommandée** : `/start`
  **Dernier commit reflété** : (aucun — projet neuf)

  ## Historique récent
  (vide)
  <!-- /close:active -->
  ```
  puis applique la même substitution `{Nom du projet}`.

Tu **n'écris pas** dans la zone `<!-- close:active -->` — c'est `/close` qui la maintient. Substitution titre uniquement.

### Étape 5 — Vérifier l'outillage (et sécuriser les credentials avant n8n)

Annonce : *"Maintenant l'outillage. Je vérifie 3 trucs : Playwright, n8n MCP, plugin frontend-design. Avant n8n, on sécurise tes credentials proprement."*

#### 5a — Playwright (MCP, pas de credentials)

Lance : `claude mcp list`

- Si `playwright` est listé → ✅ "Playwright OK." Test rapide : *"Tu veux que je vérifie qu'il marche ? (snapshot rapide de google.com)"* — si oui, invoque le MCP pour naviguer + snapshot, rapporte succès/échec.
- Si absent → propose :
  ```
  claude mcp add playwright -- npx -y @playwright/mcp@latest
  ```
  *"Copie-colle dans un autre terminal, dis-moi quand c'est fait."* Attends confirmation. Puis re-`claude mcp list` pour valider.

#### 5b — n8n MCP (UNIQUEMENT si `project_uses_n8n: true`)

> **Gate conditionnel** : si `project_uses_n8n: false` (Q4), **skip entièrement** cette sous-section 5b. Le kit reste slim — pas de MCP n8n installé, pas de collection skills czlonkowski. Tu pourras toujours basculer plus tard en relançant la procédure `.claude/rules/n8n-setup.md` à la main.
>
> Si `project_uses_n8n: true`, suis les étapes 5b.1 à 5b.5 ci-dessous **PUIS** déclenche la procédure complète d'installation de la collection en exécutant `.claude/rules/n8n-setup.md` (annonce : *"Je lance maintenant l'install n8n complète selon `.claude/rules/n8n-setup.md` — collection skills czlonkowski + rule path-scoped + activation section CLAUDE.md."* puis suis ses 5 étapes).

Le MCP n8n demande une `N8N_API_URL` et une `N8N_API_KEY`. **Règle Anthropic** : ces clés ne doivent JAMAIS finir en clair dans un fichier committé. Pattern recommandé : `${VAR}` dans `.mcp.json` (committé), valeurs réelles dans `.env` (gitignored).

**Étape 5b.1 — Vérifier `.gitignore`**

Lis `.gitignore` à la racine. Vérifie qu'il contient (ajoute si manquants) :
```
.env
.env.local
.env.*.local
```

Si pas de `.gitignore` du tout → crée-le avec ces lignes + une ligne de courtoisie pour les artefacts courants :
```
# Secrets
.env
.env.local
.env.*.local

# Node
node_modules/
.next/
dist/
build/

# OS
.DS_Store
Thumbs.db
```

**Étape 5b.2 — Vérifier `.env.example`**

Lis `.env.example`. Si absent ou vide → crée-le avec les placeholders pour les services que l'utilisateur va utiliser. Par défaut :
```
# n8n MCP credentials (récupérables dans Settings → API de ton instance n8n)
N8N_API_URL=https://ton-instance.n8n.cloud
N8N_API_KEY=ta_clé_api_ici

# Anthropic SDK (si tu construis une app qui appelle Claude)
ANTHROPIC_API_KEY=sk-ant-...
```

`.env.example` est **committé** (sert de doc pour les futurs forkers/collègues). `.env` ne l'est jamais.

**Étape 5b.3 — Mode n8n MCP (recommandation : API-connected)**

Le MCP n8n (czlonkowski) a 2 modes. **La recommandation par défaut est Mode B (API-connected)** — il débloque 13 tools de management en plus des 7 docs (création/update workflows, exécutions, audit instance) et c'est ce dont tu auras besoin dès que tu construis un vrai workflow. Mode A (docs-only) n'est un bon choix QUE si tu n'as pas encore d'instance n8n.

Pose UNE seule question pour trancher :

> *"Tu as une instance n8n avec accès API (n8n Cloud, self-hosted, ou autre) ? (oui / pas encore)"*

**Si "oui"** → bascule en **Mode B** sans repasser par un menu A/B. Annonce : *"Parfait, on configure le MCP en API-connected (20 tools dispo). Je vais te demander 2 valeurs — elles vont dans `.env` (gitignored, donc privé)."*

Demande `N8N_API_URL` puis `N8N_API_KEY` (l'utilisateur les récupère dans Settings → API de son instance n8n).

Crée/édite `.env` à la racine avec :
```
N8N_API_URL=<valeur fournie>
N8N_API_KEY=<valeur fournie>
```

**JAMAIS** echo, log, ou répète la valeur de `N8N_API_KEY` dans la conversation. Tu confirmes juste *"Clé écrite dans `.env`."* Passe à 5b.4 en mode B.

**Si "pas encore"** → fallback **Mode A** (docs-only). Annonce : *"OK, on configure en docs-only — tu auras les 7 tools de recherche + validation locale, suffisant pour apprendre n8n. Dès que tu auras une instance, ajoute `N8N_API_URL` + `N8N_API_KEY` dans `.env` et tu passes en mode B sans rien d'autre à toucher."* Passe à 5b.4 en mode A.

**Anti-pattern à éviter** : si l'utilisateur t'a déjà dit qu'il a une instance n8n (par exemple en Étape 3 Q1/Q2 ou plus tôt dans la session), **ne lui repose pas la question** — vas directement Mode B. Et si tu vois des `N8N_API_*` déjà présents dans `.env` ou un `.env` à la racine au démarrage, **mentionne-le** : *"Je vois des credentials n8n dans `.env` — on part en Mode B directement."*

**Étape 5b.4 — Ajouter n8n à `.mcp.json` avec les 3 env vars OBLIGATOIRES**

Lis `.mcp.json`. Édite-le pour ajouter l'entrée `n8n-mcp` avec les 3 env vars OBLIGATOIRES (`MCP_MODE`, `LOG_LEVEL`, `DISABLE_CONSOLE_OUTPUT` — sans elles, le canal stdio se pollue et Claude voit des JSON parse errors).

**Si Mode A (docs-only)** :
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

**Si Mode B (API-connected)** :
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

(Préserve les autres entrées MCP éventuellement déjà présentes — fusion, pas remplacement.)

**Pin de version** : `n8n-mcp@latest` te donne le dernier release. Pour la reproductibilité, l'utilisateur peut remplacer par `n8n-mcp@2.51.3` (ou la version observée via `npm view n8n-mcp version`). Mentionne-le mais ne le force pas.

**Étape 5b.5 — Indiquer comment charger `.env` pour la session**

Le `${VAR}` est lu dans l'environnement shell au lancement de `claude`. Donne 2 options à l'utilisateur :

> "Pour que `${N8N_API_KEY}` soit résolu, ton shell doit avoir la variable au moment où tu lances `claude`. Deux options :
>
> **Option A — Manuel pour cette session** :
> ```bash
> set -a && source .env && set +a
> # Puis relance claude
> ```
>
> **Option B — Automatique avec direnv** (recommandé si tu repasses souvent sur ce projet) :
> ```bash
> # Installer une fois : brew install direnv (ou apt install direnv)
> # Puis dans le projet :
> echo 'dotenv' > .envrc
> direnv allow
> ```
> Direnv chargera `.env` automatiquement à chaque `cd` dans le dossier.
>
> Tu choisis laquelle ?"

Après que l'utilisateur a choisi + appliqué, ferme la boucle : *"Quand tu auras relancé `claude` avec les vars chargées, tape `/mcp` pour vérifier que le MCP n8n se connecte. Si OK, on continue."*

#### 5c — Plugin frontend-design

Lance : `claude plugin list`

- Si `frontend-design@claude-code-plugins` listé → ✅ skip.
- Si absent → propose :
  ```
  claude plugin install frontend-design@claude-code-plugins
  ```
  *"Le plugin officiel Anthropic qui **construit** des composants UI propres (Next.js + Tailwind + shadcn). Il travaillera en duo avec le skill `/design` du kit : `/design` définit le système (DESIGN.md), `frontend-design` build les composants en lisant DESIGN.md. Skippe si t'as pas d'UI dans ton projet."*

### Étape 6 — Routage

Demande :

> "Dernière question : ton idée est précise (tu peux décrire le résultat final en 3 phrases) ou encore floue (tu as un besoin mais pas la solution exacte) ?
> - **Précise** → on attaque directement le PRD avec `/architect`
> - **Floue** → on creuse d'abord avec `/brainstorm` (3 questions clarifiantes, puis on enchaîne sur `/architect`)"

### Étape 7 — Handoff

Format strict :

```markdown
## ✅ Setup terminé

### Cadrage
- Projet : {Nom}
- Cible : {Q2}
- Output : {type A/B/C/D}
- Identité écrite dans `CLAUDE.md` (section `## Identité`)

### Outillage
- Playwright MCP : {✅ / ⏭ skippé / ⚠️ à installer manuellement}
- n8n MCP : {✅ / ⏭ skippé}
- Plugin frontend-design : {✅ / ⏭ skippé}

### Prochaine étape
- `/{brainstorm | architect}` selon ta réponse à la dernière question
- *(si web app)* Après `/architect`, lance `/design` pour produire `DESIGN.md` avant `/plan` Phase 1 — le plugin `frontend-design` le lira pour rester cohérent sur toutes tes pages.

Tu peux relancer `/start` à tout moment pour ré-cadrer ou re-vérifier l'outillage.
```

## Risque #1 — exposer un credential en clair

**Jamais** écrire `N8N_API_KEY` ou n'importe quel secret directement dans `.mcp.json`, dans `CLAUDE.md`, ou dans un commit message. Toujours :
1. Valeur réelle → `.env` (gitignored)
2. `.env` ligne dans `.gitignore` vérifiée avant d'écrire
3. `.mcp.json` utilise `${VAR}` qui sera résolu au lancement de `claude`
4. `.env.example` committé avec les placeholders pour la doc

Si l'utilisateur paste sa clé dans la conversation, **ne la répète jamais** dans tes réponses — confirme juste "Clé écrite dans `.env`." Si tu vois une clé qui ressemble à un token (suite de `eyJhbGc...` ou `sk-ant-...` ou `ghp_...`) en clair quelque part dans le repo, **stop** et alerte l'utilisateur.

## Risque #2 — écrire en dehors des ancres

**Test du miroir** : avant chaque `Edit` du `CLAUDE.md`, vérifie que tu modifies uniquement le contenu entre `<!-- start:identité -->` et `<!-- /start:identité -->`. Si la modif touche autre chose, **arrête** et redemande. Sans cette discipline, tu écrases la doc utilisateur ou les sections que d'autres skills écrivent.

## Risque #3 — bombarder de questions

3 questions au cadrage, pas plus. Si tu te dis "ah il me faudrait aussi savoir X", **non** — c'est `/architect` qui pose les questions de stack. Reste sur ton scope.

## Quand ne PAS utiliser ce skill

- En cours de session de travail (édition de code, debug) → c'est un skill d'onboarding, pas de fonctionnement quotidien
- Pour modifier le PRD ou la stack → `/architect` ou édition manuelle
- Pour ajouter un MCP au milieu d'un projet → utilise `claude mcp add` direct, pas besoin de `/start`

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "start", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Affiche à l'utilisateur :

```
✅ Cadrage projet créé : CLAUDE.md ## Identité

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /{brainstorm,architect} (selon project_type)
```

**Prochaine étape** : `/close → /clear → /{brainstorm,architect} (selon project_type)` — voir le rituel dans `docs/KIT.md § STATUS.md & rituel`.
