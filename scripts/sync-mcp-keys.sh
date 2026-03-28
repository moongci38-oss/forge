#!/bin/bash
# forge/.env의 MCP API 키들을 ~/.claude.json 헤더에 동기화한다.
# Source of truth: ~/forge/.env
# 사용: bash ~/forge/scripts/sync-mcp-keys.sh

set -euo pipefail

ENV_FILE="${FORGE_ROOT:-$HOME/forge}/.env"
CLAUDE_JSON="$HOME/.claude.json"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: $ENV_FILE not found"
  exit 1
fi

# forge/.env에서 키 로드
set -a && source "$ENV_FILE" && set +a

# python으로 .claude.json 업데이트
python3 -c "
import json, os

with open('$CLAUDE_JSON') as f:
    d = json.load(f)

servers = d.get('mcpServers', {})

# Ludo: Authentication 헤더에 API 키 주입
if 'ludo' in servers:
    key = os.environ.get('LUDO_API_KEY', '')
    if key:
        servers['ludo']['headers'] = {'Authentication': f'ApiKey {key}'}
        servers['ludo'].pop('env', None)
        servers['ludo'].pop('envFile', None)
        print(f'ludo: synced (key={key[:8]}...)')
    else:
        print('ludo: LUDO_API_KEY not found in env')

with open('$CLAUDE_JSON', 'w') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)

print('Done. Restart Claude Code to apply.')
"
