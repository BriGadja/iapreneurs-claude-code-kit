# Validation des 4 scénarios v2.0.0

> **Méthode** : script déterministe (`scripts/validate-kit-v2.sh`) qui vérifie par `grep`/`test` la présence des skills, ancres, examples, et l'absence des régressions Round 1 identifiées par le challenge Round 1 (Dipler hardcoded, collision /init, RLS hardcoded).
>
> **Pas de simulation mentale "LLM theater"** — le verdict est un comptage de checks PASS sur total. Cible v2.0 : tous scénarios ≥ 8/10.

## Exécution

```bash
bash scripts/validate-kit-v2.sh
```

Sortie : verdict par section + verdict global N/N PASS.

## Scénario A — Webapp SaaS (cycle complet de A à Z)

**Profil débutant** : un IAPreneur découvre Claude Code, veut construire une web app SaaS (auth + BDD + utilisateurs) sans connaissance préalable. Stack Next.js + Supabase + Vercel.

**Friction Round 1** : "j'ai un PRD mais mon repo est vide, je tape quoi ?" → `/scaffold` envisagé puis dropped en D25 (fold dans `/architect` Étape 6 Provisioning).

**Checks** (11/11) :
- /start existe
- /architect existe avec Étape 6 Provisioning
- /architect demande providers favoris (Étape 2b)
- /design existe
- /plan existe et adaptatif project_type
- /execute existe et ne marque PLUS ✅ Terminée (D3 source unique = /close)
- /validate existe avec audit policy BDD
- /close existe (mandatory + harvest learnings)
- /livrer existe et lit ## Stack (jamais hardcode)
- Example webapp existe (`examples/webapp-saas-freelance-devis/`)
- Example webapp a project_type webapp

**Verdict v2.0** : 11/11 PASS

## Scénario B — Site vitrine (LITE)

**Profil débutant** : un coach business veut un site 4 pages avec formulaire de contact. Pas de BDD, pas d'auth. Stack Next.js + Vercel + Resend.

**Friction Round 1** : "le kit force /design même si je n'ai pas vraiment d'UI à designer" → résolu par Request Classification LITE (skip /design + PRD réduit 3 sections).

**Checks** (5/5) :
- Example site existe (`examples/site-vitrine-coach/`)
- Example site a project_type: site
- Example site est niveau LITE
- PRD example site a max 1-2 phases
- /architect mentionne LITE/STANDARD/FULL

**Verdict v2.0** : 5/5 PASS

## Scénario C — Automation n8n

**Profil débutant** : un IAPreneur veut automatiser sa veille IA via un workflow n8n (RSS → Claude → Slack). Pas d'UI front, pas d'utilisateurs interactifs.

**Friction Round 1** : "le kit me pose des questions UI alors que mon projet n'a pas d'UI" → résolu par `/plan` adaptatif project_type (questions automation : trigger, credentials externes, idempotence ; web-app-centric retirées).

**Checks** (4/4) :
- Example automation existe (`examples/automation-n8n-veille-rss/`)
- Example automation a project_type: automation
- /plan adapte questions selon project_type automation
- /livrer supporte automation (activation workflow n8n)

**Verdict v2.0** : 4/4 PASS

## Scénario D — Reprise (prime)

**Profil débutant** : un IAPreneur ouvre une session de travail sur son projet existant (matin, après pause, ou retour J+15). Il veut recharger le contexte avant de continuer.

**Friction Round 1** : "je dois relire le PRD à la main pour me souvenir" → résolu par `/prime` (renommé depuis l'ancien skill *recap* en v2.1.0) qui lit PRD + STRUCTURE.md + plans (`docs/plans/` priorité, fallback `plans/` puis racine) + git log + MEMORY.md et propose 1-3 actions concrètes. `/start` détecte automatiquement les projets existants et bifurque vers `/prime`.

**Checks** (6/6) :
- /prime existe (ex-recap)
- l'ancien skill recap n'existe plus (renommé en /prime)
- /prime lit PRD/plans/git log (≥ 3 mentions)
- /start bifurque vers /prime si projet existant
- /prime lit MEMORY.md (mémoire persistante)
- /prime lit STRUCTURE.md (carte d'architecture v2.1.0)

**Verdict v2.1.0** : 6/6 PASS

## Anti-régressions Round 1

**Vérifications déterministes** que les frictions identifiées par le challenge Round 1 ne sont pas résurgentes :

| Check | Status |
|-------|--------|
| Pas de mention Dipler dans le kit (sauf CHANGELOG historique) | ✅ |
| Pas de skill nommé `/init` (collision built-in Claude Code) | ✅ |
| Pas de skill `/resume` (collision built-in) | ✅ |
| Pas de skill `/debug` custom (utilise natif Claude Code) | ✅ |
| Vocabulaire "un/le skill" masculin partout (jamais féminin) | ✅ |

## Structure mémoire (Phase H)

| Check | Status |
|-------|--------|
| `memory/learnings/` existe | ✅ |
| `memory/topics/` existe | ✅ |
| `memory/decisions.md` existe | ✅ |
| `MEMORY.md` racine existe | ✅ |
| `/close` fait le harvest learnings | ✅ |

## CLAUDE.md template

| Check | Status |
|-------|--------|
| Glossaire présent | ✅ |
| project_type documenté | ✅ |
| Request Classification documenté | ✅ |
| Ancre `<!-- design:summary -->` | ✅ |
| Ancre `<!-- ship:url -->` | ✅ |
| Règle 6 Auto-évaluation | ✅ |
| Section Mémoire persistante | ✅ |
| `tmp/` directory exists | ✅ |
| `tmp/` in `.gitignore` | ✅ |

## Verdict global

**44 / 44 PASS** — Kit v2.0.0 validé.

Tous les scénarios passent leurs checks (≥ 8/10 cible respectée : A=100%, B=100%, C=100%, D=100%). Aucune régression Round 1 résurgente. Structure mémoire opérationnelle.

## Méthode (rappel)

Le script `validate-kit-v2.sh` est **déterministe** (grep/test, pas de jugement LLM). Verdict reproductible : `bash scripts/validate-kit-v2.sh` retourne `exit 0` si tous PASS, `exit 1` si au moins un FAIL. Logs en stdout.

Pas de simulation mentale. Pas de "ça devrait marcher". Si un check échoue, le terminal le dit, et le commit/tag est bloqué jusqu'à fix.
