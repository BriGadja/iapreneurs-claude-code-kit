# Compose commit message (Étape 4)

> **Lis ce fichier à l'Étape 4 du SKILL.md** pour générer le message de commit.
>
> Logique différente selon le mode (planning = auto-commit déterministe, full = dialogue avec l'utilisateur).

## Mode planning — auto-commit sans dialogue (gain ~1-3 min)

Le message est dérivé déterministe-ment du dernier skill du trace.jsonl + l'artefact produit :

| Dernier skill | Template message |
|---------------|------------------|
| `brainstorm` (greenfield) | `chore(plan): brief brainstorm {sujet}` |
| `brainstorm` (feature mode) | `chore(plan): brief feature {slug} pour évaluation` |
| `architect` | `chore(plan): PRD initial + stack définie` |
| `evoluer` | `chore(plan): SPEC {slug} + V_{n+1} PRD checkbox` |
| `plan` | `chore(plan): {artifact-basename} découpé en tâches` |
| `challenge` | `chore(plan): challenge {target} — verdict {GO/NO-GO}` |

Affiche le message dans le handoff (Étape 7) — pas de prompt de validation. Si l'user veut amender, il le fait au prochain `/close` ou via `git commit --amend` manuellement. Mode planning = confiance par défaut.

## Mode full — dialogue de validation maintenu

Lance `git status` et `git diff --stat` pour voir ce qui a changé. Propose un message conventionnel :

```
{type}({scope}): {what} — {why en 1 phrase}
```

- **type** : `feat` (nouveau), `fix` (bug), `chore` (admin/config), `refactor`, `docs`, `test`
- **scope** : nom de la feature ou du module (ex: `auth`, `dashboard`, `n8n`)
- **what** : ce qui a changé (impératif, ex: "ajoute upload de transcripts")
- **why** : la raison (en 1 phrase, lisible par toi-même dans 3 mois)

Exemple :
```
feat(hub-documents): Phase 1 — UI shell + Supabase auth — base technique pour les phases 2-5
```

Affiche le message dans le chat :

> "Voilà le commit que je propose :
>
> ```
> {type}({scope}): Phase {N} — {what} — {why}
> ```
>
> Tu valides, ou tu veux ajuster ?"

Itère jusqu'à validation.

## Retour au SKILL.md

Une fois le message validé (full) ou dérivé (planning), retourne à l'Étape 5 du SKILL.md (commit).
