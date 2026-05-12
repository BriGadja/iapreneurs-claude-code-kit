# IAPreneurs Claude Code Kit

> **Framework guidé Claude Code pour débutants**, du démarrage au scaling. Supporte 3 cas d'usage : **site vitrine**, **web app SaaS**, **automatisation n8n**. Tape `/start` après le clone, suis le guide piloté, et tu attaques ton premier projet en 5 minutes.

## 3 parcours typiques

**Parcours 1 — Création (premier projet)** :
```
/start              ← cadrage + outillage + project_type + Request Classification
   ↓
/brainstorm         ← (optionnel) si idée floue
   ↓
/architect          ← PRD.md + providers favoris + Étape 6 scaffold + provisioning
   ↓
/design             ← SI webapp : produit DESIGN.md (sinon skip)
   ↓
/plan Phase 1       ← découpe en tâches (adapté project_type)
   ↓
/challenge          ← (optionnel, systématique en FULL)
   ↓
/execute            ← coche les [x] une par une
   ↓
/validate           ← verdict réel "ça marche / ça marche pas"
   ↓
/close              ← MANDATORY : ✅ Terminée + commit + harvest mémoire
   ↓
/plan Phase 2 → ... (boucle)
   ↓
/livrer             ← deploy prod selon ## Stack (Vercel/Netlify/Cloudflare/autre)
```

**Parcours 2 — Reprise (tu reviens après une absence)** :
```
/recap              ← lit PRD + plans + git log + MEMORY.md → propose la suite
   ↓
{action proposée}   ← /execute, /plan, /livrer, /evoluer selon l'état détecté
```

**Parcours 3 — Évolution (projet livré, tu veux ajouter une feature)** :
```
/recap              ← détecte projet livré → propose /evoluer
   ↓
/evoluer            ← parse PRD + 3 questions cadrage + insère Phase N+1
   ↓
/plan Phase N+1     ← reprend le flux standard
   ↓
/execute → /validate → /close → /livrer
```

## Démarrage

```bash
# 1. Fork ce repo (bouton "Fork" sur GitHub)
# 2. Clone ton fork
git clone https://github.com/TON-USERNAME/iapreneurs-claude-code-kit.git
cd iapreneurs-claude-code-kit

# 3. Lance Claude Code
claude
```

Une fois dans Claude, tape :

```
/start
```

`/start` te guide :
1. **Détection projet** — lit MEMORY.md + CLAUDE.md + PRD.md. Si projet existant détecté → bifurque vers `/recap`.
2. **Visite du kit** (skippable)
3. **3 questions de cadrage** → remplit la section `## Identité` de ton `CLAUDE.md` + écrit `project_type` ∈ `{webapp, site, automation}`
4. **Sécurisation des credentials** → `.env` créé et gitignored, `.mcp.json` avec syntaxe `${VAR}`
5. **Vérification de l'outillage** → Playwright + n8n MCP + plugin frontend-design
6. **Routage** → `/brainstorm` (idée floue) ou `/architect` (idée claire) ou `/recap` (projet existant)

Sortie : projet cadré, outillage testé, prochain skill suggéré.

## Skills

**Table principale — 10 commandes du cycle de vie projet** *(certaines arrivent en v2.0.0 GA — voir colonne "Statut")* :

| Skill | Rôle | Statut |
|-------|------|--------|
| `/start` | Onboarding piloté (5 phases + détection projet existant qui bifurque vers `/recap`). À taper 1x à l'ouverture. Écrit la variable `project_type` ∈ {webapp, site, automation}. | ✅ |
| `/brainstorm` | Clarifier une idée vague en 3 questions. Route 2 délègue à `research-delegate` pour explorer projets similaires. | ✅ |
| `/architect` | Produire un `PRD.md` structuré + **Étape 2b demande les providers favoris** (hosting/BDD/email) avant de figer la stack + **Étape 6 Provisioning & Scaffold** (scaffold le repo selon `project_type` + providers retenus + écriture `.env`). Écrit la section `## Stack` du `CLAUDE.md`. | ✅ |
| `/design` *(webapp uniquement)* | **Définit** le design system au format **DESIGN.md officiel Google** (open-source, spec alpha — YAML tokens + 8 sections markdown). Template fourni dans `.claude/skills/design/template.md`. **Complémentaire** au plugin Anthropic `frontend-design` qui lit `DESIGN.md` pour build des composants cohérents. | ✅ |
| `/plan` | Découper UNE phase du PRD en tâches avec critères "Fait quand". Lit `DESIGN.md` si la phase touche à l'UI. Adapte ses questions selon `project_type`. | ✅ |
| `/execute` | Exécuter le plan tâche par tâche, cocher au fur et à mesure. Délègue à `research-delegate` si bloqué par une doc API externe. | ✅ |
| `/validate` | Vérifier que la phase marche pour de vrai (Playwright / n8n / autre / **audit policy d'accès BDD** si données clients). Jamais "ça devrait marcher". | ✅ |
| `/close` | Clôturer la phase : marque ✅ Terminée dans le PRD + commit conventionnel + harvest learnings + handoff. **Mandatory** après `/validate ✅`. | ✅ |
| `/livrer` | Déployer en production selon `## Stack` (hosting/BDD/email **détectés depuis CLAUDE.md, jamais hardcode** — Vercel/Netlify/Cloudflare/GitHub Pages/autre) + checklist policy d'accès advisory + smoke test. | ✅ |
| `/evoluer` | Ajouter une nouvelle feature à un projet livré : insère Phase N+1 dans PRD existant sans écraser (regex parse + 3 questions + idempotent). | ✅ |

**Skills optionnels avancés** :

| Skill | Rôle |
|-------|------|
| `/challenge` | Devil's advocate sur un plan : 3 risques + 3 hypothèses non vérifiées + verdict GO/REWORK/STOP. Systématique en Request Classification FULL. |

**Notes hors table** :
- Tu reviens après une pause ? Tape `/recap` — lit `PRD.md` + `phase-*-plan.md` + git log + `MEMORY.md` et propose la suite. `/start` détecte automatiquement les projets existants et bifurque vers `/recap`.
- Pour debugger un bug → tape `/debug` (built-in Claude Code natif). **Règle de comportement** : écris d'abord un test de régression qui reproduit le bug, puis fais-le passer (TDD).
- **Mémoire persistante** : `/close` maintient automatiquement `memory/learnings/`, `memory/topics/`, `memory/decisions.md` et `MEMORY.md` (index racine) à chaque clôture de phase, via 3 questions ciblées (décision arch ? gotcha ? pattern ?). **L'utilisateur n'édite jamais ces fichiers à la main.** Détails dans le template `CLAUDE.md` section `## Mémoire persistante`.

Workflow type : `/start` → `/brainstorm`? → `/architect` (PRD + providers + scaffold) → `/design`? → `/plan` Phase 1 → `/execute` → `/validate` → `/close` → `/plan` Phase 2 → ... → `/livrer`. Reprise : `/recap`. Évolution : `/evoluer`.

`/design` est conditionnel — skip si `project_type` ∈ {site, automation}. `/challenge` est optionnel.

## Sous-agent

`research-delegate` (`.claude/agents/`) — sous-agent read-only invoqué automatiquement par les skills (recherche web pour `/brainstorm`, scout codebase pour `/plan`, lecture doc pour `/execute`, parallélisation pour `/validate`). Lit jusqu'à 15 sources et renvoie 3-10 bullets. Garde ta fenêtre de contexte propre.

## Skills n8n

7 skills officiels de [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT) dans `.claude/skills/n8n/` : `n8n-mcp-tools-expert`, `n8n-workflow-patterns`, `n8n-validation-expert`, `n8n-node-configuration`, `n8n-expression-syntax`, `n8n-code-javascript`, `n8n-code-python`. Auto-invoqués quand tu touches à n8n.

## Règles path-scoped

`.claude/rules/` contient des fichiers Markdown avec frontmatter `paths:` qui se chargent **automatiquement** quand Claude ouvre un fichier matching le glob. Permet de garder le `CLAUDE.md` court.

Exemples fournis :
- `frontend.md` (`paths: src/**/*.{ts,tsx}`) — React + Tailwind + shadcn
- `n8n.md` (`paths: **/*.workflow.json`) — naming workflows, credentials, webhooks, anti-patterns

Voir `.claude/rules/README.md` pour le détail du pattern.

## Template `CLAUDE.md`

5 couches **Identité / Stack / Conventions / Instructions / Contexte métier** avec ancres HTML pour les zones écrites par les skills (`<!-- start:identité -->`, `<!-- architect:stack -->`) + 4 règles de comportement (réfléchir avant de coder, simplicité, modifs chirurgicales, exécution orientée but) + section "Comment ce CLAUDE.md est entretenu" (séquencement skills, qui écrit quoi, déportation vers `.claude/rules/`) + section "Sécurité des credentials".

## Exemples remplis

Trois exemples, un par `project_type` :

| Exemple | `project_type` | Niveau | Stack |
|---------|---------------|--------|-------|
| [`examples/site-vitrine-coach/`](examples/site-vitrine-coach/) | `site` | LITE | Next.js + Vercel + Resend |
| [`examples/webapp-saas-freelance-devis/`](examples/webapp-saas-freelance-devis/) | `webapp` | STANDARD | Next.js + Supabase + n8n + Resend + Vercel |
| [`examples/automation-n8n-veille-rss/`](examples/automation-n8n-veille-rss/) | `automation` | STANDARD | n8n + Supabase + Anthropic Haiku + Slack |

Détails et critères de choix dans [`examples/README.md`](examples/README.md). Ouvre ces fichiers en parallèle de tes propres essais — le format est plus parlant qu'une longue doc.

## Scaffolding outillage

- `.mcp.json` vide prêt à recevoir Playwright, n8n MCP, plugin frontend-design (commandes documentées dans `CLAUDE.md`)
- `.env.example` avec placeholders pour n8n, Anthropic SDK, Supabase, Resend
- `.gitignore` durci sur `.env`, `.env.local`, `.env.*.local`, `.envrc`
- `tmp/` (gitignored sauf `.gitkeep`) pour les fichiers temporaires : screenshots Playwright produits par l'auto-évaluation (cf. CLAUDE.md règle 6), dumps debug, outputs intermédiaires de skills. **Nettoie après usage** — le dossier existe pour ne pas polluer le repo, pas pour s'accumuler.
- `memory/` (structure créée à l'init) + `MEMORY.md` (index racine) — **maintenu par `/close`**, pas d'édition manuelle

## Sécurité

### Credentials

**Règle non-négociable** : aucune clé API en clair dans un fichier committé.

Pattern Anthropic-officiel (appliqué automatiquement par `/start`) :
- `.env` (gitignored) → vraies valeurs
- `.env.example` (committé) → placeholders pour la doc
- `.mcp.json` (committé) → syntaxe `${VAR}` :
  ```json
  { "env": { "N8N_API_KEY": "${N8N_API_KEY}" } }
  ```
- Charger `.env` dans le shell avant `claude` : `set -a && source .env && set +a` (ou installer `direnv` pour le faire automatiquement)

### Row-Level Security (Supabase)

Dès que ton app contient des données clients (nom, email, téléphone, SIRET, transcripts RDV, devis, factures, leads, multi-tenant), **RLS dès le premier deploy. Sans exception.**

Cas inverse : un outil à données éphémères sans PII (sondage live, kanban temporaire) peut skipper RLS. Mais c'est minoritaire.

> Test simple : si le pire scénario d'une fuite est "rien de grave", tu peux skipper. Sinon, RLS systématique avant prod.

Et au-delà de RLS : valide les inputs côté serveur (jamais juste côté client), ne committe **jamais** `.env`.

## 📚 Pour en savoir plus

- [`docs/KIT.md`](docs/KIT.md) — Doc de référence complète du kit (skills, parcours, MCP install, sous-agent)
- [`CLAUDE.md`](CLAUDE.md) — Template projet (à adapter à ton cas)
- [`memory/README.md`](memory/README.md) — Système mémoire persistante (maintenu par `/close`)
- [`.claude/skills/`](.claude/skills/) — Détail de chaque skill (`/start` comme point d'entrée)
- [`.claude/rules/README.md`](.claude/rules/README.md) — Règles path-scoped auto-chargées

## Crédits

- **Skills n8n** : [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT, attribution dans `.claude/skills/n8n/LICENSE-czlonkowski`)

## License

[MIT](LICENSE) — Copyright 2026 Brice Gachadoat. Fais-en ce que tu veux.
