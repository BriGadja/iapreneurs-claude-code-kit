# Exemples

Trois exemples remplis, un par `project_type`. Le kit s'adapte à ton cas — ces exemples sont là pour te montrer **le format attendu**, pas pour t'imposer une stack.

> 📖 **Tu veux voir une session réelle de A à Z ?** Lis [`webapp-saas-freelance-devis/SESSION.md`](webapp-saas-freelance-devis/SESSION.md) — tuto narratif avec les commandes tapées + sorties LLM abrégées, du `claude` initial à la mise en prod en 3h20 cumulées sur 2 jours. Le format est plus parlant qu'une doc abstraite.

## Comparaison rapide

| Exemple | `project_type` | Niveau Request Classification | Stack | Complexité | Skills utilisés |
|---------|---------------|------------------------------|-------|------------|-----------------|
| [`site-vitrine-coach/`](site-vitrine-coach/) | `site` | **LITE** (PRD 3 sections, 1 phase) | Next.js + Vercel + Resend | ⭐ | `/start` `/architect` `/plan` `/execute` `/validate` `/close` `/livrer` |
| [`webapp-saas-freelance-devis/`](webapp-saas-freelance-devis/) | `webapp` | **STANDARD** (PRD complet, 4 phases) | Next.js + Supabase + n8n + Resend + Vercel | ⭐⭐⭐ | tous + `/design` (DESIGN.md inclus) |
| [`automation-n8n-veille-rss/`](automation-n8n-veille-rss/) | `automation` | **STANDARD** (PRD complet, 2 phases) | n8n + Supabase + Anthropic Haiku + Slack | ⭐⭐ | tous sauf `/design` (pas d'UI) |

## Quel exemple regarder selon ton projet ?

- **Tu veux faire un site web simple** (présence en ligne, 1-5 pages, formulaire contact) → `site-vitrine-coach/`. Tu verras qu'on **skip `/design`**, qu'on choisit le niveau **LITE** pour aller vite, et que le PRD tient en 3 sections.
- **Tu veux faire une app web SaaS** (auth + BDD + utilisateurs) → `webapp-saas-freelance-devis/`. C'est l'exemple le plus riche : tu verras `DESIGN.md` rempli (palette + 9 composants), `phase-1-plan.md` avec 5 tâches détaillées, et le PRD complet 7 sections.
- **Tu veux faire une automatisation** (workflow déclenché, pas d'UI) → `automation-n8n-veille-rss/`. Tu verras qu'on **skip `/design`**, que le PRD met l'accent sur les **credentials externes** et l'**idempotence**, et qu'un squelette de workflow JSON est fourni à titre pédagogique.

## Format commun à tous les exemples

Chaque dossier contient au minimum :

| Fichier | Produit par | À quoi ça sert |
|---------|-------------|---------------|
| `CLAUDE.md` | `/start` + `/architect` + manuel | Identité + Stack + Request Classification + Conventions/Instructions/Contexte métier |
| `PRD.md` | `/architect` | Sommaire + Utilisateurs + MVP + Hors-MVP + Phases + Stack + Critères de succès |
| `phase-N-plan.md` | `/plan` | *(webapp uniquement)* Plan détaillé d'une phase avec critères "Fait quand" |
| `DESIGN.md` | `/design` | *(webapp uniquement)* Design system Google `design.md` (YAML tokens + 8 sections) |
| `*.workflow.json` | manuel via n8n UI | *(automation uniquement)* Squelette du workflow n8n |

Ouvre ces fichiers en parallèle de tes propres essais — le format est plus parlant qu'une longue doc.

> Note : ces projets sont illustratifs. Tu n'as **pas** à reproduire ces projets ni à utiliser la même stack. Le kit s'adapte à ton cas via `project_type` et les providers favoris que tu déclares dans `/architect`.
