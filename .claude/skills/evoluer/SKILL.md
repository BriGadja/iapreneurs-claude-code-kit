---
name: evoluer
description: Utiliser sur un projet livré pour ajouter une nouvelle feature (ex : SMS de rappel, dashboard analytics, export PDF). Argument optionnel — un chemin de brief brainstorm (`/evoluer docs/brainstorms/{date}-feature-{slug}.md`) pré-remplit le cadrage. Ne PAS utiliser sur un projet non-livré (utilise `/plan` directement) ni pour modifier une feature existante (édition manuelle).
---

# Skill /evoluer — ajouter une feature à un projet livré

**Cérémonie distincte de `/architect`.** `/architect` construit le PRD fondateur ; `/evoluer` étend un PRD existant sans le réécrire. Le PRD est vivant discipliné (cap 100L) : `/evoluer` ne mute QUE les checkboxes (`[ ]` → `[x]`) et append une ligne dans Implementation Phases. Jamais d'écrasement de section.

## Pour quoi faire

Ton projet est livré (`/livrer` passé, `<!-- ship:url -->` rempli). Tu veux ajouter une feature. `/evoluer` fait ça proprement :

1. Lit le contexte existant (PRD, STRUCTURE, decisions, dernier SPEC, STATUS, brief si fourni)
2. Te pose 3 questions de cadrage
3. Détecte si la feature est dans `## 4. Hors scope` ou pas
4. Détecte les capacités techniques nouvelles (n8n, Google Drive, Stripe, etc.) absentes et lance leur install + validation live (Étape 4bis)
5. Écrit atomiquement : SPEC daté + déplacement checkbox + append phase + append ADR si choix archi
6. Gate `/validate` (tests existants passent encore) AVANT handoff
7. Handoff `/plan docs/specs/SPEC-{date}-{slug}.md` puis `/execute`

## Détection format PRD (4 branches déterministes)

Avant toute autre étape, exécute la détection :

```
has_new = grep -q "^## 7. Implementation Phases" PRD.md
has_old = grep -q "^## Phases" PRD.md
```

| Branche | has_new | has_old | Action |
|---------|---------|---------|--------|
| 1 | ✅ | ❌ | Format v2.2 → comportement standard (Étapes 1-7 ci-dessous) |
| 2 | ❌ | ✅ | Format v2.1.x legacy → **lis `references/legacy-v2.1.md` et applique sa procédure** (flow simplifié, pas de SPEC) |
| 3 | ✅ | ✅ | État mixte (mid-migration) → **SAFE ABORT** |
| 4 | ❌ | ❌ | PRD malformé ou absent → **SAFE ABORT** |

**Messages SAFE ABORT** :
- Branche 3 : *"PRD en état mixte (ancien `## Phases` + nouveau `## 7. Implementation Phases`). /evoluer ne peut pas opérer sans risque de corruption. Termine la migration via `docs/MIGRATION-v2.1-to-v2.2.md` puis relance /evoluer."*
- Branche 4 : *"PRD ne contient ni `## Phases` ni `## 7. Implementation Phases`. Vérifier le PRD avant /evoluer."*

## Étape 1 — vérifier que le projet est livré + prérequis fichiers

1. Lis `CLAUDE.md` et cherche `<!-- ship:url -->`. Si URL réelle → continue. Sinon : prompt utilisateur (*"/evoluer est conçu pour un projet en prod. Confirmer ?"*). Sinon stoppe.
2. Vérifie l'existence de `templates/SPEC-template.md`. Si absent → **STOP** avec message *"Template SPEC manquant à `templates/SPEC-template.md`. /evoluer ne peut pas créer le SPEC sans son template. Restaure-le depuis le kit avant de continuer."* (early fail, évite de planter à l'Étape 5b après les 3 questions).

## Étape 1bis — lire le contexte existant (Read en parallèle)

Lis en parallèle, selon ce qui est passé en argument :

**Toujours** :
- `PRD.md` racine (vision + scope + hors scope)
- `STRUCTURE.md` (état actuel)
- `memory/decisions.md` (derniers ADR-NNN)
- `STATUS.md` (active work)
- Le SPEC le plus récent : `ls docs/specs/SPEC-*.md 2>/dev/null | sort -r | head -1` puis le lire (1 fichier, pas 3 — économie de contexte sur projet mature 10+ SPECs)

**Si l'utilisateur a invoqué `/evoluer docs/brainstorms/{date}-feature-{slug}.md`** :
- Lis ce fichier en entier — il contient déjà le manque résolu, l'intégration UI, les dépendances techniques détectées, l'ampleur S/M/L. Utilise-le pour pré-remplir Q1+Q2+Q3 de l'Étape 2 (tu proposes les réponses extraites du brief, l'utilisateur confirme ou amende).

**Si pas de brief en argument** :
- Lis aussi les 2 SPECs précédents (total 3 derniers SPECs) pour avoir plus de contexte historique sur le projet.

Pas de scan codebase complet : on fait confiance aux artefacts.

## Étape 2 — cadrage feature (3 questions + check Hors scope)

Pose **exactement 3 questions** séquentielles :

1. **Nom de la feature** (slug court 4-5 mots)
2. **Description** (1 phrase)
3. **Critère de succès** (1 phrase concrète + vérifiable)

**Puis check Hors scope** : grep le nom feature (case-insensitive, fuzzy) dans `## 4. Hors scope`.

- **Si match** : *"Cette feature était dans `## 4. Hors scope` (V1 différé). On la déplace vers `## 3. Scope actuel` et on la livre maintenant ?"* → si oui, marquer `move_from_hors_scope = true`.
- **Si pas match** : *"On l'ajoute en `## 3. Scope actuel (V_n+1)` ?"* → `move_from_hors_scope = false`.

## Étape 3 — idempotence

Grep le nom feature dans `## 7. Implementation Phases` ET dans les SPECs existants (filenames `docs/specs/SPEC-*.md`). Si match exact ou très proche → STOP, propose autre nom ou édition manuelle.

## Étape 4 — calculer V_{n+1}

```
max_v = grep -oE "^\*\*V[0-9]+" PRD.md | grep -oE "[0-9]+" | sort -n | tail -1
next_v = max_v + 1
```

Si aucun `**V_N` matché : **warn explicite à l'utilisateur** (*"Aucun marker `**V_N` trouvé dans `## 7. Implementation Phases`. PRD probablement malformé ou jamais évolué. Je continue avec `V_2` (V1 implicite). Vérifie ton PRD si ça te paraît bizarre."*) puis `next_v = 2`.

## Étape 4bis — gate capacités techniques (conditionnelle)

Analyse Q1+Q2+Q3 contre la stack courante (`CLAUDE.md ## Stack` + `.mcp.json`). Cherche les signaux de capacités nouvelles :

| Capacité | Signaux dans la description |
|----------|-----------------------------|
| **n8n** | "workflow", "async", "webhook + traitement long", "PDF + email + storage chaîné", "intégrations multiples", "retry / monitoring externe" |
| **Google Drive / Sheets / Docs / Gmail** | "archive perso", "dossier client", "stockage docs", "spreadsheet", "Google Sheet", "Google Doc", "envoi email perso depuis Gmail" |
| **Stripe** | "paiement", "abonnement", "facture en ligne" |
| **Email transactionnel** (Resend / SendGrid) | "envoi email client à grande échelle", "notification automatisée" |

**Si une capacité est détectée et absente du projet** → **lis `references/mcp-live-gate.md` et applique sa procédure** (install + validation live MCP, bloquant, capé à 3 tentatives). Cette gate empêche `/execute` de planter au premier appel MCP sur un outil pas vraiment installé.

**Si aucune capacité nouvelle détectée** → skip cette étape, passe directement à l'Étape 5.

## Étape 5 — écriture atomique (séquence 5a-5i)

Affiche d'abord la diff complète proposée pour validation utilisateur.

### 5a — Préparer le dossier specs

```
mkdir -p docs/specs/
```

Idempotent.

### 5b — Créer le SPEC

Slug = kebab-case du nom feature (Q1). Path : `docs/specs/SPEC-{YYYY-MM-DD}-{slug}.md`.

**Collision** : si le path existe déjà (deux évolutions le même jour avec slug identique), suffixer `-02`, `-03`... (incrémenter jusqu'à un path libre).

Copier `templates/SPEC-template.md` vers le path et remplir les 4 sections (Feature / Examples / Documentation / Considerations) en utilisant Q1+Q2+Q3 + les éléments du PRD lus à l'Étape 1bis.

### 5c — Checkpoint git (point de retour stable)

```
git add docs/specs/SPEC-{date}-{slug}.md
git commit -m "checkpoint(/evoluer): SPEC créé pour {feature}"
```

Si les étapes 5d-5h échouent partiellement, `git reset --hard HEAD` ramène ici sans perdre le SPEC.

### 5d — Déplacer checkbox Hors scope → Scope actuel (si applicable)

Si `move_from_hors_scope = true` :
- Dans `## 4. Hors scope` : remplacer `- [ ] {feature}` par `- [x] {feature}`
- Déplacer la ligne entière vers `## 3. Scope actuel (V_n)` → sous-section `### Core` (par défaut) ou `### Technique` selon nature (demander si ambigu)

Si `move_from_hors_scope = false` :
- Append `- [ ] {feature}` dans `## 3. Scope actuel (V_n)` → `### Core` (par défaut)

Opération ligne-à-ligne, idempotente (skip si checkbox déjà cochée).

### 5e — Append Implementation Phases

Dans `## 7. Implementation Phases`, append la ligne :

```
**V_{n+1} (en cours)** — {nom feature} (cf docs/specs/SPEC-{date}-{slug}.md)
```

### 5f — Append ADR si choix architectural significatif

Demande à l'utilisateur : *"Cette feature implique-t-elle un choix architectural significatif (nouveau provider, nouveau pattern, changement de stack) qui mérite un ADR dans `memory/decisions.md` ?"*

Si oui : auto-incrément depuis le dernier `ADR-NNN` du fichier. Append :

```
## ADR-{NNN} — {Titre court du choix}
**Status**: Accepted
**Date**: {YYYY-MM-DD}
**Context**: {1-2 phrases du contexte feature}
**Decision**: {1-2 phrases du choix architectural}
**Consequences**: {1 ligne impact futur}
```

### 5g — MAJ STRUCTURE.md si intégrations / key-files changent

Demande : *"Cette feature ajoute des intégrations externes (nouveaux services, APIs) ou des fichiers structurants ? Si oui, lesquelles ?"*

Si oui : update `<!-- structure:integrations -->` et/ou `<!-- structure:key-files -->`. Append également une ligne courte sous `<!-- structure:evolutions-summary -->` :

```
- V_{n+1} ({date}) — {nom feature} : {1-ligne résumé impact structurel}
```

### 5h — Scaffold optionnel `.claude/rules/{domain}.md`

Si la feature introduit un domaine technique nouveau (webhook handling, payment, OAuth, etc.) : propose à l'utilisateur (pas auto) de créer un fichier path-scoped court. Skip par défaut.

### 5i — Commit final (amend du checkpoint)

```
git add -A
git commit --amend -m "feat(/evoluer): {feature} — SPEC + decisions + STRUCTURE + PRD checkbox"
```

Amend du checkpoint 5c pour grouper les changes 5d-5h dans un seul commit logique.

## Étape 6 — Gate /validate (avant handoff)

**OBLIGATOIRE avant handoff.** Appelle `/validate` sur l'état actuel du projet. Métrique = "tests existants passent encore" (Karpathy regression check).

- Si `/validate` PASS → continue Étape 7.
- Si `/validate` FAIL → bloque. Présente les failures à l'utilisateur. Options : (a) fix puis re-/validate, (b) abandonner l'évolution (`git reset --hard HEAD~1` pour défaire le commit /evoluer).

Ne JAMAIS faire handoff vers `/plan` si /validate échoue : c'est une régression introduite par l'état pré-évolution qu'il faut résoudre avant d'ajouter du nouveau code.

## Étape 7 — Handoff

Passe le SPEC (pas le PRD entier) comme input du /plan suivant. Le /plan suivant écrira son output dans `docs/plans/phase-V_{n+1}-plan.md`.

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

## Règles strictes

- **Jamais d'écrasement** de section Implementation Phases ou Scope actuel : uniquement append ou checkbox flip
- **SPEC frozen post-/execute** : header `<!-- frozen: {date} -->` ajouté par /close Étape 6.4
- **Cap 100L PRD** : si après ajout V_{n+1} le PRD dépasse 100L, /close Étape 0.6 va warn (pas bloquer)
- **Gate /validate obligatoire** en mode v2.2 ; skip seulement en mode legacy (voir `references/legacy-v2.1.md`)
- **Atomicité git** : checkpoint après 5c, amend en 5i — un seul commit logique au final

## Quand ne PAS utiliser

- Projet pas encore livré → `/plan` direct sur la prochaine phase du PRD initial
- Modifier une feature existante (scope change) → édition manuelle PRD + SPEC
- Refactor majeur multi-domaines → relancer `/architect` (nouveau PRD)
- PRD état mixte ou malformé → Safe abort, voir Branche 3/4

## Trace de fin

Append `tmp/skill-trace.jsonl` (lue puis supprimée par /close Étape 0 + Étape 0.5.6) :

```json
{"skill": "evoluer", "artifact": "docs/specs/SPEC-{date}-{slug}.md", "next": "/plan docs/specs/SPEC-{date}-{slug}.md", "ts": "<ISO8601>"}
```

**Prochaine étape** : `/close → /clear → /plan docs/specs/SPEC-{date}-{slug}.md → /execute` — voir `docs/KIT.md § Cycle de vie`.
