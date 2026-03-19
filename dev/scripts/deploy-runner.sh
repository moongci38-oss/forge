#!/usr/bin/env bash
# deploy-runner.sh — Forge Dev Phase 6/7 배포 실행기
# 사용법: bash deploy-runner.sh --env <staging|production> [--config <path>]
#
# release-config.json의 deployCommand를 읽어 실행한다.
# deployCommand가 빈 문자열이면 skip하고 build/test만 실행한다.

set -euo pipefail

ENV=""
CONFIG_FILE="release-config.json"

# 인수 파싱
while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
      shift 2
      ;;
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$ENV" ]]; then
  echo "Error: --env <staging|production> is required" >&2
  exit 1
fi

if [[ "$ENV" != "staging" && "$ENV" != "production" ]]; then
  echo "Error: --env must be 'staging' or 'production'" >&2
  exit 1
fi

# release-config.json 읽기
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "::notice::$CONFIG_FILE not found — skipping deploy, running build only"
  if [[ -f "package.json" ]]; then
    echo "[deploy-runner] Running build..."
    if command -v pnpm &>/dev/null; then
      pnpm run build
    elif command -v npm &>/dev/null; then
      npm run build
    fi
  fi
  exit 0
fi

# Node.js로 JSON 파싱 (jq 미설치 환경 대응)
DEPLOY_CMD=$(node -e "
  try {
    const c = require('./$CONFIG_FILE');
    const cmd = c.environments?.['$ENV']?.deployCommand || '';
    process.stdout.write(cmd);
  } catch(e) {
    process.stdout.write('');
  }
" 2>/dev/null || echo "")

HEALTH_ENDPOINT=$(node -e "
  try {
    const c = require('./$CONFIG_FILE');
    const ep = c.environments?.['$ENV']?.healthEndpoint || '';
    process.stdout.write(ep);
  } catch(e) {
    process.stdout.write('');
  }
" 2>/dev/null || echo "")

HEALTH_TIMEOUT=$(node -e "
  try {
    const c = require('./$CONFIG_FILE');
    const t = c.environments?.['$ENV']?.healthTimeout || 120;
    process.stdout.write(String(t));
  } catch(e) {
    process.stdout.write('120');
  }
" 2>/dev/null || echo "120")

# 배포 실행
if [[ -z "$DEPLOY_CMD" ]]; then
  echo "[deploy-runner] deployCommand is empty for '$ENV' — 배포 인프라 미설정"
  echo "[deploy-runner] build/test만 실행합니다. 배포하려면 $CONFIG_FILE의 environments.$ENV.deployCommand를 설정하세요."
  exit 0
fi

echo "[deploy-runner] Deploying to $ENV..."
echo "[deploy-runner] Command: $DEPLOY_CMD"
eval "$DEPLOY_CMD"
echo "[deploy-runner] Deploy command completed."

# Health check
if [[ -n "$HEALTH_ENDPOINT" ]]; then
  echo "[deploy-runner] Waiting for health check: $HEALTH_ENDPOINT (timeout: ${HEALTH_TIMEOUT}s)"
  END=$((SECONDS + HEALTH_TIMEOUT))
  while [[ $SECONDS -lt $END ]]; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_ENDPOINT" 2>/dev/null || echo "000")
    if [[ "$STATUS" == "200" ]]; then
      echo "[deploy-runner] Health check passed (HTTP 200)"
      exit 0
    fi
    echo "[deploy-runner] Health check returned $STATUS — retrying in 5s..."
    sleep 5
  done
  echo "[deploy-runner] Error: Health check timed out after ${HEALTH_TIMEOUT}s" >&2
  exit 1
fi

echo "[deploy-runner] Done (no health endpoint configured)."
