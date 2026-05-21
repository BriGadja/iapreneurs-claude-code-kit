# Changelog

> Toutes les versions notables du kit IAPreneurs Claude Code.
> Format inspiré de [Keep a Changelog](https://keepachangelog.com/). Versions [SemVer](https://semver.org/lang/fr/).

## v2.8.3 — 2026-05-21

### Ajouté

- **Tuto narratif "session réelle de A à Z"** : nouveau fichier `examples/webapp-saas-freelance-devis/SESSION.md` qui raconte une session complète, du `claude` initial à la prod, avec les 9 commandes tapées et les sorties LLM abrégées aux essentiels. Durée référence : 3h20 sur 2 jours. Lien depuis le README racine et `examples/README.md`.
- **README — section "Pourquoi ce kit existe" + "Pour qui"** : intro non-débutant-Claude-Code en deuxième position après le titre. Répond à la critique "10 min pour comprendre pourquoi le kit existe". Liste explicitement la cible (freelance solo, entrepreneur no-code, dev junior) et l'anti-cible (équipes 5+, missions courtes).
- **`CONTRIBUTING.md`** : guide de contribution explicite (signature de skills = contrat, non-breaking par défaut, CI verte mandatory, format de commit, domaines où l'aide serait utile). Mitige le bus factor = 1 en ouvrant la porte aux contributeurs externes.

### Pourquoi

Audit externe 2026-05-21 a relevé trois points actionnables : (1) "pas de tuto déroulé complet 'session réelle de A à Z'", (2) README pas grand public, (3) bus factor = 1 sans CONTRIBUTING. Patch documentation pur, zéro impact UX.

### Non-breaking

Aucune signature modifiée, aucun skill touché. Ajout pur de fichiers de doc + intro README + lien depuis examples/README.

---

## v2.8.2 — 2026-05-21

### Ajouté

- **`validate-kit.sh` Check 7 — VERSION cohérent** : vérifie que le fichier `VERSION` racine, et la section `## {version}` la plus récente dans `docs/CHANGELOG.md`, sont alignés. Bloque le merge si désynchronisé.
- **`validate-kit.sh` Check 8 — Soft cap 200L par SKILL.md** : warning informatif (pas bloquant) sur les SKILL.md > 200 lignes. Signal de discipline : invite à extraire le détail vers `references/` lors des prochaines refactos, sans casser la CI en urgence.
- **`validate-kit.sh` Check 9 — Liens markdown internes** : grep tous les liens `](path)` non-HTTP dans `README.md`, `QUICKSTART.md`, `CLAUDE.md.template` et `docs/**/*.md`, vérifie que la cible existe. Détecte les renames non-propagés.

### Modifié

- **Header `validate-kit-v2.sh`** : suppression du marker "v2.1.0" obsolète en commentaire de tête. La version réelle du kit est lue dynamiquement depuis le fichier `VERSION` (ligne 29) — le `-v2` du nom de script réfère à la **génération 2** de la suite de validation (post-refacto Phase 1 v2.7.0), pas au numéro de release. Clarification documentée dans l'en-tête.
- **`README.md` ligne 201** : lien `[CLAUDE.md](CLAUDE.md)` corrigé en `[CLAUDE.md.template](CLAUDE.md.template)`. Le fichier `CLAUDE.md` est gitignored par design (chaque fork génère le sien à partir du template). Désormais détecté par le Check 9.

### Pourquoi

Audit externe 2026-05-21 relevé : header désynchronisé sur `validate-kit-v2.sh` ("on ne triche pas avec sa propre CI"), 6 SKILL.md > 200L sans plafond, 1 lien interne cassé non détecté. Patch hygiène pur tooling, zéro impact UX.

### Non-breaking

- Aucune signature de skill modifiée. Aucune commande retirée.
- Soft cap = warning seulement (ne bloque pas la CI sur les 6 dépassements actuels — ils seront résorbés progressivement).
- Vidéos pédagogiques v2.8.0 restent valides.

---

## v2.8.1 — 2026-05-21

### Modifié

- **`/close` — harvest silencieux par défaut** : suppression des questions ciblées par trigger (ancien 6.2 dans `references/harvest-questions.md`) et de l'annonce "Mémoire mise à jour" (ancien 6.4). Le harvest écrit uniquement l'auto-récap session dans `memory/learnings/{date}.md`, sans interaction. Si l'utilisateur veut explicitement capturer une décision, il le dit en cours de session ("remember X") — `/close` ne le redemande plus à la clôture.
- **`/close` — handoff condensé (3-5 lignes max)** : les trois variantes du bloc final (no-op / planning / full) sont raccourcies. Plus de paragraphe d'explication, plus de récap admin — juste `✅ {état} · {SHA} · {STATUS}` puis la prochaine étape.

### Pourquoi

L'expérience utilisateur du cycle se dégradait à cause du temps passé en clôture (questions admin, récap mémoire long). Le kit doit donner une route claire pour shipper, pas faire passer 5 minutes en boucle externe à chaque feature. Le commit + STATUS.md + gate déploiement Vercel restent intacts (ça produit du résultat) ; seul le harvest interactif est silencé.

### Non-breaking

- Aucune signature de skill modifiée. Aucune commande retirée. Aucune ancre déplacée.
- `/close` reste mandatory après `/validate ✅`. Les vidéos pédagogiques v2.8.0 du kit restent valides — seul le ressenti "rapide" change.
- Forks v2.8.0 peuvent merger v2.8.1 sans casse.

---

## v2.8.0 — 2026-05-21

### Ajouté

- **Fichier `VERSION` racine** : source de vérité unique pour la version du kit. Lu par `scripts/validate-kit-v2.sh` (interpolé dans l'en-tête + verdict final) et référencé par `docs/KIT.md`. Plus de divergence possible entre script et doc.
- **CI GitHub Actions** (`.github/workflows/validate.yml`) : lance `validate-kit.sh` (structure) + `validate-kit-v2.sh` (contenu) à chaque push et PR sur `main`. Régression bloquante désormais détectée automatiquement.
- **`CLAUDE.md.template`** : le template à la racine est désormais nommé `.template` pour distinguer clairement "template du kit" vs "CLAUDE.md rempli pour un projet réel". `/start` copie le template vers `CLAUDE.md` au boot si absent. Le `CLAUDE.md` projet est gitignored par défaut (Brice et auteurs du kit peuvent forcer avec `git add -f` s'ils veulent ship le leur).
- **`QUICKSTART.md` racine** (~30 lignes) : onboarding 60 secondes — 4 étapes pour démarrer + cycle de vie en 6 commandes. Pointe vers `docs/KIT.md` pour approfondir.
- **README route débutant** : section QUICKSTART en première position après le titre, redirection vers `QUICKSTART.md` + `docs/KIT.md`.
- **ADR-001 exemple pédagogique** dans `memory/decisions.md` : un ADR complet avec les 5 sections (Status / Date / Context / Decision / Consequences) montre à quoi un ADR de production ressemble. Marqué "exemple à remplacer".
- **`/brainstorm` refondu — réflexion pure, plus de routing automatique** : Phase A dialogue (3-5 questions) → Phase B recherche (optionnelle) → Phase C synthèse brief `docs/brainstorms/{date}-{slug}.md` → Phase D handoff explicite (utilisateur choisit `/architect`, `/plan`, ou `/evoluer` avec le brief en argument). Plus de détection PRD existe → /evoluer automatique, plus de mot-clé "refonte" → /architect automatique. L'utilisateur garde le contrôle.
- **`/architect` et `/plan` acceptent un brief path en argument** : si un chemin `docs/brainstorms/*.md` est passé, le skill lit le brief et pré-remplit les questions de cadrage au lieu de partir de zéro (pattern déjà éprouvé sur `/evoluer`).

### Modifié

- `scripts/validate-kit-v2.sh` : 17 fails post-refacto Phase 1 v2.7.0 fixés. Les greps suivent désormais la nouvelle structure SKILL.md + references/ (file-list variables `CLOSE_FILES`, `START_FILES`, `LIVRER_FILES`). Verdict 148/148 PASS restauré.
- `docs/KIT.md` ligne 3 : version pointe vers fichier `VERSION` racine au lieu d'une string hardcodée.
- `.claude/skills/architect/SKILL.md` : suppression du bloc legacy `## Format du PRD` v2.1.x (Sommaire / MVP / Hors-MVP / Phases) qui contredisait silencieusement le format v2.2 (8 sections). Redirige vers `templates/PRD-template.md` comme source unique.
- Descriptions frontmatter slim :
  - `/start` : 90 mots → < 50 mots (énonce uniquement *quand utiliser*, jamais *comment* — règle CSO)
  - `/close` : 118 mots → < 50 mots (idem)

### Pourquoi

Audit externe livré 2026-05-21 a relevé :
1. CI rouge (validate-kit-v2.sh 131/148 sur main) — régression introduite par refacto Phase 1 v2.7.0 qui externalisait du contenu en `references/` sans router les greps.
2. Divergence versions (KIT.md v2.6.0, script v2.5.2, tag v2.7.0) — pas de source unique.
3. `architect/SKILL.md` contenait le format PRD v2.1.x en doublon avec v2.2.
4. Descriptions `/start` et `/close` dépassaient le cap Anthropic 50 mots et leak des steps de workflow.
5. `/brainstorm` auto-routait via mot-clé "refonte" non-documenté.
6. Onboarding initial : un débutant qui clone le repo ne savait pas par où commencer.

v2.8.0 résout ces 6 points en une release cohérente, sans toucher à l'UX des skills filmés (`/start`, `/architect`, `/plan`, `/execute`, `/validate`, `/close`, `/livrer`, `/evoluer`).

### Inchangé

- Toutes les questions utilisateur des skills `/start /architect /plan /execute /validate /close /livrer /evoluer` (Vidéos tournées : zéro régression UX).
- Format PRD (templates/PRD-template.md), format SPEC, format ADR, format plan.
- Cycle de vie documenté et tous les invariants structurels.

## v2.7.0 — 2026-05-20

### Ajouté

- **Refacto Phase 1 — externalisation références skills longs** (`ef42200`, `c17d33e`, `91d8013`) : `/start`, `/close`, `/livrer` chacun gardent un SKILL.md slim (workflow) et déportent les procédures détaillées en `references/*.md` (Vercel, Cloudflare, Netlify, OVH/Gandi/Cloudflare/Hostinger, bootstrap fresh clone, audit-caps, harvest-questions, etc.). Économie de contexte : Claude ne charge les references qu'à la demande.
- **Browser-verifier agent** (`7686ed8`) : sous-agent dédié à la vérification visuelle webapp via Playwright MCP. Délégué proactivement.
- **Délégation browser-verifier dans `/execute /validate /livrer`** (`f1b85a8`) : ces 3 skills appellent le sous-agent au lieu de manipuler Playwright directement, économise du contexte sur la session principale.
- **`scripts/validate-kit.sh`** (`5f12553`) : lint structurel complémentaire à validate-kit-v2.sh — vérifie ancres HTML appariées, handoff `**Prochaine étape**:` terminal, cap descriptions frontmatter (soft 100 / hard 120 mots), `.mcp.json` gitignored, cross-refs `/skill Étape N` cohérentes.

### Corrigé

- **Incohérence install n8n** (`38501cf`) : `.claude/rules/n8n-setup.md` clarifié — installation API-connected par défaut, `.mcp.json` gitignored avec valeurs en clair (Claude Code ne source pas `.env` automatiquement). Stop aux pièges récurrents shell parent / `${VAR}`.

### Pourquoi

Les SKILL.md grossissaient. Browser-verifier capitalise sur la vérification visuelle. validate-kit.sh complète validate-kit-v2.sh (structure vs contenu). L'install n8n laissait passer trop de pièges.

## v2.6.0 — 2026-05-19

### Ajouté

- `/evoluer` **Étape 4bis — Détection capacités techniques nouvelles (MCP / setup)** ajoutée entre l'Étape 4 (calcul `V_{n+1}`) et l'Étape 5 (écriture atomique) :
  - Analyse LLM des 3 questions de cadrage (nom + description + critère de succès) vs Stack courante (`CLAUDE.md ## Stack`) et `.mcp.json` actuel
  - Table d'heuristiques mots-clés → capacités : **n8n** (workflow async, webhook + traitement long, intégrations multiples), **Google Drive** (archive perso, dossier client freelance), **Stripe** (paiement, abonnement), **Email transactionnel** (Resend/SendGrid)
  - Vérification déterministe d'absence via `grep` sur `.mcp.json`, `.env.example`, `CLAUDE.md ## n8n`
  - 3 options posées à l'utilisateur en cas de capacité absente : **installer maintenant** (lance la procédure) / **déjà installé ailleurs** (flag dans SPEC Considerations) / **pas besoin, reformule** (boucle Étape 2)
  - Pour n8n : exécute `.claude/rules/n8n-setup.md` (5 étapes existantes : install MCP + copie 7 skills czlonkowski + crée `.claude/rules/n8n.md` + active `## n8n` dans `CLAUDE.md` + health_check), note commit SHA + version MCP dans le SPEC
  - Pour autres MCP : ajout `.mcp.json` + `.env.example` selon pattern `${VAR}` (jamais de secret en clair)
  - **Commit intermédiaire séparé** `chore(/evoluer): install {capacité} prérequis pour feature {nom}` avant le commit feature → rollback granulaire possible
  - Idempotent : skip silencieux si déjà installée
- `.claude/rules/n8n-setup.md` : première ligne élargie pour autoriser deux cas d'invocation — (1) `/start` Q4 sur projet neuf, (2) `/evoluer` Étape 4bis sur projet existant

### Pourquoi

Scénario typique débloqué : projet `site` ou `webapp` démarré sans n8n (`/start` Q4 = non). Plus tard, le membre veut greffer un workflow async (envoi PDF + archive Drive + email). Avant v2.6.0 : `/evoluer` écrivait le SPEC, `/plan` planifiait, `/execute` crashait à la 1re commande `mcp__n8n-mcp__*` parce que le MCP n'était pas dans `.mcp.json`. v2.6.0 ramène le projet dans un état cohérent **avant** que le SPEC ne référence ces capacités, et matérialise la mise en pratique du cycle de vie kit mode "maintenance" dans la 5.2 du module.

### Inchangé

- Comportement standard (Branche 1 PRD v2.2) hors Étape 4bis : strictement inchangé
- Mode legacy (Branche 2 PRD v2.1.x) : strictement inchangé (pas d'Étape 4bis appliquée)
- Procédure `n8n-setup.md` elle-même : 5 étapes inchangées, juste élargissement des cas d'invocation
- `validate-kit-v2.sh` : 148/148 PASS préservé

## v2.5.2 — 2026-05-18

### Ajouté

- `/livrer` **Étape 1.3 — Confirmation stack (recommandation, JAMAIS imposition)** ajoutée en tête de skill (avant Étape 2 pré-checks) :
  - Énonce explicitement la stack recommandée par défaut module Claude Code IAPreneurs : **GitHub** (code) + **Vercel** (hosting) + **OVH** (registrar) — avec justifications (FR, retours communauté)
  - 4 options en Cas A (stack vide/ambiguë) : tout accepter / changer hosting / changer registrar / tout changer
  - Cas B (stack déjà renseignée) : confirmation rapide 1 question avec défaut "garder"
  - Routing déterministe : la stack confirmée détermine quelle branche d'Étape 3 (Vercel/Netlify/Cloudflare) et d'Étape 3.5 (OVH/Gandi/Cloudflare/Hostinger) sera déroulée ensuite
  - Test du miroir renforcé : le skill ne peut pas proposer une commande Vercel sans avoir explicitement obtenu confirmation de l'utilisateur en 1.3
- Étape 1.2 : ligne **Registrar domaine** ajoutée dans les éléments à extraire de `## Stack` (au même titre que hosting/BDD/email)

### Pourquoi

Retour utilisateur : "Vercel semblait imposé par le skill, je voudrais que ce soit recommandé pas imposé". Le skill lisait bien `## Stack` mais ne re-confirmait pas explicitement avant de plonger dans le flow Vercel — donnait l'impression d'un défaut imposé. v2.5.2 ajoute une question explicite "OK avec la stack recommandée ?" en tête de skill, qui peut router vers n'importe quel autre hosting/registrar choisi par l'utilisateur.

### Inchangé

- Toutes les autres étapes (3.V.x onboarding, 3.5 domaine custom, 4 smoke test, 5 ## Production) sont préservées
- Routes Netlify / Cloudflare / GitHub Pages / n8n : strictement inchangées
- Règle Dashboard vs CLI (v2.5.0) et fix OAuth inline (v2.5.1) préservés

## v2.5.1 — 2026-05-18

### Corrigé

- `/livrer` route Vercel onboarding : **suppression de l'étape standalone "Install Vercel GitHub App"** (https://vercel.com/integrations/github). Cette étape était une friction inutile et présentait l'install comme une démarche "third-party" alors que c'est la connexion OAuth classique GitHub ↔ Vercel.
- Refonte UX : la connexion GitHub ↔ Vercel se fait désormais **inline pendant l'import du projet** sur `https://vercel.com/new` :
  - 1ère fois : Vercel propose "Continue with GitHub" ou "Configure GitHub App" dans la même page d'import (écran OAuth GitHub standard)
  - Sessions suivantes : repos directement listés
  - Si un repo manque dans la liste : lien **"Adjust GitHub App Permissions"** disponible inline (toujours dans la page d'import, pas de détour)
- Renumérotation : étapes 5-9 deviennent étapes 5-8 (passage 9 étapes → 8 étapes onboarding)

### Inchangé

- Tous les autres aspects v2.5.0 (règle Dashboard vs CLI, marqueurs `git ls-remote` + `ship:url`, env vars 2 options, etc.) sont préservés
- Routes Netlify / Cloudflare / GitHub Pages / n8n : strictement inchangées
- Étape 3.5 (Domaine custom) : inchangée

## v2.5.0 — 2026-05-18

### Ajouté

- `/livrer` route Vercel — **règle explicite Dashboard vs CLI** ajoutée en tête de section :
  - **Dashboard web obligatoire** : création de compte (GitHub, Vercel), création du repo GitHub (github.com/new), création/import du projet Vercel (vercel.com/new) — raisons pédagogiques (l'utilisateur voit où se passent les choses)
  - **CLI OK pour l'automatisation non-interactive** : `gh api user` (auth check), `gh auth login --web`, `git remote add` / `git push`, `vercel link` (linker projet déjà créé via Dashboard), `vercel env add`, etc.
  - **CLI interdite** pour : `gh repo create` (visuel sur github.com/new) et l'import projet Vercel (visuel sur vercel.com/new)

### Modifié (route Vercel onboarding refondée — 9 étapes au lieu de 9 dans la v2.3.0, mais structure différente)

- **Étape 4 (création repo GitHub)** : remplace `gh repo create --source . --push` par flow Dashboard github.com/new + paste URL HTTPS + `git remote add origin` + `git push` (git natif uniquement)
- **Étape 7 (création projet Vercel)** : remplace `vercel link --yes` par flow Dashboard vercel.com/new → Import Git Repository → Configure Project. L'auto-deploy se fait ensuite via GitHub App webhook au prochain `git push`
- **Étape 8 (env vars)** : présente 2 options — Option A Dashboard (recommandé 1ère fois, visuel) / Option B CLI `vercel env add` / `vercel env pull` (automation possible une fois le projet créé)
- **Étape 2 (check auth GitHub)** : conservé via `gh api user` (automation OK)
- **Détection 3 marqueurs (Étape 3.V.0)** : marqueur #2 utilise désormais `git ls-remote origin HEAD` (git natif) au lieu de `gh repo view` ; marqueur #3 utilise `<!-- ship:url -->` rempli dans CLAUDE.md (au lieu de `.vercel/project.json` qui n'existe qu'avec `vercel link`)
- **Power-users fallback HTML** : clarifie que la CLI Vercel est *entièrement optionnelle* — le flow par défaut suit la règle Dashboard/CLI ci-dessus

### Inchangé (intentionnel)

- Étape 3.V.2 fast path (`route_vercel_push`) : toujours pur `git push` — aucun changement
- Étape 3.5 (Domaine custom v2.4.0) : flow Dashboard Vercel + DNS registrar préservé, mention `vercel domains add` reformulée comme automation OK (post-création projet)
- Routes Netlify / Cloudflare / GitHub Pages / n8n : strictement inchangées

## v2.4.0 — 2026-05-18

### Ajouté

- `/livrer` **Étape 3.5 — Domaine custom (advisory, opt-out)** entre Étape 3 (deploy) et Étape 4 (smoke test) :
  - Question d'entrée 3 options : sous-domaine d'un domaine existant / domaine racine fraîchement acheté / garder URL hosting par défaut (skip direct)
  - Registrar-aware : **OVH** (recommandé module Claude Code IAPreneurs), **Gandi**, **Cloudflare**, **Hostinger**, **Autre** (pattern générique)
  - Distinction sous-domaine (CNAME, simple) vs apex (A records, plus complexe — OVH ne supporte pas ALIAS/ANAME)
  - Gotcha OVH "point final obligatoire sur la cible CNAME" explicité
  - Gotcha Cloudflare "Proxy DNS only (nuage gris, pas orange)" explicité (sinon SSL Vercel pète)
  - Mode attente active : `dig +short` poll 30s × max 10 min jusqu'à résolution DNS détectée
  - Mode skip : marquer `⏳ DNS pending` dans `## Production`, smoke test sur fallback hosting
  - SSL Let's Encrypt automatique mentionné (Vercel émet dès propagation DNS)
- `/livrer` Étape 4 (smoke test) : choix URL cible automatique (custom si propagée, fallback sinon) + warning DNS pending
- `/livrer` Étape 5 (## Production) : bloc enrichi en cas de domaine custom (URL prod custom + URL fallback hosting + ligne DNS détaillée registrar/type/target)
- `scripts/validate-kit-v2.sh` : Scénario K (6 checks couvrant Étape 3.5 + Étapes 4/5 adaptées)

### Modifié

- `/livrer` frontmatter `description:` : mention de la nouvelle config domaine custom registrar-aware

### Inchangé (intentionnel)

- Étape 3 (deploy) inchangée — l'Étape 3.5 vient strictement après le deploy réussi
- Routes hosting non-Vercel (Netlify/Cloudflare/GitHub Pages) : flow par défaut intact, le bloc 3.5.3 documente un placeholder "TODO" pour le hosting-side (à remplir au fil des livraisons réelles)
- Pas de breaking change : projets v2.3.0 conservent leur ## Production existant (Cas A reste compatible)

## v2.3.0 — 2026-05-18

### Ajouté

- `/livrer` route Vercel refondue : flow par défaut **GitHub→Vercel auto-deploy** (push = deploy)
- `/livrer` détecte 3 marqueurs d'état (remote github, repo existe sur GitHub, `.vercel/project.json`) pour router automatiquement entre onboarding guidé et fast path push
- `/close` Étape 6.5 conditionnelle : propose gate déploiement (`commit only` / `push main = deploy prod` / `push branche = preview`) si Vercel lié + commits non-pushés + `project_type` ∈ {webapp, site}
- Warning Vercel Hobby = non-commercial affiché **AVANT** tout setup (anti-piège pour prestations clients €1500+)
- `scripts/validate-kit-v2.sh` : Scénario J (9 checks couvrant la nouvelle logique /livrer + /close)

### Modifié

- `/livrer` ne présente plus `vercel --prod` CLI par défaut (conservé en commentaire HTML `<!-- power-users-fallback -->` pour utilisateurs avancés)
- Check auth GitHub via `gh api user` au lieu de `gh auth status` (régression connue sur certaines versions retournant exit 0 même en échec)
- Étape 4 (smoke test) : retry HTTP 60s × 2 si build Vercel pas encore terminé (502/504/404 transient)

### Inchangé (intentionnel)

- Routes Netlify, Cloudflare Pages, GitHub Pages, n8n automation strictement inchangées
- Template `CLAUDE.md`, ancres, 3 examples — aucun breaking change pour projets v2.0.0+

## v2.2.0 — 2026-05-14

### Ajouté (3 modifications structurelles bundle)

**1. n8n MCP opt-in**

- Collection `czlonkowski` bundled retirée (`.claude/skills/n8n/` supprimé)
- Nouveau fichier `.claude/rules/n8n-setup.md` : procédure 5-étapes pour installer le MCP n8n à la demande, lit upstream `github.com/czlonkowski/n8n-mcp/README.md` + embarque le prompt opérationnel (Core Principles, 8-step workflow, validation 4-levels, Top 20 nodes — snapshot 2026-05-14)
- `/start` Étape 3 : nouvelle Q4 booléenne `project_uses_n8n`. Si oui → exécute `n8n-setup.md`. Si non → skip entièrement.
- Placeholder `<!-- n8n-section -->` dans CLAUDE.md template, décommenté par n8n-setup.md à l'install.

**2. Structure projet pour évolutions (PRD vivant discipliné)**

- **PRD 8 sections** (Vision / Personas / Scope actuel V_n / Hors scope / Constraints / Success Criteria / Implementation Phases / Risks & Mitigations) cap 100 lignes. Templates dans `templates/PRD-template.md` + `templates/SPEC-template.md`.
- **`docs/specs/SPEC-{date}-{slug}.md`** : un SPEC par évolution post-livraison. Format 4 sections (Feature / Examples / Documentation / Considerations). Frozen post-/execute via header `<!-- frozen: {date} -->`.
- **`memory/decisions.md` format ADR numéroté** : ADR-NNN avec Status / Date / Context / Decision / Consequences. `/architect` init ADR-001 fondateur. `/evoluer` append ADR à chaque choix architectural significatif.
- **`/evoluer` cérémonie distincte** : lit PRD + STRUCTURE + decisions + 3 derniers SPECs + STATUS. Crée SPEC daté + déplace checkbox Hors scope → Scope actuel + append Implementation Phases V_n+1 + gate `/validate` obligatoire AVANT handoff. Atomicité git via checkpoint après création SPEC.
- **`/prime` adaptatif maintenance/création** : Étape 0.5 détecte `mode` via `count(docs/specs/SPEC-*.md)`. Maintenance → lit aussi decisions + 3 derniers SPECs. Affiche le mode dans la synthèse Étape 5.
- **`/close` Étape 0.6 audit caps** : warn (pas bloquer) si CLAUDE.md > 200L ou PRD.md > 100L. Acknowledged flag `.claude/cache/close-cap-acknowledged.json` anti-spam re-prompt.
- **`/architect` Étape DISCOVER + ANALYZE** (pattern DISCOVER+ANALYZE) : si codebase non-vide, scan stack/patterns existants et enrichit `<!-- architect:stack -->` + `<!-- architect:patterns -->`.
- **STRUCTURE.md +3 ancres** : `<!-- structure:integrations -->`, `<!-- structure:key-files -->`, `<!-- structure:evolutions-summary -->` (maintenues par /architect + /evoluer).
- **`/plan` Étape 4.5 option G/W/T** : si Request Classification ≥ STANDARD ET project_type == webapp, propose user stories Given/When/Then en plus des tâches techniques.
- **`/execute` Étape 2 Golden rule** : validation post-task obligatoire (PAS batched), formalisée comme règle stricte.

**3. Vidéos pédagogie**

- Sommaire IAPreneurs v5 et plan Hub Documents séquencés pour défer n8n à 5.2 et intégrer `/design` dans 5.1 (modification externe, hors repo kit).

### Modifié (layout)

- `examples/webapp-saas-freelance-devis/phase-1-plan.md` → `docs/plans/phase-1-plan.md` (correction incohérence convention `docs/plans/` v2.1.0).
- Les 3 PRD examples migrés au nouveau format 8 sections (cap 100L).
- Nouveau SPEC simulé `examples/webapp-saas-freelance-devis/docs/specs/SPEC-2026-08-12-export-pdf-devis.md` (montre le pattern évolution post-livraison).

### Breaking change

- **Format PRD 7 → 8 sections** : ancien `## Phases` remplacé par `## 7. Implementation Phases` + ajout `## 3. Scope actuel (V_n)` + `## 4. Hors scope (différé)`.
- **Mitigation** : adaptateur format legacy v2.1.x dans `/evoluer` + `/prime` + `/close` (4 branches déterministes : nouveau / ancien / mixte (safe abort) / malformé (safe abort)).
- **Migration guide** : voir `docs/MIGRATION-v2.1-to-v2.2.md` (~30 lignes).

### Nouveaux fichiers

- `templates/PRD-template.md` (8 sections)
- `templates/SPEC-template.md` (4 sections)
- `.claude/rules/n8n-setup.md` (procédure install à la demande + prompt opérationnel czlonkowski embarqué)
- `docs/MIGRATION-v2.1-to-v2.2.md` (guide migration format PRD)

### Validation

- `scripts/validate-kit-v2.sh` Scénario I ajouté (~17 nouveaux checks). Total ≥ 90 checks.

---

## v2.1.0 — 2026-05-13

### Renommé
- L'ancien skill *recap* (v2.0.x) est devenu `/prime` (description élargie : rituel d'entrée de session, pas seulement post-absence)

### Ajouté
- **`STRUCTURE.md`** : carte d'architecture du projet, écrite par `/architect` Étape 6.5, lue par `/prime`. Adaptée selon `project_type` (webapp/site/automation). 4 ancres : `<!-- architect:directories -->`, `<!-- architect:patterns -->`, `<!-- architect:tests -->`, `<!-- architect:conventions -->`.
- **`/architect` Étape 6.5** : génération STRUCTURE.md initial après scaffold, avec templates par `project_type`.
- **`/prime` Étape 1.5** : lecture STRUCTURE.md si présent (mode dégradé sinon) + section "Architecture" dans la synthèse Étape 5.
- **STRUCTURE.md dans les 3 examples** du kit (`site-vitrine-coach`, `webapp-saas-freelance-devis`, `automation-n8n-veille-rss`).
- **Vocabulaire "boucle interne / boucle externe"** dans CLAUDE.md règle 6 et `/close` SKILL.md. Boucle interne = PIV (`/prime → /plan → /execute → /validate → /close`) sur une feature. Boucle externe = corriger le système qui a laissé passer un bug (règle, étape de skill, assertion validate-kit).
- **Rituel PIV explicite** (`/prime → /plan → /execute → /validate → /close`) dans CLAUDE.md, mis en évidence en haut du template.
- **Convention `docs/{type}/`** : les outputs des skills (plans, brainstorms) vivent désormais dans `docs/plans/` et `docs/brainstorms/` au lieu de la racine. Documentation dans la nouvelle section `## Où vivent les fichiers` de CLAUDE.md.

### Modifié (layout)
- `/plan` écrit `docs/plans/phase-N-plan.md` (au lieu de racine), avec `mkdir -p docs/plans` au début.
- `/brainstorm` écrit `docs/brainstorms/{YYYY-MM-DD}-{sujet}.md` (au lieu de `brainstorm-{sujet}.md` racine), avec `mkdir -p docs/brainstorms` au début. Préfixe date pour tri chronologique.
- `/prime`, `/execute`, `/validate`, `/challenge`, `/evoluer`, `/close`, `/start` lisent depuis `docs/plans/` avec **fallback compatibilité** vers `plans/` puis racine (projets pré-v2.1.0 continuent à marcher).

### Validation
- **Scénarios D/E/F/G** ajoutés à `scripts/validate-kit-v2.sh` (>= 55 checks total au lieu de 44). Scénario D mis à jour (prime au lieu de recap), Scénario E = STRUCTURE.md, Scénario F = BONUS pédagogiques (vocab + PIV + anti-leak D9), Scénario G = docs/{type}/ layout.

### Migration depuis v2.0.0
Aucune action utilisateur requise pour projets pré-v2.1.0 :
- L'ancien skill *recap* est renommé en `/prime` — anciens projets continuent à fonctionner, juste taper `/prime` au lieu de l'ancien nom.
- `STRUCTURE.md` est optionnel — `/prime` fonctionne en mode dégradé sans (juste pas de section "Architecture" dans la synthèse).
- Plans existants à la racine ou dans `plans/` continuent d'être lus (fallback). Pour une organisation propre, déplacer manuellement vers `docs/plans/` (ou laisser tel quel — pas bloquant).

---

## [v2.0.0] — 2026-05-12

> **Statut** : GA — validation script-driven `scripts/validate-kit-v2.sh` = 44/44 PASS. Voir `docs/VALIDATION-SCENARIOS-V2.md`.

> **Refonte majeure** : passage d'un squelette spec-driven web-app-centric à un **framework guidé complet** couvrant tout le cycle de vie d'un projet pour **3 cas d'usage** (site / webapp / automation).

### Breaking changes

- Nouvelle variable `project_type` ∈ `{site, webapp, automation}` requise dans `<!-- start:identité -->` du `CLAUDE.md` template. Forks v1.x sont migrés automatiquement par `/start` (question one-shot, pas de cascade-block).
- `/close` n'est plus optionnel — devient **mandatory** post `/validate ✅`. La source unique pour marquer ✅ Terminée dans le PRD passe de `/execute` à `/close` (résout doublon).
- Nouvelles ancres HTML dans `CLAUDE.md` template : `<!-- design:summary -->` (écrit par `/design`) et `<!-- ship:url -->` (écrit par `/ship`).

### Ajouté

- **3 nouveaux skills (noms FR pour cohérence communauté IAPreneurs)** :
  - `/prime` — reprendre un projet existant après absence (lit PRD/plans/git log)
  - `/livrer` — déployer en production en lisant `## Stack` du CLAUDE.md (jamais hardcode de provider — Vercel/Netlify/Cloudflare/GitHub Pages/autre détectés depuis stack) + checklist policy d'accès BDD advisory + smoke test
  - `/evoluer` — ajouter une feature à un projet livré sans écraser le PRD

**Skills envisagés puis droppés** (décision D26 mid-execute, "less is more") :
- `/troubleshoot` → remplacé par `/debug` (built-in Claude Code natif) + règle de comportement TDD dans CLAUDE.md (test de régression avant fix)
- `/remember` → remplacé par édition manuelle de `memory/topics/{topic}.md` (skill trop léger pour mériter un slot)
- **Mémoire persistante** : structure `memory/{learnings,topics}/` + `memory/decisions.md` + `MEMORY.md` index à la racine. Le kit apprend du projet au fil des sessions. **Tout est écrit par `/close`** post-commit (auto-récap session dans `learnings/` + 3 questions ciblées opt-in : décision arch ? gotcha ? pattern ? → écrit dans `topics/{domaine}.md` ou `decisions.md`). `/start` et `/prime` lisent `MEMORY.md` au démarrage et affichent le résumé. **L'utilisateur ne touche jamais à la mémoire manuellement.**
- **3 examples par `project_type`** : `examples/site-vitrine-coach/`, `examples/webapp-saas-freelance-devis/`, `examples/automation-n8n-veille-rss/`.
- **Request Classification LITE / STANDARD / FULL** dans `CLAUDE.md` template (proposée par `/start` Phase 4).
- **Règle de comportement #6 — Auto-évaluation** dans CLAUDE.md template : tu ne dis jamais "done" sans avoir vérifié programmatiquement ou visuellement. Pour webapp + modif UI → Playwright MCP (navigate + snapshot/screenshot dans `tmp/`). Pour automation + workflow → exécution réelle via MCP. Pour API → curl. Pour BDD → query directe. Si tu ne peux pas raconter exactement ce que tu as vérifié, tu n'as pas auto-évalué.
- **Dossier `tmp/`** (gitignored sauf `.gitkeep`) créé par défaut dans le kit : destination des screenshots Playwright, dumps debug, outputs intermédiaires. Skills `/validate` et `/livrer` y enregistrent leurs artefacts temporaires.
- **Glossaire** (4 termes : Phase / Tâche / Critère "Fait quand" / Critères de succès) en intro du `CLAUDE.md` template.
- **README enrichi** : 3 diagrammes de parcours (création / reprise / évolution) + table 12 skills (hard cap) + section "Quel example regarder ?".
- **`docs/CHANGELOG.md`** : ce fichier (historique rétroactif v1.0 → v2.0).

### Modifié

- `/start` détecte projet existant et bifurque vers `/prime` (au lieu de toujours faire l'onboarding). Migration v1.x → v2.0 transparente.
- `/architect` étendu avec **Étape 6 — Provisioning & Scaffold** (scaffold le repo selon `project_type` + provisioning Supabase/Vercel/n8n + écriture `.env`). Décision D25 : fold de l'ancien `/scaffold` envisagé puis dropped — `architect` définit le projet end-to-end, scaffolding est Phase 1 du PRD donc redondant comme skill séparé. Handoff route vers `/design` (si webapp) puis `/plan Phase 1`.
- `/architect` route aussi vers `/evolve` pour modifications de PRD existant.
- `/validate` handoff → `/close` (mandatory), plus de skip optionnel.
- `/close` enrichi : harvest learnings post-commit + handoff vers `/ship` si projet jamais shippé.
- `/plan` adapte ses questions selon `project_type` (automation = retire web-app-centric, ajoute credentials externes).
- `/execute` ne marque plus ✅ Terminée dans PRD (responsabilité déplacée à `/close`).

### Retiré

- Mentions de **Dipler** dans le kit public (règle IAPreneurs : voice agents = **Vapi** dans la communauté, jamais Dipler).

### Méthode

- Plan : `plans/iapreneurs-kit-framework-guide-refonte.md` (8 phases A-H, 24 décisions arch, 4 rounds challenge, trajectoire BLOCKING 6→5→2→0)
- Recherche : `research/plan/2026-05-12-iapreneurs-kit-framework-guide-refonte.md` (3 agents : audit interne / scout externe / critique pédagogique)

---

## [v1.5.0] — 2026-05-12

### Ajouté
- `/close` skill : marque ✅ Terminée dans PRD + commit conventionnel + suggestion phase suivante
- Audit RLS Supabase intégré dans `/validate` (option D) pour projets avec données clients
- Propagation de la section `## Stack` du `CLAUDE.md` après `/architect`
- Examples enrichis : `examples/freelance-devis/CLAUDE.md`

### Modifié
- Documentation README alignée sur l'inventaire complet v1.5

---

## [v1.4.0] — 2026-05-08

### Modifié — Breaking
- `/design` skill aligné sur la **spec officielle Google open-source** `DESIGN.md` (version alpha, publiée par Stitch — `stitch.withgoogle.com`)
- Format YAML front matter avec tokens (`colors`, `typography`, `rounded`, `spacing`, `components`) + 8 sections markdown canoniques
- Lint optionnel : `npx @google/design.md lint DESIGN.md`
- Template fourni dans `.claude/skills/design/template.md`

---

## [v1.3.0] — 2026-04-30

### Ajouté
- `/design` skill — produit `DESIGN.md` consommé par le plugin Anthropic `frontend-design`
- Division du travail clarifiée : `/design` = architecte (système 1x), `/frontend-design` = constructeur (composants à chaque création UI)

---

## [v1.2.0] — 2026-04-20

### Modifié — Breaking
- Rename `/create-prd` → `/architect` (produit toujours `PRD.md`, plus clair sémantiquement)

---

## [v1.1.0] — 2026-04-10

### Ajouté
- `/start` onboarding skill (5 phases : visite + cadrage + credentials + outillage + routage)
- Sécurité credentials : `.env` pattern Anthropic-officiel + `.mcp.json` avec syntaxe `${VAR}`
- `.gitignore` durci sur `.env`, `.env.local`, `.env.*.local`, `.envrc`
- Path-scoped rules `.claude/rules/` avec frontmatter `paths:` + exemple `frontend.md`
- Sous-agent `research-delegate` (read-only) invoqué automatiquement par `/brainstorm`, `/plan`, `/execute`, `/validate`
- `/challenge` skill (devil's advocate optionnel)

---

## [v1.0.0] — 2026-04-01

### Ajouté
- 5 skills core conversationnels : `/brainstorm`, `/create-prd` (renommé en `/architect` v1.2), `/plan`, `/execute`, `/validate`
- 7 skills officiels [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT) dans `.claude/skills/n8n/`
- Template `CLAUDE.md` 5 couches (Identité / Stack / Conventions / Instructions / Contexte métier) + 4 règles de comportement + ancres HTML
- `.mcp.json` scaffolding (Playwright, n8n, plugin frontend-design)
- `.env.example` avec placeholders pour n8n, Anthropic SDK, Supabase, Resend
- LICENSE MIT
- README initial avec quickstart

[v2.0.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/compare/v1.5.0...HEAD
[v1.5.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.5.0
[v1.4.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.4.0
[v1.3.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.3.0
[v1.2.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.2.0
[v1.1.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.1.0
[v1.0.0]: https://github.com/BriGadja/iapreneurs-claude-code-kit/releases/tag/v1.0.0
