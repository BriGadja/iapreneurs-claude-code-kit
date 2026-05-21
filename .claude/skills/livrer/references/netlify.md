# Netlify — procédure deploy (hosting = netlify)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: Netlify`.
>
> Netlify est l'**alternative recommandée à Vercel pour un usage commercial gratuit** (Vercel Hobby = perso uniquement). Si tu vends ton projet à un client, Netlify évite l'upgrade Pro forcé.

## Commandes de base

```bash
netlify init             # si pas déjà fait
netlify env:set {VAR_NAME} {valeur}     # pour chaque variable
netlify deploy --prod
```

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

## Domaine custom côté Netlify

Quand Étape 3.5 du SKILL.md demande d'ajouter un domaine custom et que l'hosting est Netlify :

Affiche : *"Va dans le dashboard Netlify → ton site → Domain settings → Add custom domain → ajoute `{URL_CIBLE}` → note la valeur DNS demandée et colle-la moi."* Puis continue avec Étape 3.5.4 (DNS registrar-aware).
