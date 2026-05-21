# Contribuer au kit IAPreneurs Claude Code

> Tu utilises le kit et tu vois un truc à améliorer ? Merci d'avance. Le kit a un bus factor = 1 aujourd'hui (auteur solo : Brice Gachadoat) — toute contribution externe le rend plus solide.

## Avant d'ouvrir une PR

1. **Ouvre une issue d'abord** si ton changement modifie une signature de skill, une ancre HTML (`<!-- start:identité -->`, `<!-- architect:stack -->`, etc.), ou la structure d'un fichier généré (`PRD.md`, `DESIGN.md`, `STATUS.md`, `MEMORY.md`). Ces points sont des contrats inter-skills — si tu casses l'un, tu casses la chaîne.
2. **Pas besoin d'issue** pour : typos, clarifications de doc, ajout d'un check à `validate-kit.sh`, exemples supplémentaires dans `examples/`.

## Règles de contribution

- **Non-breaking par défaut** : le kit a des vidéos pédagogiques publiques tournées contre l'UX actuelle. Tout changement qui modifie ce qu'un débutant voit (questions posées, ordre d'étapes, format de sortie) doit être discuté en issue avec un argument explicite "pourquoi le breaking justifie le coût".
- **CI verte** : `bash scripts/validate-kit.sh && bash scripts/validate-kit-v2.sh` doit passer (38/38 + 148/148 PASS). La GitHub Action `.github/workflows/validate.yml` les exécute à chaque push.
- **CHANGELOG mis à jour** : toute PR ajoute une entrée datée dans `docs/CHANGELOG.md` sous le format `## v{X.Y.Z} — {YYYY-MM-DD}` avec les sections Ajouté / Modifié / Pourquoi / Non-breaking.
- **VERSION bumpé** : patch (`v2.8.X`) pour fixes/tooling, minor (`v2.Y.0`) pour nouveau skill non-breaking, major (`vX.0.0`) pour breaking change consensuel.
- **Cap descriptions frontmatter** : `description:` dans le YAML d'un SKILL.md doit faire ≤ 100 mots (warn) / < 120 (hard cap CI). Énonce *quand utiliser*, jamais *comment*.
- **Soft cap 200L par SKILL.md** : au-dessus, extrait le détail dans `.claude/skills/{skill}/references/*.md` (cf. la refacto Phase 1 v2.7.0). Le Check 8 de `validate-kit.sh` warn mais ne bloque pas — c'est un signal de discipline.

## Workflow

```bash
git checkout -b {feat|fix|chore}/v2.X.Y-{short-desc}
# … tes changements …
bash scripts/validate-kit.sh && bash scripts/validate-kit-v2.sh    # doivent passer
git commit -m "{type}({scope}): {what} — {why}"
git push -u origin {ta-branche}
gh pr create --base main
```

Format de commit conventionnel : `feat`, `fix`, `chore`, `docs`, `refactor`, `test`. Le body explique *pourquoi*, pas seulement *quoi*.

## Domaines où la contribution serait particulièrement utile

- **Exemples supplémentaires** dans `examples/` (autres stacks, autres `project_type`, autres workflows n8n)
- **Tests narratifs** : sessions réelles documentées au format `examples/{x}/SESSION.md` (cf. tuto A-Z dans `webapp-saas-freelance-devis/`)
- **Skills n8n** (à `.claude/skills/n8n/`) si tu trouves un pattern d'expression / config / workflow qui revient
- **Traduction QUICKSTART/README en anglais** (le kit est FR par design pour la communauté IAPreneurs, mais une version EN ouvre l'adoption)

## Ce que le kit ne deviendra pas

Pour cadrer les attentes :

- Pas une "plateforme" avec serveur central, dashboard, télémétrie. Le kit est un dossier de fichiers markdown.
- Pas un wrapper Claude Code propriétaire. Les skills sont du markdown lisible.
- Pas multi-langue par essence. La communauté cible est FR ; l'EN est possible mais secondaire.

## Contact

- Issues : https://github.com/BriGadja/iapreneurs-claude-code-kit/issues
- Auteur : Brice Gachadoat (`brice@sablia.io`)

## License

[MIT](LICENSE) — fais-en ce que tu veux. Si tu forkes et tu améliores, ouvre une PR amont stp.
