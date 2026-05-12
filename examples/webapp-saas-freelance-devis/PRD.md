# PRD : Freelance Devis

## Sommaire

Application web qui automatise la génération de devis pour un freelance français. Un prospect remplit un formulaire de demande sur le site, un moteur n8n qualifie et calcule un brouillon de devis, puis le freelance relit et envoie. Réduit le temps "demande reçue → devis envoyé" de 2h à 10 min.

## Utilisateurs cibles

- **Le freelance (admin)** : reçoit les demandes qualifiées, relit le brouillon, ajuste, envoie. Utilise l'app 2-5x par semaine.
- **Le prospect (anonyme, sans compte)** : remplit le formulaire de demande en moins de 3 minutes sur mobile ou desktop. Ne revient jamais dans l'app (recoit le devis par mail).

## MVP — ce qu'on fait

- Formulaire public de demande de devis (nom, email, téléphone, type de prestation, budget approximatif, message libre)
- Webhook n8n qui qualifie la demande (champs obligatoires présents, type de prestation reconnu) puis calcule un brouillon de devis depuis une grille de prix
- Espace admin (auth Supabase) qui liste les devis en brouillon, permet la relecture, l'ajustement, et l'envoi
- Envoi du devis en PDF par email (Resend), avec mentions légales (SIRET, RCS, TVA, conditions de paiement)
- Statut tracking : `brouillon → envoye → accepte / refuse` (le freelance change le statut manuellement)

## Hors-MVP — ce qu'on ne fait PAS

- Pas de paiement intégré (Stripe, virement) — gestion hors app
- Pas de signature électronique (DocuSign, etc.)
- Pas d'auth pour les prospects (pas de compte client)
- Pas de relances automatiques (le freelance relance à la main)
- Pas de multi-utilisateurs (un seul freelance par instance, pas de team)
- Pas de devis récurrents / contrats — uniquement devis ponctuels

## Phases

- **Phase 1** — Squelette + auth admin + formulaire public : le freelance se connecte, voit un dashboard vide, un prospect peut soumettre une demande qui apparaît dans la liste.
- **Phase 2** — Moteur n8n de qualification + brouillon : la demande qualifie automatiquement et un brouillon de devis est calculé selon la grille de prix.
- **Phase 3** — Edition + génération PDF + envoi Resend : le freelance ajuste, génère le PDF, envoie par mail.
- **Phase 4** — Statuts + RLS Supabase strict + audit sécurité + déploiement Vercel.

## Stack technique

- Frontend : Next.js 16 (App Router) + Tailwind v4 + shadcn/ui
- Backend : n8n (moteur de qualification + calcul) + Supabase (Auth + Postgres + Storage pour PDF)
- Email : Resend (envoi du devis)
- PDF : génération côté n8n (template HTML → PDF via Puppeteer self-hosted ou api.pdfshift)
- Hosting : Vercel (frontend) + n8n self-hosted (workflow)
- Langue : français uniquement (interface, contenus, mentions légales)

## Critères de succès

- [ ] Un prospect peut soumettre une demande end-to-end en moins de 3 min sur mobile sans crash
- [ ] Le freelance peut ajuster, générer le PDF et envoyer en moins de 5 min
- [ ] Le devis envoyé contient les 5 mentions légales obligatoires (SIRET, RCS, TVA, conditions de paiement, validité)
- [ ] RLS Supabase actif sur toutes les tables — `get_advisors` retourne 0 advisory `security:high`
- [ ] Lighthouse mobile ≥ 90 perf, ≥ 95 a11y sur la page formulaire
