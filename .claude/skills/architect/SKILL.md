---
name: architect
description: Utiliser pour transformer un fichier brainstorm (ou une idée claire) en Product Requirements Document structuré (PRD.md). Définit la stack et l'architecture du projet via 1-2 questions ciblées sur le type d'output. Ne PAS utiliser si l'idée est encore floue — passer par /brainstorm d'abord. Ne PAS utiliser pour ajouter une feature à un PRD existant — éditer directement le PRD.
---

# Skill /architect — définir l'architecture et produire le PRD

## Pour quoi faire

Transformer une idée (claire ou issue d'un `/brainstorm`) en **PRD** : un fichier `PRD.md` qui définit l'architecture du projet (stack, frontières techniques, phases) et sert de référence pour toute la suite (`/plan`, `/execute`, `/validate`). Le PRD est lu en début de chaque skill suivant.

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

### Étape 2 — déterminer la nature du projet, puis proposer la stack

Avant de proposer une stack, **comprends la nature du projet** en posant 1-2 questions ciblées :

- "Où l'utilisateur final voit-il le résultat — dans son navigateur, par mail, dans une notification, dans un fichier exporté ?"
- "Y a-t-il un output qui doit s'afficher en temps réel pendant que l'utilisateur attend (streaming, progression visible) ? Ou alors l'output peut-il être livré quelques secondes plus tard (mail, PDF, notification) ?"

Ces questions déterminent les choix techniques **avant** de figer la stack :
- **Output live à l'écran (streaming)** → SDK direct (Anthropic, OpenAI) dans une API route ; n8n ne sait pas streamer vers un navigateur.
- **Output asynchrone (PDF, email, BDD, intégration externe)** → workflow n8n + callback de notification cohabitable avec l'app.
- **Mix des deux** → frontière explicite : SDK pour le live, n8n pour le reste.

Puis **propose une stack par défaut** alignée avec la nature du projet :

- **App web (CRUD classique + auth)** : Next.js (App Router) + Tailwind + shadcn/ui + Supabase (Auth + BDD + Realtime si besoin) + Vercel
- **App web avec génération IA visible** : ci-dessus + Anthropic SDK (ou OpenAI / Mistral) dans une API route Next.js (runtime nodejs)
- **App web avec génération IA async (PDF, email)** : ci-dessus + workflow n8n via webhook + callback Supabase Realtime
- **Automatisation pure (pas d'UI front)** : n8n + Supabase (stockage / état) + intégrations externes
- **Voix** : Vapi (provider voice IAPreneurs community-friendly)
- **Scripts ponctuels** : Python ou TypeScript Node

Toujours **demander confirmation** : "Je propose **{stack}**. Ça te va ou tu veux changer un truc ?"

Si l'utilisateur ne sait pas trancher entre SDK direct et n8n, ré-explique brièvement la règle : "tokens qui doivent défiler à l'écran = SDK ; PDF ou email qui peut arriver dans 20 secondes = n8n".

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

Sauvegarder dans `PRD.md` à la racine du projet uniquement après validation explicite.

### Étape 5b — propager la Stack dans CLAUDE.md

Une fois `PRD.md` sauvegardé, ouvre `CLAUDE.md` et trouve le bloc :

```
<!-- architect:stack -->
{...placeholder ou contenu précédent...}
<!-- /architect:stack -->
```

Remplace le contenu entre les deux ancres par la **section Stack du PRD** (juste les bullets, pas le titre `## Stack technique`). **Garde les ancres**, **ne touche à aucune autre partie du `CLAUDE.md`**.

Si les ancres `<!-- architect:stack -->` / `<!-- /architect:stack -->` ne sont pas trouvées (CLAUDE.md trop ancien ou template modifié) :
1. Cherche le heading `## Stack` à la racine du fichier
2. Si trouvé, remplace son contenu placeholder par les bullets du PRD + ajoute les ancres autour pour les futures sessions
3. Si pas trouvé non plus, dis à l'utilisateur : *"Pas d'ancre `<!-- architect:stack -->` ni de section `## Stack` dans CLAUDE.md. Je n'écris pas pour ne pas casser ta structure. Tu veux que je l'ajoute en bas du fichier ?"*

Annonce à l'utilisateur : *"Stack synchronisée dans `CLAUDE.md ## Stack`. Future Claude saura quelle techno tu utilises sans relire le PRD entier."*

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

Fin du skill : message avec le path du PRD validé.

- **Si la stack du PRD inclut une UI web** (Next.js, React, Vue, Svelte, etc.) → suggestion `/design` AVANT `/plan` Phase 1. Le `DESIGN.md` produit par `/design` sera lu par le plugin `frontend-design` à chaque création de composant — sans, le plugin réinvente une palette à chaque page.
- **Sinon** (script CLI, automation n8n pure, API backend) → suggestion `/plan` Phase 1 direct.
