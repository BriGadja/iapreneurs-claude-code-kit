# `.claude/rules/` — règles auto-chargées par chemin

## Le pattern en une phrase

Chaque fichier `.md` ici a un **frontmatter `paths:`** qui définit quand Claude doit charger ce fichier. Quand tu (ou Claude) ouvre un fichier qui match le pattern, Claude charge automatiquement la règle correspondante en plus du `CLAUDE.md` principal.

## Pourquoi c'est utile

Le `CLAUDE.md` est le cerveau global du projet. Si tu y entasses TOUTES tes règles — front, back, n8n, conventions générales — il devient :
- **Long** (plus de 200 lignes lues à chaque session, ça coûte en tokens)
- **Hors-sujet la plupart du temps** (Claude n'a pas besoin de tes règles n8n quand il modifie du CSS)

Les règles path-scoped résolvent ça : elles ne se chargent **que quand elles sont pertinentes**.

## Format d'un fichier de règle

```markdown
---
paths: src/**/*.{ts,tsx}
---

# Règles frontend

- Toujours shadcn/ui pour les composants UI standard (bouton, input, dialog) — jamais `<button>` brut.
- Toasts via `sonner`, jamais `alert`/`confirm`/`prompt`.
- Date au format `JJ/MM/AAAA` côté UI (helper `formatDate` dans `src/lib/format.ts`).
- ...
```

Le `paths:` accepte les patterns globs standards :
- `src/**/*.{ts,tsx}` — tous les TS/TSX dans `src/`
- `**/*.workflow.json` — tous les workflows n8n exportés
- `app/**/page.tsx` — toutes les pages Next.js App Router
- `supabase/migrations/**/*.sql` — toutes les migrations Supabase

## Exemples fournis dans ce kit

- `frontend.md` — règles génériques React + Tailwind + shadcn (à adapter ou remplacer)

## Quand créer un fichier de règle

**Bon signe** : tu te retrouves à écrire 5+ règles d'affilée dans `CLAUDE.md ## Conventions` ou `## Instructions` qui ne concernent qu'un domaine précis (ex: 8 règles React). Déporte-les ici.

**Mauvais signe** (ne pas faire de fichier de règle) : 1 ou 2 règles isolées qui s'appliquent partout. Reste dans `CLAUDE.md`.

## Ne pas confondre avec

- **Skills** (`.claude/skills/`) : workflows réutilisables invoquables (`/start`, `/plan`, etc.)
- **Sous-agents** (`.claude/agents/`) : entités déléguables avec leur propre fenêtre de contexte
- **Règles** (`.claude/rules/`) : contenu auto-injecté dans le contexte de la session quand un fichier matching est touché

## Limites

Les règles auto-chargées sont en CLI Claude Code uniquement (pas dans la web app ou desktop). Si tu travailles en équipe et que certains coéquipiers ne lisent pas les règles, garde les **vraiment critiques** (sécurité, RLS, etc.) dans `CLAUDE.md` même si c'est répétitif.
