#!/usr/bin/env bash
# skill-harness-check.sh — SKILL.md 내부 하네스 패턴 커버리지 검사
# Usage: bash skill-harness-check.sh [--fix] [--json]
#
# 종료 코드:
#   0 = 모든 CRITICAL 스킬 하네스 적용됨
#   1 = CRITICAL 스킬 중 하네스 미적용 스킬 존재
#   2 = 검사 실패 (경로 없음 등)

set -euo pipefail

FORGE_CLAUDE="${FORGE_ROOT:-$HOME/forge}/.claude/skills"
GLOBAL_CLAUDE="$HOME/.claude/skills"
FIX_MODE=0
JSON_MODE=0

for arg in "$@"; do
  case "$arg" in
    --fix)  FIX_MODE=1 ;;
    --json) JSON_MODE=1 ;;
  esac
done

# 하네스 패턴 (하나라도 있으면 PASS)
HARNESS_PATTERNS=(
  'Agent('
  '독립 Evaluator'
  'Wave 2\.5'
  '독립.*[Ss]ubagent'
  '[Ss]ubagent.*독립'
  'PGE\b'
  'Evaluator subagent'
  'PASS.*FAIL\|FAIL.*PASS'
  'eval-report\.md'
  'WP_EVAL\|DSR_EVAL\|WR_EVAL\|FD_EVAL'
  'Step 3\.5'
  '신뢰도.*HIGH'
)

# 파이프라인 직결 — 하네스 필수 (미적용 시 CRITICAL)
CRITICAL_SKILLS=(
  "qa"
  "spec-compliance-checker"
  "visual-loop"
  "autoplan"
  "writing-plans"
  "frontend-design"
  "daily-system-review"
  "weekly-research"
  "wiki-sync"
  "rd-plan"
  "content-creator"
  "asset-critic"
)

declare -a ALL_SKILLS=()
declare -a PASS_SKILLS=()
declare -a FAIL_SKILLS=()
declare -a CRITICAL_FAIL=()

collect_skills() {
  local base="$1"
  [[ -d "$base" ]] || return 0
  while IFS= read -r skill_md; do
    local skill_name
    skill_name=$(basename "$(dirname "$skill_md")")
    ALL_SKILLS+=("$skill_name|$skill_md")
  done < <(find "$base" -maxdepth 2 -name "SKILL.md" 2>/dev/null | sort)
}

collect_skills "$FORGE_CLAUDE"

# 글로벌 스킬 중 forge에 없는 것만 추가
while IFS= read -r skill_md; do
  local_name=$(basename "$(dirname "$skill_md")")
  already=0
  for entry in "${ALL_SKILLS[@]:-}"; do
    [[ "${entry%%|*}" == "$local_name" ]] && { already=1; break; }
  done
  [[ $already -eq 0 ]] && ALL_SKILLS+=("$local_name|$skill_md")
done < <(find "$GLOBAL_CLAUDE" -maxdepth 2 -name "SKILL.md" 2>/dev/null | sort)

if [[ ${#ALL_SKILLS[@]} -eq 0 ]]; then
  echo "ERROR: SKILL.md 파일을 찾을 수 없음 (forge: $FORGE_CLAUDE, global: $GLOBAL_CLAUDE)" >&2
  exit 2
fi

check_harness() {
  local skill_md="$1"
  for pat in "${HARNESS_PATTERNS[@]}"; do
    grep -qE "$pat" "$skill_md" 2>/dev/null && return 0
  done
  return 1
}

for entry in "${ALL_SKILLS[@]}"; do
  name="${entry%%|*}"
  path="${entry#*|}"
  if check_harness "$path"; then
    PASS_SKILLS+=("$name")
  else
    FAIL_SKILLS+=("$name|$path")
    for c in "${CRITICAL_SKILLS[@]}"; do
      [[ "$name" == "$c" ]] && CRITICAL_FAIL+=("$name|$path") && break
    done
  fi
done

TOTAL=${#ALL_SKILLS[@]}
PASS_COUNT=${#PASS_SKILLS[@]}
FAIL_COUNT=${#FAIL_SKILLS[@]}
CRITICAL_COUNT=${#CRITICAL_FAIL[@]}
COVERAGE=$(( PASS_COUNT * 100 / TOTAL ))

if [[ $JSON_MODE -eq 1 ]]; then
  echo "{"
  echo "  \"total_skills\": $TOTAL,"
  echo "  \"harness_applied\": $PASS_COUNT,"
  echo "  \"coverage_rate\": $COVERAGE,"
  echo "  \"missing_harness\": ["
  for i in "${!FAIL_SKILLS[@]}"; do
    name="${FAIL_SKILLS[$i]%%|*}"
    comma=$( [[ $i -lt $((FAIL_COUNT-1)) ]] && echo "," || echo "" )
    echo "    \"$name\"$comma"
  done
  echo "  ],"
  echo "  \"critical_missing\": ["
  for i in "${!CRITICAL_FAIL[@]}"; do
    name="${CRITICAL_FAIL[$i]%%|*}"
    comma=$( [[ $i -lt $((CRITICAL_COUNT-1)) ]] && echo "," || echo "" )
    echo "    \"$name\"$comma"
  done
  echo "  ]"
  echo "}"
  [[ $CRITICAL_COUNT -gt 0 ]] && exit 1 || exit 0
fi

# Human-readable output
echo "============================================"
echo " Skill Harness Coverage Check"
echo "============================================"
echo " Total:    $TOTAL skills"
echo " PASS:     $PASS_COUNT  (${COVERAGE}%)"
echo " FAIL:     $FAIL_COUNT"
echo " CRITICAL: $CRITICAL_COUNT"
echo "--------------------------------------------"

if [[ ${#PASS_SKILLS[@]} -gt 0 ]]; then
  echo ""
  echo "✅ PASS (하네스 적용됨):"
  for name in "${PASS_SKILLS[@]}"; do
    echo "   $name"
  done
fi

if [[ $FAIL_COUNT -gt 0 ]]; then
  echo ""
  echo "❌ FAIL (하네스 없음):"
  for entry in "${FAIL_SKILLS[@]}"; do
    name="${entry%%|*}"
    path="${entry#*|}"
    is_critical=""
    for c in "${CRITICAL_SKILLS[@]}"; do
      [[ "$name" == "$c" ]] && is_critical=" ← CRITICAL" && break
    done
    echo "   $name$is_critical"
    echo "   └─ $path"
  done
fi

if [[ $FIX_MODE -eq 1 && $FAIL_COUNT -gt 0 ]]; then
  echo ""
  echo "============================================"
  echo " --fix: 권장 하네스 패턴 (각 SKILL.md 말미에 추가)"
  echo "============================================"
  cat << 'TEMPLATE'

---

## 독립 Evaluator (하네스)

생성 완료 후 독립 Evaluator Subagent가 결과물을 검증한다.

```python
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
당신은 독립 평가자입니다. {SKILL_NAME} 결과물을 검토하세요.

평가 기준:
- [항목1]: [기준]
- [항목2]: [기준]

판정: PASS(품질 충족) / FAIL(재작업 필요)
피드백 형식: [파일명+섹션] — [이유] → [방법]
"""
)
```

피드백 루프:
- PASS → 파이프라인 계속
- FAIL → 재작업 후 1회 재실행. 2회 연속 FAIL 시 [STOP] Human 에스컬레이션
TEMPLATE
fi

echo ""
echo "============================================"
if [[ $CRITICAL_COUNT -gt 0 ]]; then
  echo " 결과: FAIL — CRITICAL 스킬 $CRITICAL_COUNT개 하네스 미적용"
  echo "============================================"
  exit 1
else
  echo " 결과: PASS — CRITICAL 스킬 전체 하네스 적용됨"
  echo "============================================"
  exit 0
fi
