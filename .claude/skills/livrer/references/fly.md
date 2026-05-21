# Fly.io — procédure deploy (hosting = fly)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: Fly.io`.

## Procédure générique

```bash
fly deploy
```

Pré-requis : `fly auth login` + `fly launch` (au premier deploy, crée `fly.toml`).

Demande à l'utilisateur la commande qu'il utilise habituellement si tu vois déjà un `fly.toml` à la racine. Propose de l'écrire dans une section `## Déploiement` du CLAUDE.md pour les prochains `/livrer`.

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

## Domaine custom côté Fly.io

Quand Étape 3.5 du SKILL.md demande d'ajouter un domaine custom et que l'hosting est Fly.io :

Affiche : *"Lance `fly certs add {URL_CIBLE}` puis `fly certs show {URL_CIBLE}` pour voir la valeur DNS exacte à configurer (généralement CNAME vers `{app}.fly.dev`). Colle-la moi."* Puis continue avec Étape 3.5.4 (DNS registrar-aware).
