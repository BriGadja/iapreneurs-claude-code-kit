# IAPreneurs Claude Code Kit

> Kit Claude Code prêt à forker. Tape `/start` après le clone, suis le guide piloté, et tu attaques ton premier projet en 5 minutes.

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

`/start` te guide en 5 phases :
1. **Visite du kit** (skippable)
2. **3 questions de cadrage** → remplit la section `## Identité` de ton `CLAUDE.md`
3. **Sécurisation des credentials** → `.env` créé et gitignored, `.mcp.json` avec syntaxe `${VAR}`
4. **Vérification de l'outillage** → Playwright + n8n MCP + plugin frontend-design
5. **Routage** → `/brainstorm` (idée floue) ou `/architect` (idée claire)

Sortie : projet cadré, outillage testé, prochain skill suggéré.

## Skills

**Table principale — 11 commandes du cycle de vie projet** *(certaines arrivent en v2.0.0 GA — voir colonne "Statut")* :

| Skill | Rôle | Statut |
|-------|------|--------|
| `/start` | Onboarding piloté (5 phases + détection projet existant qui bifurque vers `/recap`). À taper 1x à l'ouverture. Écrit la variable `project_type` ∈ {webapp, site, automation}. | ✅ |
| `/brainstorm` | Clarifier une idée vague en 3 questions. Route 2 délègue à `research-delegate` pour explorer projets similaires. | ✅ |
| `/architect` | Produire un `PRD.md` structuré + **Étape 6 Provisioning & Scaffold** (scaffold le repo selon `project_type` + provisioning Supabase/Vercel/n8n + écriture `.env`). Écrit la section `## Stack` du `CLAUDE.md`. | ✅ |
| `/design` *(webapp uniquement)* | **Définit** le design system (architecte) au format **DESIGN.md officiel Google** (open-source, spec alpha — YAML tokens + 8 sections markdown). Template fourni dans `.claude/skills/design/template.md`. Lint optionnel : `npx @google/design.md lint DESIGN.md`. **Complémentaire** au plugin Anthropic `frontend-design` (le constructeur) qui lit `DESIGN.md` pour build des composants cohérents. | ✅ |
| `/plan` | Découper UNE phase du PRD en tâches avec critères "Fait quand". Lit `DESIGN.md` si la phase touche à l'UI. Adapte ses questions selon `project_type`. | ✅ |
| `/execute` | Exécuter le plan tâche par tâche, cocher au fur et à mesure. Délègue à `research-delegate` si bloqué par une doc API externe. | ✅ |
| `/validate` | Vérifier que la phase marche pour de vrai (Playwright / n8n / autre / **audit RLS Supabase** si données clients). Jamais "ça devrait marcher". | ✅ |
| `/close` | Clôturer la phase : marque ✅ Terminée dans le PRD + commit conventionnel + harvest learnings + handoff. **Mandatory** après `/validate ✅`. | ✅ |
| `/ship` | Déployer en production selon `project_type` (Vercel / n8n / GitHub Pages) + checklist RLS advisory + smoke test. | à venir v2.0 Phase D |
| `/evolve` | Ajouter une nouvelle feature à un projet shipped : insère Phase N+1 dans PRD existant sans écraser. | à venir v2.0 Phase E |
| `/troubleshoot` | Investiguer un bug : repro → root cause → fix → regression test. | à venir v2.0 Phase F |

**Skills optionnels avancés** :

| Skill | Rôle |
|-------|------|
| `/challenge` | Devil's advocate sur un plan : 3 risques + 3 hypothèses non vérifiées + verdict GO/REWORK/STOP. Systématique en Request Classification FULL. |

**Notes hors table** :
- Tu reviens après une pause ? Tape `/recap` — lit `PRD.md` + `phase-*-plan.md` + git log + `MEMORY.md` et propose la suite. `/start` détecte automatiquement les projets existants et bifurque vers `/recap`.
- Capture rapide d'un learning ? Tape `/remember {topic}` — append-only dans `memory/topics/{topic}.md`. *(à venir v2.0 Phase H)*

Workflow type : `/start` → `/brainstorm`? → `/architect` (PRD + scaffold) → `/design`? → `/plan` Phase 1 → `/execute` → `/validate` → `/close` → `/plan` Phase 2 → ... → `/ship`. Reprise : `/recap`. Évolution : `/evolve`.

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

`examples/freelance-devis/` montre à quoi ressemblent un `PRD.md`, un `phase-1-plan.md`, un `DESIGN.md` et un `CLAUDE.md` produits par la suite des skills sur un projet illustratif (freelance qui automatise ses devis). Ouvre ces fichiers en parallèle de tes propres essais — le format est plus parlant qu'une longue doc.

## Scaffolding outillage

- `.mcp.json` vide prêt à recevoir Playwright, n8n MCP, plugin frontend-design (commandes documentées dans `CLAUDE.md`)
- `.env.example` avec placeholders pour n8n, Anthropic SDK, Supabase, Resend
- `.gitignore` durci sur `.env`, `.env.local`, `.env.*.local`, `.envrc`

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

## Crédits

- **Skills n8n** : [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT, attribution dans `.claude/skills/n8n/LICENSE-czlonkowski`)

## License

[MIT](LICENSE) — Copyright 2026 Brice Gachadoat. Fais-en ce que tu veux.
