---
name: brainstorm
description: Utiliser quand l'utilisateur a une idée vague ou floue à explorer, soit pour un nouveau projet ("j'aimerais une app pour…"), soit pour une feature à ajouter ("j'ai envie d'ajouter du SMS à mon Hub Documents"). Produit un brief de cadrage écrit dans docs/brainstorms/{date}-{slug}.md. Ne PAS utiliser si l'idée est déjà claire — passer direct à /architect (greenfield) ou /evoluer (feature). N'opère aucun routing automatique — c'est l'utilisateur qui choisit la suite (/architect, /plan, ou /evoluer) avec le brief en argument.
---

# Skill /brainstorm — clarifier une idée vague (réflexion pure, sans routing auto)

## Pour quoi faire

L'utilisateur a une idée mais elle n'est pas claire. Ton rôle :

1. **Dialoguer** pour clarifier le besoin (3-5 questions ciblées).
2. **Rechercher** si nécessaire (sous-agent, optionnel).
3. **Synthétiser** un brief écrit dans `docs/brainstorms/{date}-{slug}.md`.
4. **Proposer** un handoff explicite à l'utilisateur (3 options) — JAMAIS de routing automatique.

Ce skill ne décide pas à la place de l'utilisateur. Pas de détection PRD → /evoluer auto, pas de mot-clé "refonte" → /architect auto. L'utilisateur lit le brief et choisit lui-même.

## Comment procéder

### Phase A — Dialogue (3-5 questions)

#### A.1 — Reformuler le sujet (1 phrase)

> "Si je comprends bien, tu veux **{reformulation}**. C'est ça ?"

Si l'utilisateur corrige, intègre la correction.

#### A.2 — Poser 3 à 5 questions ciblées (une par une, pas en bloc)

**Règle stricte** : 5 questions max. Si tu as besoin de plus, le sujet est trop large pour `/brainstorm` — propose à l'utilisateur de découper.

Pioche dans ces 5 axes selon ce qui manque le plus de clarté :

1. **Pour qui ?** — "C'est pour toi tout seul, ton équipe, des clients, le grand public ?"
2. **Pour quoi ?** — "Quel problème concret ça résout ? Donne-moi un exemple où ça t'aurait servi cette semaine."
3. **Contexte existant ?** — "C'est un projet from-scratch, une feature à greffer sur une app existante, ou un cadrage d'une tâche d'un projet en cours ?"
4. **Contraintes connues ?** — "Y a-t-il des contraintes que tu connais déjà (budget, deadline, stack imposée, intégrations obligatoires) ?"
5. **Échecs précédents ?** — "Tu as déjà essayé une approche qui n'a pas marché ? Si oui, qu'est-ce qui a bloqué ?"

Adapte l'ordre et les formulations. Si l'utilisateur a déjà répondu à une question dans sa demande initiale, ne la repose pas.

### Phase B — Recherche (optionnelle)

Si après les questions tu juges que des références externes manqueraient (concurrents, patterns établis, retours d'expérience documentés), propose :

> "Tu veux que je creuse un peu ? Je peux déléguer à un sous-agent `research-delegate` qui va explorer le web, lire 5-10 sources, et me ramener une synthèse en 3-10 bullets. Ton contexte principal reste propre, je récupère juste l'essentiel. Tu préfères qu'on continue direct ou qu'on creuse ?"

Si l'utilisateur veut creuser :

```
Agent({
  subagent_type: "research-delegate",
  description: "Recherche {sujet}",
  prompt: "Cherche sur le web 5-10 projets/outils/articles qui font {résumé du brainstorm}. Pour chacun : (1) ce qu'ils font, (2) leur stack si pertinent, (3) un piège ou retour d'expérience documenté. Sortie au format research-delegate standard."
})
```

Tu peux aussi explorer la codebase actuelle (`Read`, `Grep`) si l'idée touche à du code existant — utile en mode feature pour repérer les points d'intégration.

Si tu juges la recherche inutile (idée déjà bien cadrée), passe direct à Phase C.

### Phase C — Synthèse du brief

`mkdir -p docs/brainstorms` si absent.

Choisis un slug kebab-case court (3-5 mots) à partir du sujet. Format du fichier : `docs/brainstorms/{YYYY-MM-DD}-{slug}.md`.

Structure du brief :

```markdown
# Brainstorm : {sujet}

## Idée en 1 phrase
{phrase claire issue de la reformulation Phase A.1}

## Besoin clarifié
- {réponse Q "pour qui"}
- {réponse Q "pour quoi" — avec l'exemple concret}
- {réponse Q "contexte" — projet neuf / feature / tâche d'un projet en cours}

## Contraintes connues
- {réponse Q "contraintes" ou "aucune connue"}

## Alternatives explorées
- {alternative 1 envisagée + pourquoi écartée ou retenue}
- {alternative 2 si pertinent}
- {ou "aucune alternative pertinente identifiée"}

## Direction recommandée
- {1-3 bullets : ce qui semble la voie la plus solide selon les réponses}

## Hypothèses encore à valider
- [ ] {hypothèse 1 à confirmer en plan/architect/evoluer}
- [ ] {hypothèse 2}

## Inspirations (si Phase B faite)
{bullets research-delegate ou exploration codebase}

## Prochaine étape suggérée
{Voir Phase D du skill — handoff explicite à l'utilisateur, JAMAIS de routing auto.}
```

Écris le fichier. Affiche son chemin.

### Phase D — Handoff explicite (l'utilisateur choisit)

Annonce :

```
✅ Brief créé : docs/brainstorms/{YYYY-MM-DD}-{slug}.md

Étapes suivantes pour repartir propre :
  1. /close    → commit du brief + STATUS.md
  2. /clear    → contexte vide
  3. /{architect|plan|evoluer} docs/brainstorms/{YYYY-MM-DD}-{slug}.md (au choix, voir ci-dessous)

Selon ce qu'on a dégagé, voici la suite logique. **C'est toi qui choisis** :

1. **Nouveau projet from-scratch** (pas de PRD encore)
   → `/architect docs/brainstorms/{YYYY-MM-DD}-{slug}.md`
   /architect lira le brief, pré-remplira ses 3 questions de cadrage, et produira PRD.md.

2. **Feature à ajouter à un projet existant livré** (PRD présent, phases ✅ Terminées)
   → `/evoluer docs/brainstorms/{YYYY-MM-DD}-{slug}.md`
   /evoluer lira le brief, fera son Étape 1bis (lecture PRD + 3 derniers SPECs), et créera le SPEC daté.

3. **Tâche à cadrer dans un projet en cours** (PRD présent, phase actuelle non terminée)
   → `/plan docs/brainstorms/{YYYY-MM-DD}-{slug}.md`
   /plan lira le brief et l'utilisera comme contexte pour découper la prochaine phase.

Quelle direction ?
```

Attends la réponse de l'utilisateur. Ne route PAS automatiquement vers l'une des trois options — c'est l'utilisateur qui tape la commande.

**Règle d'or** : ce skill n'a aucune branche conditionnelle qui décide à la place de l'utilisateur. Pas de détection PRD → /evoluer auto. Pas de mot-clé "refonte" → /architect auto. La décision appartient à l'utilisateur.

## Risque #1 — partir sans clarification

Si tu sautes les questions Phase A et tu écris direct le brief avec tes hypothèses, tu vas générer un brief qui ne correspond à rien et l'utilisateur va devoir tout refaire. **Toujours poser au moins 3 questions, même si tu crois "avoir compris"**.

## Risque #2 — re-introduire du routing automatique

Si tu ajoutes une branche "si PRD.md existe alors handoff /evoluer" ou "si l'utilisateur dit 'refonte' alors handoff /architect", tu reproduis le bug v2.7.0 que cette refonte v2.8.0 corrige précisément. L'utilisateur lit le brief et choisit — c'est tout.

## Quand ne PAS utiliser ce skill

- L'utilisateur a déjà une idée claire ET pas de PRD → `/architect` direct (avec ou sans brief)
- L'utilisateur a déjà une idée claire ET un PRD existant → `/evoluer` direct
- L'utilisateur veut juste discuter/explorer sans rien produire → conversation libre, pas de skill
- Le sujet est énorme (refonte complète d'un produit non livré) → trop large, propose de le découper

## Trace de fin

Avant d'afficher le handoff Phase D, append une ligne JSON à `tmp/skill-trace.jsonl` (créer le fichier et le dossier `tmp/` si absent) :

```json
{"skill": "brainstorm", "artifact": "docs/brainstorms/{YYYY-MM-DD}-{slug}.md", "next": "user-choice", "ts": "<ISO8601 UTC>"}
```

## Handoff

Voir Phase D — le handoff est explicite : l'utilisateur choisit `/architect`, `/plan` ou `/evoluer` avec le brief path en argument. Rituel : `/close → /clear → /{architect|plan|evoluer} docs/brainstorms/...`.

**Prochaine étape** : choix utilisateur entre `/architect`, `/plan` ou `/evoluer` (Phase D).
