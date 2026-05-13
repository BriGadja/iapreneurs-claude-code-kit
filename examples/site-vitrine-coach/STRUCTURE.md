# STRUCTURE.md — Site vitrine coach mariage (LITE)

## Arborescence

<!-- architect:directories -->
- `app/page.tsx` — page d'accueil (présentation + CTA contact)
- `app/services/page.tsx` — détail des prestations
- `app/contact/page.tsx` — formulaire de contact + coordonnées
- `components/` — composants réutilisables (Header, Footer, ContactForm)
- `public/` — assets statiques (photos shooting, logo, favicon)
<!-- /architect:directories -->

## Patterns clés

<!-- architect:patterns -->
- Static generation pour les 3 pages (pas de BDD, pas d'auth)
- Formulaire contact via Server Action + Resend (email envoyé à la coach)
- Server Components partout, aucun `use client` sauf interactivité critique
- Photos optimisées via `next/image`
<!-- /architect:patterns -->

## Tests

<!-- architect:tests -->
Pas de tests automatisés (niveau LITE). Vérification manuelle visuelle après chaque modif via Playwright MCP (`browser_navigate` + `browser_take_screenshot`).
<!-- /architect:tests -->

## Conventions d'arborescence

<!-- architect:conventions -->
- Fichiers en kebab-case (`contact-form.tsx`, pas `ContactForm.tsx`)
- Composants React en PascalCase à l'export
- Copy en français — vérifier les accents (é, è, à, ç) avant de pousser
- Pas de pop-up JS (`alert`/`confirm`) — utiliser des toasts si feedback nécessaire
<!-- /architect:conventions -->
