#!/usr/bin/env bash
# Forge CLI Tools Setup — MCP와 병행 사용하는 CLI 도구 설치
# 팀원 온보딩 시 실행: bash shared/scripts/setup-cli.sh

set -euo pipefail

echo "========================================="
echo " Forge CLI Tools Setup"
echo "========================================="
echo ""

# Node.js 확인
if ! command -v node &>/dev/null; then
  echo "ERROR: Node.js가 필요합니다."
  exit 1
fi

INSTALL_COUNT=0
SKIP_COUNT=0

# --- Lighthouse CLI ---
echo "[1/3] Lighthouse CLI"
if command -v lighthouse &>/dev/null; then
  echo "  ⏭ lighthouse $(lighthouse --version) (already installed)"
  ((SKIP_COUNT++))
else
  echo "  + Installing lighthouse..."
  npm install -g lighthouse
  echo "  ✅ lighthouse $(lighthouse --version)"
  ((INSTALL_COUNT++))
fi

# --- Sentry CLI ---
echo "[2/3] Sentry CLI"
if command -v sentry-cli &>/dev/null; then
  echo "  ⏭ sentry-cli $(sentry-cli --version 2>/dev/null) (already installed)"
  ((SKIP_COUNT++))
else
  echo "  + Installing @sentry/cli..."
  npm install -g @sentry/cli
  echo "  ✅ sentry-cli $(sentry-cli --version 2>/dev/null)"
  ((INSTALL_COUNT++))
fi

# --- Brave Search (npx 기반, 설치 불필요) ---
echo "[3/3] Brave Search CLI"
echo "  ℹ npx @anthropic-ai/brave-search 으로 사용 (별도 설치 불필요)"
echo "  ℹ 환경변수 BRAVE_API_KEY 필요"

echo ""
echo "========================================="
echo " Done: ${INSTALL_COUNT} installed, ${SKIP_COUNT} skipped"
echo "========================================="
echo ""
echo "CLI vs MCP 사용 가이드:"
echo ""
echo "  Lighthouse"
echo "    CLI:  lighthouse https://example.com --output=json"
echo "    MCP:  대화 내 인터랙티브 감사 (세션 내 탐색)"
echo ""
echo "  Sentry"
echo "    CLI:  sentry-cli releases list"
echo "    MCP:  이슈 조회 + AI 근본원인 분석"
echo ""
echo "  Brave Search"
echo "    CLI:  curl 'https://api.search.brave.com/res/v1/web/search?q=query' -H 'X-Subscription-Token: \$BRAVE_API_KEY'"
echo "    MCP:  대화 내 인터랙티브 검색"
echo ""
