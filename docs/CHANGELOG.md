# Changelog

> Toutes les versions notables du kit IAPreneurs Claude Code.
> Format inspiré de [Keep a Changelog](https://keepachangelog.com/). Versions [SemVer](https://semver.org/lang/fr/).

## [v2.0.0] — En cours

> **Refonte majeure** : passage d'un squelette spec-driven web-app-centric à un **framework guidé complet** couvrant tout le cycle de vie d'un projet pour **3 cas d'usage** (site / webapp / automation).

### Breaking changes

- Nouvelle variable `project_type` ∈ `{site, webapp, automation}` requise dans `<!-- start:identité -->` du `CLAUDE.md` template. Forks v1.x sont migrés automatiquement par `/start` (question one-shot, pas de cascade-block).
- `/close` n'est plus optionnel — devient **mandatory** post `/validate ✅`. La source unique pour marquer ✅ Terminée dans le PRD passe de `/execute` à `/close` (résout doublon).
- Nouvelles ancres HTML dans `CLAUDE.md` template : `<!-- design:summary -->` (écrit par `/design`) et `<!-- ship:url -->` (écrit par `/ship`).

### Ajouté

- **3 nouveaux skills (noms FR pour cohérence communauté IAPreneurs)** :
  - `/recap` — reprendre un projet existant après absence (lit PRD/plans/git log)
  - `/livrer` — déployer en production en lisant `## Stack` du CLAUDE.md (jamais hardcode de provider — Vercel/Netlify/Cloudflare/GitHub Pages/autre détectés depuis stack) + checklist policy d'accès BDD advisory + smoke test
  - `/evoluer` — ajouter une feature à un projet livré sans écraser le PRD

**Skills envisagés puis droppés** (décision D26 mid-execute, "less is more") :
- `/troubleshoot` → remplacé par `/debug` (built-in Claude Code natif) + règle de comportement TDD dans CLAUDE.md (test de régression avant fix)
- `/remember` → remplacé par édition manuelle de `memory/topics/{topic}.md` (skill trop léger pour mériter un slot)
- **Mémoire persistante** : structure `memory/{learnings,topics}/` + `memory/decisions.md` + `MEMORY.md` index à la racine. Le kit apprend du projet au fil des sessions. Écriture par `/close` (harvest learnings post-commit) + édition manuelle directe (pas de skill `/remember` dédié — édition `memory/topics/{topic}.md` à la main).
- **3 examples par `project_type`** : `examples/site-vitrine-coach/`, `examples/webapp-saas-freelance-devis/`, `examples/automation-n8n-veille-rss/`.
- **Request Classification LITE / STANDARD / FULL** dans `CLAUDE.md` template (proposée par `/start` Phase 4).
- **Glossaire** (4 termes : Phase / Tâche / Critère "Fait quand" / Critères de succès) en intro du `CLAUDE.md` template.
- **README enrichi** : 3 diagrammes de parcours (création / reprise / évolution) + table 12 skills (hard cap) + section "Quel example regarder ?".
- **`docs/CHANGELOG.md`** : ce fichier (historique rétroactif v1.0 → v2.0).

### Modifié

- `/start` détecte projet existant et bifurque vers `/recap` (au lieu de toujours faire l'onboarding). Migration v1.x → v2.0 transparente.
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
