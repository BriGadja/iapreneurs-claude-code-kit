# Étape 4bis — Gate live des capacités techniques (MCP)

> **Lis ce fichier uniquement si** `/evoluer` Étape 4bis détecte qu'une feature nécessite une capacité MCP nouvelle (n8n, Google Workspace, Stripe, Resend, etc.) absente du projet.
>
> But : empêcher `/execute` de planter au premier appel MCP sur un outil pas vraiment installé (cas typique : `.mcp.json` édité mais Claude Code pas redémarré, ou clé invalide → MCP démarre en mode docs-only sans le dire).

## Règle non-négociable

`/evoluer` ne sort PAS de cette étape tant que chaque MCP requis n'a pas été validé par un appel live (health check + au moins un read réel). On ne fait pas confiance au `grep .mcp.json` pour conclure "c'est installé" : on confirme avec l'outil.

**Cap retry** : 3 tentatives max par capacité. Au-delà, abandon explicite (voir § Abandon ci-dessous). Pas de boucle infinie.

## Procédure (3 passes par capacité)

### Passe 1 — détection statique (fichier seul)

Pour chaque capacité repérée à l'Étape 4bis du SKILL.md :

| Capacité | Check statique |
|----------|----------------|
| n8n | `grep -q "n8n-mcp" .mcp.json` |
| Google Workspace | `grep -qE "google-workspace|workspace-mcp|server-gdrive" .mcp.json` |
| Stripe | `grep -q "stripe" .mcp.json` |
| Resend / SendGrid | `grep -q "RESEND_API_KEY\|SENDGRID_API_KEY" .env .env.example .mcp.json` |

**Si la passe statique est négative**, demande à l'utilisateur :

> *"Cette feature semble nécessiter `{capacité}`. Je ne vois pas l'install correspondante dans `.mcp.json`. Confirmes-tu qu'il faut l'installer maintenant ?*
> - *oui, installer → je lance la procédure {référence}, puis je valide l'install live avant de continuer*
> - *non, déjà installé ailleurs / global → je tente quand même la validation live (le MCP peut être chargé via `~/.claude/mcp.json` global)*
> - *non, finalement pas besoin → reformule la feature, je relance l'Étape 2"*

### Passe 2 — installation (si "oui, installer")

| Capacité | Procédure d'install |
|----------|---------------------|
| **n8n** | Lis et exécute `.claude/rules/n8n-setup.md` (Étapes 1.a-1.c + 2-5). À la fin, note dans le SPEC § Documentation la version du MCP installée + l'URL n8n cible (sans la clé). |
| **Google Workspace** | Ajout dans `.mcp.json` (gitignoré, pattern n8n-setup.md § 1.b) avec valeurs réelles. Imprime la commande OAuth à lancer (depuis README upstream du MCP Google choisi). Attends confirmation utilisateur *"OAuth fait"* avant Passe 3. |
| **Stripe / Resend / autre** | Même pattern : valeurs en clair dans `.mcp.json` gitignoré, ou clé dans le `.env` du provider selon ce que demande le MCP. |

### Passe 3 — validation live (BLOQUANTE)

C'est la version Étape 4bis du principe Karpathy "le test EST la métrique". Pour CHAQUE capacité requise, exécute le check correspondant **dans la session Claude Code courante** (si tu viens de redémarrer Claude Code, les tools sont disponibles immédiatement) :

| Capacité | Check 1 (health) | Check 2 (read réel) | PASS si |
|----------|------------------|---------------------|---------|
| **n8n MCP** | `mcp__n8n-mcp__n8n_health_check` | `mcp__n8n-mcp__n8n_list_workflows` | Health renvoie `apiConfigured: true` ET list_workflows retourne `[]` ou liste réelle sans 401/404 |
| **Google Workspace MCP** | Lister les tools `mcp__google-workspace__*` (vérif présence) | `mcp__google-workspace__list_calendars` ou `list_drive_items` (root) | Au moins un read renvoie une réponse non vide / non-erreur |
| **Stripe MCP** | Lister `mcp__stripe__*` | `mcp__stripe__list_customers` (limit 1) | Réponse sans erreur d'auth |
| **Resend (HTTP, pas MCP)** | `curl -s -H "Authorization: Bearer ${RESEND_API_KEY}" https://api.resend.com/domains` | Idem | HTTP 200 ou 401 explicite (pas timeout) |

### Si un check échoue (boucle retry capée à 3)

1. Imprime le message d'erreur exact à l'utilisateur.
2. Diagnostique :
   - **401/403** → clé invalide
   - **404** → URL malformée (oublié `/api/v1` ?)
   - **`command not found`** côté MCP → Claude Code pas redémarré après edit `.mcp.json`
   - **Tool absent** → MCP pas dans `.mcp.json` (ou `.mcp.json` mal parsé)
3. Propose la correction concrète, attends que l'utilisateur la fasse + relance Claude Code si nécessaire.
4. Relance Passe 3 (compte la tentative).

### Abandon (après 3 échecs OU choix explicite utilisateur)

Si tu atteins 3 tentatives sans PASS sur une capacité, ou si l'utilisateur dit *"non, finalement pas besoin"* à tout moment :

- **Cap retry atteint** : *"3 tentatives de validation live pour `{capacité}` ont échoué. Dernier message d'erreur : `{erreur}`. Je ne peux pas garantir que `/execute` ne plantera pas. Deux options : (a) abandonner la feature et reformuler sans `{capacité}` à l'Étape 2, (b) sortir de /evoluer pour debug manuel (clé, URL, redémarrage Claude Code) puis relancer /evoluer."*
- **Abandon utilisateur** : retourne à l'Étape 2 du SKILL.md pour reformuler la feature sans cette capacité.

**Pas de bypass possible.** On ne sort de cette gate qu'avec PASS ou abandon explicite.

## Commit intermédiaire (si install + validation OK)

Après installation réussie ET validation live PASS pour toutes les capacités requises :

```bash
git add .mcp.json.example .gitignore CLAUDE.md .claude/rules/
git commit -m "chore(/evoluer): install {capacité} prérequis pour feature {nom}"
```

**Ne commit JAMAIS `.mcp.json` lui-même** (gitignoré car il contient des clés).

## Idempotence

Si Passe 1 ET Passe 3 passent du premier coup pour une capacité, **skip silencieux** (log *"{capacité} déjà opérationnelle, validation live OK"*). Pas de re-confirmation, pas de doublon `.mcp.json`.

## Retour au SKILL.md

Une fois toutes les capacités requises en PASS (ou abandon propre) : retourne à l'Étape 5 du SKILL.md (écriture atomique).
