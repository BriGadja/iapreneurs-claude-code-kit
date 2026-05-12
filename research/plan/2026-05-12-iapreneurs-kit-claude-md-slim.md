---
topic: Slimmer CLAUDE.md du kit IAPreneurs (405 → ~150 lignes) — redistribution méta-doc vers docs/skills/rules
created: 2026-05-12
agents: [codebase-scout (dependency mapping)]
plan: plans/iapreneurs-kit-claude-md-slim.md
---

## Research Findings

### Codebase scout — dépendances skill → CLAUDE.md

**Ancres HTML (write-targets pour les skills)** :

| Ancre | Écrite par | Lue par |
|-------|-----------|---------|
| `<!-- start:identité -->` | `/start` | `/recap`, `/livrer`, `/design`, `/plan`, `/architect`, `/evoluer` |
| `<!-- architect:stack -->` | `/architect` | `/livrer`, `/design`, `/plan` |
| `<!-- design:summary -->` | `/design` | (display only) |
| `<!-- ship:url -->` | `/livrer` | `/recap`, `/evoluer` |
| `<!-- close:topics-index -->` (dans MEMORY.md, pas CLAUDE.md) | `/close` | `/start` |
| `<!-- close:learnings-index -->` (dans MEMORY.md) | `/close` | `/start` |

**Variable `project_type`** : critique. Lue par 6+ skills (`/architect` Étape 6, `/design`, `/plan` Étape 1.1, `/execute`, `/livrer` Étape 1 stoppe si absent, `/evoluer`).

**Sections de CLAUDE.md programmatiquement lues** (à PRÉSERVER) :
- `## Identité` + `project_type:` — 6+ skills
- `## Stack` (anchor `<!-- architect:stack -->`) — `/livrer`, `/design`, `/plan`
- `## Production` (anchor `<!-- ship:url -->`) — `/recap`, `/evoluer`
- `## Design system` (anchor `<!-- design:summary -->`) — `/design` écrit, display ailleurs

**Sections display-only (jamais lues par skills)** — candidates au déménagement :
- `## Conventions`, `## Instructions`, `## Contexte métier` — display, USER content (mais KEEP : user les édite directement)
- `## Sécurité des credentials` (20 lignes) — règle, contenu dupliqué dans `/start`
- `## MCP & plugin à installer` (28 lignes) — doc install, dupliqué dans `/start`
- `## Règles de comportement` (70 lignes) — directives Karpathy, AFFICHÉ à chaque session
- `## Request Classification` (12 lignes) — explication, écrit par `/architect`
- `## Mémoire persistante` (29 lignes) — explique système `/close`
- `## Comment ce CLAUDE.md est entretenu` (70 lignes) — méta-doc : 3 parcours typiques + table qui-écrit-quoi + "déporter vers rules"
- `## Skills disponibles dans ce kit` (35 lignes) — table 10+1 skills + notes
- `## Sous-agent` (5 lignes) — doc research-delegate
- `## Création UI (si web app)` (14 lignes) — règle `/design` vs `/frontend-design`

**Score** : ~200 lignes (50%) sont de la méta-doc sur le kit lui-même (jamais lues programmatiquement, juste affichées au user à chaque session).

### Synthèse pour le plan

**Cible** : ~150 lignes CLAUDE.md.

**Stratégie de redistribution** :
1. **Méta-doc kit** (parcours, table skills, sous-agent, MCP install) → `docs/KIT.md` (un fichier de référence unique, linké depuis CLAUDE.md + README.md)
2. **Section `Création UI`** → corps de `/design` SKILL.md (c'est sa règle)
3. **Section `Mémoire persistante` deep-dive** → `memory/README.md` (5 lignes résumé restent dans CLAUDE.md)
4. **Section `Request Classification` deep-dive** → `/architect` SKILL.md Étape 3.1 (déjà décrite là-bas) + 4 lignes résumé dans CLAUDE.md
5. **Sections `Sécurité credentials` + `MCP install`** → résumer 3 lignes pointant vers /start (qui contient le détail)
6. **Règles de comportement** : condenser de 70 → ~45 lignes (drop les exemples-table massifs, garder l'essentiel)

**Critère absolu** : ZÉRO ancre HTML supprimée, ZÉRO section programmatiquement-lue supprimée.

**Risque #1** : casser `/start`, `/architect`, `/livrer`, `/recap`, `/evoluer`, `/design`, `/plan` qui lisent des sections/ancres précises.
**Mitigation** : audit dépendances fait (voir tableau ci-dessus). Préservation explicite listée dans Phase A.

**Risque #2** : créer trop de fichiers de doc (anti-pattern "less is more").
**Mitigation** : UN SEUL nouveau fichier (`docs/KIT.md`). Pas de prolifération.

**Risque #3** : casser l'expérience débutant si l'utilisateur cherche la doc dans CLAUDE.md.
**Mitigation** : footer CLAUDE.md = 1 ligne "Pour comprendre le kit, voir `docs/KIT.md`". README.md déjà existant a la table skills.
