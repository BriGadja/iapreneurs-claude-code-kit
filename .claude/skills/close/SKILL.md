---
name: close
description: Utiliser à la fin d'une phase (après /validate ✅) pour clôturer proprement — marque la phase ✅ Terminée dans le PRD (source unique depuis v2.0), propose un commit conventionnel à partir du diff, fait le harvest learnings (auto-récap dans memory/learnings/ + topics opt-in via 3 questions ciblées dans memory/topics/ et memory/decisions.md, update MEMORY.md index), suggère /plan Phase N+1 ou /livrer si dernière phase. L'utilisateur ne touche jamais à la mémoire manuellement — c'est ce skill qui la maintient. Skill mandatory post /validate ✅ (plus optionnel depuis v2.0).
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
   - Sinon → pause projet (et `/prime` pour reprendre plus tard)

C'est court. C'est un rituel, pas un skill de production.

## Règle stricte

**Pas de commit sans validation utilisateur explicite**. Tu écris le message, tu l'affiches, l'utilisateur dit "oui" → tu commits. Pas avant.

## Comment procéder

### Étape 1 — détecter la phase clôturée

Lis `PRD.md`. Cherche la dernière phase qui n'est PAS encore marquée ✅ Terminée. Confirme à l'utilisateur :

> "Je vais clôturer **Phase {N} — {nom}**. C'est ça, ou tu veux clôturer une autre phase ?"

Si l'utilisateur dit "phase Y" → utilise celle-là. Sinon continue.

### Étape 2 — vérifier que /validate a tourné

Lis le plan de la phase. Cherche d'abord dans `docs/plans/phase-{N}-plan.md` (convention v2.1.0+), puis fallback `plans/phase-{N}.md`, puis `phase-{N}-plan.md` à la racine (projets pré-v2.1.0). Le commit message guidé (Étape 4) référence le path complet `docs/plans/phase-{N}-plan.md` quand le plan est à cet emplacement.

Cherche un bloc `## Validation Phase {N}` avec verdict `✅ OK`. Si absent ou si verdict `❌ KO` / `⚠️ Partiel` non résolu :

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

### Étape 6 — Harvest learnings (mémoire persistante)

Post-commit, **l'utilisateur ne touche pas à la mémoire manuellement** — c'est ce skill qui la maintient. Deux blocs : auto-récap (toujours) + topics opt-in (questions ciblées).

> **Boucle externe (vocabulaire kit v2.1.0)** : tu fais la **boucle externe** ici. La **boucle interne** (PIV : `/prime → /plan → /execute → /validate → /close`) résout la feature courante ; la **boucle externe** cristallise ce que la session t'a appris en mémoire persistante (`memory/topics/`, `memory/decisions.md`, `MEMORY.md`) pour que les futures sessions ne refassent pas les mêmes erreurs.

**6.1 — Auto-récap session (toujours écrit, low-friction)**

Crée ou complète `memory/learnings/{YYYY-MM-DD}.md` avec un récap automatique de la phase clôturée :

```markdown
## Phase {N} — {nom} (clôturée à {HH:MM})

### Commits
- {SHA court} {message} *(le commit de cette /close)*
- {SHAs précédents de la phase, depuis le /close de Phase N-1)}

### Fichiers modifiés (top 10)
- {liste git diff --stat depuis le dernier /close}

### Durée approximative
{calcul : entre le premier commit de la phase et celui-ci} → environ {X}h
```

Pas de question, écriture directe. Si le fichier `memory/learnings/{date}.md` existe déjà (plusieurs phases clôturées le même jour), append en bas.

**6.2 — Topics opt-in (questions ciblées)**

Demande à l'utilisateur **0 à 3 questions** parmi celles-ci, **dans l'ordre, et s'arrête dès qu'il dit "rien à signaler"** :

> *"Une décision d'arch notable pendant cette phase ? (ex : choix entre 2 BDD, frontière SDK/n8n, abandon d'une feature)*"

Si réponse → écris dans `memory/decisions.md` ancre `<!-- close:decisions -->` :
```
- **{YYYY-MM-DD}** — {décision} (Phase {N}). Rationale : {réponse utilisateur}
```

> *"Un gotcha ou un piège technique qu'on a rencontré ? (ex : webhook qui ne marche que si rawBody, CORS qui demande OPTIONS, RLS qui bloque une query)"*

Si réponse → demande le **domaine** ("c'est plutôt n8n, auth, deploy, autre ?") et écris dans `memory/topics/{domaine}.md` (crée si absent) :
```markdown
## {YYYY-MM-DD} — {résumé 1-ligne}
{réponse utilisateur, 2-5 lignes}
```

> *"Un pattern réutilisable que tu veux mémoriser pour les prochaines features ?"*

Même process : domaine + écriture dans `memory/topics/{domaine}.md`.

**6.3 — Update MEMORY.md index**

Après écriture(s) en 6.2, met à jour `MEMORY.md` à la racine :

- Ancre `<!-- close:topics-index -->` : ajoute un lien `- [domaine](memory/topics/{domaine}.md) — {résumé 1-ligne}` si nouveau topic, sinon laisse (le détail est dans le fichier topic).
- Ancre `<!-- close:learnings-index -->` : ajoute `- [{date}](memory/learnings/{date}.md) — Phase {N} clôturée ({X}h, {N commits})`.

**Règle d'or** : si l'utilisateur répond "rien" à toutes les questions, tu ne demandes pas de troisième confirmation. Tu skipes 6.2/6.3 et passes à 6.4. Pas de friction.

**6.4 — Annonce courte** : *"Mémoire mise à jour : {N learnings + {M topics si applicable}}. MEMORY.md indexé."*. Pas de dump du contenu écrit.

### Étape 7 — suggestion suivante

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
