# Hostinger — procédure deploy (hosting = hostinger)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: Hostinger` (VPS ou hosting partagé).

## Procédure générique

Hostinger varie selon le plan (hosting partagé, VPS, cloud). Demande à l'utilisateur la commande qu'il utilise habituellement (rsync, git pull sur VPS, upload FTP, panneau hPanel). Propose de l'écrire dans une section `## Déploiement` du CLAUDE.md pour les prochains `/livrer`.

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

## Domaine custom côté Hostinger

Si Hostinger est aussi le **hosting**, la gestion du domaine se fait directement dans hPanel → Hosting → ton site → Domains. Affiche : *"Va dans hPanel → Hosting → ton site → ajoute `{URL_CIBLE}` comme domaine pointé. Si le DNS est aussi chez Hostinger (cas fréquent), la propagation est interne et rapide."* Puis continue avec Étape 3.5.4 si le DNS est ailleurs.
