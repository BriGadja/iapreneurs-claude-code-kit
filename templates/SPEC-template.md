<!--
SPEC pour une évolution. Frozen après /execute. Cap ~80 lignes.
Créé par /evoluer Étape 5b dans docs/specs/SPEC-{YYYY-MM-DD}-{slug}.md.
-->

# SPEC — {Nom de la feature}

> **Version cible** : V_{n+1}
> **Créé le** : {YYYY-MM-DD}
> **Status** : draft → ready → in-progress → frozen (post /execute)

## Feature

{2-4 phrases : ce que la feature fait, pour qui, dans quel contexte d'usage. Pas de motivation longue — juste la description fonctionnelle. Renvoie au PRD § Vision pour le pourquoi global.}

**Critère de succès (1 ligne)** : {comment on saura que c'est livré et utilisable}

## Examples

{1-3 exemples concrets d'usage, en flow utilisateur. Chaque exemple = un scénario user qui montre la feature en action.}

- **{Scénario 1}** : {user → action → résultat attendu}
- **{Scénario 2}** : {user → action → résultat attendu}

## Documentation

{Liens externes nécessaires : doc API tierce, RFC, papier, lib doc, exemple repo. Tout ce que l'agent /plan + /execute doit lire AVANT d'implémenter.}

- {Lien 1 — pourquoi pertinent}
- {Lien 2 — pourquoi pertinent}

## Considerations

{Pièges connus, contraintes spécifiques, edge cases anticipés, risques à surveiller. Ce que tu veux que l'implémenteur SACHE avant de plonger.}

- **Piège** : {description, ex: rate limit API à 100 req/min}
- **Contrainte** : {description, ex: doit fonctionner offline-first}
- **Edge case** : {description, ex: import de transcripts > 50 MB}
- **Risque** : {description, ex: hallucination LLM sur prix → validation humaine obligatoire}

---

> **Après /execute & /validate** : ajouter `<!-- frozen: {YYYY-MM-DD} -->` en tête (posé par /close Étape 6.4).
