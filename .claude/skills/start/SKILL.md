---
name: start
description: Utiliser à l'ouverture d'une nouvelle session sur un projet basé sur ce kit. Visite guidée du kit (skippable), 3 questions de cadrage qui remplissent la section Identité du CLAUDE.md, vérification de l'outillage (Playwright + n8n MCP + plugin frontend-design), puis routage vers /brainstorm (idée floue) ou /architect (idée claire). Ne PAS utiliser au milieu d'une session de travail — c'est un skill d'onboarding.
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
3. Y a-t-il des fichiers `plans/phase-*.md` (ou `phase-*-plan.md` à la racine) ?
4. La variable `project_type:` est-elle présente dans `<!-- start:identité -->` ?

Branche selon le diagnostic :

**Cas A — Projet neuf** (placeholder identité présent, pas de PRD, pas de plans, pas de `project_type`) → tu déroules les phases 2 à 6 normalement (visite + 3 questions + écriture identité + outillage + routage).

**Cas B — Projet existant en cours** (identité remplie + PRD ou plans présents) → bifurque vers `/recap` :
> *"Projet déjà cadré et en cours ({Nom détecté de l'identité}). Trois options :*
> *(1) **Reprendre où tu en étais** — je délègue à `/recap` qui lit l'état et te propose la suite [recommandé]*
> *(2) **Cadrer une nouvelle tâche/feature** sur ce projet — on continue en mode visite + routage*
> *(3) **Ré-onboarder complet** (efface l'identité actuelle et re-fais le cadrage) — confirmation à 3 reprises avant écrasement"*
> *Tu choisis ?"*
- Si (1) → annonce *"OK, je passe la main à `/recap`"* et stoppe (l'utilisateur lance `/recap` ou tu peux suggérer en handoff).
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
```

(la valeur exacte du Q3 stocké en Étape 3). **Garde les ancres**. **Ne touche à aucune autre partie du fichier.**

Affiche la diff à l'utilisateur : *"Voici ce que je vais écrire dans `## Identité` (paragraphe + variable `project_type`). OK ou tu veux ajuster ?"* — sauvegarde après validation.

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

#### 5b — Sécuriser les credentials AVANT d'installer n8n MCP

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

**Étape 5b.3 — Demander les valeurs réelles**

Annonce : *"Je vais te demander 2 valeurs pour ton instance n8n. Elles vont dans `.env` (qui est gitignored, donc privé)."*

Demande `N8N_API_URL` et `N8N_API_KEY` (récupérables dans Settings → API de l'instance n8n).

**Si l'utilisateur dit "pas tout de suite"** : skip ; crée juste `.env` vide ou avec les placeholders, dis *"OK on le mettra quand tu en auras besoin. Edit `.env` direct."*

**Si l'utilisateur donne les valeurs** : crée/édite `.env` à la racine avec :
```
N8N_API_URL=<valeur fournie>
N8N_API_KEY=<valeur fournie>
```

**JAMAIS** echo, log, ou répète la valeur de `N8N_API_KEY` dans la conversation. Tu confirmes juste *"Clé écrite dans `.env`."*

**Étape 5b.4 — Ajouter n8n à `.mcp.json` avec `${VAR}`**

Lis `.mcp.json`. Édite-le pour ajouter l'entrée n8n avec syntaxe d'expansion (PAS de valeurs en dur) :

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": ["-y", "n8n-mcp@latest"],
      "env": {
        "N8N_API_URL": "${N8N_API_URL}",
        "N8N_API_KEY": "${N8N_API_KEY}"
      }
    }
  }
}
```

(Préserve les autres entrées MCP éventuellement déjà présentes — fusion, pas remplacement.)

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

## Handoff

Fin du skill : bloc "✅ Setup terminé" + suggestion `/brainstorm` ou `/architect`.
