# Plan — Phase 1 : Squelette + auth admin + formulaire public

> PRD parent : `PRD.md`
> Date : 2026-05-12

## Contexte (extrait du PRD)

Objectif : le freelance peut se connecter, voir un dashboard vide ; un prospect peut soumettre une demande qui apparaît dans la liste du freelance.

Nature : output **synchrone côté UI** (le prospect voit "Demande reçue" après submit, le freelance voit le row apparaître via Supabase Realtime). Pas de génération IA dans cette phase, donc **pas de SDK direct Anthropic**. Le calcul de devis (Phase 2) ira dans n8n.

Données clients réelles (nom, email, téléphone) → **RLS Supabase MANDATORY** dès la Phase 1.

## Tâches

- [ ] **1. Provisioning Supabase + schéma initial** — Crée le projet Supabase `freelance-devis`, applique migration `001_init` avec table `quote_requests` (id, created_at, name, email, phone, service_type, budget_range, message, status default `'new'`, owner_id FK auth.users). Active RLS dès la création, policies : `SELECT` pour `owner_id = auth.uid()`, `INSERT` public anonyme avec `with_check (owner_id IS NULL)`, `UPDATE` pour `owner_id = auth.uid()`. **Fait quand** : `npx supabase db reset` passe + `mcp__supabase__get_advisors` retourne 0 advisory `security:high` sur la table.

- [ ] **2. Squelette Next.js + auth admin** — Init Next.js 16 + Tailwind v4 + shadcn/ui. Crée `app/(admin)/login/page.tsx` avec composant `<LoginForm>` (shadcn Card + Input + Button, design tokens depuis `DESIGN.md`). Crée `app/(admin)/dashboard/page.tsx` qui redirige vers `/login` si pas authentifié, affiche un état vide sinon. **Fait quand** : `npm run dev` lance, navigation `/login` montre le form selon palette DESIGN.md, login avec un compte test redirige vers `/dashboard` qui montre "Aucune demande pour le moment".

- [ ] **3. Formulaire public de demande** — Crée `app/page.tsx` avec `<QuoteRequestForm>` : champs nom (texte required), email (email required), téléphone (text format français +33 ou 06/07, validé Zod), service_type (Select avec 4 options : conseil, dev, design, autre), budget_range (Select : <2k, 2-5k, 5-10k, >10k), message (Textarea, optional). Submit → POST `/api/quote-request` qui insert dans `quote_requests` (anonyme, owner_id NULL). **Fait quand** : un test E2E Playwright (ou check manuel) confirme qu'un submit avec champs valides crée un row dans Supabase, et qu'un submit avec téléphone invalide affiche un toast d'erreur (pas d'alert).

- [ ] **4. Lien public → admin via owner_id** — Tâche admin manuelle au login : le premier admin qui se connecte voit un bouton "Récupérer les demandes anonymes". Click → RPC Supabase `claim_unowned_quotes()` qui set `owner_id = auth.uid()` sur tous les rows `owner_id IS NULL`. **Fait quand** : un admin nouvellement créé peut récupérer toutes les demandes orphelines en 1 click, et celles-ci passent visibles dans son dashboard.

- [ ] **5. Dashboard liste + Supabase Realtime** — Sur `/dashboard`, liste les `quote_requests` du freelance triés par `created_at desc`. Composant `<QuoteCard>` (shadcn Card avec design tokens) avec nom, type service, budget, statut, date. Active Supabase Realtime sur la table — un nouveau row inséré pendant que l'admin est connecté apparaît sans refresh. **Fait quand** : test manuel en 2 onglets confirme qu'un submit dans l'onglet public fait apparaître la card dans l'onglet admin en moins de 2 secondes.

## Critère de phase complète

- [ ] Toutes les tâches 1 à 5 sont cochées
- [ ] End-to-end : un prospect anonyme soumet une demande → un admin connecté voit la card apparaître en live (Realtime) → aucune fuite RLS (vérifié via `get_advisors`)
- [ ] Lighthouse mobile ≥ 80 sur la page d'accueil formulaire (perf, a11y, best practices)

## Prochaine étape

`/execute phase-1-plan.md`
