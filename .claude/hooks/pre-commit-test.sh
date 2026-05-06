#!/usr/bin/env bash
# pre-commit-test.sh — git commit PreToolUse
# 프로젝트 타입 감지(npm/pytest/dotnet) → 테스트 자동 실행 → 실패 시 exit 2로 차단
#
# 입력: stdin JSON { tool_name, tool_input: { command } }
# exit 2 → 차단 + stdout을 Claude에 피드백

set -uo pipefail

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')

# git commit 명령만 처리
if ! printf '%s' "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

# CWD 결정: git root 기준
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# ── 프로젝트 타입 감지 ──────────────────────────────────────────────
detect_type() {
  local root="$1"
  if [[ -f "$root/package.json" ]]; then
    echo "npm"
  elif [[ -f "$root/pytest.ini" || -f "$root/pyproject.toml" || -f "$root/setup.py" ]]; then
    echo "pytest"
  elif ls "$root"/*.sln "$root"/*.csproj 2>/dev/null | head -1 | grep -q .; then
    echo "dotnet"
  elif find "$root" -maxdepth 3 -name "test_*.py" -o -name "*_test.py" 2>/dev/null | head -1 | grep -q .; then
    echo "pytest"
  else
    echo "unknown"
  fi
}

PROJECT_TYPE=$(detect_type "$GIT_ROOT")

# ── 테스트 실행 ────────────────────────────────────────────────────
run_tests() {
  local type="$1"
  local root="$2"
  local out
  local rc=0

  case "$type" in
    npm)
      # test 스크립트가 있을 때만 실행
      if jq -e '.scripts.test' "$root/package.json" >/dev/null 2>&1; then
        out=$(cd "$root" && npm test 2>&1) || rc=$?
      else
        exit 0
      fi
      ;;
    pytest)
      PYTEST_BIN=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "")
      if [[ -z "$PYTEST_BIN" ]]; then exit 0; fi
      if ! "$PYTEST_BIN" -m pytest --version >/dev/null 2>&1; then exit 0; fi
      out=$(cd "$root" && "$PYTEST_BIN" -m pytest --tb=short -q 2>&1) || rc=$?
      ;;
    dotnet)
      out=$(cd "$root" && dotnet test --no-build --verbosity minimal 2>&1) || rc=$?
      ;;
    unknown)
      exit 0
      ;;
  esac

  if [[ $rc -ne 0 ]]; then
    printf '⛔ [pre-commit-test] 테스트 실패 — commit 차단\n\n프로젝트 타입: %s\n\n%s\n\n테스트를 수정한 후 다시 commit 하세요.' \
      "$type" "$out"
    exit 2
  fi
}

run_tests "$PROJECT_TYPE" "$GIT_ROOT"
exit 0
