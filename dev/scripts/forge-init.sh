#!/bin/bash
# forge-init.sh — Forge 워크스페이스 초기화
# 대화형으로 forge-workspace.json을 생성한다.
# Usage: bash forge-init.sh [workspace-dir]

set -euo pipefail

WORKSPACE_DIR="${1:-.}"
CONFIG_FILE="$WORKSPACE_DIR/forge-workspace.json"
SCHEMA_PATH="$HOME/.claude/forge/schemas/forge-workspace-schema.json"

# 색상
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== Forge Workspace Initializer ===${NC}"
echo ""

# 기존 설정 확인
if [ -f "$CONFIG_FILE" ]; then
  echo -e "${YELLOW}forge-workspace.json이 이미 존재합니다: $CONFIG_FILE${NC}"
  read -p "덮어쓸까요? (y/N): " overwrite
  if [ "$overwrite" != "y" ] && [ "$overwrite" != "Y" ]; then
    echo "초기화를 취소합니다."
    exit 0
  fi
fi

# 워크스페이스 이름
read -p "워크스페이스 이름 (예: my-business): " ws_name
ws_name="${ws_name:-my-workspace}"

# 폴더 구조 선택
echo ""
echo -e "${CYAN}폴더 구조를 선택하세요:${NC}"
echo "  1) 기본 구조 (research/product/design/content/operations/templates/handoff)"
echo "  2) 단순 구조 (planning/design)"
echo "  3) 커스텀 (직접 입력)"
read -p "선택 (1/2/3): " folder_choice

case "$folder_choice" in
  1)
    research="01-research/projects"
    product="02-product/projects"
    design="05-design/projects"
    content="04-content/projects"
    operations="10-operations"
    templates="09-tools/templates"
    handoff="10-operations/handoff-to-dev"
    ;;
  2)
    research="planning/research"
    product="planning/product"
    design="planning/design"
    content="planning/content"
    operations="operations"
    templates="templates"
    handoff="operations/handoff"
    ;;
  3)
    read -p "리서치 경로 (research): " research
    research="${research:-research}"
    read -p "제품 기획 경로 (product): " product
    product="${product:-product}"
    read -p "디자인 경로 (design): " design
    design="${design:-design}"
    read -p "콘텐츠 경로 (content): " content
    content="${content:-content}"
    read -p "운영 경로 (operations): " operations
    operations="${operations:-operations}"
    read -p "템플릿 경로 (templates): " templates
    templates="${templates:-templates}"
    read -p "핸드오프 경로 (handoff): " handoff
    handoff="${handoff:-operations/handoff}"
    ;;
  *)
    echo "잘못된 선택입니다. 기본 구조를 사용합니다."
    research="01-research/projects"
    product="02-product/projects"
    design="05-design/projects"
    content="04-content/projects"
    operations="10-operations"
    templates="09-tools/templates"
    handoff="10-operations/handoff-to-dev"
    ;;
esac

# 프로젝트 등록
echo ""
echo -e "${CYAN}개발 프로젝트를 등록하세요 (빈 줄 입력으로 종료):${NC}"

projects_json=""
while true; do
  read -p "프로젝트명 (예: my-app, 빈 줄=종료): " proj_name
  [ -z "$proj_name" ] && break

  read -p "  개발 프로젝트 절대 경로: " dev_target
  read -p "  symlink 기본 경로 [docs/planning/active/forge]: " symlink_base
  symlink_base="${symlink_base:-docs/planning/active/forge}"

  if [ -n "$projects_json" ]; then
    projects_json="$projects_json,"
  fi
  projects_json="$projects_json
    \"$proj_name\": {
      \"devTarget\": \"$dev_target\",
      \"symlinkBase\": \"$symlink_base\"
    }"
done

# JSON 생성
cat > "$CONFIG_FILE" << EOF
{
  "\$schema": "/home/damools/forge/dev/schemas/forge-workspace-schema.json",
  "version": "1.0.0",
  "name": "$ws_name",
  "folderMap": {
    "research": "$research",
    "product": "$product",
    "design": "$design",
    "content": "$content",
    "operations": "$operations",
    "templates": "$templates",
    "handoff": "$handoff"
  },
  "projects": {$projects_json
  },
  "defaults": {
    "symlinkBase": "docs/planning/active/forge",
    "datePrefix": true
  }
}
EOF

# 폴더 생성
echo ""
echo -e "${CYAN}폴더 구조를 생성합니다...${NC}"
mkdir -p "$WORKSPACE_DIR/$research"
mkdir -p "$WORKSPACE_DIR/$product"
mkdir -p "$WORKSPACE_DIR/$design"
mkdir -p "$WORKSPACE_DIR/$content"
mkdir -p "$WORKSPACE_DIR/$templates"
mkdir -p "$WORKSPACE_DIR/$handoff"

echo -e "${GREEN}완료! forge-workspace.json이 생성되었습니다: $CONFIG_FILE${NC}"
echo ""
echo "다음 단계:"
echo "  1. Forge 파이프라인 시작: /forge <프로젝트명>"
echo "  2. S4 완료 후 Forge Dev 진입: /forge <프로젝트명>"
