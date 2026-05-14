<!--
PRD vivant discipliné. Cap 100 lignes hard.
Mis à jour par /evoluer (jamais réécrit destructivement).
project_type: automation | Request Classification: STANDARD
-->

# PRD — Veille RSS IA via n8n

## 1. Vision

Workflow n8n qui agrège 10 flux RSS d'IA tech tous les lundis à 7h, classe les nouveaux articles par pertinence via Claude Haiku, et envoie un top-10 résumé sur Slack `#veille-ia`. Pas d'UI utilisateur — l'output Slack EST l'interface.

## 2. Personas

- **Coach business solo** — veut rester à jour sans passer 2h/jour à scroller. Lecture passive sur Slack mobile pendant le café du lundi. Douleur : FOMO + saturation flux d'info.

## 3. Scope actuel (V_n)

> Cochée = livré. Mis à jour par `/evoluer`.

### Core
- [ ] Trigger Cron : tous les lundis 7h Europe/Paris
- [ ] 10 flux RSS configurés dans un node "RSS list"
- [ ] Dédup via Supabase `seen_articles` (URL hash)
- [ ] Classement pertinence via Claude Haiku
- [ ] Formatage Markdown top-10 (titre + 1 phrase + lien)
- [ ] Envoi Slack via webhook `#veille-ia`

### Technique
- [ ] n8n self-hosted (ou cloud)
- [ ] Anthropic Claude Haiku (`claude-haiku-4-5-20251001`)
- [ ] Supabase Postgres table `seen_articles` (`url_hash` UNIQUE)
- [ ] Slack incoming webhook

## 4. Hors scope (différé)

- [ ] UI de gestion des flux RSS (édition direct dans n8n suffit)
- [ ] Multi-canal (juste Slack pour l'instant, pas d'email)
- [ ] Statistiques d'utilisation (clics, articles lus)
- [ ] Filtrage par tag (toute la veille IA)
- [ ] Config flux dans table Supabase (au lieu de hardcode)
- [ ] Monitoring échec (alerte si workflow KO)

## 5. Constraints non-négociables

- Coût Anthropic < 1€/mois
- Pas de bruit Slack en dehors du lundi 7h
- Idempotent : 2 runs le même lundi = 0 doublon Slack

## 6. Success Criteria

- Le workflow tourne le lundi 7h sans intervention humaine (0 erreur sur 4 lundis consécutifs)
- La dédup empêche les doublons sur 4 lundis
- Coût Anthropic mensuel < 1€ (~40 articles × 4 lundis × Haiku pricing)
- Top-10 reçu sur Slack en < 5 minutes après le trigger
- Si < 5 articles pertinents, message "Semaine calme, top 3" envoyé quand même

## 7. Implementation Phases

**V1 (livré le YYYY-MM-DD)** — Workflow MVP fonctionnel hardcoded canal test.

**V2 (envisagé)** — Production-ready : config flux dans Supabase + monitoring échec + passage prod.

## 8. Risks & Mitigations

- **Risque** : flux RSS down → **Mitigation** : try/catch n8n par flux, skip silent si fail (pas d'erreur globale)
- **Risque** : Claude rate-limit → **Mitigation** : batch d'articles par appel (10-20 par prompt)
- **Risque** : Supabase dédup race condition → **Mitigation** : `INSERT ... ON CONFLICT DO NOTHING` sur `url_hash`
