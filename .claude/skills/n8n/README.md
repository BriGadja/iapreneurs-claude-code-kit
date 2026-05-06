# Skills n8n — attribution & utilisation

Les 7 skills présents dans ce dossier sont les **skills officiels** de [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills).

## License

**MIT License** — Copyright 2025 Romuald Członkowski (czlonkowski).

Le fichier `LICENSE-czlonkowski` dans ce dossier est la licence MIT d'origine du repo source. Sa présence est requise par les termes de la licence MIT (préservation de l'attribution).

## Source

- Repo : https://github.com/czlonkowski/n8n-skills
- Commit copié : `27e9d0ab92cccfc46db4f147497b173f214b69c5` (snapshot du 2026-05-06)

Pour obtenir la version la plus récente, va sur le repo source et copie/fork ces skills depuis là. Les versions ci-dessous peuvent prendre du retard sur les évolutions upstream.

## Liste des 7 skills

| Skill | Rôle |
|-------|------|
| `n8n-mcp-tools-expert` | Guide maître pour utiliser les outils MCP n8n (search, get_node, validate, etc.). |
| `n8n-workflow-patterns` | 6 patterns clés : webhook, API call, BDD, AI agent, batch processing, scheduled. |
| `n8n-validation-expert` | Interprétation des erreurs de validation (`validate_workflow`, `validate_node`). |
| `n8n-node-configuration` | Configuration operation-aware (par opération, pas par nom de node). |
| `n8n-expression-syntax` | Syntaxe `{{}}`, variables `$json`, `$node['Name'].json`. |
| `n8n-code-javascript` | Code nodes en JavaScript (sandbox, helpers, retours). |
| `n8n-code-python` | Code nodes en Python (rare, mais utile). |

## Quand sont-ils utiles

Tu utilises n8n et tu veux qu'un agent Claude (ou Cursor, ou autre client MCP) sache **comment construire** correctement un workflow n8n sans halluciner les noms de nodes ou les expressions.

## Mise à jour

Les skills sont copiés au commit `27e9d0a...`. Ils ne se mettent pas à jour tout seuls. Si tu veux la dernière version :

```bash
cd /tmp
git clone --depth=1 https://github.com/czlonkowski/n8n-skills cz-skills
# Puis copie ce qui t'intéresse depuis cz-skills/skills/
```

## Crédit

Merci à Romuald Członkowski (`czlonkowski` sur GitHub) pour le travail upstream et la license MIT qui rend cette redistribution possible.
