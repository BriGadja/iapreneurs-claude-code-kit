---
name: start
description: Utiliser à l'ouverture d'une nouvelle session sur un projet basé sur ce kit. Visite guidée du kit (skippable), 3 questions de cadrage qui remplissent la section Identité du CLAUDE.md, vérification de l'outillage (Playwright + n8n MCP + plugin frontend-design), puis routage vers /brainstorm (idée floue) ou /create-prd (idée claire). Ne PAS utiliser au milieu d'une session de travail — c'est un skill d'onboarding.
---

# Skill /start — démarrage piloté

## Pour quoi faire

Premier skill à invoquer après avoir forké/cloné le kit. Trois objectifs :
1. **Cadrer le projet** : 3 questions ciblées qui écrivent la section `## Identité` du `CLAUDE.md`.
2. **Vérifier l'outillage** : Playwright, n8n MCP, plugin `frontend-design` installés et testés.
3. **Router** : vers `/brainstorm` (idée floue) ou `/create-prd` (idée claire).

Sortie : un `CLAUDE.md` avec l'Identité remplie + un MCP/plugin stack fonctionnel + le bon prochain skill suggéré.

## Règle d'or

**Tu ne modifies que les zones marquées par des ancres HTML** dans le `CLAUDE.md` (`<!-- start:identité -->` ... `<!-- /start:identité -->`). Tout le reste du fichier reste intact, même s'il est encore en mode template — ce sont les autres skills (`/create-prd`, etc.) ou l'utilisateur qui rempliront le reste plus tard.

## Comment procéder

### Étape 1 — Détecter l'état (10s)

Lis le `CLAUDE.md` à la racine.

- Si la section `<!-- start:identité -->` contient encore le placeholder `{2-3 phrases écrites par /start...}` → **première fois**, tu déroules les phases 2 à 5.
- Si la section est déjà remplie → demande : *"Identité déjà cadrée. Tu veux la re-écrire ou je passe direct à la vérif outillage et au routage ?"* Adapte.

### Étape 2 — Visite guidée (1 min, skippable)

Annonce :

> "Bienvenue. Je vais te guider en 4 phases : visite du kit (1 min, skippable), 3 questions sur ton projet, vérif de ton outillage, puis routage. **Tu veux skipper la visite ?** (oui / non)"

Si **non** (visite demandée), liste en 6 lignes :

> "Dans ce kit, tu as :
> - **7 skills** : `/start` (moi), `/brainstorm`, `/create-prd`, `/plan`, `/challenge` (optionnel), `/execute`, `/validate`.
> - **1 sous-agent** `research-delegate` que les skills invoquent quand ils ont besoin de chercher sans polluer ton contexte.
> - **7 skills n8n** officiels de Czlonkowski pour les workflows.
> - **Un `.mcp.json` vide** prêt à recevoir Playwright + n8n MCP + plugin `frontend-design` (on les installe en phase 3).
> - **Un dossier `.claude/rules/`** pour déporter les règles spécifiques à un domaine quand le `CLAUDE.md` devient trop long.
> Le tout est conçu pour grandir avec toi : tu peux commencer avec 3 skills (`/brainstorm`, `/create-prd`, `/plan`) et activer le reste au fil du temps."

Si **oui** (skip), passe direct à l'étape 3.

### Étape 3 — 3 questions de cadrage

Pose **exactement 3 questions**, une par une (pas en bloc — attendre la réponse) :

1. **Nom + une phrase** : "Ton projet s'appelle comment, et en une phrase, ça fait quoi ?"
2. **Pour qui** : "Qui va l'utiliser ? Toi tout seul, ton équipe, des clients pros, le grand public ?"
3. **Type d'output** : "L'utilisateur final voit le résultat où ?
   - **A** : page web qui se met à jour en direct (streaming, dashboard)
   - **B** : email / PDF / notification qui arrive en différé
   - **C** : script ou CLI (pas d'UI)
   - **D** : automatisation pure (n8n, pas d'utilisateur direct)"

Stocke les 3 réponses. **Ne propose pas la stack maintenant** — c'est `/create-prd` qui le fera.

### Étape 4 — Écrire la section Identité du CLAUDE.md

Compose 2-3 phrases à partir des réponses :

> "**{Nom}** est {phrase Q1}, destiné à {Q2}. Le résultat est livré via {Q3 en clair, ex: 'page web temps réel' / 'email avec PDF en pièce jointe' / 'script CLI' / 'workflow n8n déclenché par webhook'}."

Lis le `CLAUDE.md`, trouve le bloc :

```
<!-- start:identité -->
{...placeholder...}
<!-- /start:identité -->
```

Remplace le contenu entre les deux ancres par ton paragraphe. **Garde les ancres**. **Ne touche à aucune autre partie du fichier.**

Affiche la diff à l'utilisateur : *"Voici ce que je vais écrire dans `## Identité`. OK ou tu veux ajuster ?"* — sauvegarde après validation.

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
      "args": ["n8n-mcp@latest"],
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
  *"Bon pour les composants UI propres si tu fais du Next.js + Tailwind + shadcn. Skippe si t'as pas d'UI dans ton projet."*

### Étape 6 — Routage

Demande :

> "Dernière question : ton idée est précise (tu peux décrire le résultat final en 3 phrases) ou encore floue (tu as un besoin mais pas la solution exacte) ?
> - **Précise** → on attaque directement le PRD avec `/create-prd`
> - **Floue** → on creuse d'abord avec `/brainstorm` (3 questions clarifiantes, puis on enchaîne sur `/create-prd`)"

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
- `/{brainstorm | create-prd}` selon ta réponse à la dernière question

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

3 questions au cadrage, pas plus. Si tu te dis "ah il me faudrait aussi savoir X", **non** — c'est `/create-prd` qui pose les questions de stack. Reste sur ton scope.

## Quand ne PAS utiliser ce skill

- En cours de session de travail (édition de code, debug) → c'est un skill d'onboarding, pas de fonctionnement quotidien
- Pour modifier le PRD ou la stack → `/create-prd` ou édition manuelle
- Pour ajouter un MCP au milieu d'un projet → utilise `claude mcp add` direct, pas besoin de `/start`

## Handoff

Fin du skill : bloc "✅ Setup terminé" + suggestion `/brainstorm` ou `/create-prd`.
