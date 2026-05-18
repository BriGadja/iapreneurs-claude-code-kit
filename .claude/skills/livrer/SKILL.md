---
name: livrer
description: Utiliser pour déployer le projet en production une fois la dernière phase /close. Lit la section ## Stack du CLAUDE.md (jamais hardcode de provider) pour s'adapter aux choix faits dans /architect — hosting (Vercel/Netlify/Cloudflare/GitHub Pages/autre), BDD (Supabase/Neon/autre), email (Resend/Postmark/autre). Inclut une checklist d'accès BDD advisory (jamais auto-exécutée), **configuration d'un domaine ou sous-domaine custom optionnelle** (Étape 3.5, registrar-aware : OVH/Gandi/Cloudflare/Hostinger/autre), un smoke test post-deploy et l'écriture de l'URL prod dans CLAUDE.md. Ne PAS utiliser au milieu d'une phase ou si /validate ❌ KO.
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

**Hosting = Vercel** — pattern moderne **GitHub → Vercel auto-deploy** (push = deploy). **Règle de séparation CLI/Dashboard** :

- **Dashboard web obligatoire** pour : création de compte (GitHub, Vercel) + **création du repo GitHub** (github.com/new) + **création/import du projet Vercel** (vercel.com/new). Ces étapes restent visuelles pour des raisons pédagogiques (l'utilisateur voit où se passent les choses sur les plateformes).
- **CLI OK pour l'automatisation non-interactive** : `gh api user` (check auth), `gh auth login --web` (auth), `git remote add` / `git push` (automation git), `vercel whoami` / `vercel link` (linker un projet déjà créé via Dashboard), etc.
- **CLI interdite** pour : `gh repo create` (repo doit être créé visuellement sur github.com/new) et `vercel projects add` / import via CLI (projet doit être créé visuellement sur vercel.com/new).

**Étape 3.V.0 — Détection 3 marqueurs d'état** (déterministe, basés uniquement sur `git` standard et CLAUDE.md, pas de CLI tierce) :

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

**Étape 3.V.1 — `route_vercel_onboarding`** (déclenchée si < 3/3 marqueurs)

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

**Étape 3.V.2 — `route_vercel_push`** (déclenchée si 3/3 marqueurs, fast path — toujours pur git)

```bash
CUR_BRANCH=$(git branch --show-current)
git push origin "$CUR_BRANCH"
```

Affiche selon la branche :
- **Push sur `main`** = **deploy prod auto** :
  > "Push sur main. Vercel détecte (GitHub App webhook) et build prod. URL prod (lue depuis `<!-- ship:url -->` de CLAUDE.md) : `{URL_PROD}`. Build ~1-2 min (jusqu'à 3 min grosse app). J'attends 90s avant smoke test. Tu peux suivre le build live sur **https://vercel.com/dashboard** onglet Deployments."
- **Push sur une branche feature** = **preview Vercel** :
  > "Push sur `{CUR_BRANCH}`. Vercel crée un déploiement preview. URL pattern : `https://{slug}-git-{branche-slugifiee}-{team}.vercel.app` (URL exacte visible dans le PR GitHub ou Vercel Dashboard → Deployments). J'attends 90s avant smoke test."

Le smoke test (Étape 4) fait HTTP GET avec retry à 60s × 2 max si la première tentative renvoie 502/504 (build pas fini).

<!-- power-users-fallback:
La CLI Vercel (`vercel`, `vercel --prod`, `vercel link`, etc.) est ENTIÈREMENT OPTIONNELLE — le flow par défaut /livrer est 100% Dashboard web pour des raisons pédagogiques (l'utilisateur voit chaque étape du CI/CD).
Si tu sais ce que tu fais et veux skipper GitHub pour pousser directement :
  vercel --prod
Conservé uniquement pour utilisateurs avancés. Idem côté GitHub : le flow Dashboard utilise uniquement `git` standard, jamais `gh` CLI — celle-ci reste utilisable si déjà installée mais non requise.
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

### Étape 3.5 — Domaine custom (advisory, opt-out)

**S'applique si Étape 3 a produit une URL hosting par défaut** (ex: `discoverly-xi.vercel.app`, `cool-app.netlify.app`, `proj.pages.dev`) et que `project_type` ∈ `{webapp, site}`. Skip silencieux pour `automation` (n8n webhook, pas d'URL marketing).

**Philosophie** : cette étape est **opt-out**. Une seule question d'entrée : si l'utilisateur répond "Non", on file directement à Étape 4 sans le ralentir. Si "Oui", on guide pas-à-pas car le DNS varie selon le registrar (et c'est typiquement là qu'un kit a sa valeur ajoutée).

**Étape 3.5.1 — Question d'entrée**

AskUserQuestion :

> "Tu veux configurer une URL custom (ex: `app.monsite.fr` ou `monsite.fr`) au lieu de garder `{URL_DEFAUT}` ?"

Options :
- **"Oui, un sous-domaine d'un domaine que je possède déjà"** (ex: `app.monsite.fr`, `discoverly.sablia.fr`) → continue 3.5.2 — c'est le cas le plus simple (CNAME)
- **"Oui, un domaine racine que je viens d'acheter"** (ex: `monsite.fr`) → continue 3.5.2 — apex (A records, plus complexe)
- **"Non, je garde l'URL par défaut"** (suffisant pour MVP, interne, démo) → skip direct vers Étape 4

**Étape 3.5.2 — Demander l'URL cible et le registrar**

AskUserQuestion (input texte) : *"Quelle est l'URL exacte que tu veux ?"* → stocke dans `URL_CIBLE` (ex: `discoverly.sablia.fr` ou `monsite.fr`).

AskUserQuestion (choix) : *"Quel registrar gère le domaine `{domaine-parent}` ?"* — options :
1. **OVH** *(recommandé dans le module Claude Code IAPreneurs)*
2. **Gandi**
3. **Cloudflare**
4. **Hostinger**
5. **Autre** *(le skill demandera le nom et proposera un pattern générique CNAME/A)*

Si l'utilisateur ne sait pas → mention : "Si tu n'as pas encore de domaine, **OVH est le registrar par défaut suggéré dans le module Claude Code** (interface FR, support FR, ~7€/an pour un .fr). Achète ton domaine sur ovh.com puis relance `/livrer`."

**Étape 3.5.3 — Côté hosting : ajouter le domaine (V1 = Vercel détaillé)**

**Hosting = Vercel** :

1. Affiche :
   > "Va dans **Vercel Dashboard → ton projet → Settings → Domains → Add**. Entre `{URL_CIBLE}` et clique Add.
   >
   > Vercel va t'afficher la **valeur DNS exacte à configurer chez {registrar}** (généralement un CNAME pour sous-domaine, des A records pour apex). **Colle-moi cette valeur ici avant qu'on touche au DNS** — selon ton cas tu verras soit :
   > - `CNAME` → `cname.vercel-dns.com` (sous-domaine)
   > - `A` → `76.76.21.21` (et parfois d'autres IPs, apex)"
2. AskUserQuestion (input texte) : *"Colle la valeur DNS que Vercel demande"* → stocke dans `DNS_TARGET` (et type `DNS_TYPE` ∈ {CNAME, A}).
3. Le CLI `vercel domains add {URL_CIBLE}` existe en équivalent (automation OK une fois le projet créé), mais pour la 1ère fois le Dashboard est plus visuel et te donne directement la valeur DNS exacte à coller.

**Hosting = Netlify / Cloudflare Pages / GitHub Pages / autre** :
- TODO documenter le flow équivalent (à remplir au fil des livraisons réelles sur d'autres hostings). Pour l'instant, le skill affiche : *"Va dans le dashboard {hosting} → section Domains/Custom domain → ajoute `{URL_CIBLE}` → note la valeur DNS demandée et colle-la moi."* Puis continue avec 3.5.4.

**Étape 3.5.4 — Côté DNS (registrar-aware)**

Selon `{registrar}` et type d'URL (`sous-domaine` si `URL_CIBLE` contient au moins 2 points pour `.fr`/`.com`, sinon apex) :

**OVH + sous-domaine (cas le plus fréquent — Discoverly, IAPreneurs)** :
> 1. Va sur **www.ovh.com/manager → Web Cloud → Domaines → `{domaine-parent}` → Zone DNS**
> 2. Clique **"Ajouter une entrée"** → choisis type **CNAME**
> 3. **Sous-domaine** : `{sous-domaine}` (ex: `discoverly` pour `discoverly.sablia.fr`) — **PAS l'URL complète**
> 4. **Cible** : `{DNS_TARGET}.` ⚠️ **AVEC LE POINT FINAL** ← gotcha classique OVH, sans le point l'entrée est mal interprétée
> 5. TTL : laisse la valeur par défaut (3600s = 1h)
> 6. Valide. La propagation prend généralement 5-15 min chez OVH.

**OVH + apex (domaine racine)** :
> ⚠️ OVH ne supporte PAS ALIAS/ANAME pour apex. Tu dois utiliser des **records A** vers les IPs Vercel.
> 1. Manager OVH → Zone DNS → **modifier le record A par défaut** (sous-domaine = laisse vide) → cible `{DNS_TARGET}` (IP Vercel)
> 2. Si Vercel demande plusieurs IPs, ajoute autant de records A que nécessaire
> 3. Doc Vercel à jour pour les IPs : https://vercel.com/docs/projects/domains/working-with-domains#dns-records

**Gandi + sous-domaine** :
> Gandi LiveDNS → ton domaine → **Records → Add Record** → Type CNAME → Name `{sous-domaine}` → Hostname `{DNS_TARGET}.` (avec point final aussi) → TTL 1800.

**Cloudflare + sous-domaine** :
> ⚠️ Cloudflare DNS proxy + Vercel SSL = SSL cassé (Vercel reçoit du HTTPS Cloudflare au lieu du HTTP origin, l'issu Let's Encrypt échoue).
> 1. Dashboard Cloudflare → ton domaine → **DNS → Records → Add record** → Type CNAME → Name `{sous-domaine}` → Target `{DNS_TARGET}`
> 2. **Proxy status : "DNS only" (nuage GRIS, PAS orange)** ← non-négociable pour Vercel
> 3. Save.

**Hostinger + sous-domaine** :
> hPanel → ton domaine → **DNS / Nameservers → DNS Zone Editor → Add Record** → Type CNAME → Name `{sous-domaine}` → Points to `{DNS_TARGET}` → TTL 14400. Pas de point final requis chez Hostinger (auto-ajouté).

**Autre registrar** (réponse "Autre" en 3.5.2) :
> Pattern générique : crée un record **{DNS_TYPE}** avec name=`{sous-domaine ou @}` et target/value=`{DNS_TARGET}`. Doc Vercel "Add a domain" : https://vercel.com/docs/projects/domains/add-a-domain — section "Configure DNS" couvre les cas par registrar.

**Étape 3.5.5 — Attente propagation**

AskUserQuestion :

> "DNS configuré ! Propagation typique : 5 min à 1h (parfois jusqu'à 24h selon TTL ancien). Tu veux quoi maintenant ?"

Options :
- **"Attente active (max 10 min)"** → le skill poll `dig +short {URL_CIBLE}` (ou `nslookup {URL_CIBLE}`) toutes les 30s. Continue dès que la réponse contient `{DNS_TARGET}` ou une IP Vercel. Si > 10 min, propose : "Continuer en mode pending ou retenter ?"
- **"Skip — je vérifierai moi-même"** → smoke test Étape 4 sur l'URL **fallback hosting** (`{URL_DEFAUT}`), marquer `⏳ DNS pending` dans `## Production` à Étape 5. Le skill propose : *"Re-lance `/livrer` quand le DNS aura propagé pour faire le smoke test final sur ton URL custom."*

**Étape 3.5.6 — SSL Let's Encrypt (info)**

Affiche :
> "🔒 **SSL** : Vercel émet automatiquement un certificat Let's Encrypt dès qu'il détecte la propagation DNS (généralement < 1 min après). Pas d'action de ta part. Tu peux vérifier dans Vercel Dashboard → Domains → état devient ✅ Valid Configuration + 🔒 Active."

**Étape 3.5.7 — Stockage des valeurs pour Étapes 4 et 5**

Garde en mémoire pour la suite :
- `URL_CIBLE` (URL custom configurée) — utilisée par Étape 4 (smoke test cible custom) et Étape 5 (## Production)
- `URL_DEFAUT` (URL hosting fallback) — toujours écrite en backup dans `## Production`
- `DNS_TYPE`, `DNS_TARGET`, `registrar` — écrits dans `## Production` pour audit futur
- `dns_propagated` (booléen) — `true` si attente active validée, `false` si mode skip

### Étape 4 — Smoke test post-deploy

Une fois le deploy passé (URL prod reçue) :

**`project_type = webapp` ou `site`** :
1. **Choix de l'URL cible** :
   - Si Étape 3.5 a configuré une URL custom ET `dns_propagated == true` → smoke test sur `https://{URL_CIBLE}`
   - Si Étape 3.5 a configuré une URL custom MAIS `dns_propagated == false` (mode skip) → smoke test sur `https://{URL_DEFAUT}` (fallback hosting) + affiche warning : *"⏳ DNS pending sur {URL_CIBLE}. Smoke test fait sur fallback. Re-lance `/livrer` quand le DNS aura propagé."*
   - Si Étape 3.5 skip (utilisateur a dit "Non") → smoke test sur `https://{URL_DEFAUT}`
2. **Si tu sors de `route_vercel_push` ou `route_vercel_onboarding` (sous-routes GitHub→Vercel)** : attends 90s avant la 1ère tentative (build Vercel typique). Si la 1ère requête HTTP renvoie 502/504/404 (build pas encore terminé, OU DNS pas encore résolu pour URL custom), retry à 60s × 2 max avant de considérer le deploy en échec.
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

**Cas A — sans domaine custom** (Étape 3.5 skip ou non-applicable) :
```
- **URL production** : {URL_DEFAUT}
- **Hosting** : {nom détecté en 1.2}
- **Type** : {webapp | site | automation}
- **Livré le** : {YYYY-MM-DD}
- **Dernier smoke test** : ✅ {YYYY-MM-DD HH:MM}
```

**Cas B — avec domaine custom configuré** (Étape 3.5 a tourné) :
```
- **URL production** : https://{URL_CIBLE}{statut DNS si applicable}
- **URL fallback hosting** : https://{URL_DEFAUT}
- **DNS** : {DNS_TYPE} chez {registrar} → {DNS_TARGET}
- **Hosting** : {nom détecté en 1.2}
- **Type** : {webapp | site | automation}
- **Livré le** : {YYYY-MM-DD}
- **Dernier smoke test** : ✅ {YYYY-MM-DD HH:MM} (sur {URL_CIBLE | URL_DEFAUT fallback si pending})
```

Où `{statut DNS si applicable}` =
- ` ✅ Propagé` si `dns_propagated == true`
- ` ⏳ DNS pending (propagation en cours, re-lance \`/livrer\` quand résolu)` si `dns_propagated == false`

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
