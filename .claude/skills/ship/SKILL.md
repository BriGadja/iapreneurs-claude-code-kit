---
name: ship
description: Utiliser pour déployer le projet en production une fois la dernière phase /close. Adapté à project_type ∈ {webapp, site, automation} — Vercel pour le web, n8n activate pour les workflows, GitHub Pages en option. Inclut une checklist RLS Supabase advisory (jamais auto-exécutée), un smoke test post-deploy et l'écriture de l'URL prod dans CLAUDE.md. Ne PAS utiliser au milieu d'une phase ou si /validate ❌ KO.
---

# Skill /ship — déployer en production

## Pour quoi faire

Le parcours du kit ne s'arrête pas au `localhost`. `/ship` te fait passer **du repo qui marche en local au projet shipped en prod**, adapté à ton `project_type` :
- **`webapp`** → Vercel + audit RLS Supabase + env vars prod + smoke test homepage
- **`site`** → Vercel static ou GitHub Pages + vérif 404 + Lighthouse basique
- **`automation`** → activate workflow n8n + smoke test webhook + monitor 1ère exécution

Pas d'auto-déploiement silencieux : chaque commande shell affichée, validée explicitement avant exécution. Le RLS audit est une **checklist humaine**, pas une query — le skill ne touche pas à Supabase pour toi.

## Règle stricte

**Pas de deploy sans pré-checks validés**. Si `project_type` est absent du CLAUDE.md, ou si l'audit RLS n'a pas été reviewé (cas webapp), tu **stoppes** et alerts l'utilisateur. Pas de défaut silencieux.

## Comment procéder

### Étape 1 — Lire `project_type` (mandatory)

Lis `<!-- start:identité -->` dans `CLAUDE.md`. Cherche `project_type: {valeur}`.

- Si **absent ou invalide** (∉ `{webapp, site, automation}`) → stoppe :
  > *"Pas de variable `project_type` dans `CLAUDE.md` (ou valeur invalide). `/ship` ne peut pas adapter le déploiement sans elle. Relance `/start` qui va te poser la question et l'écrire."*
- Si **valide** → annonce *"Project type : `{valeur}`. Je déroule le flow ship pour ce type."*

### Étape 2 — Checklist pré-deploy (ADVISORY, jamais auto-exécutée)

**Si `project_type = webapp`** : affiche la **checklist RLS Supabase** (Row-Level Security) — le skill ne peut PAS la vérifier automatiquement (pas d'accès Supabase MCP côté kit forké), donc tu PRINTES la checklist et demandes à l'utilisateur de cocher manuellement.

1. Grep dans `src/`, `app/`, `supabase/migrations/` pour identifier les tables Supabase touchées par le code (mots-clés : `from('table_name')`, `CREATE TABLE`, `INSERT INTO`).
2. Pour chaque table identifiée, affiche :
   ```
   - [ ] Table `{nom}` : RLS activée ? (Supabase Dashboard → Authentication → Policies → {table})
       Lien direct : https://supabase.com/dashboard/project/{ref}/auth/policies
   ```
3. Annonce :
   > *"Voici les tables Supabase touchées par le code. Avant de ship, vérifie manuellement que chacune a une policy RLS adaptée. Dès qu'il y a des données clients (email, téléphone, transcripts, devis, factures, leads, multi-tenant), **RLS dès le premier deploy. Sans exception**.*
   > *Tu confirmes que tu as reviewé chaque table ? (oui / pas encore / pas applicable car pas de données clients)"*
4. Si "pas encore" → stop, demande à l'utilisateur de revenir quand c'est fait.
5. Si "oui" ou "pas applicable" → continue.

**Si `project_type = site`** : checklist plus courte (pas de Supabase typiquement) :
- [ ] Pas de clés API en clair dans le code (grep `sk-`, `Bearer `, `eyJ` dans `src/` et `app/`)
- [ ] `.env` est bien gitignored (`git check-ignore .env`)
- [ ] Lighthouse score local ≥ 80 (lancer `npx lighthouse http://localhost:3000 --view`)

**Si `project_type = automation`** : checklist n8n :
- [ ] Le workflow est validé via `n8n_validate_workflow` MCP
- [ ] Les credentials n8n sont configurées dans l'instance (pas en clair dans le JSON)
- [ ] Le webhook a une URL stable (production, pas test)

### Étape 3 — Déploiement adapté au `project_type`

**Commandes affichées, exécutées sur confirmation explicite. Confirmation-before-action sur tout ce qui touche prod.**

**`project_type = webapp`** :
```bash
# 1. Vérifier que Vercel est lié
vercel link        # si pas déjà fait (génère .vercel/project.json)

# 2. Ajouter les env vars production sur Vercel
vercel env add NEXT_PUBLIC_SUPABASE_URL production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
# (Anthropic SDK, Resend, etc. selon ce que .env contient)

# 3. Deploy production
vercel --prod
```

**`project_type = site`** :
```bash
# Option A — Vercel static
vercel --prod

# Option B — GitHub Pages (si static export Next.js avec output: 'export')
npm run build
# Le workflow .github/workflows/deploy.yml fait le push sur gh-pages
git push origin main   # déclenche le déploiement GitHub Pages
```

**`project_type = automation`** :
```bash
# Activer le workflow n8n (via MCP)
# Tu lances : n8n_update_partial_workflow avec operation activate
# OU : aller dans n8n UI, toggler "active"
```

Pour chaque commande : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

### Étape 4 — Smoke test post-deploy

Une fois le deploy passé (URL prod reçue) :

**`project_type = webapp` ou `site`** :
1. Récupère l'URL prod (de la sortie `vercel --prod` ou du GitHub Pages config).
2. Lance via Playwright MCP : `mcp__playwright__browser_navigate({ url: "https://..." })` + `mcp__playwright__browser_snapshot()`.
3. Vérifie : (a) la page charge sans erreur 5xx, (b) le contenu principal est visible (pas page blanche), (c) pas d'erreur console critique.

**`project_type = automation`** :
1. Récupère l'URL du webhook (de l'output n8n).
2. Lance `curl -X POST <webhook-url> -d '{"test":"smoke"}' -H "Content-Type: application/json"`.
3. Vérifie : (a) réponse HTTP 200 (ou 202 si async), (b) pas d'erreur immédiate, (c) regarde la 1ère exécution dans n8n UI / via MCP `n8n_executions`.

Si le smoke test ÉCHOUE → ne marque pas le projet shipped, alerte l'utilisateur, suggère `/troubleshoot` (v2.0 GA) ou debug manuel.

### Étape 5 — Écrire l'URL prod dans CLAUDE.md

Une fois le smoke test ✅, ouvre `CLAUDE.md` et trouve le bloc :

```
<!-- ship:url -->
{...placeholder...}
<!-- /ship:url -->
```

Remplace le contenu entre les ancres par :

```
- **URL production** : {URL récupérée}
- **Type** : {webapp | site | automation}
- **Shipped le** : {YYYY-MM-DD}
- **Dernier smoke test** : ✅ {YYYY-MM-DD HH:MM}
```

Si l'ancre `<!-- ship:url -->` n'est pas présente (CLAUDE.md trop ancien) → ajoute la section "## Production" en bas du fichier avec les ancres + le contenu. Annonce à l'utilisateur ce que tu as fait.

## Risque #1 — ship sans RLS audit (webapp)

Si tu ship un webapp avec des tables Supabase sans RLS activée, **toutes les données sont publiquement lisibles** par n'importe qui qui connaît la `anon key` (qui est dans le bundle JS donc publique par design). Test du miroir : tu dois pouvoir citer pour chaque table touchée la policy RLS associée (ou justifier explicitement pourquoi c'est OK — ex : table publique read-only).

## Risque #2 — env vars production manquantes

Si Vercel deploy sans `NEXT_PUBLIC_SUPABASE_URL` ou autres env vars → build passe peut-être mais runtime crash sur la première page qui appelle Supabase. **Test du miroir** : avant deploy, tu listes à l'utilisateur les env vars critiques de `.env` et tu confirmes qu'elles sont configurées sur Vercel (via `vercel env ls`).

## Risque #3 — smoke test mensonger

"J'ai déployé, ça devrait marcher" ≠ smoke test. Tu dois **vraiment** taper l'URL et voir une réponse. Si Playwright n'est pas dispo, fais un `curl -I {url}` à minima pour vérifier le 200 OK.

## Quand ne PAS utiliser ce skill

- Avant `/close` de la dernière phase → `/close` d'abord (ship = sortie finale)
- Pour un projet sans `project_type` valide → relance `/start`
- Pour pousser vers GitHub sans deploy prod → c'est `git push`, pas un skill
- Pour redéployer un changement mineur → `vercel --prod` direct, pas besoin de tout le skill

## Handoff

Fin du skill :

```markdown
## ✅ Projet shipped

- **URL** : {URL prod}
- **Type** : {project_type}
- **Smoke test** : ✅
- **CLAUDE.md** : URL écrite dans `<!-- ship:url -->`

### Prochaine étape
- Surveiller la production pendant 24-48h (logs Vercel / n8n executions)
- Quand tu veux ajouter une feature → `/evolve` *(à venir v2.0 GA)*
- Si bug en prod → `/troubleshoot` *(à venir v2.0 GA)*
```
