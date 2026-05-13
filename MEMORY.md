# Mémoire projet — index

> Ce fichier est l'**index de la mémoire persistante** de ton projet. Il est lu automatiquement par `/start` et `/prime` au démarrage d'une session, pour que Claude arrive avec le contexte projet déjà compris.
>
> **Tu n'édites pas ce fichier à la main.** C'est `/close` qui le maintient pendant la phase de harvest learnings post-commit.
>
> Format : entrées 1-ligne courtes (< 200 caractères). Chaque entrée renvoie à un fichier `memory/topics/{topic}.md` ou `memory/learnings/{date}.md` qui contient le détail.

## Topics (cumulatif, par domaine)

<!-- close:topics-index -->
{Vide au démarrage. Premiers exemples après quelques sessions :

- [auth](memory/topics/auth.md) — patterns d'authentification rencontrés (Supabase Auth, magic link, RLS policies)
- [n8n](memory/topics/n8n.md) — gotchas n8n (webhooks Stripe demandent rawBody, credentials Switch node)
- [deploy](memory/topics/deploy.md) — env vars critiques, smoke tests post-deploy
- [bugs](memory/topics/bugs.md) — bugs rencontrés et tests de régression écrits}
<!-- /close:topics-index -->

## Learnings (par session, daté)

<!-- close:learnings-index -->
{Vide au démarrage. Premiers exemples :

- [2026-05-15](memory/learnings/2026-05-15.md) — Phase 1 : squelette + formulaire public + insertion Supabase (3 commits, 4h)
- [2026-05-22](memory/learnings/2026-05-22.md) — Phase 2 : auth magic link + dashboard pro (5 commits, 6h)}
<!-- /close:learnings-index -->

## Décisions d'architecture

Voir [memory/decisions.md](memory/decisions.md) pour les choix d'arch durables (BDD, hosting, framework, etc.).

---

**Mode d'emploi** :
- À chaque `/close` de phase, propose 0-3 questions ciblées : "Une décision d'arch notable ? Un gotcha à retenir ? Un pattern réutilisable ?"
- Si tu réponds, `/close` écrit dans le fichier topic correspondant + met à jour cet index.
- Si tu skip, `/close` écrit juste l'auto-récap session dans `memory/learnings/{date}.md` (commits, fichiers modifiés, durée) — pas de pollution.
