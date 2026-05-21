# Audit caps CLAUDE.md + PRD.md (Étape 0.6)

> **Lis ce fichier uniquement si** `/close` est en mode **full** (skip silencieux en mode planning).
>
> But : warner sur la longueur des fichiers de gouvernance avant qu'ils ne deviennent imbitables. Ne bloque JAMAIS le commit — juste warn + propose.

## 0.6.1 — Audit CLAUDE.md

```
N=$(wc -l < CLAUDE.md)
```

- Si `N > 200` : warn *"⚠️ CLAUDE.md = {N} lignes (cap recommandé : 200). Sections candidates au déport (top H2 par longueur via awk) : {liste}. Tu veux qu'on les déporte vers `.claude/rules/{topic}.md` path-scoped ? (oui/skip)"*

## 0.6.2 — Audit PRD.md

Si PRD existe :
```
N=$(wc -l < PRD.md)
```

- Si `N > 100` : warn *"⚠️ PRD.md = {N} lignes (cap recommandé : 100, doit rester court et vivant). Tu veux qu'on identifie ce qui peut sortir vers `docs/specs/` ? (oui/skip)"*

## 0.6.3 — Acknowledged flag (anti-spam re-prompt)

Stocker l'ack dans `.claude/cache/close-cap-acknowledged.json` :
```json
{
  "CLAUDE.md": {"acked_at_lines": 245, "ts": "2026-05-14T10:00:00Z"},
  "PRD.md":    {"acked_at_lines": 108, "ts": "2026-05-14T10:00:00Z"}
}
```

Re-prompt seulement si lignes courantes **≥ acked_at_lines + 50**. Sinon skip (l'utilisateur a déjà acknowledgé à un seuil proche). Idempotent.

## Retour au SKILL.md

Une fois l'audit fait (ou skippé pour cause d'ack flag), retourne à l'Étape 1 du SKILL.md (détection phase).
