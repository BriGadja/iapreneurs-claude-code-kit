---
name: start
description: Utiliser à l'ouverture d'une session sur un projet basé sur ce kit, pour cadrer ou recadrer le contexte. Pose 4 questions de cadrage (nom, public, project_type, n8n) et route vers /brainstorm ou /architect. Ne PAS utiliser au milieu d'une session de travail — c'est un skill d'onboarding. Pour reprendre un projet existant après pause, utiliser /prime à la place.
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

### Étape 0a — Initialiser CLAUDE.md depuis le template (3s)

**Détection** : si `CLAUDE.md` est absent à la racine ET que `CLAUDE.md.template` existe, copie-le :

```bash
[ ! -f CLAUDE.md ] && [ -f CLAUDE.md.template ] && cp CLAUDE.md.template CLAUDE.md
```

Le template contient les placeholders `{Nom de ton projet}`, `{site | webapp | automation}`, etc. — c'est ce fichier que les étapes suivantes (3, 5+) vont remplir. Le `CLAUDE.md` projet est gitignored par défaut (chaque fork génère le sien). Si tu veux quand même le ship : `git add -f CLAUDE.md`.

**Si `CLAUDE.md` existe déjà** : ne touche à rien, passe à l'Étape 0.

### Étape 0 — Détecter un clone direct du kit (5s)

**Détection** : lance `git remote get-url origin 2>/dev/null` et grep `iapreneurs-claude-code-kit`. Si match ET que `<!-- start:identité -->` contient encore le placeholder par défaut (= projet jamais cadré), tu es dans le cas "fresh clone du kit".

**Si détecté** → **lis `references/bootstrap-fresh-clone.md` et applique sa procédure** (question utilisateur + reinit git si oui).

**Si pas détecté** (utilisateur a "Use this template", ou a déjà fait le bootstrap) → ne dis rien et passe à l'Étape 0.5.

### Étape 0.5 — Identité git locale (15s)

Avant d'aller plus loin, on s'assure que les commits de ce projet auront **ton** nom dessus.

**Lis `references/git-identity.md` et applique sa procédure** (détection 3 cas A/B/C — pas de repo / identité présente / identité absente ou à override).

### Étape 1 — Détecter l'état du projet (10s)

**Lis `references/project-detection.md` et applique sa procédure** (lecture MEMORY.md + CLAUDE.md + 4 signaux + branche A/B/C selon diagnostic).

Selon la branche diagnostiquée, l'étape suivante varie : Cas A → Étape 2, Cas B(1) → handoff `/prime`, Cas B(2) → Étape 5, Cas B(3) → Étape 2 après 3 confirmations, Cas C → Étape 5 après écriture `project_type`.

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

- Si **oui** ou si `project_type == automation` → `project_uses_n8n: true`. Tu vas devoir installer le MCP n8n + la collection skills czlonkowski via la procédure `references/n8n-mcp-install.md` (Étape 5b).
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

> **Note** : le placeholder `<!-- n8n-section -->` dans `CLAUDE.md` reste intact à ce stade. Il sera décommenté par `.claude/rules/n8n-setup.md` à l'install (Étape 5b), seulement si `project_uses_n8n: true`.

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

#### 5a — Playwright

**Lis `references/playwright-install.md` et applique** (claude mcp list → install si absent → test optionnel).

#### 5b — n8n MCP (UNIQUEMENT si `project_uses_n8n: true`)

> **Gate conditionnel** : si `project_uses_n8n: false` (Q4), **skip entièrement** cette sous-section 5b. Le kit reste slim — pas de MCP n8n installé, pas de collection skills czlonkowski. Tu pourras toujours basculer plus tard en relançant la procédure `.claude/rules/n8n-setup.md` à la main.

**Si `project_uses_n8n: true` : lis `references/n8n-mcp-install.md` et applique sa procédure complète** (5 sous-étapes : gitignore, .env.example, mode API-connected recommandé, `.mcp.json` valeurs en clair gitignored, puis déclenchement de `.claude/rules/n8n-setup.md`).

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

**Jamais** écrire `N8N_API_KEY` ou n'importe quel secret dans un fichier **committé**. Le pattern canonique du kit met les valeurs réelles dans `.mcp.json` qui est **gitignored** — ça reste sur ta machine. Toujours :
1. `.mcp.json` ligne dans `.gitignore` vérifiée avant d'écrire (Étape 5b.1)
2. `.mcp.json.example` committé avec `REPLACE_ME` pour les futurs forkers/collègues
3. Pour les secrets applicatifs (Stripe, OpenAI, etc.) → `.env` (gitignored) + `.env.example` (committé)

Si l'utilisateur paste sa clé dans la conversation, **ne la répète jamais** dans tes réponses — confirme juste "Clé écrite dans `.mcp.json`." Si tu vois une clé qui ressemble à un token (suite de `eyJhbGc...` ou `sk-ant-...` ou `ghp_...`) en clair quelque part dans un fichier **committé**, **stop** et alerte l'utilisateur.

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
