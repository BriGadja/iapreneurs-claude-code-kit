---
name: design
description: Utiliser pour définir le design system (palette, typographie, ton, composants clés, animations) d'une app web AVANT /plan Phase 1. Produit un fichier `DESIGN.md` à la racine du projet qui sera lu par le plugin `frontend-design` (Anthropic) à chaque création de composant UI. Ne PAS utiliser pour un projet sans UI (script CLI, automation n8n pure). Ne PAS utiliser sans PRD validé — `/architect` d'abord.
---

# Skill /design — définir le design system avant le build UI

## Pour quoi faire

Une fois le PRD validé (`/architect`), si ton projet a une UI web, définir une fois pour toutes le **design system** : palette, typographie, ton, composants clés. Sortie : un fichier `DESIGN.md` à la racine du projet.

Le plugin `frontend-design` d'Anthropic lit ce fichier à chaque création de composant UI — sans `DESIGN.md`, le plugin invente une palette différente à chaque page. Avec `DESIGN.md`, il reste cohérent.

## Quand l'invoquer dans le workflow

```
/start → /brainstorm? → /architect → /design (si web app) → /plan Phase 1 → ...
```

`/architect` te suggérera `/design` à la fin de son handoff si la stack inclut une UI web (Next.js, React, Vue, etc.). Si pas d'UI → skip et passe direct à `/plan`.

## Comment procéder

### Étape 1 — Vérifier les prérequis

1. Lire `CLAUDE.md` section `## Stack`. Si pas de framework UI (Next.js, React, Vue, Svelte, ...) → annonce "Ton projet n'a pas d'UI web, `DESIGN.md` n'est pas pertinent. Passe direct à `/plan` Phase 1." et stoppe.
2. Vérifier que le plugin `frontend-design` est installé : `claude plugin list` (cherche `frontend-design@claude-code-plugins`). Si absent → propose :
   ```
   claude plugin install frontend-design@claude-code-plugins
   ```
   et attends confirmation. Tu peux continuer même si l'utilisateur veut l'installer plus tard — `DESIGN.md` est utile même sans le plugin (tout LLM qui code de l'UI peut le lire).

### Étape 2 — Brand existante ou from scratch ?

> "Tu pars d'une **brand existante** (couleurs/typo/ton déjà définis ailleurs) ou tu démarres **from scratch** ?"

**Si existante** → Étape 3a. **Si from scratch** → Étape 3b.

### Étape 3a — Récupérer la brand existante (4 questions)

Pose les 4 questions, une par une :

1. **Palette** : "Donne-moi tes couleurs : primary, secondary (optionnel), accent (optionnel), et neutrals (background + texte). Format `#RRGGBB` ou nom de couleur."
2. **Typographie** : "Quelles font-families : display (titres) et body (texte courant) ? Si Google Fonts, donne juste le nom. Sinon, web-safe (`system-ui`, `Georgia`, ...)."
3. **Ton & voix** : "En 2-3 mots, le ton de ta marque : pro/chaleureux/tech/luxe/punk/etc ? À qui tu parles ?"
4. **Refs visuelles** : "Des sites/apps que tu trouves visuellement proches de ce que tu veux ? (optionnel, 1-3 URLs)"

Passe à l'étape 4 avec les réponses.

### Étape 3b — Proposer 3 directions (from scratch)

À partir du contexte (lis le PRD, section "Utilisateurs cibles" + "Sommaire"), propose **3 directions** distinctes :

> "Voilà 3 directions cohérentes avec ton projet. Choisis celle qui te parle, ou demande-moi une variante.
>
> **A — Minimal & épuré** (tech B2B, productivity)
> - Palette : `#0F172A` (texte) sur `#FFFFFF` (background), accent `#3B82F6` (bleu), neutrals slate
> - Typo : Inter (display + body), JetBrains Mono pour le code
> - Ton : direct, factuel, "outil professionnel pour gens occupés"
>
> **B — Chaleureux & humain** (services, coaching, consulting)
> - Palette : `#1A1A1A` sur `#FAF7F2` (warm white), primary `#C2410C` (terracotta), neutrals stone
> - Typo : Fraunces ou Source Serif (display), Inter (body)
> - Ton : conversationnel, premier degré, "expert qui te tutoie"
>
> **C — Moderne & vibrant** (creator economy, SaaS jeune)
> - Palette : `#0A0A0A` sur `#FFFFFF`, primary `#7C3AED` (purple) ou `#10B981` (emerald), accent vibrant
> - Typo : Geist Sans (display + body), Geist Mono
> - Ton : punchy, second degré assumé, "on est ici pour casser des codes"
>
> Tu choisis A, B, C, ou tu veux une variante ?"

Itère jusqu'à ce que l'utilisateur valide.

### Étape 4 — Affiner les composants clés

Pose **2 questions max** sur les composants critiques :

1. **Border radius général** : "Tu veux des bords carrés (`0`), légèrement arrondis (`6px`, default shadcn), bien arrondis (`12px`) ou très arrondis (`24px` voire `999px` pour pill-shaped) ?"
2. **Densité** : "Interface dense (data-heavy, dashboard pro) ou aérée (marketing/landing, beaucoup d'espace) ?"

Inférer le reste (boutons, cards, inputs) à partir de la direction choisie + ces 2 réponses.

### Étape 5 — Écrire `DESIGN.md`

Compose le fichier complet, affiche-le entier dans le chat, demande validation **avant** de sauvegarder.

> "Voilà le DESIGN.md que je propose. Tu valides ou tu veux ajuster un truc ?"

Itère jusqu'à OK. Puis sauvegarde à la racine.

## Format du DESIGN.md

```markdown
# Design — {Nom du projet}

> Lu automatiquement par le plugin `frontend-design` et par tout skill qui touche à l'UI. Source de vérité pour la cohérence visuelle.

## Brand & ton
{2-3 phrases : ton (pro/chaleureux/tech/...), public, registre. Ex: "Outil B2B pour freelances français. Ton direct, factuel, premier degré. Pas de gaminess, pas d'emojis dans l'UI."}

## Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#XXXXXX` | CTAs, liens, focus rings |
| `secondary` | `#XXXXXX` | CTAs secondaires (optionnel) |
| `accent` | `#XXXXXX` | Highlights, badges, surcharges visuelles (optionnel) |
| `background` | `#XXXXXX` | Background page |
| `surface` | `#XXXXXX` | Background cards/modals |
| `border` | `#XXXXXX` | Borders subtiles |
| `text` | `#XXXXXX` | Texte courant |
| `text-muted` | `#XXXXXX` | Texte secondaire |
| `success` | `#XXXXXX` | Toasts success, badges OK |
| `warning` | `#XXXXXX` | Toasts warning |
| `error` | `#XXXXXX` | Toasts error, validation invalide |

> En mode Tailwind/shadcn : ces tokens vont dans `app/globals.css` en CSS custom properties, mappés sur `--primary`, `--background`, etc.

## Typographie

- **Display** (titres h1-h3) : `{Font Name}` — weight 600-700 — line-height tight (1.1-1.2)
- **Body** (texte courant) : `{Font Name}` — weight 400-500 — line-height normal (1.5-1.6)
- **Mono** (code, données numériques) : `{Font Name}` — weight 400

Échelle de tailles (Tailwind par défaut OK, ou custom) :
- h1 : `text-4xl` / `text-5xl` desktop
- h2 : `text-2xl` / `text-3xl` desktop
- h3 : `text-xl`
- body : `text-base`
- small : `text-sm`
- caption : `text-xs`

## Espacement & layout

- Scale : Tailwind par défaut (`4px` step)
- Container max-width : `max-w-6xl` (1152px) pour les pages standard
- Border radius : `{0 | 6px (rounded-md) | 12px (rounded-xl) | full}`
- Densité : `{compact | normal | spacious}`

## Composants clés

### Boutons
- **Primary** : background `primary`, text white, hover assombri 10%
- **Secondary** : background `surface`, border `border`, text `text`
- **Ghost** : pas de background, hover background `surface`
- **Destructive** : background `error`, text white

### Inputs
- Background `surface`, border `border`, focus ring 2px `primary`
- Padding intérieur `px-3 py-2`
- Erreur : border `error`, helper text en `error`

### Cards
- Background `surface`, border `border`, radius général
- Shadow : `shadow-sm` au repos, `shadow-md` au hover (si interactif)

### Toasts (sonner)
- Position top-right desktop, bottom mobile
- Background `surface`, accent latéral selon type (success/warn/error)

## Animations

- **Durée standard** : `150ms` pour hover/focus, `250ms` pour modal/dialog
- **Easing** : `ease-out` pour entrée, `ease-in` pour sortie
- **Pas de bounce/spring** sauf si direction "Moderne & vibrant"

## Refs visuelles

{URLs optionnelles vers des sites/apps qui inspirent. Aide le plugin frontend-design à calibrer.}
```

## Comment le plugin `frontend-design` consomme DESIGN.md

Le plugin `frontend-design@claude-code-plugins` ne lit pas automatiquement `DESIGN.md` — c'est à toi de le référencer dans ton prompt. Mais Claude Code, lui, lit le `CLAUDE.md` qui contient (depuis le template `/start`) l'instruction *"Pour toute création UI, lire `DESIGN.md` d'abord"*. Donc en pratique, dès que tu demandes "construis-moi une page X" dans une session, Claude lit `DESIGN.md` avant d'invoquer le plugin.

Tu peux aussi le référencer explicitement : *"Construis-moi une page de connexion qui respecte `DESIGN.md`."*

## Risque #1 — proposer une palette générique

Si tu choisis Direction A par défaut sans regarder le PRD, tu fais du Inter + bleu = ce que tout le monde a. **Test du miroir** : avant de proposer A/B/C, relis la section "Utilisateurs cibles" du PRD. Une app pour avocats n'a pas la même palette qu'une app pour créateurs TikTok.

## Risque #2 — sur-spécifier

`DESIGN.md` doit tenir en ~80 lignes max. Si tu te retrouves à spécifier chaque pixel de chaque composant, tu fais le travail du plugin à sa place. Reste sur les **décisions de système** : palette, typo, density, radius général. Les détails (padding exact d'un input particulier) sortent du scope.

## Quand ne PAS utiliser ce skill

- Projet sans UI (script CLI, automation n8n pure, API backend uniquement) → skip
- Refonte d'un design existant déjà documenté → édite `DESIGN.md` direct
- Question ponctuelle "quelle couleur pour ce bouton" → réponse inline, pas un skill
- Pas de PRD validé → `/architect` d'abord

## Handoff

Fin du skill : path `DESIGN.md` + suggestion `/plan` Phase 1.
