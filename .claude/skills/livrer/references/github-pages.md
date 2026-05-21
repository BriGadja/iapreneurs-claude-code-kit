# GitHub Pages — procédure deploy (hosting = github-pages)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: GitHub Pages`.
>
> Typique pour site statique Next.js avec `output: 'export'`.

## Commandes de base

```bash
npm run build
git push origin main     # workflow .github/workflows/deploy.yml gère le push gh-pages
```

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

## Domaine custom côté GitHub Pages

Quand Étape 3.5 du SKILL.md demande d'ajouter un domaine custom et que l'hosting est GitHub Pages :

Affiche : *"Va dans Settings → Pages → Custom domain → ajoute `{URL_CIBLE}` et crée un fichier `CNAME` à la racine du repo contenant l'URL. Note la valeur DNS demandée et colle-la moi."* Puis continue avec Étape 3.5.4 (DNS registrar-aware).
