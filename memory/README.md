# `memory/` — mémoire persistante du projet

> Le kit construit progressivement le **cerveau** de ton projet : gotchas, décisions d'arch, patterns réutilisables, learnings par session. À chaque nouvelle session, `/start` et `/prime` chargent `MEMORY.md` (à la racine) → Claude arrive avec le contexte déjà compris.

## Règle d'or

**Tu n'édites jamais `memory/` à la main.** Tout est écrit par `/close` après chaque phase validée. Le harvest est court (3 questions opt-in). Si tu n'as rien à dire, skip — pas de pollution.

## Structure

| Fichier / dossier | Contient | Écrit par |
|-------------------|----------|-----------|
| `MEMORY.md` (racine) | Index 1-ligne par entrée — lu en intro de chaque `/start` et `/prime` | `/close` (à chaque clôture) |
| `memory/learnings/{YYYY-MM-DD}.md` | Récap **automatique** par session : commits, fichiers modifiés, durée approx. Pas de question | `/close` (toujours, low-friction) |
| `memory/topics/{domaine}.md` | Cumul par domaine (auth, n8n, deploy, bugs...). Append-only | `/close` (opt-in via questions harvest) |
| `memory/decisions.md` | Log des choix d'arch durables (BDD, hosting, framework...) | `/close` (opt-in via la 1ère question harvest) |

## Mini-glossaire

- **learnings** (par session, daté) : "ce qui s'est passé". Auto-écrit, pas de prise de décision.
- **topics** (cumulatif, par domaine) : "ce qu'on a appris sur X". Tu y reviens quand tu retouches le domaine.
- **decisions** (choix d'arch durables) : "ce qu'on a tranché et pourquoi". Utile pour les revues 6 mois plus tard.

## Le harvest de `/close` — 3 questions ciblées

À chaque `/close` de phase, après le commit conventionnel :

1. **Auto-récap session** (toujours, pas de question) → `memory/learnings/{date}.md`
2. **Question 1** : *"Une décision d'arch notable ?"* → si oui, `memory/decisions.md`
3. **Question 2** : *"Un gotcha technique ?"* → si oui, `memory/topics/{domaine}.md`
4. **Question 3** : *"Un pattern réutilisable ?"* → si oui, `memory/topics/{domaine}.md`
5. Si "rien" à toutes les questions → skip, pas de friction.

## Comment c'est lu au démarrage

`/start` et `/prime` lisent `MEMORY.md` (l'index) et affichent : *"📚 Mémoire projet : 3 topics ({liste}), dernière session il y a 4 jours"*. Tu décides si tu plonges (`cat memory/topics/...`) ou continues.

## Ancres dans MEMORY.md (auto-maintenues)

- `<!-- close:topics-index -->` ... `<!-- /close:topics-index -->` — index des topics cumulés
- `<!-- close:learnings-index -->` ... `<!-- /close:learnings-index -->` — index des learnings par session

**Ne supprime pas ces ancres**, sinon `/close` ne sait plus où écrire.
