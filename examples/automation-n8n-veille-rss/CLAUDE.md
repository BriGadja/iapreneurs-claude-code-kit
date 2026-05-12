# CLAUDE.md — Exemple "veille RSS IA via n8n"

> Exemple **STANDARD** : workflow n8n qui agrège des flux RSS d'IA tech, classe par pertinence via Anthropic, envoie un résumé hebdo sur Slack. Pas d'UI front, juste de l'automation.

## Identité

<!-- start:identité -->
Workflow n8n de veille RSS sur l'IA tech : tous les lundis 7h, agrège les 10 flux RSS configurés, classe les nouveaux articles par pertinence via Claude Haiku, formate un résumé top-10 et l'envoie sur le canal Slack `#veille-ia`. Pas d'UI utilisateur — c'est de l'automation pure.

project_type: automation
<!-- /start:identité -->

## Stack

<!-- architect:stack -->
- Automation runtime : n8n self-hosted (sur VPS du coach) ou n8n cloud
- IA : Anthropic Claude Haiku (classement pertinence, le moins cher)
- Source : 10 flux RSS (config dans node "RSS list" du workflow)
- Destination : Slack webhook (canal `#veille-ia`)
- Stockage état (pour dédup) : Supabase table `seen_articles` (URL hash + date)
<!-- /architect:stack -->

## Request Classification

**Niveau choisi pour ce projet** : `STANDARD` — workflow multi-étapes mais 1-2 phases au final, `/challenge` optionnel, validation via `n8n_test_workflow` MCP.

## Conventions

- Naming workflow n8n : `[PROD] veille-rss-ia-hebdo`
- Naming credentials n8n : `anthropic-api` (clé Anthropic), `slack-webhook-veille-ia`, `supabase-veille`
- Commits : conventionnel + scope `n8n` (ex: `feat(n8n): ajout filtre nouveauté < 7j`)

## Instructions

- Le workflow doit être **idempotent** : si exécuté 2x le même lundi par erreur, pas de double Slack
- Clé d'unicité dans `seen_articles` : SHA-256 de l'URL canonicalisée
- Limite de coût Anthropic : si plus de 100 articles à classer dans la session, échantillonne (Top 100 par date desc)

## Contexte métier

- Le coach business utilise ça pour rester à jour sur les outils IA qu'il enseigne
- Pertinence = "intéressant pour un entrepreneur IA débutant à intermédiaire" (pas de papier de recherche pur, pas de hardware)
- Si moins de 5 articles pertinents dans la semaine → message Slack "Semaine calme, voici quand même le top 3"
