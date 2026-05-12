---
name: plan
description: Utiliser pour découper UNE phase d'un PRD en tâches numérotées avec critères "Fait quand" vérifiables. Ne PAS utiliser si pas de PRD — créer le PRD d'abord avec /create-prd. Ne PAS planifier plusieurs phases d'un coup — une phase à la fois pour éviter le scope creep.
---

# Skill /plan — découper une phase en tâches

## Pour quoi faire

Prendre **UNE phase** d'un PRD et la découper en tâches numérotées avec des critères "Fait quand" vérifiables. Une tâche = un truc concret à faire (créer un fichier, écrire une fonction, configurer un service). Le fichier produit s'appelle `phase-{N}-plan.md` et il sert de check-list pendant `/execute`.

## Règles strictes

1. **Une phase à la fois** — jamais Phase 1 + Phase 2 dans le même fichier. Tu finis Phase 1, tu valides, puis tu fais `/plan` Phase 2.
2. **8 tâches max par phase** — au-delà, c'est que la phase est trop grosse. Re-découper.
3. **Chaque tâche a un critère "Fait quand"** vérifiable (objectif, pas subjectif). Pas "Fait quand ça marche". Plutôt "Fait quand le fichier `auth.ts` exporte la fonction `login(email, password)` et que `npm test auth.test.ts` passe."

## Comment procéder

### Étape 1 — lire le PRD + identifier la phase

L'utilisateur passe en argument soit `PRD.md`, soit le numéro de phase ("phase 1"), soit les deux.

Lire le PRD. Identifier la phase à planifier. Reformuler à l'utilisateur :

> "OK, je vais planifier **Phase {N} — {nom}** : {description PRD}. C'est ça ?"

### Étape 1bis — scout du codebase (si le projet a déjà du code)

Avant de découper en tâches du type "créer auth.ts", vérifie ce qui existe déjà. Sinon tu vas planifier la création d'un fichier qui existe sous un autre nom — et `/execute` va dupliquer.

**Si le projet contient déjà du code** (au moins un fichier `src/` ou `app/`), lance un sous-agent `research-delegate` pour scout :

```
Agent({
  subagent_type: "research-delegate",
  description: "Scout codebase pour Phase {N}",
  prompt: "Liste tous les fichiers liés à {sujet de la phase, ex: 'authentification' ou 'upload de transcripts'} qui existent déjà dans ce projet. Pour chaque fichier : ce qu'il fait en 1 ligne, et les fonctions/composants exportés. Sortie au format research-delegate standard."
})
```

Reprends la main avec la synthèse. Tu sais maintenant ce qui existe → tu planifies du nouveau, pas de la duplication. Le sous-agent a lu 20 fichiers, ton contexte n'en a vu que 5 lignes de résumé.

**Si le projet est vide** (juste un `package.json` ou rien), skip cette étape.

### Étape 2 — poser 3-5 questions ciblées sur la nature du projet et la phase

Selon la phase, poser **3 à 5 questions** précises qui te manquent pour découper. **Tu ne pré-supposes JAMAIS l'architecture** : tu déduis des réponses si SDK direct, n8n, ou autre est approprié.

Axes de questions (priorise selon ce que le PRD laisse ouvert) :

1. **Type d'output utilisateur** → "Le résultat de cette phase, l'utilisateur le voit où ? Page web qui se met à jour, mail reçu, fichier téléchargé, notification ?"
2. **Latence acceptable** → "L'output doit-il s'afficher en temps réel pendant que l'utilisateur attend (streaming token par token), ou peut-il arriver quelques secondes plus tard ?"
3. **Sensibilité des données** → "Tu manipules des données clients réelles (transcripts, contacts, paiements) ou des données éphémères (sondage live, kanban d'atelier) ? Cela détermine si RLS Supabase est obligatoire ou skippable."
4. **Infrastructure existante** → "Tu as déjà un compte Supabase / Vercel / GitHub / n8n configuré ? Sinon il faudra une tâche provisioning."
5. **Frontend ou backend d'abord ?** → "Tu préfères qu'on attaque le squelette UI ou la logique métier en premier ?"
6. **Test** → "Pour cette phase, tu veux des tests automatisés ou on valide à la main avec `/validate` ?"

**Règle d'inférence architecturale** : à partir des réponses Q1+Q2+Q3, infère l'architecture **sans la cacher** :
- Output live + streaming → Anthropic SDK (ou autre LLM SDK) dans une API route, `runtime='nodejs'`, ReadableStream cote front
- Output async (PDF, email, BDD) → workflow n8n + webhook + callback Supabase Realtime
- Données sensibles → RLS Supabase MANDATORY, audit `get_advisors` après chaque migration
- Données éphémères → RLS skippable, mais à justifier explicitement

Présente ton inférence à l'utilisateur AVANT de découper : "Vu tes réponses, je propose **{architecture}**. Ça te va, ou tu veux changer ?"

**Ne pas dépasser 5 questions**. Si t'as plus, la phase est mal découpée dans le PRD — propose de revenir à `/create-prd`.

### Étape 3 — découper en 3-8 tâches

Chaque tâche doit être :
- **Concrète** (créer fichier X, configurer service Y)
- **Indépendante** ou avec dépendance explicite ("après tâche 2")
- **Vérifiable** par un critère mesurable

### Étape 4 — afficher + valider + sauvegarder

Affiche le brouillon dans le chat. Demande validation. Sauvegarder seulement après "oui c'est bon".

## Format du fichier

```markdown
# Plan — Phase {N} : {nom}

> PRD parent : `PRD.md`
> Date : {YYYY-MM-DD}

## Tâches

- [ ] **1. {nom de la tâche}** — Fait quand : {critère vérifiable}
- [ ] **2. {nom}** — Fait quand : {critère}
- [ ] **3. {nom}** — Fait quand : {critère}
- [ ] **4. {nom}** — Fait quand : {critère}

## Critère de phase complète

- [ ] Toutes les tâches 1 à N sont cochées
- [ ] {critère global de la phase, ex: "L'utilisateur peut s'inscrire end-to-end"}

## Prochaine étape

`/execute phase-{N}-plan.md`
```

## Exemple de tâche bien formulée

❌ Mauvais : "Faire l'authentification"
✅ Bon : "Créer `src/lib/auth.ts` qui exporte `signIn(email, password)` et `signOut()`. Fait quand : `npm run lint` passe + `signIn` retourne `{ user, session }` valide quand testé manuellement avec un compte de test."

## Risque #1 — tâches floues

Si tu écris "faire la BDD" ou "configurer le backend", c'est trop vague. À `/execute`, l'agent va patiner. **Test du miroir** : si tu ne peux pas vérifier la tâche en 30 secondes via une commande ou un fichier, c'est trop vague. Re-découper.

## Quand ne PAS utiliser ce skill

- Pas de PRD → `/create-prd` d'abord
- Tâche très petite (1 fichier, 5 minutes) → fais-le directement, pas la peine de planifier
- Plusieurs phases d'un coup → une phase à la fois, c'est non-négociable

## Handoff

Fin du skill : path du fichier `phase-{N}-plan.md` + suggestion `/execute phase-{N}-plan.md`.
