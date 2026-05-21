# Décisions d'architecture du projet

> Ce fichier a deux usages :
>
> 1. **ADR fondateurs/architecturaux numérotés** (écrits par `/architect` Étape 6.6 ADR-001 + `/evoluer` Étape 5f si choix significatif). Format strict, idempotent (ne réécrit pas un ADR existant).
> 2. **Harvest libre** (écrit par `/close` lors du harvest learnings, zone `<!-- close:decisions -->` ci-dessous, format bullet libre).
>
> Les deux coexistent : ADR numérotés en tête (rigueur), bullets en bas (rapidité).

## ADR — Architecture Decision Records

> Format : `ADR-NNN — {Titre court}` puis bloc `Status / Date / Context / Decision / Consequences`. Status ∈ {Accepted, Superseded, Deprecated}. Numérotation strictement incrémentale, jamais réutilisée.

<!-- ADR-NNN entries appended here by /architect (Étape 6.6) and /evoluer (Étape 5f) -->

<!--
Exemple ADR-001 ci-dessous : à remplacer par tes vrais ADR au fil du projet.
`/architect` Étape 6.6 le réécrira avec ton vrai choix de stack lors du premier
cadrage. Garde-le tel quel pour voir à quoi un ADR de production ressemble.
-->

### ADR-001 — Stack Next.js + Supabase pour le MVP

**Status** : Accepted
**Date** : 2026-05-21
**Context** : Le projet a besoin d'auth, BDD relationnelle, storage de fichiers, et déploiement rapide. L'équipe est 1 personne, non-backend. Budget MVP < €50/mois.
**Decision** : Next.js (frontend + API routes) + Supabase (auth + Postgres + Storage) + Vercel (hosting). Pas de backend custom, pas de Prisma — Supabase client direct depuis API routes Next.js.
**Consequences** :
- ✅ Auth en 30 min sans rouler son propre backend (OAuth Google + email/password gérés)
- ✅ Postgres = relationnel sérieux, pas un sandbox jouet (jointures, contraintes, vues)
- ✅ RLS côté BDD = sécurité by default si > 1 utilisateur, pas de check applicatif à oublier
- ⚠️ Lock-in Vercel partiel : Next.js compatible ailleurs, mais build optimisé pour Vercel (ISR, edge)
- ⚠️ Coûts Supabase à surveiller si > 500 MAU (gratuit jusqu'à 50k MAU, payant ~$25/mo au-dessus)
- ⚠️ Pas de queue/cron natif : besoin d'externaliser (Vercel cron, n8n) si async

---

## Décisions (harvest libre)

<!-- close:decisions -->
{Vide au démarrage. Premier exemple après quelques sessions :

- **2026-05-15** — BDD : Supabase au lieu de Neon. Rationale : Auth + BDD + Realtime en un, RLS native, gratuit jusqu'à 500 MB suffisant pour le MVP.
- **2026-05-22** — Hosting : Vercel au lieu de Netlify. Rationale : meilleure intégration Next.js, déploiement preview par PR, gratuit pour projet perso.
- **2026-06-01** — Email transactionnel : Resend. Rationale : DX moderne (React Email), 3000 emails/mois gratuit, dépendance minimale.}
<!-- /close:decisions -->
