#!/usr/bin/env bash
# Forge MCP Setup — 전역 MCP 서버를 ~/.claude.json에 등록
# 팀원 온보딩 시 실행: bash shared/scripts/setup-mcp.sh
# 이미 등록된 서버는 건너뜀 (멱등성 보장)

set -euo pipefail

CLAUDE_JSON="$HOME/.claude.json"

# jq 없이 동작하도록 node 기반 처리
if ! command -v node &>/dev/null; then
  echo "ERROR: Node.js가 필요합니다. 설치 후 재실행하세요."
  exit 1
fi

# MCP 서버 정의 (JSON)
read -r -d '' MCP_SERVERS << 'SERVERS_EOF' || true
{
  "stitch": {
    "type": "stdio",
    "command": "npx",
    "args": ["@_davideast/stitch-mcp", "proxy"],
    "env": { "STITCH_API_KEY": "${STITCH_API_KEY}" }
  },
  "lighthouse-web": {
    "type": "stdio",
    "command": "npx",
    "args": ["@danielsogl/lighthouse-mcp@latest"]
  },
  "sentry": {
    "type": "http",
    "url": "https://mcp.sentry.dev/mcp"
  },
  "brave-search": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-brave-search"],
    "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" }
  },
  "drawio": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@drawio/mcp"]
  },
  "magic-ui": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@magicuidesign/mcp@latest"]
  },
  "ludo": {
    "type": "http",
    "url": "https://mcp.ludo.ai/mcp",
    "headers": { "Authentication": "ApiKey ${LUDO_API_KEY}" }
  },
  "replicate": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "replicate-mcp"],
    "env": { "REPLICATE_API_TOKEN": "${REPLICATE_API_TOKEN}" }
  },
  "nano-banana": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@akashvekariya/nano-banana-mcp"],
    "env": { "GEMINI_API_KEY": "${GEMINI_API_KEY}" }
  },
  "notion": {
    "type": "http",
    "url": "https://mcp.notion.com/mcp"
  }
}
SERVERS_EOF

# Node.js 스크립트로 머지
node -e "
const fs = require('fs');
const path = '${CLAUDE_JSON}';

// ~/.claude.json 읽기 (없으면 빈 객체)
let config = {};
if (fs.existsSync(path)) {
  config = JSON.parse(fs.readFileSync(path, 'utf8'));
}

// mcpServers 필드 초기화
if (!config.mcpServers) {
  config.mcpServers = {};
}

const newServers = ${MCP_SERVERS};
let added = 0;
let skipped = 0;

for (const [name, serverConfig] of Object.entries(newServers)) {
  if (config.mcpServers[name]) {
    console.log('  ⏭ ' + name + ' (already exists)');
    skipped++;
  } else {
    config.mcpServers[name] = serverConfig;
    console.log('  + ' + name);
    added++;
  }
}

fs.writeFileSync(path, JSON.stringify(config, null, 2) + '\n');
console.log('');
console.log('Done: ' + added + ' added, ' + skipped + ' skipped');

if (added > 0) {
  // 환경변수 필요 서버 안내
  const envVars = [
    'STITCH_API_KEY',
    'BRAVE_API_KEY',
    'LUDO_API_KEY',
    'REPLICATE_API_TOKEN',
    'GEMINI_API_KEY'
  ];
  console.log('');
  console.log('Required env vars (set in ~/.claude/.env or shell profile):');
  envVars.forEach(v => console.log('  - ' + v));
}
"

echo ""
echo "MCP setup complete. Restart Claude Code to apply."
