---
name: brainstorm
description: Utiliser quand l'utilisateur a une idée vague ou floue, soit pour un nouveau projet ("j'aimerais une app pour..."), soit pour une nouvelle feature sur un projet existant ("j'ai envie d'ajouter un dashboard à mon app..."). Le skill détecte le contexte (PRD.md présent ou non) et adapte ses questions + son handoff. Ne PAS utiliser si l'idée est déjà précise — passer direct à /architect (greenfield) ou /evoluer (feature). Sortie — fichier `docs/brainstorms/{date}-{sujet}.md` (greenfield) ou `docs/brainstorms/{date}-feature-{slug}.md` (feature).
---

# Skill /brainstorm — clarifier une idée vague (greenfield OU feature)

## Pour quoi faire

L'utilisateur a une idée mais elle n'est pas claire. Tu poses **3 questions max** pour clarifier, puis tu produis un brief en bullet points actionnables. Deux modes :

- **Mode greenfield** : pas de PRD encore, idée de projet neuf → brief alimente `/architect`.
- **Mode feature** : PRD existant, idée de feature à greffer sur l'app → brief alimente `/evoluer` (ou plusieurs `/evoluer` si feature trop large).

Le mode est détecté à l'Étape 0 (auto + confirmation user) — pas une question à poser à froid.

## Comment procéder

### Étape 0 — détecter le mode (auto + confirmation)

Vérifier en parallèle :

```bash
test -f PRD.md && echo "has_prd"
grep -q "^## Stack" CLAUDE.md && echo "has_stack"
grep -A2 "<!-- ship:url -->" CLAUDE.md | grep -qE "https?://" && echo "is_shipped"
```

**Branches** :

| has_prd | Comportement |
|---------|--------------|
| ❌ | Mode **greenfield** silencieux — passer directement à l'Étape 1 standard |
| ✅ | Lire `PRD.md` (Vision + Section 3 Scope actuel + Section 4 Hors scope) puis **confirmer le mode** auprès de l'user (voir ci-dessous) |

**Confirmation user (si has_prd)** :

> "Je détecte le projet **{Vision en 1 phrase, extraite du PRD}** (livré le {date depuis `## Production`} | en cours). Tu brainstormes :
> - **(a) une nouvelle feature** à greffer sur ce projet → je passerai la main à `/evoluer`
> - **(b) un projet totalement nouveau / refonte** → je passerai la main à `/architect` (le PRD existant ne sera pas touché tant que tu ne lances pas `/architect` explicitement)
>
> Tu choisis ?"

Si choix (a) → mode **feature**. Si (b) → mode **greenfield**.

Si `PRD.md` est malformé (pas de section Vision lisible) → traiter comme greenfield, mais signaler à l'user.

### Étape 1 — comprendre le sujet

Reformule en 1 phrase ce que tu as compris. Demande confirmation :

> "Si je comprends bien, tu veux **{ce que j'ai compris}**. C'est ça ?"

Si l'utilisateur corrige, intègre la correction. Sinon, continue.

### Étape 2 — poser 3 questions max (questions adaptées au mode)

**Règle stricte** : 3 questions max. Pas 4. Pas 5.

#### Mode greenfield — 3 questions parmi 5 axes

Priorise selon le sujet :

1. **Pour qui ?** → "C'est pour toi tout seul, ton équipe, des clients, des inconnus ?"
2. **Pour quoi ?** → "Ça doit résoudre quel problème concret ? Tu peux me donner un exemple où ça t'aurait servi cette semaine ?"
3. **Combien ?** → "Combien de personnes vont l'utiliser en même temps ? 1, 10, 100, 1000 ?"
4. **Quoi d'abord ?** → "Si tu pouvais avoir UNE seule fonctionnalité à la fin de la journée, ce serait laquelle ?"
5. **Hors scope ?** → "Qu'est-ce qui est hors sujet, à ne PAS faire dans ce projet ?"

#### Mode feature — 3 questions adaptées

1. **Manque résolu** → "Quel manque ou friction de l'app actuelle veux-tu résoudre ? Donne-moi un moment cette semaine où ça t'aurait servi."
2. **Intégration UI/UX** → "Concrètement, où apparaît-elle dans l'app ? Nouvelle page, widget dans un écran existant, action sur l'écran X ?"
3. **Dépendances techniques** → "Elle dépend d'une nouvelle techno absente de la stack (n8n, paiement, email transactionnel, Drive, ...) ou elle reste dans ce que tu as déjà ?"

**Check supplémentaire en mode feature** : grep le sujet (case-insensitive, fuzzy) dans la section `## 4. Hors scope` du PRD. Si match → signaler à l'user : *"Cette feature semble déjà listée dans Hors scope du PRD — `/evoluer` saura la déplacer automatiquement."*

Si tu as besoin de plus de 3 questions, c'est que le sujet est trop large pour `/brainstorm` :
- En greenfield → propose `/architect` directement
- En feature → propose de découper en plusieurs sous-features (voir Étape 5 cas L)

### Étape 3 — proposer 2 routes (inchangé)

Une fois les réponses obtenues, propose :

> "OK, deux options :
> 1. **Je te fais le brief direct** avec ce qu'on a.
> 2. **On creuse encore** — je délègue à un sous-agent `research-delegate` qui va explorer le web, lire 5-10 sources (projets similaires, patterns établis, retours d'expérience), et me ramener une synthèse en 3-10 bullets. Ton contexte principal reste propre, je récupère juste l'essentiel.
>
> Tu préfères quoi ?"

Si route 2 :

```
Agent({
  subagent_type: "research-delegate",
  description: "Recherche projets similaires {sujet}",
  prompt: "Cherche sur le web 5-10 projets ou tutos qui font {résumé du brainstorm}. Pour chacun : (1) ce qu'ils font, (2) leur stack, (3) un piège ou retour d'expérience documenté. Sortie au format research-delegate standard."
})
```

Reprends la main avec la synthèse, ajoute-la sous une sous-section "Inspirations" du brief.

### Étape 4 — écrire le brief

`mkdir -p docs/brainstorms` si absent.

#### Mode greenfield → `docs/brainstorms/{YYYY-MM-DD}-{sujet}.md`

```markdown
# Brainstorm : {sujet}

## Idée en 1 phrase
{phrase claire}

## Pour qui
- {réponse Q1}

## Problème résolu
- {réponse Q2}

## Échelle attendue
- {réponse Q3 ou estimation}

## Première fonctionnalité (si une seule)
- {réponse Q4}

## Hors scope
- {réponse Q5 ou liste explicite}

## Prochaine étape
- [ ] /architect docs/brainstorms/{YYYY-MM-DD}-{sujet}.md
```

#### Mode feature → `docs/brainstorms/{YYYY-MM-DD}-feature-{slug}.md`

Slug = kebab-case du nom de la feature (3-5 mots max).

```markdown
# Brainstorm feature : {nom feature}

## Projet cible
{Vision extraite du PRD, 1 phrase} — voir `PRD.md`

## Manque résolu
- {réponse Q1, avec l'exemple concret de la semaine}

## Intégration dans l'app existante
- **Où elle apparaît** : {réponse Q2}
- **Touche au PRD existant** : {section(s) ## 3. Scope actuel concernée(s)}
- **Déjà listée dans Hors scope ?** : {oui (à flip via /evoluer) | non (ajout V_{n+1})}

## Dépendances techniques nouvelles
- {liste : n8n / Google Drive / Stripe / ... ou "aucune, stack actuelle suffit"}
- ⚠️ Si dépendance nouvelle : `/evoluer` Étape 4bis fera la gate live (install + validation MCP).

## Ampleur estimée
- {S | M | L}
  - **S** : 1 SPEC, 1 phase de plan, <1 journée — `/evoluer` direct
  - **M** : 1 SPEC, 2-3 phases de plan, 2-3 jours — `/evoluer` direct
  - **L** : multi-aspect, refonte d'un écran majeur, ou impact transverse stack — voir Prochaine étape

## Inspirations (si Étape 3 route 2)
{bullets research-delegate}

## Prochaine étape
{Voir Étape 5 du skill — selon ampleur S/M ou L}
```

### Étape 5 — handoff différencié

#### Mode greenfield

```
✅ Brief créé : docs/brainstorms/{YYYY-MM-DD}-{sujet}.md

Étapes suivantes pour repartir propre :
  1. /close    → commit + mise à jour STATUS.md
  2. /clear    → contexte vide
  3. /architect docs/brainstorms/{YYYY-MM-DD}-{sujet}.md
```

#### Mode feature, ampleur S ou M

```
✅ Brief feature créé : docs/brainstorms/{YYYY-MM-DD}-feature-{slug}.md

Étapes suivantes :
  1. /close    → commit + STATUS.md
  2. /clear    → contexte vide
  3. /evoluer  → relira ce brief + PRD + posera ses 3 questions de cadrage, créera SPEC daté
```

#### Mode feature, ampleur L (multi-aspect)

Présenter **deux chemins** à l'user, **il choisit** :

> "Ampleur L détectée. Deux chemins propres :
>
> **(a) Découper en N sous-features** (recommandé si la feature touche plusieurs écrans/domaines indépendants)
>   → tu enchaînes N fois `/evoluer`, 1 SPEC par sous-feature, PRD reste vivant et discipliné (cap 100L).
>   → Sous-features proposées d'après le brief : {liste 2-4 sous-features}
>
> **(b) Refonte explicite via `/architect`** (si la feature implique de revoir la Vision, les Personas, ou le Scope structurel du PRD)
>   → ⚠️ `/architect` réécrit `PRD.md` from scratch. Le PRD actuel sera sauvegardé en `PRD.{date}.backup.md` avant écrasement.
>   → À choisir uniquement si tu veux changer le cœur du projet, pas pour ajouter une grosse feature."

Selon la réponse, écrire le handoff approprié dans la section "Prochaine étape" du brief avant `/close`.

## Risque #1 — partir sans clarification

Si tu sautes les 3 questions et tu écris direct le brief avec tes hypothèses, tu vas générer un PRD/SPEC qui ne correspond à rien et l'utilisateur va devoir tout refaire. **Toujours poser les 3 questions, même si tu crois "avoir compris"**. Mieux vaut 5 minutes de questions que 2h de travail à jeter.

## Risque #2 — confondre les modes

Si tu pars en greenfield alors qu'un PRD existe, tu vas proposer `/architect` qui va écraser le PRD du projet. **Toujours faire l'Étape 0 de détection + confirmation user avant de poser les questions.** Pas de raccourci.

## Quand ne PAS utiliser ce skill

- L'utilisateur a déjà une idée claire ET pas de PRD → `/architect` direct
- L'utilisateur a déjà une idée claire ET un PRD existant → `/evoluer` direct
- L'utilisateur veut juste discuter/explorer sans rien produire → conversation libre, pas de skill
- Le sujet est énorme (refonte complète d'un produit non livré) → trop large, découper en sous-sujets

## Trace de fin

Avant d'afficher le handoff, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "brainstorm", "mode": "{greenfield|feature}", "artifact": "{chemin produit}", "next": "{commande suggérée}", "ts": "<ISO8601 UTC>"}
```

## Handoff

Voir Étape 5 — le handoff dépend du mode et de l'ampleur. Toujours respecter le rituel `/close → /clear → /{architect|evoluer}` (voir `docs/KIT.md § STATUS.md & rituel`).

**Prochaine étape** : selon mode détecté à l'Étape 0 — `/architect` (greenfield) ou `/evoluer` (feature S/M) ou choix user (feature L).
