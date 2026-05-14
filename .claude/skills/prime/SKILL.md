---
name: prime
description: Utiliser à chaque nouvelle session de travail sur un projet existant pour recharger le contexte rapidement (PRD, plans, git log, MEMORY.md, STRUCTURE.md) avant `/plan` ou autre action. Inclut aussi le cas reprise après absence. Ne PAS utiliser sur un projet neuf — c'est `/start` qui détecte ce cas et bifurque automatiquement.
---

# Skill /prime — rituel d'entrée de session sur un projet existant

## Pour quoi faire

`/prime` est le **rituel d'entrée de session** : à chaque fois que tu reprends le travail sur un projet existant (le matin, après le déjeuner, après une absence de quelques jours ou plusieurs semaines), tu tapes `/prime` avant tout. En 5-10 secondes il lit l'état du projet et te dit : *"Tu as Phase 1 ✅ Terminée le 2026-04-15, Phase 2 plan créé mais pas exécuté, dernier commit il y a 18 jours. Action suggérée : `/execute docs/plans/phase-2-plan.md`."*

Pas de devinette, pas de relire le PRD à la main. Le skill te ramène dans le contexte d'architecture, d'avancement et d'historique récent — peu importe que ta dernière session date d'1 heure ou de 3 semaines.

> **Quand `/start` détecte un projet existant** (CLAUDE.md rempli, PRD.md présent, ou plans dans `docs/plans/`/`plans/`), il bifurque automatiquement vers `/prime` — donc en pratique tu tapes souvent `/start` et tu te retrouves ici par redirection. Tu peux aussi appeler `/prime` directement.

## Comment procéder

### Étape 0 — Lecture STATUS.md (accélérateur)

Avant tout, vérifie si `STATUS.md` existe à la racine du projet.

**Si présent** : lis la zone entre `<!-- close:active -->` et `<!-- /close:active -->`. Extrais :
- `**Dernière étape**`
- `**Prochaine étape recommandée**`
- `**Dernier commit reflété**` (champ SHA)
- Historique récent (5 dernières lignes)

- **Si la zone contient** `(aucune — projet neuf, lance /start)` → projet neuf, redirige vers `/start` et stoppe.
- **Si STATUS.md riche** : affiche la synthèse extraite + valide rapidement contre le PRD (Étape 1 ci-dessous) en mode "vérification cohérence" (1 ligne). STATUS.md devient ta **source principale**.

**Si STATUS.md absent** (projet pré-v2.1) : annonce *"Pas de STATUS.md détecté — fallback lecture complète."* puis continue Étapes 1-5 actuelles intact (backwards compat).

### Étape 0.5 — Detect mode (création vs maintenance)

Avant Étape 1, compte les SPECs livrés :

```
count_specs=$(ls docs/specs/SPEC-*.md 2>/dev/null | wc -l)
mode = "création" si count_specs == 0 else "maintenance"
```

Stocke `mode` et `count_specs` en variables session — utilisés par Étapes 1, 1.6, 5.

### Étape 1 — Lire l'état des phases du PRD (adaptateur format)

Lis `PRD.md` à la racine. Détecte le format via les 4 branches (identiques à /evoluer) :

```
has_new = grep -q "^## 7. Implementation Phases" PRD.md
has_old = grep -q "^## Phases" PRD.md
```

| Branche | has_new | has_old | Parser |
|---------|---------|---------|--------|
| 1 | ✅ | ❌ | **Nouveau format v2.2** : parser `## 7. Implementation Phases` pour lignes `**V_N (livré le {date}) — ...** / **V_N (en cours) — ...** / **V_N (envisagé) — ...**`. Classer par état. |
| 2 | ❌ | ✅ | **Ancien format v2.1.x (legacy)** : parser `## Phases` pour lignes `- **Phase N** — ...` ; `— ✅ Terminée` = terminée, sinon à faire/en cours. |
| 3 | ✅ | ✅ | **État mixte** : warn "PRD en état mixte (ancien + nouveau format). Lecture partielle — pense à migrer via `docs/MIGRATION-v2.1-to-v2.2.md`." Parser nouveau format en priorité. |
| 4 | ❌ | ❌ | **PRD malformé ou absent** : annonce *"Pas de PRD.md à la racine ou format non reconnu. Soit tu n'as pas encore lancé `/architect`, soit tu n'es pas dans un projet basé sur ce kit. Tu veux lancer `/architect` maintenant ?"* et stoppe. |

### Étape 1.5 — Lire STRUCTURE.md si présent

Si `STRUCTURE.md` existe à la racine, lis-le rapidement (max 100 lignes — c'est un fichier court par design). Tu en extrais :
- L'arbo des dossiers principaux (`<!-- architect:directories -->`)
- 1-2 patterns clés (`<!-- architect:patterns -->`)

Tu n'affiches pas le détail — tu l'utilises en input pour la synthèse finale (Étape 5, section "Architecture"). Si `STRUCTURE.md` n'existe pas (projet pré-v2.1.0 ou pas encore passé par `/architect` Étape 6.5), passe cette étape sans alerter — tu fonctionnes en dégradé sans ce contexte.

> **Pourquoi** : évite que tu redécouvres l'arbo et les patterns à chaque session. STRUCTURE.md est ta carte d'architecture.

### Étape 1.6 — (mode maintenance uniquement) Lire decisions.md + 3 derniers SPECs

Si `mode == "maintenance"` (count_specs > 0) :

- Lis `memory/decisions.md` et extrais les **5 derniers ADR-NNN** (sort par numéro desc) — titre + status + date suffisent.
- Liste les SPECs triés par date desc : `ls docs/specs/SPEC-*.md 2>/dev/null | sort -r | head -3`. Lis chacun (4 sections : Feature/Examples/Documentation/Considerations).

Ces lectures alimentent la synthèse Étape 5 (section "Évolutions récentes"). Si `mode == "création"` (count_specs == 0) → skip entièrement, pas de bruit.

### Étape 2 — Lister les plans de phase

Cherche les fichiers de plan dans cet ordre (le premier emplacement non-vide gagne) :
1. **`docs/plans/phase-*-plan.md`** (priorité, convention v2.1.0+)
2. **`plans/phase-*.md`** (fallback compat projets pré-v2.1.0)
3. **`phase-*-plan.md` à la racine** (fallback legacy)

Si un seul de ces emplacements contient des fichiers, utilise-le. Si plusieurs en contiennent (cas de transition), affiche un warning court : *"Plans détectés dans plusieurs emplacements (`docs/plans/` + `plans/`). Convention actuelle = `docs/plans/`. Tu peux migrer manuellement quand tu veux."* puis lis tous les plans pour ne rien manquer.

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

> **Note** : si le projet est sur une version du kit qui n'a pas encore le harvest learnings de `/close`, `MEMORY.md` n'existe pas — passe cette étape sans alerter.

### Étape 5 — Synthèse + actions proposées

Affiche un bloc structuré :

```markdown
## Récap projet — {Nom du projet}

**Mode {création|maintenance} détecté.** {N} évolutions livrées depuis {date V1 du PRD}.
_(N = count_specs ; date V1 = première mention `V1 (livré le {date})` dans `## 7. Implementation Phases`, ou date du commit initial si format legacy)_

### Évolutions récentes (mode maintenance uniquement)
{Si mode == maintenance : lister les 3 derniers SPECs (filename + 1-ligne Feature) + 2-3 derniers ADR-NNN (titre). Sinon omettre cette section.}

### Avancement
- **PRD** : {X phases au total, Y ✅ Terminées}
- **Plans** : {liste des phase-*-plan.md avec état, chemin complet `docs/plans/...` ou `plans/...`}
- **Dernier commit utile** : "{message}" — il y a {N jours}

### Architecture
{1 ligne tirée de STRUCTURE.md si présent — ex: "Vertical slice par feature, RSC + Server Actions, tests co-located". Si STRUCTURE.md absent, omettre cette section sans alerter.}

### Mémoire projet
{ligne 1 sur MEMORY.md si présent, sinon "Pas de MEMORY.md (kit pré-v2.0 ou pas encore enrichi)"}

### Tu en es ici
{1 phrase qui synthétise : "Phase 1 ✅, Phase 2 plan existe mais 0 tâche cochée, projet en pause depuis 18 jours"}

### Action suggérée
{1 à 3 actions concrètes, invocables directement} :
- → `/execute docs/plans/phase-2-plan.md` (la plus probable, à mettre en premier)
- → `/plan Phase 3` (si Phase 2 finie mais Phase 3 pas planifiée)
- → `/livrer` (si toutes les phases ✅ et projet jamais déployé)
- → `/evoluer` (si projet shipped et tu veux ajouter une feature)
```

**Règle** : toujours **1 à 3 actions**, pas plus. La première doit être la plus probable. Si l'état est ambigu (ex : Phase 2 ✅ Terminée mais plan Phase 3 absent), explicite : *"Phase 2 est marquée Terminée mais je n'ai pas trouvé `phase-3-plan.md`. Tu veux lancer `/plan Phase 3` ou tu considères le projet terminé (`/livrer`) ?"*

### Étape 5b — Détection STATUS.md stale

Si STATUS.md existe, vérifie qu'il est synchronisé avec le dernier commit via 2 signaux déterministes :

**Signal 1 — SHA divergent** : le champ `**Dernier commit reflété** : {sha-short}` (écrit par /close) ≠ `git rev-parse --short HEAD`. Si différent → STATUS.md non synchro avec le dernier commit → **stale**.

**Signal 2 — Modifs non-clôturées** : `git status --porcelain` retourne des fichiers modifiés ET le `mtime` de STATUS.md est antérieur au dernier commit (`git log -1 --pretty=format:%H STATUS.md` antérieur à HEAD) → un `/close` a été oublié.

Si **stale** détecté : annonce *"⚠️ STATUS.md pas à jour (dernier commit reflété : {old-sha}, HEAD = {new-sha}) — un `/close` a peut-être été oublié à la dernière session. Pense à `/close` quand tu auras fini ta session courante."*

### Étape 6 — Cas limites

- **Projet livré** (toutes phases ✅ + `<!-- ship:url -->` rempli dans CLAUDE.md OU dernier commit `feat(livrer)`) → suggestion `/evoluer` en priorité. *(Note alpha : si `/evoluer` n'existe pas encore dans la version du kit installée, affiche : "/evoluer arrivera en v2.0.0 GA — d'ici là, édite manuellement ton PRD.md ou relance `/architect` pour repartir d'un PRD étendu".)*
- **Aucun plan trouvé** mais PRD présent → suggestion `/plan Phase 1`.
- **PRD absent** → géré dans Étape 1 (stop early avec proposition `/architect`).
- **Plan en cours avec 80%+ tâches cochées** mais sans `/close` → suggestion `/validate` puis `/close`.

## Pourquoi ne pas tout afficher

Tu pourrais dumper le PRD entier, tous les plans, l'historique git complet. **Ne fais pas ça.** Le but du skill est de te ramener dans le contexte en 10 secondes, pas de te noyer dans 200 lignes. Synthèse > exhaustivité.

## Quand ne PAS utiliser ce skill

- Premier lancement sur un projet neuf → `/start` (qui peut ensuite bifurquer ici)
- Pour relire le PRD entier → ouvre `PRD.md` direct
- Pour debugger un bug → `/debug` (built-in Claude Code natif) + test de régression avant fix (règle TDD CLAUDE.md)
- Pour ajouter une feature → `/evoluer` (v2.0 GA)

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "prime", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Fin du skill : bloc "## Récap projet" + bloc "### Action suggérée" avec 1-3 actions invocables. Tu ne lances **pas** l'action automatiquement — l'utilisateur décide.

**Prochaine étape** : action proposée dans le bloc "Action suggérée" ci-dessus
