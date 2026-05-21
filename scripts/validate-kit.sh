#!/usr/bin/env bash
# validate-kit.sh — lint déterministe des invariants structurels du kit
#
# Complémentaire à scripts/validate-kit-v2.sh (qui vérifie le contenu des skills).
# Ici on vérifie la structure : ancres appariées, handoff terminal, gitignore,
# cross-refs Étape, description frontmatter cap, .mcp.json gitignored.
#
# Usage :
#   bash scripts/validate-kit.sh           — run tous les checks, exit 0 si PASS
#   bash scripts/validate-kit.sh --self-test  — casse temporairement un invariant
#                                              + vérifie exit 1 + restaure
#
# Exit code : 0 si tous les checks PASS, 1 sinon.

set -u
cd "$(dirname "$0")/.."

PASS=0
FAIL=0
TOTAL=0
ERRORS=()

check() {
  local label="$1"
  local cmd="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  ✅ $label"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $label"
    FAIL=$((FAIL + 1))
    ERRORS+=("$label")
  fi
}

# ─────────────────────────────────────────────────────────────────────────
# Self-test mode : casse un invariant + relance + restaure
# ─────────────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--self-test" ]; then
  echo ""
  echo "═══ Self-test mode ═══"
  echo "Étape 1 : ajout d'une ancre orpheline dans STATUS.md."
  TARGET="STATUS.md"
  if [ ! -f "$TARGET" ]; then
    echo "❌ Self-test impossible : $TARGET introuvable."
    exit 1
  fi
  # Sauvegarde
  cp "$TARGET" "$TARGET.bak"
  # Injection : ajoute <!-- broken:anchor --> sans fermante en fin de fichier
  printf '\n<!-- broken:anchor -->\n' >> "$TARGET"

  echo "Étape 2 : relance du script en mode normal (doit exit 1)."
  set +e
  bash "$0" >/dev/null 2>&1
  RC=$?
  set -e
  # Restaure immédiatement (que le test passe ou non)
  mv "$TARGET.bak" "$TARGET"

  if [ "$RC" -eq 0 ]; then
    echo "❌ Self-test failed : le script a retourné 0 sur un invariant cassé (ancre orpheline)."
    exit 1
  else
    echo "✅ Self-test PASS : ancre orpheline détectée, exit 1 confirmé, fichier restauré."
    exit 0
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  validate-kit.sh — invariants structurels"
echo "═══════════════════════════════════════════════════════════"

# ─────────────────────────────────────────────────────────────────────────
# Check 1 — Toutes les ancres <!-- skill:section --> ont leur fermante
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ Check 1 — Ancres HTML appariées ═══"
# Pattern : <!-- name:section --> (open) doit avoir <!-- /name:section --> (close)
# Ne traite que les ancres qui contiennent ":" (skill:section), pas les ancres
# de directive (ex: <!-- power-users-fallback: ... -->).
# On scanne les fichiers qui contiennent typiquement des ancres écrites par les skills.
ANCHOR_FILES="CLAUDE.md.template STATUS.md STRUCTURE.md MEMORY.md templates/PRD-template.md templates/SPEC-template.md"
anchor_issues=0
for f in $ANCHOR_FILES; do
  [ -f "$f" ] || continue
  # Liste des noms d'ancres ouvrantes (sans le / initial) — un par ligne, dédupliqués.
  # On exclut les lignes où l'ancre est dans un span inline `<!-- ... -->` (= exemple, pas vraie ancre).
  opens=$(grep -nE '<!--[[:space:]]+[a-z][a-z-]+:[a-z][a-z-]+[[:space:]]+-->' "$f" 2>/dev/null \
    | grep -v '`<!--' \
    | grep -oE '<!--[[:space:]]+[a-z][a-z-]+:[a-z][a-z-]+[[:space:]]+-->' \
    | sed -E 's|<!--[[:space:]]+([a-z][a-z-]+:[a-z][a-z-]+)[[:space:]]+-->|\1|' \
    | sort -u)
  while IFS= read -r name; do
    [ -z "$name" ] && continue
    if ! grep -qE "<!--[[:space:]]+/${name}[[:space:]]+-->" "$f" 2>/dev/null; then
      echo "  ❌ $f : ancre ouvrante <!-- $name --> sans fermante <!-- /$name -->"
      anchor_issues=$((anchor_issues + 1))
      ERRORS+=("$f : ancre orpheline $name")
    fi
  done <<< "$opens"
done
TOTAL=$((TOTAL + 1))
if [ "$anchor_issues" -eq 0 ]; then
  echo "  ✅ Toutes les ancres ouvertes ont leur fermante dans le même fichier"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# ─────────────────────────────────────────────────────────────────────────
# Check 2 — Chaque SKILL.md termine par "**Prochaine étape**:"
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ Check 2 — Handoff terminal **Prochaine étape**: ═══"
for skill in .claude/skills/*/SKILL.md; do
  if grep -q '\*\*Prochaine étape\*\*' "$skill"; then
    check "$skill termine par '**Prochaine étape**:'" "true"
  else
    check "$skill termine par '**Prochaine étape**:'" "false"
  fi
done

# ─────────────────────────────────────────────────────────────────────────
# Check 3 — tmp/ dans .gitignore
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ Check 3 — tmp/ dans .gitignore ═══"
check "tmp/ ou tmp/* dans .gitignore" "grep -qE '^tmp/' .gitignore"

# ─────────────────────────────────────────────────────────────────────────
# Check 4 — Cross-refs /{skill} Étape {N}{lettre} pointent vers des étapes existantes
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ Check 4 — Cross-refs Étape vers étapes existantes ═══"
# Parse toutes les références "/skill Étape N(.lettre)?" dans tous les SKILL.md
# Pour chaque ref, vérifier que le skill cible contient un heading "### Étape N..."
# ou mentionne au moins "Étape N" dans son texte.

# Liste des refs : on grep "/{skill} Étape {N}..."
cross_refs=$(grep -rhEo '/(start|brainstorm|architect|design|plan|execute|validate|close|livrer|evoluer|challenge|prime|debug) Étape [0-9]+(\.[0-9a-z]+)?' .claude/skills/ 2>/dev/null | sort -u)

while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  # ref ex: "/livrer Étape 3.5"
  skill_name=$(echo "$ref" | sed -E 's|^/([a-z]+) Étape.*|\1|')
  etape=$(echo "$ref" | sed -E 's|^/[a-z]+ Étape (.+)|\1|')
  target_skill=".claude/skills/${skill_name}/SKILL.md"

  if [ ! -f "$target_skill" ]; then
    # skill cible inexistant (ex: /debug est natif) → skip silencieux
    continue
  fi

  # Cherche "Étape {etape}" dans le skill cible (texte ou heading)
  if grep -qE "Étape ${etape}([^0-9]|$)" "$target_skill"; then
    check "$ref → trouvée dans $target_skill" "true"
  else
    check "$ref → trouvée dans $target_skill" "false"
  fi
done <<< "$cross_refs"

# ─────────────────────────────────────────────────────────────────────────
# Check 5 — Description frontmatter cap : warn à >= 100 mots, fail à >= 120
# ─────────────────────────────────────────────────────────────────────────
# Le cap "soft" est 100 mots (lisibilité + Rule CSO/skill-description-hygiene).
# Le cap "hard" est 120 — au-delà, la description est trop longue et risque
# d'être tronquée ou de leak des steps de workflow (anti-pattern Rule 10).
# Entre 100 et 120 : warning informatif, pas d'échec.
echo ""
echo "═══ Check 5 — Description frontmatter cap (soft 100 / hard 120 mots) ═══"
for skill in .claude/skills/*/SKILL.md; do
  desc=$(awk '/^---$/{count++; next} count==1 && /^description:/' "$skill" | sed -E 's/^description:[[:space:]]*//')
  word_count=$(echo "$desc" | wc -w | tr -d ' ')
  if [ "$word_count" -lt 100 ]; then
    check "$skill description = $word_count mots (< 100)" "true"
  elif [ "$word_count" -lt 120 ]; then
    TOTAL=$((TOTAL + 1))
    PASS=$((PASS + 1))
    echo "  ⚠️  $skill description = $word_count mots (>= 100, warn — à slim quand possible)"
  else
    check "$skill description = $word_count mots (HARD CAP DÉPASSÉ, >= 120)" "false"
  fi
done

# ─────────────────────────────────────────────────────────────────────────
# Check 6 — .mcp.json gitignored (pattern canonique du kit)
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ Check 6 — .mcp.json gitignored (pattern canonique) ═══"
check ".mcp.json dans .gitignore" "grep -qE '^\\.mcp\\.json$' .gitignore"
check ".mcp.json NON tracké par git" "[ -z \"\$(git ls-files .mcp.json)\" ]"
check ".mcp.json.example tracké (template)" "[ -n \"\$(git ls-files .mcp.json.example)\" ]"

# ─────────────────────────────────────────────────────────────────────────
# Check 7 — VERSION cohérent entre fichier racine, README et CHANGELOG
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══ Check 7 — VERSION cohérent (fichier racine ↔ CHANGELOG) ═══"
ROOT_VERSION=$(cat VERSION 2>/dev/null | tr -d ' \n')
if [ -z "$ROOT_VERSION" ]; then
  check "fichier VERSION lisible et non-vide" "false"
else
  check "fichier VERSION = $ROOT_VERSION" "true"
  # CHANGELOG doit contenir une section pour cette version au top
  check "docs/CHANGELOG.md contient une section '## $ROOT_VERSION'" "grep -qE '^## '\"$ROOT_VERSION\"'( |$)' docs/CHANGELOG.md"
fi

# ─────────────────────────────────────────────────────────────────────────
# Check 8 — Soft cap 200 lignes par SKILL.md (warning, pas fail)
# ─────────────────────────────────────────────────────────────────────────
# Au-dessus de 200L, la densité comportementale dégrade le respect des
# instructions LLM. C'est un signal de discipline, pas un blocage — il
# faut pouvoir refactor sans subir d'urgence CI.
echo ""
echo "═══ Check 8 — Soft cap 200L par SKILL.md (warn only) ═══"
soft_warn=0
for skill in .claude/skills/*/SKILL.md; do
  lines=$(wc -l < "$skill" | tr -d ' ')
  if [ "$lines" -gt 200 ]; then
    echo "  ⚠️  $skill = $lines lignes (>200 — candidat refacto references/)"
    soft_warn=$((soft_warn + 1))
  fi
done
TOTAL=$((TOTAL + 1))
PASS=$((PASS + 1))
if [ "$soft_warn" -eq 0 ]; then
  echo "  ✅ Tous les SKILL.md ≤ 200L"
else
  echo "  → $soft_warn SKILL.md > 200L (warning, ne bloque pas la CI)"
fi

# ─────────────────────────────────────────────────────────────────────────
# Check 9 — Liens markdown internes cassés (README, docs/, CLAUDE.md.template)
# ─────────────────────────────────────────────────────────────────────────
# On scanne les liens markdown relatifs [text](path) dans les fichiers doc
# racine et vérifie que la cible existe. URLs externes (http/https) skip.
echo ""
echo "═══ Check 9 — Liens markdown internes (README + docs/ + CLAUDE.md.template) ═══"
LINK_FILES="README.md QUICKSTART.md CLAUDE.md.template"
[ -d docs ] && LINK_FILES="$LINK_FILES $(find docs -maxdepth 2 -name '*.md' 2>/dev/null | tr '\n' ' ')"
broken_links=0
for f in $LINK_FILES; do
  [ -f "$f" ] || continue
  # extract [text](target) where target doesn't start with http or #
  while IFS= read -r target; do
    [ -z "$target" ] && continue
    # strip anchor fragment
    file_part="${target%%#*}"
    [ -z "$file_part" ] && continue
    # resolve relative to the file's directory
    dir=$(dirname "$f")
    if [ "$dir" = "." ]; then
      resolved="$file_part"
    else
      resolved="$dir/$file_part"
    fi
    if [ ! -e "$resolved" ]; then
      echo "  ❌ $f → lien cassé : $target"
      broken_links=$((broken_links + 1))
      ERRORS+=("$f : lien cassé $target")
    fi
  done < <(
    # strip inline code spans `...` to avoid matching backticked text like `](path)`
    # then extract real markdown links [text](target) where target doesn't start with http/mailto/#
    sed -E 's/`[^`]*`//g' "$f" 2>/dev/null \
      | grep -oE '\]\([^)]+\)' \
      | sed -E 's/^\]\(([^)]+)\)$/\1/' \
      | grep -vE '^(https?://|mailto:|#)'
  )
done
TOTAL=$((TOTAL + 1))
if [ "$broken_links" -eq 0 ]; then
  echo "  ✅ Aucun lien markdown interne cassé"
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
fi

# ─────────────────────────────────────────────────────────────────────────
# Verdict global
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Verdict : $PASS / $TOTAL PASS"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "❌ $FAIL checks ont échoué :"
  for err in "${ERRORS[@]}"; do
    echo "   - $err"
  done
  exit 1
fi

echo "✅ Tous les invariants structurels du kit sont OK."
exit 0
