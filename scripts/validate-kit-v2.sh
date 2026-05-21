#!/usr/bin/env bash
# validate-kit-v2.sh — script déterministe de validation du **contenu** des skills.
# Vérifie par grep/test la présence des skills, ancres, examples, et l'absence
# des régressions Round 1 (Dipler, collision /init, RLS hardcoded).
#
# Note version : la version du kit est lue dynamiquement depuis le fichier `VERSION`
# (ligne 29) — le nom `-v2` réfère à la **génération 2** de la suite de validation
# (post-refacto Phase 1 v2.7.0), pas au numéro de release. Voir `validate-kit.sh`
# pour le lint **structurel** complémentaire (ancres, handoffs, caps).
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

VERSION=$(cat VERSION 2>/dev/null || echo "unknown")

# File-list variables : SKILL.md + references/*.md (greps doivent matcher l'un ou l'autre
# depuis la refacto Phase 1 v2.7.0 qui a externalisé le contenu détaillé en references/).
CLOSE_FILES=".claude/skills/close/SKILL.md .claude/skills/close/references"
START_FILES=".claude/skills/start/SKILL.md .claude/skills/start/references"
LIVRER_FILES=".claude/skills/livrer/SKILL.md .claude/skills/livrer/references"

# CLAUDE.md projet vs CLAUDE.md.template : depuis v2.8.0 le template est nommé .template
# pour distinguer "template du kit" de "fichier rempli par /start". Le projet CLAUDE.md
# est gitignored. Les validations doivent grep le template.
CLAUDE_MD="CLAUDE.md.template"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Validation kit IAPreneurs Claude Code $VERSION"
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
check "/close existe (mandatory + harvest learnings)" "test -f .claude/skills/close/SKILL.md && grep -q 'mandatory' .claude/skills/close/SKILL.md && grep -rq 'Harvest\|harvest' $CLOSE_FILES"
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
check "CLAUDE.md pointe vers STRUCTURE.md" "grep -q 'STRUCTURE.md' $CLAUDE_MD"
check "Example site a STRUCTURE.md" "test -f examples/site-vitrine-coach/STRUCTURE.md"
check "Example webapp a STRUCTURE.md" "test -f examples/webapp-saas-freelance-devis/STRUCTURE.md"
check "Example automation a STRUCTURE.md" "test -f examples/automation-n8n-veille-rss/STRUCTURE.md"

echo ""
echo "═══ Scénario F — BONUS pédagogiques (v2.1.0) ═══"
check "CLAUDE.md a vocab boucle interne/externe" "grep -qiE 'boucle interne|boucle externe|inner.?loop|outer.?loop' $CLAUDE_MD"
check "/close a vocab boucle externe" "grep -rqiE 'boucle externe|outer.?loop' $CLOSE_FILES"
check "CLAUDE.md a rituel PIV explicite" "grep -qE '/prime.*→.*/plan.*→.*/execute' $CLAUDE_MD"
check "Aucune mention de l'auteur inspirateur externe dans le kit (anti-leak D9)" "[ \"\$(grep -rEi --exclude-dir=worktrees 'c''ole.?medin|c''oleam00' .claude/ docs/ examples/ memory/ scripts/ $CLAUDE_MD README.md MEMORY.md STRUCTURE.md 2>/dev/null | wc -l)\" = \"0\" ]"

echo ""
echo "═══ Scénario G — docs/{type}/ layout (v2.1.0) ═══"
check "CLAUDE.md a section 'Où vivent les fichiers'" "grep -q '^## Où vivent les fichiers' $CLAUDE_MD"
check "CLAUDE.md documente docs/plans/" "grep -q 'docs/plans/' $CLAUDE_MD"
check "CLAUDE.md documente docs/brainstorms/" "grep -q 'docs/brainstorms/' $CLAUDE_MD"
check "/plan écrit dans docs/plans/" "grep -q 'docs/plans/' .claude/skills/plan/SKILL.md"
check "/brainstorm écrit dans docs/brainstorms/" "grep -q 'docs/brainstorms/' .claude/skills/brainstorm/SKILL.md"
check "/prime lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/prime/SKILL.md"
check "/execute lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/execute/SKILL.md"
check "/validate lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/validate/SKILL.md"
check "/challenge lit docs/plans/" "grep -q 'docs/plans/' .claude/skills/challenge/SKILL.md"
check "/evoluer écrit dans docs/plans/" "grep -q 'docs/plans/' .claude/skills/evoluer/SKILL.md"
check "/close référence docs/plans/" "grep -q 'docs/plans/' .claude/skills/close/SKILL.md"
check "/start détecte docs/plans/" "grep -rq 'docs/plans/' $START_FILES"

echo ""
echo "═══ Anti-régressions Round 1 ═══"
check "Pas de mention Dipler dans le kit (sauf CHANGELOG)" "! grep -ril --exclude-dir=worktrees 'dipler' .claude/ examples/ README.md $CLAUDE_MD 2>/dev/null | grep -v CHANGELOG | grep -q ."
check "Pas de skill nommé /init (collision built-in)" "! test -d .claude/skills/init"
check "Pas de skill /resume (collision built-in)" "! test -d .claude/skills/resume"
check "Pas de skill /debug custom (utilise natif)" "! test -d .claude/skills/debug"
check "Vocabulaire 'un/le skill' masculin partout" "! grep -ri --exclude-dir=worktrees 'une skill\\|la skill\\|cette skill' .claude/ README.md $CLAUDE_MD 2>/dev/null | grep -q ."

echo ""
echo "═══ Structure mémoire (Phase H) ═══"
check "memory/learnings/ existe" "test -d memory/learnings"
check "memory/topics/ existe" "test -d memory/topics"
check "memory/decisions.md existe" "test -f memory/decisions.md"
check "MEMORY.md racine existe" "test -f MEMORY.md"
check "/close fait le harvest learnings" "grep -rhci 'memory/learnings\\|memory/topics' $CLOSE_FILES | awk 'BEGIN{s=0} {s+=\$1} END{exit !(s>=2)}'"

echo ""
echo "═══ CLAUDE.md template ═══"
check "Glossaire présent" "grep -q '## Glossaire' $CLAUDE_MD"
check "project_type documenté" "grep -q 'project_type' $CLAUDE_MD"
check "Request Classification documenté" "grep -q 'Request Classification' $CLAUDE_MD"
check "Ancre <!-- design:summary -->" "grep -q '<!-- design:summary -->' $CLAUDE_MD"
check "Ancre <!-- ship:url -->" "grep -q '<!-- ship:url -->' $CLAUDE_MD"
check "Règle 6 auto-évaluation" "grep -q '### 6. Auto-évaluation' $CLAUDE_MD"
check "Section Mémoire persistante" "grep -q '## Mémoire persistante' $CLAUDE_MD"
check "tmp/ directory exists" "test -f tmp/.gitkeep"
check "tmp/ in .gitignore" "grep -q 'tmp/\\*' .gitignore"

echo ""
echo "═══ Scénario H : Séquencement v2.1 (STATUS.md + close dynamique + bloc handoff) ═══"
check "H STATUS.md template exists" "test -f STATUS.md"
check "H STATUS.md a ancres close:active" "grep -c 'close:active' STATUS.md | awk '\$1>=2 {exit 0} {exit 1}'"
check "H /close Étape 0 scope detection" "grep -q 'Étape 0 — Détection du scope' .claude/skills/close/SKILL.md"
check "H /close Étape 0.5 STATUS.md write" "grep -q 'Étape 0.5 — Update STATUS.md' .claude/skills/close/SKILL.md"
check "H /close 3 modes documentés" "grep -cE 'no-op|planning|full' .claude/skills/close/SKILL.md | awk '\$1>=3 {exit 0} {exit 1}'"
check "H /prime Étape 0 lit STATUS.md" "grep -q 'Étape 0 — Lecture STATUS.md' .claude/skills/prime/SKILL.md"
check "H 8 skills planning ont bloc handoff" "count=\$(grep -l 'Étapes suivantes pour repartir propre' .claude/skills/start/SKILL.md .claude/skills/brainstorm/SKILL.md .claude/skills/architect/SKILL.md .claude/skills/challenge/SKILL.md .claude/skills/design/SKILL.md .claude/skills/plan/SKILL.md .claude/skills/livrer/SKILL.md .claude/skills/evoluer/SKILL.md | wc -l); [ \$count -eq 8 ]"
check "H CLAUDE.md mentionne STATUS.md et /clear" "grep -q STATUS.md $CLAUDE_MD && grep -q '/clear' $CLAUDE_MD"
check "H docs/KIT.md section STATUS.md & rituel" "grep -q 'STATUS.md & rituel' docs/KIT.md"

echo ""
echo "═══ Scénario I : v2.2.0 (PRD vivant 8 sections + SPECs + n8n opt-in + cérémonie /evoluer) ═══"
check "I PRD template existe" "test -f templates/PRD-template.md"
check "I PRD template 8 sections" "[ \$(grep -c '^## ' templates/PRD-template.md) -eq 8 ]"
check "I PRD template cap 100L mention" "grep -q 'Cap 100 lignes' templates/PRD-template.md"
check "I SPEC template existe" "test -f templates/SPEC-template.md"
check "I decisions.md format ADR header" "grep -qE 'ADR-NNN|ADR numéroté' memory/decisions.md"
check "I STRUCTURE.md +3 ancres" "grep -cE 'structure:integrations|structure:key-files|structure:evolutions-summary' STRUCTURE.md | awk '\$1>=3 {exit 0} {exit 1}'"
check "I CLAUDE.md Cycle de vie" "grep -q 'Cycle de vie' $CLAUDE_MD"
check "I .claude/rules/n8n-setup.md existe" "test -f .claude/rules/n8n-setup.md"
check "I n8n-setup.md référence czlonkowski upstream" "grep -q 'github.com/czlonkowski' .claude/rules/n8n-setup.md"
check "I n8n-setup.md prompt opérationnel embarqué" "grep -q 'expert in n8n automation' .claude/rules/n8n-setup.md"
check "I .claude/skills/n8n absent (opt-in)" "[ ! -d .claude/skills/n8n ]"
check "I /start Q4 project_uses_n8n" "grep -q 'project_uses_n8n' .claude/skills/start/SKILL.md"
check "I /architect 8 sections PRD" "grep -qE 'PRD-template.md|8 sections' .claude/skills/architect/SKILL.md"
check "I /architect DISCOVER+ANALYZE" "grep -qiE 'DISCOVER|ANALYZE' .claude/skills/architect/SKILL.md"
check "I /architect Étape 6.6 ADR-001" "grep -qE 'ADR-001|6.6' .claude/skills/architect/SKILL.md"
check "I /evoluer Étape 1bis lit existants" "grep -qE 'Étape 1bis|3 derniers spec|3 SPECs les plus récents' .claude/skills/evoluer/SKILL.md"
check "I /evoluer Étape 5b SPEC daté" "grep -qE 'SPEC-\\{YYYY-MM-DD\\}|docs/specs/' .claude/skills/evoluer/SKILL.md"
check "I /evoluer ADR append" "grep -qE 'ADR-NNN|ADR-\\{NNN\\}' .claude/skills/evoluer/SKILL.md"
check "I /evoluer gate /validate" "grep -qE 'Gate /validate|/validate.*AVANT' .claude/skills/evoluer/SKILL.md"
check "I /evoluer adaptateur legacy v2.1.x" "grep -qE 'ancien format|legacy v2.1|## Phases' .claude/skills/evoluer/SKILL.md"
check "I /prime Étape 0.5 detect mode" "grep -qE 'Étape 0.5|count_specs' .claude/skills/prime/SKILL.md"
check "I /prime adaptateur format v2.2" "grep -qE '## 7. Implementation Phases|nouveau format' .claude/skills/prime/SKILL.md"
check "I /close Étape 0.6 audit caps" "grep -qE 'Étape 0.6|cap recommandé' .claude/skills/close/SKILL.md"
check "I /close acknowledged flag" "grep -rq 'close-cap-acknowledged' $CLOSE_FILES"
check "I /close adaptateur format PRD" "grep -qE '## 3. Scope actuel|## 7. Implementation Phases' .claude/skills/close/SKILL.md"
check "I /plan Étape 4.5 G/W/T option" "grep -qE 'Given.*when.*then|user stories.*STANDARD' .claude/skills/plan/SKILL.md"
check "I /execute Étape 2 Golden rule" "grep -qE 'Golden rule|CHAQUE tâche.*validation' .claude/skills/execute/SKILL.md"
check "I 3 examples PRD format 8 sections" "for f in examples/*/PRD.md; do n=\$(grep -c '^## ' \$f); [ \$n -ge 7 ] || exit 1; done"
check "I webapp example plan dans docs/plans/" "test -f examples/webapp-saas-freelance-devis/docs/plans/phase-1-plan.md"
check "I webapp example phase-1-plan racine absent" "[ ! -f examples/webapp-saas-freelance-devis/phase-1-plan.md ]"
check "I webapp example SPEC simulé" "test -f examples/webapp-saas-freelance-devis/docs/specs/SPEC-2026-08-12-export-pdf-devis.md"
check "I docs/KIT.md Cycle de vie" "grep -q 'Cycle de vie' docs/KIT.md"
check "I docs/CHANGELOG.md v2.2.0" "grep -qE 'v2.2.0|## v2.2' docs/CHANGELOG.md"
check "I docs/MIGRATION existe" "test -f docs/MIGRATION-v2.1-to-v2.2.md"

echo ""
echo "═══ Scénario J : v2.3.0 (livrer GitHub→Vercel auto-deploy + close gate) — markers refresh v2.5.0+ ═══"
check "J /livrer 3 marqueurs détection présents (git natif + ship:url depuis v2.5.0)" "[ \$(grep -rhcE 'git remote get-url|git ls-remote|ship:url' $LIVRER_FILES | awk '{s+=\$1} END{print s}') -ge 3 ]"
check "J /livrer route_vercel_onboarding présente" "grep -rq 'route_vercel_onboarding' $LIVRER_FILES"
check "J /livrer route_vercel_push présente" "grep -rq 'route_vercel_push' $LIVRER_FILES"
check "J /livrer Hobby warning EN PREMIER (avant Étape 3.V.2)" "awk '/Étape 3\\.V\\.1/,/Étape 3\\.V\\.2/' .claude/skills/livrer/references/vercel.md | grep -qi 'hobby'"
check "J /livrer fallback power-users en commentaire HTML" "grep -rq 'power-users-fallback' $LIVRER_FILES"
check "J /close Étape 6.5 présente avec 3 options" "grep -q 'Étape 6.5' .claude/skills/close/SKILL.md && [ \$(grep -cE 'Commit only|Push main|Push.*branche|preview Vercel' .claude/skills/close/SKILL.md) -ge 3 ]"
check "J /close condition .vercel/project.json énoncée" "grep -q '.vercel/project.json' .claude/skills/close/SKILL.md"
check "J docs/KIT.md mention Netlify alternative non-commerciale" "grep -qE 'Netlify.*commercial|commercial.*Netlify' docs/KIT.md"
check "J docs/KIT.md version courante + docs/CHANGELOG.md entrée v2.3.0" "grep -qE 'v2\\.[3-9]\\.[0-9]+' docs/KIT.md && grep -qE '^## v2\\.3\\.0' docs/CHANGELOG.md"

echo ""
echo "═══ Scénario K : v2.4.0 (livrer Étape 3.5 domaine custom registrar-aware) ═══"
check "K /livrer Étape 3.5 Domaine custom présente" "grep -qE 'Étape 3\\.5.*Domaine custom|Étape 3\\.5 — Domaine' .claude/skills/livrer/SKILL.md"
check "K /livrer 4 registrars couverts (OVH/Gandi/Cloudflare/Hostinger)" "[ \$(grep -cE 'OVH|Gandi|Cloudflare|Hostinger' .claude/skills/livrer/SKILL.md) -ge 4 ]"
check "K /livrer gotcha OVH point final CNAME" "grep -rqE 'point final|cname\\.vercel-dns\\.com\\.' $LIVRER_FILES"
check "K /livrer gotcha Cloudflare DNS only (nuage gris)" "grep -rqE 'DNS only|nuage gris|orange cloud' $LIVRER_FILES"
check "K /livrer distinction sous-domaine vs apex" "grep -rqE 'apex|sous-domaine' $LIVRER_FILES && grep -rqE 'ALIAS|ANAME|records A' $LIVRER_FILES"
check "K /livrer Étape 5 Cas A/B (URL custom vs default)" "grep -qE 'Cas A|Cas B|URL_CIBLE|URL_DEFAUT' .claude/skills/livrer/SKILL.md"
check "K /livrer frontmatter mention domaine custom" "head -10 .claude/skills/livrer/SKILL.md | grep -qiE 'domaine custom|sous-domaine custom'"
check "K docs/KIT.md section Domaine custom" "grep -qE 'Domaine custom \\(v2\\.4\\.0|Domaine custom .*opt-out' docs/KIT.md"
check "K docs/CHANGELOG.md entrée v2.4.0" "grep -qE '^## v2\\.4\\.0' docs/CHANGELOG.md"

echo ""
echo "═══ Scénario L : v2.5.x (livrer Dashboard vs CLI séparation + classic OAuth) ═══"
check "L /livrer règle Dashboard vs CLI explicite" "grep -rqE 'Dashboard web obligatoire|Règle de séparation CLI/Dashboard' $LIVRER_FILES"
check "L /livrer PAS d'invocation gh repo create (les mentions sont des interdictions explicites)" "! grep -rqE 'gh repo create [-\\\"\\$]' $LIVRER_FILES"
check "L /livrer création repo via github.com/new (Dashboard)" "grep -rq 'github.com/new' $LIVRER_FILES"
check "L /livrer création projet Vercel via vercel.com/new (Dashboard)" "grep -rq 'vercel.com/new' $LIVRER_FILES"
check "L /livrer marqueur git ls-remote (pas gh repo view)" "grep -rq 'git ls-remote' $LIVRER_FILES"
check "L /livrer marqueur ship:url (pas .vercel/project.json en marqueur)" "awk '/Étape 3\\.V\\.0/,/Étape 3\\.V\\.1/' .claude/skills/livrer/references/vercel.md | grep -q 'ship:url'"
check "L /livrer auth check via gh api user conservé (automation)" "grep -rq 'gh api user' $LIVRER_FILES"
check "L /livrer env vars Option A Dashboard + Option B CLI" "grep -rqE 'Option A.*Dashboard|Option B.*CLI' $LIVRER_FILES"
check "L docs/KIT.md section Règle Dashboard vs CLI" "grep -qE 'Règle Dashboard vs CLI|Dashboard web obligatoire' docs/KIT.md"
check "L docs/CHANGELOG.md entrée v2.5.0" "grep -qE '^## v2\\.5\\.0' docs/CHANGELOG.md"
check "L /livrer PAS d'étape standalone Install Vercel GitHub App (v2.5.2 fix)" "! grep -rqE 'vercel\\.com/integrations/github' $LIVRER_FILES"
check "L /livrer connexion GitHub-Vercel inline pendant import (v2.5.2)" "grep -rqE 'inline pendant l.import' $LIVRER_FILES"
check "L docs/CHANGELOG.md entrée v2.5.1 (fix UX OAuth inline)" "grep -qE '^## v2\\.5\\.1' docs/CHANGELOG.md"
check "L /livrer Étape 1.3 confirmation stack (v2.5.2)" "grep -qE 'Étape 1\\.3 — Confirmation stack|recommandation, JAMAIS imposition' .claude/skills/livrer/SKILL.md"
check "L /livrer mention stack recommandée GitHub+Vercel+OVH (v2.5.2)" "grep -qE 'GitHub.*Vercel.*OVH|stack recommandée' .claude/skills/livrer/SKILL.md"
check "L /livrer Étape 1.2 inclut Registrar domaine (v2.5.2)" "awk '/1\\.2 — .## Stack./,/1\\.3/' .claude/skills/livrer/SKILL.md | grep -qE 'Registrar domaine'"
check "L docs/CHANGELOG.md entrée v2.5.2 (stack recommandée non imposée)" "grep -qE '^## v2\\.5\\.2' docs/CHANGELOG.md"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Verdict global : $PASS / $TOTAL PASS"
echo "═══════════════════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "❌ $FAIL checks ont échoué. Voir détails ci-dessus."
  exit 1
else
  echo "✅ Tous les checks passent. Kit $VERSION validé."
  exit 0
fi
