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

L'utilisateur passe en argument soit `prd-{projet}.md`, soit le numéro de phase ("phase 1"), soit les deux.

Lire le PRD. Identifier la phase à planifier. Reformuler à l'utilisateur :

> "OK, je vais planifier **Phase {N} — {nom}** : {description PRD}. C'est ça ?"

### Étape 2 — poser 3-5 questions ciblées

Selon la phase, poser **3 à 5 questions** précises qui te manquent pour découper :

- "Tu veux que je commence par le frontend ou le backend ?"
- "Tu as déjà un compte Supabase / Vercel / GitHub configuré ?"
- "Pour cette phase, tu veux des tests automatisés ou on valide à la main ?"
- "Quel format pour les noms de fichiers : kebab-case, camelCase ?"
- "Y a-t-il un design ou une maquette à respecter ?"

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

> PRD parent : `prd-{projet}.md`
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
