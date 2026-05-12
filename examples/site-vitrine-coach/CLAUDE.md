# CLAUDE.md — Exemple "site vitrine coach business"

> Exemple **LITE** : site vitrine 4 pages pour un coach business solo. PRD réduit (3 sections), pas de BDD, formulaire de contact via Resend.

## Identité

<!-- start:identité -->
Site vitrine d'un coach business solo. 4 pages (accueil, à propos, services, contact). Le visiteur peut soumettre une demande via le formulaire de contact qui arrive par email. Pas de BDD, pas d'auth, pas d'admin.

project_type: site
<!-- /start:identité -->

## Stack

<!-- architect:stack -->
- Frontend : Next.js 16 (App Router) + Tailwind v4 + shadcn/ui (4 composants : Hero, FeatureCard, ContactForm, Footer)
- Hosting : Vercel (gratuit)
- Email transactionnel : Resend (formulaire contact → email vers `coach@exemple.fr`)
- Langue : français uniquement
<!-- /architect:stack -->

## Request Classification

**Niveau choisi pour ce projet** : `LITE` — 1 phase, PRD 3 sections, pas de `/challenge` systématique, validation manuelle au lieu de tests automatisés.

## Conventions

- Fichiers : kebab-case (`page.tsx`, `contact-form.tsx`)
- Commit : conventionnel (`feat:`, `fix:`, `chore:`)
- Couleur primaire : `#6855F8` (violet, choix du coach)

## Instructions

- Pas de JS pour les interactions simples (utiliser CSS uniquement)
- Lighthouse cible : Performance ≥ 90 / Accessibility ≥ 95 / SEO ≥ 90
- Pas de cookies tiers (ni GA, ni Hotjar — pas besoin)

## Contexte métier

- Le coach reçoit ~10 demandes/mois, validation manuelle des leads suffit
- Pas de tarif affiché (volontaire — discussion d'abord)
