#!/bin/bash
# analyze-video.sh — Gemini Video Understanding CLI wrapper
# Usage: analyze-video.sh <video-path-or-url> [output-file] [prompt]
#
# - video-path: 로컬 파일 경로 (mp4/mov/avi/webm/mkv) 또는 YouTube URL
# - output-file: 분석 결과 저장 경로 (캐싱 — 파일 존재 시 API 미호출)
# - prompt: 분석 관점 지시 (기본: 게임 연출 분석)
#
# 환경변수:
#   GEMINI_API_KEY — Gemini API 키 (필수)
#
# 예시:
#   analyze-video.sh ./gacha-demo.mp4
#   analyze-video.sh ./gacha-demo.mp4 ./analysis.md "가챠 연출 타이밍 분석"
#   analyze-video.sh "https://youtube.com/watch?v=xxx" ./yt-analysis.md

set -euo pipefail

VIDEO_INPUT="${1:?Usage: analyze-video.sh <video-path-or-url> [output-file] [prompt]}"
OUTPUT_FILE="${2:-}"
PROMPT="${3:-다음 게임 영상을 분석해주세요. 타임스탬프별로 연출 요소(파티클, 셰이더, 애니메이션, 사운드, UI 전환)를 식별하고, 각 요소의 시작/종료 시간, 이징, 구현에 필요한 Unity 컴포넌트를 표 형식으로 정리해주세요.}"

# --- API 키 확인 ---
if [ -z "${GEMINI_API_KEY:-}" ]; then
  # .env 파일에서 로드 시도
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

# --- MCP 패키지 확인 ---
if ! command -v mcp-gemini-video-understanding &> /dev/null; then
  # npx fallback
  MCP_CMD="npx -y @ugarchance/mcp-gemini-video-understanding"
else
  MCP_CMD="mcp-gemini-video-understanding"
fi

# --- 입력 유형 판별 ---
IS_URL=false
if [[ "$VIDEO_INPUT" =~ ^https?:// ]]; then
  IS_URL=true
fi

# --- 분석 실행 ---
echo "🎬 영상 분석 시작: $VIDEO_INPUT"
echo "📝 프롬프트: ${PROMPT:0:80}..."

# Gemini API로 직접 분석 (MCP 서버 대신 REST API 사용)
TEMP_RESULT=$(mktemp)
trap 'rm -f "$TEMP_RESULT"' EXIT

if [ "$IS_URL" = true ]; then
  # YouTube URL — Gemini에 URL 직접 전달
  curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}" \
    -H 'Content-Type: application/json' \
    -d "$(cat <<JSONEOF
{
  "contents": [{
    "parts": [
      {"text": "$PROMPT"},
      {"file_data": {"file_uri": "$VIDEO_INPUT", "mime_type": "video/*"}}
    ]
  }]
}
JSONEOF
)" > "$TEMP_RESULT" 2>/dev/null

else
  # 로컬 파일 — Gemini Files API로 업로드 후 분석
  if [ ! -f "$VIDEO_INPUT" ]; then
    echo "❌ 파일을 찾을 수 없습니다: $VIDEO_INPUT"
    exit 1
  fi

  # MIME 타입 추정
  EXT="${VIDEO_INPUT##*.}"
  case "${EXT,,}" in
    mp4)  MIME="video/mp4" ;;
    mov)  MIME="video/quicktime" ;;
    avi)  MIME="video/x-msvideo" ;;
    webm) MIME="video/webm" ;;
    mkv)  MIME="video/x-matroska" ;;
    *)    MIME="video/mp4" ;;
  esac

  echo ""
  echo "⚠️  보안 확인: 로컬 영상 파일을 Google Files API에 업로드합니다."
  echo "   파일: $VIDEO_INPUT"
  echo "   업로드된 파일은 Google 서버에 최대 48시간 보관됩니다."
  echo "   미공개 게임플레이·기밀 콘텐츠가 포함된 경우 Ctrl+C로 중단하세요."
  echo "   (공개된 레퍼런스 영상은 YouTube URL로 대신 전달하면 업로드 없음)"
  echo ""
  sleep 4

  echo "📤 파일 업로드 중... ($MIME)"

  # Step 1: 파일 업로드
  UPLOAD_RESULT=$(curl -s -X POST \
    "https://generativelanguage.googleapis.com/upload/v1beta/files?key=${GEMINI_API_KEY}" \
    -H "X-Goog-Upload-Command: start, upload, finalize" \
    -H "X-Goog-Upload-Header-Content-Type: $MIME" \
    -H "Content-Type: $MIME" \
    --data-binary "@$VIDEO_INPUT")

  # 업로드 결과에서 file URI 추출
  FILE_URI=$(echo "$UPLOAD_RESULT" | grep -o '"uri": *"[^"]*"' | head -1 | sed 's/"uri": *"//;s/"$//')

  if [ -z "$FILE_URI" ]; then
    echo "❌ 파일 업로드 실패"
    echo "$UPLOAD_RESULT"
    exit 1
  fi

  echo "✅ 업로드 완료: $FILE_URI"

  # Step 2: 업로드된 파일로 분석 (처리 대기)
  MAX_WAIT=120
  WAIT=0
  while [ $WAIT -lt $MAX_WAIT ]; do
    # 파일 상태 확인
    FILE_NAME=$(echo "$FILE_URI" | grep -o 'files/[^"]*')
    FILE_STATUS=$(curl -s "https://generativelanguage.googleapis.com/v1beta/${FILE_NAME}?key=${GEMINI_API_KEY}" | grep -o '"state": *"[^"]*"' | sed 's/"state": *"//;s/"$//')

    if [ "$FILE_STATUS" = "ACTIVE" ]; then
      break
    fi

    echo "⏳ 파일 처리 중... ($WAIT초)"
    sleep 5
    WAIT=$((WAIT + 5))
  done

  curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${GEMINI_API_KEY}" \
    -H 'Content-Type: application/json' \
    -d "$(cat <<JSONEOF
{
  "contents": [{
    "parts": [
      {"text": "$PROMPT"},
      {"file_data": {"file_uri": "$FILE_URI", "mime_type": "$MIME"}}
    ]
  }]
}
JSONEOF
)" > "$TEMP_RESULT" 2>/dev/null

fi

# --- 결과 추출 ---
# Gemini API 응답에서 텍스트 추출
ANALYSIS=$(cat "$TEMP_RESULT" | python3 -c "
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
" 2>/dev/null)

if [ -z "$ANALYSIS" ]; then
  echo "❌ 분석 결과를 추출할 수 없습니다."
  echo "Raw response:"
  cat "$TEMP_RESULT"
  exit 1
fi

# --- 결과 출력/저장 ---
if [ -n "$OUTPUT_FILE" ]; then
  # 출력 디렉토리 생성
  mkdir -p "$(dirname "$OUTPUT_FILE")"

  # 분석 결과 저장
  cat > "$OUTPUT_FILE" <<EOF
# 영상 레퍼런스 분석

**원본**: \`$VIDEO_INPUT\`
**분석일**: $(date +%Y-%m-%d)
**프롬프트**: $PROMPT

---

$ANALYSIS
EOF

  # 원본 경로 기록
  SOURCE_FILE="${OUTPUT_FILE%.md}-source.txt"
  echo "$VIDEO_INPUT" > "$SOURCE_FILE"
  echo "$(date -Iseconds)" >> "$SOURCE_FILE"

  echo "✅ 분석 완료: $OUTPUT_FILE"
else
  echo ""
  echo "---"
  echo "$ANALYSIS"
fi
