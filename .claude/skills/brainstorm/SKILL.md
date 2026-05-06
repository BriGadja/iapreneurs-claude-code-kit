---
name: brainstorm
description: Utiliser quand l'utilisateur a une idée vague ou floue ("j'aimerais une app pour...", "je voudrais automatiser...", "j'ai envie de faire un truc qui..."). Ne PAS utiliser si l'utilisateur a déjà une idée précise — passer direct à /create-prd. Sortie : fichier `brainstorm-{sujet}.md` clarifié.
---

# Skill /brainstorm — clarifier une idée vague

## Pour quoi faire

L'utilisateur a une idée mais elle n'est pas claire. Tu poses **3 questions max** pour clarifier, puis tu produis un fichier `brainstorm-{sujet}.md` qui résume l'idée en bullet points actionnables. C'est ce fichier qui alimentera `/create-prd` après.

## Comment procéder

### Étape 1 — comprendre le sujet

Reformule en 1 phrase ce que tu as compris. Demande confirmation :

> "Si je comprends bien, tu veux **{ce que j'ai compris}**. C'est ça ?"

Si l'utilisateur corrige, intègre la correction. Sinon, continue.

### Étape 2 — poser 3 questions max

Choisis **3 questions parmi** ces 5 axes (priorise selon le sujet) :

1. **Pour qui ?** → "C'est pour toi tout seul, ton équipe, des clients, des inconnus ?"
2. **Pour quoi ?** → "Ça doit résoudre quel problème concret ? Tu peux me donner un exemple où ça t'aurait servi cette semaine ?"
3. **Combien ?** → "Combien de personnes vont l'utiliser en même temps ? 1, 10, 100, 1000 ?"
4. **Quoi d'abord ?** → "Si tu pouvais avoir UNE seule fonctionnalité à la fin de la journée, ce serait laquelle ?"
5. **Hors scope ?** → "Qu'est-ce qui est hors sujet, à ne PAS faire dans ce projet ?"

**Règle stricte** : 3 questions max. Pas 4. Pas 5. Si tu en as besoin plus, c'est que le sujet est trop large pour `/brainstorm` — propose `/architect` ou découper en plusieurs sous-projets.

### Étape 3 — proposer 2 routes

Une fois les réponses obtenues, propose à l'utilisateur :

> "OK, deux options :
> 1. **Je te fais le PRD direct** avec ce qu'on a (`/create-prd`).
> 2. **On creuse encore** — recherche web, exemples de projets similaires, retours d'utilisateurs (recherche externe).
> Tu préfères quoi ?"

### Étape 4 — écrire le fichier

Écrire `brainstorm-{sujet}.md` à la racine du projet. Format :

```markdown
# Brainstorm : {sujet}

## Idée en 1 phrase
{phrase claire}

## Pour qui
- {réponse Q1}

## Problème résolu
- {réponse Q2}

## Échelle attendue
- {réponse Q3 ou estimation}

## Première fonctionnalité (si une seule)
- {réponse Q4}

## Hors scope
- {réponse Q5 ou liste explicite}

## Prochaine étape
- [ ] /create-prd brainstorm-{sujet}.md
```

## Risque #1 — partir sans clarification

Si tu sautes les 3 questions et tu écris direct le fichier brainstorm avec tes hypothèses, tu vas générer un PRD qui ne correspond à rien et l'utilisateur va devoir tout refaire. **Toujours poser les 3 questions, même si tu crois "avoir compris"**. Mieux vaut 5 minutes de questions que 2h de PRD à jeter.

## Quand ne PAS utiliser ce skill

- L'utilisateur a déjà une idée claire → `/create-prd` direct
- L'utilisateur veut juste discuter/explorer sans rien produire → conversation libre, pas de skill
- Le sujet est énorme (refonte complète d'un produit) → trop large, découper en sous-sujets

## Handoff

Fin du skill : message à l'utilisateur avec les 2 options route + le path du fichier `brainstorm-{sujet}.md`.
