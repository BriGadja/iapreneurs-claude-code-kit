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

**Hosting = Vercel** :
```bash
vercel link              # si pas déjà fait
vercel env add {VAR_NAME} production    # pour chaque variable de .env
vercel --prod
```

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
2. Lance via Playwright MCP : `mcp__playwright__browser_navigate({ url: "https://..." })` + `mcp__playwright__browser_snapshot()`. Si tu prends un screenshot, enregistre-le dans `tmp/smoke-test-{date}.png` (le dossier `tmp/` est gitignored), supprime après vérification.
3. Vérifie : (a) la page charge sans 5xx, (b) contenu principal visible (pas page blanche), (c) pas d'erreur console critique.

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
