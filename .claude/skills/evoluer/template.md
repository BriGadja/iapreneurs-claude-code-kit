# Template d'une nouvelle Phase ajoutée par /evoluer

Ce fichier est le **template exact** qu'/evoluer utilise pour insérer une nouvelle Phase dans `PRD.md` existant. Format identique à celui des Phases initiales pour éviter la divergence.

## Format de la ligne Phase à insérer dans `## Phases`

```
- **Phase {N}** — {nom feature} : {1 phrase de description}
```

Où :
- `{N}` = dernier numéro de Phase trouvé + 1 (calculé par /evoluer via regex `^[\-\*]\s+\*\*Phase\s+(\d+)\*\*\s+—`)
- `{nom feature}` = réponse à la Q1 "Comment tu nommes cette feature ?" (slug court, max 4-5 mots)
- `{description}` = réponse à la Q2 "En une phrase, c'est quoi ?"

**Pas de marker `✅ Terminée`** (la phase démarre à l'état "à faire" — c'est `/close` qui ajoute ce marker après `/validate ✅`).

## Critères de succès à ajouter dans `## Critères de succès` (à la fin du fichier)

```
- [ ] {réponse Q3 "Quel est le critère qui fait que cette feature est réussie ?"}
```

Cette ligne est ajoutée **à la suite** des critères existants, dans la section `## Critères de succès` du PRD. Les critères des Phases précédentes restent intacts.

## Position d'insertion

| Section PRD | Action |
|-------------|--------|
| `## Phases` | Insère la nouvelle ligne **juste après la dernière Phase**, **avant** la section suivante (`## Stack technique` ou `## Hors-MVP` selon l'ordre du PRD) |
| `## Critères de succès` | Append la nouvelle ligne à la fin |

## Idempotence

Si une Phase au même `{nom feature}` (slug) existe déjà dans `## Phases`, **refuse** l'insertion avec le message :
> *"Une Phase '{nom feature}' existe déjà (Phase {numéro existant}). Soit tu choisis un autre nom, soit tu édites la Phase existante directement, soit tu confirmes que c'est une nouvelle Phase distincte malgré le nom proche."*

Pas d'insertion silencieuse, pas d'écrasement.
