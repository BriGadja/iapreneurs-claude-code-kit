---
paths:
  - "**/*.workflow.json"
  - "**/.mcp.json"
  - ".claude/skills/n8n/**"
---

# Règles n8n (auto-chargées sur `.workflow.json`, `.mcp.json`, ou skill n8n)

> Adapte ou supprime selon ton projet. Ce fichier complète les 7 skills `n8n-*` du kit (création/validation/debug) — ici on documente les **directives système prescrites par czlonkowski** (auteur du MCP) **+** les conventions transverses du projet.

## Directives système — n8n MCP (prescrites par czlonkowski)

Ces 4 règles viennent du README de [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp) et sont la condition pour utiliser le MCP correctement :

1. **Silent Execution** — exécute les outils MCP sans commentaire intermédiaire. Réponds **après** que tous les outils soient terminés, pas pendant. Pas de "Je vais maintenant appeler…" + tool call + "Voici le résultat…" — fais juste les tool calls et synthétise à la fin.
2. **Templates-First** — avant de construire un workflow from scratch, **toujours** chercher dans les ~2 352 templates disponibles via `search_templates` / `get_template`. Tu pars d'un template existant 80 % du temps.
3. **Validate Before Deploy** — avant d'écrire un workflow dans n8n via `n8n_create_workflow` / `n8n_update_full_workflow`, **toujours** appeler `validate_workflow` sur le JSON proposé. Si la validation retourne des warnings, fix avant de déployer.
4. **Never edit production with AI** — ne modifie **jamais** directement un workflow en `[PROD]` via le MCP. Édite la version `[DEV]` (copie), valide, teste, puis l'utilisateur fait le swap manuellement.

**Flow type pour "crée-moi un workflow X"** : `search_templates` → `get_template` (si match) → adapt → `validate_workflow` → `n8n_create_workflow` en `[DEV]`. Pas de raccourci.

## Mode docs-only vs API-connected

Le MCP czlonkowski a deux modes selon la présence (ou non) de `N8N_API_URL` + `N8N_API_KEY` :

- **Docs-only** (sans credentials) — 7 tools : search nodes, get docs, templates, validate JSON. Suffisant pour **apprendre** n8n ou construire des workflows en local avant déploiement.
- **API-connected** (avec credentials) — 20 tools (les 7 docs + 13 management : create/update workflows, run executions, audit instance).

Si l'utilisateur n'a pas encore d'instance n8n, le mode docs-only marche immédiatement après `claude mcp add`. Pas besoin de bloquer l'onboarding.

## Naming des workflows

- Format : `[ENV] {client-ou-projet}-{fonction}-{detail-optionnel}`
- Exemples : `[PROD] hub-documents-resume-generation`, `[DEV] hub-documents-resume-generation`
- `ENV` parmi `PROD`, `DEV`, `STAGING`. Aide à filtrer dans l'UI n8n.

## Credentials

- **Jamais** de credentials en dur dans les nodes. Toujours via le store de credentials n8n (Settings → Credentials), référencés par ID.
- Quand tu exportes un workflow, le `credentialId` reste dans le JSON mais la valeur n'y est jamais. C'est OK de commit l'export.

## Webhooks

- Génère **toujours** un `webhookId` UUID stable (visible dans le node Webhook → Settings). Sans `webhookId`, n8n régénère un nouveau path à chaque réimport — tous les callers cassent.
- Path lisible : `/webhook/hub-documents-resume` plutôt que `/webhook/abc123`.
- Method : `POST` par défaut. `GET` uniquement pour les triggers sans body utile.

## Patterns à éviter

- **Pas de Code node** pour ce qu'un nœud natif fait nativement (HTTP Request, Supabase, IF, Set). Le Code node = dernier recours, pas premier réflexe.
- **Pas de polling** sur une ressource qui supporte les webhooks. Si Resend, Supabase, Stripe envoient des webhooks → écoute-les, ne les sonde pas.
- **Pas de mots de passe ou clés API en clair** dans une expression `={{$json.password}}` qui finit logguée — passer par Credentials toujours.

## Tests

- Active le workflow uniquement après avoir testé avec un Trigger manuel + données réelles.
- Pour les workflows en prod, garde une version DEV en parallèle (`[DEV] {meme-nom}`) pour itérer sans casser la prod.

## Versionning

- Exporte les workflows critiques en `.workflow.json` dans le repo (gitté). L'UI n8n n'a pas d'historique fiable au-delà des 90 derniers jours par défaut.
- Au début de chaque sprint, sync `n8n.cloud → repo` pour capturer les modifs faites en UI.

## Quand un workflow casse

Ordre de debug :
1. Lance le skill `/n8n-debug` du kit (si présent) — il sait lire les executions
2. Sinon : MCP `n8n-mcp` → `n8n_executions` pour voir la dernière erreur
3. Lis le node qui a planté, regarde son input réel (souvent un champ manquant ou un type Wrong)
4. Si erreur sur un node IF → vérifie que la valeur comparée existe vraiment dans `$json` (cas fréquent : Webhook reçoit un body vide)
