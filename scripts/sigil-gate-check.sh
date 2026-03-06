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

# folderMap 경로 추출 (jq fallback: grep-based)
json_value() {
  grep "\"$1\"" "$WORKSPACE_JSON" | head -1 | sed 's/.*: *"\(.*\)".*/\1/'
}

RESEARCH_DIR=$(json_value "research")
RESEARCH_DIR=${RESEARCH_DIR:-"01-research/projects"}
PRODUCT_DIR=$(json_value "product")
PRODUCT_DIR=${PRODUCT_DIR:-"02-product/projects"}
DESIGN_DIR=$(json_value "design")
DESIGN_DIR=${DESIGN_DIR:-"05-design/projects"}

PROJECT_RESEARCH="$RESEARCH_DIR/$PROJECT"
PROJECT_PRODUCT="$PRODUCT_DIR/$PROJECT"
PROJECT_DESIGN="$DESIGN_DIR/$PROJECT"

PASS=0
FAIL=0
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
    ;;

  S4|s4)
    echo "[S4 DoD Checks]"
    # 7대 필수 산출물
    check_file "상세 기획서" "*s4-detailed-plan*.md" "$PROJECT_PRODUCT"
    check_file "사이트맵" "*s4-sitemap*.md" "$PROJECT_PRODUCT"
    check_file "로드맵" "*s4-roadmap*.md" "$PROJECT_PRODUCT"
    check_file "개발 계획" "*s4-development-plan*.md" "$PROJECT_PRODUCT"
    check_file "WBS" "*s4-wbs*.md" "$PROJECT_PRODUCT"
    check_file "UI/UX 기획서" "*s4-uiux*.md" "$PROJECT_DESIGN"
    check_file "테스트 전략서" "*s4-test-strategy*.md" "$PROJECT_PRODUCT"

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
echo "=== Result: $PASS PASS / $FAIL FAIL ==="

if [[ $FAIL -gt 0 ]]; then
  echo "STATUS: FAIL — $FAIL item(s) not met"
  exit 1
else
  echo "STATUS: PASS — All [AI] DoD items verified"
  exit 0
fi
