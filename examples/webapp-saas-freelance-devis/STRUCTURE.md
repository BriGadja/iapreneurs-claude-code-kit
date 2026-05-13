# STRUCTURE.md — Webapp SaaS freelance devis (STANDARD)

## Arborescence

<!-- architect:directories -->
- `src/app/(public)/` — pages publiques (landing, login, signup)
- `src/app/(dashboard)/` — pages auth-protected (liste devis, création, paramètres)
- `src/components/ui/` — composants shadcn (Button, Input, Dialog…)
- `src/components/devis/` — composants métier (QuoteForm, QuotePreview, LineItemRow)
- `src/lib/supabase/` — clients Supabase (`browser.ts`, `server.ts`, helpers RLS)
- `src/lib/pdf/` — génération devis PDF (react-pdf templates)
- `supabase/migrations/` — migrations SQL versionnées
<!-- /architect:directories -->

## Patterns clés

<!-- architect:patterns -->
- RSC pour toutes les pages auth-protected (auth check côté serveur via `@supabase/ssr`)
- Server Actions pour CRUD devis (create/update/delete) — pas de Route Handler sauf webhook
- Supabase RLS strict sur table `quotes` : un freelance ne voit que ses propres devis
- Validation Zod aux frontières (`schema.parse` sur tous les inputs Server Action)
- Génération PDF via `react-pdf` côté serveur, retournée en Response stream
<!-- /architect:patterns -->

## Tests

<!-- architect:tests -->
- Vitest unitaires pour les utils de `src/lib/` (calculs HT/TVA/TTC, formattage devises)
- Playwright E2E pour le parcours critique : signup → création devis → preview PDF → envoi email
- Lancement : `npm test` (Vitest) et `npm run e2e` (Playwright)
- Tests co-located : `lib/format.test.ts` à côté de `lib/format.ts`
<!-- /architect:tests -->

## Conventions d'arborescence

<!-- architect:conventions -->
- Composants shadcn de base dans `components/ui/`, composants métier dans `components/devis/`
- Fichiers en kebab-case (`quote-form.tsx`), composants React en PascalCase
- `use client` uniquement quand nécessaire (formulaires interactifs, dialogs)
- Devises en EUR uniquement, format `1 234,56 EUR` (helper `formatMoney` dans `lib/format.ts`)
<!-- /architect:conventions -->
