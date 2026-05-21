# Session réelle de A à Z — Freelance Devis

> Tuto narratif : tu lis les commandes que je tape, les réponses Claude (abrégées), et tu comprends comment le kit s'enchaîne. Les artefacts complets (`CLAUDE.md`, `PRD.md`, `DESIGN.md`) sont dans ce dossier — ici tu vois **comment ils ont été produits**.
>
> Durée réelle de la session de référence : ~3h20 sur 2 sessions (jour 1 : `/start` → `/plan Phase 1`, jour 2 : `/execute` Phase 1 → `/livrer`).
>
> Lecture rapide : les blocs `> Claude :` sont les sorties LLM tronquées aux essentiels. Les `…` indiquent les coupes pour la lisibilité.

---

## Jour 1 — 14h05 — Démarrage

J'ai cloné le kit via le bouton "Use this template" sur GitHub, nommé mon repo `freelance-devis`, fait `git clone`, `cd freelance-devis`, lancé `claude`.

### Skill 1 — `/start`

```
> /start
```

> Claude :
> *Bienvenue. Je détecte un fresh template du kit IAPreneurs. Le `CLAUDE.md.template` est présent mais pas de `CLAUDE.md` projet — je copie le template vers `CLAUDE.md` (gitignored par défaut, chaque fork génère le sien).*
>
> *Tu veux skipper la visite du kit ? (oui/non)*

Je tape **oui** (j'ai déjà lu le QUICKSTART).

> Claude :
> *3 questions de cadrage :*
> *1. Ton projet s'appelle comment, et en une phrase, ça fait quoi ?*

**Une app qui automatise la génération de devis pour mon activité de freelance, à partir d'un formulaire public que je peux mettre sur mon site.**

> *2. Qui va l'utiliser ?*

**Moi tout seul côté admin. Les clients via un formulaire public.**

> *3. Quel type de projet ?*
> *A: webapp SaaS · B: site vitrine · C: automatisation n8n · D: autre*

**A** (webapp).

> *4. Tu vas utiliser n8n sur ce projet ? (oui/non)*

**Oui** (je veux que la qualification du devis tourne sur n8n).

> Claude :
> *Identité écrite dans `CLAUDE.md` (section `## Identité`) avec `project_type: webapp` et `project_uses_n8n: true`. STATUS.md initialisé.*
>
> *Vérif outillage…*
> - *Playwright MCP : ✅ déjà installé*
> - *n8n MCP : pas trouvé → je lance l'install via `references/n8n-mcp-install.md`. Tu as une instance n8n ? URL + API key dans `.env` ?*

J'ai déjà n8n self-hosted, je colle l'URL et la clé dans `.env` (Claude m'a confirmé qu'il ne la répèterait pas en clair). Le `.mcp.json` est mis à jour avec `${N8N_URL}` et `${N8N_API_KEY}`.

> Claude :
> *MCP n8n testé : 12 nodes accessibles ✅. Plugin frontend-design : pas installé, je l'installe (`claude plugin install frontend-design@claude-code-plugins`).*
>
> *Dernière question : ton idée est précise ou floue ?*

**Précise — je sais ce que je veux.**

> Claude :
> *Setup terminé. Prochaine étape : `/architect`.*

**Total : ~7 min.** Je tape `/close` puis `/clear` (rituel) avant `/architect`.

---

## Jour 1 — 14h18 — Cadrage du PRD

### Skill 2 — `/architect`

```
> /architect
```

Claude pose 6 questions (cadrage MVP, utilisateurs, providers favoris, scaffold). Les réponses clé :

- **Pour Étape 2b providers favoris** : Vercel (hosting), Supabase (BDD + auth), Resend (email), n8n self-hosted (moteur). Claude écrit `Stack` dans `CLAUDE.md`.
- **Pour Étape 4 scope MVP** : 3 features Core — formulaire public, espace admin protégé, génération PDF via n8n. Hors-MVP : multi-freelance, multi-langue, paiement Stripe.
- **Pour Étape 6 Provisioning & Scaffold** : Claude scaffold le repo Next.js + Tailwind + shadcn, écrit `.env.example`, crée la structure `app/`, `lib/`, `components/`.

> Claude :
> *PRD.md écrit (4 phases : Phase 1 formulaire + persistance, Phase 2 admin & PDF, Phase 3 polish UX, Phase 4 production-ready). Stack écrit dans CLAUDE.md.*
>
> *Tu es en webapp + Request Classification **STANDARD**. Prochaine étape recommandée : `/design` avant `/plan` Phase 1.*

**Total : ~25 min** (questions + scaffold). `/close` → `/clear` → `/design`.

---

## Jour 1 — 14h48 — Design system

### Skill 3 — `/design`

```
> /design
```

Claude pose les questions sur identité visuelle (palette, typo, ton, composants centraux). Le projet est pour un freelance pro français — je donne :

- Palette : neutre + un accent (j'hésite entre bleu et vert sapin)
- Typo : Inter (lisibilité)
- Ton : sobre, professionnel, pas du tout startup-tech
- Composants centraux : 9 (Button, Input, TextArea, FormField, Card, Modal, Toast, Badge, EmptyState)

> Claude :
> *DESIGN.md produit au format Google `design.md` alpha (YAML tokens + 8 sections markdown). Je propose `#3a6f4b` (vert sapin) comme accent — neutre + crédible pour un freelance pro français. Tu valides ?*

**Validé.**

> Claude :
> *DESIGN.md écrit. Le plugin frontend-design lira ce fichier pour construire les composants. Prochaine étape : `/plan Phase 1`.*

**Total : ~30 min** (le LLM itère deux fois sur la palette avant de valider). `/close` → `/clear` → `/plan Phase 1`.

---

## Jour 1 — 15h25 — Plan Phase 1

### Skill 4 — `/plan Phase 1`

```
> /plan Phase 1
```

Claude lit `PRD.md` Phase 1 + `DESIGN.md` (Phase touche à l'UI). Découpe en 5 tâches avec critères "Fait quand" testables :

1. Setup Supabase (schema + RLS sur `quote_requests`) — Fait quand : `psql` retourne 1 row insérée par `anon` et 0 row insérée par `authenticated` non-owner
2. Component `<QuoteRequestForm/>` (5 champs + validation Zod) — Fait quand : `pnpm test components/quote-request-form.test.tsx` PASS
3. Page `/devis` avec form + handler API `/api/quote-request` — Fait quand : Playwright remplit form → 200 + row en BDD
4. Auth admin (Supabase Auth magic link, email allowlist `.env`) — Fait quand : connexion magic link OK depuis `brice@…`, refusée pour `random@…`
5. Page `/admin/quotes` listant les requests — Fait quand : Playwright login → liste affichée

> Claude :
> *`docs/plans/phase-1-plan.md` écrit. Tu veux `/challenge` avant `/execute` ? (Request Classification STANDARD → optionnel)*

**Oui** — Phase 1 a du RLS et de l'auth, je veux un devil's advocate dessus.

### Skill 5 — `/challenge docs/plans/phase-1-plan.md`

```
> /challenge docs/plans/phase-1-plan.md
```

> Claude :
> *3 risques majeurs :*
> *1. **RLS sur `quote_requests` — policy INSERT anon** : si tu actives la policy `WITH CHECK (true)` pour anon, n'importe qui peut spammer. Faut au minimum un rate-limit en amont (middleware Next.js ou Supabase Edge Function avec captcha). Tâche 1 actuelle ne mentionne pas ça.*
> *2. **Magic link allowlist en `.env`** : si tu déploies sur Vercel et tu changes l'allowlist, faut un redeploy. Migre vers une table `admin_emails` ou laisse en `.env` mais documente le coût.*
> *3. **Tâche 3 critère "200 + row en BDD" est trop faible** : 200 ne dit pas que le row a les bons champs. Renforce le critère : "200 + row en BDD avec tous les champs zod-valides + Resend ack présent dans le log".*
>
> *3 hypothèses non vérifiées :*
> *1. Supabase env vars dispo dans Vercel (à vérifier en dashboard avant Tâche 1).*
> *2. n8n webhook accessible depuis Vercel (CORS + auth).*
> *3. Resend domaine vérifié pour SPF/DKIM.*
>
> *Verdict : **REWORK** — patcher Tâche 1 (rate-limit) et Tâche 3 (critère renforcé) avant `/execute`.*

J'accepte le REWORK. Claude patche le plan, je relance `/challenge`. Verdict **GO**.

**Total Phase 1 plan + challenge : ~40 min.** `/close` → `/clear` (fin de session jour 1).

---

## Jour 2 — 9h12 — Exécution Phase 1

### Skill 6 — `/execute docs/plans/phase-1-plan.md`

```
> /execute docs/plans/phase-1-plan.md
```

Claude tourne pendant ~1h45 sur les 5 tâches. Quelques moments clés :

**Tâche 1** : Claude écrit la migration Supabase `0001_quote_requests.sql` avec RLS + rate-limit via Edge Function. Test : `psql` direct PASS, mais l'Edge Function refuse au-delà de 5 inserts/IP/h → ✅. Coché.

**Tâche 2** : composant `<QuoteRequestForm/>`. Claude délègue à `frontend-design` plugin qui lit `DESIGN.md` → composant qui respecte les tokens (vert sapin sur boutons primary). Vitest PASS du premier coup. Coché.

**Tâche 3** : page `/devis` + API. Premier essai du Playwright Test → ❌ 500 sur `/api/quote-request`. Claude invoque `/debug` (built-in) :

> Claude (mode /debug) :
> *Le 500 vient de `await resend.emails.send(...)` qui throw `domain not verified`. Hypothèse `/challenge` n°3 vérifiée : domaine Resend pas configuré. Test de régression écrit (`api/quote-request.test.ts`), il échoue. Fix : `try/catch` + `logForDebugging` + queue retry n8n. Test pass.*

Coché.

**Tâche 4** : auth magic link. Tout passe.

**Tâche 5** : page `/admin/quotes`. RLS sur `SELECT` filtre par `admin_emails`. Playwright PASS.

> Claude :
> *Phase 1 — 5/5 tâches cochées. VERIMAP : 5/5 pass. Prochaine étape : `/validate`.*

**Total Phase 1 execute : ~1h45**.

---

## Jour 2 — 11h05 — Validation Phase 1

### Skill 7 — `/validate`

```
> /validate
```

> Claude :
> *Phase 1 webapp — j'exécute :*
> *1. Playwright screenshot `/devis` (page publique) → ✅ form rendu, champs visibles, bouton primary vert sapin OK*
> *2. Playwright screenshot `/admin/quotes` après login → ✅ liste affichée*
> *3. Audit policy d'accès BDD :*
>    - *RLS active sur `quote_requests` : ✅*
>    - *Policy INSERT anon : ✅ (avec rate-limit Edge Function)*
>    - *Policy SELECT admin : ✅ (filtré par `admin_emails`)*
> *4. Resend SPF/DKIM : ⚠️ domaine `freelancedevis.fr` pas encore vérifié → ajouté à TODO Phase 2*
>
> *Verdict : ✅ OK (Phase 1 validée, 1 TODO Phase 2 noté)*

`/close` direct (mandatory post `/validate ✅`).

---

## Jour 2 — 11h12 — Clôture Phase 1

### Skill 8 — `/close`

```
> /close
```

Claude détecte le mode **full** (commit + harvest + Vercel gate).

> Claude :
> *Phase 1 — Formulaire & persistance ✅ Terminée le 2026-02-12 (marquée dans PRD.md).*
>
> *Commit proposé :*
> ```
> feat(phase-1): formulaire public + persistance + auth admin
>
> - migration 0001_quote_requests.sql avec RLS + rate-limit Edge Function
> - <QuoteRequestForm/> + page /devis + handler API
> - auth magic link + allowlist .env
> - page /admin/quotes
>
> Validate ✅ : Playwright PASS, RLS audit OK. TODO Phase 2 : Resend SPF.
> ```
>
> *Tu valides ?*

**Oui.**

> Claude (post-commit) :
> *✅ Phase 1 clôturée · commit ab7f2c1 · STATUS à jour*
> *→ /clear puis /plan Phase 2*

(Pas de questions admin de harvest depuis v2.8.1 — l'auto-récap a été écrit en silence dans `memory/learnings/2026-02-12.md`.)

**Total Phase 1 close : ~3 min.**

---

## Phases 2, 3, 4 — résumé compact

Même pattern : `/clear` → `/plan Phase N` → (optionnel `/challenge`) → `/clear` → `/execute` → `/validate` → `/close`.

- **Phase 2** (Admin & PDF, ~2h30) : workflow n8n qualifie + génère PDF, page `/admin/quotes/[id]` avec relecture + envoi
- **Phase 3** (Polish UX, ~1h45) : empty states, toasts, mobile responsiveness
- **Phase 4** (Prod-ready, ~50 min) : SPF/DKIM Resend, monitoring Vercel, page mentions légales

À la fin de Phase 4, `/close` détecte "dernière phase ✅, projet pas shipped" → propose `/livrer`.

---

## Jour 2 — 17h25 — Mise en prod

### Skill 9 — `/livrer`

```
> /livrer
```

Claude lit la section `## Stack` du CLAUDE.md pour détecter Vercel + Supabase + Resend + n8n self-hosted. Confirme la stack, demande :

- URL prod cible : `https://freelancedevis.fr` (déjà acheté via OVH)
- Branche à pusher : `main`
- Smoke test post-deploy : Playwright sur `/devis` + envoi formulaire fictif

> Claude :
> *Checklist policy d'accès BDD (advisory) :*
> *- RLS active sur `quote_requests`, `users` : ✅*
> *- Aucune route API sans auth-check côté serveur : ✅*
> *- Resend domaine `freelancedevis.fr` vérifié : ✅*
> *- Variables d'env Vercel set : ⚠️ `N8N_WEBHOOK_URL` manquant. À ajouter avant push.*

Je vais ajouter la var dans le dashboard Vercel, puis :

> Claude :
> *Push `main` sur GitHub → Vercel rebuild → DNS A record déjà pointé sur Vercel.*
> *Smoke test :*
>    *1. Playwright GET `/devis` → ✅ 200, form rendu*
>    *2. Playwright remplit form + submit → ✅ 200, row en BDD prod*
>    *3. Email Resend reçu sur ma boîte → ✅*
>
> *✅ Mis en prod. URL : https://freelancedevis.fr. STATUS.md mis à jour avec `<!-- ship:url -->https://freelancedevis.fr<!-- /ship:url -->`*.

`/close` final.

**Total /livrer : ~25 min.**

---

## Bilan

**Session totale : ~3h20 cumulées sur 2 jours**, du `claude` initial à `https://freelancedevis.fr` en prod avec form + auth admin + workflow n8n + email + PDF.

**Skills utilisés (ordre chronologique) :** `/start`, `/architect`, `/design`, `/plan Phase 1`, `/challenge`, `/execute`, `/validate`, `/close`, `/livrer`. Plus `/close` après chaque skill produisant un artefact (~6 fois).

**Ce que le kit a fait pour moi :**

- Cadrage en 3 questions au lieu d'un brainstorm vague (`/start`)
- PRD propre + scaffold automatique (`/architect` Étape 6)
- Design system formalisé avant le premier composant (`/design`)
- Plan challengé sur RLS + un risque réel attrapé avant exécution (`/challenge`)
- `/debug` invoqué automatiquement sur la première erreur 500 (Tâche 3)
- `/validate` qui audite la RLS + screenshots Playwright avant de dire OK
- `/livrer` qui vérifie les env vars Vercel avant push

**Ce que je n'ai PAS fait :**

- Pas de "ça compile mais ça marche pas" (chaque tâche a un critère testable de l'extérieur)
- Pas de RLS oubliée (Tâche 1 l'a noté dès le plan, `/challenge` l'a renforcé, `/validate` l'a auditée)
- Pas de session bloquée à chercher "où on en était" (`/prime` lit STATUS.md à chaque reprise jour 2)

**Coût LLM approximatif (Sonnet 4.6, 1M ctx) :** ~30 € sur les 2 sessions cumulées, dont ~40% sur `/execute` Phase 2 (workflow n8n + génération PDF).

---

## Artefacts à explorer dans ce dossier

- [`CLAUDE.md`](CLAUDE.md) — Identité + Stack remplis (post `/start` + `/architect`)
- [`PRD.md`](PRD.md) — Produit final par `/architect`
- [`DESIGN.md`](DESIGN.md) — Design system YAML + 8 sections (post `/design`)
- [`docs/plans/phase-1-plan.md`](docs/plans/phase-1-plan.md) — Plan détaillé Phase 1 (post `/plan` + `/challenge`)

Pour les autres `project_type` (site vitrine ou automation n8n), regarde [`site-vitrine-coach/`](../site-vitrine-coach/) ou [`automation-n8n-veille-rss/`](../automation-n8n-veille-rss/). Le flow reste le même, seuls les artefacts changent (pas de `DESIGN.md` pour site/automation, pas de `phase-N-plan.md` détaillé en niveau LITE).
