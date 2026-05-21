# Harvest learnings — auto-récap silencieux (Étape 6)

> **Lis ce fichier à l'Étape 6 du SKILL.md** (mode **full** uniquement — skip en planning).
>
> But : capturer ce que la session a produit **sans poser de question à l'utilisateur**. Les gens veulent ship vite, pas répondre à 3 questions admin à chaque clôture.

> **Boucle externe (vocabulaire kit v2.1.0)** : la **boucle interne** (PIV : `/prime → /plan → /execute → /validate → /close`) résout la feature courante ; la **boucle externe** ici cristallise ce que la session t'a appris en mémoire persistante, **passivement, sans bloquer l'utilisateur**. Si l'utilisateur veut explicitement capturer une décision, il dit "remember X" en cours de session — c'est tout.

## 6.1 — Auto-récap session (toujours écrit, silencieux)

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

## 6.2 — Topics opt-in (uniquement sur demande explicite)

**Skippé par défaut.** Aucune question posée à l'utilisateur. Aucune détection de trigger automatique.

Si l'utilisateur a explicitement demandé en cours de session de "capturer" / "remember" / "noter" quelque chose (mot-clé clair, pas du devinement), tu peux écrire dans `memory/topics/{domaine}.md` au moment où il l'a demandé — pas à la clôture.

Pour les décisions d'architecture significatives écrites par `/evoluer` dans `memory/decisions.md`, le fichier est déjà mis à jour par `/evoluer` — `/close` n'a rien à ajouter.

## 6.3 — Update MEMORY.md index (conditionnel, silencieux)

Si `memory/topics/` ou `memory/decisions.md` ont été modifiés **par d'autres skills** (pas par `/close`) depuis le dernier commit (`git diff --name-only HEAD~1..HEAD` les montre), refresh `MEMORY.md` à la racine en ajoutant les liens correspondants sous les ancres `<!-- close:topics-index -->` et `<!-- close:learnings-index -->`. Idempotent : skip si déjà présent.

Aucune action si rien n'a bougé dans `memory/`.

## 6.4 — Pas d'annonce

Pas de "Mémoire mise à jour : ...". L'auto-récap 6.1 est silencieux. Si tu veux mentionner quelque chose dans le handoff final, ajoute juste `💾 récap session écrit` en bullet de Étape 7 (1 ligne, pas plus). Si rien d'autre n'a été écrit, ne mentionne rien.

## Retour au SKILL.md

Une fois 6.1 (et éventuellement 6.3) terminés, retourne à l'Étape 6.4 du SKILL.md (SPEC frozen header) puis 6.5 (gate déploiement Vercel).
