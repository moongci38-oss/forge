# Claude Code 실무 MCP 서버 Top 10 심층 분석

**Claude Code에서 가장 많이 사용되는 MCP 서버 10개를 GitHub 스타, npm 다운로드, Smithery 사용량, 커뮤니티 추천 빈도를 종합 분석한 결과, Context7이 주간 21만 다운로드로 1위, Playwright MCP(26.8k 스타)와 GitHub MCP Server(26.7k 스타)가 그 뒤를 잇고 있다.** MCP Tool Search 기능(v2.1.7+) 도입으로 컨텍스트 소비량이 **85% 감소**하면서, 이전에는 2~3개로 제한되던 MCP 서버를 이제 수십 개까지 연결할 수 있게 되었다. 이 리포트는 각 서버의 설치 설정, 도구 목록, 실전 사용법, 컨텍스트 관리 전략을 실무 관점에서 상세히 다룬다.

---

## 인기도 순위와 선정 기준

순위는 GitHub 스타 수, npm 주간 다운로드, Smithery.ai 사용량, 커뮤니티 추천 빈도를 종합 가중치로 산정했다. 공식 `modelcontextprotocol/servers` 모노레포(78.2k 스타)에 속한 서버는 개별 npm 다운로드와 Smithery 사용량으로 구분했다.

| 순위 | 서버명 | GitHub 스타 | npm 주간 다운로드 | Smithery 사용 | 카테고리 |
|:---:|--------|:-----------:|:----------------:|:------------:|---------|
| 1 | Context7 | 45.0k | ~214,000 | - | 문서/컨텍스트 |
| 2 | Playwright MCP | 26.8k | ~44,000 | 257+ | 브라우저 자동화 |
| 3 | GitHub MCP Server | 26.7k | Docker 기반 | 2,890+ | 버전 관리 |
| 4 | TaskMaster MCP | 25.3k | npm | 374+ | 태스크 관리 |
| 5 | Filesystem MCP | (모노레포) | ~137,649 | - | 파일시스템 |
| 6 | Sequential Thinking | (모노레포) | ~49,731 | **5,550+** | 구조화 사고 |
| 7 | Brave Search MCP | (모노레포) | - | 680+ | 웹 검색 |
| 8 | Figma Context MCP | 13.0k | - | - | 디자인 |
| 9 | Desktop Commander | 5.4k | - | 199+ | 시스템 제어 |
| 10 | Memory MCP | (모노레포) | - | 263+ | 영속 메모리 |

주목할 점은 Sequential Thinking이 Smithery에서 **사용량 1위(5,550+)**를 기록하면서 실제 활용도에서 최상위를 차지하고 있다는 점이다. Figma MCP는 단일 용도 서버임에도 **13k 스타**를 달성하며 디자인-투-코드 워크플로의 수요를 입증했다.

---

## 1위: Context7 — 라이브러리 문서의 실시간 주입

Context7은 **AI 모델의 훈련 데이터 커트오프 문제를 해결**한다. React 19, Next.js 15 등 최신 라이브러리 API를 질의 시점에 실시간으로 가져와 프롬프트에 주입함으로써, 할루시네이션과 deprecated API 생성을 방지한다. 주간 **21만 다운로드**로 전체 MCP 서버 중 가장 높은 npm 다운로드를 기록하며, 거의 모든 "best MCP" 리스트에서 추천된다.

**제공 도구 (2개):**
- `resolve-library-id` — 라이브러리명을 Context7 호환 ID로 변환 (예: "Next.js" → `/vercel/next.js`)
- `get-library-docs` — 해당 라이브러리의 최신 문서, 코드 예시, API 레퍼런스 반환

**Claude Code 설정:**
```bash
# CLI 설치 (user 스코프 — 모든 프로젝트에서 사용)
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest
```

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

**API 키:** 선택 사항. https://context7.com/dashboard에서 무료 키를 발급받으면 rate limit이 완화된다. 키 없이도 공개 rate limit 내에서 사용 가능하다.

**실전 프롬프트 예시:**
```
Next.js 15에서 미들웨어로 인증을 처리하는 코드를 작성해줘. use context7
Prisma 6으로 PostgreSQL 연결 설정을 해줘. use context7
```

**컨텍스트 관리 팁:** MCP Tool Search 활성화 시 `use context7` 트리거 전까지 **토큰 소비 0**. CLAUDE.md에 `"라이브러리 관련 코드 생성 시 항상 context7을 사용하세요"` 룰을 추가하면 자동 호출이 가능하다. `ERR_MODULE_NOT_FOUND` 에러 발생 시 `bunx`로 전환하면 해결된다.

---

## 2위: Playwright MCP — 접근성 기반 브라우저 자동화

Microsoft 공식 Playwright MCP는 스크린샷 대신 **접근성 스냅샷(accessibility snapshot)**을 사용해 웹 페이지를 텍스트 구조로 표현한다. 비전 모델 없이도 결정적이고 빠른 브라우저 상호작용이 가능하며, 토큰 효율성이 스크린샷 방식보다 월등하다. **27.1k 스타**, Apache-2.0 라이선스.

**제공 도구 (25+ 코어 도구):**
- **핵심:** `browser_navigate`, `browser_click`, `browser_fill_form`, `browser_snapshot`, `browser_type`, `browser_press_key`, `browser_select_option`, `browser_wait_for`
- **모니터링:** `browser_console_messages`, `browser_network_requests`, `browser_take_screenshot`
- **고급:** `browser_evaluate` (JS 실행), `browser_file_upload`, `browser_drag`, `browser_tabs`
- **선택적(`--caps`):** Vision 도구(좌표 기반 클릭), PDF 생성, 테스트 코드 생성

**Claude Code 설정:**
```bash
claude mcp add playwright -- npx @playwright/mcp@latest
```

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest", "--headless", "--browser", "chromium"]
    }
  }
}
```

**API 키:** 없음. 완전 로컬 실행. 웹앱 인증은 보이는 브라우저에서 수동 로그인 후 세션 유지.

**실전 프롬프트 예시:**
```
playwright mcp로 localhost:3000에서 회원가입 폼을 테스트 데이터로 채우고 제출한 후 성공 메시지를 확인해줘
모바일, 태블릿, 데스크톱 세 가지 화면 크기로 홈페이지 스크린샷을 찍어줘
```

**컨텍스트 관리 전략:** 접근성 스냅샷이 대형 페이지에서 매우 크질 수 있으므로, `--snapshot-mode=incremental`(기본값)을 사용하고, 코딩 에이전트 고처리량 작업에는 Playwright CLI+SKILLS 모드가 더 효율적이다. **서브에이전트에 Playwright 도구만 할당하는 패턴**이 메인 컨텍스트 오염을 방지하는 최선 방법이다.

```yaml
# .claude/agents/ui-tester.md
---
name: ui-tester
description: UI 테스트 전문 서브에이전트
tools: mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_click, Read
model: sonnet
---
Playwright MCP 도구를 사용해 웹 인터페이스를 테스트합니다.
```

---

## 3위: GitHub MCP Server — Git 워크플로 완전 통합

GitHub 공식 MCP 서버는 레포, 이슈, PR, CI/CD, 코드 스캐닝, Dependabot까지 **GitHub API 전체를 커버**한다. Go로 작성되어 Docker 이미지로 배포되며, 구 npm 패키지(`@modelcontextprotocol/server-github`)는 **2025년 4월 deprecated**되었다. **26.7k 스타**, Smithery 2,890+ 사용.

**제공 도구 (40+ 도구, 17개 toolset):**

| Toolset | 주요 도구 |
|---------|---------|
| repos | `get_file_contents`, `push_files`, `search_repositories`, `search_code`, `list_commits` |
| issues | `create_issue`, `update_issue`, `list_issues`, `search_issues`, `add_issue_comment` |
| pull_requests | `create_pull_request`, `merge_pull_request`, `get_pull_request_diff`, `create_pull_request_review` |
| actions | `actions_list`, `actions_run_trigger`, `get_job_logs` |
| code_security | `list_code_scanning_alerts`, `get_code_scanning_alert` |

**Claude Code 설정:**

```bash
# 방법 A: Remote HTTP (OAuth 지원, 권장)
claude mcp add --transport http github https://api.githubcopilot.com/mcp/

# 방법 B: Docker (PAT 사용)
claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxx \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
```

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
        "-e", "GITHUB_TOOLSETS=repos,issues,pull_requests",
        "ghcr.io/github/github-mcp-server"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_xxxx"
      }
    }
  }
}
```

**컨텍스트 관리 핵심:** 40+ 도구가 한꺼번에 로드되면 컨텍스트의 **~25%를 소비**한다. 반드시 `GITHUB_TOOLSETS` 환경변수로 필요한 toolset만 활성화하거나, `GITHUB_DYNAMIC_TOOLSETS=1`로 동적 로딩을 활성화해야 한다. `--read-only` 플래그로 분석 전용 모드 설정이 가능하다.

---

## 4위: TaskMaster MCP — AI 기반 프로젝트 태스크 관리

TaskMaster는 PRD를 파싱해 **의존성 인식 태스크 트리로 분해**하고, 복잡도 분석, 우선순위 결정, 다중 AI 프로바이더 지원(Claude, GPT, Gemini, Perplexity)을 제공한다. **25.3k 스타**로 에이전틱 코딩 워크플로의 핵심 도구다.

**도구 구성 (TASK_MASTER_TOOLS 환경변수로 제어):**
- **Core (7개, ~70% 토큰 절감):** `get_tasks`, `next_task`, `get_task`, `set_task_status`, `update_subtask`, `parse_prd`, `expand_task`
- **Standard (15개):** Core + `initialize_project`, `analyze_project_complexity`, `add_subtask`, `generate` 등
- **All (36개):** Standard + 의존성 관리, 태그, 리서치, 배치 작업 등

**Claude Code 설정:**
```bash
claude mcp add task-master-ai --scope user \
  --env TASK_MASTER_TOOLS="core" \
  --env ANTHROPIC_API_KEY="sk-ant-xxxx" \
  -- npx -y task-master-ai@latest
```

```json
{
  "mcpServers": {
    "task-master-ai": {
      "command": "npx",
      "args": ["-y", "task-master-ai"],
      "env": {
        "TASK_MASTER_TOOLS": "core",
        "ANTHROPIC_API_KEY": "sk-ant-xxxx"
      }
    }
  }
}
```

**토큰 소비 주의:** TaskMaster 단독으로 200k 컨텍스트 중 **~33k 토큰을 소비**한다. `"core"` 모드를 사용하면 약 **70% 절감**된다. 태스크 간 전환 시 반드시 `/clear`로 새 채팅을 시작해야 한다. PRD 파싱 시 Claude Code에서 JSON 파싱 에러가 발생할 수 있으며, Cursor에서 먼저 파싱 후 Claude Code로 전환하는 우회법이 있다.

---

## 5위: Filesystem MCP — 안전한 파일시스템 접근

공식 레퍼런스 서버로 **디렉토리 화이트리스트 기반의 샌드박싱된 파일 작업**을 제공한다. 주간 **~137,649 다운로드**로 가장 기본적이면서 필수적인 MCP 서버다. Claude Code 자체에 파일 접근 기능이 있지만, MCP 서버로 별도 구성하면 서브에이전트에 파일 접근 권한을 세밀하게 할당할 수 있다.

**제공 도구 (12개):** `read_text_file`(head/tail 지원), `read_media_file`, `read_multiple_files`, `write_file`, `edit_file`(패턴 기반 검색-교체), `create_directory`, `list_directory`, `list_directory_with_sizes`, `directory_tree`, `move_file`, `get_file_info`, `list_allowed_directories`

**Claude Code 설정:**
```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /Users/me/projects /Users/me/Documents
```

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y", "@modelcontextprotocol/server-filesystem",
        "/Users/me/projects",
        "/Users/me/Documents"
      ]
    }
  }
}
```

**보안 주의:** `~/.ssh`, `~/.aws` 등 민감 디렉토리는 절대 허용하지 마라. Docker의 `ro` 마운트 플래그로 읽기 전용 접근을 구성할 수 있다. 반드시 **절대 경로**를 사용해야 하며, 상대 경로는 동작하지 않는다.

---

## 6위: Sequential Thinking — 구조화된 단계별 추론

Smithery에서 **사용량 1위(5,550+)**를 기록한 추론 프레임워크다. 복잡한 문제를 단계별로 분해하고, 사고를 수정하거나 대안적 추론 경로로 분기할 수 있는 **동적 사고 체인**을 제공한다. 아키텍처 설계, 디버깅, 마이그레이션 계획에서 "시니어 아키텍트처럼 먼저 생각하게 만든다"는 평가를 받는다.

**제공 도구 (1개):** `sequentialthinking` — 현재 사고 단계(`thought`), 다음 단계 필요 여부(`nextThoughtNeeded`), 수정 여부(`isRevision`), 분기(`branchFromThought`, `branchId`) 등의 파라미터를 받는다. **실행 도구가 아닌 사고 프레임워크**다.

**Claude Code 설정:**
```bash
claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

**API 키:** 없음. 환경변수 불필요. 단순한 작업에는 오히려 오버헤드만 추가하므로, **복잡한 다단계 의사결정에만 사용**해야 한다. GitHub MCP, Sentry MCP 등 실행 도구와 조합하면 "계획 → 실행" 워크플로가 완성된다.

---

## 7위: Brave Search MCP — 실시간 웹 검색

Claude Code에 **실시간 웹 검색 능력**을 부여한다. Brave 공식 v2.x(`@brave/brave-search-mcp-server`)는 6개 도구(웹, 로컬, 이미지, 비디오, 뉴스, AI 요약)를 제공하며, Anthropic 레퍼런스 버전은 2개 도구(웹, 로컬)로 더 가볍다.

**Claude Code 설정:**
```bash
# Brave 공식 (6개 도구, 권장)
claude mcp add --scope user brave-search -e BRAVE_API_KEY=BSA_xxxx \
  -- npx -y @brave/brave-search-mcp-server
```

```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@brave/brave-search-mcp-server"],
      "env": {
        "BRAVE_API_KEY": "BSA_xxxx"
      }
    }
  }
}
```

**API 키:** 필수. https://brave.com/search/api/ 에서 발급. **무료 티어: 월 2,000 쿼리, 1req/sec**. Pro 플랜은 1,000쿼리당 ~$3. `BRAVE_MCP_DISABLED_TOOLS`로 이미지/비디오 검색을 비활성화하면 도구 정의 오버헤드를 줄일 수 있다. v2.x에서 base64 이미지 인코딩이 제거되어 컨텍스트 소비가 크게 감소했다.

---

## 8위: Figma Context MCP — 디자인에서 코드로

Figma 공식 MCP 서버는 디자인 파일의 레이아웃, 컴포넌트, 토큰, 변수를 **구조화된 코드 표현(기본: React + Tailwind)**으로 변환한다. **13k 스타**로 단일 용도 MCP 서버 중 최고 인기를 자랑하며, 프론트엔드 개발자의 디자인-투-코드 워크플로를 혁신한다.

**제공 도구:** `get_design_context`(핵심, 프레임→코드 변환), `get_variables`(디자인 토큰), `get_code_connect_map`, `get_metadata`, `get_screenshot`, `create_design_system_rules`, `get_figjam`, `generate_diagram`

**Claude Code 설정:**
```bash
# Remote (OAuth, 권장)
claude mcp add --transport http figma https://mcp.figma.com/mcp
```

```json
{
  "mcpServers": {
    "figma": {
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

**API 키:** OAuth로 자동 인증(별도 키 불필요). Figma Dev Mode 활성화 필요. **Rate limit:** Starter/View 좌석은 월 6회 도구 호출, Dev/Full 유료 좌석은 분당 Tier 1 제한. 복잡한 프레임을 선택하면 출력이 매우 커지므로 **개별 프레임 단위**로 변환해야 한다.

---

## 9위: Desktop Commander — 터미널과 파일의 스위스 아미 나이프

**5.4k 스타**. 터미널 제어, 파일시스템 접근, diff 기반 코드 편집을 하나의 서버로 통합한다. 원래 Claude Desktop용으로 설계되었으나, 서브에이전트에 시스템 제어를 위임할 때 유용하다.

**제공 도구:** 터미널(`execute_command`, `read_output`, `list_processes`, `kill_process`), 파일(`read_file`, `write_file`, `search_files`, `search_code`), 편집(`edit_block` — diff 형식 검색-교체), 설정(`get_config`, `set_config_value`)

**Claude Code 설정:**
```bash
claude mcp add-json "desktop-commander" '{"command":"npx","args":["-y","@wonderwhy-er/desktop-commander"]}'
```

**API 키:** 없음. 주의: Claude Code 자체에 터미널/파일 접근이 이미 있으므로 **다소 중복**될 수 있다. 주 가치는 Claude Desktop 사용자나, 특정 서브에이전트에 시스템 레벨 접근을 격리하여 할당할 때 발휘된다. Docker 설치로 완전 샌드박싱이 가능하나, 터미널 명령은 `allowedDirectories` 제한을 우회할 수 있으므로 주의가 필요하다.

---

## 10위: Memory MCP — 세션 간 영속 메모리

공식 레퍼런스 서버로, **로컬 지식 그래프(Knowledge Graph)**를 사용해 세션 간 정보를 영속 저장한다. 엔티티(Entity), 관계(Relation), 관찰(Observation) 세 가지 원시 타입으로 구성되며, JSONL 파일에 저장된다. Smithery **263+** 사용.

**제공 도구 (9개):** `create_entities`, `create_relations`, `add_observations`, `delete_entities`, `delete_observations`, `delete_relations`, `read_graph`, `search_nodes`, `open_nodes`

**Claude Code 설정:**
```bash
claude mcp add memory -- npx -y @modelcontextprotocol/server-memory
```

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE_PATH": "/Users/me/.memory/memory.jsonl"
      }
    }
  }
}
```

**핵심 주의:** `MEMORY_FILE_PATH`를 반드시 설정하라. 기본값은 npx 캐시 디렉토리에 저장되어 언제든 삭제될 수 있다. `read_graph`는 **전체 그래프를 컨텍스트에 로드**하므로 대형 그래프에서 토큰 폭탄이 된다. 대신 `search_nodes`나 `open_nodes`로 타겟 검색을 해야 한다. CLAUDE.md에 "세션 시작 시 메모리를 검색하고, 새로운 정보는 즉시 저장하라"는 지침을 추가하면 자동화 효과가 극대화된다.

---

## MCP 컨텍스트 관리 종합 Best Practices

MCP 서버의 최대 과제는 **컨텍스트 소비**다. 7개 이상 서버를 설정하면 작업 전에 이미 컨텍스트의 50~70%가 도구 정의로 소진될 수 있다. 이를 해결하는 핵심 전략은 다음과 같다.

**MCP Tool Search (v2.1.7+)는 게임 체인저다.** MCP 도구 정의가 컨텍스트의 10%를 초과하면 자동 활성화되며, 기존 ~77k 토큰 소비를 **~8.7k 토큰으로 85% 절감**한다. Opus 4 정확도는 49% → 74%, Opus 4.5는 79.5% → 88.1%로 향상되었다. 설정은 환경변수로 제어한다:

```bash
ENABLE_TOOL_SEARCH=auto claude        # 기본값: 10% 임계치에서 자동 활성화
ENABLE_TOOL_SEARCH=auto:5 claude      # 5% 임계치로 조정
ENABLE_TOOL_SEARCH=true claude        # 강제 활성화
```

**토큰 예산 관리 체크리스트:**
- `/context` 명령으로 서버별 토큰 소비량 수시 모니터링
- GitHub MCP는 반드시 `GITHUB_TOOLSETS`로 필요 toolset만 활성화
- TaskMaster는 `TASK_MASTER_TOOLS="core"`로 70% 절감
- Brave Search는 `BRAVE_MCP_DISABLED_TOOLS`로 불필요 도구 비활성화
- `MAX_MCP_OUTPUT_TOKENS=50000`으로 대형 출력 허용 (기본 25,000)
- `/mcp` 명령으로 세션 중 미사용 서버 토글 off

**서브에이전트 활용 패턴이 핵심이다.** MCP 도구를 메인 에이전트에서 직접 사용하면 컨텍스트가 오염된다. 대신 서브에이전트에 필요한 MCP 도구만 `tools` 필드로 화이트리스팅하라:

```yaml
# .claude/agents/db-analyst.md
---
name: db-analyst
tools: mcp__postgres__query, mcp__postgres__schema, Read, Bash
model: sonnet
---
```

`tools` 필드를 생략하면 **모든 MCP 도구를 상속**하므로, 반드시 의도적으로 화이트리스팅해야 한다.

---

## 설정 방법 종합 가이드

Claude Code의 MCP 설정 체계는 **네 가지 스코프**로 계층화된다.

| 스코프 | 저장 위치 | 가시 범위 | 용도 |
|-------|----------|----------|------|
| **local** (기본) | `~/.claude.json` (프로젝트 경로 하위) | 나만, 이 프로젝트만 | 개인 개발 서버, 실험적 설정 |
| **project** | `.mcp.json` (프로젝트 루트) | 팀 전체 (VCS 공유) | 팀 표준 도구 |
| **user** | `~/.claude.json` (글로벌 mcpServers) | 나만, 모든 프로젝트 | 범용 유틸리티 (검색, GitHub 등) |
| **managed** | `managed-mcp.json` (시스템 디렉토리) | 전체 사용자 | 엔터프라이즈 배포 |

**우선순위:** managed > local > project > user. 동일 이름 서버는 높은 우선순위가 승리한다.

**⚠️ 중요:** MCP 서버는 `~/.claude/settings.json`이 아니라 **`~/.claude.json`** 또는 **`.mcp.json`**에 설정한다. 이는 자주 혼동되는 부분이다(GitHub Issue #4976).

**프로젝트 `.mcp.json`에서 환경변수 확장:**
```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${GITHUB_PAT}"
      }
    }
  }
}
```

`${VAR:-default}` 구문으로 기본값 지정이 가능하다. 시크릿이 포함된 `.mcp.json`은 `.gitignore`에 추가해야 한다.

**권한 관리 (.claude/settings.json):**
```json
{
  "permissions": {
    "allow": [
      "mcp__github__create_issue",
      "mcp__github__list_issues",
      "mcp__context7__resolve_library_id",
      "mcp__context7__get_library_docs"
    ],
    "deny": [
      "mcp__github__delete_repository"
    ]
  }
}
```

MCP 도구명 패턴은 `mcp__<서버명>__<도구명>`이며, **와일드카드는 지원하지 않는다.**

---

## 역할별 추천 조합

개발자 역할에 따른 최적의 MCP 서버 조합은 실질적으로 큰 차이를 만든다.

**프론트엔드 개발자:**
Context7(프레임워크 최신 문서) + Playwright(브라우저 테스트) + Figma(디자인→코드) — 3개 서버로 디자인에서 테스트까지 완결

**백엔드 개발자:**
GitHub(PR/이슈 관리) + Brave Search(문제 해결 검색) + Supabase 또는 PostgreSQL MCP(DB 접근) + Sentry(에러 모니터링) — 디버그 루프 완성

**풀스택 개발자:**
GitHub + Context7 + Brave Search + Playwright + DB 서버 — MCP Tool Search 필수 활성화

**프로젝트 리드/PM:**
TaskMaster(태스크 분해/추적) + Linear(이슈 관리) + Sequential Thinking(아키텍처 설계) + GitHub — 계획에서 실행까지

**DevOps/인프라:**
AWS MCP(Core 필수) + Docker MCP + GitHub — AWS Core MCP를 먼저 설치하면 다른 AWS 서버를 오케스트레이션한다

---

## 주목할 차점 후보 서버들

Top 10에는 들지 못했지만 실무에서 자주 언급되는 서버들이다.

**Sentry MCP** (`https://mcp.sentry.dev/mcp`): OAuth 기반 원격 서버로 제로 설치. 16+ 도구로 에러 모니터링, Seer AI 디버깅, 릴리즈 관리를 지원한다. `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp`로 즉시 설정.

**Linear MCP** (`https://mcp.linear.app/mcp`): OAuth 기반 원격 서버. 이슈 생성/검색/업데이트, 프로젝트 관리를 자연어로 처리. `claude mcp add --transport http linear https://mcp.linear.app/mcp`

**Notion MCP** (`https://mcp.notion.com/mcp`): OAuth 기반. 페이지 CRUD, DB 쿼리, AI 검색. 호스팅 버전이 셀프호스팅보다 토큰 효율적.

**Supabase MCP** (`https://mcp.supabase.com/mcp`): OAuth 2.1 지원. SQL 실행, 마이그레이션, TypeScript 타입 생성, 문서 검색. 반드시 `--read-only` 모드로 시작할 것.

**AWS MCP** (awslabs): 45+ 전문 서버. Core MCP를 먼저 설치해야 다른 서버가 동작한다. **필요한 서버만 선택적으로 설치**해야 컨텍스트 폭발을 방지한다.

**Exa MCP** (`https://mcp.exa.ai/mcp`): 무료 원격 MCP. 시맨틱 웹 검색, 코드 검색, 기업/인물 리서치, 학술 논문 검색까지 지원하며 Brave Search와 상호 보완적이다.

---

## 결론: 실질적 인사이트

MCP 생태계의 핵심 변곡점은 **MCP Tool Search의 등장**이다. 이전에는 2~3개 서버가 한계였지만, 이제 수십 개를 연결해도 토큰 오버헤드가 미미하다. 이 변화는 "어떤 MCP를 제거할까"에서 "어떤 MCP를 추가하면 좋을까"로 패러다임을 전환시켰다.

가장 영향력 있는 조합은 **Context7 + GitHub MCP + 역할별 특화 서버 1~2개**다. Context7은 모든 개발자에게 즉각적인 코드 품질 향상을 제공하고, GitHub MCP는 워크플로 통합의 핵심이다. 여기에 프론트엔드라면 Figma, 백엔드라면 DB/Sentry를 추가하면 된다.

Remote HTTP 전송(OAuth)을 지원하는 서버(Sentry, Linear, Notion, Figma, Supabase)는 **설치가 필요 없고 인증도 브라우저에서 자동 처리**되므로, 도입 장벽이 가장 낮다. 반면 Docker 기반 서버(GitHub MCP)는 보안 격리가 우수하지만 Docker 런타임이 필요하다. npx 기반 서버(Context7, Filesystem, Memory, Sequential Thinking)는 가장 보편적이지만 Node.js 18+ 환경이 전제된다.

서브에이전트에 MCP 도구를 명시적으로 할당하고, `ENABLE_TOOL_SEARCH=auto`를 유지하며, `/context`로 주기적으로 모니터링하는 것이 2026년 현재 가장 효과적인 MCP 운영 전략이다.