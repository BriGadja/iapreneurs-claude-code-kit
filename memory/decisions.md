# Décisions d'architecture du projet

> Ce fichier accumule les **choix d'architecture durables** au fil du projet. Écrit par `/close` quand tu valides une décision arch notable pendant le harvest learnings.
>
> Format : un bullet par décision, avec date + 1-2 phrases de rationale. Pas de prose, pas de longue justification — la valeur est dans la trace.

## Décisions

<!-- close:decisions -->
{Vide au démarrage. Premier exemple après quelques sessions :

- **2026-05-15** — BDD : Supabase au lieu de Neon. Rationale : Auth + BDD + Realtime en un, RLS native, gratuit jusqu'à 500 MB suffisant pour le MVP.
- **2026-05-22** — Hosting : Vercel au lieu de Netlify. Rationale : meilleure intégration Next.js, déploiement preview par PR, gratuit pour projet perso.
- **2026-06-01** — Email transactionnel : Resend. Rationale : DX moderne (React Email), 3000 emails/mois gratuit, dépendance minimale.}
<!-- /close:decisions -->
