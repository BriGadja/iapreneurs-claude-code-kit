---
name: challenge
description: Utiliser pour passer un plan (`phase-{N}-plan.md`) au crible d'un devil's advocate avant /execute. Sortie — 3 risques majeurs + 3 hypothèses non vérifiées + verdict GO/REWORK/STOP. Ne PAS utiliser sans plan — créer le plan d'abord avec /plan. Ne PAS utiliser pour challenger un PRD — c'est /plan qui pose les questions de cadrage en amont.
---

# Skill /challenge — devil's advocate sur un plan

**Invocation** : `/challenge docs/plans/phase-{N}-plan.md` (priorité v2.1.0+) ou `/challenge phase-{N}-plan.md` / `/challenge plans/phase-N.md` (fallback compat projets pré-v2.1.0). Le skill cherche le plan dans cet ordre : argument littéral → `docs/plans/{arg}` → `plans/{arg}` → racine.

## Pour quoi faire

Avant `/execute`, faire un dernier passage critique sur le plan. **Objectif** : trouver ce que `/plan` n'a pas vu. Tu joues le rôle d'un collègue lucide qui pose les questions qui dérangent. Sortie : 3 risques majeurs + 3 hypothèses non vérifiées + un verdict **GO / REWORK / STOP**.

## Règle stricte numéro 1

**Tu n'es pas là pour valider.** Si tu n'as rien trouvé de gênant, t'as pas assez cherché. Re-lis le plan en mode "qu'est-ce qui peut foirer ?".

## Comment procéder

### Étape 1 — lire le plan + le PRD

Lire `phase-{N}-plan.md` ET le PRD parent. Sans le PRD, tu challenges dans le vide — tu ne sais pas si le plan respecte le scope MVP.

### Étape 2 — chercher 3 risques majeurs

Catégories à scanner (ne pas toutes traiter, choisir les 3 plus probables × les plus graves) :

1. **Risque technique** : une tâche dépend d'un service / API / lib qui peut casser ou changer ?
2. **Risque scope** : une tâche cache en réalité 3 sous-tâches (mal découpée) ?
3. **Risque sécurité** : RLS, validation côté serveur, gestion des secrets sont-ils dans le plan ? Si données clients réelles → RLS doit être une tâche explicite.
4. **Risque "ça compile mais ça marche pas"** : le critère "Fait quand" est-il vraiment vérifiable de l'extérieur (clic utilisateur, requête réelle, sortie observable) ou juste "le fichier existe" ?
5. **Risque effet d'ordre** : la tâche 4 a-t-elle vraiment toutes ses dépendances cochées par les tâches 1-3 ?
6. **Risque infra** : Supabase / Vercel / n8n / domaine — qui doit être en place AVANT la tâche 1 ? Provisioning oublié ?

Sors **3 risques**. Pas 5 (dilution). Pas 1 (sous-challenge).

### Étape 3 — chercher 3 hypothèses non vérifiées

Lis le plan en cherchant les phrases qui présupposent quelque chose. Exemples :
- "On suppose que Supabase est déjà configuré" — vérifié ?
- "Le webhook n8n existe" — vérifié ?
- "L'utilisateur a Node 22" — vérifié ?
- "L'API Anthropic retourne du markdown propre" — vérifié sur un échantillon ?

Sors **3 hypothèses** dont la fausseté tuerait l'exécution.

### Étape 4 — verdict

Format strict :

```markdown
## Challenge — Phase {N}

> Plan challengé : `phase-{N}-plan.md`
> PRD parent : `PRD.md`
> Date : {YYYY-MM-DD}

### 3 risques majeurs
1. **{titre court}** — {pourquoi grave, ce qui se passerait concrètement}
2. **{titre}** — ...
3. **{titre}** — ...

### 3 hypothèses non vérifiées
1. **{hypothèse}** — comment la vérifier en < 5 min avant d'exécuter ?
2. ...
3. ...

### Verdict
- **GO** : risques connus, acceptables, on lance `/execute`
- **REWORK** : 1-2 risques nécessitent de retoucher le plan avant d'exécuter (préciser quelles tâches à modifier)
- **STOP** : un risque tue le plan ou révèle un trou dans le PRD, retour à `/architect` ou `/brainstorm`
```

### Étape 5 — décision et handoff

- **GO** → annonce "Plan validé, on attaque" + suggestion `/execute phase-{N}-plan.md`
- **REWORK** → liste les modifications à apporter au plan, demande à l'utilisateur s'il veut que tu édites direct ou si lui le fait
- **STOP** → annonce "Le plan a un trou structurel" + propose la prochaine étape (`/architect` ou `/brainstorm`)

## Risque #1 — challenger pour la forme

Si tu sors 3 risques bidon (genre "le serveur peut tomber"), tu fais pire que rien : l'utilisateur s'habitue à ignorer le verdict et le `/challenge` devient un tampon administratif.

**Test du miroir** : un risque est crédible si tu peux écrire en 1 phrase **comment il se réaliserait dans CE projet**. "Le serveur peut tomber" → faux. "Si Supabase change le format de retour de auth.getUser() entre deux versions, les tâches 3 et 5 cassent silencieusement" → crédible et actionnable.

## Quand ne PAS utiliser ce skill

- Pas de plan → `/plan` d'abord
- Plan ultra-petit (1-2 tâches triviales) → pas la peine, lance direct
- Tu veux challenger un PRD ou une idée → c'est `/plan` (qui pose les questions de cadrage stack/architecture) ou retour à `/brainstorm`

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "challenge", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Affiche à l'utilisateur :

```
✅ Plan challengé (verdict GO) : {chemin-plan}

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /execute {chemin-plan}
```

**Prochaine étape** : `/close → /clear → /execute {chemin-plan}` — voir le rituel dans `docs/KIT.md § STATUS.md & rituel`.
