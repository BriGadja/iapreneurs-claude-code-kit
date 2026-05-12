# IAPreneurs Claude Code Kit

> Le kit de démarrage **Claude Code** des membres IAPreneurs. Forke-le, configure ton `CLAUDE.md`, et tu codes en quelques minutes avec une méthode propre — même si tu n'as jamais codé avant.

## Ce que tu récupères

Un dossier `.claude/` prêt à l'emploi avec :

- **5 skills core** qui couvrent le cycle complet d'un projet : clarifier une idée → produire un PRD → planifier une phase → exécuter → vérifier.
- **1 skill optionnelle** `/challenge` — devil's advocate sur le plan avant `/execute` (à activer dans ton workflow quand tu te sens à l'aise).
- **1 sous-agent** `research-delegate` — invoqué automatiquement par les skills core pour la recherche (codebase + web), garde ta fenêtre de contexte propre.
- **7 skills n8n officiels** (MIT, czlonkowski) pour t'aider à construire et debugger des workflows n8n sans halluciner les nodes.
- **Un `CLAUDE.md` template** à adapter à ton projet (5 couches + 4 règles de comportement inspirées de Karpathy).
- **Un `.mcp.json` vide** prêt à recevoir les MCP recommandés (Playwright, n8n) — commandes d'installation dans `CLAUDE.md`.

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

Au lancement, Claude lit `CLAUDE.md` et a accès aux 5 skills core + 7 skills n8n. Tu peux directement taper :

```
/brainstorm une app pour gérer mes recettes de cuisine
```

Et c'est parti.

## Ce qu'il y a dans le kit

### `.claude/skills/` — les 5 skills core (méthode SDD simplifiée) + 1 optionnelle

| Skill | Rôle |
|-------|------|
| `/brainstorm` | Tu n'as qu'une idée vague. 3 questions et tu repars avec un fichier `brainstorm-{sujet}.md` qui clarifie ce que tu veux. Route 2 délègue à `research-delegate` pour explorer projets similaires. |
| `/create-prd` | À partir du brainstorm, génère un Product Requirements Document structuré (sommaire / utilisateurs / MVP / phases / stack / critères de succès). |
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

### `CLAUDE.md` — le template à adapter

5 couches : **Identité** / **Stack** / **Conventions** / **Instructions** / **Contexte métier** + **4 règles de comportement** inspirées d'Andrej Karpathy (réfléchir avant de coder / simplicité d'abord / modifications chirurgicales / exécution orientée but).

Tu copies, tu adaptes les 5 couches à ton projet, tu gardes les 4 règles (elles s'appliquent à n'importe quel projet).

Le `CLAUDE.md` documente aussi les **MCP recommandés** (Playwright, n8n) et le **plugin `frontend-design`** d'Anthropic — installations en 1 commande.

### `.mcp.json` — scaffolding MCP

Fichier vide par défaut (`{"mcpServers": {}}`). Tu installes les MCP qui te servent (commandes dans `CLAUDE.md`), `.mcp.json` se remplit tout seul. Tu commit ce fichier dans Git pour que ton équipe ait les mêmes outils.

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

Les 5 skills core de ce kit sont une version pédagogique simplifiée des skills internes Sablia (`/brainstorm`, `/plan`, `/execute`, `/validate` complets, ~250-450 lignes chacun). Ils restent privés.

Si tu te sens à l'aise avec ce kit et que tu veux la version complète : on en reparle dans la communauté IAPreneurs.

## License

[MIT License](LICENSE) — Copyright 2026 Brice Gachadoat. Fais-en ce que tu veux.
