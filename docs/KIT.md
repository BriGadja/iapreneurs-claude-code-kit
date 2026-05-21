# Kit IAPreneurs Claude Code — doc de référence

> **Version actuelle : v2.8.0** (2026-05-21). Source de vérité : fichier [`VERSION`](../VERSION) à la racine. Changelog : [`docs/CHANGELOG.md`](CHANGELOG.md).

> Doc de référence complète du kit. **Lue à la demande, pas à chaque session.** Pour démarrer un projet : tape `/start`. Le `CLAUDE.md` à la racine ne contient que ce qui sert à *chaque* session — tout le reste vit ici.

## Skills du kit

### Table principale — 10 commandes du cycle de vie projet

| Skill | Pour quoi | Quand | Statut |
|-------|-----------|-------|--------|
| `/start` | Cadrage projet + sécurisation credentials + vérif outillage + routage. Détecte aussi projet existant et bifurque vers `/prime`. Écrit `project_type` ∈ `{webapp, site, automation}` dans CLAUDE.md `## Identité`. | 1x à l'ouverture d'une nouvelle session | ✅ |
| `/brainstorm` | Clarifier une idée vague (3-5 questions + recherche optionnelle) et produire un brief écrit dans `docs/brainstorms/{date}-{slug}.md`. Aucun routing automatique — l'utilisateur choisit ensuite `/architect`, `/plan` ou `/evoluer` avec le brief en argument. | Si l'idée n'est pas claire après `/start` ou en cours de projet | ✅ |
| `/architect` | Produire un `PRD.md` structuré (mini-3-sections en LITE, 7 sections en STANDARD/FULL) + **Étape 2b providers favoris** (hosting/BDD/email) + **Étape 6 Provisioning & Scaffold** (scaffold le repo selon `project_type` + retenus + écriture `.env`). Écrit `## Stack` dans CLAUDE.md. | Une fois l'idée claire | ✅ |
| `/design` *(webapp uniquement)* | Définit le design system au format **DESIGN.md officiel Google** (open-source, spec alpha). Template fourni. **Complémentaire** au plugin Anthropic `frontend-design`. | Après `/architect`, **uniquement si project_type = webapp** | ✅ |
| `/plan` | Découper UNE phase du PRD en tâches numérotées avec critères "Fait quand". Adapte ses questions selon `project_type`. | Avant d'exécuter une phase | ✅ |
| `/execute` | Exécuter le plan tâche par tâche, coche les `[x]` au fil de l'eau. Délègue à `research-delegate` si bloqué par une doc API externe. | Après `/plan` (et éventuellement `/challenge`) | ✅ |
| `/validate` | Vérifier que la phase marche pour de vrai (Playwright / n8n / curl / **audit policy d'accès BDD** si données clients). Jamais "ça devrait marcher". | Après `/execute` | ✅ |
| `/close` | Clôturer la phase : ✅ Terminée dans PRD + commit conventionnel + harvest learnings (3 questions ciblées) + suggestion next. **Étape 6.5** propose un gate déploiement (commit only / push main = deploy prod / push branche = preview) si projet Vercel-lié avec commits non-pushés. | **Mandatory** après `/validate ✅` | ✅ |
| `/livrer` | Déployer en production via **GitHub→Vercel auto-deploy** par défaut (push = deploy), ou selon `## Stack` (Netlify/Cloudflare/GitHub Pages/autre) — toujours **détecté depuis CLAUDE.md, jamais hardcode**. Inclut onboarding guidé au premier deploy + checklist policy d'accès advisory + **configuration domaine/sous-domaine custom registrar-aware** (OVH/Gandi/Cloudflare/Hostinger, Étape 3.5 opt-out) + smoke test. | Quand la dernière phase est `/close` | ✅ |
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

## Premier déploiement — flow GitHub → Vercel auto-deploy (v2.3.0)

Depuis v2.3.0, `/livrer` pour `hosting = vercel` adopte le pattern moderne **GitHub → Vercel auto-deploy** : tu pousses sur GitHub, Vercel détecte le commit et build automatiquement. Plus besoin de `vercel --prod` à chaque release (conservé en fallback "power users" pour cas spécifiques).

### Règle Dashboard vs CLI (v2.5.0)

`/livrer` respecte une **séparation explicite** :

- **Dashboard web obligatoire** (visuel/pédagogique) : création de compte GitHub/Vercel, création du repo sur github.com/new, import du projet sur vercel.com/new.
- **CLI OK pour l'automatisation** : `gh api user`, `gh auth login --web`, `git remote add` / `git push`, `vercel link` (linker projet existant), `vercel env add`, `vercel domains add`, etc.
- **CLI interdite** pour : `gh repo create` (l'utilisateur doit voir où il crée son repo) et l'import projet Vercel (idem).

### Prérequis (vérifiés par `/livrer` au premier deploy)

- Compte **GitHub** (le skill propose le lien signup si tu n'en as pas)
- Compte **Vercel** (gratuit) + **Vercel GitHub App** installée sur ton compte (scope `Only select repositories` recommandé pour la sécurité)
- Variables d'environnement (`.env.local`) ajoutées dans **Vercel dashboard AVANT le premier push** — sinon build OK mais runtime crash silencieux

### 3 marqueurs d'état (détection automatique)

`/livrer` détermine si tu es au premier deploy ou en mode "push fast path" en checkant 3 marqueurs :

1. `git remote get-url origin` pointe vers GitHub ?
2. Le repo distant existe sur GitHub (vérifié via `gh repo view`) ?
3. `.vercel/project.json` présent (= Vercel link déjà fait) ?

- **3/3** → fast path : juste `git push` + smoke test
- **< 3/3** → onboarding guidé pas-à-pas (warning Hobby plan, auth GitHub, création/lien repo, install Vercel GitHub App, env vars dashboard, `vercel link`, premier push)

### ⚠️ Vercel Hobby plan = non-commercial

**Vercel Hobby = usage personnel uniquement** (TOS). Si tu vends ton projet comme prestation à un client (€1500+), tu DOIS upgrade Vercel Pro (~$20/mo) avant le push. `/livrer` t'affiche ce warning **avant** tout setup.

**Alternative sans cette restriction** : **Netlify** est gratuit même pour usage commercial. Change `## Stack` de ton CLAUDE.md (hosting: Netlify) et relance `/livrer` — la route Netlify est conservée intacte par v2.3.0.

### Domaine custom (v2.4.0, opt-out)

Entre Étape 3 (deploy) et Étape 4 (smoke test), `/livrer` propose **Étape 3.5 — Domaine custom**. Une seule question d'entrée : *"Tu veux configurer une URL custom au lieu de garder `{URL_DEFAUT}` ?"*. Si "Non" → skip direct, aucun ralentissement. Si "Oui" → flow guidé pas-à-pas.

**Registrars couverts** (avec instructions précises) :
- **OVH** *(recommandé dans le module Claude Code IAPreneurs — interface FR, support FR, ~7€/an .fr)*
- **Gandi**, **Cloudflare**, **Hostinger**
- **Autre** : pattern générique CNAME/A + lien doc Vercel

**Gotchas explicités** :
- **OVH CNAME** : point final obligatoire sur la cible (`cname.vercel-dns.com.` PAS `cname.vercel-dns.com`)
- **Cloudflare** : Proxy status "DNS only" (nuage gris, PAS orange) — sinon SSL Vercel cassé
- **OVH apex** : pas d'ALIAS/ANAME → records A vers IPs Vercel

**Si DNS pas encore propagé** : marquer `⏳ DNS pending` dans `## Production`, smoke test sur fallback hosting, re-lancer `/livrer` après propagation.

### Gate déploiement dans `/close` (v2.3.0)

Quand `/close` détecte que ton projet est Vercel-lié + qu'il reste des commits non-pushés + que `project_type` est `webapp` ou `site`, il propose **Étape 6.5 — gate déploiement** avec 3 options :

- **Commit only** : comportement actuel (push différé)
- **Push main = deploy prod** : push immédiat, Vercel build prod
- **Push branche feature = preview** : crée une branche, push, Vercel build preview (URL pattern `https://{slug}-git-{branche}-{team}.vercel.app`)

Si tu n'es pas sur Vercel, ou si tu n'as pas de commit non-pushé, cette étape est skip silencieuse.

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
# Pattern canonique du kit : valeurs en clair dans .mcp.json (gitignored).
# Remplace les <...> par tes vraies valeurs avant de lancer la commande.
# Cf. .claude/rules/n8n-setup.md § 1.b pour le rationale (le pattern ${VAR}+.env est piégeux côté Claude Code).
claude mcp add n8n-mcp \
  -e MCP_MODE=stdio \
  -e LOG_LEVEL=error \
  -e DISABLE_CONSOLE_OUTPUT=true \
  -e 'N8N_API_URL=<URL réelle, ex: https://n8n.tondomaine.com/api/v1>' \
  -e 'N8N_API_KEY=<JWT réel>' \
  -- npx -y n8n-mcp@latest

# Plugin frontend-design
claude plugin install frontend-design@claude-code-plugins
```

Puis : `claude mcp list` et `claude plugin list` pour vérifier.

> **Pin de version recommandé** — `n8n-mcp@latest` te donne le dernier release (czlonkowski ship souvent : `2.51.x` actuellement). Pour la reproductibilité, pinne une version explicite dans `.mcp.json` (ex : `n8n-mcp@2.51.3`) et bump volontairement après avoir lu le CHANGELOG.

### Pattern canonique du kit pour les credentials MCP

Le kit applique un seul pattern d'install MCP, prescrit par [`.claude/rules/n8n-setup.md`](../.claude/rules/n8n-setup.md) § 1.b :

1. **`.mcp.json`** à la racine — **valeurs réelles en clair**, **gitignored**. Pourquoi pas `${VAR}` + `.env` ? Parce que Claude Code ne source pas `.env` automatiquement : il lit `${VAR}` depuis l'environnement du **shell parent** qui a lancé `claude`. Friction systématique sur Code Server. On évite le problème en mettant les valeurs directement dans `.mcp.json` (gitignored).
2. **`.mcp.json.example`** committé — copie de `.mcp.json` avec `REPLACE_ME` à la place des secrets, sert de doc pour les futurs forkers/collègues.
3. **`.env`** — réservé aux **secrets applicatifs** (Stripe, OpenAI, Resend, etc. lus par l'app au runtime), gitignored. Pas pour les MCP du kit.
4. **`.env.example`** committé — placeholders pour les secrets applicatifs.

Exemple `.mcp.json` (gitignored) :
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
        "N8N_API_URL": "https://n8n.tondomaine.com/api/v1",
        "N8N_API_KEY": "eyJhbGciOiJIUzI1NiIs..."
      }
    }
  }
}
```

Le `-y` dans `args` évite que npx te bloque sur un prompt "install ?" au premier lancement du MCP. Si tu veux le mode docs-only, retire les 2 dernières lignes `N8N_API_*`.

Aucune commande shell magique n'est nécessaire ensuite : **redémarrer Claude Code** suffit (`exit` puis `claude`), il relit `.mcp.json`.

### Directives système (Silent Execution, Templates-First, Validate Before Deploy)

Le créateur du MCP prescrit 4 directives pour utiliser l'outil correctement. Elles sont consignées dans **`.claude/rules/n8n.md`** (auto-chargées sur `.workflow.json`, `.mcp.json`, et tout fichier du dossier `.claude/skills/n8n/`). En résumé : `search_templates` avant de coder, `validate_workflow` avant de déployer, jamais d'édition AI directe sur `[PROD]`, exécution silencieuse des outils.

Si tu vois un secret en clair dans un fichier **committé**, **stop immédiatement** et déplace-le dans le bon endroit (`.mcp.json` gitignored pour les creds MCP, `.env` gitignored pour les creds applicatifs). Re-write l'historique git si nécessaire (`git filter-repo` ou re-création du repo si récent).

---

## STATUS.md & rituel close → clear → next

Le kit utilise un fichier **`STATUS.md`** à la racine du projet (~15-25 lignes) pour reprendre proprement après chaque session ou interruption. Ce fichier a **un seul écrivain** : `/close`. Tu ne l'édites jamais à la main.

### Le rituel en 3 étapes après chaque skill majeur

Quand un skill produit un artefact (PRD, plan, design, brief, etc.), il affiche un bloc final :

```
✅ {Résultat} : {chemin/artefact}

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /{next-skill} {args}
```

**Pourquoi 3 étapes (pas 1)** :
- `/close` persiste : commit conventionnel + update STATUS.md (+ harvest learnings si fin de phase). Sans ça, le contexte de ce qui vient d'être fait n'est pas conservé pour la session suivante.
- `/clear` repart d'une fenêtre vide : pas de bruit accumulé, le skill suivant lit STATUS.md fraîchement.
- `/{next-skill}` enchaîne sur l'étape suivante. Le skill relit `STATUS.md` + l'artefact mentionné.

### `tmp/skill-trace.jsonl` — la trace mécanique

Chaque skill append une ligne JSON à `tmp/skill-trace.jsonl` à sa fin (le fichier et le dossier `tmp/` sont créés si absents) :

```json
{"skill": "plan", "artifact": "docs/plans/phase-1-plan.md", "next": "/execute phase-1", "ts": "2026-05-13T14:32:01+02:00"}
```

`tmp/` est gitignored — la trace est locale. `/close` consolide la trace dans STATUS.md puis **supprime** le fichier (consommation).

### Qui écrit STATUS.md et quand

| Action sur STATUS.md | Qui | Quand |
|---|---|---|
| Création initiale | `/start` (template) | À l'onboarding du projet |
| Mise à jour | `/close` (planning ou full) | À chaque fin de skill majeur |
| Lecture prioritaire | `/prime` | À chaque reprise de session |
| Édition manuelle | **Personne** | Jamais (single writer = `/close`) |

### `/close` — 3 modes auto-détectés

`/close` détecte automatiquement le scope du diff git + de la trace :

- **No-op** : trace vide ET aucun fichier modifié → "Rien à clôturer. Tu peux `/clear` directement."
- **Planning** : seuls les artefacts de planning sont touchés (plans/, PRD.md, STATUS.md, research/, docs/brainstorms/, docs/plans/, memory/daily/) → commit + update STATUS.md + skip les 3 questions harvest.
- **Full (fin de phase)** : du code est inclus → commit + marque Phase ✅ dans PRD + update STATUS.md + harvest 3 questions opt-in.

---

## Cycle de vie d'un projet

Un projet kit a deux modes de vie : **création** (de zéro jusqu'à livraison) puis **maintenance** (évolutions post-livraison). Les skills sont pensés pour ces 2 modes distincts.

### Mode création (V1 du projet)

```
/start → /architect → /plan → /execute → /validate → /close → /livrer
```

- **`/start`** — onboarding (Q1-Q4 dont `project_uses_n8n`), génère squelette CLAUDE.md + STATUS.md
- **`/architect`** — PRD fondateur (8 sections, cap 100L) + STRUCTURE.md + decisions.md ADR-001
- **`/plan`** — découpe Phase 1 (option G/W/T si STANDARD+ webapp)
- **`/execute`** — exécute tâche par tâche (golden rule = vérif post-task immédiate)
- **`/validate`** — Karpathy regression check
- **`/close`** — commit + harvest + STATUS.md (+ audit caps si applicable)
- **`/livrer`** — déploiement prod stack-aware

### Mode maintenance (V2, V3, ...)

```
/prime (mode maintenance) → /evoluer → /plan → /execute → /validate → /close
```

- **`/prime`** — détecte `mode` via `count(docs/specs/SPEC-*.md)` : si > 0 → maintenance, lit decisions + 3 derniers SPECs
- **`/evoluer`** — cérémonie distincte : lit PRD/STRUCTURE/decisions/3 SPECs, crée `docs/specs/SPEC-{date}-{slug}.md`, déplace checkbox Hors scope → Scope actuel, append Implementation Phases V_n+1, append ADR si choix archi, gate /validate avant merge
- **`/plan`** prend le SPEC en input (pas le PRD entier)
- **`/execute`** + **`/validate`** + **`/close`** identiques (mode full)

### Qui écrit quoi

| Skill | Lit | Écrit | Mute |
|-------|-----|-------|------|
| `/start` | — | CLAUDE.md, STATUS.md, .mcp.json | — |
| `/architect` | CLAUDE.md | PRD.md (8 sections), STRUCTURE.md, memory/decisions.md ADR-001 | — |
| `/plan` | PRD, STRUCTURE, codebase | docs/plans/phase-N-plan.md | — |
| `/execute` | plan, PRD | code + tests | plan checkboxes |
| `/validate` | plan, tests | tmp/validate-report.md | — |
| `/close` | trace, git diff | STATUS.md, memory/learnings/, memory/topics/, memory/decisions.md | PRD checkbox + Implementation Phases date |
| `/evoluer` | PRD, STRUCTURE, decisions, 3 SPECs, STATUS | docs/specs/SPEC-{date}-{slug}.md, STRUCTURE, decisions.md ADR | PRD checkbox Hors scope→Scope, append Phases V_n+1 |
| `/prime` | STATUS, PRD, plans, git, decisions, SPECs | — (lecture pure) | — |

**Règle d'or** : le **PRD est vivant discipliné** (cap 100L). Mis à jour uniquement par `/evoluer` (déplace checkboxes) et `/close` (cocher + dater). **Jamais réécrit destructivement.**

### Convention collision SPEC

Si deux évolutions le même jour ont le même slug : `SPEC-{date}-{slug}-02.md`, `-03.md`, etc. `/evoluer` Étape 5b détecte et incrémente automatiquement.

---

## Aller plus loin

- `.claude/rules/README.md` — pattern des règles auto-chargées par chemin (paths-scoped)
- `memory/README.md` — système mémoire persistante (learnings / topics / decisions)
- `.claude/skills/{skill}/SKILL.md` — détail d'un skill spécifique
- `examples/` — 3 exemples remplis (site, webapp, automation)
