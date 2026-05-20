---
name: close
description: Utiliser à la fin d'une phase (après /validate ✅) pour clôturer proprement — marque la phase ✅ Terminée dans le PRD (source unique depuis v2.0), propose un commit conventionnel à partir du diff, fait le harvest learnings conditionnel (auto-récap toujours dans memory/learnings/ + questions ciblées seulement si triggers détectés dans le diff : nouvelle dépendance, MCP, migration SQL, workaround, règle path-scoped, ADR), suggère /plan Phase N+1 ou /livrer si dernière phase. Détecte automatiquement le mode (planning rapide vs full fin-de-phase) — en mode planning skippe l'audit caps, l'amend SHA et le dialogue commit (auto-commit). L'utilisateur ne touche jamais à la mémoire manuellement — c'est ce skill qui la maintient. Skill mandatory post /validate ✅ (plus optionnel depuis v2.0).
---

# Skill /close — clôturer proprement une phase

**Invocation** : `/close` (rien à passer, le skill détecte la phase depuis le PRD + git status).

**Mandatory post-`/validate ✅`** depuis v2.0 — sans `/close`, le commit n'est jamais fait et le PRD reste non-à-jour. Le handoff de `/validate` ne propose plus le skip.

## Pour quoi faire

Après `/validate ✅`, faire la sortie propre :
1. Marquer la phase **✅ Terminée le YYYY-MM-DD** dans le PRD parent — **source unique** depuis v2.0 (avant, `/execute` Étape 3 marquait aussi → doublon résolu).
2. Proposer un message de commit conventionnel à partir du diff git réel.
3. Demander confirmation avant `git commit`. Pas de `git push` automatique.
4. Suggérer la prochaine étape :
   - Si ce n'est **pas la dernière phase** → `/plan Phase {N+1}`
   - Si c'est la **dernière phase** ET projet **jamais shipped** (pas d'`<!-- ship:url -->` rempli dans CLAUDE.md) → `/livrer`
   - Sinon → pause projet (et `/prime` pour reprendre plus tard)

C'est court. C'est un rituel, pas un skill de production.

## Règle stricte

**Pas de commit sans validation utilisateur explicite**. Tu écris le message, tu l'affiches, l'utilisateur dit "oui" → tu commits. Pas avant.

## Comment procéder

### Étape 0 — Détection du scope (no-op / planning / full)

Avant toute autre action, `/close` détecte automatiquement son mode d'exécution.

**0.1 — Lire la trace `tmp/skill-trace.jsonl`** (si présente). Chaque skill du kit append une ligne JSON à sa fin :
`{"skill":"plan","artifact":"docs/plans/foo.md","next":"/execute foo","ts":"<ISO8601>"}`

- Si > 10 lignes accumulées → alerter : *"Trop de skills depuis le dernier /close (N lignes) — tu as peut-être oublié de clôturer une étape précédente."* Poursuit avec les **10 dernières lignes**.
- Si fichier absent ou vide → trace vide (cas projet neuf ou /close juste précédent).

**0.2 — Calculer le diff git** (union pour catch staged + untracked + modified + récent) :
- `git status --porcelain` (staged, modifié, untracked)
- `git diff --name-only HEAD~1..HEAD` (commits récents)
- **Fallback** si `git rev-parse --verify HEAD` échoue (projet sans aucun commit) → traiter comme mode **full** (premier commit). Le no-op n'est pas possible avant le premier commit.
- **Fallback** si `HEAD~1` inexistant (1 seul commit) → utiliser `git diff --cached --name-only`.

**0.3 — Définir les chemins de planning** (toutes les modifs qui matchent ces patterns = planning-only) :
```
plans/, docs/plans/, docs/brainstorms/, research/,
PRD.md, STATUS.md, memory/daily/
```

**0.4 — Décider du mode** :
- Trace vide **ET** diff vide → mode **no-op** → affiche : *"Rien à clôturer. Aucun fichier modifié et aucun skill récent. Tu peux `/clear` directement."* → **fin du skill** (skip toutes les étapes suivantes).
- Tous les fichiers du diff matchent `planning_paths` → mode **planning** (rapide).
- Sinon → mode **full** (fin de phase).

**0.5 — Annoncer** : *"Mode détecté : **{mode}**. {explication 1-ligne}"*.

### Étape 0.5 — Update STATUS.md (modes planning ET full)

Cette étape tourne en mode **planning** et **full** (skippée en no-op).

**0.5.1 — Créer STATUS.md si absent** (projet pré-v2.2 migré manuellement) : écrire le template canonique (voir A1 du plan v2.1) avec `{Nom du projet}` laissé tel quel — `/start` le résoudra à la prochaine session si pas déjà fait.

**0.5.2 — Lire trace.jsonl** : la dernière ligne = dernier skill exécuté avant /close. C'est la base de "Dernière étape" et "Prochaine étape recommandée".

**0.5.3 — Lire STATUS.md actuel** pour récupérer l'historique récent (5 dernières lignes max).

**0.5.4 — Réécrire la zone entre `<!-- close:active -->` et `<!-- /close:active -->`** avec :
- `**Dernière étape**` = dernier skill du trace + son artifact + date du jour
- `**Prochaine étape recommandée**` = `next` du dernier trace, ou suggestion contextuelle
- `**Dernier commit reflété**` = `git rev-parse --short HEAD` (sera ensuite mis à jour post-commit avec le nouveau SHA — voir 0.5.6)
- `## Historique récent` = jusqu'à 5 lignes, la plus récente en haut (drop la plus ancienne si > 5)

Pattern d'écriture : **read fresh + atomic** (écrire tmp puis `mv`).

**0.5.5 — Ordre absolu** :

**Mode planning** (gain ~30-60s) — pas d'amend SHA :
1. **Update STATUS.md** sans le champ `Dernier commit reflété` (ou laisser la valeur précédente — sera rafraîchie lazily au prochain `/close` full ou `/prime`)
2. `git add -A`
3. `git commit -m "{message}"`

**Mode full** — séquence complète avec amend SHA :
1. **Update STATUS.md** (zone active, sans le SHA post-commit encore)
2. `git add -A` (inclut STATUS.md modifié)
3. `git commit -m "{message}"`
4. **Refresh STATUS.md** : ré-écrire le champ `Dernier commit reflété` avec `git rev-parse --short HEAD` (le nouveau SHA), puis `git commit --amend --no-edit` (ou commit séparé `chore: refresh STATUS sha` si amend bloqué par l'utilisateur).

Cet ordre garantit que le commit inclut STATUS.md à jour. Si l'écriture STATUS.md échoue (disque plein, permissions) → **NE PAS commit**. Re-run /close est idempotent.

**0.5.6 — Supprimer `tmp/skill-trace.jsonl`** (consommation). À faire **après** la réussite de l'écriture STATUS.md. Si l'écriture a échoué, NE PAS supprimer (recover possible).

### Étape 0.6 — Audit caps (CLAUDE.md, PRD.md)

**Skip silencieux en mode planning** (les artefacts planning — brief, SPEC, plan — ne touchent jamais les limites de CLAUDE.md/PRD.md aux endroits scrutés ici). Cette étape ne tourne qu'en mode **full**.

Entre Étape 0.5 (STATUS.md) et Étape 1 (détection phase). **Ne bloque jamais le commit — juste warn + propose**.

**0.6.1 — Audit CLAUDE.md** :
```
N=$(wc -l < CLAUDE.md)
```
- Si `N > 200` : warn *"⚠️ CLAUDE.md = {N} lignes (cap recommandé : 200). Sections candidates au déport (top H2 par longueur via awk) : {liste}. Tu veux qu'on les déporte vers `.claude/rules/{topic}.md` path-scoped ? (oui/skip)"*

**0.6.2 — Audit PRD.md** (si PRD existe) :
```
N=$(wc -l < PRD.md)
```
- Si `N > 100` : warn *"⚠️ PRD.md = {N} lignes (cap recommandé : 100, doit rester court et vivant). Tu veux qu'on identifie ce qui peut sortir vers `docs/specs/` ? (oui/skip)"*

**0.6.3 — Acknowledged flag** (anti-spam re-prompt) :

Stocker l'ack dans `.claude/cache/close-cap-acknowledged.json` :
```json
{
  "CLAUDE.md": {"acked_at_lines": 245, "ts": "2026-05-14T10:00:00Z"},
  "PRD.md":    {"acked_at_lines": 108, "ts": "2026-05-14T10:00:00Z"}
}
```

Re-prompt seulement si lignes courantes **≥ acked_at_lines + 50**. Sinon skip (l'utilisateur a déjà acknowledgé à un seuil proche). Idempotent.

### Étape 1 — détecter la phase clôturée

> **Note mode planning** : en mode planning, on **skip** Étapes 1, 2, 3 (pas de phase à marquer dans le PRD — la planning artifact est elle-même l'output). On garde Étapes 4-5 (commit). On **skip** Étapes 6.2-6.3 (3 questions harvest — déjà couvertes par les mining markers planning). On écrit un marker `[plan-mining-done:{artifact-slug}]` dans `memory/daily/{today}.md` (créé si absent — convention alignée avec workspace). Étape 7 = annonce + bloc handoff.
>
> **Note mode full** : enchaînement actuel intact (Étapes 1-7), avec en plus les Étapes 0 + 0.5 ajoutées en amont.

Lis `PRD.md`. Cherche la dernière phase qui n'est PAS encore marquée ✅ Terminée. Confirme à l'utilisateur :

> "Je vais clôturer **Phase {N} — {nom}**. C'est ça, ou tu veux clôturer une autre phase ?"

Si l'utilisateur dit "phase Y" → utilise celle-là. Sinon continue.

### Étape 2 — vérifier que /validate a tourné

Lis le plan de la phase. Cherche d'abord dans `docs/plans/phase-{N}-plan.md` (convention v2.1.0+), puis fallback `plans/phase-{N}.md`, puis `phase-{N}-plan.md` à la racine (projets pré-v2.1.0). Le commit message guidé (Étape 4) référence le path complet `docs/plans/phase-{N}-plan.md` quand le plan est à cet emplacement.

Cherche un bloc `## Validation Phase {N}` avec verdict `✅ OK`. Si absent ou si verdict `❌ KO` / `⚠️ Partiel` non résolu :

> "La Phase {N} n'a pas de verdict `✅ OK` dans son plan. Tu veux lancer `/validate` d'abord, ou tu confirmes que la phase est vraiment finie ?"

Si l'utilisateur confirme malgré tout, continue. Si pas de réponse, stoppe.

### Étape 3 — marquer la phase ✅ Terminée dans le PRD (adaptateur format)

Détecte le format via les 4 branches (identiques à /evoluer + /prime) :

```
has_new = grep -q "^## 7. Implementation Phases" PRD.md
has_old = grep -q "^## Phases" PRD.md
```

**Branche 1 — Nouveau format v2.2** (`## 7. Implementation Phases` présent) :
- Dans `## 3. Scope actuel (V_n)` (sous-sections `### Core` ou `### Technique`) : cocher la checkbox correspondant à la feature livrée (`- [ ] {feature}` → `- [x] {feature}`).
- Dans `## 7. Implementation Phases` : remplacer `**V_n (en cours)** — {nom}` par `**V_n (livré le {YYYY-MM-DD})** — {nom}`.

**Branche 2 — Ancien format v2.1.x legacy** (`## Phases` présent) :
- Section `## Phases`, remplacer `- **Phase {N}** — {nom} : {description}` par `- **Phase {N}** — {nom} : {description} ✅ Terminée le {YYYY-MM-DD}` (comportement legacy intact).

**Branche 3 — État mixte** : warn "PRD en état mixte. Migration recommandée via `docs/MIGRATION-v2.1-to-v2.2.md`." Marquer dans le nouveau format en priorité.

**Branche 4 — PRD malformé** : warn et skip Étape 3 (commit Étape 5 quand même OK).

### Étape 4 — composer le message de commit

**Mode planning — auto-commit sans dialogue** (gain ~1-3 min) :

Le message est dérivé déterministe-ment du dernier skill du trace.jsonl + l'artefact produit :

| Dernier skill | Template message |
|---------------|------------------|
| `brainstorm` (greenfield) | `chore(plan): brief brainstorm {sujet}` |
| `brainstorm` (feature mode) | `chore(plan): brief feature {slug} pour évaluation` |
| `architect` | `chore(plan): PRD initial + stack définie` |
| `evoluer` | `chore(plan): SPEC {slug} + V_{n+1} PRD checkbox` |
| `plan` | `chore(plan): {artifact-basename} découpé en tâches` |
| `challenge` | `chore(plan): challenge {target} — verdict {GO/NO-GO}` |

Affiche le message dans le handoff (Étape 7) — pas de prompt de validation. Si l'user veut amender, il le fait au prochain `/close` ou via `git commit --amend` manuellement. Mode planning = confiance par défaut.

**Mode full — dialogue de validation maintenu** :

Lance `git status` et `git diff --stat` pour voir ce qui a changé. Propose un message conventionnel :

```
{type}({scope}): {what} — {why en 1 phrase}
```

- **type** : `feat` (nouveau), `fix` (bug), `chore` (admin/config), `refactor`, `docs`, `test`
- **scope** : nom de la feature ou du module (ex: `auth`, `dashboard`, `n8n`)
- **what** : ce qui a changé (impératif, ex: "ajoute upload de transcripts")
- **why** : la raison (en 1 phrase, lisible par toi-même dans 3 mois)

Exemple :
```
feat(hub-documents): Phase 1 — UI shell + Supabase auth — base technique pour les phases 2-5
```

Affiche le message dans le chat :

> "Voilà le commit que je propose :
>
> ```
> {type}({scope}): Phase {N} — {what} — {why}
> ```
>
> Tu valides, ou tu veux ajuster ?"

Itère jusqu'à validation.

### Étape 5 — commit (après validation explicite)

Lance :
```bash
git add -A
git commit -m "{message validé}"
```

Annonce le SHA résultant. **Ne push pas automatiquement** — c'est à l'utilisateur de décider quand pousser (et où).

### Étape 6 — Harvest learnings (mémoire persistante, conditionnel)

Post-commit, **l'utilisateur ne touche pas à la mémoire manuellement** — c'est ce skill qui la maintient. Mais le harvest est **conditionnel** depuis v2.0.2 : on ne pose des questions à l'user que si la session contient des **signaux de notabilité** détectables sur le diff git. Sinon, on fait juste l'auto-récap silencieux et on passe.

> **Boucle externe (vocabulaire kit v2.1.0)** : tu fais la **boucle externe** ici. La **boucle interne** (PIV : `/prime → /plan → /execute → /validate → /close`) résout la feature courante ; la **boucle externe** cristallise ce que la session t'a appris en mémoire persistante (`memory/topics/`, `memory/decisions.md`, `MEMORY.md`) pour que les futures sessions ne refassent pas les mêmes erreurs.

**6.0 — Détection des triggers (décide si on engage l'user)**

Sur le diff git de la phase (`git diff {commit-ouverture-phase}..HEAD`), exécuter en parallèle ces 6 checks :

| Trigger | Détection | Question pertinente à poser |
|---------|-----------|------------------------------|
| **T1 — nouvelle dépendance** | `git diff` touche `package.json` ligne `+ "..."` dans `dependencies`/`devDependencies` | "Un gotcha pendant l'install ou le choix de cette dépendance ?" |
| **T2 — nouveau MCP** | `git diff` touche `.mcp.json` ou `.mcp.json.example` avec ajout de bloc `mcpServers` | "Un piège lors de la config de ce MCP (auth, URL, mode docs-only) ?" |
| **T3 — migration SQL / RLS** | Fichiers `supabase/migrations/*.sql` ajoutés OU diff contient `CREATE POLICY`, `ALTER TABLE`, `ENABLE ROW LEVEL SECURITY` | "Une décision RLS ou un schéma de données à mémoriser ?" |
| **T4 — workaround / hack** | `git diff` contient `HACK`, `FIXME`, `XXX`, `workaround`, `temporary fix` (case-insensitive) dans les fichiers code (pas dans la doc) | "Un contournement à documenter pour ne pas l'oublier ?" |
| **T5 — nouvelle règle path-scoped** | Nouveau fichier `.claude/rules/*.md` créé | "Un pattern réutilisable à formaliser ? (sinon je n'écris pas)" |
| **T6 — choix arch significatif** | Diff `memory/decisions.md` (ADR ajouté par `/evoluer`) OU le commit message contient `feat(...)` + le ` — ` (rationale séparator) avec une raison non triviale | "Une décision d'arch à raconter en 2 lignes pour mémoire ?" |

**Logique** :
- **Aucun trigger** → skip 6.2 et 6.3 totalement. Annonce : *"Mémoire : auto-récap seul écrit (rien de notable détecté dans le diff)."*
- **1 trigger** → poser **uniquement** la question associée (1 question, pas 3).
- **2+ triggers** → poser les questions associées dans l'ordre T1→T6, max 3 questions au total.

**Règle d'or** : si la question retourne "rien à signaler" / "skip" → ne pas insister, passer à la suivante ou clôturer 6.

**6.1 — Auto-récap session (toujours écrit, low-friction)**

Crée ou complète `memory/learnings/{YYYY-MM-DD}.md` avec un récap automatique de la phase clôturée :

```markdown
## Phase {N} — {nom} (clôturée à {HH:MM})

### Commits
- {SHA court} {message} *(le commit de cette /close)*
- {SHAs précédents de la phase, depuis le /close de Phase N-1)}

### Fichiers modifiés (top 10)
- {liste git diff --stat depuis le dernier /close}

### Durée approximative
{calcul : entre le premier commit de la phase et celui-ci} → environ {X}h
```

Pas de question, écriture directe. Si le fichier `memory/learnings/{date}.md` existe déjà (plusieurs phases clôturées le même jour), append en bas.

**6.2 — Topics opt-in (questions ciblées par triggers détectés)**

Skippé totalement si l'Étape 6.0 n'a détecté aucun trigger. Sinon, pour chaque trigger détecté (max 3), pose la question associée du tableau 6.0. **Une seule question par trigger**, jamais l'arsenal complet à froid.

Selon la réponse :

- **Trigger T6 (décision arch)** ou réponse type "décision" → écris dans `memory/decisions.md` ancre `<!-- close:decisions -->` :
  ```
  - **{YYYY-MM-DD}** — {décision} (Phase {N}). Rationale : {réponse utilisateur}
  ```

- **Trigger T1/T2/T3/T4 (gotcha, install, RLS, workaround)** → demande le **domaine** en 1 mot (ex : "n8n", "supabase", "deploy") et écris dans `memory/topics/{domaine}.md` (crée si absent) :
  ```markdown
  ## {YYYY-MM-DD} — {résumé 1-ligne}
  {réponse utilisateur, 2-5 lignes}
  ```

- **Trigger T5 (pattern réutilisable)** → écris dans `memory/topics/{domaine}.md` (même format que T1-T4).

Si l'user dit "rien à signaler" / "skip" sur une question, passe à la suivante. Si tous les triggers passent en "skip" → 6.2 produit 0 écriture (c'est OK, l'auto-récap 6.1 suffit).

**6.3 — Update MEMORY.md index**

Après écriture(s) en 6.2, met à jour `MEMORY.md` à la racine :

- Ancre `<!-- close:topics-index -->` : ajoute un lien `- [domaine](memory/topics/{domaine}.md) — {résumé 1-ligne}` si nouveau topic, sinon laisse (le détail est dans le fichier topic).
- Ancre `<!-- close:learnings-index -->` : ajoute `- [{date}](memory/learnings/{date}.md) — Phase {N} clôturée ({X}h, {N commits})`.

**Règle d'or** : si l'utilisateur répond "rien" à toutes les questions, tu ne demandes pas de troisième confirmation. Tu skipes 6.2/6.3 et passes à 6.4. Pas de friction.

**6.4 — Annonce courte** : *"Mémoire mise à jour : {N learnings + {M topics si applicable}}. MEMORY.md indexé."*. Pas de dump du contenu écrit.

### Étape 6.4 — SPEC frozen header (post-/evoluer + /execute)

Si `/evoluer` a été le dernier skill significatif avant cette session (présence d'un `docs/specs/SPEC-*.md` créé ou modifié dans le diff git de cette /close), ajouter en tête du SPEC un header informatif :

```
<!-- frozen: {YYYY-MM-DD} -->
```

Idempotent : si le header existe déjà, skip. Signal informatif uniquement (pas d'enforcement runtime — sert pour /prime + revue manuelle).

### Étape 6.5 — Gate déploiement (conditionnelle, Vercel uniquement)

**Insérée entre l'Étape 6 (harvest) et l'Étape 7 (suggestion)**. Cette étape propose un push contextuel quand le projet est lié à Vercel et qu'il reste des commits non-pushés. Sinon elle se skip silencieusement (zero friction).

**6.5.1 — Conditions de déclenchement** (TOUTES doivent être vraies, sinon skip direct vers Étape 7) :

```bash
# C1 — Vercel lié au projet ?
COND_VERCEL=0 ; test -f .vercel/project.json && COND_VERCEL=1

# C2 — commits non-pushés OU changements non-commités sur main ?
COND_UNPUSHED=0
if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 ; then
  AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  [ "$AHEAD" -gt 0 ] && COND_UNPUSHED=1
fi
# OU il n'y a pas encore d'upstream (cas premier deploy avec branche locale)
git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1 || COND_UNPUSHED=1

# C3 — project_type ∈ {webapp, site} ?
PT=$(grep -oE 'project_type:\s*(webapp|site|automation)' CLAUDE.md 2>/dev/null | sed -E 's/.*:\s*//')
COND_TYPE=0
case "$PT" in webapp|site) COND_TYPE=1 ;; esac
# Fallback : si project_type non détectable (regex échoue, ancre absente) → skip 6.5 silencieusement, pas d'erreur
[ -z "$PT" ] && { echo "Étape 6.5 skipped (project_type non détectable)" ; SKIP_65=1 ; }
```

Si `COND_VERCEL == 1 && COND_UNPUSHED == 1 && COND_TYPE == 1 && SKIP_65 != 1` → continue 6.5.2. Sinon → skip silencieux vers Étape 7.

**6.5.2 — AskUserQuestion : 3 options**

> "Le projet est lié à Vercel et tu as des commits non-pushés. Tu veux quoi maintenant ?"
>
> Options :
> 1. **Commit only** — comportement actuel /close, pas de push (push différé à plus tard)
> 2. **Push main = deploy prod auto** — `git push origin main` puis affichage URL prod (lue depuis `<!-- ship:url -->`) + délai 90s annoncé pour le build Vercel
> 3. **Push sur branche feature = preview Vercel** — propose un nom de branche slugifié (ex : `feat/{topic-court}`), crée la branche, push, affiche l'URL preview attendue (pattern générique `https://{slug}-git-{branche}-{team}.vercel.app`)

**6.5.3 — Exécution selon l'option choisie**

- **Option 1 (commit only)** : ne rien faire de plus, passe à 6.5.4.
- **Option 2 (push main)** :
  ```bash
  git push origin main
  ```
  Affiche : *"Push effectué sur main. Vercel build en cours, ~1-2 min. URL prod : {URL_PROD lue depuis ship:url}. Le smoke test n'est pas relancé ici — c'est `/livrer` qui s'en charge si tu veux vérifier."*
- **Option 3 (push branche feature)** :
  ```bash
  BRANCH_NAME="feat/{slug-suggéré}"
  git checkout -b "$BRANCH_NAME"
  git push -u origin "$BRANCH_NAME"
  ```
  Affiche : *"Branche `{BRANCH_NAME}` créée et pushée. Vercel crée un déploiement preview. URL attendue (pattern générique) : `https://{slug}-git-{branche-slugifiée}-{team}.vercel.app` — visible dans le PR si tu en ouvres un, ou dans le dashboard Vercel onglet Deployments."*

**6.5.4 — Trace enrichie**

Append à `tmp/skill-trace.jsonl` (en plus de la trace standard de close) :
```json
{"skill":"close","deploy_action":"commit_only|push_main|push_feature","ts":"<ISO8601>"}
```

Si 6.5 a été skip (conditions non remplies ou fallback `project_type` indétectable) → `deploy_action: null`.

### Étape 7 — suggestion suivante

Lis `PRD.md ## Phases`. Identifie la phase suivante (première sans ✅ Terminée).

- **Si une phase suivante existe** :
  > "Phase {N} clôturée. Tu veux enchaîner sur **Phase {N+1} — {nom}** maintenant avec `/plan Phase {N+1}`, ou tu fais une pause ?"

- **Si toutes les phases sont ✅ Terminées** (Phase {N} était la dernière), vérifie si le projet a déjà été shipped : grep `<!-- ship:url -->` dans `CLAUDE.md`, regarde si le bloc contient une URL (pas juste le placeholder).
  - **Pas encore shipped** :
    > "Phase {N} clôturée. Toutes les phases du PRD sont ✅ Terminées et le projet n'a jamais été déployé. Tu veux lancer **`/livrer`** pour passer en production ?"
  - **Déjà shipped** :
    > "Phase {N} clôturée. Toutes les phases du PRD sont ✅ Terminées et le projet est déjà en production. Quand tu veux ajouter une feature → `/evoluer` (v2.0 GA). Sinon, projet bouclé. 🎉"

## Risque #1 — commit silencieux

Si tu lances `git commit` sans avoir affiché le message et obtenu un "oui", tu peux écrire n'importe quoi dans l'historique du projet — et l'historique est public dès le push. **Test du miroir** : tu dois pouvoir citer le message que l'utilisateur a explicitement validé. Si tu ne te souviens pas l'avoir affiché, tu n'as pas le droit de commit.

## Risque #2 — clôturer une phase pas finie

Si `/validate` n'a pas dit `✅ OK`, la phase n'est pas finie. Marquer ✅ Terminée à ce stade pollue le PRD et casse le repère "où on en est". **Test du miroir** : tu dois pouvoir pointer le bloc `## Validation Phase {N}` avec verdict OK avant d'écrire `✅ Terminée le ...`.

## Quand ne PAS utiliser ce skill

- Au milieu d'une phase (tâches encore `[ ]` non cochées) → `/execute` d'abord
- Sans `/validate` préalable (sauf si l'utilisateur force) → `/validate` d'abord
- Pour pousser vers GitHub → c'est `git push`, pas un skill (et c'est à l'utilisateur de décider)
- Pour archiver le projet → c'est manuel (move vers `archive/`, mise à jour README)

## Trace de fin

`/close` est le **consommateur** de `tmp/skill-trace.jsonl` — il lit puis supprime le fichier (voir Étape 0.5.6). Il n'append pas de ligne lui-même : `/close` est le dernier maillon de la chaîne avant `/clear`.

## Handoff

Trois variantes selon le mode détecté en Étape 0 :

**Mode no-op** :
> "Rien à clôturer. Tu peux `/clear` directement, ou continuer si tu veux."

**Mode planning** :
> "Commit fait ({SHA}), STATUS.md à jour. Marker `[plan-mining-done:{artifact-slug}]` écrit dans `memory/daily/{today}.md`.
>
> Étapes suivantes pour repartir propre :
>   1. /clear
>   2. /{next-skill du trace}"

**Mode full (fin de phase)** :
> "Phase {N} ✅, commit {SHA} fait, STATUS.md à jour.
>
> Étapes suivantes pour repartir propre :
>   1. /clear
>   2. /{next-skill}"
>
> Suggestion `next-skill` selon l'état du PRD :
> - Phase suivante existe → `/plan Phase {N+1}`
> - Dernière phase + pas shipped → `/livrer`
> - Dernière phase + déjà shipped → fin de cycle (proposer `/evoluer` pour future feature)

**Prochaine étape** : `/clear` puis `/{next-skill}` (voir variante du mode ci-dessus).
