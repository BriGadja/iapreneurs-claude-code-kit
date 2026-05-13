# STRUCTURE.md — Automation n8n veille RSS (STANDARD)

## Arborescence

<!-- architect:directories -->
- `workflows/veille-rss.workflow.json` — workflow n8n exporté (versionné git)
- `scripts/import-workflow.sh` — script d'import vers n8n via MCP / API
- `docs/credentials-required.md` — liste des credentials à provisionner côté n8n
- `.env.example` — placeholders pour les variables d'environnement
<!-- /architect:directories -->

## Patterns clés

<!-- architect:patterns -->
- 1 workflow déclenché par cron (toutes les 4h) : RSS → filtre LLM → résumé → Telegram
- Workflow versionné en JSON dans `workflows/`, push via MCP `n8n_create_workflow` ou `n8n_update_full_workflow`
- Credentials sensibles (clé OpenAI, token Telegram) jamais dans le JSON exporté — injectées via UI n8n
- `.env` local utilisé uniquement pour les variables non-sensibles (URLs RSS, chat_id Telegram)
<!-- /architect:patterns -->

## Tests

<!-- architect:tests -->
- Test manuel via UI n8n : bouton "Execute Workflow" avec un article RSS exemple
- Test programmatique via `n8n_test_workflow` MCP avec payload simulé
- Validation préalable : `n8n_validate_workflow` sur le JSON avant tout push (templates-first, fix les warnings)
<!-- /architect:tests -->

## Conventions d'arborescence

<!-- architect:conventions -->
- Nommage des workflows : `[ENV] veille-{source}` (ex : `[PROD] veille-techcrunch`, `[DEV] veille-techcrunch`)
- Jamais d'édition AI directe sur un workflow `[PROD]` — toujours éditer la copie `[DEV]`, valider, tester, puis swap manuel
- Fichiers JSON exportés : un par workflow, kebab-case, suffixe `.workflow.json`
<!-- /architect:conventions -->
