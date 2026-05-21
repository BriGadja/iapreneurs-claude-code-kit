# Détection état projet (Étape 1)

> **Lis ce fichier uniquement si** `/start` Étape 1 doit diagnostiquer si on est sur un projet neuf, existant en cours, ou en migration v1→v2.
>
> But : éviter d'écraser l'identité ou de re-cadrer un projet qui est déjà en cours.

## 1.0 — Lire MEMORY.md

Si `MEMORY.md` existe à la racine et n'est pas vide (au-delà du template), lis-le rapidement (50 premières lignes max). Tu en extrais :
- Nombre d'entrées dans `<!-- close:topics-index -->` (compter les liens markdown)
- Date de la dernière entrée dans `<!-- close:learnings-index -->`
- Domaines présents (auth, n8n, deploy, etc.)

Si non-vide, **affiche un résumé une fois** au tout début de la session (avant les autres étapes) :
> *"📚 Mémoire projet détectée : {N} topics ({liste}), dernière session enregistrée le {date}. Tape `cat MEMORY.md` pour le détail, ou continue — je sais que ça existe."*

Si vide ou inexistant → ne dis rien (pas de bruit).

## 1.1 — Lire CLAUDE.md + vérifier 4 signaux

1. La section `<!-- start:identité -->` contient encore le placeholder par défaut ?
2. Y a-t-il un `PRD.md` à la racine ?
3. Y a-t-il des fichiers de plan ? Cherche dans cet ordre : `docs/plans/phase-*-plan.md` (priorité, convention v2.1.0+), puis `plans/phase-*.md`, puis `phase-*-plan.md` à la racine (fallback projets pré-v2.1.0).
4. La variable `project_type:` est-elle présente dans `<!-- start:identité -->` ?

## Branche selon le diagnostic

### Cas A — Projet neuf

Placeholder identité présent, pas de PRD, pas de plans, pas de `project_type` → tu déroules les phases 2 à 6 du SKILL.md normalement (visite + 3 questions + écriture identité + outillage + routage).

### Cas B — Projet existant en cours

Identité remplie + PRD ou plans présents → bifurque vers `/prime` :

> *"Projet déjà cadré et en cours ({Nom détecté de l'identité}). Trois options :*
> *(1) **Recharger le contexte de session** (continuer ce projet) — je délègue à `/prime` qui lit l'état (PRD + STRUCTURE.md + plans + git log + MEMORY.md) et te propose la suite [recommandé]*
> *(2) **Cadrer une nouvelle tâche/feature** sur ce projet — on continue en mode visite + routage*
> *(3) **Ré-onboarder complet** (efface l'identité actuelle et re-fais le cadrage) — confirmation à 3 reprises avant écrasement"*
> *Tu choisis ?"*

- Si (1) → annonce *"OK, je passe la main à `/prime`"* et stoppe (l'utilisateur lance `/prime` ou tu peux suggérer en handoff).
- Si (2) → saute à l'Étape 5 (outillage) du SKILL.md puis 6 (routage), skip phases 2-4.
- Si (3) → demande **3 confirmations explicites** avant d'écrire (*"sûr ?" "vraiment sûr ?" "dernière chance, on écrase l'identité actuelle ?"*). Puis dérouler phases 2-6.

### Cas C — Migration v1.x → v2.0

Identité remplie MAIS pas de `project_type` dans `<!-- start:identité -->` → ne stoppe PAS, juste un mini-patch :

> *"Ton projet utilise une version antérieure du kit (pas de variable `project_type` dans CLAUDE.md). C'est une variable que les nouveaux skills (`/architect Étape 6`, `/livrer`, `/plan` adaptatif) attendent. Je te pose une question pour la définir :*
> *Quel type de projet ?*
> *- **(a) Web app SaaS** (auth + BDD, utilisateurs, plusieurs pages) → `project_type: webapp`*
> *- **(b) Site vitrine** (1-5 pages, peu/pas de BDD) → `project_type: site`*
> *- **(c) Automatisation n8n** (workflow déclenché, pas d'UI utilisateur) → `project_type: automation`"*

- Écris la réponse dans `<!-- start:identité -->` au format `project_type: {valeur}` (sur sa propre ligne, après le paragraphe identité).
- Continue ensuite vers Étape 5 (outillage) du SKILL.md puis 6 (routage) — pas de re-cadrage complet, le projet est déjà défini.

## Retour au SKILL.md

Selon le cas diagnostiqué, l'étape suivante varie :
- Cas A → Étape 2 (visite guidée)
- Cas B (1) → stop, propose `/prime` en handoff
- Cas B (2) → Étape 5 (outillage)
- Cas B (3) → Étape 2 après 3 confirmations
- Cas C → Étape 5 (outillage) après écriture `project_type`
