# Changelog

> Toutes les versions notables du kit IAPreneurs Claude Code.
> Format inspiré de [Keep a Changelog](https://keepachangelog.com/). Versions [SemVer](https://semver.org/lang/fr/).

## v2.4.0 — 2026-05-18

### Ajouté

- `/livrer` **Étape 3.5 — Domaine custom (advisory, opt-out)** entre Étape 3 (deploy) et Étape 4 (smoke test) :
  - Question d'entrée 3 options : sous-domaine d'un domaine existant / domaine racine fraîchement acheté / garder URL hosting par défaut (skip direct)
  - Registrar-aware : **OVH** (recommandé module Claude Code IAPreneurs), **Gandi**, **Cloudflare**, **Hostinger**, **Autre** (pattern générique)
  - Distinction sous-domaine (CNAME, simple) vs apex (A records, plus complexe — OVH ne supporte pas ALIAS/ANAME)
  - Gotcha OVH "point final obligatoire sur la cible CNAME" explicité
  - Gotcha Cloudflare "Proxy DNS only (nuage gris, pas orange)" explicité (sinon SSL Vercel pète)
  - Mode attente active : `dig +short` poll 30s × max 10 min jusqu'à résolution DNS détectée
  - Mode skip : marquer `⏳ DNS pending` dans `## Production`, smoke test sur fallback hosting
  - SSL Let's Encrypt automatique mentionné (Vercel émet dès propagation DNS)
- `/livrer` Étape 4 (smoke test) : choix URL cible automatique (custom si propagée, fallback sinon) + warning DNS pending
- `/livrer` Étape 5 (## Production) : bloc enrichi en cas de domaine custom (URL prod custom + URL fallback hosting + ligne DNS détaillée registrar/type/target)
- `scripts/validate-kit-v2.sh` : Scénario K (6 checks couvrant Étape 3.5 + Étapes 4/5 adaptées)

### Modifié

- `/livrer` frontmatter `description:` : mention de la nouvelle config domaine custom registrar-aware

### Inchangé (intentionnel)

- Étape 3 (deploy) inchangée — l'Étape 3.5 vient strictement après le deploy réussi
- Routes hosting non-Vercel (Netlify/Cloudflare/GitHub Pages) : flow par défaut intact, le bloc 3.5.3 documente un placeholder "TODO" pour le hosting-side (à remplir au fil des livraisons réelles)
- Pas de breaking change : projets v2.3.0 conservent leur ## Production existant (Cas A reste compatible)

## v2.3.0 — 2026-05-18

### Ajouté

- `/livrer` route Vercel refondue : flow par défaut **GitHub→Vercel auto-deploy** (push = deploy)
- `/livrer` détecte 3 marqueurs d'état (remote github, repo existe sur GitHub, `.vercel/project.json`) pour router automatiquement entre onboarding guidé et fast path push
- `/close` Étape 6.5 conditionnelle : propose gate déploiement (`commit only` / `push main = deploy prod` / `push branche = preview`) si Vercel lié + commits non-pushés + `project_type` ∈ {webapp, site}
- Warning Vercel Hobby = non-commercial affiché **AVANT** tout setup (anti-piège pour prestations clients €1500+)
- `scripts/validate-kit-v2.sh` : Scénario J (9 checks couvrant la nouvelle logique /livrer + /close)

### Modifié

- `/livrer` ne présente plus `vercel --prod` CLI par défaut (conservé en commentaire HTML `<!-- power-users-fallback -->` pour utilisateurs avancés)
- Check auth GitHub via `gh api user` au lieu de `gh auth status` (régression connue sur certaines versions retournant exit 0 même en échec)
- Étape 4 (smoke test) : retry HTTP 60s × 2 si build Vercel pas encore terminé (502/504/404 transient)

### Inchangé (intentionnel)

- Routes Netlify, Cloudflare Pages, GitHub Pages, n8n automation strictement inchangées
- Template `CLAUDE.md`, ancres, 3 examples — aucun breaking change pour projets v2.0.0+

## v2.2.0 — 2026-05-14

### Ajouté (3 modifications structurelles bundle)

**1. n8n MCP opt-in**

- Collection `czlonkowski` bundled retirée (`.claude/skills/n8n/` supprimé)
- Nouveau fichier `.claude/rules/n8n-setup.md` : procédure 5-étapes pour installer le MCP n8n à la demande, lit upstream `github.com/czlonkowski/n8n-mcp/README.md` + embarque le prompt opérationnel (Core Principles, 8-step workflow, validation 4-levels, Top 20 nodes — snapshot 2026-05-14)
- `/start` Étape 3 : nouvelle Q4 booléenne `project_uses_n8n`. Si oui → exécute `n8n-setup.md`. Si non → skip entièrement.
- Placeholder `<!-- n8n-section -->` dans CLAUDE.md template, décommenté par n8n-setup.md à l'install.

**2. Structure projet pour évolutions (PRD vivant discipliné)**

- **PRD 8 sections** (Vision / Personas / Scope actuel V_n / Hors scope / Constraints / Success Criteria / Implementation Phases / Risks & Mitigations) cap 100 lignes. Templates dans `templates/PRD-template.md` + `templates/SPEC-template.md`.
- **`docs/specs/SPEC-{date}-{slug}.md`** : un SPEC par évolution post-livraison. Format 4 sections (Feature / Examples / Documentation / Considerations). Frozen post-/execute via header `<!-- frozen: {date} -->`.
- **`memory/decisions.md` format ADR numéroté** : ADR-NNN avec Status / Date / Context / Decision / Consequences. `/architect` init ADR-001 fondateur. `/evoluer` append ADR à chaque choix architectural significatif.
- **`/evoluer` cérémonie distincte** : lit PRD + STRUCTURE + decisions + 3 derniers SPECs + STATUS. Crée SPEC daté + déplace checkbox Hors scope → Scope actuel + append Implementation Phases V_n+1 + gate `/validate` obligatoire AVANT handoff. Atomicité git via checkpoint après création SPEC.
- **`/prime` adaptatif maintenance/création** : Étape 0.5 détecte `mode` via `count(docs/specs/SPEC-*.md)`. Maintenance → lit aussi decisions + 3 derniers SPECs. Affiche le mode dans la synthèse Étape 5.
- **`/close` Étape 0.6 audit caps** : warn (pas bloquer) si CLAUDE.md > 200L ou PRD.md > 100L. Acknowledged flag `.claude/cache/close-cap-acknowledged.json` anti-spam re-prompt.
- **`/architect` Étape DISCOVER + ANALYZE** (pattern DISCOVER+ANALYZE) : si codebase non-vide, scan stack/patterns existants et enrichit `<!-- architect:stack -->` + `<!-- architect:patterns -->`.
- **STRUCTURE.md +3 ancres** : `<!-- structure:integrations -->`, `<!-- structure:key-files -->`, `<!-- structure:evolutions-summary -->` (maintenues par /architect + /evoluer).
- **`/plan` Étape 4.5 option G/W/T** : si Request Classification ≥ STANDARD ET project_type == webapp, propose user stories Given/When/Then en plus des tâches techniques.
- **`/execute` Étape 2 Golden rule** : validation post-task obligatoire (PAS batched), formalisée comme règle stricte.

**3. Vidéos pédagogie**

- Sommaire IAPreneurs v5 et plan Hub Documents séquencés pour défer n8n à 5.2 et intégrer `/design` dans 5.1 (modification externe, hors repo kit).

### Modifié (layout)

- `examples/webapp-saas-freelance-devis/phase-1-plan.md` → `docs/plans/phase-1-plan.md` (correction incohérence convention `docs/plans/` v2.1.0).
- Les 3 PRD examples migrés au nouveau format 8 sections (cap 100L).
- Nouveau SPEC simulé `examples/webapp-saas-freelance-devis/docs/specs/SPEC-2026-08-12-export-pdf-devis.md` (montre le pattern évolution post-livraison).

### Breaking change

- **Format PRD 7 → 8 sections** : ancien `## Phases` remplacé par `## 7. Implementation Phases` + ajout `## 3. Scope actuel (V_n)` + `## 4. Hors scope (différé)`.
- **Mitigation** : adaptateur format legacy v2.1.x dans `/evoluer` + `/prime` + `/close` (4 branches déterministes : nouveau / ancien / mixte (safe abort) / malformé (safe abort)).
- **Migration guide** : voir `docs/MIGRATION-v2.1-to-v2.2.md` (~30 lignes).

### Nouveaux fichiers

- `templates/PRD-template.md` (8 sections)
- `templates/SPEC-template.md` (4 sections)
- `.claude/rules/n8n-setup.md` (procédure install à la demande + prompt opérationnel czlonkowski embarqué)
- `docs/MIGRATION-v2.1-to-v2.2.md` (guide migration format PRD)

### Validation

- `scripts/validate-kit-v2.sh` Scénario I ajouté (~17 nouveaux checks). Total ≥ 90 checks.

---

## v2.1.0 — 2026-05-13

### Renommé
- L'ancien skill *recap* (v2.0.x) est devenu `/prime` (description élargie : rituel d'entrée de session, pas seulement post-absence)

### Ajouté
- **`STRUCTURE.md`** : carte d'architecture du projet, écrite par `/architect` Étape 6.5, lue par `/prime`. Adaptée selon `project_type` (webapp/site/automation). 4 ancres : `<!-- architect:directories -->`, `<!-- architect:patterns -->`, `<!-- architect:tests -->`, `<!-- architect:conventions -->`.
- **`/architect` Étape 6.5** : génération STRUCTURE.md initial après scaffold, avec templates par `project_type`.
- **`/prime` Étape 1.5** : lecture STRUCTURE.md si présent (mode dégradé sinon) + section "Architecture" dans la synthèse Étape 5.
- **STRUCTURE.md dans les 3 examples** du kit (`site-vitrine-coach`, `webapp-saas-freelance-devis`, `automation-n8n-veille-rss`).
- **Vocabulaire "boucle interne / boucle externe"** dans CLAUDE.md règle 6 et `/close` SKILL.md. Boucle interne = PIV (`/prime → /plan → /execute → /validate → /close`) sur une feature. Boucle externe = corriger le système qui a laissé passer un bug (règle, étape de skill, assertion validate-kit).
- **Rituel PIV explicite** (`/prime → /plan → /execute → /validate → /close`) dans CLAUDE.md, mis en évidence en haut du template.
- **Convention `docs/{type}/`** : les outputs des skills (plans, brainstorms) vivent désormais dans `docs/plans/` et `docs/brainstorms/` au lieu de la racine. Documentation dans la nouvelle section `## Où vivent les fichiers` de CLAUDE.md.

### Modifié (layout)
- `/plan` écrit `docs/plans/phase-N-plan.md` (au lieu de racine), avec `mkdir -p docs/plans` au début.
- `/brainstorm` écrit `docs/brainstorms/{YYYY-MM-DD}-{sujet}.md` (au lieu de `brainstorm-{sujet}.md` racine), avec `mkdir -p docs/brainstorms` au début. Préfixe date pour tri chronologique.
- `/prime`, `/execute`, `/validate`, `/challenge`, `/evoluer`, `/close`, `/start` lisent depuis `docs/plans/` avec **fallback compatibilité** vers `plans/` puis racine (projets pré-v2.1.0 continuent à marcher).

### Validation
- **Scénarios D/E/F/G** ajoutés à `scripts/validate-kit-v2.sh` (>= 55 checks total au lieu de 44). Scénario D mis à jour (prime au lieu de recap), Scénario E = STRUCTURE.md, Scénario F = BONUS pédagogiques (vocab + PIV + anti-leak D9), Scénario G = docs/{type}/ layout.

### Migration depuis v2.0.0
Aucune action utilisateur requise pour projets pré-v2.1.0 :
- L'ancien skill *recap* est renommé en `/prime` — anciens projets continuent à fonctionner, juste taper `/prime` au lieu de l'ancien nom.
- `STRUCTURE.md` est optionnel — `/prime` fonctionne en mode dégradé sans (juste pas de section "Architecture" dans la synthèse).
- Plans existants à la racine ou dans `plans/` continuent d'être lus (fallback). Pour une organisation propre, déplacer manuellement vers `docs/plans/` (ou laisser tel quel — pas bloquant).

---

## [v2.0.0] — 2026-05-12

> **Statut** : GA — validation script-driven `scripts/validate-kit-v2.sh` = 44/44 PASS. Voir `docs/VALIDATION-SCENARIOS-V2.md`.

> **Refonte majeure** : passage d'un squelette spec-driven web-app-centric à un **framework guidé complet** couvrant tout le cycle de vie d'un projet pour **3 cas d'usage** (site / webapp / automation).

### Breaking changes

- Nouvelle variable `project_type` ∈ `{site, webapp, automation}` requise dans `<!-- start:identité -->` du `CLAUDE.md` template. Forks v1.x sont migrés automatiquement par `/start` (question one-shot, pas de cascade-block).
- `/close` n'est plus optionnel — devient **mandatory** post `/validate ✅`. La source unique pour marquer ✅ Terminée dans le PRD passe de `/execute` à `/close` (résout doublon).
- Nouvelles ancres HTML dans `CLAUDE.md` template : `<!-- design:summary -->` (écrit par `/design`) et `<!-- ship:url -->` (écrit par `/ship`).

### Ajouté

- **3 nouveaux skills (noms FR pour cohérence communauté IAPreneurs)** :
  - `/prime` — reprendre un projet existant après absence (lit PRD/plans/git log)
  - `/livrer` — déployer en production en lisant `## Stack` du CLAUDE.md (jamais hardcode de provider — Vercel/Netlify/Cloudflare/GitHub Pages/autre détectés depuis stack) + checklist policy d'accès BDD advisory + smoke test
  - `/evoluer` — ajouter une feature à un projet livré sans écraser le PRD

**Skills envisagés puis droppés** (décision D26 mid-execute, "less is more") :
- `/troubleshoot` → remplacé par `/debug` (built-in Claude Code natif) + règle de comportement TDD dans CLAUDE.md (test de régression avant fix)
- `/remember` → remplacé par édition manuelle de `memory/topics/{topic}.md` (skill trop léger pour mériter un slot)
- **Mémoire persistante** : structure `memory/{learnings,topics}/` + `memory/decisions.md` + `MEMORY.md` index à la racine. Le kit apprend du projet au fil des sessions. **Tout est écrit par `/close`** post-commit (auto-récap session dans `learnings/` + 3 questions ciblées opt-in : décision arch ? gotcha ? pattern ? → écrit dans `topics/{domaine}.md` ou `decisions.md`). `/start` et `/prime` lisent `MEMORY.md` au démarrage et affichent le résumé. **L'utilisateur ne touche jamais à la mémoire manuellement.**
- **3 examples par `project_type`** : `examples/site-vitrine-coach/`, `examples/webapp-saas-freelance-devis/`, `examples/automation-n8n-veille-rss/`.
- **Request Classification LITE / STANDARD / FULL** dans `CLAUDE.md` template (proposée par `/start` Phase 4).
- **Règle de comportement #6 — Auto-évaluation** dans CLAUDE.md template : tu ne dis jamais "done" sans avoir vérifié programmatiquement ou visuellement. Pour webapp + modif UI → Playwright MCP (navigate + snapshot/screenshot dans `tmp/`). Pour automation + workflow → exécution réelle via MCP. Pour API → curl. Pour BDD → query directe. Si tu ne peux pas raconter exactement ce que tu as vérifié, tu n'as pas auto-évalué.
- **Dossier `tmp/`** (gitignored sauf `.gitkeep`) créé par défaut dans le kit : destination des screenshots Playwright, dumps debug, outputs intermédiaires. Skills `/validate` et `/livrer` y enregistrent leurs artefacts temporaires.
- **Glossaire** (4 termes : Phase / Tâche / Critère "Fait quand" / Critères de succès) en intro du `CLAUDE.md` template.
- **README enrichi** : 3 diagrammes de parcours (création / reprise / évolution) + table 12 skills (hard cap) + section "Quel example regarder ?".
- **`docs/CHANGELOG.md`** : ce fichier (historique rétroactif v1.0 → v2.0).

### Modifié

- `/start` détecte projet existant et bifurque vers `/prime` (au lieu de toujours faire l'onboarding). Migration v1.x → v2.0 transparente.
- `/architect` étendu avec **Étape 6 — Provisioning & Scaffold** (scaffold le repo selon `project_type` + provisioning Supabase/Vercel/n8n + écriture `.env`). Décision D25 : fold de l'ancien `/scaffold` envisagé puis dropped — `architect` définit le projet end-to-end, scaffolding est Phase 1 du PRD donc redondant comme skill séparé. Handoff route vers `/design` (si webapp) puis `/plan Phase 1`.
- `/architect` route aussi vers `/evolve` pour modifications de PRD existant.
- `/validate` handoff → `/close` (mandatory), plus de skip optionnel.
- `/close` enrichi : harvest learnings post-commit + handoff vers `/ship` si projet jamais shippé.
- `/plan` adapte ses questions selon `project_type` (automation = retire web-app-centric, ajoute credentials externes).
- `/execute` ne marque plus ✅ Terminée dans PRD (responsabilité déplacée à `/close`).

### Retiré

- Mentions de **Dipler** dans le kit public (règle IAPreneurs : voice agents = **Vapi** dans la communauté, jamais Dipler).

### Méthode

- Plan : `plans/iapreneurs-kit-framework-guide-refonte.md` (8 phases A-H, 24 décisions arch, 4 rounds challenge, trajectoire BLOCKING 6→5→2→0)
- Recherche : `research/plan/2026-05-12-iapreneurs-kit-framework-guide-refonte.md` (3 agents : audit interne / scout externe / critique pédagogique)

---

## [v1.5.0] — 2026-05-12

### Ajouté
- `/close` skill : marque ✅ Terminée dans PRD + commit conventionnel + suggestion phase suivante
- Audit RLS Supabase intégré dans `/validate` (option D) pour projets avec données clients
- Propagation de la section `## Stack` du `CLAUDE.md` après `/architect`
- Examples enrichis : `examples/freelance-devis/CLAUDE.md`

### Modifié
- Documentation README alignée sur l'inventaire complet v1.5

---

## [v1.4.0] — 2026-05-08

### Modifié — Breaking
- `/design` skill aligné sur la **spec officielle Google open-source** `DESIGN.md` (version alpha, publiée par Stitch — `stitch.withgoogle.com`)
- Format YAML front matter avec tokens (`colors`, `typography`, `rounded`, `spacing`, `components`) + 8 sections markdown canoniques
- Lint optionnel : `npx @google/design.md lint DESIGN.md`
- Template fourni dans `.claude/skills/design/template.md`

---

## [v1.3.0] — 2026-04-30

### Ajouté
- `/design` skill — produit `DESIGN.md` consommé par le plugin Anthropic `frontend-design`
- Division du travail clarifiée : `/design` = architecte (système 1x), `/frontend-design` = constructeur (composants à chaque création UI)

---

## [v1.2.0] — 2026-04-20

### Modifié — Breaking
- Rename `/create-prd` → `/architect` (produit toujours `PRD.md`, plus clair sémantiquement)

---

## [v1.1.0] — 2026-04-10

### Ajouté
- `/start` onboarding skill (5 phases : visite + cadrage + credentials + outillage + routage)
- Sécurité credentials : `.env` pattern Anthropic-officiel + `.mcp.json` avec syntaxe `${VAR}`
- `.gitignore` durci sur `.env`, `.env.local`, `.env.*.local`, `.envrc`
- Path-scoped rules `.claude/rules/` avec frontmatter `paths:` + exemple `frontend.md`
- Sous-agent `research-delegate` (read-only) invoqué automatiquement par `/brainstorm`, `/plan`, `/execute`, `/validate`
- `/challenge` skill (devil's advocate optionnel)

---

## [v1.0.0] — 2026-04-01

### Ajouté
- 5 skills core conversationnels : `/brainstorm`, `/create-prd` (renommé en `/architect` v1.2), `/plan`, `/execute`, `/validate`
- 7 skills officiels [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT) dans `.claude/skills/n8n/`
- Template `CLAUDE.md` 5 couches (Identité / Stack / Conventions / Instructions / Contexte métier) + 4 règles de comportement + ancres HTML
- `.mcp.json` scaffolding (Playwright, n8n, plugin frontend-design)
- `.env.example` avec placeholders pour n8n, Anthropic SDK, Supabase, Resend
- LICENSE MIT
- README initial avec quickstart

[v2.0.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/compare/v1.5.0...HEAD
[v1.5.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.5.0
[v1.4.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.4.0
[v1.3.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.3.0
[v1.2.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.2.0
[v1.1.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.1.0
[v1.0.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.0.0
