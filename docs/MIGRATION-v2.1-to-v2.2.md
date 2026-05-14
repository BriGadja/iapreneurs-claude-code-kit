# Migration v2.1.x → v2.2.0

Guide rapide pour migrer un projet existant créé avec le kit v2.1.x vers le format v2.2.0.

## Pourquoi migrer ?

v2.2.0 introduit le **PRD vivant discipliné** (cap 100L, format 8 sections) + `docs/specs/SPEC-{date}-{slug}.md` pour les évolutions post-livraison. Le format v2.1.x (`## Phases` linéaire) ne sépare pas la livraison initiale des évolutions.

## Compatibilité backward

`/evoluer`, `/prime` et `/close` détectent automatiquement le format de ton PRD :
- **Nouveau format v2.2** (`## 7. Implementation Phases`) → comportement standard
- **Ancien format v2.1.x** (`## Phases`) → mode legacy (insertion `## Phases`, pas de SPEC)
- **État mixte** (les deux présents) → safe abort, force migration

Tu peux donc rester en v2.1.x indéfiniment. La migration est **opt-in**.

## Procédure migration (3 étapes)

### 1. Restructurer le PRD

Réécrire `PRD.md` en 8 sections (voir `templates/PRD-template.md`) :

1. Vision (depuis ancien `## Sommaire`)
2. Personas (depuis ancien `## Utilisateurs cibles`)
3. **Scope actuel (V_n)** avec sous-sections `### Core` + `### Technique`, checkboxes `[x]` pour ce qui est livré (depuis ancien `## MVP`)
4. **Hors scope (différé)** avec checkboxes `[ ]` (depuis ancien `## Hors-MVP`)
5. Constraints non-négociables (nouveau)
6. Success Criteria (depuis ancien `## Critères de succès`)
7. **Implementation Phases** : une ligne `**V_N (livré le {date})** — {desc}` par phase livrée (depuis ancien `## Phases ✅ Terminée`)
8. Risks & Mitigations (nouveau)

Cap 100 lignes — déporter le surplus vers `docs/specs/` si nécessaire.

### 2. Initialiser `memory/decisions.md` format ADR

Si pas déjà fait, append ADR-001 fondateur avec le stack initial :

```
## ADR-001 — Stack initial
**Status**: Accepted
**Date**: {date du commit initial}
**Context**: {1-2 phrases pourquoi ce projet}
**Decision**: {stack: Next.js + Supabase + ...}
**Consequences**: {1 ligne impact futur}
```

### 3. Préparer `docs/specs/` pour les évolutions à venir

```
mkdir -p docs/specs/
```

À partir de la prochaine évolution, `/evoluer` créera automatiquement `docs/specs/SPEC-{date}-{slug}.md`.

## Vérification post-migration

- `grep "^## 7. Implementation Phases" PRD.md` doit retourner 1 match
- `grep "^## Phases" PRD.md` doit retourner 0 match (sinon état mixte)
- `wc -l PRD.md` doit retourner ≤ 100

## Rollback

`git checkout PRD.md` ramène à la version pré-migration. Les skills v2.2 continueront à fonctionner en mode legacy sur ton ancien PRD.
