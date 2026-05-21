# Mode detection (Étape 0)

> **Lis ce fichier au début de chaque `/close`.**
>
> But : décider du mode d'exécution (no-op / planning / full) avant toute action. Évite de dérouler la cérémonie complète sur un projet sans diff, ou de lancer un audit caps sur un simple commit de plan.

## 0.1 — Lire la trace `tmp/skill-trace.jsonl`

Chaque skill du kit append une ligne JSON à sa fin :
`{"skill":"plan","artifact":"docs/plans/foo.md","next":"/execute foo","ts":"<ISO8601>"}`

- Si > 10 lignes accumulées → alerter : *"Trop de skills depuis le dernier /close (N lignes) — tu as peut-être oublié de clôturer une étape précédente."* Poursuit avec les **10 dernières lignes**.
- Si fichier absent ou vide → trace vide (cas projet neuf ou /close juste précédent).

## 0.2 — Calculer le diff git

Union pour catch staged + untracked + modified + récent :
- `git status --porcelain` (staged, modifié, untracked)
- `git diff --name-only HEAD~1..HEAD` (commits récents)
- **Fallback** si `git rev-parse --verify HEAD` échoue (projet sans aucun commit) → traiter comme mode **full** (premier commit). Le no-op n'est pas possible avant le premier commit.
- **Fallback** si `HEAD~1` inexistant (1 seul commit) → utiliser `git diff --cached --name-only`.

## 0.3 — Définir les chemins de planning

Toutes les modifs qui matchent ces patterns = planning-only :
```
plans/, docs/plans/, docs/brainstorms/, research/,
PRD.md, STATUS.md, memory/daily/
```

## 0.4 — Décider du mode

- Trace vide **ET** diff vide → mode **no-op** → affiche : *"Rien à clôturer. Aucun fichier modifié et aucun skill récent. Tu peux `/clear` directement."* → **fin du skill** (skip toutes les étapes suivantes).
- Tous les fichiers du diff matchent `planning_paths` → mode **planning** (rapide).
- Sinon → mode **full** (fin de phase).

## 0.5 — Annoncer

*"Mode détecté : **{mode}**. {explication 1-ligne}"*.

## Conséquences pour la suite du SKILL.md

| Mode | Étapes 0.5 (STATUS) | Étape 0.6 (caps) | Étapes 1-3 (PRD) | Étape 4-5 (commit) | Étape 6 (harvest) | Étape 6.5 (gate deploy) |
|------|---------------------|------------------|------------------|--------------------|--------------------|-------------------------|
| no-op | skip | skip | skip | skip | skip | skip |
| planning | run | skip (silencieux) | skip | auto-commit (pas de dialogue) | skip 6.2-6.3 (mining marker) | conditionnel comme full |
| full | run | run | run | dialogue + amend SHA | run conditionnel (triggers) | conditionnel |

## Retour au SKILL.md

Selon le mode décidé :
- **no-op** → handoff direct, fin du skill
- **planning** → Étape 0.5 (STATUS.md sans amend SHA) + Étape 4-5 auto-commit + Étape 7
- **full** → enchaînement complet Étapes 0.5 → 7
