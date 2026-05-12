---
version: alpha
name: Freelance Devis
description: |
  Interface chaleureuse et humaniste pour un freelance français qui gère des devis. Ancrée sur un canvas
  crème teinté avec titres serif et CTAs corail. Le voltage vient du pairing crème/corail — délibérément
  chaud et humaniste, à contre-courant des SaaS B2B bleus froids. Cible : freelance pressé qui a 2
  minutes entre deux clients pour relire un devis et l'envoyer.

colors:
  primary: "#cc785c"
  primary-active: "#a9583e"
  primary-disabled: "#e6dfd8"

  ink: "#141413"
  body: "#3d3d3a"
  muted: "#6c6a64"
  muted-soft: "#8e8b82"

  hairline: "#e6dfd8"
  hairline-soft: "#ebe6df"

  canvas: "#faf9f5"
  surface-soft: "#f5f0e8"
  surface-card: "#efe9de"

  on-primary: "#ffffff"

  success: "#5db872"
  warning: "#d4a017"
  error: "#c64545"

typography:
  display-lg:
    fontFamily: "Fraunces, Georgia, serif"
    fontSize: 48px
    fontWeight: 600
    lineHeight: 1.1
  display-md:
    fontFamily: "Fraunces, Georgia, serif"
    fontSize: 36px
    fontWeight: 600
    lineHeight: 1.15
  title-lg:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 22px
    fontWeight: 500
    lineHeight: 1.3
  title-md:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 18px
    fontWeight: 500
    lineHeight: 1.4
  body-md:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 16px
    fontWeight: 400
    lineHeight: 1.55
  body-sm:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 14px
    fontWeight: 400
    lineHeight: 1.55
  caption:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 13px
    fontWeight: 500
    lineHeight: 1.4
  button:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: 14px
    fontWeight: 500
    lineHeight: 1

rounded:
  sm: 6px
  md: 8px
  lg: 12px
  pill: 999px

spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px

components:
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

  badge-status-new:
    backgroundColor: "{colors.warning}"
    textColor: "{colors.ink}"
    typography: "{typography.caption}"
    rounded: "{rounded.pill}"
    padding: "4px 12px"

  badge-status-sent:
    backgroundColor: "{colors.success}"
    textColor: "{colors.on-primary}"
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

Freelance Devis vit dans un univers chaleureux — canvas crème, typo serif pour les titres (Fraunces), Inter pour le corps. Le ton est conversationnel et premier degré : "Vous voulez un devis ? Remplissez ça, je vous reviens dans 24h." Les CTAs en corail (`{colors.primary}`) tirent l'œil sans agresser. À contre-courant des SaaS B2B sérieux qui empilent du bleu froid et du slate, Freelance Devis vise un sentiment d'artisanat moderne : un pro qui sait ce qu'il fait, sans esbroufe.

## Colors

- **Primary `{colors.primary}` (corail/terracotta)** : CTAs principaux (Envoyer, Soumettre), liens importants, focus rings. Choisi pour son contraste chaud avec le canvas crème.
- **Surfaces (canvas, surface-soft, surface-card)** : hiérarchie de fonds tons crème. Canvas = page entière, surface-soft = sections de page, surface-card = panels/cards.
- **Ink vs body vs muted** : 3 niveaux de gris chaud pour le texte. Ink = titres serif. Body = paragraphes. Muted = hints, dates, statuts secondaires.
- **Semantic (success, warning, error)** : uniquement pour les feedbacks (toast envoi OK, statut "nouveau", erreur formulaire).

## Typography

- **Display Fraunces** : titres de page (`display-lg`) et sections (`display-md`). Le serif appuie le côté humaniste et permet de varier visuellement des SaaS génériques.
- **Title Inter** : sous-titres de cards, headers de tableau. Toujours sans-serif pour la lisibilité dense.
- **Body Inter** : texte courant. `body-md` pour le formulaire et les paragraphes, `body-sm` pour les listes/cards denses.
- **Caption** : statuts, dates, labels secondaires.

## Layout

- Container max-width `max-w-4xl` (768px) pour les pages formulaire (forme étroite = focus utilisateur).
- Container `max-w-6xl` (1152px) pour le dashboard admin (besoin de densité).
- Grille mobile-first : 1 colonne mobile → 2 colonnes tablette → 3 colonnes desktop sur le dashboard.

## Elevation & Depth

- **Pas de shadows lourds**. Le canvas crème + surfaces différenciées suffisent à hiérarchiser.
- Niveau 1 (cards) : `shadow-sm` très subtil (2px blur 5% opacité).
- Niveau 2 (toasts, popovers) : `shadow-md`.
- Hover sur les cards cliquables : passe de niveau 1 à niveau 2, transition `150ms ease-out`.

## Shapes

- `{rounded.md}` (8px) pour inputs, boutons, badges-status.
- `{rounded.lg}` (12px) pour les cards.
- `{rounded.pill}` pour les badge pills.
- Cohérence : si une card est `{rounded.lg}`, ses inputs internes sont `{rounded.md}` (un cran en dessous).

## Components

- **Boutons** : `button-primary` pour l'action principale unique de la page (Envoyer la demande, Envoyer le devis). `button-secondary` pour les actions de support.
- **Form** : labels au-dessus des inputs, focus ring 2px `{colors.primary}` offset 2px, helper text en `{colors.muted}` en dessous.
- **Cards de devis** (dashboard) : nom prospect en `title-md`, type de service + budget en `body-sm`, statut via `badge-status-*` en haut à droite, date en `caption` en bas.
- **Toasts** : `sonner`, position top-right, auto-dismiss 4s. Jamais d'`alert()` ou de `confirm()`.

## Do's and Don'ts

### Do

- Référencer les tokens (`{colors.primary}`, `{spacing.lg}`) au lieu de hex/px en dur dans le code.
- Garder Fraunces uniquement pour les titres `display-*`. Le reste en Inter.
- Utiliser les couleurs sémantiques (`success`, `warning`, `error`) **uniquement** pour les statuts/toasts, pas pour la décoration.

### Don't

- Pas de couleur primary pour du texte courant — réservée aux CTAs et focus rings.
- Pas de Fraunces pour le body — illisible à 14px.
- Pas d'opacité sur le texte (`opacity: 0.5`) — utilise `{colors.muted}` qui est déjà calibré.
- Pas de border radius arbitraire — toujours via les tokens.
