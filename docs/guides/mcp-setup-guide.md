# MCP 서버 설정 가이드

> Business 워크스페이스 MCP 서버 설정 완료 가이드

---

## 설정 현황

### ✅ 완료된 작업

1. **Project 스코프 MCP 서버** (`.mcp.json`) - ✅ 설치 완료
   - Filesystem
   - ~~Playwright~~ → **Playwright CLI** (`@playwright/cli`) 전환 완료
   - Sequential Thinking
   - Memory

2. **Memory 디렉토리** - ✅ 생성 완료
   - `.claude/memory/memory.jsonl`

3. **CLAUDE.md** - ✅ 업데이트 완료
   - MCP 사용 가이드 추가

4. **환경변수** - ✅ 설정 완료
   - `ENABLE_TOOL_SEARCH=auto` (토큰 효율성 최적화)

### ⚠️ 수동 작업 필요

**User 스코프 MCP 서버** (`~/.claude.json`) - Context7, Brave Search

---

## User 스코프 MCP 서버 수동 추가 방법

### 방법 1: 텍스트 에디터로 직접 추가 (권장)

1. **파일 열기**: `C:\Users\{사용자명}\.claude.json` (또는 `~/.claude.json`)

2. **파일 끝부분에 다음 내용 추가**:
```json
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {
        "CONTEXT7_API_KEY": "<YOUR_CONTEXT7_API_KEY>"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@brave/brave-search-mcp-server"],
      "env": {
        "BRAVE_API_KEY": "<YOUR_BRAVE_API_KEY>"
      }
    }
  }
```

3. **주의사항**:
   - 마지막 줄 `"showSpinnerTree": false` 뒤에 **쉼표(,)** 를 추가한 후 `mcpServers`를 추가해야 합니다
   - JSON 형식이 올바른지 확인 (괄호, 쉼표 체크)

4. **저장 후 Claude Code 재시작**

### 방법 2: Claude CLI 사용 (대안)

```bash
# Context7
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest

# Brave Search
claude mcp add --scope user brave-search -e BRAVE_API_KEY=<YOUR_BRAVE_API_KEY> \
  -- npx -y @brave/brave-search-mcp-server
```

---

## 설정 확인 방법

### 1. Claude Code 재시작

```bash
cd <YOUR_BUSINESS_ROOT>
claude
```

### 2. MCP 서버 목록 확인

Claude Code 인터랙티브 세션에서:
```
/mcp list
```

**예상 출력**:
- context7 (user 스코프)
- brave-search (user 스코프)
- filesystem (project 스코프)
- playwright-cli (글로벌 npm 패키지, `playwright-cli --version`으로 확인)
- sequential-thinking (project 스코프)
- memory (project 스코프)

### 3. 컨텍스트 확인

```
/context
```

총 5개 MCP 서버 + playwright-cli가 표시되어야 합니다.

---

## 테스트 프롬프트

### Brave Search 테스트
```
"2026년 SaaS 시장 트렌드를 조사해줘"
```

### Context7 테스트
```
"Next.js 15의 Server Actions 사용법을 알려줘"
```

### Filesystem 테스트
```
"E:\portfolio_project 폴더의 프로젝트 목록을 보여줘"
```

### Sequential Thinking 테스트
```
"신제품 출시 전략을 단계별로 계획해줘"
```

### Memory 테스트
```
"이 시장 조사 결과를 기억해줘: SaaS 시장은 2026년 $1,200억 규모로 성장 예상"
```

---

## 문제 해결

### MCP 서버가 연결되지 않는 경우

1. **~/.claude.json 형식 확인**
   - JSON 형식이 올바른지 확인 (https://jsonlint.com/ 에서 검증)

2. **Claude Code 재시작**
   - 완전히 종료 후 다시 시작

3. **npx 명령 확인**
   ```bash
   npx -y @upstash/context7-mcp@latest --version
   npx -y @brave/brave-search-mcp-server --version
   ```

4. **API 키 확인**
   - Brave API 키: `<YOUR_BRAVE_API_KEY>`
   - Context7 API 키: `<YOUR_CONTEXT7_API_KEY>`

### Brave Search rate limit 초과

- 무료: 월 2,000쿼리
- 초과 시: Pro 플랜 고려 ($3/1,000쿼리)

---

## 다음 단계

1. User 스코프 MCP 서버 수동 추가 (위 가이드 참조)
2. Claude Code 재시작
3. `/mcp list`로 6개 서버 확인
4. 테스트 프롬프트로 각 서버 동작 확인
5. 포트폴리오 프로젝트 분석 시작

---

*Created: 2026-02-16*
*Status: Project MCP 완료, User MCP 수동 작업 대기*
