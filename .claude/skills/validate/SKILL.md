---
name: validate
description: Utiliser après /execute pour vérifier qu'une phase fonctionne réellement (pas juste "le code compile"). Propose 3 options de validation selon le contexte (web → Playwright, n8n → test exécution, autre → demande). Ne PAS utiliser pour valider un PRD ou un plan — usage = vérifier l'exécution.
---

# Skill /validate — vérifier que ça marche pour de vrai

## Pour quoi faire

Après `/execute`, vérifier que la phase **fait vraiment ce qu'elle est censée faire**. Pas "le code compile". Pas "ça devrait marcher". Tu **lances** l'application, tu **observes** le comportement, tu donnes un **verdict** réel.

## Règle stricte numéro 1

> **Tu ne dis jamais "ça devrait marcher".**

Si tu n'as pas testé, dis "je n'ai pas testé". Si tu as testé et ça marche, dis "j'ai testé X, ça marche". Si ça marche pas, dis "j'ai testé X, voilà l'erreur, voilà ce que je propose".

## Comment procéder

### Étape 1 — lire le plan + identifier le type de projet

Lire `phase-{N}-plan.md`. Identifier le type de livrable :

- **App web** (Next.js, page web déployée) → option A
- **Workflow n8n** → option B
- **Autre** (script, API, CLI) → option C

### Étape 2 — proposer 3 options

Toujours **proposer 3 options** à l'utilisateur, pas une décision en silence :

> "Pour valider la phase {N}, je te propose 3 options :
>
> **A. Test navigateur (Playwright)** — je lance le navigateur, je clique, je vérifie ce qui s'affiche. Bon pour les apps web.
>
> **B. Test workflow n8n** — j'envoie un trigger réel au workflow, je vérifie la sortie. Bon pour n8n.
>
> **C. Autre** — dis-moi comment tu veux que je teste, je m'adapte (script, API call, manuel avec captures d'écran).
>
> Tu préfères quelle option ?"

### Étape 3 — exécuter le test

Selon l'option choisie, **lance vraiment le test** :

**Option A — Playwright** :
- Lancer le serveur (`npm run dev` ou URL Vercel)
- Naviguer vers la page
- Snapshot DOM ou screenshot
- Vérifier les éléments attendus (boutons, textes, couleurs)
- Vérifier les actions (clic → état change)

**Option B — n8n** :
- Identifier le webhook ou trigger du workflow
- Envoyer une requête réelle (curl ou interface n8n)
- Vérifier l'exécution dans n8n (succès/échec, sortie)
- Vérifier les effets (BDD insérée, message envoyé, etc.)

**Option C — autre** :
- Demander à l'utilisateur comment tester
- Suivre les instructions
- Toujours **observer la sortie**

### Étape 4 — verdict

Format de sortie strict :

```markdown
## Validation Phase {N}

### Méthode utilisée
- {A / B / C} : {description courte}

### Tests réalisés
- [{x ou ✗}] {test 1} : {ce que j'ai vu}
- [{x ou ✗}] {test 2} : {ce que j'ai vu}

### Verdict
- **{✅ OK / ⚠️ Partiel / ❌ KO}**

### Si KO ou Partiel
- Cause probable : {analyse}
- Proposition de correction : {action concrète}
```

### Étape 5 — décision

- **OK** → annoncer "Phase {N} validée. Tu veux passer à `/plan` Phase {N+1} ?"
- **Partiel** → demander à l'utilisateur s'il accepte ou veut corriger
- **KO** → revenir sur `/execute` pour fix, puis re-`/validate`

## Risque #1 — valider sans avoir lancé

Si t'écris "Phase 1 validée ✅" sans avoir lancé le serveur ni cliqué sur un bouton, c'est un mensonge.

**Test du miroir** : tu dois pouvoir dire à l'utilisateur **exactement ce que tu as fait** : "j'ai lancé `npm run dev`, j'ai ouvert `localhost:3000`, j'ai cliqué le bouton vert, j'ai vu le compteur passer de 0 à 1". Si tu ne peux pas raconter ça, t'as pas validé.

## Cas particulier — projet sans tests automatisés

Pas grave. La validation manuelle bien faite vaut mieux qu'un test bidon. L'important c'est :
1. Tu **fais** un truc dans le produit (clic, requête, exécution)
2. Tu **observes** la sortie (UI, logs, BDD)
3. Tu **rapportes** ce que tu as vu, pas ce que tu **supposais**

## Quand ne PAS utiliser ce skill

- Phase pas encore exécutée → `/execute` d'abord
- Validation d'un PRD ou plan (relecture qualité) → c'est de la review, pas du `/validate`
- Test unitaire isolé → c'est `npm test`, pas un skill

## Handoff

Fin du skill : verdict + prochaine étape. Si ✅ OK → `/plan` phase suivante ou `/close`. Si KO → `/execute` correction.
