#!/bin/bash
# RAG 환경 설정 + 인덱스 빌드 원스텝 스크립트
# Usage: bash setup.sh [target_dir]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-$HOME/forge-outputs/09-grants}"

echo "🔧 RAG 환경 설정"
echo "   대상: $TARGET_DIR"
echo ""

# 1. 패키지 설치
echo "📦 패키지 설치 중..."
pip install -q -r "$SCRIPT_DIR/requirements.txt" 2>&1 | tail -3

# 2. API 키 확인
if [ -z "${OPENAI_API_KEY:-}" ]; then
  if [ -f "$HOME/forge/.env" ]; then
    source "$HOME/forge/.env"
  fi
fi

if [ -z "${OPENAI_API_KEY:-}" ]; then
  echo "❌ OPENAI_API_KEY 미설정"
  echo "   export OPENAI_API_KEY=sk-... 또는 ~/forge/.env에 추가"
  exit 1
fi

echo "✅ API 키 확인됨"

# 3. 인덱스 빌드
echo ""
python3 "$SCRIPT_DIR/index.py" "$TARGET_DIR" --rebuild

echo ""
echo "🎉 RAG 설정 완료!"
echo ""
echo "사용법:"
echo "  python3 $SCRIPT_DIR/search.py \"투자 유치 전략\""
echo "  python3 $SCRIPT_DIR/search.py \"TagHub 기술 차별점\" --top-k 10"
echo "  python3 $SCRIPT_DIR/search.py \"시장 규모\" --mode vector"
echo "  python3 $SCRIPT_DIR/search.py \"PoC 검증\" --json"
