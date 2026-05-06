---
name: execute
description: Utiliser pour exécuter un fichier `phase-{N}-plan.md` créé par /plan. Coche les tâches au fur et à mesure, marque la phase ✅ Terminée dans le PRD parent à la fin. Ne PAS utiliser sans plan — créer le plan d'abord avec /plan.
---

# Skill /execute — exécuter un plan tâche par tâche

## Pour quoi faire

Tu prends un fichier `phase-{N}-plan.md` et tu **fais** ce qu'il dit. Une tâche, puis la suivante. Tu coches `[x]` quand c'est fini. À la fin de la phase, tu marques la phase comme **✅ Terminée** dans le PRD parent.

## Règles strictes

1. **Une tâche à la fois**. Pas 3 en parallèle. Pas en avance sur la suivante.
2. **Cocher la case `[x]`** dans le fichier `phase-{N}-plan.md` **à chaque** tâche finie.
3. **Vérifier le critère "Fait quand"** avant de cocher. Si le critère n'est pas vérifié, la tâche n'est pas finie.
4. **Pas d'improvisation**. Si tu vois un truc à améliorer hors plan, **note-le** dans la section "Découvertes" en bas du fichier mais ne le fais pas. Le scope du plan, c'est le scope.
5. Si une tâche **ne peut pas être finie** (manque info, blocage technique), arrête-toi et demande à l'utilisateur.

## Comment procéder

### Étape 1 — lire le plan + le PRD

Lire `phase-{N}-plan.md` passé en argument. Lire aussi le PRD parent (mentionné dans le header du plan) pour avoir le contexte global.

### Étape 2 — pour chaque tâche dans l'ordre

Boucle sur les tâches `[ ]` non cochées :

1. **Annoncer** : "Je commence la tâche {N} : {nom}."
2. **Faire** ce qu'il faut (créer fichiers, configurer services, etc.)
3. **Vérifier le critère "Fait quand"** :
   - Si commande à lancer → la lancer, vérifier la sortie
   - Si fichier à créer → vérifier qu'il existe + ouvrir + scanner
   - Si test à passer → lancer le test, vérifier exit code
4. **Si critère vérifié** → cocher `[x]` dans le fichier `phase-{N}-plan.md`
5. **Si critère non vérifié** → corriger, retenter (max 3 fois). Si échec persistant → arrêter et demander.

### Étape 3 — phase complète

Quand toutes les tâches sont `[x]` :
1. Vérifier le **critère de phase complète** (en bas du plan)
2. Si OK → marquer la phase **✅ Terminée** dans le PRD parent (section Phases) :
   ```
   - **Phase 1** — Nom : description ✅ Terminée le YYYY-MM-DD
   ```
3. Annoncer à l'utilisateur : "Phase {N} terminée. Tu veux que je passe à `/validate` ou `/plan` Phase {N+1} ?"

## Risque #1 — sauter le critère "Fait quand"

C'est le risque le plus fréquent : tu codes vite, tu coches la case sans vérifier. Résultat : 3 tâches plus tard, t'as une régression et tu perds 2h à débugger.

**Test du miroir** : avant de cocher `[x]`, tu dois avoir **vu** la sortie d'une commande ou **lu** un fichier. Pas "je l'ai créé je suppose que ça marche". Tu lances, tu lis, tu coches.

## Si tu casses un truc

Si pendant l'exécution un test/build/feature qui marchait avant **casse** :
1. **Stop**. Ne passe pas à la tâche suivante.
2. **Identifie ce qui a cassé**. Lis l'erreur, pas juste le titre.
3. **Cherche la cause racine**. Pas un patch qui masque le problème.
4. **Corrige**.
5. **Re-vérifie** la tâche en cours et celle d'avant.

Cf. règle de comportement #4 (orienté but) du `CLAUDE.md`.

## Découvertes en cours d'exécution

Si tu remarques un truc à améliorer hors plan (refactor, bug existant, opportunité), **ne le fais pas**. Note-le en bas du fichier `phase-{N}-plan.md` :

```markdown
## Découvertes (hors plan)

- 2026-XX-XX : `src/api.ts` a du code mort lignes 40-55, à nettoyer plus tard.
- 2026-XX-XX : la fonction `formatDate` est dupliquée dans 3 fichiers, à refactor.
```

L'utilisateur décidera plus tard s'il veut ouvrir un nouveau plan dessus.

## Quand ne PAS utiliser ce skill

- Pas de fichier plan → `/plan` d'abord
- Tâche unique non planifiée → fais-la directement
- Le plan a 0 tâche cochable (juste de la doc) → pas un /execute

## Handoff

Fin du skill : annonce phase terminée + suggestion `/validate phase-{N}-plan.md`.
