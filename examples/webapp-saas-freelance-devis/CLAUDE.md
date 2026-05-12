# Freelance Devis

> Exemple de CLAUDE.md après /start (Identité) + /architect (Stack). Sections Conventions / Instructions / Contexte métier remplies à la main au fil de l'eau.

## Identité

<!-- start:identité -->
Application web qui automatise la génération de devis pour un freelance français. Le client final reçoit des demandes via un formulaire public, un moteur n8n qualifie et calcule un brouillon de devis, le freelance relit dans un espace admin et envoie un PDF par mail. Sert un seul freelance par instance, 2-5x par semaine.

project_type: webapp
<!-- /start:identité -->

## Stack

<!-- architect:stack -->
- Frontend : Next.js 16 (App Router) + Tailwind v4 + shadcn/ui
- Backend : n8n (moteur de qualification + calcul) + Supabase (Auth + Postgres + Storage pour PDF)
- Email : Resend (envoi du devis)
- PDF : génération côté n8n (template HTML → PDF via Puppeteer self-hosted ou api.pdfshift)
- Hosting : Vercel (frontend) + n8n self-hosted (workflow)
- Langue : français uniquement (interface, contenus, mentions légales)
<!-- /architect:stack -->

## Conventions

- Fichiers : kebab-case (`quote-request-form.tsx`, pas `QuoteRequestForm.tsx`)
- Commit : conventionnel (`feat:`, `fix:`, `chore:`)
- Format date : JJ/MM/AAAA partout dans l'UI
- Devises : EUR uniquement, format `1 234,56 EUR` (espaces fines insécables ` `)

## Instructions

- Jamais de `alert()` / `confirm()` / `prompt()` — toujours `sonner` toasts
- Toujours valider les téléphones au format français côté serveur (`+33` ou commençant par `06`/`07`)
- TVA par défaut : 20% (configurable en table `settings`)
- Le devis n'est **JAMAIS** envoyé automatiquement — le freelance valide chaque envoi

## Création UI (si web app) — division du travail `/design` vs `/frontend-design`

Avant de créer ou modifier un composant UI : **lire `DESIGN.md`** pour récupérer les tokens. `/design` (skill kit) a produit le système, `/frontend-design` (plugin Anthropic) construit les composants en suivant le système.

## Contexte métier

- Un "devis" = document commercial avec mentions légales obligatoires (SIRET, RCS, TVA, conditions de paiement, durée de validité)
- Statuts : `new` (depuis formulaire) → `draft` (qualifié par n8n) → `sent` → `accepted` / `refused`
- Le freelance valide chaque envoi manuellement. Non négociable.
- Numérotation devis : `DEV-2026-NNNN` (année + 4 chiffres incrémentaux)
