# IAPreneurs Claude Code Kit

> Le kit de démarrage **Claude Code** des membres IAPreneurs. Forke-le, configure ton `CLAUDE.md`, et tu codes en quelques minutes avec une méthode propre — même si tu n'as jamais codé avant.

## D'où ça vient — la story Cup App

Pendant les ateliers IAPreneurs, on utilise une petite app web : la **Cup App**. Trois boutons : 🟢 je suis, 🟠 je décroche un peu, 🔴 je suis perdu. Tout le monde clique en direct, l'animateur voit le taux de rouge en temps réel et adapte le rythme.

Cette app a été **buildée from scratch en live** pendant la Partie 5.1 du module Claude Code. Aucune ligne écrite à la main. Juste la méthode `brainstorm → create-prd → plan → execute → validate` qui est dans ce kit.

L'idée du kit : tu repars avec **exactement les outils utilisés dans le tournage**. Tu peux refaire la Cup App, ou n'importe quel autre projet, avec la même méthode.

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

### `.claude/skills/` — les 5 skills core (méthode SDD simplifiée)

| Skill | Rôle |
|-------|------|
| `/brainstorm` | Tu n'as qu'une idée vague. 3 questions et tu repars avec un fichier `brainstorm-{sujet}.md` qui clarifie ce que tu veux. |
| `/create-prd` | À partir du brainstorm, génère un Product Requirements Document structuré (sommaire / utilisateurs / MVP / phases / stack / critères de succès). |
| `/plan` | Prend une phase du PRD et la découpe en tâches numérotées avec critères "Fait quand" vérifiables. 8 tâches max par phase. |
| `/execute` | Exécute les tâches une par une. Coche les cases au fur et à mesure. Marque la phase ✅ Terminée dans le PRD parent. |
| `/validate` | Propose 3 options de validation (web → Playwright, n8n → test exécution, autre → demande). Verdict réel, jamais "ça devrait marcher". |

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

## ⚠️ Sécurité — important

Si tu refais la Cup App ou un projet similaire avec données éphémères, tu n'auras peut-être **pas besoin de RLS** (Row Level Security Supabase). C'est volontaire dans le tournage : pas de données sensibles, sessions atelier qui durent 1h.

**Mais si tu pars en prod avec de vrais utilisateurs** : tu **dois** activer RLS sur toutes tes tables Supabase. C'est non-négociable. Le module en parle dans la Partie 4.

Le kit est pédago. Pas un template prod-ready clé en main. Adapte avant de mettre en prod.

## Inspirations & crédits

- **Méthode SDD simplifiée** : inspirée de l'[ai-transformation-workshop de Cole Medin](https://github.com/coleam00/ai-transformation-workshop) (pattern repo public + skills conversationnels).
- **Skills n8n** : [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) (MIT License).
- **4 règles de comportement** : adaptées de [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills).

## Pour aller plus loin

Les 5 skills core de ce kit sont une version pédagogique simplifiée des skills internes Sablia (`/brainstorm`, `/plan`, `/execute`, `/validate` complets, ~250-450 lignes chacun). Ils restent privés.

Si tu te sens à l'aise avec ce kit et que tu veux la version complète : on en reparle dans la communauté IAPreneurs.

## License

[MIT License](LICENSE) — Copyright 2026 Brice Gachadoat. Fais-en ce que tu veux.
