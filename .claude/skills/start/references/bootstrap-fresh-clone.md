# Bootstrap fresh clone (Étape 0)

> **Lis ce fichier uniquement si** `/start` Étape 0 détecte un clone direct du kit (remote `origin` pointe vers `iapreneurs-claude-code-kit` ET `<!-- start:identité -->` contient encore le placeholder par défaut).
>
> But : repartir d'un historique git propre tout en gardant le kit accessible via `upstream` pour récupérer les updates futures.

## Question utilisateur

> *"Je vois que tu as cloné directement le repo du kit (origin = `iapreneurs-claude-code-kit`). Pour que ton projet parte sur un historique git propre, je peux :*
> *1. Supprimer l'historique du kit (`rm -rf .git && git init`)*
> *2. Garder le kit comme remote `upstream` (pour tirer les updates futures via `git pull upstream main`)*
> *3. Faire un premier commit `chore: init from iapreneurs-claude-code-kit v{version}`*
>
> *Tu veux que je fasse ça maintenant ? (oui / non)*
>
> *💡 Alternative : utiliser le bouton "Use this template" sur GitHub la prochaine fois → tu skipperas cette étape automatiquement."*

## Si l'utilisateur dit oui

```bash
# Capturer l'URL et la version AVANT de supprimer .git
KIT_URL=$(git remote get-url origin)
KIT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v2.1.0")

# Reinit
rm -rf .git
git init -b main

# Ajouter le kit comme upstream (pour les updates futures)
git remote add upstream "$KIT_URL"

# Premier commit propre
git add -A
git commit -m "chore: init from iapreneurs-claude-code-kit $KIT_VERSION"
```

Annonce ensuite : *"✅ Historique git réinitialisé. Le kit est gardé comme `upstream` — `git pull upstream main` pour récupérer les futures versions. Premier commit fait. On continue le cadrage."*

## Si l'utilisateur dit non

Respecte le choix, continue sans toucher au git. Note dans ta tête que ce projet partagera l'historique du kit — ce n'est pas grave, juste un choix.

## Retour au SKILL.md

Une fois bootstrap fait (ou refusé), retourne à l'Étape 0.5 du SKILL.md (identité git locale).
