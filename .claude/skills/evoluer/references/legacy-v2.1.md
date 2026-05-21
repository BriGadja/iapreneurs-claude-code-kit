# Mode legacy v2.1.x — flow simplifié (Branche 2)

> **Lis ce fichier uniquement si** la détection format PRD du SKILL.md a matché Branche 2 (`## Phases` présent, `## 7. Implementation Phases` absent).
>
> But : préserver la rétrocompat sur les projets créés avec le kit v2.1.x sans forcer la migration. Mode dégradé : pas de SPEC, pas d'ADR, pas de gate /validate forcée.

## Warn initial (à imprimer)

> *"PRD ancien format v2.1.x détecté (`## Phases` au lieu de `## 7. Implementation Phases`). /evoluer va opérer en mode legacy : pas de SPEC, juste insertion d'une nouvelle Phase dans `## Phases`. Pour migrer vers le format v2.2 (SPECs + cap 100L + checkboxes), suivre `docs/MIGRATION-v2.1-to-v2.2.md`."*

## Procédure (7 étapes)

### 1. Parser le numéro de la dernière Phase

```
last_n = grep -oE '^[\-\*]\s+\*\*Phase\s+([0-9]+)\*\*' PRD.md | grep -oE '[0-9]+' | sort -n | tail -1
next_n = last_n + 1
```

### 2. Poser les 3 questions de cadrage (Étape 2 simplifiée)

1. **Nom de la feature** (slug court 4-5 mots)
2. **Description** (1 phrase)
3. **Critère de succès** (1 phrase concrète + vérifiable)

### 3. Vérifier l'idempotence

Grep le nom feature (slug) dans `## Phases`. Si match exact ou très proche → STOP avec message :

> *"Une Phase '{nom feature}' existe déjà (Phase {numéro existant}). Soit tu choisis un autre nom, soit tu édites la Phase existante directement, soit tu confirmes que c'est une nouvelle Phase distincte malgré le nom proche."*

### 4. Insérer la nouvelle Phase dans `## Phases`

Après la dernière Phase trouvée, **avant** la section suivante (`## Stack technique` ou `## Hors-MVP` selon l'ordre du PRD), insère la ligne :

```
- **Phase {N+1}** — {nom feature} : {description}
```

Pas de marker `✅ Terminée` : la phase démarre à l'état "à faire". C'est `/close` qui ajoutera ce marker après `/validate ✅`.

### 5. Append le critère de succès

Dans `## Critères de succès` (à la fin du fichier), append :

```
- [ ] {réponse Q3}
```

À la suite des critères existants, intacts.

### 6. Pas de SPEC, pas d'ADR, pas de gate /validate

Le mode legacy n'a pas les garanties v2.2. Skip :
- création SPEC dans `docs/specs/`
- déplacement checkbox Hors scope (pas de section dédiée en v2.1.x)
- append ADR (à faire manuellement si pertinent)
- gate `/validate` obligatoire avant handoff (recommandée mais pas bloquante)

### 7. Commit + handoff

```
git add PRD.md
git commit -m "feat(/evoluer legacy): Phase {N+1} — {feature}"
```

Affiche le handoff :

```
✅ Évolution préparée (mode legacy v2.1.x) :
   - PRD.md : Phase {N+1} ajoutée dans ## Phases
   - Critère de succès ajouté dans ## Critères de succès

Étapes suivantes :
  1. /close   → commit + STATUS.md
  2. /clear   → contexte vide
  3. /plan Phase {N+1}   → découper en tâches
  4. /execute → implémenter

Astuce : pour bénéficier des garanties v2.2 (SPECs + checkboxes + gate /validate), suis `docs/MIGRATION-v2.1-to-v2.2.md` quand tu auras un moment.
```

## Trace de fin

Même format que le mode standard (lu par /close) :

```json
{"skill": "evoluer", "artifact": "PRD.md (legacy Phase {N+1})", "next": "/plan Phase {N+1}", "ts": "<ISO8601>"}
```
