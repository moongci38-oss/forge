# 팀원 온보딩 가이드

> 신규 팀원이 3개 프로젝트를 로컬 PC에 세팅하는 전체 과정

---

## 1. 사전 요구사항

| 도구 | 버전 | 설치 |
|------|------|------|
| Node.js | 20+ | https://nodejs.org/ |
| Git | 2.40+ | https://git-scm.com/ |
| PowerShell | 7+ | `winget install Microsoft.PowerShell` |
| WSL2 | Ubuntu 22.04 | `wsl --install -d Ubuntu-22.04` |
| VS Code | 최신 | https://code.visualstudio.com/ |
| Claude Code CLI | 최신 | `npm install -g @anthropic-ai/claude-code` |

### WSL 내부 추가 설치 (Agent Teams용)

```bash
sudo apt update && sudo apt install -y tmux
```

---

## 2. 프로젝트 클론

### SSH 키 설정

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# → GitHub Settings > SSH Keys에 등록
```

### 3개 프로젝트 클론

```bash
# Business (HTTPS)
git clone https://github.com/moongci38-oss/ai-business-workspace.git ~/business

# Portfolio (SSH)
git clone git@github.com:ljw7555-rgb/portfolio-project.git ~/portfolio-project

# GodBlade (SSH)
git clone git@github.com:ljw7555-rgb/godblade.git ~/godblade
```

> 경로는 자유롭게 변경 가능. 이후 환경변수에 실제 경로를 설정한다.

---

## 3. 환경변수 설정

### 시스템 환경변수 (Windows)

`시스템 속성 > 환경 변수 > 사용자 변수`에 추가:

| 변수명 | 값 (예시) | 설명 |
|--------|----------|------|
| `BUSINESS_ROOT` | `C:\Users\홍길동\business` | Business 워크스페이스 절대경로 |
| `PORTFOLIO_PROJECT` | `C:\Users\홍길동\portfolio-project` | Portfolio 프로젝트 절대경로 |
| `BRAVE_API_KEY` | (팀 리더에게 문의) | Brave Search API 키 |
| `CONTEXT7_API_KEY` | (팀 리더에게 문의) | Context7 API 키 |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | `1` | Agent Teams 활성화 (선택) |

### WSL 환경변수 (Agent Teams 사용 시)

```bash
# ~/.bashrc 에 추가
export BUSINESS_ROOT="/home/$(whoami)/business"
export PORTFOLIO_PROJECT="/home/$(whoami)/portfolio-project"
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

---

## 4. MCP 서버 설정

### 프로젝트별 `.mcp.json` 생성

각 프로젝트에 `.mcp.json.example` (또는 `.env.template`)이 제공됨.
복사 후 자신의 경로/크레덴셜로 수정한다.

#### Business

```bash
cd ~/business
cp .mcp.json.example .mcp.json
# 에디터로 열어서 <YOUR_BUSINESS_ROOT>, <YOUR_PORTFOLIO_PROJECT> 를 실제 경로로 교체
```

#### Portfolio

```bash
cd ~/portfolio-project
cp .env.example .env
# PostgreSQL, Redis 크레덴셜 입력 (팀 리더에게 문의)
```

#### GodBlade

```bash
cd ~/godblade/src
cp .env.template .env
# MySQL, Redis 크레덴셜 입력 (팀 리더에게 문의)
```

### User 스코프 MCP 서버 (Brave Search, Context7)

```bash
# Claude Code CLI로 추가
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest
claude mcp add --scope user brave-search -e BRAVE_API_KEY=$BRAVE_API_KEY -- npx -y @brave/brave-search-mcp-server
```

---

## 5. VS Code 멀티루트 워크스페이스 설정

`File > Add Folder to Workspace`로 3개 프로젝트를 추가하거나,
`.code-workspace` 파일을 생성:

```json
{
  "folders": [
    { "path": "./business", "name": "BUSINESS" },
    { "path": "./portfolio-project", "name": "PORTFOLIO" },
    { "path": "./godblade/src", "name": "GODBLADE" }
  ]
}
```

> 경로는 자신의 환경에 맞게 수정

---

## 6. 검증 체크리스트

각 프로젝트 터미널에서 Claude Code를 실행해 확인:

```bash
cd ~/business && claude
# /mcp list → filesystem, playwright, sequential-thinking, memory, notion 확인
```

```bash
cd ~/portfolio-project && claude
# /mcp list → redis, postgres 확인
```

```bash
cd ~/godblade/src && claude
# /mcp list → mysql-eod-game 외 7개 서버 확인
```

---

## 7. 프로젝트별 주의사항

### Business

- **B영역(06-finance, 07-legal, 08-admin) 접근 금지** — 민감 정보
- 코드 개발 금지 (개발은 Portfolio/GodBlade에서)
- 파일명: `YYYY-MM-DD-{description}.md` 형식 필수

### GodBlade

- **SDD (Spec Driven Development) 워크플로우 필수**: Spec → Plan → Task → Implement → PR
- 브랜치: `develop` → `staging` → `main`
- Agent Teams: Server Teammate(`server/**`)와 Client Teammate(`client/**`) 도메인 분리

### Portfolio

- 브랜치: `develop` → `staging` → `main`
- Agent Teams: Backend Teammate(`apps/api/**`)와 Frontend Teammate(`apps/web/**`) 도메인 분리
- `pnpm` 패키지 매니저 사용

---

## 8. Agent Teams 사용법 (선택)

Agent Teams는 병렬 작업 시 사용. **tmux가 필수**.

```bash
# WSL에서 실행
wsl -d Ubuntu-22.04
tmux new-session -s agent-team
cd ~/godblade/src  # 또는 다른 프로젝트
claude
```

자세한 가이드: 각 프로젝트의 `.claude/rules/agent-teams.md` 참조

---

## 9. 키 로테이션 / 보안

- API 키는 **절대 git에 커밋하지 않는다**
- `.env`, `.mcp.json`, `.claude/settings.local.json`은 `.gitignore`에 포함됨
- 키가 노출된 경우 즉시 로테이션:
  - Brave Search: https://brave.com/search/api/
  - Context7: https://context7.com/

---

*Created: 2026-02-19*
