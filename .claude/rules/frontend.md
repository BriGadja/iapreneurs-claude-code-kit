---
paths: src/**/*.{ts,tsx}
---

# Règles frontend (auto-chargées sur tout `.ts`/`.tsx` dans `src/`)

> Adapte ou supprime selon ton projet. Ce fichier est un **exemple générique** React + Tailwind + shadcn. Si ton projet n'utilise pas cette stack, remplace le contenu ou supprime le fichier.

## Composants UI

- **Toujours** utiliser shadcn/ui pour les composants standards : `Button`, `Input`, `Dialog`, `Select`, `Toast`. **Jamais** `<button>` / `<input>` bruts pour de l'interaction utilisateur.
- Variantes via `cva` (class-variance-authority), pas de `if (variant === 'primary')` dans le JSX.
- Icônes via `lucide-react` (`<ChevronRight />`), jamais d'emoji dans le JSX.

## Notifications

- Toasts via `sonner` (`toast.success(...)`, `toast.error(...)`).
- **Jamais** `alert()`, `confirm()`, `prompt()` — ces APIs bloquent l'UI et cassent le flow utilisateur.

## Forms & validation

- Validation client + serveur. Le client donne du feedback rapide, le serveur fait foi.
- Schémas via `zod` (`z.object({ ... })`), réutilisés client + serveur.
- React Hook Form (`useForm`) avec `zodResolver` pour le câblage standard.

## État côté client

- Local UI state : `useState`. Cross-component : `useContext` simple. **Pas** de Redux/Zustand sans raison documentée.
- Server state : `@tanstack/react-query` (cache, retry, refetch).

## Styling

- Tailwind utility-first. **Pas** de CSS modules ni de styled-components.
- Pas de classe `bg-blue-500` en dur quand le design system fournit une variable (`bg-primary`).
- Layout : `flex`/`grid` (pas de `float` ni de marges négatives pour caler).

## Types TypeScript

- `strict: true` dans `tsconfig.json` (non négociable).
- `any` interdit. Préfère `unknown` + narrowing si tu ne connais pas le type.
- Types dérivés de Zod (`z.infer<typeof schema>`), pas dupliqués à la main.

## Imports

- Chemins absolus depuis `src/` via alias `@/` (configuré dans `tsconfig.json`).
- Pas d'import `../../../` au-delà de 2 niveaux — refactor.

## Performance

- Server Components Next.js par défaut. `'use client'` uniquement quand strictement nécessaire (interactivité, hooks).
- Images via `next/image`, jamais `<img>` brut (sauf data-URI ou SVG inline).
- `Suspense` + `loading.tsx` pour les fetches côté serveur, pas de spinner global qui flash.
