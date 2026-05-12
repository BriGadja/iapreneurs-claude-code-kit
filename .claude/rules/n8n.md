---
paths: "**/*.workflow.json"
---

# Règles n8n (auto-chargées sur tout `.workflow.json`)

> Adapte ou supprime selon ton projet. Ce fichier complète les 7 skills `n8n-*` du kit qui couvrent la création/validation/debug — ici on documente les conventions transverses.

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
