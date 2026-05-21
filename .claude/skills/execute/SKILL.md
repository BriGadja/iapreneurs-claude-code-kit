---
name: execute
description: Utiliser pour exécuter un fichier `phase-{N}-plan.md` créé par /plan. Coche les tâches au fur et à mesure (`[x]` dans le plan), fait une auto-évaluation déterministe avant le handoff (Playwright sur localhost pour UI, curl pour API, n8n_test_workflow pour automation — JAMAIS `file://`). Ne marque PAS ✅ Terminée dans le PRD — depuis v2.0 c'est `/close` qui le fait (source unique, après `/validate ✅`). Ne PAS utiliser sans plan — créer le plan d'abord avec /plan.
---

# Skill /execute — exécuter un plan tâche par tâche

**Invocation** : `/execute docs/plans/phase-{N}-plan.md` (priorité v2.1.0+) ou `/execute phase-{N}-plan.md` / `/execute plans/phase-N.md` (fallback compat projets pré-v2.1.0). Le skill cherche le plan dans cet ordre : argument littéral → `docs/plans/{arg}` → `plans/{arg}` → racine.

## Pour quoi faire

Tu prends un fichier `phase-{N}-plan.md` et tu **fais** ce qu'il dit. Une tâche, puis la suivante. Tu coches `[x]` quand c'est fini. À la fin de la phase, tu **ne marques PAS ✅ Terminée dans le PRD** — depuis v2.0 c'est `/close` qui s'en charge (source unique, après le verdict `/validate ✅`). Tu finis tes tâches, tu passes la main à `/validate` puis `/close`.

## Règles strictes

1. **Une tâche à la fois**. Pas 3 en parallèle. Pas en avance sur la suivante.
2. **Cocher la case `[x]`** dans le fichier `phase-{N}-plan.md` **à chaque** tâche finie.
3. **Vérifier le critère "Fait quand"** avant de cocher. Si le critère n'est pas vérifié, la tâche n'est pas finie.
4. **Pas d'improvisation**. Si tu vois un truc à améliorer hors plan, **note-le** dans la section "Découvertes" en bas du fichier mais ne le fais pas. Le scope du plan, c'est le scope.
5. Si une tâche **ne peut pas être finie** (manque info, blocage technique), deux options :
   - **Manque d'info externe** (doc d'API, syntaxe d'une lib, exemple de config) → lance un sous-agent `research-delegate` qui va lire la doc à ta place et te ramener juste ce dont tu as besoin. Ton contexte ne se remplit pas de pages de docs entières.
   - **Blocage qui dépend d'une décision utilisateur** → arrête-toi et demande.

## Comment procéder

### Étape 1 — lire le plan + le PRD

Lire `phase-{N}-plan.md` passé en argument. Lire aussi le PRD parent (mentionné dans le header du plan) pour avoir le contexte global.

### Étape 2 — pour chaque tâche dans l'ordre

> **🔁 Golden rule (validation post-task)** — après CHAQUE tâche, lance la vérif "Fait quand" **immédiatement** (PAS batched à la fin de la phase).
>
> **❌ Anti-pattern** : Faire tâche 1 + 2 + 3 puis vérifier toutes les "Fait quand" ensemble.
> **✅ Pattern** : Tâche 1 → vérifier → cocher → tâche 2 → vérifier → cocher → ...
>
> Raison : tester à la fin laisse les bugs s'accumuler. Tester après chaque tâche te dit immédiatement si tu casses quelque chose.

Boucle sur les tâches `[ ]` non cochées :

1. **Annoncer** : "Je commence la tâche {N} : {nom}."
2. **Faire** ce qu'il faut (créer fichiers, configurer services, etc.)
3. **Vérifier le critère "Fait quand"** :
   - Si commande à lancer → la lancer, vérifier la sortie
   - Si fichier à créer → vérifier qu'il existe + ouvrir + scanner
   - Si test à passer → lancer le test, vérifier exit code
4. **Si critère vérifié** → cocher `[x]` dans le fichier `phase-{N}-plan.md`
5. **Si critère non vérifié** → corriger, retenter (max 3 fois). Si échec persistant → arrêter et demander.

### Étape 2.5 — Auto-évaluation AVANT le handoff (non négociable)

> **Pourquoi cette étape existe** : cocher `[x]` une tâche prouve que tu as écrit le fichier. Ça ne prouve PAS que le résultat marche pour un utilisateur. Avant de passer la main à `/validate` (qui couvre les critères de phase + AC), tu fais ta propre boucle de vérif déterministe — sinon tu refiles à `/validate` un projet à débugger au lieu d'un projet à signer.

**Anti-patterns explicitement interdits** (vus en prod, à ne JAMAIS faire) :
- ❌ Annoncer "le site marche" parce que le fichier `.html` existe sur disque
- ❌ Ouvrir un `.html` en `file://` dans le navigateur pour "tester" — ça n'attrape ni les bugs de fetch, ni de CORS, ni de routing relatif, ni de Tailwind/SSR/build
- ❌ Skip Playwright parce que "c'est juste un mockup" — le MCP est installé par `/start` justement pour cette étape
- ❌ Skip `npm test` / `vitest` parce que "j'ai juste touché à du CSS"

**Procédure** : lis la valeur de `project_type` dans `CLAUDE.md ## Identité`, puis applique la ligne correspondante du tableau ci-dessous. Si la phase a touché à plusieurs catégories (UI + API par exemple), tu fais TOUTES les vérifs concernées, pas juste une.

| `project_type` | Modif a touché à... | Vérification obligatoire |
|----------------|---------------------|--------------------------|
| `webapp` / `site` | UI (`.tsx`, `.html`, `.css`, page, layout, composant) | (1) Lancer le dev server (`npm run dev` ou équivalent du framework — JAMAIS `file://`) en background ; (2) **Invoquer le sub-agent `browser-verifier`** avec `url = http://localhost:{port}/{route concernée}` + critères contextuels (status 2xx, console_errors == 0, non_blank, et selectors présents si la phase a ajouté des éléments identifiables). Affiche son verdict à l'utilisateur sous la forme `Vérification UI : OK ({raison})` / `Vérification UI : anomalie — {raison}` / `Vérification UI : KO — {raison}`. JAMAIS de mention du sub-agent côté UX. |
| `webapp` | API / route serveur | `curl -i` sur l'endpoint → status + 5 premières lignes du payload affichés dans la réponse |
| `webapp` / `site` | BDD (migration, RLS, table) | Query directe (`psql`, Supabase MCP, ou client équivalent) → vérifier structure + une row de test si applicable |
| `automation` | Workflow n8n | `n8n_test_workflow` via MCP (si trigger webhook/form/chat) OU `curl` sur le webhook → vérifier output + status. Si schedule-only : ajouter temporairement un webhook trigger en parallèle pour smoke-test, ou attendre prochain run scheduled |
| Tout type | Tests automatisés | `npm test` / `vitest run` → 0 failure, lire le résumé final |
| Tout type | Build de prod (si livrable) | `npm run build` → 0 erreur (anticipe `/livrer`) |

**Critère de passage** : tu dois pouvoir raconter à l'utilisateur, en 2-3 phrases concrètes, **exactement ce que tu as observé** (URL visitée et verdict browser-verifier, status code reçu sur curl, output de test). Si tu te surprends à écrire "ça devrait marcher" ou "le fichier est créé", tu n'as pas auto-évalué — refais.

Si une vérification **échoue** :
1. Diagnostique la cause racine (pas un patch qui masque)
2. Corrige
3. Re-coche la tâche concernée + relance la vérif jusqu'à ce qu'elle passe
4. Max 3 itérations avant d'arrêter et demander à l'utilisateur

**Si Playwright n'est pas installé** alors que `project_type` est `webapp` / `site` et qu'il y a de l'UI : **stop**. Demande à l'utilisateur de relancer `/start` Étape 5a (qui installe Playwright) avant de continuer. Ne tente pas un fallback `file://` — c'est exactement l'anti-pattern à bloquer.

### Étape 3 — phase complète (tâches `[x]`, auto-éval passée)

Quand toutes les tâches sont `[x]` ET l'Étape 2.5 a passé proprement :
1. Vérifier le **critère de phase complète** (en bas du plan).
2. **Ne PAS marquer ✅ Terminée dans le PRD** — c'est le job de `/close` (source unique depuis v2.0, après le verdict de `/validate`).
3. Annoncer à l'utilisateur : *"Phase {N} : toutes les tâches cochées, auto-évaluation OK ({2-3 lignes qui résument ce que tu as observé}). Passe à `/validate docs/plans/phase-{N}-plan.md` pour vérifier les critères de phase, puis `/close` marquera ✅ Terminée et fera le commit."*

## Risque #1 — sauter le critère "Fait quand"

C'est le risque le plus fréquent : tu codes vite, tu coches la case sans vérifier. Résultat : 3 tâches plus tard, t'as une régression et tu perds 2h à débugger.

**Test du miroir** : avant de cocher `[x]`, tu dois avoir **vu** la sortie d'une commande ou **lu** un fichier. Pas "je l'ai créé je suppose que ça marche". Tu lances, tu lis, tu coches.

## Si tu casses un truc

Si pendant l'exécution un test/build/feature qui marchait avant **casse** :
1. **Stop**. Ne passe pas à la tâche suivante.
2. **Identifie ce qui a cassé**. Lis l'erreur, pas juste le titre.
3. **Cherche la cause racine**. Pas un patch qui masque le problème.
4. **Corrige**.
5. **Re-vérifie** la tâche en cours et celle d'avant.

Cf. règle de comportement #4 (orienté but) du `CLAUDE.md`.

## Découvertes en cours d'exécution

Si tu remarques un truc à améliorer hors plan (refactor, bug existant, opportunité), **ne le fais pas**. Note-le en bas du fichier `phase-{N}-plan.md` :

```markdown
## Découvertes (hors plan)

- 2026-XX-XX : `src/api.ts` a du code mort lignes 40-55, à nettoyer plus tard.
- 2026-XX-XX : la fonction `formatDate` est dupliquée dans 3 fichiers, à refactor.
```

L'utilisateur décidera plus tard s'il veut ouvrir un nouveau plan dessus.

## Quand ne PAS utiliser ce skill

- Pas de fichier plan → `/plan` d'abord
- Tâche unique non planifiée → fais-la directement
- Le plan a 0 tâche cochable (juste de la doc) → pas un /execute

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "execute", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Fin du skill : annonce phase terminée + suggestion `/validate docs/plans/phase-{N}-plan.md` (chemin v2.1.0+, fallback racine ou `plans/` accepté).

**Prochaine étape** : `/validate docs/plans/phase-{N}-plan.md`
