---
name: recap
description: Utiliser quand tu reviens sur un projet existant après une absence (quelques jours à plusieurs semaines) pour reprendre où tu en étais. Lit PRD.md, les phase-*-plan.md, le git log récent, et MEMORY.md (si présent), puis propose 1-3 actions concrètes. Ne PAS utiliser sur un projet neuf — c'est /start qui détecte ce cas et bifurque automatiquement.
---

# Skill /recap — reprendre un projet existant

## Pour quoi faire

Tu reviens sur un projet J+15 (ou plus tôt, après un week-end occupé) et tu ne te souviens plus exactement où tu en étais. `/recap` lit l'état du projet en quelques secondes et te dit : *"Tu as Phase 1 ✅ Terminée le 2026-04-15, Phase 2 plan créé mais pas exécuté, dernier commit il y a 18 jours. Action suggérée : `/execute phase-2-plan.md`."*

Pas de devinette, pas de relire le PRD à la main. Le skill te ramène dans le contexte en 5-10 secondes.

> **Quand `/start` détecte un projet existant** (CLAUDE.md rempli, PRD.md présent, ou plans dans `plans/`), il bifurque automatiquement vers `/recap` — donc en pratique tu tapes plus souvent `/start` après une absence et tu te retrouves ici par redirection. Tu peux aussi appeler `/recap` directement.

## Comment procéder

### Étape 1 — Lire l'état des phases du PRD

Lis `PRD.md` à la racine.

- Cherche la section `## Phases`.
- Pour chaque ligne `- **Phase N** — ...` :
  - Si elle se termine par `— ✅ Terminée` (ou contient ce marker), classe-la **terminée**.
  - Sinon, classe-la **à faire** ou **en cours**.

Si `PRD.md` n'existe pas → annonce *"Pas de PRD.md à la racine. Soit tu n'as pas encore lancé `/architect`, soit tu n'es pas dans un projet basé sur ce kit. Tu veux lancer `/architect` maintenant ?"* et stoppe.

### Étape 2 — Lister les plans de phase

Liste les fichiers matchant `plans/phase-*.md` (ou `phase-*-plan.md` à la racine si pas de `plans/`).

Pour chaque plan, lis-le et compte :
- Nombre total de tâches `- [ ]` ou `- [x]`
- Nombre de tâches cochées `- [x]`
- Ratio → "Phase N plan : 4/7 tâches cochées"

### Étape 3 — Git log récent

Lance : `git log -5 --oneline --pretty=format:'%h %ar %s'`

Récupère les 5 derniers commits avec date relative (`il y a 3 jours`). Repère le **dernier commit utile** (pas `chore:`/`docs:` mineur) pour estimer la dernière session de travail réel.

### Étape 4 — (Optionnel) Lire MEMORY.md

Si `MEMORY.md` existe à la racine du projet, lis-le rapidement (50 premières lignes max) et extrais :
- Nombre d'entrées dans `memory/topics/` (compter les liens markdown)
- Date de la dernière session enregistrée (regarder `memory/learnings/`)
- 1-2 topics récents notables

> **Note v2.0.0-alpha.1** : si le projet est sur une version du kit qui n'a pas encore `/remember` ni le harvest learnings de `/close`, `MEMORY.md` n'existe pas — passe cette étape sans alerter.

### Étape 5 — Synthèse + actions proposées

Affiche un bloc structuré :

```markdown
## Récap projet — {Nom du projet}

### Avancement
- **PRD** : {X phases au total, Y ✅ Terminées}
- **Plans** : {liste des phase-*-plan.md avec état}
- **Dernier commit utile** : "{message}" — il y a {N jours}

### Mémoire projet
{ligne 1 sur MEMORY.md si présent, sinon "Pas de MEMORY.md (kit pré-v2.0 ou pas encore enrichi)"}

### Tu en es ici
{1 phrase qui synthétise : "Phase 1 ✅, Phase 2 plan existe mais 0 tâche cochée, projet en pause depuis 18 jours"}

### Action suggérée
{1 à 3 actions concrètes, invocables directement} :
- → `/execute phase-2-plan.md` (la plus probable, à mettre en premier)
- → `/plan Phase 3` (si Phase 2 finie mais Phase 3 pas planifiée)
- → `/ship` (si toutes les phases ✅ et projet jamais déployé)
- → `/evolve` (si projet shipped et tu veux ajouter une feature)
```

**Règle** : toujours **1 à 3 actions**, pas plus. La première doit être la plus probable. Si l'état est ambigu (ex : Phase 2 ✅ Terminée mais plan Phase 3 absent), explicite : *"Phase 2 est marquée Terminée mais je n'ai pas trouvé `phase-3-plan.md`. Tu veux lancer `/plan Phase 3` ou tu considères le projet terminé (`/ship`) ?"*

### Étape 6 — Cas limites

- **Projet shipped** (toutes phases ✅ + `<!-- ship:url -->` rempli dans CLAUDE.md OU dernier commit `feat(ship)`) → suggestion `/evolve` en priorité. *(Note alpha : si `/evolve` n'existe pas encore dans la version du kit installée, affiche : "/evolve arrivera en v2.0.0 GA — d'ici là, édite manuellement ton PRD.md ou relance `/architect` pour repartir d'un PRD étendu".)*
- **Aucun plan trouvé** mais PRD présent → suggestion `/plan Phase 1`.
- **PRD absent** → géré dans Étape 1 (stop early avec proposition `/architect`).
- **Plan en cours avec 80%+ tâches cochées** mais sans `/close` → suggestion `/validate` puis `/close`.

## Pourquoi ne pas tout afficher

Tu pourrais dumper le PRD entier, tous les plans, l'historique git complet. **Ne fais pas ça.** Le but du skill est de te ramener dans le contexte en 10 secondes, pas de te noyer dans 200 lignes. Synthèse > exhaustivité.

## Quand ne PAS utiliser ce skill

- Premier lancement sur un projet neuf → `/start` (qui peut ensuite bifurquer ici)
- Pour relire le PRD entier → ouvre `PRD.md` direct
- Pour debugger un bug → `/troubleshoot` (v2.0 GA)
- Pour ajouter une feature → `/evolve` (v2.0 GA)

## Handoff

Fin du skill : bloc "## Récap projet" + bloc "### Action suggérée" avec 1-3 actions invocables. Tu ne lances **pas** l'action automatiquement — l'utilisateur décide.
