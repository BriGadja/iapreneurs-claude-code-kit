# Vercel — procédure deploy (hosting = vercel)

> **Lis ce fichier uniquement si** `/livrer` Étape 1.2 détecte `hosting: Vercel` (confirmé en Étape 1.3).
>
> Pattern moderne **GitHub → Vercel auto-deploy** (push = deploy). Onboarding guidé au premier deploy, fast path par `git push` ensuite.

## Règle de séparation CLI/Dashboard

- **Dashboard web obligatoire** pour : création de compte (GitHub, Vercel) + **création du repo GitHub** (github.com/new) + **création/import du projet Vercel** (vercel.com/new). Ces étapes restent visuelles pour des raisons pédagogiques (l'utilisateur voit où se passent les choses sur les plateformes).
- **CLI OK pour l'automatisation non-interactive** : `gh api user` (check auth), `gh auth login --web` (auth), `git remote add` / `git push` (automation git), `vercel whoami` / `vercel link` (linker un projet déjà créé via Dashboard), etc.
- **CLI interdite** pour : `gh repo create` (repo doit être créé visuellement sur github.com/new) et `vercel projects add` / import via CLI (projet doit être créé visuellement sur vercel.com/new).

## Étape 3.V.0 — Détection 3 marqueurs d'état

Déterministe, basés uniquement sur `git` standard et CLAUDE.md, pas de CLI tierce :

```bash
# Marqueur 1 — remote GitHub déjà configuré ?
MARK_REMOTE=0 ; git remote get-url origin 2>/dev/null | grep -qE 'github.com[:/]' && MARK_REMOTE=1

# Marqueur 2 — repo distant existe et est accessible (git natif, pas gh CLI) ?
MARK_REMOTE_EXISTS=0
if [ "$MARK_REMOTE" = "1" ]; then
  # git ls-remote tape le repo en lecture seule (utilise auth HTTPS keychain / GH_TOKEN / SSH key)
  git ls-remote origin HEAD >/dev/null 2>&1 && MARK_REMOTE_EXISTS=1
fi

# Marqueur 3 — projet déjà déployé une fois sur Vercel via Dashboard ?
# (l'ancre `<!-- ship:url -->` est remplie par Étape 5 au premier deploy réussi)
MARK_DEPLOYED=0 ; grep -A2 '<!-- ship:url -->' CLAUDE.md 2>/dev/null | grep -qE 'https?://[a-z0-9-]+\.vercel\.app|https?://[a-z0-9.-]+\.[a-z]{2,}' && MARK_DEPLOYED=1

# Score
SCORE=$((MARK_REMOTE + MARK_REMOTE_EXISTS + MARK_DEPLOYED))
```

- Si `SCORE == 3` → route **`route_vercel_push`** (fast path) — passe directement à l'Étape 3.V.2 ci-dessous.
- Sinon → route **`route_vercel_onboarding`** (premier deploy, guidé Dashboard) — passe à l'Étape 3.V.1.

## Étape 3.V.1 — `route_vercel_onboarding` (déclenchée si < 3/3 marqueurs)

Pas-à-pas guidé, AskUserQuestion à chaque checkpoint. **Création de comptes + création du repo GitHub + création du projet Vercel = Dashboard web** (visuel, pédagogique). **Tout le reste (auth checks, git operations, optional CLI links) peut utiliser la CLI.**

1. **Warning Vercel Hobby (EN PREMIER, avant tout setup)** — affiche :
   > ⚠️ **Vercel Hobby plan = usage personnel non-commercial uniquement.** Si tu vends cet outil comme prestation à un client (€1500+), tu DOIS upgrade vers Vercel Pro (~$20/mo) **avant** de pousser, sinon TOS violation. Alternative sans cette restriction : **Netlify** (gratuit, commercial OK) — relance `/livrer` après avoir changé `## Stack` dans CLAUDE.md si tu préfères.
   >
   > AskUserQuestion : *"Tu continues en Hobby (perso, non-commercial) ?"* — options :
   > - "Oui, Hobby OK (usage perso)"
   > - "Oui, je suis déjà sur Vercel Pro"
   > - "Stop, je vais upgrade avant" → stoppe le skill ici

2. **Check auth GitHub via `gh` CLI** (automation, pas de friction) — utilise `gh api user >/dev/null 2>&1` (plus fiable que `gh auth status` qui a une régression connue sur certaines versions retournant exit 0 même en échec) :
   ```bash
   gh api user >/dev/null 2>&1 || AUTH_KO=1
   ```
   Si KO → deux chemins d'auth (toujours CLI, automation OK) :
   - **Device flow (recommandé débutant)** : `BROWSER= gh auth login --web` (Claude affiche le code device, l'utilisateur l'entre sur github.com/login/device dans son navigateur)
   - **Personal Access Token (si déjà un PAT)** : `export GH_TOKEN=ghp_xxxxx && gh api user`

   Attends confirmation utilisateur. Si `gh` CLI absente → fallback : continue, le push à l'étape 4 utilisera l'auth git native (HTTPS keychain / SSH key).

3. **AskUserQuestion : compte GitHub ?** (création de compte = Dashboard) — options :
   - "Oui, j'ai un compte"
   - "Non, je n'en ai pas" → affiche **https://github.com/signup** (signup gratuit ~2 min via le Dashboard GitHub), attends que l'utilisateur dise "C'est fait", puis re-run check auth (étape 2)

4. **Création du repo GitHub = Dashboard web** *(non-négociable : visuel/pédagogique, PAS de `gh repo create`)* :
   > AskUserQuestion : *"Repo public ou privé ?"* — options :
   > - "Public (recommandé — philosophie communauté IAPreneurs)"
   > - "Privé"
   >
   > Va sur **https://github.com/new** :
   > 1. **Repository name** : `{REPO_NAME}` (= nom du dossier courant, ex: `discoverly`)
   > 2. **Description** : laisse vide ou mets une phrase
   > 3. **Public / Private** : selon ton choix ci-dessus
   > 4. ⚠️ **NE COCHE PAS** "Add a README file", "Add .gitignore", "Choose a license" (le repo local en a déjà) — sinon conflit au premier push
   > 5. Clique **Create repository**
   >
   > GitHub te montre alors la page "Quick setup" → copie l'URL HTTPS du repo (ex: `https://github.com/{user}/{REPO_NAME}.git`).
   >
   > AskUserQuestion (input texte) : *"Colle l'URL HTTPS du repo"* → stocke dans `REPO_URL`.
   >
   > Le skill exécute (git natif = automation OK) :
   > ```bash
   > git remote add origin "$REPO_URL"
   > git branch -M main
   > # push différé après création compte Vercel + import projet + env vars (étapes 5-7)
   > # pour que le 1er build trigger Vercel quand tout est en place
   > ```
   >
   > **Cas re-clone** (repo déjà créé sur GitHub avant `/livrer`) : skip la création, demande juste `REPO_URL` et fait le `git remote add origin`.

5. **AskUserQuestion : compte Vercel ?** (création de compte = Dashboard) — options :
   - "Oui, j'ai un compte"
   - "Non" → affiche **https://vercel.com/signup** → clique **"Continue with GitHub"** (connexion OAuth classique — Vercel utilise ton identité GitHub, pas de nouveau mot de passe, pas de "third-party app" à installer séparément)

6. **Création/import du projet Vercel = Dashboard web** *(non-négociable : visuel/pédagogique, PAS d'import via CLI)*. **La connexion GitHub ↔ Vercel se fait inline pendant l'import**, pas via une étape séparée "install Vercel GitHub App" — Vercel gère ça transparent dès le 1er Import :
   > Va sur **https://vercel.com/new** :
   > 1. Section **"Import Git Repository"** :
   >    - **1ère fois** : Vercel affiche un bouton **"Continue with GitHub"** ou **"Configure GitHub App"** — clique, autorise l'accès à tes repos. Tu peux choisir **"Only select repositories"** et cocher uniquement `{REPO_NAME}` (sécurité). Ça reste **dans le flow Vercel**, c'est juste l'écran OAuth classique GitHub qui s'ouvre — c'est pas une démarche "third-party" séparée.
   >    - **Sessions suivantes** : tes repos sont déjà listés, tu vois `{REPO_NAME}` directement.
   > 2. Clique **Import** à côté de `{REPO_NAME}`
   > 3. **Configure Project** :
   >    - Framework Preset : auto-détecté (Next.js, Vite, etc.)
   >    - Root Directory : `./` (laisse par défaut sauf monorepo)
   >    - Build Command / Output Directory : auto-détectés
   > 4. **NE CLIQUE PAS ENCORE "Deploy"** — il faut d'abord ajouter les env vars (étape 7).
   >
   > AskUserQuestion : *"Tu es sur la page Configure Project (avant Deploy) ?"* — options :
   > - "Oui, prêt pour les env vars"
   > - "J'ai déjà cliqué Deploy" → continue, on ajoutera les env vars après et on relancera un deploy
   > - "Vercel ne voit pas mon repo `{REPO_NAME}`" → clique **"Adjust GitHub App Permissions"** dans la même page d'import, sélectionne `{REPO_NAME}` dans la liste GitHub, valide, retour à l'import — toujours inline, pas de détour

7. **Env vars AVANT premier deploy (sequencing critique)** — détecte les clés présentes dans `.env.local` (ou `.env`) :

   **Option A — Dashboard** (recommandé pour la 1ère fois, visuel) :
   > Sur la page Vercel **Configure Project** (avant le clic Deploy) :
   > 1. Déroule la section **Environment Variables**
   > 2. Pour chaque clé : tape le Name (ex: `OPENAI_API_KEY`), colle la Value depuis ton `.env.local`, laisse les 3 environments cochés (Production / Preview / Development)
   > 3. Add (bouton). Répète pour chaque variable.

   **Option B — CLI `vercel env add` ou `vercel env pull`** (automation, après que le projet est créé via Dashboard) :
   > Si tu préfères automatiser, après que le projet existe sur Vercel :
   > ```bash
   > vercel link --yes          # associe le repo local au projet Vercel créé en étape 6
   > # puis pour chaque var :
   > vercel env add OPENAI_API_KEY production   # interactif : Vercel demande la valeur
   > # OU push depuis .env.local en batch :
   > vercel env pull .env.vercel-check          # pull les vars actuelles pour comparaison
   > ```

   **Si tu as déjà cliqué Deploy à l'étape 6** : pas grave, va dans **Project Settings → Environment Variables**, ajoute tes clés, puis **Deployments → ⋯ → Redeploy**.

   AskUserQuestion : *"J'ai ajouté toutes les variables"* — options :
   - "Oui, toutes ajoutées"
   - "Pas de variables d'env (site statique sans backend)"
   - "Je m'en occupe après (build prod va crash mais OK pour test visuel)"

8. **Premier deploy** :
   > Sur la page Vercel **Configure Project** : clique **Deploy** (Dashboard) — OU si tu as déjà cliqué Deploy en étape 6, le push de l'étape suivante re-trigger automatiquement.
   >
   > **Push GitHub pour build** (git automation) — si pas encore fait :
   > ```bash
   > git push -u origin main
   > ```
   > Vercel détecte le push (GitHub App webhook) et lance le build. Tu peux suivre live sur **https://vercel.com/dashboard** → onglet Deployments.
   >
   > Build typique : 1-2 min (jusqu'à 3 min grosse app). URL prod : `https://{REPO_NAME}.vercel.app` (suffixée si conflit : `{REPO_NAME}-{hash}.vercel.app`).
   >
   > AskUserQuestion (input texte) : *"Colle l'URL prod exacte affichée par Vercel (ou laisse vide si pas encore visible — j'attends 90s)"* → stocke dans `URL_DEFAUT`. Si vide → attente 90s + relance la question.

## Étape 3.V.2 — `route_vercel_push` (déclenchée si 3/3 marqueurs, fast path — toujours pur git)

```bash
CUR_BRANCH=$(git branch --show-current)
git push origin "$CUR_BRANCH"
```

Affiche selon la branche :
- **Push sur `main`** = **deploy prod auto** :
  > "Push sur main. Vercel détecte (GitHub App webhook) et build prod. URL prod (lue depuis `<!-- ship:url -->` de CLAUDE.md) : `{URL_PROD}`. Build ~1-2 min (jusqu'à 3 min grosse app). J'attends 90s avant smoke test. Tu peux suivre le build live sur **https://vercel.com/dashboard** onglet Deployments."
- **Push sur une branche feature** = **preview Vercel** :
  > "Push sur `{CUR_BRANCH}`. Vercel crée un déploiement preview. URL pattern : `https://{slug}-git-{branche-slugifiee}-{team}.vercel.app` (URL exacte visible dans le PR GitHub ou Vercel Dashboard → Deployments). J'attends 90s avant smoke test."

Le smoke test (Étape 4 du SKILL.md) fait HTTP GET avec retry à 60s × 2 max si la première tentative renvoie 502/504 (build pas fini).

<!-- power-users-fallback:
La CLI Vercel (`vercel`, `vercel --prod`, `vercel link`, etc.) est ENTIÈREMENT OPTIONNELLE — le flow par défaut /livrer est 100% Dashboard web pour des raisons pédagogiques (l'utilisateur voit chaque étape du CI/CD).
Si tu sais ce que tu fais et veux skipper GitHub pour pousser directement :
  vercel --prod
Conservé uniquement pour utilisateurs avancés. Idem côté GitHub : le flow Dashboard utilise uniquement `git` standard, jamais `gh` CLI — celle-ci reste utilisable si déjà installée mais non requise.
-->

## Domaine custom côté Vercel (appelé par Étape 3.5 du SKILL.md)

Quand Étape 3.5 du SKILL.md demande d'ajouter un domaine custom et que l'hosting est Vercel :

1. Affiche :
   > "Va dans **Vercel Dashboard → ton projet → Settings → Domains → Add**. Entre `{URL_CIBLE}` et clique Add.
   >
   > Vercel va t'afficher la **valeur DNS exacte à configurer chez {registrar}** (généralement un CNAME pour sous-domaine, des A records pour apex). **Colle-moi cette valeur ici avant qu'on touche au DNS** — selon ton cas tu verras soit :
   > - `CNAME` → `cname.vercel-dns.com` (sous-domaine)
   > - `A` → `76.76.21.21` (et parfois d'autres IPs, apex)"
2. AskUserQuestion (input texte) : *"Colle la valeur DNS que Vercel demande"* → stocke dans `DNS_TARGET` (et type `DNS_TYPE` ∈ {CNAME, A}).
3. Le CLI `vercel domains add {URL_CIBLE}` existe en équivalent (automation OK une fois le projet créé), mais pour la 1ère fois le Dashboard est plus visuel et te donne directement la valeur DNS exacte à coller.

## SSL Let's Encrypt (info)

> "🔒 **SSL** : Vercel émet automatiquement un certificat Let's Encrypt dès qu'il détecte la propagation DNS (généralement < 1 min après). Pas d'action de ta part. Tu peux vérifier dans Vercel Dashboard → Domains → état devient ✅ Valid Configuration + 🔒 Active."
