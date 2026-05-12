---
name: evoluer
description: Utiliser quand un projet est livré (toutes phases ✅ Terminée, /livrer passé) et que tu veux ajouter une nouvelle feature. Mini-/architect ciblé : 3 questions de cadrage feature, insertion idempotente d'une Phase N+1 dans le PRD existant sans écraser les Phases ✅ Terminée, handoff vers /plan. Ne PAS utiliser sur un projet non-livré (utilise /plan Phase suivante directement) ni pour modifier une Phase existante (édite manuellement).
---

# Skill /evoluer — ajouter une feature à un projet livré

## Pour quoi faire

Ton projet est livré (`/livrer` passé, `<!-- ship:url -->` rempli, toutes les phases du PRD `✅ Terminée`). Tu veux ajouter une feature : envoyer un SMS de rappel, ajouter un dashboard analytics, intégrer un nouveau provider.

Tu ne devrais **PAS éditer le PRD à la main** — risque de casser le format que les autres skills (`/recap`, `/plan`, `/close`) parsent. `/evoluer` fait l'insertion proprement :
1. Parse le PRD existant pour trouver le dernier numéro de Phase
2. Te pose 3 questions de cadrage feature
3. Insère une nouvelle Phase au bon endroit, sans écraser
4. Handoff vers `/plan Phase {N+1}` pour le découpage en tâches

## Règle stricte

**Jamais d'écrasement de Phase existante.** Les Phases `✅ Terminée` sont immutables — leur ligne ne change pas. La nouvelle Phase est insérée **après** la dernière Phase et **avant** la section suivante (`## Stack technique` ou `## Hors-MVP`).

## Comment procéder

### Étape 1 — vérifier que le projet est livré (optionnel mais conseillé)

Lis `CLAUDE.md` et cherche `<!-- ship:url -->`. Si le bloc contient une URL réelle (pas le placeholder), le projet est en prod → contexte clair pour `/evoluer`.

Si pas d'URL prod et phases pas toutes `✅` → demande à l'utilisateur :
> *"Je ne vois pas de trace d'un projet livré (`<!-- ship:url -->` vide). `/evoluer` est conçu pour ajouter une feature à un projet DÉJÀ en prod. Si ta dernière phase n'est pas encore terminée, lance plutôt `/plan Phase {N+1}` direct sans passer par `/evoluer`. Tu confirmes que tu veux ajouter une nouvelle Phase quand même ?"*

Si l'utilisateur confirme malgré tout → continue. Sinon stoppe.

### Étape 2 — parser le PRD pour trouver le dernier numéro de Phase

Lis `PRD.md` à la racine.

**2.1 — Détecter le format des Phases**. Cherche dans la section `## Phases` les lignes qui matchent le regex (bullet style standard du template kit) :

```
^[\-\*]\s+\*\*Phase\s+(\d+)\*\*\s+—
```

Récupère tous les numéros matchés. Le **dernier numéro + 1** est le numéro de la nouvelle Phase.

**2.2 — Gérer les cas d'échec parse** :

- **Aucune Phase matchée** → soit le PRD n'a pas de section `## Phases`, soit le format est non-standard (H2 au lieu de bullet, autre style). **STOPPE** avec le message :
  > *"PRD.md ne suit pas le format bullet standard `- **Phase N** — ...`. Tu as deux options : (a) édite manuellement ton PRD pour aligner le format, ou (b) lance `/architect` pour repartir d'un PRD propre. Pas de fallback silencieux."*
- **Section `## Phases` absente** → même message, même STOP.
- **Numéros non-séquentiels (ex: 1, 2, 4 sans 3)** → utilise quand même le max + 1 (donc 5), pas le premier trou. Annonce-le à l'utilisateur : *"Les Phases existantes sont 1, 2, 4 (pas 3). J'ajoute Phase 5. C'est OK ?"*

### Étape 3 — 3 questions de cadrage feature

Pose **exactement 3 questions**, une par une (pas en bloc — attendre la réponse) :

1. **Nom de la feature** : *"Comment tu nommes cette nouvelle feature (slug court, max 4-5 mots) ? Exemple : 'Rappel SMS clients', 'Dashboard analytics', 'Export PDF facture'."*
2. **Description courte** : *"En une phrase, qu'est-ce que cette feature fait ? Tu écris ça comme tu l'expliquerais à un IAPreneur dans 6 mois."*
3. **Critère de succès** : *"Quel est LE critère qui fait que cette feature est réussie ? Une phrase concrète et vérifiable (ex: 'Un SMS arrive sur le téléphone du client dans les 5 minutes après son RDV')."*

Stocke les 3 réponses.

### Étape 4 — vérifier l'idempotence

Avant d'écrire, **grep dans `## Phases`** pour voir si le nom de la feature existe déjà (case-insensitive, fuzzy : si "Rappel SMS clients" et déjà "Rappels par SMS aux clients", c'est suffisamment proche pour alerter).

Si match → STOP avec :
> *"Une Phase '{nom proposé}' existe déjà (Phase {numéro existant}, ligne : {ligne PRD}). Soit tu choisis un autre nom, soit tu édites la Phase existante directement, soit tu confirmes que c'est une nouvelle Phase distincte malgré le nom proche."*

Si l'utilisateur confirme distinction → continue. Sinon, repose la Q1.

### Étape 5 — afficher la diff proposée, valider, écrire

Compose les 2 modifications à appliquer au PRD :

**Modif 1 — Section `## Phases`** : insère la nouvelle ligne **après** la dernière Phase existante :
```
- **Phase {N+1}** — {nom Q1} : {description Q2}
```

**Modif 2 — Section `## Critères de succès`** : append à la fin :
```
- [ ] {critère Q3}
```

Affiche la diff complète à l'utilisateur **avant d'écrire** :
> *"Voilà ce que je vais ajouter dans `PRD.md` :*
> *Dans `## Phases` (juste après Phase {N}) :*
> *`- **Phase {N+1}** — {nom} : {description}`*
> *Dans `## Critères de succès` (à la fin) :*
> *`- [ ] {critère}`*
> *Tu valides ou tu veux ajuster ?"*

Itère jusqu'à validation. **Puis** écris dans `PRD.md` aux deux endroits, sans toucher au reste.

### Étape 6 — handoff vers `/plan`

Annonce :
> *"`PRD.md` mis à jour : Phase {N+1} '{nom}' ajoutée. Prochaine étape : `/plan Phase {N+1}` pour découper en tâches concrètes.*
> *(Si la feature touche l'UI et que tu utilises `/design`, jette aussi un œil à `DESIGN.md` pour voir si les composants existants couvrent ou si tu dois en ajouter.)"*

## Risque #1 — écraser une Phase ✅ Terminée

C'est le risque principal. Mitigations :
- Étape 4 : check idempotence sur le nom
- Étape 5 : diff montrée AVANT écriture
- L'insertion est **uniquement** après la dernière ligne Phase, jamais au milieu
- **Test du miroir** : avant d'écrire, tu dois pouvoir citer (a) le numéro de la dernière Phase trouvée, (b) la ligne EXACTE de cette dernière Phase. Si tu ne peux pas, tu n'écris pas.

## Risque #2 — PRD malformé non détecté

Si le PRD a un format non-standard que ton regex ne match pas, mais que tu insères quand même "à l'aveugle" en fin de fichier, tu casses la structure. Mitigations :
- Étape 2.2 : STOP si aucune Phase matchée, pas de fallback
- Le message d'erreur propose 2 actions concrètes (édition manuelle ou `/architect`)

## Quand ne PAS utiliser ce skill

- Projet pas encore livré → `/plan Phase {N+1}` direct
- Modifier une Phase existante (changement de scope) → édite manuellement le PRD (l'utilisateur sait ce qu'il change)
- Refactor majeur qui touche plusieurs phases → relance `/architect` pour repartir d'un PRD étendu
- Nouvelle feature ÉNORME (3+ phases nécessaires) → `/architect` plutôt que `/evoluer`

## Handoff

Fin du skill :

```markdown
## ✅ Phase {N+1} '{nom}' ajoutée au PRD

- **Description** : {description Q2}
- **Critère de succès** : {critère Q3}
- **Position** : après Phase {N}, avant `## Stack technique` / `## Hors-MVP`

### Prochaine étape
- `/plan Phase {N+1}` pour découper en tâches concrètes
- (Si feature UI et `DESIGN.md` existe) Vérifie au passage que les tokens design couvrent ce qu'il te faut
```
