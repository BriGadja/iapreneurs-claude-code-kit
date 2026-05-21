---
name: plan
description: Utiliser pour découper UNE phase d'un PRD en tâches numérotées avec critères "Fait quand" vérifiables. Ne PAS utiliser si pas de PRD — créer le PRD d'abord avec /architect. Ne PAS planifier plusieurs phases d'un coup — une phase à la fois pour éviter le scope creep.
---

# Skill /plan — découper une phase en tâches

## Pour quoi faire

Prendre **UNE phase** d'un PRD et la découper en tâches numérotées avec des critères "Fait quand" vérifiables. Une tâche = un truc concret à faire (créer un fichier, écrire une fonction, configurer un service). Le fichier produit s'écrit dans **`docs/plans/phase-{N}-plan.md`** (convention v2.1.0+ — crée le dossier avec `mkdir -p docs/plans` si absent) et il sert de check-list pendant `/execute`.

> **Compat v2.0.x** : les plans existants à la racine ou dans `plans/` continuent d'être lus par `/execute`, `/validate`, `/challenge`, `/prime`, `/close`, `/start` via fallback. La migration manuelle vers `docs/plans/` n'est pas bloquante.

## Règles strictes

1. **Une phase à la fois** — jamais Phase 1 + Phase 2 dans le même fichier. Tu finis Phase 1, tu valides, puis tu fais `/plan` Phase 2.
2. **8 tâches max par phase** — au-delà, c'est que la phase est trop grosse. Re-découper.
3. **Chaque tâche a un critère "Fait quand"** vérifiable (objectif, pas subjectif). Pas "Fait quand ça marche". Plutôt "Fait quand le fichier `auth.ts` exporte la fonction `login(email, password)` et que `npm test auth.test.ts` passe."

## Comment procéder

### Étape 1 — lire le PRD (+ project_type + DESIGN.md si UI) + identifier la phase

L'utilisateur passe en argument soit `PRD.md`, soit le numéro de phase ("phase 1"), soit les deux, soit **un brief de brainstorm** (`docs/brainstorms/{date}-{slug}.md`).

**1.0 — Si l'argument est un brief de brainstorm** : lis-le en entier avant tout. Le brief contient l'idée clarifiée, le besoin, les contraintes, la direction recommandée et les hypothèses à valider — utilise-le comme contexte pour pré-remplir les questions de l'Étape 2 (tu proposes les réponses extraites, l'utilisateur confirme ou amende). Le brief sert à cadrer la phase à planifier (souvent la prochaine phase du PRD existant, ou une tâche transverse).

**1.1 — Lire `project_type` depuis `CLAUDE.md ## Identité`** (variable `project_type:` ∈ `{webapp, site, automation}`). Cette valeur **adapte les questions de l'Étape 2** (skip les questions web-app-centriques si `automation`, ajoute des questions credentials externes n8n, etc.). Si absent → suggère `/start` migration v1.x.

**1.2 — Lire le PRD**. **Si la phase touche à l'UI web** (composants, pages, layout) ET qu'un fichier `DESIGN.md` existe à la racine → le lire aussi. Tes tâches devront référencer la palette/typo/composants définis dedans. Si la phase touche à l'UI mais qu'il n'y a pas de `DESIGN.md` → suggère à l'utilisateur de lancer `/design` d'abord (anti-incohérence visuelle).

**1.3 — Identifier la phase à planifier**. Reformuler à l'utilisateur :

> "OK, je vais planifier **Phase {N} — {nom}** : {description PRD}. C'est ça ?"
> *(Si DESIGN.md lu)* "Je vais respecter le design system de `DESIGN.md` dans les tâches UI."
> *(Si `project_type` détecté)* "Project type : `{valeur}`. Je vais adapter mes questions et tâches en conséquence."

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

### Étape 2 — poser 3-5 questions ciblées (adaptées au `project_type`)

Selon la phase ET le `project_type`, poser **3 à 5 questions** précises qui te manquent pour découper. **Tu ne pré-supposes JAMAIS l'architecture** : tu déduis des réponses si SDK direct, n8n, ou autre est approprié.

**Axes de questions adaptés par `project_type`** :

**Si `project_type = webapp`** (priorise) :
1. **Type d'output utilisateur** → "Le résultat de cette phase, l'utilisateur le voit où ? Page web qui se met à jour, mail reçu, fichier téléchargé, notification ?"
2. **Latence acceptable** → "L'output doit-il s'afficher en temps réel pendant que l'utilisateur attend (streaming token par token), ou peut-il arriver quelques secondes plus tard ?"
3. **Sensibilité des données** → "Tu manipules des données clients réelles (transcripts, contacts, paiements) ou des données éphémères (sondage live, kanban d'atelier) ? Cela détermine si policy d'accès BDD est obligatoire ou skippable."
4. **Frontend ou backend d'abord ?** → "Tu préfères qu'on attaque le squelette UI ou la logique métier en premier ?"
5. **Test** → "Pour cette phase, tu veux des tests automatisés ou on valide à la main avec `/validate` ?"

**Si `project_type = site`** (priorise) :
1. **Pages concernées** → "Quelles pages cette phase concerne ? Accueil, contact, à propos, autre ?"
2. **Formulaires / interactions** → "La phase ajoute-t-elle un formulaire ou une interaction côté utilisateur (newsletter, contact, devis) ? Si oui, où va la donnée (Resend, Google Sheets, autre) ?"
3. **SEO / performance** → "Cette phase a-t-elle des contraintes SEO ou perf (Lighthouse ≥ 90) ?"
4. **Test** → "Validation manuelle ou tests automatisés (Playwright pour les pages clés) ?"

**Si `project_type = automation`** (priorise, **retire** les questions web-app-centriques) :
1. **Trigger** → "Comment le workflow est-il déclenché ? Webhook entrant, cron, event d'une autre app (Make/Zapier/intégration n8n native) ?"
2. **Credentials externes** → "Quels services externes le workflow appelle ? (API, BDD, email, IA, etc.). Quelles credentials manquent dans la config n8n actuelle ?"
3. **Output / effet** → "Que produit le workflow ? Insertion BDD, envoi message, génération fichier, callback HTTP ?"
4. **Idempotence** → "Le workflow doit-il être idempotent (rejouable sans doublon) ? Si oui, quelle clé d'unicité ?"
5. **Test** → "Validation via `n8n_test_workflow` MCP, curl direct sur webhook, ou exécution manuelle dans l'UI n8n ?"

**Règle d'inférence architecturale** (webapp principalement) : à partir des réponses Q1+Q2+Q3, infère l'architecture **sans la cacher** :
- Output live + streaming → Anthropic SDK (ou autre LLM SDK) dans une API route, `runtime='nodejs'`, ReadableStream côté front
- Output async (PDF, email, BDD) → workflow n8n + webhook + callback BDD Realtime
- Données sensibles → policy d'accès BDD (RLS si Supabase/Neon) MANDATORY, audit après chaque migration
- Données éphémères → policy skippable, mais à justifier explicitement

Présente ton inférence à l'utilisateur AVANT de découper : "Vu tes réponses, je propose **{architecture}**. Ça te va, ou tu veux changer ?"

**Ne pas dépasser 5 questions**. Si t'as plus, la phase est mal découpée dans le PRD — propose de revenir à `/architect`.

### Étape 3 — découper en 3-8 tâches

Chaque tâche doit être :
- **Concrète** (créer fichier X, configurer service Y)
- **Indépendante** ou avec dépendance explicite ("après tâche 2")
- **Vérifiable** par un critère mesurable

### Étape 4.5 — User stories Given/When/Then (option, STANDARD+ uniquement)

Si la phase est classée `Request Classification ≥ STANDARD` ET `project_type == webapp` (parcours utilisateur central), proposer :

> *"Tu veux des user stories Given/When/Then en plus des tâches techniques ? Recommandé pour les features avec parcours utilisateur clair (login, checkout, dashboard). (oui/skip)"*

Si **oui** : générer 1-3 user stories au format Given/When/Then standard (en complément des tâches) :

```
## US-N {title}
**As a** {user persona}
**I want to** {action}
**So that** {benefit}

### Acceptance Criteria
- [ ] Given {context}, when {action}, then {result}
- [ ] Given {edge case}, when {action}, then {result}
```

Les stories sont insérées dans le plan avant les tâches techniques (section `## User Stories`). Les acceptance criteria deviennent des checkboxes /execute parallèles aux tâches techniques.

Si **LITE** : skip silencieusement (pas de question, juste tâches techniques).

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

`/execute docs/plans/phase-{N}-plan.md`
```

> **Écriture** : ce skill fait `mkdir -p docs/plans` puis écrit dans `docs/plans/phase-{N}-plan.md`. Si un fichier `phase-{N}-plan.md` existe déjà à la racine ou dans `plans/` (projet pré-v2.1.0), ne pas l'écraser — alerter l'utilisateur et proposer soit la migration (déplacer dans `docs/plans/`), soit garder l'ancien emplacement et écrire ailleurs.

## Exemple de tâche bien formulée

❌ Mauvais : "Faire l'authentification"
✅ Bon : "Créer `src/lib/auth.ts` qui exporte `signIn(email, password)` et `signOut()`. Fait quand : `npm run lint` passe + `signIn` retourne `{ user, session }` valide quand testé manuellement avec un compte de test."

## Risque #1 — tâches floues

Si tu écris "faire la BDD" ou "configurer le backend", c'est trop vague. À `/execute`, l'agent va patiner. **Test du miroir** : si tu ne peux pas vérifier la tâche en 30 secondes via une commande ou un fichier, c'est trop vague. Re-découper.

## Quand ne PAS utiliser ce skill

- Pas de PRD → `/architect` d'abord
- Tâche très petite (1 fichier, 5 minutes) → fais-le directement, pas la peine de planifier
- Plusieurs phases d'un coup → une phase à la fois, c'est non-négociable

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "plan", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Affiche à l'utilisateur :

```
✅ Plan créé : docs/plans/phase-{N}-plan.md

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /execute {chemin-plan}
```

**Prochaine étape** : `/close → /clear → /execute {chemin-plan}` — voir le rituel dans `docs/KIT.md § STATUS.md & rituel`.
