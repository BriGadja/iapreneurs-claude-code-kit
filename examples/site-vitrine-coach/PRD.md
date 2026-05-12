# PRD : Site vitrine coach business

> **Niveau Request Classification** : LITE (3 sections : Sommaire + 1 Phase + Hors-MVP)
> **project_type** : site

## Sommaire

Site vitrine 4 pages d'un coach business solo. Permet au visiteur de découvrir l'offre, lire les services, et envoyer une demande de contact via un formulaire. Le coach reçoit la demande par email. Pas de BDD, pas d'auth, pas d'espace privé.

## Phases

- **Phase 1** — Site complet 4 pages + formulaire de contact fonctionnel : pages Accueil / À propos / Services / Contact, design cohérent avec palette violet `#6855F8`, formulaire connecté à Resend (envoi email vers `coach@exemple.fr`), déploiement Vercel avec domaine custom, Lighthouse ≥ 90 sur toutes les pages.

## Hors-MVP — ce qu'on ne fait PAS

- Blog ou CMS — le coach n'a pas le temps de tenir un blog
- Espace membre / login — pas de besoin
- Calendrier de prise de RDV intégré — RDV pris à la main après contact
- Multi-langue — français uniquement
- Newsletter — pas de besoin pour 10 demandes/mois

## Stack technique

- Frontend : Next.js 16 (App Router, static export pour SEO) + Tailwind v4 + shadcn/ui
- Hosting : Vercel
- Email : Resend (formulaire contact → email)

## Critères de succès

- [ ] Le visiteur peut naviguer les 4 pages sans bug visuel
- [ ] Le formulaire de contact envoie bien un email à `coach@exemple.fr` en < 30 secondes
- [ ] Lighthouse Performance ≥ 90, Accessibility ≥ 95, SEO ≥ 90 sur l'accueil
- [ ] Le site est déployé sur Vercel avec domaine custom HTTPS
