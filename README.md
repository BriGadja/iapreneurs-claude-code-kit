# IAPreneurs Claude Code Kit

> Le kit de démarrage **Claude Code** des membres IAPreneurs. Forke-le, configure ton `CLAUDE.md`, et tu codes en quelques minutes avec une méthode propre — même si tu n'as jamais codé avant.

## Ce que tu récupères

Un dossier `.claude/` prêt à l'emploi avec :

- **`/start`** — skill d'onboarding piloté : cadrage projet en 3 questions, sécurisation des credentials (`.env` + `.mcp.json` avec `${VAR}`), vérification de l'outillage (Playwright + n8n MCP + plugin frontend-design), puis routage vers le bon skill suivant.
- **5 skills core** qui couvrent le cycle complet d'un projet : clarifier une idée → produire un PRD → planifier une phase → exécuter → vérifier.
- **1 skill optionnelle** `/challenge` — devil's advocate sur le plan avant `/execute` (à activer dans ton workflow quand tu te sens à l'aise).
- **1 sous-agent** `research-delegate` — invoqué automatiquement par les skills core pour la recherche (codebase + web), garde ta fenêtre de contexte propre.
- **7 skills n8n officiels** (MIT, czlonkowski) pour t'aider à construire et debugger des workflows n8n sans halluciner les nodes.
- **`.claude/rules/`** — règles path-scoped auto-chargées (exemple `frontend.md`) pour garder le `CLAUDE.md` court.
- **Un `CLAUDE.md` template** à adapter à ton projet (5 couches + 4 règles de comportement Karpathy + section "Comment ce CLAUDE.md est entretenu" qui explique le séquencement des skills et la déportation vers `.claude/rules/`).
- **Un `.mcp.json` vide + `.env.example`** — scaffolding pour ajouter Playwright, n8n MCP, plugin frontend-design avec sécurisation des credentials (`/start` te guide).

Tu forks, tu adaptes, tu codes. C'est la méthode utilisée dans le module Claude Code IAPreneurs.

> ℹ️ **Note gouvernance** : ce repo est sous le compte perso `BriGadja`, pas sous l'organisation IAPreneurs. C'est un projet pédagogique perso, pas un asset officiel co-géré par la communauté. Yassine est au courant, on garde la flexibilité de migrer vers une orga `iapreneurs-cc` plus tard si besoin.

## Comment l'utiliser

```bash
# 1. Forker ce repo (bouton "Fork" en haut à droite sur GitHub)
# 2. Cloner ton fork
git clone https://github.com/TON-USERNAME/iapreneurs-claude-code-kit.git
cd iapreneurs-claude-code-kit

# 3. Lancer Claude Code dedans
claude
```

Premier réflexe : tape **`/start`**. Le skill te guide en 5 phases (visite kit, 3 questions de cadrage, sécurisation `.env`, vérif MCP/plugin, routage). Sortie : `CLAUDE.md` partiellement rempli + outillage testé + bon prochain skill suggéré.

```
/start
```

Tu peux aussi attaquer directement si tu veux :

```
/brainstorm une app pour gérer mes recettes de cuisine
```

Et c'est parti.

## Ce qu'il y a dans le kit

### `.claude/skills/` — les 7 skills (entrée `/start` + 5 core + 1 optionnelle)

| Skill | Rôle |
|-------|------|
| `/start` | **Point d'entrée**. Visite kit (skippable), 3 questions de cadrage (Identité du `CLAUDE.md`), sécurisation credentials (`.env` + `.gitignore` + `.mcp.json` avec `${VAR}`), vérif outillage (Playwright + n8n MCP + plugin frontend-design), routage vers `/brainstorm` ou `/create-prd`. À invoquer 1x à l'ouverture. |
| `/brainstorm` | Tu n'as qu'une idée vague. 3 questions et tu repars avec un fichier `brainstorm-{sujet}.md` qui clarifie ce que tu veux. Route 2 délègue à `research-delegate` pour explorer projets similaires. |
| `/create-prd` | À partir du brainstorm, génère un Product Requirements Document structuré (sommaire / utilisateurs / MVP / phases / stack / critères de succès). Écrit la section `## Stack` du `CLAUDE.md`. |
| `/plan` | Prend une phase du PRD et la découpe en tâches numérotées avec critères "Fait quand" vérifiables. 8 tâches max par phase. Étape 1bis scout le codebase via `research-delegate` pour éviter les doublons. |
| `/challenge` *(optionnel)* | Passe le plan au crible avant `/execute` : 3 risques + 3 hypothèses non vérifiées + verdict GO/REWORK/STOP. À ajouter dans ton workflow quand tu sens que `/plan` seul te laisse partir avec des angles morts. |
| `/execute` | Exécute les tâches une par une. Coche les cases au fur et à mesure. Marque la phase ✅ Terminée dans le PRD parent. Délègue à `research-delegate` si bloqué par un manque d'info externe. |
| `/validate` | Propose 3 options de validation (web → Playwright, n8n → test exécution, autre → demande). Verdict réel, jamais "ça devrait marcher". Étape 2bis parallélise via `research-delegate` pour les phases multi-dimensions. |

### `.claude/agents/` — le sous-agent

| Agent | Rôle |
|-------|------|
| `research-delegate` | Sous-agent read-only invoqué automatiquement par les skills core. Lit jusqu'à 15 sources (code local, web, docs) et renvoie une synthèse en 3-10 bullets max. Garde ta fenêtre de contexte principale propre. Voir vidéo 3.4 du module pour la théorie. |

### `.claude/skills/n8n/` — les 7 skills n8n officiels (MIT)

Skills officiels de [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT License Copyright 2025 Romuald Członkowski). Inclus tels quels avec attribution. Voir `.claude/skills/n8n/README.md` et `.claude/skills/n8n/LICENSE-czlonkowski`.

| Skill | Rôle |
|-------|------|
| `n8n-mcp-tools-expert` | Guide maître pour utiliser les outils MCP n8n. |
| `n8n-workflow-patterns` | Patterns courants : webhook, API, BDD, AI agent, batch, scheduled. |
| `n8n-validation-expert` | Interprétation des erreurs de validation n8n. |
| `n8n-node-configuration` | Configuration operation-aware (par opération). |
| `n8n-expression-syntax` | Syntaxe `{{}}`, variables `$json`, `$node`. |
| `n8n-code-javascript` | Code nodes JavaScript. |
| `n8n-code-python` | Code nodes Python (rare). |

### `.claude/rules/` — règles auto-chargées par chemin

Les fichiers ici ont un frontmatter `paths:` qui définit quand Claude doit les charger. Quand tu ouvres un fichier qui match le pattern (ex: `src/**/*.{ts,tsx}`), Claude charge automatiquement la règle correspondante en plus du `CLAUDE.md` principal.

Ça évite que ton `CLAUDE.md` gonfle à 300 lignes avec des règles front + back + n8n alors que 90 % du temps Claude n'a besoin que d'une dimension à la fois.

Exemple fourni : `frontend.md` (s'applique à tous les `.ts`/`.tsx` dans `src/`). Voir `.claude/rules/README.md` pour le détail du pattern.

### `CLAUDE.md` — le template à adapter

5 couches : **Identité** / **Stack** / **Conventions** / **Instructions** / **Contexte métier** + **4 règles de comportement** inspirées d'Andrej Karpathy + une section **"Comment ce CLAUDE.md est entretenu"** qui explique :
- le séquencement des skills (`/start → /brainstorm? → /create-prd → /plan → /challenge? → /execute → /validate`),
- qui écrit dans quelle section (ancres HTML `<!-- skill:nom -->` pour `/start` et `/create-prd`),
- comment déporter vers `.claude/rules/` quand une section dépasse 20 lignes,
- la **sécurité des credentials** : pattern Anthropic-officiel `${VAR}` dans `.mcp.json`, valeurs réelles dans `.env` (gitignored), `.env.example` committé pour la doc.

Tu copies, tu adaptes les 5 couches à ton projet (`/start` rempli déjà Identité et Stack pour toi), tu gardes les 4 règles + la section meta.

### `.mcp.json` + `.env.example` — scaffolding outillage

`.mcp.json` vide par défaut. `.env.example` documente les variables d'environnement standard (n8n, Anthropic SDK, Supabase, Resend). `/start` te guide pour remplir `.env` (gitignored), ajouter les MCP dans `.mcp.json` avec syntaxe `${VAR}`, et charger `.env` dans ton shell.

## ⚠️ Sécurité — important

Le kit est **pédago**, pas prod-ready clé en main. Adapte avant de mettre en prod.

### Le cas concret du module : le Hub Documents perso (5.1-5.4)

Le **Hub Documents** construit en démo (5.1-5.4) est un outil perso freelance qui transforme des transcripts RDV en livrables pros (propale PDF + email, résumé exécutif, cas client, post LinkedIn). Il traite des **données clients réelles** : transcripts de RDV, contacts, parfois chiffres confidentiels.

**RLS Supabase est MANDATORY** sur le Hub Documents. Sans exception. Les policies activées dans la démo :
- `documents` : `auth.uid() = owner` (chaque utilisateur ne voit que ses transcripts)
- `generations` : via JOIN avec `documents.owner`
- Bucket Storage `documents` : `(auth.uid()::text = (storage.foldername(name))[1])`

C'est typiquement le cas pour 99% des apps pros que tu vas construire.

### Le cas inverse (hors module) : un outil à données éphémères

Si tu construis un outil **à données éphémères sans PII** — un sondage live d'atelier, un kanban temporaire, un timer partagé — RLS peut être skippé. Le pire scénario d'une fuite serait "quelqu'un voit qu'un participant anonyme est passé en rouge". Aucun préjudice.

Dans ce contexte, RLS ajoute du frottement sans valeur. Mais ce cas est minoritaire.

### Quand RLS est OBLIGATOIRE (la majorité des cas)

Dès que ton app contient :
- Données clients (nom, email, téléphone, adresse, SIRET…)
- Transcripts RDV, devis, factures, leads
- Auth utilisateur avec données privées
- Multi-tenant (plusieurs comptes / clients sur la même base)

→ **RLS dès le premier deploy. Sans exception. C'est le cas du Hub Documents.**

### La règle générale

> Si le pire scénario d'une fuite de données est "rien de grave", tu peux skipper RLS.
> Sinon (99% des cas pro, le Hub Documents inclus), RLS systématique avant prod.

Et au-delà de RLS : valide les inputs côté serveur (jamais juste côté client), gère les secrets via variables d'environnement, et ne committe **jamais** de `.env` ni de credentials. Le module IAPreneurs en reparle dans la Partie 4 et solidifie tout ça en 5.4 (audit RLS post-incident).

## Inspirations & crédits

- **Méthode SDD simplifiée** : inspirée de l'[ai-transformation-workshop de Cole Medin](https://github.com/coleam00/ai-transformation-workshop) (pattern repo public + skills conversationnels).
- **Skills n8n** : [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT License).
- **4 règles de comportement** : adaptées de [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills).

## Pour aller plus loin

Les 7 skills + sous-agent de ce kit sont une version pédagogique simplifiée des outils internes Sablia (`/start` ne fait pas partie du workflow Sablia — c'est un wrapper d'onboarding spécifique au kit ; `/brainstorm`, `/plan`, `/execute`, `/validate`, `/challenge` complets côté Sablia font ~250-450 lignes chacun, plus une dizaine d'autres skills domaine). Le sous-agent `research-delegate` est lui aussi une version simplifiée — Sablia en utilise neuf en production.

Si tu te sens à l'aise avec ce kit et que tu veux la version complète : on en reparle dans la communauté IAPreneurs.

## License

[MIT License](LICENSE) — Copyright 2026 Brice Gachadoat. Fais-en ce que tu veux.
