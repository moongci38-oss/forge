#!/bin/bash
# SIGIL Wave 2 트레이서빌리티 자동 검증 스크립트
# S3 기획서에서 요구사항 ID를 추출하고, S4 산출물에서 참조 여부를 검증한다.
# Usage: bash scripts/sigil-wave2-trace.sh <project>
# Example: bash scripts/sigil-wave2-trace.sh portfolio-admin

set -uo pipefail

PROJECT=${1:-""}

if [[ -z "$PROJECT" ]]; then
  echo "Usage: bash scripts/sigil-wave2-trace.sh <project>"
  echo "  project: baduki, portfolio-admin, etc."
  exit 1
fi

# sigil-workspace.json에서 경로 해석
WORKSPACE_JSON="sigil-workspace.json"
if [[ ! -f "$WORKSPACE_JSON" ]]; then
  echo "FAIL: sigil-workspace.json not found in $(pwd)"
  exit 1
fi

# jq fallback: grep-based JSON parsing
json_value() {
  grep "\"$1\"" "$WORKSPACE_JSON" | head -1 | sed 's/.*: *"\(.*\)".*/\1/'
}

PRODUCT_DIR=$(json_value "product")
PRODUCT_DIR=${PRODUCT_DIR:-"02-product/projects"}
DESIGN_DIR=$(json_value "design")
DESIGN_DIR=${DESIGN_DIR:-"05-design/projects"}

S3_DIR="$PRODUCT_DIR/$PROJECT"
S4_PRODUCT_DIR="$PRODUCT_DIR/$PROJECT"
S4_DESIGN_DIR="$DESIGN_DIR/$PROJECT"

# S3 파일 찾기 (s3-prd.md 또는 s3-gdd.md)
S3_FILE=""
for f in "$S3_DIR"/*s3-prd*.md "$S3_DIR"/*s3-gdd*.md; do
  if [[ -f "$f" ]]; then
    S3_FILE="$f"
    break
  fi
done

if [[ -z "$S3_FILE" ]]; then
  echo "FAIL: S3 기획서를 찾을 수 없습니다 ($S3_DIR/*s3-{prd,gdd}*.md)"
  exit 1
fi

echo "=== SIGIL Wave 2 트레이서빌리티 검증: $PROJECT ==="
echo ""
echo "S3 기획서: $S3_FILE"
echo ""

# S3에서 요구사항 ID 추출
# 패턴: FR-XXX, NFR-XXX, US-XXX, REQ-XXX, FUNC-XXX, PERF-XXX, SEC-XXX
REQ_PATTERN='(FR|NFR|US|REQ|FUNC|PERF|SEC)-[0-9]+'
REQ_IDS=$(grep -oE "$REQ_PATTERN" "$S3_FILE" 2>/dev/null | sort -u || true)

if [[ -z "$REQ_IDS" ]]; then
  echo "WARNING: S3 기획서에서 요구사항 ID를 찾을 수 없습니다."
  echo "  지원 패턴: FR-NNN, NFR-NNN, US-NNN, REQ-NNN, FUNC-NNN, PERF-NNN, SEC-NNN"
  echo ""
  echo "=== 대체 검증: 섹션 기반 트레이서빌리티 ==="
  echo ""

  # 요구사항 ID가 없으면 S3 주요 섹션 헤더로 대체 검증
  S3_SECTIONS=$(grep -E '^#{2,3} ' "$S3_FILE" | sed 's/^#* //' | head -30)
  TOTAL=$(echo "$S3_SECTIONS" | wc -l)
  FOUND=0
  MISSING=""

  # S4 산출물 수집
  S4_FILES=""
  for f in "$S4_PRODUCT_DIR"/*s4-*.md "$S4_DESIGN_DIR"/*s4-*.md; do
    [[ -f "$f" ]] && S4_FILES="$S4_FILES $f"
  done

  if [[ -z "$S4_FILES" ]]; then
    echo "FAIL: S4 산출물을 찾을 수 없습니다"
    exit 1
  fi

  while IFS= read -r section; do
    # 빈 줄 스킵
    [[ -z "$section" ]] && continue
    # 3글자 미만 스킵
    [[ ${#section} -lt 3 ]] && continue

    if grep -rl "$section" $S4_FILES > /dev/null 2>&1; then
      ((FOUND++))
    else
      MISSING="$MISSING\n  - $section"
    fi
  done <<< "$S3_SECTIONS"

  MISSING_COUNT=$((TOTAL - FOUND))

  if [[ $TOTAL -gt 0 ]]; then
    COVERAGE=$(( (FOUND * 100) / TOTAL ))
  else
    COVERAGE=0
  fi

  echo "S3 주요 섹션: $TOTAL개"
  echo "S4 반영 확인: $FOUND개"
  echo "미반영: $MISSING_COUNT개"
  echo "커버리지: ${COVERAGE}%"

  if [[ -n "$MISSING" && "$MISSING" != "" ]]; then
    echo ""
    echo "미반영 섹션:"
    echo -e "$MISSING"
  fi

else
  # 요구사항 ID 기반 검증
  TOTAL=$(echo "$REQ_IDS" | wc -l)
  FOUND=0
  MISSING=""

  # S4 산출물 수집
  S4_FILES=""
  for f in "$S4_PRODUCT_DIR"/*s4-*.md "$S4_DESIGN_DIR"/*s4-*.md; do
    [[ -f "$f" ]] && S4_FILES="$S4_FILES $f"
  done

  if [[ -z "$S4_FILES" ]]; then
    echo "FAIL: S4 산출물을 찾을 수 없습니다"
    exit 1
  fi

  echo "[요구사항 ID 트레이서빌리티]"
  echo ""

  while IFS= read -r req_id; do
    [[ -z "$req_id" ]] && continue

    if grep -rl "$req_id" $S4_FILES > /dev/null 2>&1; then
      echo "  PASS: $req_id"
      ((FOUND++))
    else
      echo "  MISS: $req_id"
      MISSING="$MISSING\n  - $req_id"
    fi
  done <<< "$REQ_IDS"

  MISSING_COUNT=$((TOTAL - FOUND))

  if [[ $TOTAL -gt 0 ]]; then
    COVERAGE=$(( (FOUND * 100) / TOTAL ))
  else
    COVERAGE=0
  fi

  echo ""
  echo "총 요구사항: $TOTAL개"
  echo "S4 반영: $FOUND개"
  echo "미반영: $MISSING_COUNT개"
  echo "커버리지: ${COVERAGE}%"
fi

echo ""
echo "=== Result: 커버리지 ${COVERAGE}% ==="

if [[ $COVERAGE -ge 90 ]]; then
  echo "STATUS: PASS — 트레이서빌리티 ${COVERAGE}% (90%+ 기준 충족)"
  exit 0
elif [[ $COVERAGE -ge 70 ]]; then
  echo "STATUS: WARN — 트레이서빌리티 ${COVERAGE}% (70-89% 보완 권장)"
  exit 0
else
  echo "STATUS: FAIL — 트레이서빌리티 ${COVERAGE}% (70% 미만)"
  exit 1
fi
