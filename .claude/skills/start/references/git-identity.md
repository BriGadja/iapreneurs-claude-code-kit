# Identité git locale (Étape 0.5)

> **Lis ce fichier uniquement si** `/start` Étape 0.5 doit s'assurer que les commits du projet auront le bon auteur.
>
> But : éviter que les commits soient attribués au mauvais auteur (config globale partagée, ou repo cloné par quelqu'un d'autre), et éviter d'avoir à balancer `git -c user.name=... user.email=...` à chaque commit.

## Détection

Lance en parallèle :
- `git rev-parse --git-dir 2>/dev/null && echo HAS_REPO || echo NO_REPO`
- `git config --get user.name && git config --get user.email` (config effective = local fusionné avec global)

## Cas A — pas de repo git (`NO_REPO`)

Annonce *"Pas de repo git ici. Tu veux que j'en initialise un ? (oui / non)"*

- **Oui** → `git init -b main`, puis bascule sur Cas C (identité à régler).
- **Non** → note "mode sans-git" pour cette session. **Avertis** : *"OK, on travaille sans git. ⚠️ `/close` et `/livrer` partent du principe que git est dispo — quand ils arriveront, dis-leur de skipper les commits, sinon ils échoueront. La plupart des hostings (Vercel/Netlify) exigent git pour déployer."* Skip le reste de 0.5, passe à Étape 1 du SKILL.md.

## Cas B — repo existant, identité effective présente

Les 2 `git config --get` retournent une valeur. Annonce :

> *"Identité git effective : `{name} <{email}>`. On l'utilise pour ce projet ? (oui / autre)"*

- **Oui** → continue Étape 1 du SKILL.md sans rien toucher.
- **Autre** → bascule sur Cas C pour collecter de nouvelles valeurs et les écrire en **local** (override le global pour ce projet uniquement).

## Cas C — repo existant, identité absente ou à override

Annonce :

> *"Je vais écrire une identité git **locale** pour ce projet (commande `git config --local` — ta config globale `~/.gitconfig` n'est pas touchée)."*

Demande 2 valeurs, une à la fois :
1. *"Ton nom (apparaîtra dans `git log` et sur GitHub) ?"*
2. *"Ton email (idéalement celui de ton compte GitHub pour que les commits soient liés à ton profil) ?"*

Puis lance :
```bash
git config --local user.name "{nom fourni}"
git config --local user.email "{email fourni}"
```

Vérifie : `git config --local --get user.name && git config --local --get user.email` — les 2 valeurs doivent ressortir. Confirme : *"✅ Identité locale écrite. Tes prochains commits seront signés correctement, sans override par commande."*

> **Pour la suite** : `/close` et `/livrer` commiteront avec cette identité automatiquement. Plus besoin de `git -c user.name=...` à chaque commit.

## Retour au SKILL.md

Une fois l'identité réglée (Cas A oui→C, B, ou C complété), retourne à l'Étape 1 du SKILL.md (détection état projet).
