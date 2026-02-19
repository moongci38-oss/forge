# MCP 서버 복구 가이드

> `.claude.json` 파일이 초기화되었을 때 MCP 설정을 복구하는 방법

## 문제 상황

- `C:\Users\{사용자명}\.claude.json`이 초기화됨
- Context7, Brave Search 설정 손실

---

## 복구 방법

### 1단계: VS Code 완전히 종료

**중요**: Claude Code/VS Code를 완전히 종료해야 합니다. (작업 관리자에서도 확인)

### 2단계: 설정 파일 수정

메모장이나 다른 텍스트 에디터로 `C:\Users\{사용자명}\.claude.json` 열기:

```json
{
  "clientDataCache": {
    "data": {},
    "timestamp": 1771240215735
  },
  "userID": "<YOUR_USER_ID>",
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp@latest"
      ],
      "env": {
        "CONTEXT7_API_KEY": "<YOUR_CONTEXT7_API_KEY>"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": [
        "-y",
        "@brave/brave-search-mcp-server"
      ],
      "env": {
        "BRAVE_API_KEY": "<YOUR_BRAVE_API_KEY>"
      }
    }
  }
}
```

**주의**: 마지막 userID 뒤에 쉼표(`,`)를 추가하고, 맨 끝 `mcpServers` 블록을 추가하세요.

### 3단계: VS Code 재시작

1. 설정 파일 저장
2. VS Code 재시작
3. `Ctrl+Shift+P` → `Claude Code: Manage MCP Servers` 에서 연결 확인

---

## 현재 MCP 서버 상태

### Project MCP (`.mcp.json`)

| 서버 | 상태 | 설정 |
|------|------|------|
| filesystem | ✅ 수정 완료 | `Z:/`, `E:/` 경로 사용 |
| memory | ✅ 정상 | |
| playwright | ✅ 정상 | |
| sequential-thinking | ✅ 정상 | |

### User MCP (`~/.claude.json`)

| 서버 | 상태 | API 키 |
|------|------|--------|
| context7 | ⚠️ 복구 필요 | `ctx7sk-f04d...` |
| brave-search | ⚠️ 복구 필요 | `BSA2LDy...` (신규) |

---

## 대체 방법: Claude Code UI 사용

VS Code에서:

1. **View** → **Command Palette** (`Ctrl+Shift+P`)
2. `Claude Code: Manage MCP Servers` 입력
3. **Add Server** 클릭
4. 각 서버 정보 입력:

### Context7 서버 추가
- Name: `context7`
- Command: `npx`
- Args: `-y`, `@upstash/context7-mcp@latest`
- Environment Variables:
  - `CONTEXT7_API_KEY`: `<YOUR_CONTEXT7_API_KEY>`

### Brave Search 서버 추가
- Name: `brave-search`
- Command: `npx`
- Args: `-y`, `@brave/brave-search-mcp-server`
- Environment Variables:
  - `BRAVE_API_KEY`: `<YOUR_BRAVE_API_KEY>`

---

## 백업 권장사항

향후 유사한 문제 방지를 위해 정기적으로 백업:

```bash
# MCP 설정 백업
cp ~/.claude.json ~/backup/.claude.json.backup
cp .mcp.json ./backup/.mcp.json.backup

# 또는 Git으로 관리
cd ~/business
git add .mcp.json
git commit -m "backup: MCP configuration"
```

---

*Last Updated: 2026-02-16*
