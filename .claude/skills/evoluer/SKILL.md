---
name: evoluer
description: Utiliser quand un projet est livré (PRD format v2.2 avec sections Scope actuel/Hors scope/Implementation Phases, ou format v2.1.x legacy avec ## Phases) et que tu veux ajouter une nouvelle feature. Cérémonie distincte de /architect — ne mute jamais le PRD destructivement, déplace uniquement les checkboxes Hors scope → Scope actuel et crée un SPEC daté dans docs/specs/. Ne PAS utiliser sur un projet non-livré ni pour modifier une feature existante.
---

# Skill /evoluer — ajouter une feature à un projet livré (cérémonie distincte)

**Cérémonie distincte de `/architect`.** `/architect` construit le PRD fondateur ; `/evoluer` étend un PRD existant sans le réécrire. Le PRD est vivant discipliné (cap 100L) : `/evoluer` ne mute QUE les checkboxes (`[ ]` → `[x]`) et append une ligne dans Implementation Phases — jamais d'écrasement de section, jamais de réécriture destructive.

## Pour quoi faire

Ton projet est livré (`/livrer` passé, `<!-- ship:url -->` rempli). Tu veux ajouter une feature : SMS de rappel, dashboard analytics, export PDF.

`/evoluer` fait ça proprement :
1. Lit le contexte existant (PRD, STRUCTURE, decisions, 3 derniers SPECs, STATUS)
2. Te pose 3 questions de cadrage
3. Détecte si la feature est dans `## 4. Hors scope` ou pas
4. Écrit atomiquement : SPEC daté + déplacement checkbox + append phase + append ADR si choix archi
5. Gate `/validate` (tests existants passent encore) AVANT handoff
6. Handoff `/plan docs/specs/SPEC-{date}-{slug}.md` → `/execute`

## Détection format PRD (4 branches déterministes)

Avant toute autre étape, exécute la détection :

```
has_new = grep -q "^## 7. Implementation Phases" PRD.md
has_old = grep -q "^## Phases" PRD.md
```

| Branche | has_new | has_old | Action |
|---------|---------|---------|--------|
| 1 | ✅ | ❌ | Nouveau format v2.2 → comportement standard (Étapes 1bis-7 ci-dessous) |
| 2 | ❌ | ✅ | Ancien format v2.1.x → mode legacy (voir § Mode legacy) |
| 3 | ✅ | ✅ | État mixte (mid-migration) → **SAFE ABORT** |
| 4 | ❌ | ❌ | PRD malformé ou absent → **SAFE ABORT** |

**Messages SAFE ABORT** :
- Branche 3 : *"PRD en état mixte (ancien `## Phases` + nouveau `## 7. Implementation Phases`). /evoluer ne peut pas opérer sans risque de corruption. Termine la migration via `docs/MIGRATION-v2.1-to-v2.2.md` puis relance /evoluer."*
- Branche 4 : *"PRD ne contient ni `## Phases` ni `## 7. Implementation Phases`. Vérifier le PRD avant /evoluer."*

## Étape 1 — vérifier que le projet est livré

Lis `CLAUDE.md` et cherche `<!-- ship:url -->`. Si URL réelle → continue. Sinon : prompt utilisateur ("/evoluer est conçu pour un projet en prod. Confirmer ?"). Sinon stoppe.

## Étape 1bis — lire le contexte existant (Read en parallèle)

Lis en parallèle, sans relire brainstorm/research from-zero :

- `PRD.md` racine (vision + scope + hors scope)
- `STRUCTURE.md` (état actuel)
- `memory/decisions.md` (derniers ADR-NNN)
- Les 3 SPECs les plus récents : `ls docs/specs/SPEC-*.md 2>/dev/null | sort -r | head -3` puis lire chacun
- `STATUS.md` (active work)

Ces 5 lectures constituent le contexte d'évolution. Pas de scan codebase complet ; on fait confiance aux artefacts.

## Étape 2 — cadrage feature (3 questions + check Hors scope)

Pose **exactement 3 questions** séquentielles :

1. **Nom de la feature** (slug court 4-5 mots)
2. **Description** (1 phrase)
3. **Critère de succès** (1 phrase concrète + vérifiable)

**Puis check Hors scope** : grep le nom feature (case-insensitive, fuzzy) dans `## 4. Hors scope`.

- **Si match** : *"Cette feature était dans `## 4. Hors scope` (V1 différé). On la déplace vers `## 3. Scope actuel` et on la livre maintenant ?"* → si oui, marquer `move_from_hors_scope = true`.
- **Si pas match** : *"On l'ajoute en `## 3. Scope actuel (V_n+1)` ?"* → `move_from_hors_scope = false`.

## Étape 3 — idempotence

Grep le nom feature dans `## 7. Implementation Phases` ET dans les SPECs existants (`docs/specs/SPEC-*.md` filenames). Si match exact ou très proche → STOP, propose autre nom ou édition manuelle.

## Étape 4 — calculer V_{n+1}

```
max_v = grep -oE "^\*\*V[0-9]+" PRD.md | grep -oE "[0-9]+" | sort -n | tail -1
next_v = max_v + 1
```

Si aucun `**V_N` matché : `next_v = 2` (le PRD initial = V1 implicite).

## Étape 5 — écriture atomique (séquence 5a-5h)

Affiche d'abord la diff complète proposée pour validation utilisateur.

### 5a — Préparer le dossier specs

```
mkdir -p docs/specs/
```

Idempotent.

### Étape 5b — Créer le SPEC
**Atomicité : checkpoint git commit immédiatement après création SPEC** (voir 5h pour la commande). Le SPEC créé est le point de retour stable du checkpoint.

Slug = kebab-case du nom feature (Q1). Path : `docs/specs/SPEC-{YYYY-MM-DD}-{slug}.md`.

**Collision** : si le path existe déjà (2 évolutions le même jour avec slug identique), suffixer `-02`, `-03`... (incrémenter jusqu'à trouver un libre). Convention documentée dans `docs/KIT.md § Cycle de vie`.

Copier `templates/SPEC-template.md` vers le path et remplir les 4 sections (Feature / Examples / Documentation / Considerations) en utilisant Q1+Q2+Q3 + les éléments du PRD lus à l'Étape 1bis.

### 5h — Checkpoint git (atomicité)

```
cd <project-root> && git add docs/specs/SPEC-{date}-{slug}.md && git commit -m "checkpoint(/evoluer): SPEC créé pour {feature}"
```

Point de retour stable. Si 5c-5g échouent partiellement, `git reset --hard HEAD` ramène ici sans perdre le SPEC.

### 5c — Déplacer checkbox Hors scope → Scope actuel (si applicable)

Si `move_from_hors_scope = true` :
- Dans `## 4. Hors scope` : remplacer `- [ ] {feature}` par `- [x] {feature}`
- Déplacer la ligne entière vers `## 3. Scope actuel (V_n)` → sous-section `### Core` (par défaut) ou `### Technique` selon nature (demander si ambigu)

Si `move_from_hors_scope = false` :
- Append `- [ ] {feature}` dans `## 3. Scope actuel (V_n)` → `### Core` (par défaut).

Opération ligne-à-ligne, idempotente (skip si checkbox déjà cochée).

### 5d — Append Implementation Phases

Dans `## 7. Implementation Phases`, append la ligne :

```
**V_{n+1} (en cours)** — {nom feature} (cf docs/specs/SPEC-{date}-{slug}.md)
```

### 5e — Append ADR si choix architectural significatif

Demande à l'utilisateur (LLM jugement) : *"Cette feature implique-t-elle un choix architectural significatif (nouveau provider, nouveau pattern, changement de stack) qui mérite un ADR dans `memory/decisions.md` ?"*

Si oui : auto-incrément depuis le dernier `ADR-NNN` du fichier. Append :

```
## ADR-{NNN} — {Titre court du choix}
**Status**: Accepted
**Date**: {YYYY-MM-DD}
**Context**: {1-2 phrases du contexte feature}
**Decision**: {1-2 phrases du choix architectural}
**Consequences**: {1 ligne impact futur}
```

### 5f — MAJ STRUCTURE.md si intégrations / key-files changent

Demande : *"Cette feature ajoute des intégrations externes (nouveaux services, APIs) ou des fichiers structurants ? Si oui, lesquelles ?"*

Si oui : update `<!-- structure:integrations -->` et/ou `<!-- structure:key-files -->`. Append également une ligne courte sous `<!-- structure:evolutions-summary -->` :

```
- V_{n+1} ({date}) — {nom feature} : {1-ligne résumé impact structurel}
```

### 5g — Scaffold optionnel `.claude/rules/{domain}.md`

Si la feature introduit un domaine technique nouveau (webhook handling, payment, OAuth, etc.) : propose à l'utilisateur (pas auto) de créer un fichier path-scoped court. Skip par défaut.

### Commit final

```
git commit --amend -m "feat(/evoluer): {feature} — SPEC + decisions + STRUCTURE + PRD checkbox"
```

(amend du checkpoint 5h pour grouper les changes 5c-5g dans le même commit logique).

## Étape 6 — Gate /validate (avant merge)

**OBLIGATOIRE avant handoff.** Appeler `/validate` (slash invocation) sur l'état actuel du projet. Métrique = "tests existants passent encore" (Karpathy regression check).

- Si `/validate` PASS → continue Étape 7.
- Si `/validate` FAIL → bloquer. Présenter les failures à l'utilisateur. Options : (a) fix puis re-/validate, (b) abandonner l'évolution (`git reset --hard HEAD~1` pour défaire le commit /evoluer).

Ne JAMAIS faire handoff vers `/plan` si /validate échoue — c'est une régression introduite par l'état pré-évolution qu'il faut résoudre avant d'ajouter du nouveau code.

## Étape 7 — Handoff

Passer le SPEC (pas le PRD entier) comme input du /plan suivant. Le /plan suivant écrira son output dans `docs/plans/phase-V_{n+1}-plan.md` (convention v2.1.0+).

```
✅ Évolution préparée :
   - docs/specs/SPEC-{date}-{slug}.md créé (frozen après /execute)
   - PRD V_{n+1} (en cours) ajouté
   - memory/decisions.md : ADR-{NNN} (si applicable)
   - STRUCTURE.md mis à jour (si applicable)

Étapes suivantes pour repartir propre :
  1. /close   → commit + STATUS.md
  2. /clear   → contexte vide
  3. /plan docs/specs/SPEC-{date}-{slug}.md   → découper en tâches (output: docs/plans/phase-V_{n+1}-plan.md)
  4. /execute → implémenter
```

## Mode legacy (Branche 2 — format v2.1.x avec `## Phases`)

Si détecté à l'init : **warn explicite** :

> *"PRD ancien format v2.1.x détecté (`## Phases` au lieu de `## 7. Implementation Phases`). /evoluer va opérer en mode legacy : pas de SPEC, juste insertion d'une nouvelle Phase dans `## Phases`. Pour migrer vers le format v2.2 (SPECs + cap 100L + checkboxes), suivre `docs/MIGRATION-v2.1-to-v2.2.md`."*

Fallback complet à l'ancien comportement :
1. Parser `## Phases` pour trouver le dernier `**Phase N**` (regex `^[\-\*]\s+\*\*Phase\s+(\d+)\*\*`)
2. 3 questions cadrage (Étape 2 simplifiée)
3. Idempotence (Étape 3)
4. Insérer la ligne `- **Phase N+1** — {nom} : {description}` après la dernière Phase
5. Append `- [ ] {critère}` dans `## Critères de succès`
6. Pas de SPEC, pas d'ADR, pas de Gate /validate forcé (mode legacy = pas de garanties v2.2)
7. Handoff : `/plan Phase N+1` (pas SPEC path)

## Règles strictes

- **Jamais d'écrasement** de section Implementation Phases ou Scope actuel — uniquement append ou checkbox flip
- **SPEC frozen post-/execute** — header `<!-- frozen: {date} -->` ajouté par /close Étape 6.4
- **Cap 100L PRD** — si après ajout V_{n+1} le PRD dépasse 100L, /close Étape 0.6 va warn (pas bloquer)
- **Gate /validate obligatoire** mode v2.2 ; skip seulement en mode legacy
- **Atomicité git** : checkpoint après 5b, amend après 5g — un seul commit logique au final

## Quand ne PAS utiliser

- Projet pas encore livré → `/plan` direct sur la prochaine phase du PRD initial
- Modifier une feature existante (scope change) → édition manuelle PRD + SPEC
- Refactor majeur multi-domaines → relancer `/architect` (nouveau PRD)
- PRD état mixte ou malformé → Safe abort, voir Branche 3/4

## Trace de fin

Append `tmp/skill-trace.jsonl` :

```json
{"skill": "evoluer", "artifact": "docs/specs/SPEC-{date}-{slug}.md", "next": "/plan docs/specs/SPEC-{date}-{slug}.md", "ts": "<ISO8601>"}
```

**Prochaine étape** : `/close → /clear → /plan docs/specs/SPEC-{date}-{slug}.md → /execute` — voir `docs/KIT.md § Cycle de vie`.
