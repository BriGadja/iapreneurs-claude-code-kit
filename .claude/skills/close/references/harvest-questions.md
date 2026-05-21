# Harvest learnings — questions ciblées par triggers (Étape 6)

> **Lis ce fichier à l'Étape 6 du SKILL.md** (mode **full** uniquement — skip en planning).
>
> But : ne poser des questions à l'utilisateur que si la session contient des **signaux de notabilité** détectables sur le diff git. Sinon, auto-récap silencieux + passage.

> **Boucle externe (vocabulaire kit v2.1.0)** : tu fais la **boucle externe** ici. La **boucle interne** (PIV : `/prime → /plan → /execute → /validate → /close`) résout la feature courante ; la **boucle externe** cristallise ce que la session t'a appris en mémoire persistante (`memory/topics/`, `memory/decisions.md`, `MEMORY.md`) pour que les futures sessions ne refassent pas les mêmes erreurs.

## 6.0 — Détection des triggers

Sur le diff git de la phase (`git diff {commit-ouverture-phase}..HEAD`), exécuter en parallèle ces 6 checks :

| Trigger | Détection | Question pertinente à poser |
|---------|-----------|------------------------------|
| **T1 — nouvelle dépendance** | `git diff` touche `package.json` ligne `+ "..."` dans `dependencies`/`devDependencies` | "Un gotcha pendant l'install ou le choix de cette dépendance ?" |
| **T2 — nouveau MCP** | `git diff` touche `.mcp.json` ou `.mcp.json.example` avec ajout de bloc `mcpServers` | "Un piège lors de la config de ce MCP (auth, URL, mode docs-only) ?" |
| **T3 — migration SQL / RLS** | Fichiers `supabase/migrations/*.sql` ajoutés OU diff contient `CREATE POLICY`, `ALTER TABLE`, `ENABLE ROW LEVEL SECURITY` | "Une décision RLS ou un schéma de données à mémoriser ?" |
| **T4 — workaround / hack** | `git diff` contient `HACK`, `FIXME`, `XXX`, `workaround`, `temporary fix` (case-insensitive) dans les fichiers code (pas dans la doc) | "Un contournement à documenter pour ne pas l'oublier ?" |
| **T5 — nouvelle règle path-scoped** | Nouveau fichier `.claude/rules/*.md` créé | "Un pattern réutilisable à formaliser ? (sinon je n'écris pas)" |
| **T6 — choix arch significatif** | Diff `memory/decisions.md` (ADR ajouté par `/evoluer`) OU le commit message contient `feat(...)` + le ` — ` (rationale séparator) avec une raison non triviale | "Une décision d'arch à raconter en 2 lignes pour mémoire ?" |

## Logique

- **Aucun trigger** → skip 6.2 et 6.3 totalement. Annonce : *"Mémoire : auto-récap seul écrit (rien de notable détecté dans le diff)."*
- **1 trigger** → poser **uniquement** la question associée (1 question, pas 3).
- **2+ triggers** → poser les questions associées dans l'ordre T1→T6, max 3 questions au total.

**Règle d'or** : si la question retourne "rien à signaler" / "skip" → ne pas insister, passer à la suivante ou clôturer 6.

## 6.1 — Auto-récap session (toujours écrit, low-friction)

Crée ou complète `memory/learnings/{YYYY-MM-DD}.md` avec un récap automatique de la phase clôturée :

```markdown
## Phase {N} — {nom} (clôturée à {HH:MM})

### Commits
- {SHA court} {message} *(le commit de cette /close)*
- {SHAs précédents de la phase, depuis le /close de Phase N-1)}

### Fichiers modifiés (top 10)
- {liste git diff --stat depuis le dernier /close}

### Durée approximative
{calcul : entre le premier commit de la phase et celui-ci} → environ {X}h
```

Pas de question, écriture directe. Si le fichier `memory/learnings/{date}.md` existe déjà (plusieurs phases clôturées le même jour), append en bas.

## 6.2 — Topics opt-in (questions ciblées par triggers détectés)

Skippé totalement si l'Étape 6.0 n'a détecté aucun trigger. Sinon, pour chaque trigger détecté (max 3), pose la question associée du tableau 6.0. **Une seule question par trigger**, jamais l'arsenal complet à froid.

Selon la réponse :

- **Trigger T6 (décision arch)** ou réponse type "décision" → écris dans `memory/decisions.md` ancre `<!-- close:decisions -->` :
  ```
  - **{YYYY-MM-DD}** — {décision} (Phase {N}). Rationale : {réponse utilisateur}
  ```

- **Trigger T1/T2/T3/T4 (gotcha, install, RLS, workaround)** → demande le **domaine** en 1 mot (ex : "n8n", "supabase", "deploy") et écris dans `memory/topics/{domaine}.md` (crée si absent) :
  ```markdown
  ## {YYYY-MM-DD} — {résumé 1-ligne}
  {réponse utilisateur, 2-5 lignes}
  ```

- **Trigger T5 (pattern réutilisable)** → écris dans `memory/topics/{domaine}.md` (même format que T1-T4).

Si l'user dit "rien à signaler" / "skip" sur une question, passe à la suivante. Si tous les triggers passent en "skip" → 6.2 produit 0 écriture (c'est OK, l'auto-récap 6.1 suffit).

## 6.3 — Update MEMORY.md index

Après écriture(s) en 6.2, met à jour `MEMORY.md` à la racine :

- Ancre `<!-- close:topics-index -->` : ajoute un lien `- [domaine](memory/topics/{domaine}.md) — {résumé 1-ligne}` si nouveau topic, sinon laisse (le détail est dans le fichier topic).
- Ancre `<!-- close:learnings-index -->` : ajoute `- [{date}](memory/learnings/{date}.md) — Phase {N} clôturée ({X}h, {N commits})`.

**Règle d'or** : si l'utilisateur répond "rien" à toutes les questions, tu ne demandes pas de troisième confirmation. Tu skipes 6.2/6.3 et passes à 6.4. Pas de friction.

## 6.4 — Annonce courte

*"Mémoire mise à jour : {N learnings + {M topics si applicable}}. MEMORY.md indexé."*. Pas de dump du contenu écrit.

## Retour au SKILL.md

Une fois harvest terminé (avec ou sans questions posées), retourne à l'Étape 6.4 du SKILL.md (SPEC frozen header) puis 6.5 (gate déploiement).
