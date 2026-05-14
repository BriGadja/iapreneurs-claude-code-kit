<!--
PRD vivant discipliné. Cap 100 lignes hard.
Mis à jour par /evoluer (jamais réécrit destructivement).
project_type: site | Request Classification: LITE
-->

# PRD — Site vitrine coach business

## 1. Vision

Site vitrine 4 pages d'un coach business solo pour présenter l'offre et recevoir des demandes de contact par email. Pas de BDD, pas d'auth, pas d'espace privé — un outil de présence minimaliste, pro et rapide.

## 2. Personas

- **Coach business solo (admin)** — gère le site une fois déployé, ne touche presque jamais au code. Douleur : besoin de présence pro sans payer 200€/mois à Wix.
- **Prospect visiteur (anonyme)** — découvre l'offre en 2 min sur mobile, envoie un mail si intéressé. Douleur : sites coachs souvent lents et peu clairs.

## 3. Scope actuel (V_n)

> Cochée = livré. Mis à jour par `/evoluer` (déplace les `[x]` Hors scope → ici).

### Core
- [ ] 4 pages : Accueil / À propos / Services / Contact
- [ ] Formulaire de contact → Resend → `coach@exemple.fr`
- [ ] Déploiement Vercel + domaine custom HTTPS

### Technique
- [ ] Next.js 16 App Router + static export
- [ ] Tailwind v4 + shadcn/ui, palette violet `#6855F8`
- [ ] Resend pour l'envoi email

## 4. Hors scope (différé)

> Cocher = on l'apporte maintenant, `/evoluer` la déplacera vers Scope actuel.

- [ ] Blog ou CMS — le coach n'a pas le temps de tenir un blog
- [ ] Espace membre / login — pas de besoin
- [ ] Calendrier de prise de RDV intégré — RDV pris à la main après contact
- [ ] Multi-langue — français uniquement
- [ ] Newsletter — pas de besoin pour 10 demandes/mois

## 5. Constraints non-négociables

- Français uniquement (interface + contenus)
- Lighthouse ≥ 90 perf / ≥ 95 a11y sur toutes les pages
- Pas de tracker tiers (RGPD-friendly par défaut)

## 6. Success Criteria

- Le visiteur peut naviguer les 4 pages sans bug visuel
- Le formulaire de contact envoie bien un email à `coach@exemple.fr` en < 30 secondes
- Lighthouse Performance ≥ 90, Accessibility ≥ 95, SEO ≥ 90 sur l'accueil
- Le site est déployé sur Vercel avec domaine custom HTTPS

## 7. Implementation Phases

**V1 (livré le YYYY-MM-DD)** — Site complet 4 pages + formulaire de contact fonctionnel + déploiement Vercel.

## 8. Risks & Mitigations

- **Risque** : formulaire spam par bots → **Mitigation** : honeypot CSS + rate-limit côté Vercel function
- **Risque** : domaine mal configuré DNS → **Mitigation** : valider via `dig` avant push prod
