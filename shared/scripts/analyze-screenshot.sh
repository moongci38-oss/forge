#!/bin/bash
# analyze-screenshot.sh — Gemini Vision API 이미지 분석 CLI wrapper
# Usage: analyze-screenshot.sh <image-path-or-url> [output-file] [prompt] [image2] [image3]
#
# - image-path-or-url: 로컬 이미지 경로 (png/jpg/jpeg/webp/gif/bmp) 또는 URL (http/https)
# - output-file: 분석 결과 저장 경로 (캐싱 — 파일 존재 시 API 미호출)
# - prompt: 분석 관점 지시 (기본: 게임 UI 레이아웃 분석)
# - image2, image3: 비교 분석용 추가 이미지 (선택)
#
# 환경변수:
#   GEMINI_API_KEY — Gemini API 키 (필수)
#   GEMINI_MODEL  — 모델명 (기본: gemini-2.5-flash)
#
# 예시:
#   analyze-screenshot.sh ./lobby-ui.png
#   analyze-screenshot.sh ./lobby-ui.png ./analysis.md "HUD 레이아웃 분석"
#   analyze-screenshot.sh ./ref.png ./compare.md "구현 검증" ./impl.png
#   analyze-screenshot.sh "https://example.com/screenshot.png" ./analysis.md

set -euo pipefail

IMAGE_INPUT="${1:?Usage: analyze-screenshot.sh <image-path-or-url> [output-file] [prompt] [image2] [image3]}"
OUTPUT_FILE="${2:-}"
PROMPT="${3:-다음 스크린샷의 UI를 개별 컴포넌트로 분해해주세요. 모든 시각 요소를 고유 컴포넌트 단위로 분해하고, 컴포넌트 분해 테이블(컴포넌트명/타입/반복/Z순서/크기/색상Hex/텍스트/구현노트), 컬러 팔레트(Hex 최소 3색), Prefab 계층 트리, 구현 가이드를 포함해주세요.}"
IMAGE2="${4:-}"
IMAGE3="${5:-}"
GEMINI_MODEL="${GEMINI_MODEL:-gemini-2.5-flash}"

# --- API 키 확인 ---
if [ -z "${GEMINI_API_KEY:-}" ]; then
  ENV_FILE="$(dirname "$0")/.env"
  if [ -f "$ENV_FILE" ]; then
    # shellcheck source=/dev/null
    source "$ENV_FILE"
  fi
fi

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "❌ GEMINI_API_KEY가 설정되지 않았습니다."
  echo "   export GEMINI_API_KEY=your_key 또는 ~/.claude/scripts/.env에 설정하세요."
  exit 1
fi

# --- 캐시 확인 ---
if [ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ]; then
  echo "📋 캐시된 분석 결과를 사용합니다: $OUTPUT_FILE"
  cat "$OUTPUT_FILE"
  exit 0
fi

# --- 이미지 처리 함수 ---
TEMP_FILES=()
cleanup_temp() {
  rm -f "$TEMP_RESULT" "${TEMP_FILES[@]}"
}

# resolve_image: URL이면 다운로드, 로컬이면 검증. base64 + MIME 반환
resolve_image() {
  local input="$1"
  local resolved=""

  if [[ "$input" =~ ^https?:// ]]; then
    local tmp
    tmp=$(mktemp /tmp/screenshot-XXXXXX)
    TEMP_FILES+=("$tmp")
    echo "🌐 URL에서 이미지 다운로드 중: $input" >&2

    local http_code
    http_code=$(curl -sL -o "$tmp" -w "%{http_code}" \
      -H "User-Agent: Mozilla/5.0" \
      --max-time 30 \
      "$input" 2>/dev/null)

    if [ "$http_code" -lt 200 ] || [ "$http_code" -ge 400 ]; then
      echo "❌ 다운로드 실패 (HTTP $http_code): $input" >&2
      return 1
    fi

    local ftype
    ftype=$(file -b --mime-type "$tmp" 2>/dev/null)
    if [[ ! "$ftype" =~ ^image/ ]]; then
      echo "❌ 이미지 파일이 아닙니다 (타입: $ftype): $input" >&2
      return 1
    fi
    resolved="$tmp"
  else
    if [ ! -f "$input" ]; then
      echo "❌ 파일을 찾을 수 없습니다: $input" >&2
      return 1
    fi
    resolved="$input"
  fi

  # 파일 크기 확인 (20MB 제한)
  local fsize
  fsize=$(stat -c%s "$resolved" 2>/dev/null || stat -f%z "$resolved" 2>/dev/null)
  if [ "$fsize" -gt 20971520 ]; then
    echo "❌ 파일이 20MB를 초과합니다: $(( fsize / 1048576 ))MB" >&2
    return 1
  fi

  # MIME 타입
  local mime
  mime=$(file -b --mime-type "$resolved" 2>/dev/null)
  if [[ ! "$mime" =~ ^image/ ]]; then
    local ext="${resolved##*.}"
    case "${ext,,}" in
      png)  mime="image/png" ;;
      jpg|jpeg) mime="image/jpeg" ;;
      webp) mime="image/webp" ;;
      gif)  mime="image/gif" ;;
      bmp)  mime="image/bmp" ;;
      *)    mime="image/png" ;;
    esac
  fi

  # base64
  local b64
  b64=$(base64 -w0 "$resolved" 2>/dev/null || base64 "$resolved" 2>/dev/null)

  echo "🖼️ 이미지 준비: $input ($mime, $(( fsize / 1024 ))KB)" >&2
  # 출력: MIME|BASE64
  echo "${mime}|${b64}"
}

# --- 이미지 처리 ---
IMG1_DATA=$(resolve_image "$IMAGE_INPUT") || exit 1
IMG1_MIME="${IMG1_DATA%%|*}"
IMG1_B64="${IMG1_DATA#*|}"
IMAGE_SOURCE="$IMAGE_INPUT"

# 추가 이미지 parts 조립
EXTRA_PARTS=""
IMG_COUNT=1

if [ -n "$IMAGE2" ]; then
  IMG2_DATA=$(resolve_image "$IMAGE2") || exit 1
  IMG2_MIME="${IMG2_DATA%%|*}"
  IMG2_B64="${IMG2_DATA#*|}"
  EXTRA_PARTS=",{\"inline_data\": {\"mime_type\": \"$IMG2_MIME\", \"data\": \"$IMG2_B64\"}}"
  IMAGE_SOURCE="$IMAGE_INPUT + $IMAGE2"
  IMG_COUNT=2
fi

if [ -n "$IMAGE3" ]; then
  IMG3_DATA=$(resolve_image "$IMAGE3") || exit 1
  IMG3_MIME="${IMG3_DATA%%|*}"
  IMG3_B64="${IMG3_DATA#*|}"
  EXTRA_PARTS="${EXTRA_PARTS},\n      {\"inline_data\": {\"mime_type\": \"$IMG3_MIME\", \"data\": \"$IMG3_B64\"}}"
  IMAGE_SOURCE="$IMAGE_INPUT + $IMAGE2 + $IMAGE3"
  IMG_COUNT=3
fi

echo "📊 분석 모델: $GEMINI_MODEL | 이미지: ${IMG_COUNT}장"

# --- Gemini API 호출 ---
TEMP_RESULT=$(mktemp)
trap 'cleanup_temp' EXIT

# JSON 안전 이스케이프 (프롬프트 내 특수문자 처리)
SAFE_PROMPT=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$PROMPT")
# json.dumps는 따옴표 포함 문자열을 출력하므로 앞뒤 따옴표 제거
SAFE_PROMPT="${SAFE_PROMPT:1:-1}"

curl -s "https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}" \
  -H 'Content-Type: application/json' \
  -d "{
  \"contents\": [{
    \"parts\": [
      {\"text\": \"$SAFE_PROMPT\"},
      {\"inline_data\": {\"mime_type\": \"$IMG1_MIME\", \"data\": \"$IMG1_B64\"}}${EXTRA_PARTS}
    ]
  }]
}" > "$TEMP_RESULT" 2>/dev/null

# --- 결과 추출 ---
ANALYSIS=$(python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    parts = data.get('candidates', [{}])[0].get('content', {}).get('parts', [])
    for part in parts:
        if 'text' in part:
            print(part['text'])
except Exception as e:
    print(f'Error parsing response: {e}', file=sys.stderr)
    sys.exit(1)
" < "$TEMP_RESULT" 2>/dev/null)

if [ -z "$ANALYSIS" ]; then
  echo "❌ 분석 결과를 추출할 수 없습니다."
  echo "Raw response:"
  cat "$TEMP_RESULT"
  exit 1
fi

# --- 결과 출력/저장 ---
if [ -n "$OUTPUT_FILE" ]; then
  mkdir -p "$(dirname "$OUTPUT_FILE")"

  cat > "$OUTPUT_FILE" <<EOF
# 스크린샷 레퍼런스 분석

**원본**: \`$IMAGE_SOURCE\`
**분석일**: $(date +%Y-%m-%d)
**모델**: $GEMINI_MODEL
**프롬프트**: $PROMPT

---

$ANALYSIS
EOF

  echo "✅ 분석 완료: $OUTPUT_FILE"
else
  echo ""
  echo "---"
  echo "$ANALYSIS"
fi
