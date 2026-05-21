# Render — procédure deploy (hosting = render)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: Render`.

## Procédure générique

Render est typiquement piloté depuis le Dashboard avec auto-deploy GitHub.

Demande à l'utilisateur la commande qu'il utilise habituellement (ou si c'est `git push` sur la branche connectée). Propose de l'écrire dans une section `## Déploiement` du CLAUDE.md pour les prochains `/livrer`.

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

## Domaine custom côté Render

Quand Étape 3.5 du SKILL.md demande d'ajouter un domaine custom et que l'hosting est Render :

Affiche : *"Va dans le dashboard Render → ton service → Settings → Custom Domains → ajoute `{URL_CIBLE}` → note la valeur DNS demandée et colle-la moi."* Puis continue avec Étape 3.5.4 (DNS registrar-aware).
