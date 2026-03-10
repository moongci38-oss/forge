#!/bin/bash
# SIGIL Gate DoD [AI] 항목 자동 검증 스크립트
# Usage: bash scripts/sigil-gate-check.sh <project> <stage>
# Example: bash scripts/sigil-gate-check.sh baduki S4

set -uo pipefail

PROJECT=${1:-""}
STAGE=${2:-""}

if [[ -z "$PROJECT" || -z "$STAGE" ]]; then
  echo "Usage: bash scripts/sigil-gate-check.sh <project> <stage>"
  echo "  project: baduki, portfolio-admin, etc."
  echo "  stage: S1, S2, S3, S4"
  exit 1
fi

# sigil-workspace.json에서 경로 해석
WORKSPACE_JSON="sigil-workspace.json"
if [[ ! -f "$WORKSPACE_JSON" ]]; then
  echo "FAIL: sigil-workspace.json not found in $(pwd)"
  exit 1
fi

# folderMap 경로 추출 (python3 dot-path parser)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/json-get.sh"

RESEARCH_DIR=$(json_get "$WORKSPACE_JSON" "folderMap.research")
RESEARCH_DIR=${RESEARCH_DIR:-"01-research/projects"}
PRODUCT_DIR=$(json_get "$WORKSPACE_JSON" "folderMap.product")
PRODUCT_DIR=${PRODUCT_DIR:-"02-product/projects"}
DESIGN_DIR=$(json_get "$WORKSPACE_JSON" "folderMap.design")
DESIGN_DIR=${DESIGN_DIR:-"05-design/projects"}

PROJECT_RESEARCH="$RESEARCH_DIR/$PROJECT"
PROJECT_PRODUCT="$PRODUCT_DIR/$PROJECT"
PROJECT_DESIGN="$DESIGN_DIR/$PROJECT"

PASS=0
FAIL=0
WARN=0
WARNS=""

check_file() {
  local desc="$1"
  local pattern="$2"
  local dir="$3"

  if compgen -G "$dir"/$pattern > /dev/null 2>&1; then
    echo "  PASS: $desc"
    ((PASS++))
  else
    echo "  FAIL: $desc ($dir/$pattern)"
    ((FAIL++))
  fi
}

check_grep() {
  local desc="$1"
  local pattern="$2"
  local dir="$3"
  local glob="${4:-*.md}"

  if grep -rl "$pattern" "$dir"/$glob > /dev/null 2>&1; then
    echo "  PASS: $desc"
    ((PASS++))
  else
    echo "  FAIL: $desc (pattern: '$pattern' not found in $dir/$glob)"
    ((FAIL++))
  fi
}

echo "=== SIGIL Gate Check: $PROJECT / $STAGE ==="
echo ""

case $STAGE in
  S1|s1)
    echo "[S1 DoD Checks]"
    check_file "S1 리서치 파일 존재" "*s1-*.md" "$PROJECT_RESEARCH"
    check_grep "출처+신뢰도 태깅" "신뢰도" "$PROJECT_RESEARCH"
    check_grep "JTBD 분석" "JTBD\|Jobs.to.Be.Done\|해결할 문제" "$PROJECT_RESEARCH"

    # 신뢰도 정량 검증 (심화)
    echo "  --- 신뢰도 정량 검증 ---"
    cred_high=$(grep -rE "\[신뢰도: *High\]" "$PROJECT_RESEARCH/" 2>/dev/null | wc -l)
    cred_med=$(grep -rE "\[신뢰도: *Medium\]" "$PROJECT_RESEARCH/" 2>/dev/null | wc -l)
    cred_low=$(grep -rE "\[신뢰도: *Low\]" "$PROJECT_RESEARCH/" 2>/dev/null | wc -l)
    cred_high=$((cred_high + 0)); cred_med=$((cred_med + 0)); cred_low=$((cred_low + 0))
    cred_total=$((cred_high + cred_med + cred_low))

    if [ "$cred_total" -gt 0 ]; then
      cred_high_pct=$((cred_high * 100 / cred_total))
      if [ "$cred_high_pct" -ge 50 ]; then
        echo "  PASS: High 신뢰도 비율 ${cred_high_pct}% (High:$cred_high Med:$cred_med Low:$cred_low)"
        ((PASS++))
      else
        echo "  WARN: High 신뢰도 비율 ${cred_high_pct}% (50% 미만, High:$cred_high Med:$cred_med Low:$cred_low)"
        ((WARN++))
      fi
    else
      echo "  FAIL: 신뢰도 태그 미존재 (총 0건)"
      ((FAIL++))
    fi
    ;;

  S2|s2)
    echo "[S2 DoD Checks]"
    check_file "S2 컨셉 파일 존재" "*s2-concept*.md" "$PROJECT_PRODUCT"
    check_grep "Go/No-Go 점수" "총점\|Go.No-Go\|점수" "$PROJECT_PRODUCT" "*s2-*.md"
    check_grep "Kill Criteria 확인" "Kill.Criteria\|킬 크라이테리아" "$PROJECT_PRODUCT" "*s2-*.md"
    ;;

  S3|s3)
    echo "[S3 DoD Checks]"
    check_file "S3 기획서 .md 존재" "*s3-*.md" "$PROJECT_PRODUCT"
    check_file "S3 기획서 .pptx 존재" "*s3-*.pptx" "$PROJECT_PRODUCT"
    check_grep "에이전트 회의 결과" "에이전트 회의" "$PROJECT_PRODUCT" "*s3-*.md"

    # 에이전트 회의 구조화 검증 (심화)
    echo "  --- 에이전트 회의 구조 심화 검증 ---"
    s3_file=$(find "$PROJECT_PRODUCT" -maxdepth 1 -name "*s3-*.md" -type f 2>/dev/null | head -1 || echo "")
    if [ -n "$s3_file" ]; then
      # 최소 2개 에이전트 안 존재 확인
      agent_count=$(grep -cE "(Agent [A-Z]|에이전트 [A-Z]|안 [1-3]|초안 [1-3]|Draft [A-Z])" "$s3_file" 2>/dev/null || true)
      agent_count=$((agent_count + 0))
      if [ "$agent_count" -ge 2 ]; then
        echo "  PASS: 에이전트 회의 — ${agent_count}개 독립 안 존재"
        ((PASS++))
      else
        echo "  FAIL: 에이전트 회의 — 독립 안 ${agent_count}개 (최소 2개 필요)"
        ((FAIL++))
      fi

      # 비교표 존재 확인 (에이전트 회의 섹션 내 Markdown 테이블)
      compare_table=$(sed -n '/에이전트 회의/,/^## /p' "$s3_file" 2>/dev/null | grep -c '^|' || true)
      compare_table=$((compare_table + 0))
      if [ "$compare_table" -ge 3 ]; then
        echo "  PASS: 비교표 존재 (${compare_table}행)"
        ((PASS++))
      else
        echo "  FAIL: 비교표 미존재 또는 불충분 (${compare_table}행, 최소 3행 필요)"
        ((FAIL++))
      fi

      # 선택 근거 텍스트 존재 확인
      rationale=$(sed -n '/에이전트 회의/,/^## /p' "$s3_file" 2>/dev/null | grep -cE "(선택 근거|선정 이유|채택 사유|최종 선택)" || true)
      rationale=$((rationale + 0))
      if [ "$rationale" -ge 1 ]; then
        echo "  PASS: 선택 근거 존재"
        ((PASS++))
      else
        echo "  FAIL: 선택 근거 미존재"
        ((FAIL++))
      fi
    else
      echo "  FAIL: S3 기획서 파일을 찾을 수 없음"
      ((FAIL++))
    fi
    ;;

  S4|s4)
    echo "[S4 DoD Checks]"
    # 3대 필수 산출물
    check_file "상세 기획서" "*s4-detailed-plan*.md" "$PROJECT_PRODUCT"
    check_file "개발 계획" "*s4-development-plan*.md" "$PROJECT_PRODUCT"
    check_file "UI/UX 기획서" "*s4-uiux*.md" "$PROJECT_DESIGN"

    # 개발 계획 내 테스트 전략 섹션 존재 확인
    check_grep "테스트 전략 섹션" "테스트 전략\|테스트 계층\|커버리지 목표" "$PROJECT_PRODUCT" "*s4-development-plan*.md"

    # Wave 리포트
    check_file "Wave 2 트레이서빌리티 리포트" "*wave2-verification*.md" "$PROJECT_PRODUCT"
    check_file "Wave 3 CTO 리뷰 리포트" "*wave3-cto*.md" "$PROJECT_PRODUCT"
    check_file "Wave 3 UX 리뷰 리포트" "*wave3-ux*.md" "$PROJECT_PRODUCT"

    # Trine 세션 로드맵
    check_grep "Trine 세션 로드맵" "Trine.*세션\|세션.*로드맵" "$PROJECT_PRODUCT" "*s4-development-plan*.md"
    ;;

  *)
    echo "Unknown stage: $STAGE (use S1, S2, S3, S4)"
    exit 1
    ;;
esac

echo ""
echo "=== Result: $PASS PASS / $FAIL FAIL / $WARN WARN ==="

if [[ $FAIL -gt 0 ]]; then
  echo "STATUS: FAIL — $FAIL item(s) not met"
  exit 1
elif [[ $WARN -gt 0 ]]; then
  echo "STATUS: CONDITIONAL — $WARN warning(s)"
  exit 0
else
  echo "STATUS: PASS — All [AI] DoD items verified"
  exit 0
fi
