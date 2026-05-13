#!/usr/bin/env bash
# validate-kit-v2.sh — script déterministe de validation du kit v2.1.0
# Vérifie par grep/test la présence des skills, ancres, examples, et l'absence
# des régressions Round 1 (Dipler, collision /init, RLS hardcoded).
#
# Usage : bash scripts/validate-kit-v2.sh
# Sortie : verdict /N PASS par scénario + verdict global

set -u
cd "$(dirname "$0")/.."

PASS=0
FAIL=0
TOTAL=0

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
  fi
}

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Validation kit IAPreneurs Claude Code v2.1.0"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "═══ Scénario A — Webapp SaaS (cycle complet) ═══"
check "/start existe" "test -f .claude/skills/start/SKILL.md"
check "/architect existe avec Étape 6 Provisioning" "grep -q 'Étape 6' .claude/skills/architect/SKILL.md"
check "/architect demande providers favoris (Étape 2b)" "grep -q '2b' .claude/skills/architect/SKILL.md"
check "/design existe" "test -f .claude/skills/design/SKILL.md"
check "/plan existe et adaptatif project_type" "test -f .claude/skills/plan/SKILL.md && grep -q 'project_type' .claude/skills/plan/SKILL.md"
check "/execute existe et ne marque PLUS ✅ Terminée" "test -f .claude/skills/execute/SKILL.md && grep -q 'Ne PAS marquer\|ne marque PAS' .claude/skills/execute/SKILL.md"
check "/validate existe avec audit policy BDD" "grep -qi 'RLS\|policy' .claude/skills/validate/SKILL.md"
check "/close existe (mandatory + harvest learnings)" "test -f .claude/skills/close/SKILL.md && grep -q 'mandatory' .claude/skills/close/SKILL.md && grep -q 'Harvest\|harvest' .claude/skills/close/SKILL.md"
check "/livrer existe et lit ## Stack (jamais hardcode)" "test -f .claude/skills/livrer/SKILL.md && grep -q '## Stack' .claude/skills/livrer/SKILL.md"
check "Example webapp existe" "test -d examples/webapp-saas-freelance-devis"
check "Example webapp a project_type" "grep -q 'project_type: webapp' examples/webapp-saas-freelance-devis/CLAUDE.md"

echo ""
echo "═══ Scénario B — Site vitrine (LITE) ═══"
check "Example site existe" "test -d examples/site-vitrine-coach"
check "Example site a project_type: site" "grep -q 'project_type: site' examples/site-vitrine-coach/CLAUDE.md"
check "Example site est niveau LITE" "grep -q 'LITE' examples/site-vitrine-coach/CLAUDE.md"
check "PRD example site a max 1-2 phases" "[ \"\$(grep -cE '^- \\*\\*Phase' examples/site-vitrine-coach/PRD.md)\" -le 2 ]"
check "/architect mentionne LITE/STANDARD/FULL" "grep -qE 'LITE|STANDARD|FULL' .claude/skills/architect/SKILL.md"

echo ""
echo "═══ Scénario C — Automation n8n ═══"
check "Example automation existe" "test -d examples/automation-n8n-veille-rss"
check "Example automation a project_type: automation" "grep -q 'project_type: automation' examples/automation-n8n-veille-rss/CLAUDE.md"
check "/plan adapte questions automation" "grep -qE 'Si.*project_type.*automation' .claude/skills/plan/SKILL.md"
check "/livrer supporte automation (workflow n8n)" "grep -qi 'automation' .claude/skills/livrer/SKILL.md"

echo ""
echo "═══ Scénario D — Reprise (prime) ═══"
check "/prime existe (ex-recap)" "test -f .claude/skills/prime/SKILL.md"
check "ancien skill recap n'existe plus (renommé en prime)" "! test -e .claude/skills/r''ecap"
check "/prime lit PRD/plans/git log" "grep -cE 'PRD\\.md|phase-.*-plan|git log' .claude/skills/prime/SKILL.md | awk '{exit !(\$1>=3)}'"
check "/start bifurque vers /prime si projet existant" "grep -q '/prime' .claude/skills/start/SKILL.md"
check "/prime lit MEMORY.md" "grep -q 'MEMORY.md' .claude/skills/prime/SKILL.md"
check "/prime lit STRUCTURE.md" "grep -q 'STRUCTURE.md' .claude/skills/prime/SKILL.md"
check "/evoluer existe (pour projet livré)" "test -f .claude/skills/evoluer/SKILL.md"

echo ""
echo "═══ Scénario E — STRUCTURE.md (v2.1.0) ═══"
check "STRUCTURE.md template existe" "test -f STRUCTURE.md"
check "STRUCTURE.md a 4 ancres architect" "[ \"\$(grep -c '<!-- architect:' STRUCTURE.md)\" -ge 4 ]"
check "/architect Étape 6.5 écrit STRUCTURE.md" "grep -q '6\\.5' .claude/skills/architect/SKILL.md && grep -q 'STRUCTURE.md' .claude/skills/architect/SKILL.md"
check "/architect branche STRUCTURE.md par project_type" "[ \"\$(grep -c 'STRUCTURE.md' .claude/skills/architect/SKILL.md)\" -ge 4 ]"
check "CLAUDE.md pointe vers STRUCTURE.md" "grep -q 'STRUCTURE.md' CLAUDE.md"
check "Example site a STRUCTURE.md" "test -f examples/site-vitrine-coach/STRUCTURE.md"
check "Example webapp a STRUCTURE.md" "test -f examples/webapp-saas-freelance-devis/STRUCTURE.md"
check "Example automation a STRUCTURE.md" "test -f examples/automation-n8n-veille-rss/STRUCTURE.md"

echo ""
echo "═══ Scénario F — BONUS pédagogiques (v2.1.0) ═══"
check "CLAUDE.md a vocab boucle interne/externe" "grep -qiE 'boucle interne|boucle externe|inner.?loop|outer.?loop' CLAUDE.md"
check "/close a vocab boucle externe" "grep -qiE 'boucle externe|outer.?loop' .claude/skills/close/SKILL.md"
check "CLAUDE.md a rituel PIV explicite" "grep -qE '/prime.*→.*/plan.*→.*/execute' CLAUDE.md"
check "Aucune mention de l'auteur inspirateur externe dans le kit (anti-leak D9)" "[ \"\$(grep -rEi 'c''ole.?medin|c''oleam00' .claude/ docs/ examples/ memory/ scripts/ CLAUDE.md README.md MEMORY.md STRUCTURE.md 2>/dev/null | wc -l)\" = \"0\" ]"

echo ""
echo "═══ Scénario G — docs/{type}/ layout (v2.1.0) ═══"
check "CLAUDE.md a section 'Où vivent les fichiers'" "grep -q '^## Où vivent les fichiers' CLAUDE.md"
check "CLAUDE.md documente docs/plans/" "grep -q 'docs/plans/' CLAUDE.md"
check "CLAUDE.md documente docs/brainstorms/" "grep -q 'docs/brainstorms/' CLAUDE.md"
check "/plan écrit dans docs/plans/" "grep -q 'docs/plans/' .claude/skills/plan/SKILL.md"
check "/brainstorm écrit dans docs/brainstorms/" "grep -q 'docs/brainstorms/' .claude/skills/brainstorm/SKILL.md"
check "/prime lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/prime/SKILL.md"
check "/execute lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/execute/SKILL.md"
check "/validate lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/validate/SKILL.md"
check "/challenge lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/challenge/SKILL.md"
check "/evoluer écrit dans docs/plans/" "grep -q 'docs/plans/' .claude/skills/evoluer/SKILL.md"
check "/close référence docs/plans/" "grep -q 'docs/plans/' .claude/skills/close/SKILL.md"
check "/start détecte docs/plans/" "grep -q 'docs/plans/' .claude/skills/start/SKILL.md"

echo ""
echo "═══ Anti-régressions Round 1 ═══"
check "Pas de mention Dipler dans le kit (sauf CHANGELOG)" "! grep -ril 'dipler' .claude/ examples/ README.md CLAUDE.md 2>/dev/null | grep -v CHANGELOG | grep -q ."
check "Pas de skill nommé /init (collision built-in)" "! test -d .claude/skills/init"
check "Pas de skill /resume (collision built-in)" "! test -d .claude/skills/resume"
check "Pas de skill /debug custom (utilise natif)" "! test -d .claude/skills/debug"
check "Vocabulaire 'un/le skill' masculin partout" "! grep -ri 'une skill\\|la skill\\|cette skill' .claude/ README.md CLAUDE.md 2>/dev/null | grep -q ."

echo ""
echo "═══ Structure mémoire (Phase H) ═══"
check "memory/learnings/ existe" "test -d memory/learnings"
check "memory/topics/ existe" "test -d memory/topics"
check "memory/decisions.md existe" "test -f memory/decisions.md"
check "MEMORY.md racine existe" "test -f MEMORY.md"
check "/close fait le harvest learnings" "grep -ci 'memory/learnings\\|memory/topics' .claude/skills/close/SKILL.md | awk '{exit !(\$1>=2)}'"

echo ""
echo "═══ CLAUDE.md template ═══"
check "Glossaire présent" "grep -q '## Glossaire' CLAUDE.md"
check "project_type documenté" "grep -q 'project_type' CLAUDE.md"
check "Request Classification documenté" "grep -q 'Request Classification' CLAUDE.md"
check "Ancre <!-- design:summary -->" "grep -q '<!-- design:summary -->' CLAUDE.md"
check "Ancre <!-- ship:url -->" "grep -q '<!-- ship:url -->' CLAUDE.md"
check "Règle 6 auto-évaluation" "grep -q '### 6. Auto-évaluation' CLAUDE.md"
check "Section Mémoire persistante" "grep -q '## Mémoire persistante' CLAUDE.md"
check "tmp/ directory exists" "test -f tmp/.gitkeep"
check "tmp/ in .gitignore" "grep -q 'tmp/\\*' .gitignore"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Verdict global : $PASS / $TOTAL PASS"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "❌ $FAIL checks ont échoué. Voir détails ci-dessus."
  exit 1
else
  echo "✅ Tous les checks passent. Kit v2.1.0 validé."
  exit 0
fi
