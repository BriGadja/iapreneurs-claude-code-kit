---
name: create-prd
description: Utiliser pour transformer un fichier brainstorm (ou une idée claire) en Product Requirements Document structuré. Ne PAS utiliser si l'idée est encore floue — passer par /brainstorm d'abord. Ne PAS utiliser pour ajouter une feature à un PRD existant — éditer directement le PRD.
---

# Skill /create-prd — produire un PRD structuré

## Pour quoi faire

Transformer une idée (claire ou issue d'un `/brainstorm`) en **PRD** : un fichier `prd-{projet}.md` qui sert de référence pour toute la suite (`/plan`, `/execute`, `/validate`). Le PRD est lu en début de chaque skill suivant.

## Sections obligatoires du PRD

Pas de PRD complet sans ces 7 sections, dans cet ordre :

1. **Sommaire** — 2-3 phrases : c'est quoi, pour qui, quel résultat
2. **Utilisateurs cibles** — qui s'en sert, dans quelle situation
3. **MVP — ce qu'on fait** — la liste minimale de fonctionnalités pour la v1
4. **Hors-MVP — ce qu'on ne fait PAS** — explicite, pour cadrer le scope
5. **Phases** — découpage en 3 à 5 phases max (Phase 1 = MVP, Phase 2+ = ajouts)
6. **Stack technique** — frameworks, services, langages choisis
7. **Critères de succès** — comment on saura que c'est fini et que ça marche

## Comment procéder

### Étape 1 — lire la source

Si le user a passé un fichier `brainstorm-{sujet}.md` en argument, le lire.
Si pas de fichier, lire ce que dit le user dans le chat et lui poser **2-3 questions de clarification** sur les sections manquantes (utilisateurs, MVP, stack).

### Étape 2 — proposer la stack

Si la stack n'est pas dans le brainstorm, **propose une stack par défaut** alignée avec le projet :

- **App web** : Next.js (App Router) + Tailwind + shadcn/ui + Supabase (Auth + BDD + Realtime si besoin) + Vercel
- **Automatisation** : n8n
- **Voix** : Dipler ou Vapi
- **Scripts ponctuels** : Python ou TypeScript Node

Toujours **demander confirmation** : "Je propose **{stack}**. Ça te va ou tu veux changer un truc ?"

### Étape 3 — découpe en phases

**3 à 5 phases max**. Pas plus. Si t'as 7 phases, c'est trop large : faut un PRD parent + plusieurs sous-PRDs.

Exemple de découpe pour une web app :
- Phase 1 — Squelette + 1 feature critique end-to-end
- Phase 2 — Compléments features
- Phase 3 — Authentification / multi-utilisateur
- Phase 4 — Déploiement + tests utilisateurs

### Étape 4 — écrire le brouillon, lire à voix haute

Écris le PRD au format markdown ci-dessous, **affiche-le entier dans le chat** et demande validation **avant** de sauvegarder le fichier.

> "Voilà le PRD que je propose. Tu valides ou tu veux qu'on change un truc ?"

Itère jusqu'à ce que l'utilisateur dise oui.

### Étape 5 — sauvegarder

Sauvegarder dans `prd-{projet}.md` à la racine du projet uniquement après validation explicite.

## Format du PRD

```markdown
# PRD : {Nom du projet}

## Sommaire
{2-3 phrases}

## Utilisateurs cibles
- {qui, dans quelle situation}

## MVP — ce qu'on fait
- {feature critique 1}
- {feature critique 2}
- {feature critique 3}

## Hors-MVP — ce qu'on ne fait PAS
- {feature explicitement écartée}
- {nice-to-have repoussé}

## Phases
- **Phase 1** — {nom} : {1 phrase de description}
- **Phase 2** — ...
- **Phase 3** — ...

## Stack technique
- Frontend : {choix}
- Backend : {choix}
- BDD : {choix}
- Hosting : {choix}

## Critères de succès
- [ ] {ex: un utilisateur peut faire X end-to-end sans bug}
- [ ] {ex: l'app charge en moins de 2s}
- [ ] {ex: 5 personnes peuvent utiliser en simultané sans crash}
```

## Risque #1 — sauvegarder sans validation humaine

**Jamais** sauvegarder le PRD sans que l'utilisateur ait dit "oui c'est bon" explicitement. Le PRD est lu par tous les skills suivants — si t'as une erreur dedans, tu la propages partout. Toujours afficher → attendre validation → sauvegarder.

## Quand ne PAS utiliser ce skill

- Idée encore floue → `/brainstorm` d'abord
- Modification d'un PRD existant → édite directement le fichier
- Projet très petit (1-2 fichiers, fix rapide) → pas besoin de PRD

## Handoff

Fin du skill : message avec le path du PRD validé + suggestion `/plan {prd-projet}.md` Phase 1.
