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

**2a — Comprendre la nature** : avant de proposer une stack, pose 1-2 questions ciblées :

- "Où l'utilisateur final voit-il le résultat — dans son navigateur, par mail, dans une notification, dans un fichier exporté ?"
- "Y a-t-il un output qui doit s'afficher en temps réel (streaming, progression visible) ? Ou peut-il être livré quelques secondes plus tard (mail, PDF, notification) ?"

Ces questions déterminent les choix techniques **avant** de figer la stack :
- **Output live à l'écran (streaming)** → SDK direct (Anthropic, OpenAI) dans une API route ; n8n ne sait pas streamer vers un navigateur.
- **Output asynchrone (PDF, email, BDD, intégration externe)** → workflow n8n + callback de notification.
- **Mix des deux** → frontière explicite : SDK pour le live, n8n pour le reste.

**2b — Demander les providers favoris** (avant de proposer une stack par défaut) :

> *"Avant que je propose une stack, est-ce que tu as des providers de référence que tu utilises déjà (gratuits ou payants) ? Par exemple :*
> *- **Hosting** (où ton app tourne) — Vercel ? Netlify ? Cloudflare Pages ? GitHub Pages ? Hostinger ? Autre ? Pas d'avis ?*
> *- **BDD** (où tes données vivent, si applicable) — Supabase ? Neon ? PlanetScale ? Pas de BDD ? Pas d'avis ?*
> *- **Email transactionnel** (si applicable) — Resend ? Postmark ? Pas d'envoi d'email ? Pas d'avis ?*
> *Dis-moi ce que tu sais et je remplis les trous avec mes défauts."*

**Défauts (utilisés si "pas d'avis" pour ce slot)** — alignés sur ce qui est couvert dans la communauté IAPreneurs :
- Hosting → **Vercel** (gratuit pour projets perso, intégré GitHub, simple)
- BDD → **Supabase** (gratuit jusqu'à 500 MB, Auth + BDD + Realtime en un, RLS native)
- Email → **Resend** (3000 emails/mois gratuit, DX moderne)
- Automation runtime → **n8n self-hosted** (couvert dans la commu) ou **n8n cloud** (si l'utilisateur veut zéro infra)

**2c — Proposer la stack complète**, alignée avec la nature du projet **ET** les providers retenus :

- **App web (CRUD + auth)** : Next.js (App Router) + Tailwind + shadcn/ui + `{BDD retenue}` + `{Hosting retenu}`
- **App web avec génération IA visible** : ci-dessus + Anthropic SDK dans une API route Next.js
- **App web avec génération IA async (PDF, email)** : ci-dessus + workflow n8n via webhook + callback `{BDD}` Realtime
- **Automatisation pure (pas d'UI front)** : n8n + `{BDD}` (stockage / état) + intégrations externes
- **Voix** : Vapi (provider voice IAPreneurs community-friendly)
- **Scripts ponctuels** : Python ou TypeScript Node

Toujours **demander confirmation** : "Je propose **{stack complète avec providers retenus}**. Ça te va ou tu veux changer un truc ?"

Si l'utilisateur ne sait pas trancher entre SDK direct et n8n, ré-explique brièvement : "tokens qui doivent défiler à l'écran = SDK ; PDF ou email qui peut arriver dans 20 secondes = n8n".

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

### Étape 6 — Provisioning & Scaffold

Une fois `PRD.md` et `CLAUDE.md ## Stack` à jour, on **scaffold le repo concrètement** et on **provisionne les credentials externes** — sans ça, l'utilisateur a un PRD mais un repo vide et `/plan Phase 1` commence dans le mur.

**6.1 — Lire `project_type`** depuis `<!-- start:identité -->` dans `CLAUDE.md`. Si la variable est absente ou invalide (∉ `{site, webapp, automation}`) :
- Demande **une fois** : *"Quel type de projet : (a) site vitrine 1-5 pages, (b) web app SaaS avec auth+BDD, (c) automatisation n8n pure ?"*
- Écris la réponse dans `<!-- start:identité -->` (`project_type: webapp` par exemple)
- Continue. **Pas de re-demande ensuite.**

**6.2 — Proposer la séquence de commandes shell** (jamais auto-exécutées sans validation explicite, **jamais** de destructive `rm -rf`/`--force`/`--no-verify` automatiquement) :

| `project_type` | Commandes proposées |
|---------------|---------------------|
| `site` | `npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*"` + optionnel `npm i resend` (si formulaire contact prévu) |
| `webapp` | `npx create-next-app@latest . --typescript --tailwind --app --src-dir --import-alias "@/*"` + `npm i @supabase/supabase-js @supabase/ssr` + `npx supabase init` (génère `supabase/config.toml`) |
| `automation` | `mkdir -p workflows` + créer `workflows/.gitkeep` + tester connexion n8n MCP via `claude mcp list` (vérifier que n8n est listé) |

Affiche le bloc commandes complet, **demande confirmation explicite** : *"J'exécute cette séquence ? (oui / modifie / skip)"*. Si "modifie", l'utilisateur édite, tu re-affiches. Si "skip", tu passes à 6.3. Si "oui", tu exécutes ligne par ligne en montrant l'output.

**6.3 — Provisioning credentials externes** (interactif, jamais en clair dans le repo) :

- **Supabase** (si `webapp`) : guide l'utilisateur — *"Va sur supabase.com/dashboard, crée un projet, copie-colle l'URL et la `anon key` ici"*. Tu récupères les 2 valeurs, tu les écris dans `.env` au format `NEXT_PUBLIC_SUPABASE_URL=...` + `NEXT_PUBLIC_SUPABASE_ANON_KEY=...`.
- **Vercel** (si `webapp` ou `site`) : *"Tu veux lier ton repo à Vercel maintenant ou plus tard (au `/livrer`) ? Si maintenant, tape `vercel link` dans un autre terminal puis colle le `.vercel/project.json` créé"*. Si l'utilisateur skip, note dans le PRD que Vercel est reporté à `/livrer`.
- **n8n** (si `webapp` async ou `automation`) : vérifie que `.env` contient `N8N_API_URL` + `N8N_API_KEY`. Si absent, demande à l'utilisateur de les fournir (ou de skipper si pas de besoin immédiat). Teste la connexion via le MCP n8n (`claude mcp list` doit montrer `n8n`).

**6.4 — Écrire `.env` depuis `.env.example` + vérifier `.gitignore`** :
1. Si `.env.example` existe à la racine, fais `cp .env.example .env` (uniquement si `.env` n'existe pas — **jamais** d'écrasement).
2. Écris les credentials récupérées en 6.3 dans `.env`.
3. Vérifie que `.gitignore` contient `.env` et `.env.local` et `.env.*.local`. Si absent, ajoute (sans toucher au reste du `.gitignore`).
4. **Test final** : `git check-ignore .env` doit retourner `.env`. Si non, alerte l'utilisateur — sécurité critique.

Annonce à l'utilisateur : *"Repo scaffold + credentials provisionnées. `.env` est gitignored. Prêt pour `/plan Phase 1`."*

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

Fin du skill : message avec le path du PRD validé + confirmation scaffold/provisioning.

- **Si `project_type = webapp`** → suggestion `/design` AVANT `/plan Phase 1`. Le `DESIGN.md` produit par `/design` sera lu par le plugin `frontend-design` à chaque création de composant — sans, le plugin réinvente une palette à chaque page.
- **Si `project_type = site` ou `automation`** → suggestion `/plan Phase 1` direct (pas de design system custom nécessaire).
