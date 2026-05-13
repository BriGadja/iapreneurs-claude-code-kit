---
name: design
description: Utiliser pour définir le design system d'une app web AVANT /plan Phase 1, au format DESIGN.md officiel Google (open-source, spec alpha). Produit un fichier `DESIGN.md` à la racine du projet avec YAML front matter (tokens machine-readable) + 8 sections markdown (prose human-readable). Lu par le plugin `frontend-design` et par tout LLM qui touche à l'UI. Ne PAS utiliser pour un projet sans UI (script CLI, automation n8n pure). Ne PAS utiliser sans PRD validé — `/architect` d'abord.
---

# Skill /design — produire un DESIGN.md (spec Google) avant le build UI

## Pour quoi faire

Une fois le PRD validé (`/architect`), si ton projet a une UI web, définir le **design system** au format **DESIGN.md officiel Google** (spec open-source `version: alpha`, publiée par l'équipe Stitch). Sortie : un fichier `DESIGN.md` à la racine du projet.

Le format Google combine :
- **YAML front matter** = tokens machine-readable (`colors`, `typography`, `rounded`, `spacing`, `components`) consommables par n'importe quel LLM ou outil via la syntaxe `{token.reference}`
- **Sections markdown** = prose human-readable qui explique le pourquoi (atmosphère, rôles sémantiques, do's/don'ts)

Le plugin `frontend-design` d'Anthropic, comme tout LLM qui code de l'UI, lit ce fichier pour rester cohérent d'une page à l'autre.

> **Tooling officiel** : Google publie un linter `npx @google/design.md lint DESIGN.md` qui valide la structure, détecte les références de tokens cassées, et vérifie les contrastes WCAG AA automatiquement.

## Quand l'invoquer dans le workflow

```
/start → /brainstorm? → /architect → /design (si web app) → /plan Phase 1 → ...
```

`/architect` te suggérera `/design` à la fin de son handoff si la stack inclut une UI web (Next.js, React, Vue, etc.). Si pas d'UI → skip et passe direct à `/plan`.

## Comment procéder

### Étape 1 — Vérifier les prérequis

1. Lire `CLAUDE.md` section `## Stack`. Si pas de framework UI (Next.js, React, Vue, Svelte, ...) → annonce "Ton projet n'a pas d'UI web, `DESIGN.md` n'est pas pertinent. Passe direct à `/plan` Phase 1." et stoppe.
2. Vérifier que le plugin `frontend-design` est installé : `claude plugin list` (cherche `frontend-design@claude-code-plugins`). Si absent → propose `claude plugin install frontend-design@claude-code-plugins` et attends confirmation. Tu peux continuer sans — `DESIGN.md` est utile même sans le plugin.
3. Lire `.claude/skills/design/template.md` — c'est le template officiel Google que tu vas remplir, **pas réinventer**. Tu modifies les valeurs des tokens et le contenu de la prose, jamais la structure des sections.

### Étape 2 — Brand existante ou from scratch ?

> "Tu pars d'une **brand existante** (couleurs/typo/ton déjà définis ailleurs) ou tu démarres **from scratch** ?"

**Si existante** → Étape 3a. **Si from scratch** → Étape 3b.

### Étape 3a — Récupérer la brand existante (4 questions)

Pose les 4 questions, une par une :

1. **Palette** : "Donne-moi tes couleurs : primary, surface/canvas, et l'idée des neutrals (clair/sombre). Format `#RRGGBB`."
2. **Typographie** : "Display (titres) et body (texte courant) ? Si Google Fonts, le nom suffit. Sinon, system-safe (`Inter`, `Georgia`, ...)."
3. **Ton & voix** : "En 2-3 mots, le ton de ta marque : pro/chaleureux/tech/luxe/punk/etc. À qui tu parles ?"
4. **Refs visuelles** : "Des sites/apps proches de ce que tu veux ? (optionnel, 1-3 URLs)"

Passe à l'étape 4 avec les réponses.

### Étape 3b — Proposer 3 directions (from scratch)

À partir du contexte (lis le PRD, section "Utilisateurs cibles" + "Sommaire"), propose **3 directions** distinctes :

> "Voilà 3 directions cohérentes avec ton projet. Choisis ou demande une variante.
>
> **A — Minimal & éditorial** (tech B2B, productivity, SaaS sérieux)
> - Palette : ink `#141413` sur canvas `#FFFFFF`, primary `#3B82F6` (bleu), neutrals slate cool
> - Typo : Inter (display + body), JetBrains Mono (code)
> - Ton : direct, factuel, "outil pro pour gens occupés"
>
> **B — Chaleureux & humaniste** (services, coaching, consulting, freelance)
> - Palette : ink `#1A1A1A` sur canvas `#FAF9F5` (warm white), primary `#CC785C` (terracotta/coral), surface-card crème `#EFE9DE`, neutrals stone
> - Typo : Fraunces ou Source Serif (display), Inter (body)
> - Ton : conversationnel, premier degré, "expert qui te tutoie"
>
> **C — Moderne & vibrant** (creator economy, SaaS jeune, audience millennial)
> - Palette : ink `#0A0A0A` sur canvas `#FFFFFF`, primary `#7C3AED` (purple) ou `#10B981` (emerald), accent vibrant
> - Typo : Geist Sans (display + body), Geist Mono
> - Ton : punchy, second degré assumé, "on est ici pour casser des codes"
>
> Tu choisis A, B, C, ou une variante ?"

Itère jusqu'à validation.

### Étape 4 — Affiner les composants clés (2 questions)

1. **Border radius général** : "Bords carrés (`0`), légèrement arrondis (`{rounded.md}` = 8px, default), bien arrondis (`{rounded.lg}` = 12px) ou pill (`{rounded.pill}` pour les badges) ?"
2. **Densité** : "Interface dense (dashboard pro, data-heavy) ou aérée (marketing/landing, beaucoup d'espace) ?"

Inférer les composants à partir des choix + de la direction.

### Étape 5 — Composer le DESIGN.md à partir du template

1. Lire `.claude/skills/design/template.md`.
2. Remplir le YAML front matter :
   - `name` : nom du projet (lu dans `CLAUDE.md ## Identité`)
   - `description` : 2-4 phrases sur la voix visuelle (depuis Q2-Q3 ou la direction choisie)
   - `colors` : ~15-20 tokens (primary + variants, ink/body/muted, surfaces, semantic) — adapter au choix utilisateur
   - `typography` : garder l'échelle template (display-xl à caption + code + button + nav-link) en ajustant les `fontFamily` au choix
   - `rounded`, `spacing` : garder le template, ajuster `rounded` si choix non-default
   - `components` : 6-10 composants clés (button-primary, button-secondary, button-ghost, text-input, card, badge-pill, toast-success, toast-error). Pas plus pour la v1.
3. Remplir les 8 sections prose canoniques :
   - **Overview** : 1 paragraphe atmosphère + intention
   - **Colors** : explique les rôles sémantiques (primary, surfaces, ink vs body vs muted, semantic). Pas re-lister les hex.
   - **Typography** : hiérarchie d'usage (quand display, quand title, quand body)
   - **Layout** : container max-width, grid, breakpoints
   - **Elevation & Depth** : niveaux shadow + transitions hover
   - **Shapes** : règles de border radius cohérents
   - **Components** : patterns d'usage en prose
   - **Do's and Don'ts** : 4-6 do, 4-6 don't
4. Sections optionnelles : **Responsive Behavior**, **Iteration Guide**, **Known Gaps** — à inclure uniquement si pertinent.

Affiche le DESIGN.md entier dans le chat, demande validation **avant** de sauvegarder.

> "Voilà le DESIGN.md que je propose. Tu valides ou tu veux ajuster un truc ?"

Itère jusqu'à OK. Puis sauvegarde à la racine.

### Étape 6 (optionnel) — Lint avec le CLI officiel Google

Propose à l'utilisateur :

> "Tu veux que je lance le linter officiel Google pour vérifier la structure, les références de tokens et les contrastes WCAG AA ?
>
> ```bash
> npx @google/design.md lint DESIGN.md
> ```
>
> Si il sort des warnings, on les fixe avant `/plan`."

Si oui, lance la commande, lis la sortie, propose des corrections si erreurs. Si non, skip.

## Format de sortie : spec officielle Google

Le `DESIGN.md` produit suit la spec **Google DESIGN.md** (`version: alpha`, open-source par Stitch — `https://stitch.withgoogle.com/docs/design-md/overview/`).

**Structure** :
- YAML front matter : `version`, `name`, `description`, `colors`, `typography`, `rounded`, `spacing`, `components`
- 8 sections markdown canoniques : Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts
- 3 sections optionnelles : Responsive Behavior, Iteration Guide, Known Gaps

**Token references** : `{colors.primary}`, `{typography.body-md}`, `{rounded.md}`, `{spacing.lg}` — cross-référencent les tokens du front matter dans les composants.

Voir `.claude/skills/design/template.md` pour la version complète avec valeurs de référence.

## `/design` vs `/frontend-design` — division du travail

Les deux skills se **complètent**, ils ne se remplacent pas.

| | `/design` (ce skill, dans le kit) | `/frontend-design` (plugin Anthropic) |
|---|---|---|
| **Quand** | 1 fois après `/architect`, avant `/plan` | À chaque création de composant/page |
| **Rôle** | Architecte — définit le **système** (palette, typo, tokens, composants) | Constructeur — **build** des composants en code |
| **Sortie** | 1 fichier `DESIGN.md` (spec Google) | Code TSX prêt à l'emploi |
| **Auto-trigger** | Non (invoqué explicitement par toi) | Oui (Claude l'invoque auto sur tout frontend work) |
| **Input** | Tes réponses + PRD | `DESIGN.md` + ton brief |

**Analogie** : `/design` dessine les plans (palette, typo, échelle d'espacement). `/frontend-design` monte les murs en suivant les plans. Les deux sont nécessaires pour une app cohérente.

### Comment `/frontend-design` consomme `DESIGN.md`

Le plugin ne lit pas automatiquement `DESIGN.md` — c'est à toi de le référencer. Mais Claude Code lit le `CLAUDE.md` qui contient (depuis le template) l'instruction *"Pour toute création UI, lire `DESIGN.md` d'abord"*. Donc en pratique, dès que tu demandes "construis une page X" dans une session, Claude lit `DESIGN.md` puis le passe au plugin pour qu'il construise dans le style défini.

Tu peux aussi le référencer explicitement : *"Construis une page de login en respectant `DESIGN.md`."*

### Pourquoi le format Google et pas un format maison

Le format Google **est conçu pour être consommé par n'importe quel LLM** — pas seulement le plugin Anthropic. Si tu changes de tooling demain (Cursor, Cline, v0, autre), ton `DESIGN.md` reste utilisable tel quel. C'est un investissement portable.

## Risque #1 — proposer une palette générique

Si tu choisis Direction A par défaut sans regarder le PRD, tu fais du Inter + bleu = ce que tout le monde a. **Test du miroir** : avant de proposer A/B/C, relis la section "Utilisateurs cibles" du PRD. Une app pour avocats n'a pas la même palette qu'une app pour créateurs TikTok.

## Risque #2 — sur-spécifier les composants

Le template a 8 composants. Pour la v1, **ne dépasse pas 10**. Tu peux ajouter `card-featured`, `cta-band`, `footer` au fil de l'eau quand tu en auras besoin. Sur-spécifier le YAML rend le DESIGN.md illisible et difficile à maintenir.

## Risque #3 — diverger du template structure

Tu adaptes les **valeurs**, pas la **structure**. Les 8 sections canoniques sont dans cet ordre exact (Overview → Colors → Typography → Layout → Elevation & Depth → Shapes → Components → Do's and Don'ts). Les outils qui lisent DESIGN.md s'attendent à cet ordre. Si tu inverses Typography et Colors, le linter Google râle.

## Quand ne PAS utiliser ce skill

- Projet sans UI (script CLI, automation n8n pure, API backend uniquement) → skip
- Refonte d'un design existant déjà documenté → édite `DESIGN.md` direct
- Question ponctuelle "quelle couleur pour ce bouton" → réponse inline, pas un skill
- Pas de PRD validé → `/architect` d'abord

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "design", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Affiche à l'utilisateur :

```
✅ DESIGN.md créé : DESIGN.md

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /plan Phase 1
```

**Prochaine étape** : `/close → /clear → /plan Phase 1` — voir le rituel dans `docs/KIT.md § STATUS.md & rituel`.
