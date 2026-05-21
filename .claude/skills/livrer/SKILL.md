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
- **Registrar domaine** (si applicable) : OVH / Gandi / Cloudflare / Hostinger / Namecheap / autre
- **BDD** (si webapp) : Supabase / Neon / PlanetScale / Turso / autre
- **Email** (si applicable) : Resend / Postmark / SendGrid / autre
- **Automation runtime** (si automation) : n8n cloud / n8n self-hosted

**1.3 — Confirmation stack (recommandation, JAMAIS imposition)** — **étape ajoutée v2.5.2, non-négociable pour respecter le principe stack-agnostic du skill** :

Avant toute action deploy, le skill DOIT confirmer explicitement la stack avec l'utilisateur — Vercel/Supabase/OVH ne sont **recommandés** (défauts module Claude Code IAPreneurs), pas **imposés**. Cette confirmation tourne **en première position dans le skill** (avant Étape 2 pré-checks).

**Cas A — `## Stack` vide ou ambiguë** (typique 1ère livraison, projet sans /architect Étape 2b complète) :

AskUserQuestion :

> "Avant de livrer, je confirme la stack qu'on va utiliser. La **stack recommandée par défaut** dans le module Claude Code IAPreneurs (interface FR, support FR, retours communauté positifs) est :
> - **GitHub** pour stocker le code (gratuit, standard de fait)
> - **Vercel** pour héberger le projet (hosting + CI/CD intégré, Hobby gratuit non-commercial / Pro ~$20/mo pour usage commercial)
> - **OVH** pour le registrar de domaine (~7€/an .fr, interface + support FR)
>
> Tu veux quoi ?"

Options :
1. **"OK, j'utilise la stack recommandée (GitHub + Vercel + OVH)"** → écris dans `## Stack` du CLAUDE.md : `hosting: Vercel` + `registrar: OVH` (+ git: GitHub implicite). Continue Étape 2.
2. **"Je veux changer l'hosting"** → AskUserQuestion choix : Netlify / Cloudflare Pages / GitHub Pages / Render / Fly.io / Hostinger / autre (input texte). Écris dans `## Stack`. Continue Étape 2.
3. **"Je veux changer le registrar"** → AskUserQuestion choix : Gandi / Cloudflare / Hostinger / Namecheap / autre (input texte). Écris dans `## Stack`. Continue Étape 2.
4. **"Je veux tout changer / pas d'avis encore"** → demande tool par tool (hosting puis registrar) en input texte. Écris dans `## Stack`. Continue Étape 2.

**Cas B — `## Stack` déjà renseignée** (livraison N+1, ou /architect a déjà fixé la stack) :

AskUserQuestion **de confirmation rapide** (1 question, défaut "garder") :

> "Détection stack depuis CLAUDE.md ## Stack :
> - **Hosting** : {hosting_detecté}
> - **Registrar** : {registrar_detecté ou "non renseigné"}
> - **BDD** : {bdd_detecté si webapp}
>
> C'est toujours bon ?"

Options :
- **"Oui, garde cette stack"** → Continue Étape 2 (cas fast path).
- **"Je veux changer quelque chose"** → bascule sur le flow Cas A pour identifier ce qui change, MAJ `## Stack` en conséquence.

**Règle stricte** : le skill **ne déroule jamais** le flow Vercel (`references/vercel.md`) si l'hosting confirmé n'est pas Vercel. Même règle pour le flow registrar (Étape 3.5) : si registrar = Cloudflare, on suit la branche Cloudflare, pas OVH. La stack confirmée ici **route déterministiquement** toutes les sous-étapes ci-dessous.

> **Test du miroir** (cf. Risque #3 ci-dessous) : tu dois pouvoir citer la réponse de l'utilisateur à cette confirmation 1.3 avant de proposer une commande Vercel/Netlify/Cloudflare. Si tu ne l'as pas demandée, tu es hors process — recommence à Étape 1.3.

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

Route selon le hosting confirmé en 1.3 :

| Hosting | Référence à charger |
|---------|---------------------|
| **Vercel** | Lis `references/vercel.md` et applique sa procédure complète (3.V.0 détection 3 marqueurs → 3.V.1 onboarding OU 3.V.2 fast path). |
| **Netlify** | Lis `references/netlify.md` et applique. |
| **Cloudflare Pages** | Lis `references/cloudflare.md` et applique. |
| **GitHub Pages** | Lis `references/github-pages.md` et applique. |
| **Render** | Lis `references/render.md` et applique. |
| **Fly.io** | Lis `references/fly.md` et applique. |
| **Hostinger** (VPS ou hosting partagé) | Lis `references/hostinger.md` et applique. |
| **Autre** | Demande à l'utilisateur la commande qu'il utilise habituellement. Propose de l'écrire dans une section `## Déploiement` du CLAUDE.md pour les prochains `/livrer`. |

**Project_type = automation** : pas de hosting traditionnel, c'est l'activation du workflow n8n :
```bash
# Via MCP : n8n_update_partial_workflow avec operation activate
# Ou via n8n UI : toggle "active"
```

Pour chaque commande issue de la référence chargée : affiche, demande *"J'exécute ? (oui / modifie / skip)"*, attends réponse.

À la sortie de la référence hosting, tu dois avoir collecté `URL_DEFAUT` (URL prod hosting par défaut, ex: `discoverly-xi.vercel.app`).

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

**Étape 3.5.3 — Côté hosting : ajouter le domaine**

Selon hosting confirmé en 1.3, la référence chargée à Étape 3 contient la sous-section "Domaine custom côté {hosting}" — applique-la pour faire ajouter `URL_CIBLE` au hosting et récupérer `DNS_TARGET` (et type `DNS_TYPE` ∈ {CNAME, A}).

**Étape 3.5.4 — Côté DNS (registrar-aware)**

**Lis `references/domain-providers.md` et applique la procédure correspondante** à `{registrar}` choisi en 3.5.2. Le fichier couvre OVH (sous-domaine + apex), Gandi, Cloudflare, Hostinger, et "Autre" (pattern générique).

**Étape 3.5.5 — Attente propagation**

AskUserQuestion :

> "DNS configuré ! Propagation typique : 5 min à 1h (parfois jusqu'à 24h selon TTL ancien). Tu veux quoi maintenant ?"

Options :
- **"Attente active (max 10 min)"** → le skill poll `dig +short {URL_CIBLE}` (ou `nslookup {URL_CIBLE}`) toutes les 30s. Continue dès que la réponse contient `{DNS_TARGET}` ou une IP Vercel. Si > 10 min, propose : "Continuer en mode pending ou retenter ?"
- **"Skip — je vérifierai moi-même"** → smoke test Étape 4 sur l'URL **fallback hosting** (`{URL_DEFAUT}`), marquer `⏳ DNS pending` dans `## Production` à Étape 5. Le skill propose : *"Re-lance `/livrer` quand le DNS aura propagé pour faire le smoke test final sur ton URL custom."*

**Étape 3.5.6 — SSL Let's Encrypt (info)**

La référence hosting (ex: `references/vercel.md` § SSL) contient l'info à afficher sur l'émission auto du certificat. Affiche-la.

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
2. **Si tu sors du flow Vercel (`references/vercel.md`, sous-routes `route_vercel_push` ou `route_vercel_onboarding`)** : attends 90s avant la 1ère tentative (build Vercel typique). Si la 1ère requête HTTP renvoie 502/504/404 (build pas encore terminé, OU DNS pas encore résolu pour URL custom), retry à 60s × 2 max avant de considérer le deploy en échec.
3. **Invoque le sub-agent `browser-verifier`** avec :
   - `url` : l'URL choisie en étape 1 ci-dessus (custom propagée, custom pending fallback hosting, ou par défaut)
   - critères : status 2xx, console_errors == 0, non_blank, et `title_contains` si le projet a un nom de marque attendu
   - Le sub-agent gère navigate + snapshot + screenshot dans `tmp/browser-verify/` + cleanup.
4. Affiche le verdict à l'utilisateur sous la forme : *"Vérification UI : OK ({raison browser-verifier})"* / *"Vérification UI : anomalie — {raison}"* / *"Vérification UI : KO — {raison}"*. JAMAIS de mention du sub-agent côté UX. Le verdict couvre : (a) la page charge sans 5xx, (b) contenu principal visible (pas page blanche), (c) pas d'erreur console critique.

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
