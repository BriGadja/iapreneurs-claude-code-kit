# Cloudflare Pages — procédure deploy (hosting = cloudflare)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: Cloudflare Pages`.

## Commandes de base

```bash
wrangler pages deploy {output_dir}
# Ou : push sur main si Cloudflare Pages connecté à GitHub
```

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

## Domaine custom côté Cloudflare Pages

Quand Étape 3.5 du SKILL.md demande d'ajouter un domaine custom et que l'hosting est Cloudflare Pages :

Affiche : *"Va dans le dashboard Cloudflare → Pages → ton projet → Custom domains → ajoute `{URL_CIBLE}` → note la valeur DNS demandée et colle-la moi."* Puis continue avec Étape 3.5.4 (DNS registrar-aware).
