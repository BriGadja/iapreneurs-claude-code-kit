<!--
PRD vivant discipliné. Cap 100 lignes hard.
Mis à jour par /evoluer (jamais réécrit destructivement).
project_type: webapp | Request Classification: STANDARD
-->

# PRD — Freelance Devis

## 1. Vision

Application web qui automatise la génération de devis pour un freelance français. Un prospect remplit un formulaire de demande, un moteur n8n qualifie et calcule un brouillon, puis le freelance relit et envoie. Réduit le temps "demande reçue → devis envoyé" de 2h à 10 min.

## 2. Personas

- **Le freelance (admin)** — reçoit les demandes qualifiées, relit le brouillon, ajuste, envoie. Usage 2-5x/semaine. Douleur : passer 2h à recalculer un devis sortable et à le mettre en forme.
- **Le prospect (anonyme)** — remplit le formulaire en < 3 min sur mobile ou desktop. Ne revient jamais dans l'app (reçoit le devis par mail). Douleur : devoir attendre 2-3 jours pour un devis.

## 3. Scope actuel (V_n)

> Cochée = livré. Mis à jour par `/evoluer`.

### Core
- [x] Formulaire public de demande (nom, email, téléphone, type de prestation, budget, message)
- [x] Webhook n8n qualification + calcul brouillon depuis grille de prix
- [x] Espace admin (auth Supabase) liste + relecture + ajustement + envoi
- [x] Envoi devis PDF par email (Resend) avec mentions légales (SIRET, RCS, TVA, conditions, validité)
- [x] Statut tracking : `brouillon → envoye → accepte / refuse` (manuel)

### Technique
- [x] Next.js 16 App Router + Tailwind v4 + shadcn/ui
- [x] Supabase (Auth + Postgres + Storage PDF) avec RLS strict
- [x] n8n self-hosted (qualification + calcul + PDF via Puppeteer)
- [x] Resend pour l'envoi email
- [x] Déploiement Vercel + n8n self-hosted

## 4. Hors scope (différé)

- [ ] Paiement intégré (Stripe, virement) — gestion hors app
- [ ] Signature électronique (DocuSign, etc.)
- [ ] Auth pour les prospects (pas de compte client)
- [ ] Relances automatiques (relance manuelle par le freelance)
- [ ] Multi-utilisateurs / team
- [ ] Devis récurrents / contrats — uniquement ponctuels
- [ ] Export PDF côté client navigateur (gain perf)

## 5. Constraints non-négociables

- Français uniquement (interface, contenus, mentions légales)
- RLS Supabase obligatoire sur toutes les tables — 0 advisory `security:high`
- Mentions légales devis : SIRET + RCS + TVA + conditions paiement + validité (5 obligatoires)
- Lighthouse mobile ≥ 90 perf / ≥ 95 a11y sur formulaire public

## 6. Success Criteria

- Un prospect peut soumettre une demande end-to-end en < 3 min sur mobile sans crash
- Le freelance peut ajuster, générer le PDF et envoyer en < 5 min
- Le devis envoyé contient les 5 mentions légales obligatoires
- RLS Supabase actif sur toutes les tables — `get_advisors` retourne 0 advisory `security:high`
- Lighthouse mobile ≥ 90 perf, ≥ 95 a11y sur la page formulaire

## 7. Implementation Phases

**V1 (livré le 2026-04-12)** — MVP complet : formulaire + auth + qualification n8n + PDF + envoi + RLS + déploiement Vercel.

**V2 (en cours)** — Export PDF côté client navigateur (cf docs/specs/SPEC-2026-08-12-export-pdf-devis.md).

## 8. Risks & Mitigations

- **Risque** : hallucination calcul n8n sur cas atypique → **Mitigation** : freelance relit toujours avant envoi (statut `brouillon` obligatoire)
- **Risque** : PDF mal généré (mentions tronquées) → **Mitigation** : test snapshot sur fichier référence avant prod
- **Risque** : RLS faille (admin voit devis d'un autre) → **Mitigation** : test E2E auth sur 2 comptes admin distincts
