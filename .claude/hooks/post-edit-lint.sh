#!/usr/bin/env bash
# post-edit-lint.sh — Edit/Write PostToolUse on source files
# *.ts/*.js/*.py/*.cs 변경 시 lint/type-check 자동 실행 (경고만, 차단 아님)

set -uo pipefail

INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')

# 소스 파일 확장자 필터
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"
case "$EXT" in
  ts|js|py|cs) ;;
  *) exit 0 ;;
esac

# GIT_ROOT 기준으로 패키지 루트 탐색
GIT_ROOT=$(git -C "$(dirname "$FILE_PATH")" rev-parse --show-toplevel 2>/dev/null || dirname "$FILE_PATH")

run_lint() {
  local ext="$1"
  local file="$2"
  local root="$3"
  local out rc=0

  case "$ext" in
    ts|js)
      if [[ -f "$root/package.json" ]]; then
        # ESLint 우선, 없으면 tsc --noEmit
        if [[ -f "$root/.eslintrc"* ]] || jq -e '.eslintConfig' "$root/package.json" >/dev/null 2>&1 || \
           [[ -f "$root/.eslintrc.js" || -f "$root/.eslintrc.json" || -f "$root/.eslintrc.cjs" || -f "$root/eslint.config.js" ]]; then
          out=$(cd "$root" && npx --no eslint "$file" 2>&1) || rc=$?
        elif [[ -f "$root/tsconfig.json" && "$ext" == "ts" ]]; then
          out=$(cd "$root" && npx --no tsc --noEmit 2>&1) || rc=$?
        fi
      fi
      ;;
    py)
      # ruff 우선, 없으면 flake8
      if command -v ruff >/dev/null 2>&1; then
        out=$(ruff check "$file" 2>&1) || rc=$?
      elif command -v flake8 >/dev/null 2>&1; then
        out=$(flake8 "$file" 2>&1) || rc=$?
      fi
      ;;
    cs)
      # dotnet build (경고 출력용)
      if ls "$root"/*.csproj "$root"/*.sln 2>/dev/null | head -1 | grep -q .; then
        out=$(cd "$root" && dotnet build --no-restore --verbosity minimal 2>&1) || rc=$?
      fi
      ;;
  esac

  if [[ $rc -ne 0 && -n "${out:-}" ]]; then
    # PostToolUse는 stdout이 Claude 컨텍스트에 경고로 노출됨 (exit 0 유지 → 차단 아님)
    printf '[post-edit-lint] ⚠️  lint/type 경고 (%s)\n%s\n' "$file" "$out" >&2
  fi
}

run_lint "$EXT" "$FILE_PATH" "$GIT_ROOT"
exit 0
