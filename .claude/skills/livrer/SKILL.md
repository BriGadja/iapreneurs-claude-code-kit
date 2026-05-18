---
name: livrer
description: Utiliser pour déployer le projet en production une fois la dernière phase /close. Lit la section ## Stack du CLAUDE.md (jamais hardcode de provider) pour s'adapter aux choix faits dans /architect — hosting (Vercel/Netlify/Cloudflare/GitHub Pages/autre), BDD (Supabase/Neon/autre), email (Resend/Postmark/autre). Inclut une checklist d'accès BDD advisory (jamais auto-exécutée), un smoke test post-deploy et l'écriture de l'URL prod dans CLAUDE.md. Ne PAS utiliser au milieu d'une phase ou si /validate ❌ KO.
---

# Skill /livrer — déployer en production (stack-aware)

## Pour quoi faire

Le parcours du kit ne s'arrête pas au `localhost`. `/livrer` te fait passer **du repo qui marche en local au projet shipped en prod**, adapté à **la stack que tu as choisie dans `/architect`** (et pas une stack imposée).

Le skill ne hardcode JAMAIS Vercel ou Supabase. Il lit la `## Stack` de ton `CLAUDE.md`, détecte ce que tu utilises, et propose les commandes adaptées. Si ta stack est Netlify + Neon, c'est ça qui sort. Si c'est Cloudflare Pages + PlanetScale, pareil.

Pas d'auto-déploiement silencieux : chaque commande affichée, validée explicitement avant exécution.

## Règle stricte

**Pas de deploy sans pré-checks validés**. Si `project_type` ou `## Stack` est absent du CLAUDE.md, ou si l'audit policy d'accès BDD n'a pas été reviewé (cas webapp avec BDD), tu **stoppes** et alerts l'utilisateur. Pas de défaut silencieux.

## Comment procéder

### Étape 1 — Lire `project_type` et `## Stack` (mandatory)

**1.1 — `project_type`** : lis `<!-- start:identité -->` dans `CLAUDE.md`. Cherche `project_type: {valeur}`.

- Si **absent ou invalide** (∉ `{webapp, site, automation}`) → stoppe avec message *"Pas de variable `project_type` dans `CLAUDE.md`. Relance `/start` qui va te poser la question et l'écrire."*

**1.2 — `## Stack`** : lis le bloc `<!-- architect:stack -->` (ou la section `## Stack`). Extrais :
- **Hosting** : Vercel / Netlify / Cloudflare Pages / GitHub Pages / Render / Fly.io / Hostinger / autre
- **BDD** (si webapp) : Supabase / Neon / PlanetScale / Turso / autre
- **Email** (si applicable) : Resend / Postmark / SendGrid / autre
- **Automation runtime** (si automation) : n8n cloud / n8n self-hosted

Si la stack est ambiguë ou incomplète → demande à l'utilisateur les valeurs manquantes + **propose de les écrire dans `## Stack`** pour les prochains `/livrer`.

> *"Détection stack : hosting = {X}, BDD = {Y}. C'est correct ? Si tu utilises autre chose, dis-le et je l'ajoute à `## Stack` du CLAUDE.md."*

### Étape 2 — Checklist pré-deploy (ADVISORY, jamais auto-exécutée)

**Si `project_type = webapp` ET BDD détectée** : affiche la **checklist policy d'accès** — le skill ne peut PAS la vérifier automatiquement (pas d'accès MCP BDD côté kit forké), donc tu PRINTES la checklist et demandes à l'utilisateur de cocher manuellement.

1. Grep dans `src/`, `app/`, `supabase/migrations/`, `db/migrations/`, etc. pour identifier les tables touchées (mots-clés selon BDD : `from('table_name')`, `CREATE TABLE`, `INSERT INTO`).
2. Pour chaque table identifiée, affiche :
   ```
   - [ ] Table `{nom}` : policy d'accès configurée ? (RLS si Supabase/Neon, équivalent ailleurs)
       Lien dashboard : {URL adaptée selon BDD détectée}
   ```
3. Annonce :
   > *"Tables BDD touchées. Avant de livrer, vérifie manuellement que chacune a une policy d'accès adaptée. Dès qu'il y a des données clients (email, téléphone, transcripts, devis, factures, leads, multi-tenant), **policy d'accès dès le premier deploy. Sans exception**.*
   > *Tu confirmes que tu as reviewé chaque table ? (oui / pas encore / pas applicable car pas de données clients)"*
4. Si "pas encore" → stop. Si "oui" ou "pas applicable" → continue.

**Si `project_type = site`** :
- [ ] Pas de clés API en clair dans le code (grep `sk-`, `Bearer `, `eyJ` dans `src/` et `app/`)
- [ ] `.env` est bien gitignored (`git check-ignore .env`)
- [ ] Lighthouse score local ≥ 80 (lancer `npx lighthouse http://localhost:3000 --view`)

**Si `project_type = automation`** :
- [ ] Workflow validé via `n8n_validate_workflow` MCP
- [ ] Credentials configurées dans l'instance (pas en clair dans le JSON exporté)
- [ ] Webhook URL stable (production, pas test)

### Étape 3 — Déploiement adapté à la `## Stack`

**Commandes affichées, exécutées sur confirmation explicite. Confirmation-before-action sur tout ce qui touche prod.**

Selon hosting détecté en 1.2 :

**Hosting = Vercel** — pattern moderne **GitHub → Vercel auto-deploy** (push = deploy). Le CLI `vercel --prod` est conservé en fallback "power users" (voir commentaire HTML en fin de section), mais le flow par défaut passe par GitHub.

**Étape 3.V.0 — Détection 3 marqueurs d'état** (déterministe, pas d'AskUserQuestion ici) :

```bash
# Marqueur 1 — remote GitHub déjà configuré ?
MARK_REMOTE=0 ; git remote get-url origin 2>/dev/null | grep -qE 'github.com[:/]' && MARK_REMOTE=1

# Marqueur 2 — repo distant existe vraiment sur GitHub ?
MARK_REMOTE_EXISTS=0
if [ "$MARK_REMOTE" = "1" ]; then
  ORIGIN=$(git remote get-url origin | sed -E 's#.*github.com[:/]([^/]+/[^/]+)(\.git)?$#\1#')
  gh repo view "$ORIGIN" >/dev/null 2>&1 && MARK_REMOTE_EXISTS=1
fi

# Marqueur 3 — projet déjà lié à Vercel ?
MARK_VERCEL=0 ; test -f .vercel/project.json && MARK_VERCEL=1

# Score
SCORE=$((MARK_REMOTE + MARK_REMOTE_EXISTS + MARK_VERCEL))
```

- Si `SCORE == 3` → route **`route_vercel_push`** (fast path) — passe directement à l'Étape 3.V.2 ci-dessous.
- Sinon → route **`route_vercel_onboarding`** (premier deploy, guidé) — passe à l'Étape 3.V.1.

**Étape 3.V.1 — `route_vercel_onboarding`** (déclenchée si < 3/3 marqueurs)

Pas-à-pas guidé, AskUserQuestion à chaque checkpoint non-automatisable. Ordre strict :

1. **Warning Vercel Hobby (EN PREMIER, avant tout setup)** — affiche :
   > ⚠️ **Vercel Hobby plan = usage personnel non-commercial uniquement.** Si tu vends cet outil comme prestation à un client (€1500+), tu DOIS upgrade vers Vercel Pro (~$20/mo) **avant** de pousser, sinon TOS violation. Alternative sans cette restriction : **Netlify** (gratuit, commercial OK) — relance `/livrer` après avoir changé `## Stack` dans CLAUDE.md si tu préfères.
   >
   > AskUserQuestion : *"Tu continues en Hobby (perso, non-commercial) ?"* — options :
   > - "Oui, Hobby OK (usage perso)"
   > - "Oui, je suis déjà sur Vercel Pro"
   > - "Stop, je vais upgrade avant" → stoppe le skill ici

2. **Check auth GitHub CLI** — utilise `gh api user >/dev/null 2>&1` (plus fiable que `gh auth status` qui a une régression connue sur certaines versions retournant exit 0 même en échec) :
   ```bash
   gh api user >/dev/null 2>&1 || AUTH_KO=1
   ```
   Si KO → affiche les deux chemins d'auth :
   - **Device flow (recommandé débutant)** : `BROWSER= gh auth login --web` (Claude affiche le code device, l'utilisateur l'entre sur github.com/login/device dans son navigateur)
   - **Personal Access Token (si déjà un PAT)** : `export GH_TOKEN=ghp_xxxxx && gh api user` (vérification)

   Attends que l'utilisateur confirme avant de continuer.

3. **AskUserQuestion : compte GitHub existant ?** — options :
   - "Oui, j'ai un compte"
   - "Non, je n'en ai pas" → affiche https://github.com/signup, attends signup, puis relance check auth (étape 2)

4. **Création/lien du repo distant** — vérifie d'abord si le repo existe déjà (cas re-clone ou repo créé via web UI) :
   ```bash
   # Détecte nom du projet depuis le dossier courant
   REPO_NAME=$(basename "$PWD")
   GH_USER=$(gh api user --jq .login)
   if gh repo view "$GH_USER/$REPO_NAME" >/dev/null 2>&1 ; then
     # Le repo distant existe déjà
     git remote get-url origin 2>/dev/null || git remote add origin "git@github.com:$GH_USER/$REPO_NAME.git"
     git push -u origin main
   else
     # Création — défaut public (philosophie communauté), opt-out vers privé
     # AskUserQuestion : "Repo public ou privé ?" (Public recommandé / Privé / Annuler)
     gh repo create "$REPO_NAME" --public --source . --push
     # Si réponse "Privé" → remplacer --public par --private
   fi
   ```

5. **AskUserQuestion : install Vercel GitHub App** — affiche :
   > "Va installer la Vercel GitHub App ici : https://vercel.com/integrations/github
   >
   > Au moment du choix de scope, **choisis 'Only select repositories' et coche uniquement `{REPO_NAME}`** (sécurité — évite que Vercel ait accès à tous tes repos GitHub). Quand c'est fait :"
   >
   > Options :
   > - "C'est installé"
   > - "Explique-moi quoi cliquer" → détaille pas-à-pas
   > - "Skip pour l'instant" → stoppe le skill, demande de relancer après install

6. **Env vars AVANT push (sequencing critique)** — détecte les clés présentes dans `.env.local` (ou `.env` selon convention projet) et affiche une **checklist advisory** :
   > "⚠️ **Ces variables doivent être dans Vercel AVANT le premier push**, sinon ton app build mais crash au runtime (Supabase, OpenAI, etc. sont undefined).
   >
   > Variables détectées dans `.env.local` :
   > {liste des KEY=... avec les valeurs masquées en `***`}
   >
   > Étapes (le CLI `vercel env add` est interactif, donc on passe par le dashboard web) :
   > 1. Ouvre https://vercel.com/dashboard
   > 2. Sélectionne ton projet `{REPO_NAME}` (apparaîtra dès que tu auras `vercel link` à l'étape suivante)
   > 3. Settings → Environment Variables → ajoute chaque clé pour `Production` (et `Preview` si tu utilises les déploiements preview)"
   >
   > AskUserQuestion : *"J'ai ajouté toutes les variables dans Vercel"* — options :
   > - "Oui, toutes ajoutées"
   > - "Pas de variables d'env (site statique sans backend)"
   > - "Je m'en occupe après (build prod va crash mais OK pour test)"

7. **Auth Vercel CLI check** — `vercel link --yes` skip les prompts de config projet, **PAS l'auth**. Vérifie d'abord :
   ```bash
   vercel whoami >/dev/null 2>&1 || VERCEL_AUTH_KO=1
   ```
   Si KO → guidance :
   > "Vercel CLI n'est pas loggué. Deux options :
   > - `vercel login` (Vercel ouvre un browser ou device flow)
   > - `export VERCEL_TOKEN=...` puis re-test (récupère un token sur https://vercel.com/account/tokens)"
   >
   > AskUserQuestion : *"Auth Vercel CLI OK ?"* — options : "Oui" / "Besoin d'aide" / "Skip (je passe par le dashboard uniquement)"

8. **Link projet** :
   ```bash
   vercel link --yes
   ```
   Vérifie que `.vercel/project.json` est créé (contient `orgId` + `projectId`). Si non → stoppe et alerte.

9. **Premier push = premier deploy auto** :
   ```bash
   git push origin main
   ```
   Annonce :
   > "Push effectué. Vercel détecte le commit et déclenche un build automatique. URL prod attendue (composée depuis le nom du projet) : `https://{REPO_NAME}.vercel.app` ou `https://{REPO_NAME}-{org}.vercel.app`. Build typique = 1-2 min (jusqu'à 3 min pour grosse app). J'attends 90s avant de tenter le smoke test (Étape 4)."

**Étape 3.V.2 — `route_vercel_push`** (déclenchée si 3/3 marqueurs, fast path)

```bash
CUR_BRANCH=$(git branch --show-current)
git push origin "$CUR_BRANCH"
```

Affiche selon la branche :
- **Push sur `main`** = **deploy prod auto** :
  > "Push sur main. Deploy prod déclenché. URL prod (lue depuis `<!-- ship:url -->` de CLAUDE.md) : `{URL_PROD}`. Build en cours, ~1-2 min (jusqu'à 3 min si grosse app). J'attends 90s avant smoke test."
- **Push sur une branche feature** = **preview Vercel** :
  > "Push sur `{CUR_BRANCH}`. Vercel va créer un déploiement preview. URL attendue (pattern générique) : `https://{slug}-git-{branche-slugifiee}-{team}.vercel.app` (l'URL exacte apparaît dans le PR GitHub si tu en ouvres un, ou dans le dashboard Vercel onglet Deployments). J'attends 90s avant smoke test."

Le smoke test (Étape 4) fait HTTP GET avec retry à 60s × 2 max si la première tentative renvoie 502/504 (build pas fini).

<!-- power-users-fallback:
Si tu préfères skipper GitHub et pousser directement via CLI (déconseillé pour le flow par défaut — on perd preview deploys + PR integration) :
  vercel --prod
Conservé uniquement pour les utilisateurs avancés qui ont une raison spécifique d'éviter GitHub.
-->



**Hosting = Netlify** :
```bash
netlify init             # si pas déjà fait
netlify env:set {VAR_NAME} {valeur}     # pour chaque variable
netlify deploy --prod
```

**Hosting = Cloudflare Pages** :
```bash
wrangler pages deploy {output_dir}
# Ou : push sur main si Cloudflare Pages connecté à GitHub
```

**Hosting = GitHub Pages** (typique pour site statique Next.js avec `output: 'export'`) :
```bash
npm run build
git push origin main     # workflow .github/workflows/deploy.yml gère le push gh-pages
```

**Hosting = autre (Render / Fly.io / Hostinger / VPS custom)** :
- Demande à l'utilisateur la commande qu'il utilise habituellement.
- Propose de l'écrire dans une section `## Déploiement` du CLAUDE.md pour les prochains `/livrer`.

**Project_type = automation** : pas de hosting traditionnel, c'est l'activation du workflow n8n :
```bash
# Via MCP : n8n_update_partial_workflow avec operation activate
# Ou via n8n UI : toggle "active"
```

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

### Étape 4 — Smoke test post-deploy

Une fois le deploy passé (URL prod reçue) :

**`project_type = webapp` ou `site`** :
1. Récupère l'URL prod (de la sortie deploy).
2. **Si tu sors de `route_vercel_push` ou `route_vercel_onboarding` (sous-routes GitHub→Vercel)** : attends 90s avant la 1ère tentative (build Vercel typique). Si la 1ère requête HTTP renvoie 502/504/404 (build pas encore terminé), retry à 60s × 2 max avant de considérer le deploy en échec.
3. Lance via Playwright MCP : `mcp__playwright__browser_navigate({ url: "https://..." })` + `mcp__playwright__browser_snapshot()`. Si tu prends un screenshot, enregistre-le dans `tmp/smoke-test-{date}.png` (le dossier `tmp/` est gitignored), supprime après vérification.
4. Vérifie : (a) la page charge sans 5xx, (b) contenu principal visible (pas page blanche), (c) pas d'erreur console critique.

**`project_type = automation`** :
1. Récupère l'URL du webhook.
2. Lance `curl -X POST <webhook-url> -d '{"test":"smoke"}' -H "Content-Type: application/json"`.
3. Vérifie : (a) réponse HTTP 200 (ou 202 si async), (b) 1ère exécution dans n8n UI / via MCP `n8n_executions`.

Si le smoke test ÉCHOUE → ne marque pas le projet livré, alerte l'utilisateur, suggère `/debug` (Claude Code natif) avec test de régression.

### Étape 5 — Écrire l'URL prod dans CLAUDE.md

Une fois le smoke test ✅, ouvre `CLAUDE.md` et trouve le bloc :

```
<!-- ship:url -->
{...placeholder...}
<!-- /ship:url -->
```

> **Note ancre** : l'ancre garde le nom `ship:url` (pas `livrer:url`) pour compat avec les forks existants. C'est juste un identifiant interne — le skill reste `/livrer`.

Remplace le contenu entre les ancres par :

```
- **URL production** : {URL récupérée}
- **Hosting** : {nom détecté en 1.2}
- **Type** : {webapp | site | automation}
- **Livré le** : {YYYY-MM-DD}
- **Dernier smoke test** : ✅ {YYYY-MM-DD HH:MM}
```

## Risque #1 — livrer sans audit policy BDD (webapp)

Si tu livres un webapp avec des tables BDD sans policy d'accès, **toutes les données peuvent être publiquement lisibles** par n'importe qui qui connaît la clé publique. Test du miroir : tu dois pouvoir citer pour chaque table touchée la policy associée (ou justifier explicitement pourquoi c'est OK).

## Risque #2 — env vars production manquantes

Si le deploy passe sans les env vars critiques → build OK mais runtime crash. **Test du miroir** : avant deploy, tu listes à l'utilisateur les env vars de `.env` et tu confirmes qu'elles sont configurées chez le hosting.

## Risque #3 — hardcoder Vercel/Supabase par défaut

Le risque principal de ce skill est de revenir à du Vercel/Supabase hardcodé "par habitude". **Test du miroir** : tu dois pouvoir citer la valeur de `## Stack` du CLAUDE.md qui a déterminé la commande proposée. Si tu proposes `vercel --prod` sans avoir lu `## Stack`, tu es hors process.

## Quand ne PAS utiliser ce skill

- Avant `/close` de la dernière phase → `/close` d'abord
- Pour un projet sans `project_type` ou `## Stack` valide → relance `/start` ou `/architect`
- Pour pousser vers GitHub sans deploy prod → c'est `git push`, pas un skill
- Pour redéployer un changement mineur → commande directe du provider, pas besoin de tout le skill

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "livrer", "artifact": "{chemin produit ou null}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Affiche à l'utilisateur :

```
✅ Projet livré (URL prod) : CLAUDE.md ## Production

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. (fin ou /evoluer) —
```

**Prochaine étape** : `/close → /clear → (fin ou /evoluer) —` — voir le rituel dans `docs/KIT.md § STATUS.md & rituel`.
