# PRD : Veille RSS IA via n8n

> **Niveau Request Classification** : STANDARD
> **project_type** : automation

## Sommaire

Workflow n8n qui agrège 10 flux RSS d'IA tech tous les lundis à 7h, classe les nouveaux articles par pertinence via Claude Haiku, et envoie un top-10 résumé sur Slack `#veille-ia`. Pas d'UI utilisateur.

## Utilisateurs cibles

- Le coach business solo qui veut rester à jour sans passer 2h/jour à scroller Twitter/LinkedIn
- Lecture passive sur Slack mobile pendant le café du lundi

## MVP — ce qu'on fait

- Trigger Cron : tous les lundis 7h Europe/Paris
- 10 flux RSS configurés dans un node "RSS list" (édition facile)
- Dédup via Supabase `seen_articles` (URL hash)
- Classement pertinence via Claude Haiku (prompt "intéressant pour entrepreneur IA débutant-intermédiaire")
- Formatage Markdown du top-10 (titre + 1 phrase + lien)
- Envoi sur Slack `#veille-ia` via webhook

## Hors-MVP — ce qu'on ne fait PAS

- UI de gestion des flux RSS (édition direct dans le workflow n8n suffit)
- Multi-canal (juste Slack pour l'instant, pas d'email)
- Statistiques d'utilisation (clics, articles lus)
- Filtrage par tag (toute la veille IA, pas de catégorisation fine)

## Phases

- **Phase 1** — Workflow MVP fonctionnel : trigger Cron + 10 flux + dédup Supabase + classement Haiku + envoi Slack en hardcoded sur 1 canal de test
- **Phase 2** — Production-ready : config flux dans table Supabase (au lieu de hardcode), monitoring échec (alerte si workflow KO), passage du canal test au canal prod

## Stack technique

- Automation : n8n self-hosted (ou cloud)
- IA : Anthropic Claude Haiku (`claude-haiku-4-5-20251001`)
- Dédup state : Supabase Postgres (table `seen_articles` avec colonne `url_hash` UNIQUE)
- Destination : Slack incoming webhook

## Critères de succès

- [ ] Le workflow tourne le lundi 7h sans intervention humaine (0 erreur sur 4 lundis consécutifs)
- [ ] La dédup empêche les doublons sur 4 lundis (pas le même article 2x)
- [ ] Le coût Anthropic mensuel < 1 € (~40 articles × 4 lundis × Haiku pricing)
- [ ] Top-10 reçu sur Slack en < 5 minutes après le trigger
- [ ] Si moins de 5 articles pertinents, message "Semaine calme, top 3" envoyé quand même
