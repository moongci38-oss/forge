#!/bin/bash
# analyze-screenshot.sh — Gemini Vision API 이미지 분석 CLI wrapper
# Usage: analyze-screenshot.sh <image-path-or-url> [output-file] [prompt]
#
# - image-path-or-url: 로컬 이미지 경로 (png/jpg/jpeg/webp/gif/bmp) 또는 URL (http/https)
# - output-file: 분석 결과 저장 경로 (캐싱 — 파일 존재 시 API 미호출)
# - prompt: 분석 관점 지시 (기본: 게임 UI 레이아웃 분석)
#
# 환경변수:
#   GEMINI_API_KEY — Gemini API 키 (필수)
#
# 예시:
#   analyze-screenshot.sh ./lobby-ui.png
#   analyze-screenshot.sh ./lobby-ui.png ./analysis.md "HUD 레이아웃 분석"
#   analyze-screenshot.sh ./competitor-shop.jpg ./shop-analysis.md "경쟁작 상점 UI 비교 분석"
#   analyze-screenshot.sh "https://example.com/game-screenshot.png" ./analysis.md

set -euo pipefail

IMAGE_INPUT="${1:?Usage: analyze-screenshot.sh <image-path-or-url> [output-file] [prompt]}"
OUTPUT_FILE="${2:-}"
PROMPT="${3:-다음 게임 스크린샷의 UI 레이아웃을 분석해주세요. 화면 영역별로 위치, 크기 비율, 포함된 컴포넌트, Unity UGUI 구현 방법(Canvas 설정, Layout Group, Anchor)을 표 형식으로 정리해주세요. 컬러 팔레트(Hex 값)도 추출해주세요.}"

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

# --- URL vs 로컬 파일 판별 + 임시 파일 cleanup ---
TEMP_DOWNLOAD=""
cleanup_temp() {
  rm -f "$TEMP_RESULT" "$TEMP_DOWNLOAD"
}

if [[ "$IMAGE_INPUT" =~ ^https?:// ]]; then
  # URL 입력: 임시 파일로 다운로드
  TEMP_DOWNLOAD=$(mktemp /tmp/screenshot-XXXXXX)
  echo "🌐 URL에서 이미지 다운로드 중: $IMAGE_INPUT"

  HTTP_CODE=$(curl -sL -o "$TEMP_DOWNLOAD" -w "%{http_code}" \
    -H "User-Agent: Mozilla/5.0" \
    --max-time 30 \
    "$IMAGE_INPUT" 2>/dev/null)

  if [ "$HTTP_CODE" -lt 200 ] || [ "$HTTP_CODE" -ge 400 ]; then
    echo "❌ 다운로드 실패 (HTTP $HTTP_CODE): $IMAGE_INPUT"
    rm -f "$TEMP_DOWNLOAD"
    exit 1
  fi

  # Content-Type 검증 (file 명령으로 실제 파일 타입 확인)
  FILE_TYPE=$(file -b --mime-type "$TEMP_DOWNLOAD" 2>/dev/null)
  if [[ ! "$FILE_TYPE" =~ ^image/ ]]; then
    echo "❌ 이미지 파일이 아닙니다 (타입: $FILE_TYPE): $IMAGE_INPUT"
    rm -f "$TEMP_DOWNLOAD"
    exit 1
  fi

  IMAGE_SOURCE="$IMAGE_INPUT"
  IMAGE_INPUT="$TEMP_DOWNLOAD"
else
  # 로컬 파일 입력
  if [ ! -f "$IMAGE_INPUT" ]; then
    echo "❌ 파일을 찾을 수 없습니다: $IMAGE_INPUT"
    exit 1
  fi
  IMAGE_SOURCE="$IMAGE_INPUT"
fi

# --- MIME 타입 추정 ---
# file 명령으로 실제 타입 확인 (URL 다운로드 시 확장자가 없을 수 있음)
DETECTED_MIME=$(file -b --mime-type "$IMAGE_INPUT" 2>/dev/null)
if [[ "$DETECTED_MIME" =~ ^image/ ]]; then
  MIME="$DETECTED_MIME"
else
  # fallback: 확장자 기반
  EXT="${IMAGE_INPUT##*.}"
  case "${EXT,,}" in
    png)  MIME="image/png" ;;
    jpg|jpeg) MIME="image/jpeg" ;;
    webp) MIME="image/webp" ;;
    gif)  MIME="image/gif" ;;
    bmp)  MIME="image/bmp" ;;
    *)    MIME="image/png" ;;
  esac
fi

# --- 파일 크기 확인 (20MB 제한) ---
FILE_SIZE=$(stat -c%s "$IMAGE_INPUT" 2>/dev/null || stat -f%z "$IMAGE_INPUT" 2>/dev/null)
if [ "$FILE_SIZE" -gt 20971520 ]; then
  echo "❌ 파일이 20MB를 초과합니다: $(( FILE_SIZE / 1048576 ))MB"
  rm -f "$TEMP_DOWNLOAD"
  exit 1
fi

# --- Base64 인코딩 ---
echo "🖼️ 이미지 분석 시작: $IMAGE_SOURCE ($MIME, $(( FILE_SIZE / 1024 ))KB)"
IMAGE_BASE64=$(base64 -w0 "$IMAGE_INPUT" 2>/dev/null || base64 "$IMAGE_INPUT" 2>/dev/null)

# --- Gemini API 호출 ---
TEMP_RESULT=$(mktemp)
trap 'cleanup_temp' EXIT

# JSON 안전 이스케이프 (프롬프트 내 특수문자 처리)
SAFE_PROMPT=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$PROMPT")
# json.dumps는 따옴표 포함 문자열을 출력하므로 앞뒤 따옴표 제거
SAFE_PROMPT="${SAFE_PROMPT:1:-1}"

curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${GEMINI_API_KEY}" \
  -H 'Content-Type: application/json' \
  -d "{
  \"contents\": [{
    \"parts\": [
      {\"text\": \"$SAFE_PROMPT\"},
      {\"inline_data\": {\"mime_type\": \"$MIME\", \"data\": \"$IMAGE_BASE64\"}}
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
