---
name: validate
description: Utiliser après /execute pour vérifier qu'une phase fonctionne réellement (pas juste "le code compile"). Propose 3 options de validation selon le contexte (web → Playwright, n8n → test exécution, autre → demande). Ne PAS utiliser pour valider un PRD ou un plan — usage = vérifier l'exécution.
---

# Skill /validate — vérifier que ça marche pour de vrai

**Invocation** : `/validate docs/plans/phase-{N}-plan.md` (priorité v2.1.0+) ou `/validate phase-{N}-plan.md` / `/validate plans/phase-N.md` (fallback compat projets pré-v2.1.0). Le skill cherche le plan dans cet ordre : argument littéral → `docs/plans/{arg}` → `plans/{arg}` → racine.

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
- **Phase touche Supabase + données clients (transcripts, contacts, paiements, multi-tenant)** → option D **en plus** de A/B/C, jamais à la place

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
> **D. Audit sécurité Supabase** *(en plus de A/B/C, pas à la place)* — `get_advisors` sur ton projet + lister les policies RLS sur les tables touchées en Phase {N}. Pas de policy = critical. À lancer dès que la phase manipule des données clients réelles (transcripts, contacts, paiements, multi-tenant).
>
> Tu préfères quelle option ?"

### Étape 2bis — phase grosse ? Parallélise

Si la phase touche **plusieurs dimensions** (UI + API + sécurité RLS + workflow n8n), valide en parallèle au lieu de tout faire toi-même en série :

```
Agent en parallèle (dans le même message, plusieurs tool calls) :
- research-delegate : "Vérifie que les composants UI de Phase {N} s'affichent dans le navigateur — liste ce que tu vois"
- research-delegate : "Vérifie que les RPC Supabase de Phase {N} retournent les bons types — liste les outputs"
- research-delegate : "Audit RLS sur les tables touchées en Phase {N} — get_advisors + lister les policies"
```

Chaque sous-agent te ramène son verdict, tu compiles le tien. Tu gagnes du temps (parallèle au lieu de série) et ton contexte reste propre.

**Pour une phase simple** (1 dimension, ex: juste un bouton qui appelle une API), skip cette étape — tu testes toi-même direct en Étape 3.

### Étape 3 — exécuter le test

Selon l'option choisie, **lance vraiment le test** :

**Option A — Playwright (via sub-agent `browser-verifier`)** :
- Lancer le serveur si besoin (`npm run dev` ou URL prod selon hosting détecté)
- **Invoquer le sub-agent `browser-verifier`** avec `url = http://localhost:{port}/{route à tester}` (ou URL prod) + critères contextuels issus du plan de phase : status 2xx, console_errors == 0, non_blank, et `selectors_present` listant les éléments clés que la phase devait livrer (boutons, formulaires, textes attendus).
- Affiche le verdict à l'utilisateur dans la section "Tests réalisés" du verdict (Étape 4) sous la forme `Vérification UI : OK ({raison browser-verifier})` / `Vérification UI : anomalie — {raison}` / `Vérification UI : KO — {raison}`. JAMAIS de mention du sub-agent côté UX.
- Pour les actions (clic → état change), enchaîne plusieurs appels du sub-agent avec des URLs ou critères différents si nécessaire (le sub-agent navigue et snapshotte, le parent décide de l'enchaînement).
- Le sub-agent gère son propre cleanup (`rm tmp/browser-verify/*.png` après lecture du screenshot).

**Option B — n8n** :
- Identifier le webhook ou trigger du workflow
- Envoyer une requête réelle (curl ou interface n8n)
- Vérifier l'exécution dans n8n (succès/échec, sortie)
- Vérifier les effets (BDD insérée, message envoyé, etc.)

**Option C — autre** :
- Demander à l'utilisateur comment tester
- Suivre les instructions
- Toujours **observer la sortie**

**Option D — audit sécurité Supabase** (en complément de A/B/C, jamais seul) :
- Lance `mcp__supabase__get_advisors` (ou équivalent) sur le projet — note les advisories `security:high` et `security:medium`
- Pour chaque table touchée en Phase {N} (créée, modifiée, ou requêtée), liste les policies RLS :
  ```sql
  SELECT tablename, policyname, cmd, qual, with_check
  FROM pg_policies
  WHERE schemaname = 'public' AND tablename IN (...);
  ```
- **Critical** si une table contient des données clients ET n'a aucune policy RLS — la table est ouverte à n'importe qui avec l'anon key
- Inclure les findings dans la section "Tests réalisés" du verdict avec préfixe `[RLS]`

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

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "validate", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Fin du skill : verdict + prochaine étape.

- **Si ✅ OK** → `/close` (**mandatory**, plus optionnel depuis v2.0). `/close` marque ✅ Terminée dans le PRD, fait le commit conventionnel, et :
  - Si ce n'est pas la dernière phase → suggère `/plan Phase {N+1}`
  - Si c'est la dernière phase ET le projet n'a jamais été livré → suggère `/livrer`
- **Si ⚠️ Partiel** → demander à l'utilisateur s'il accepte ou veut corriger via `/execute` puis re-`/validate`
- **Si ❌ KO** → revenir sur `/execute` (ou `/debug` natif Claude Code si bug complexe, avec test de régression obligatoire avant fix) pour fix, puis re-`/validate`. **Pas de `/close` tant que ce n'est pas ✅**.

**Prochaine étape** : `/close` (mandatory si verdict ✅ OK)
