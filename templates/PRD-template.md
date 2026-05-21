<!--
PRD vivant discipliné. Cap 100 lignes hard.
Mis à jour par /evoluer (déplace checkboxes Hors scope → Scope actuel, append Implementation Phases).
JAMAIS réécrit destructivement.
-->

# PRD — {Nom du projet}

## 1. Vision

{1-3 phrases. Ce que le projet livre, à qui, pour quel résultat. Pas de marketing — la phrase qui aligne toutes les décisions futures.}

## 2. Personas

{1-3 personas courts. Pour chacun : qui (rôle), contexte d'usage, douleur résolue. Pas de fiche détaillée — juste assez pour cadrer les choix UX.}

- **{Persona 1}** — {rôle}. {Contexte}. Douleur : {douleur}.
- **{Persona 2}** — {rôle}. {Contexte}. Douleur : {douleur}.

## 3. Scope actuel (V_n)

> Ce qui est dans la version courante. Cochée = livré. Mis à jour par `/evoluer` (déplace les `[x]` Hors scope → ici).

### Core
- [ ] {Feature core 1}
- [ ] {Feature core 2}

### Technique
- [ ] {Pattern infra 1 — ex: Auth Supabase + RLS}
- [ ] {Pattern infra 2}

## 4. Hors scope (différé)

> Volontairement reporté. Cocher = on l'apporte maintenant, `/evoluer` la déplacera vers Scope actuel.

- [ ] {Feature différée 1 — pourquoi reportée en 1 ligne}
- [ ] {Feature différée 2}

## 5. Constraints non-négociables

{Contraintes métier, légales, perf, sécurité qui ne bougeront pas. Si quelque chose est ici, aucune décision tech ne peut le contredire.}

- {Contrainte 1 — ex: RLS obligatoire sur toutes les tables clients}
- {Contrainte 2 — ex: Pas d'envoi auto d'email, validation humaine requise}

## 6. Success Criteria

{Critères mesurables de réussite globale du projet. Pas par feature — au niveau projet entier.}

- {Critère 1 — ex: Un freelance peut générer + envoyer un devis en < 5 min}
- {Critère 2 — ex: 0 leak de data cross-tenant détecté en audit RLS}

## 7. Implementation Phases

> Historique chronologique des versions livrées + en cours + envisagées. Append-only par `/evoluer` Étape 5e.

- **V1 (livré le {YYYY-MM-DD})** — {résumé 1 ligne de ce qui a été livré en V1}
- **V_n (en cours)** — {feature courante, cf docs/specs/SPEC-{date}-{slug}.md}
- **V_n+1 (envisagé)** — {feature future probable, sans engagement}

## 8. Risks & Mitigations

{Risques identifiés à l'init + mitigations prévues. Mis à jour si un risque se matérialise ou disparaît.}

- **Risque** : {description} → **Mitigation** : {action}
- **Risque** : {description} → **Mitigation** : {action}
