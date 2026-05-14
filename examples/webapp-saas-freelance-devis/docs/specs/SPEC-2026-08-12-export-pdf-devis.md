<!--
SPEC pour une évolution. Frozen après /execute. Cap ~80 lignes.
Créé par /evoluer Étape 5b.
-->

# SPEC — Export PDF devis côté client

> **Version cible** : V_2
> **Créé le** : 2026-08-12
> **Status** : draft → ready → in-progress → frozen (post /execute)

## Feature

Permettre au freelance de prévisualiser et exporter un devis en PDF **directement depuis le navigateur** sans repasser par n8n (gain de latence : 1s vs 15s actuel). Le PDF côté client réutilise le même template HTML que n8n + une lib JS (`@react-pdf/renderer` ou `jspdf`). L'envoi email reste côté n8n (mention légales + signature SMTP). Renvoie au PRD § 6 critère "freelance peut générer + envoyer en < 5 min".

**Critère de succès (1 ligne)** : un freelance peut prévisualiser un PDF de devis en < 2 secondes dans son navigateur sans appel réseau.

## Examples

- **Scénario 1 — prévisualisation rapide** : freelance ajuste un montant → clique "Aperçu PDF" → PDF s'ouvre dans un onglet en < 2s
- **Scénario 2 — export local** : freelance clique "Télécharger PDF" → fichier `devis-{client}-{date}.pdf` téléchargé localement (utile pour archive perso avant envoi)
- **Scénario 3 — flow d'envoi inchangé** : freelance clique "Envoyer par email" → toujours n8n + Resend (PDF généré côté serveur pour mentions légales signées)

## Documentation

- `@react-pdf/renderer` v4 docs — https://react-pdf.org/
- `jspdf` v3 docs — https://artskydj.github.io/jsPDF/docs/jsPDF.html
- Article comparant les 2 libs : https://blog.logrocket.com/jspdf-react-pdf/
- Template HTML actuel du devis (n8n) : `n8n/devis-template.html` (à porter en composant React)

## Considerations

- **Piège** : fonts custom non chargées → PDF rendu avec fallback. Embed les fonts en base64 dans le bundle.
- **Contrainte** : mentions légales obligatoires (SIRET, RCS, TVA, conditions, validité) — DOIVENT être identiques entre version client et version serveur. Tester avec snapshot.
- **Edge case** : devis > 3 pages (commentaires longs, multi-prestations) → pagination correcte sans coupure intempestive.
- **Risque** : divergence PDF client/serveur si template évolue d'un côté seulement → **Mitigation** : test E2E snapshot qui compare les 2 outputs sur 3 devis références.
- **Risque** : bundle size +200KB (lib PDF) → **Mitigation** : code-split dynamique (`next/dynamic`), charger uniquement sur la page admin "édition devis".
