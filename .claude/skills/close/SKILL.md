---
name: close
description: Utiliser à la fin d'une phase (après /validate ✅) pour clôturer proprement — marque la phase ✅ Terminée dans le PRD (source unique depuis v2.0), propose un commit conventionnel à partir du diff, suggère /plan Phase N+1 ou /livrer si dernière phase. Ne PAS utiliser au milieu d'une phase, ni si /validate ❌ KO. Skill mandatory post /validate ✅ (plus optionnel depuis v2.0).
---

# Skill /close — clôturer proprement une phase

**Invocation** : `/close` (rien à passer, le skill détecte la phase depuis le PRD + git status).

**Mandatory post-`/validate ✅`** depuis v2.0 — sans `/close`, le commit n'est jamais fait et le PRD reste non-à-jour. Le handoff de `/validate` ne propose plus le skip.

## Pour quoi faire

Après `/validate ✅`, faire la sortie propre :
1. Marquer la phase **✅ Terminée le YYYY-MM-DD** dans le PRD parent — **source unique** depuis v2.0 (avant, `/execute` Étape 3 marquait aussi → doublon résolu).
2. Proposer un message de commit conventionnel à partir du diff git réel.
3. Demander confirmation avant `git commit`. Pas de `git push` automatique.
4. Suggérer la prochaine étape :
   - Si ce n'est **pas la dernière phase** → `/plan Phase {N+1}`
   - Si c'est la **dernière phase** ET projet **jamais shipped** (pas d'`<!-- ship:url -->` rempli dans CLAUDE.md) → `/livrer`
   - Sinon → pause projet (et `/recap` pour reprendre plus tard)

C'est court. C'est un rituel, pas un skill de production.

## Règle stricte

**Pas de commit sans validation utilisateur explicite**. Tu écris le message, tu l'affiches, l'utilisateur dit "oui" → tu commits. Pas avant.

## Comment procéder

### Étape 1 — détecter la phase clôturée

Lis `PRD.md`. Cherche la dernière phase qui n'est PAS encore marquée ✅ Terminée. Confirme à l'utilisateur :

> "Je vais clôturer **Phase {N} — {nom}**. C'est ça, ou tu veux clôturer une autre phase ?"

Si l'utilisateur dit "phase Y" → utilise celle-là. Sinon continue.

### Étape 2 — vérifier que /validate a tourné

Lis `phase-{N}-plan.md`. Cherche un bloc `## Validation Phase {N}` avec verdict `✅ OK`. Si absent ou si verdict `❌ KO` / `⚠️ Partiel` non résolu :

> "La Phase {N} n'a pas de verdict `✅ OK` dans son plan. Tu veux lancer `/validate` d'abord, ou tu confirmes que la phase est vraiment finie ?"

Si l'utilisateur confirme malgré tout, continue. Si pas de réponse, stoppe.

### Étape 3 — marquer la phase ✅ Terminée dans le PRD

Édite `PRD.md`, section `## Phases`. Remplace la ligne de la phase :

```
- **Phase {N}** — {nom} : {description}
```

par :

```
- **Phase {N}** — {nom} : {description} ✅ Terminée le {YYYY-MM-DD}
```

### Étape 4 — composer le message de commit

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

### Étape 5 — commit (après validation explicite)

Lance :
```bash
git add -A
git commit -m "{message validé}"
```

Annonce le SHA résultant. **Ne push pas automatiquement** — c'est à l'utilisateur de décider quand pousser (et où).

### Étape 6 — suggestion suivante

Lis `PRD.md ## Phases`. Identifie la phase suivante (première sans ✅ Terminée).

- **Si une phase suivante existe** :
  > "Phase {N} clôturée. Tu veux enchaîner sur **Phase {N+1} — {nom}** maintenant avec `/plan Phase {N+1}`, ou tu fais une pause ?"

- **Si toutes les phases sont ✅ Terminées** (Phase {N} était la dernière), vérifie si le projet a déjà été shipped : grep `<!-- ship:url -->` dans `CLAUDE.md`, regarde si le bloc contient une URL (pas juste le placeholder).
  - **Pas encore shipped** :
    > "Phase {N} clôturée. Toutes les phases du PRD sont ✅ Terminées et le projet n'a jamais été déployé. Tu veux lancer **`/livrer`** pour passer en production ?"
  - **Déjà shipped** :
    > "Phase {N} clôturée. Toutes les phases du PRD sont ✅ Terminées et le projet est déjà en production. Quand tu veux ajouter une feature → `/evoluer` (v2.0 GA). Sinon, projet bouclé. 🎉"

## Risque #1 — commit silencieux

Si tu lances `git commit` sans avoir affiché le message et obtenu un "oui", tu peux écrire n'importe quoi dans l'historique du projet — et l'historique est public dès le push. **Test du miroir** : tu dois pouvoir citer le message que l'utilisateur a explicitement validé. Si tu ne te souviens pas l'avoir affiché, tu n'as pas le droit de commit.

## Risque #2 — clôturer une phase pas finie

Si `/validate` n'a pas dit `✅ OK`, la phase n'est pas finie. Marquer ✅ Terminée à ce stade pollue le PRD et casse le repère "où on en est". **Test du miroir** : tu dois pouvoir pointer le bloc `## Validation Phase {N}` avec verdict OK avant d'écrire `✅ Terminée le ...`.

## Quand ne PAS utiliser ce skill

- Au milieu d'une phase (tâches encore `[ ]` non cochées) → `/execute` d'abord
- Sans `/validate` préalable (sauf si l'utilisateur force) → `/validate` d'abord
- Pour pousser vers GitHub → c'est `git push`, pas un skill (et c'est à l'utilisateur de décider)
- Pour archiver le projet → c'est manuel (move vers `archive/`, mise à jour README)

## Handoff

Fin du skill : SHA du commit + suggestion selon l'état du PRD :
- Phase suivante existe → `/plan Phase {N+1}`
- Dernière phase + pas shipped → `/livrer`
- Dernière phase + déjà shipped → fin de cycle (proposer `/evoluer` pour future feature)
