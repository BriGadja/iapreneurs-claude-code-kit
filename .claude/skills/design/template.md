---
version: alpha
name: {NomDuProjet}
description: |
  Décris la voix visuelle de ta marque en 2-4 phrases. Sur quoi on s'ancre (canvas, palette, typographie),
  d'où vient le "voltage" (le contraste qui rend la marque reconnaissable), quelle est l'intention
  émotionnelle. Exemple : "Interface éditoriale chaleureuse, ancrée sur un canvas crème teinté avec
  titres serif et CTAs corail. Le voltage vient du pairing crème/corail — délibérément chaud et
  humaniste là où la plupart des marques IA utilisent du bleu froid + slate."

# === Design tokens (machine-readable, consommés par les LLM via {token references}) ===

colors:
  # Tokens principaux — utilise des noms sémantiques, pas des couleurs littérales
  primary: "#cc785c"              # CTAs, liens, focus rings
  primary-active: "#a9583e"       # primary en :active / pressed
  primary-disabled: "#e6dfd8"     # primary disabled state

  ink: "#141413"                  # texte le plus contrasté (titres)
  body: "#3d3d3a"                 # texte courant
  body-strong: "#252523"          # texte courant emphasé
  muted: "#6c6a64"                # texte secondaire / hints
  muted-soft: "#8e8b82"           # texte tertiaire / disabled labels

  hairline: "#e6dfd8"             # borders standards
  hairline-soft: "#ebe6df"        # borders subtiles

  canvas: "#faf9f5"               # background page
  surface-soft: "#f5f0e8"         # surface secondaire (sections)
  surface-card: "#efe9de"         # cards / panels
  surface-dark: "#181715"         # surfaces dark mode / contrastées
  surface-dark-elevated: "#252320"
  surface-dark-soft: "#1f1e1b"

  on-primary: "#ffffff"           # texte sur primary
  on-dark: "#faf9f5"              # texte sur surface-dark
  on-dark-soft: "#a09d96"         # texte secondaire sur surface-dark

  # Sémantique
  success: "#5db872"
  warning: "#d4a017"
  error: "#c64545"

  # Accents optionnels (highlight, badges, surcharge visuelle)
  accent-teal: "#5db8a6"
  accent-amber: "#e8a55a"

typography:
  display-xl:                     # h1 hero, splash screens
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 64px
    fontWeight: 700
    lineHeight: 1.05
    letterSpacing: -1.5px
  display-lg:                     # h1 standard
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 48px
    fontWeight: 700
    lineHeight: 1.1
    letterSpacing: -1px
  display-md:                     # h2
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 36px
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: -0.5px
  display-sm:                     # h3
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 28px
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: -0.3px
  title-lg:                       # h4, section titles
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 22px
    fontWeight: 500
    lineHeight: 1.3
  title-md:                       # h5, card titles
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 18px
    fontWeight: 500
    lineHeight: 1.4
  title-sm:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.4
  body-md:                        # texte courant
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.55
  body-sm:                        # texte courant compact
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.55
  caption:                        # legends, hints
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.4
  caption-uppercase:              # labels, eyebrow
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 12px
    fontWeight: 500
    lineHeight: 1.4
    letterSpacing: 1.5px
  code:                           # code, données numériques mono
    fontFamily: "JetBrains Mono, ui-monospace, monospace"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.6
  button:                         # textes des boutons
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1
  nav-link:                       # liens nav
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1.4

rounded:
  xs: 4px
  sm: 6px
  md: 8px
  lg: 12px
  xl: 16px
  pill: 999px

spacing:
  # Échelle Tailwind par défaut (4px step). Utilise des nombres ou strings avec unité.
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  3xl: 64px

components:
  # Tokens composables via {colors.X}, {typography.Y}, {rounded.Z}, {spacing.W}
  # Liste les variantes que TU utilises réellement dans ton app. Pas besoin d'être exhaustif.

  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    padding: "10px 16px"

  button-secondary:
    backgroundColor: "{colors.surface-card}"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    padding: "10px 16px"
    border: "1px solid {colors.hairline}"

  button-ghost:
    backgroundColor: transparent
    textColor: "{colors.body}"
    typography: "{typography.button}"
    rounded: "{rounded.md}"
    padding: "10px 16px"

  text-input:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-md}"
    rounded: "{rounded.md}"
    padding: "10px 14px"
    height: 40px
    border: "1px solid {colors.hairline}"

  card:
    backgroundColor: "{colors.surface-card}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: 24px
    border: "1px solid {colors.hairline}"

  badge-pill:
    backgroundColor: "{colors.surface-card}"
    textColor: "{colors.ink}"
    typography: "{typography.caption}"
    rounded: "{rounded.pill}"
    padding: "4px 12px"

  toast-success:
    backgroundColor: "{colors.success}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.md}"
    padding: "12px 16px"

  toast-error:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-primary}"
    typography: "{typography.body-sm}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
---

## Overview

Décris en prose l'atmosphère visuelle et l'intention de la marque. À qui on s'adresse ? Quel ton ? Qu'est-ce qui rend la marque reconnaissable ? Cette section sert de **prompt narratif** pour le LLM qui consomme le DESIGN.md — elle l'oriente avant même de regarder les tokens.

Exemple : *"{NomDuProjet} est un outil B2B pour freelances français qui transforment leurs RDV en livrables pros. Le ton est direct, factuel, premier degré — pas de gaminess, pas d'emojis dans l'UI. Visuellement on cherche le contraste entre une atmosphère chaleureuse (canvas crème, typo humaniste) et des moments d'efficacité (CTAs nets, dark mode pour le code). Cibler un freelance pressé qui a 2 minutes entre deux clients."*

## Colors

Explique les rôles sémantiques des couleurs (pas juste lister les hex — c'est déjà dans le YAML).

- **Primary `{colors.primary}`** : utilisé pour les CTAs, les liens importants, et les focus rings. Choisi parce qu'il contraste assez avec le canvas pour être lisible, sans agresser.
- **Surface tokens (canvas, surface-soft, surface-card)** : hiérarchie de fonds. Canvas = page entière, surface-soft = sections, surface-card = panels/cards. Le contraste entre les trois doit rester subtil — pas plus de 5% de différence de luminosité.
- **Ink vs body vs muted** : 3 niveaux de gris pour le texte. Ink = titres uniquement. Body = texte courant. Muted = hints, captions, secondaire. Jamais utiliser une couleur primary pour du texte courant.
- **Semantic (success, warning, error)** : uniquement pour les feedbacks utilisateur (toasts, validation, alerts). Pas dans la déco.

## Typography

- **Hiérarchie display** (`display-xl` → `display-sm`) : titres de page et sections. Toujours plus haute graisse que body, line-height serré (1.05-1.2). Couleur `{colors.ink}` par défaut.
- **Hiérarchie title** (`title-lg` → `title-sm`) : sous-titres, titres de cards. Graisse moyenne (500), line-height un peu plus aéré (1.3-1.4).
- **Body** : `body-md` pour le texte courant, `body-sm` pour les contextes denses (tables, listes). Couleur `{colors.body}` par défaut.
- **Caption / caption-uppercase** : pour les labels et eyebrow. `caption-uppercase` avec letter-spacing pour les section labels au-dessus des titres.
- **Code** : monospace pour le code inline et les blocs. Aussi pour les données numériques alignées (factures, dashboards) — la largeur fixe aide la lecture.

## Layout

- **Container max-width standard** : `max-w-6xl` (1152px) pour les pages contenu. `max-w-4xl` (768px) pour les pages texte (articles, docs).
- **Grille** : 12 colonnes desktop, `gap-6` (`{spacing.lg}`), gutters latéraux `{spacing.xl}`.
- **Densité** : *normale*. Padding cards `{spacing.lg}-{spacing.xl}`. Sections page séparées par `{spacing.2xl}` ou `{spacing.3xl}` selon emphase.
- **Breakpoints Tailwind** : sm=640, md=768, lg=1024, xl=1280, 2xl=1536. Mobile first.

## Elevation & Depth

- **Pas de shadows lourds**. Si la marque vit sur canvas chaleureux, les shadows soft suffisent. Si dark mode, contraste de luminosité plutôt que shadow.
- **Niveaux** :
  - Niveau 0 (canvas, surfaces statiques) : pas de shadow
  - Niveau 1 (cards, panels) : `shadow-sm` (1px offset, 2px blur, 5% opacity)
  - Niveau 2 (dropdowns, popovers) : `shadow-md` (4px offset, 8px blur, 10% opacity)
  - Niveau 3 (modals, dialogs) : `shadow-lg` (8px offset, 16px blur, 15% opacity) + overlay backdrop
- **Hover states interactifs** : passer de niveau 1 à niveau 2 sur les cards cliquables. Transition `150ms ease-out`.

## Shapes

- **Border radius standard** : `{rounded.md}` (8px) pour les inputs, buttons, cards. `{rounded.lg}` (12px) pour les modals et les hero cards. `{rounded.pill}` pour les badges et tags.
- **Pas de hard-edge brutaliste** (`rounded: 0`) sauf intention explicite (composant retro/dataviz).
- **Coins arrondis cohérents** : si une card a `{rounded.lg}`, ses inputs internes ont `{rounded.md}` (un cran en dessous). Pas de mix arbitraire.

## Components

Cette section décrit en prose les patterns d'usage des composants déclarés dans le YAML.

- **Boutons** : `button-primary` pour les actions principales (1 max par écran). `button-secondary` pour les actions de support. `button-ghost` pour les actions tertiaires (Cancel, Skip).
- **Inputs** : focus ring 2px `{colors.primary}` avec offset 2px. État erreur : border `{colors.error}`, helper text en `{colors.error}`.
- **Cards** : utilisées pour grouper des informations connexes. Toujours avec un titre. Padding intérieur `{spacing.lg}`.
- **Toasts** : position top-right desktop, bottom mobile. Auto-dismiss 4s. Pas de stack > 3 toasts visibles.
- **Empty states** : illustration discrète + texte explicatif + 1 CTA pour sortir de l'état vide.

## Do's and Don'ts

### Do
- Toujours référencer les tokens (`{colors.primary}`, `{spacing.lg}`) au lieu de valeurs en dur.
- Utiliser `{colors.muted}` ou `{colors.muted-soft}` pour le texte secondaire — jamais une opacité réduite sur `body`.
- Garder la hiérarchie typographique : 1 seul `display-xl` par page, 2-3 `title-*` max par section.
- Respecter les contrastes WCAG AA : `body` sur `canvas` ≥ 4.5:1, `caption` sur `canvas` ≥ 4.5:1.

### Don't
- Pas de couleur primary pour du texte de paragraphe — réservée aux CTAs et liens.
- Pas d'opacité sur les texte (`opacity: 0.5`) — utilise les tokens `muted` qui sont déjà calibrés.
- Pas de border radius arbitraire (`rounded: 7px`) — toujours via les tokens.
- Pas de shadow pour ajouter de l'emphase ; utiliser le contraste de surfaces.
- Pas de typographie hors de l'échelle (`fontSize: 19px`) — toujours via les tokens.

## Responsive Behavior

*Optionnel.* Décris ici les patterns de responsive si non-évidents.

- Hero typography : `display-xl` desktop → `display-lg` tablet → `display-md` mobile.
- Grille 12 col desktop → 6 col tablet → 1 col mobile (stack).
- Navigation : barre horizontale desktop → drawer mobile (toggle en haut à droite).

## Iteration Guide

*Optionnel.* Note ici les décisions volontairement laissées ouvertes et les pistes d'itération future.

- Dark mode : pas implémenté pour la v1, à itérer si le besoin remonte.
- Animations : pas de spring/bounce pour la v1 (`ease-out` uniquement) ; à reconsidérer si la marque devient plus expressive.

## Known Gaps

*Optionnel.* Liste les zones que ce DESIGN.md ne couvre pas encore et qui demanderont une décision en cours de route.

- Pas de tokens pour les graphiques/dataviz (couleurs de séries) — à définir au moment d'implémenter le dashboard.
- Pas de spec pour les emails transactionnels (HTML email a ses propres contraintes).
