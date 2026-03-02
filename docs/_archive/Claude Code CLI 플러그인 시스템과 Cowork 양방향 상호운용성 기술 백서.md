# Claude Code CLI 플러그인 시스템과 Cowork 양방향 상호운용성 기술 백서

Claude Code의 플러그인 시스템은 2025년 10월 9일 출시 이후 **9,000개 이상의 플러그인**과 **43개 이상의 커뮤니티 마켓플레이스**로 급성장했다. 이 시스템은 CLI 개발자와 Cowork 비즈니스 사용자 간의 양방향 브릿지 역할을 하며, 동일한 플러그인 포맷이 터미널 자동화부터 데스크톱 지식 워크플로까지 전 스펙트럼을 포괄한다. 본 백서는 2026년 2월 기준 최신 플러그인 아키텍처, CLI 명령어 레퍼런스, Cowork 연동 패턴, CI/CD 통합, 커뮤니티 생태계, 그리고 엔터프라이즈 보안 거버넌스를 포괄적으로 다룬다. 핵심적으로, 플러그인은 Markdown과 JSON 기반의 선언적 패키지로서 슬래시 커맨드, 스킬, 에이전트, 훅, MCP 서버, LSP 서버를 하나의 배포 단위로 묶는 메커니즘이다.

---

## 1. CLI 플러그인 명령어 완전 레퍼런스 (2026년 최신)

Claude Code CLI는 플러그인 수명주기 전체를 관리하는 명령어 세트를 제공한다. 모든 명령어는 인터랙티브 모드에서 `/plugin` 프리픽스로도 사용할 수 있으며, 터미널에서는 `claude plugin` 서브커맨드로 실행된다.

### 1.1 플러그인 관리 명령어

플러그인 설치는 `marketplace-name` 기반 네임스페이싱을 따른다. **`--scope` 플래그**는 플러그인이 저장되는 설정 파일 위치를 결정하며, 이는 팀 협업 패턴에 직접적 영향을 미친다.

```bash
# 플러그인 설치 (기본: user 스코프)
claude plugin install formatter@my-marketplace

# 프로젝트 스코프로 설치 (팀과 VCS로 공유)
claude plugin install formatter@my-marketplace --scope project

# 로컬 스코프로 설치 (gitignore 대상, 머신별 설정)
claude plugin install formatter@my-marketplace --scope local

# 플러그인 제거
claude plugin uninstall formatter

# 설치된 플러그인 목록 조회
claude plugin list

# 플러그인 활성화/비활성화
claude plugin enable formatter
claude plugin disable formatter

# 플러그인 검증 (현재 디렉토리의 플러그인/마켓플레이스 JSON 검증)
claude plugin validate .
```

각 스코프의 설정 파일 위치는 다음과 같다:

| 스코프 | 설정 파일 경로 | 용도 | VCS 커밋 여부 |
|--------|---------------|------|-------------|
| **user** (기본) | `~/.claude/settings.json` | 개인 플러그인 환경설정 | N/A |
| **project** | `.claude/settings.json` | 프로젝트별 설정, 팀 공유 | ✅ 커밋 |
| **local** | `.claude/settings.local.json` | 머신별 오버라이드 | ❌ gitignore |

설정 파일 내 플러그인 활성화 상태는 `enabledPlugins` 객체로 관리된다:

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": true,
    "analyzer@security-plugins": false
  }
}
```

### 1.2 마켓플레이스 CLI 명령어

마켓플레이스는 플러그인 카탈로그를 호스팅하는 Git 저장소 또는 JSON 파일이다. **5가지 소스 타입**을 지원한다:

```bash
# GitHub 저장소 기반 마켓플레이스 추가
claude plugin marketplace add owner/repo

# Git URL 기반 마켓플레이스 추가 (GitLab, Bitbucket 등)
claude plugin marketplace add https://gitlab.com/company/plugins.git

# 로컬 디렉토리 마켓플레이스 추가
claude plugin marketplace add ./my-marketplace

# 직접 JSON 파일 경로 추가
claude plugin marketplace add ./path/to/marketplace.json

# 원격 JSON URL 추가
claude plugin marketplace add https://url.of/marketplace.json

# 마켓플레이스 목록 조회
claude plugin marketplace list

# 마켓플레이스 메타데이터 새로고침
claude plugin marketplace update marketplace-name

# 마켓플레이스 제거
claude plugin marketplace remove marketplace-name
```

### 1.3 로컬 개발용 `--plugin-dir` 플래그

플러그인 개발 시 설치 과정 없이 세션 동안 로컬 디렉토리를 직접 로드할 수 있다. 이 플래그는 **반복적 개발-테스트 사이클**의 핵심이다:

```bash
# 단일 플러그인 로드
claude --plugin-dir ./my-first-plugin

# 복수 플러그인 동시 로드
claude --plugin-dir ./plugin-a --plugin-dir ./plugin-b

# 디버그 모드로 플러그인 로딩 상세 확인
claude --debug
```

`--debug` 플래그는 어떤 플러그인이 로드되는지, 매니페스트 오류, 커맨드/에이전트/훅 등록, MCP 서버 초기화 과정을 상세 출력한다.

### 1.4 플러그인 캐시 위치와 구조

CLI로 설치된 플러그인은 `~/.claude/plugins/` 디렉토리에 캐시된다. 설치 시 플러그인은 원본 위치에서 **복사**되어 캐시 디렉토리에 저장되며, 이는 보안 및 검증 목적이다.

```bash
# 플러그인 캐시 초기화 (문제 해결 시)
rm -rf ~/.claude/plugins/cache

# 설치된 플러그인 상태 확인 (jq로 파싱 가능)
jq -r '.plugins | keys[] | split("@") | "\(.[0]) (from \(.[1]))"' \
  ~/.claude/plugins/installed_plugins.json
```

**캐시 동작 규칙**: 플러그인은 복사된 디렉토리 구조 외부 파일을 참조할 수 없다. `../shared-utils` 같은 상대 경로는 작동하지 않는다. 우회 방법은 심볼릭 링크(복사 시 따라감)를 사용하거나 마켓플레이스 구조를 재설계하는 것이다.

### 1.5 런타임 플러그인 발견 및 로딩

플러그인은 세 가지 경로로 로드된다: (1) `--plugin-dir` 플래그로 세션 동안 직접 로드, (2) 마켓플레이스를 통한 캐시 설치, (3) `enabledPlugins` 설정 파일 기반 자동 로드. 공식 마켓플레이스(`claude-plugins-official`)는 **시작 시 자동 가용**하며 별도 추가 없이 플러그인을 설치할 수 있다. 매니페스트가 없어도 Claude Code는 기본 디렉토리(`commands/`, `agents/`, `skills/`, `hooks/`)에서 컴포넌트를 **자동 발견**한다.

### 1.6 GitHub Action의 `plugins` 파라미터

`anthropics/claude-code-action@v1`은 두 가지 플러그인 파라미터를 지원한다:

```yaml
- uses: anthropics/claude-code-action@v1
  with:
    anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
    
    # 마켓플레이스 Git URL (줄바꿈 구분)
    plugin_marketplaces: |
      https://github.com/user/marketplace1.git
      https://github.com/user/marketplace2.git
    
    # 설치할 플러그인 (줄바꿈 구분, name@marketplace 형식)
    plugins: |
      code-review@claude-code-plugins
      feature-dev@claude-code-plugins
```

**알려진 제약**: `plugin_marketplaces`는 원격 Git URL만 지원하며, 로컬 경로(`./my-marketplace`)는 "Invalid marketplace URL format" 오류 발생 (Issue #664). SDK를 통한 프로그래밍 방식 로딩도 지원된다:

```typescript
// TypeScript Agent SDK
import { query } from "@anthropic-ai/claude-agent-sdk";
for await (const message of query({
  prompt: "커스텀 커맨드 목록을 보여주세요",
  options: {
    plugins: [
      { type: "local", path: "./my-plugin" },
      { type: "local", path: "/absolute/path/to/plugin" }
    ],
    maxTurns: 3
  }
})) {
  if (message.type === "system" && message.subtype === "init") {
    console.log("로드된 플러그인:", message.plugins);
  }
}
```

---

## 2. Cowork 플러그인 구조와 Claude Code 네이티브 구조 비교

### 2.1 디렉토리 구조 매핑

Claude Code의 프로젝트별 설정(`.claude/`)과 플러그인 포맷(`.claude-plugin/`)은 동일한 컴포넌트를 공유하되, 패키징 방식이 다르다. 이 차이를 이해하는 것이 CLI-Cowork 간 양방향 마이그레이션의 핵심이다.

**독립 실행형 `.claude/` 디렉토리 구조** (프로젝트 레벨):
```
project-root/
├── .claude/
│   ├── settings.json          # 프로젝트 설정
│   ├── settings.local.json    # 로컬 오버라이드 (gitignore)
│   ├── CLAUDE.md              # 프로젝트 컨텍스트/메모리
│   ├── commands/              # 프로젝트 슬래시 커맨드
│   │   └── deploy.md          # → /project:deploy 생성
│   ├── agents/                # 프로젝트 에이전트
│   │   └── reviewer.md
│   └── plugins/               # 팀 자동 로드 플러그인
│       └── team-workflows/
│           └── .claude-plugin/plugin.json
```

**플러그인 포맷** (배포 가능 패키지):
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json            # 매니페스트 (이 디렉토리의 유일한 파일)
├── commands/                  # 슬래시 커맨드
├── agents/                    # 서브에이전트
├── skills/                    # 에이전트 스킬
│   └── code-reviewer/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── .mcp.json                  # MCP 서버 정의
├── .lsp.json                  # LSP 서버 설정
└── scripts/
```

**핵심 규칙**: `.claude-plugin/` 디렉토리에는 **오직 `plugin.json`만** 포함되어야 한다. 모든 컴포넌트 디렉토리는 **플러그인 루트 레벨**에 위치해야 한다. 이것이 가장 흔한 구조 오류다.

| 접근 방식 | 슬래시 커맨드 이름 | 최적 용도 |
|----------|-----------------|----------|
| **독립 실행형** (`.claude/`) | `/hello` 또는 `/project:hello` | 개인 워크플로, 프로젝트별 커스터마이징 |
| **플러그인** (`.claude-plugin/`) | `/plugin-name:hello` | 팀 공유, 커뮤니티 배포, 버전 관리 릴리스 |

### 2.2 plugin.json 매니페스트 상세

매니페스트 자체는 **선택적**이다. 생략하면 Claude Code가 기본 위치에서 컴포넌트를 자동 발견하고 디렉토리 이름에서 플러그인 이름을 파생한다.

```json
{
  "name": "enterprise-devtools",
  "version": "2.1.0",
  "description": "기업용 개발 도구 통합 플러그인",
  "author": {
    "name": "DevOps Team",
    "email": "devops@company.com",
    "url": "https://github.com/company"
  },
  "homepage": "https://docs.company.com/plugin",
  "repository": "https://github.com/company/enterprise-devtools",
  "license": "MIT",
  "keywords": ["enterprise", "devtools", "ci-cd"],
  "commands": ["./custom/commands/special.md"],
  "agents": "./custom/agents/",
  "skills": "./custom/skills/",
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json",
  "outputStyles": "./styles/",
  "lspServers": "./.lsp.json"
}
```

**필수 필드는 `name` 하나**뿐이다 (kebab-case, 공백 없음). 경로 동작 규칙상 커스텀 경로는 기본 디렉토리를 **대체하지 않고 보완**한다. `commands/`가 존재하면 커스텀 커맨드 경로와 **함께** 로드된다. 모든 경로는 `./`로 시작하는 상대 경로여야 한다.

### 2.3 Skills: SKILL.md와 YAML 프론트매터

스킬은 Claude가 **자율적으로 판단하여 적용**하는 컨텍스트 인식 지식 모듈이다:

```yaml
---
name: code-review
description: 코드 품질, 보안, 유지보수성을 검토합니다.
version: 1.0.0
disable-model-invocation: true
allowed-tools: Read, Grep
context: fork
agent: Explore
---

코드 리뷰 시 다음 항목을 확인하세요:
1. 코드 구조와 조직
2. 에러 처리
3. 보안 취약점
$ARGUMENTS를 통해 사용자 입력을 캡처합니다.
```

| 프론트매터 필드 | 설명 |
|---------------|------|
| `name` | 스킬 이름 (기본값: 폴더 이름) |
| `description` | 사용 시점 설명 (Claude 자동 호출 매칭에 핵심) |
| `disable-model-invocation: true` | 사용자만 트리거 가능 |
| `allowed-tools` | 사용 가능 도구 제한 |
| `context: fork` | 격리된 서브에이전트 컨텍스트에서 실행 |
| `agent` | 에이전트 타입 (`Explore`, `Plan`, `general-purpose`, 커스텀) |

**프로그레시브 디스클로저**: 세션 시작 시 **프론트매터(name, description)만** 로드된다. 전체 SKILL.md 내용은 Claude가 관련성을 판단할 때만 로드된다. 참조 파일은 필요 시에만, 스크립트는 외부 실행되어 출력만 반환된다. 2025년 말 도입된 **Tool Search**는 MCP 도구 설명이 컨텍스트의 10% 초과 시 온디맨드 로딩으로 전환하여 **~134,000 토큰에서 ~5,000 토큰으로** 사용량을 감소시켰다.

### 2.4 Hooks, MCP 커넥터, context: fork

**hooks.json**은 10가지 이벤트(`PreToolUse`, `PostToolUse`, `PermissionRequest`, `UserPromptSubmit`, `Notification`, `Stop`, `SubagentStop`, `SessionStart`, `SessionEnd`, `PreCompact`)를 지원한다. 훅 타입은 `command`(쉘 실행), `prompt`(LLM 프롬프트 주입), `agent`(에이전트 위임)이며, 매처 패턴으로 정확 매칭, 다중 도구(`"Read|Write|Edit"`), 와일드카드(`"*"`), 정규식을 지원한다. 종료 코드 0은 허용, 2는 차단이다.

**.mcp.json**의 MCP 서버는 플러그인 활성화 시 **자동 시작**되며 `${CLAUDE_PLUGIN_ROOT}` 환경변수로 이식 가능한 경로를 보장한다.

**`context: fork`**는 스킬을 격리된 서브에이전트 컨텍스트에서 실행한다. 스킬 내용이 서브에이전트 프롬프트가 되며, 메인 대화 이력에 접근 불가하고, 결과 요약만 메인 대화에 반환된다. `agent` 필드로 `Explore`, `Plan`, `general-purpose` 또는 커스텀 에이전트를 지정할 수 있다.

---

## 3. CLI ↔ Cowork 양방향 협업 패턴

### 3.1 CLI에서 Cowork으로: 개발자가 비개발자용 플러그인 패키징

CLI 개발자가 `.claude/` 디렉토리에서 반복 개발한 워크플로를 Cowork 사용자를 위한 플러그인으로 변환하는 과정은 다음과 같다:

```bash
# 1단계: .claude/ 에서 빠르게 프로토타이핑
mkdir -p .claude/commands .claude/skills/review
# 커맨드와 스킬 작성 후 즉시 테스트

# 2단계: 플러그인 구조로 변환
mkdir -p my-plugin/.claude-plugin
cat > my-plugin/.claude-plugin/plugin.json << 'EOF'
{
  "name": "team-review-tools",
  "version": "1.0.0",
  "description": "팀 코드 리뷰 자동화 도구"
}
EOF

# 3단계: 컴포넌트 복사 (루트 레벨에 배치!)
cp -r .claude/commands my-plugin/commands
cp -r .claude/skills my-plugin/skills

# 4단계: 로컬 테스트
claude --plugin-dir ./my-plugin

# 5단계: 마켓플레이스에 등록
# marketplace.json에 플러그인 엔트리 추가 후 Git push
```

이 워크플로의 핵심은 **"독립 실행형에서 시작하고, 플러그인으로 변환"**이라는 점진적 접근이다. `.claude/` 디렉토리에서 빠르게 실험하고, 검증된 워크플로만 플러그인으로 패키징하여 공유한다.

### 3.2 Git 기반 플러그인 공유 워크플로

팀 간 플러그인 공유는 `.claude/settings.json`의 `extraKnownMarketplaces`를 통해 자동화된다:

```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {
        "source": "github",
        "repo": "your-org/claude-plugins"
      }
    }
  }
}
```

이 설정이 프로젝트 저장소에 커밋되면, 팀원이 저장소를 신뢰(trust)할 때 Claude Code가 자동으로 마켓플레이스 설치를 제안하고 플러그인 설치를 프롬프트한다. CLI 사용자와 Cowork 사용자 모두 동일한 플러그인을 사용할 수 있다.

### 3.3 프라이빗 마켓플레이스 설정

**GitHub 저장소 기반 프라이빗 마켓플레이스**:

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "company-internal-tools",
  "owner": {
    "name": "Platform Team",
    "email": "platform@company.com"
  },
  "metadata": {
    "description": "사내 Claude Code 플러그인 카탈로그",
    "version": "1.0.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "compliance-checker",
      "source": "./plugins/compliance-checker",
      "description": "사내 코딩 표준 준수 검사",
      "version": "2.1.0",
      "category": "security",
      "strict": true
    },
    {
      "name": "deploy-tools",
      "source": {
        "source": "github",
        "repo": "company/deploy-plugin",
        "ref": "v2.0",
        "path": "plugin"
      },
      "description": "배포 자동화 도구"
    }
  ]
}
```

`source` 필드는 5가지 타입을 지원한다: 상대 경로, GitHub 저장소(`{source: "github", repo: "owner/repo"}`), Git URL(`{source: "url", url: "https://..."}`), ref/path 포함 GitHub, ref/path 포함 Git.

**LiteLLM 프록시 기반 엔터프라이즈 마켓플레이스**는 중앙 집중식 플러그인 레지스트리를 제공한다:

```bash
# 관리자: LiteLLM API로 플러그인 등록
curl -X POST http://localhost:4000/claude-code/plugins \
  -H "Authorization: Bearer $LITELLM_MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "internal-tools",
    "source": {"source": "github", "repo": "mycompany/internal-tools"},
    "version": "1.0.0",
    "description": "사내 개발 도구",
    "author": {"name": "Platform Team"},
    "category": "internal"
  }'

# 엔지니어: 회사 마켓플레이스 추가
claude plugin marketplace add http://litellm.internal:4000/claude-code/marketplace.json

# 플러그인 검색 및 설치
claude plugin install internal-tools@litellm
```

LiteLLM Admin UI에서 플러그인별 활성화/비활성화 토글, 카테고리 분류, 키워드 태깅을 관리할 수 있다. 엔지니어에게는 활성화된 플러그인만 표시된다.

### 3.4 플러그인 버전 관리 전략

플러그인은 **시맨틱 버전(MAJOR.MINOR.PATCH)**을 따른다. 공식 Anthropic 마켓플레이스는 자동 업데이트가 **기본 활성화**되고, 서드파티 마켓플레이스는 **기본 비활성화**된다. 관련 환경변수로 `DISABLE_AUTOUPDATER`(전체 업데이트 비활성화)와 `FORCE_AUTOUPDATE_PLUGINS=true`(CLI 업데이트 비활성화 시에도 플러그인 업데이트 유지)가 있다.

---

## 4. 헤드리스 모드와 CI/CD 플러그인 통합

### 4.1 `claude -p` 헤드리스 모드

`-p`(또는 `--print`) 플래그는 비대화형 모드로 Claude Code를 실행한다:

```bash
# 기본 헤드리스 실행
claude -p "이 코드를 리뷰해주세요" --output-format json

# JSON 출력 형식
claude -p "분석" --output-format json
# 결과: {"type":"result","subtype":"success","total_cost_usd":0.003,
#         "is_error":false,"duration_ms":1234,"num_turns":6,
#         "result":"응답 텍스트","session_id":"abc123"}

# 스트리밍 JSON 출력 (JSONL 형식)
claude -p "분석" --output-format stream-json

# 세션 이어가기
claude -p --resume "abc123" "후속 질문"

# 도구 제한
claude -p "리뷰" --allowedTools "Bash,Read,Grep" --permission-mode acceptAll

# MCP 서버 설정 로드
claude -p "분석" --mcp-config servers.json --max-turns 10
```

**중요 제약사항**: 헤드리스 모드에서의 플러그인 설치(`claude -p "/plugin install ..."`)는 **지원되지 않는다**. GitHub Issue #12840은 "not planned"으로 종료되었다. `/plugin` 등 사용자 호출 스킬은 인터랙티브 모드에서만 사용 가능하다.

### 4.2 GitHub Actions 통합

완전한 GitHub Actions 워크플로 예시:

```yaml
name: Claude PR Assistant
on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  pull_request_review:
    types: [submitted]

permissions:
  contents: write
  pull-requests: write
  issues: write
  actions: read

jobs:
  claude-response:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
        with:
          fetch-depth: 1

      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          
          # 마켓플레이스 추가 (줄바꿈 구분)
          plugin_marketplaces: |
            https://github.com/company/internal-plugins.git
          
          # 플러그인 설치 (줄바꿈 구분)
          plugins: |
            code-review@claude-code-plugins
            security-guidance@claude-code-plugins
          
          # CLI 인자
          claude_args: |
            --max-turns 10
            --model claude-4-0-sonnet-20250805
          
          prompt: "이 PR을 보안 관점에서 리뷰해주세요"
          
          # CI 접근 권한 (워크플로 로그 접근)
          additional_permissions: |
            actions: read
```

`actions: read` 활성화 시 Claude는 `mcp__github_ci__get_ci_status`, `mcp__github_ci__download_job_log` 등 CI MCP 도구에 접근할 수 있다. `structured_output`과 `session_id`가 출력으로 제공된다.

### 4.3 GitLab CI/CD 통합 (베타)

GitLab 통합은 **베타**이며 GitLab이 유지보수한다:

```yaml
stages:
  - ai

claude:
  stage: ai
  image: node:24-alpine3.21
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
  variables:
    GIT_STRATEGY: fetch
  before_script:
    - apk update && apk add --no-cache git curl bash
    - npm install -g @anthropic-ai/claude-code
  script:
    - /bin/gitlab-mcp-server || true
    - >
      claude
      -p "${AI_FLOW_INPUT:-'이 MR을 리뷰하고 변경사항을 구현하세요'}"
      --permission-mode acceptEdits
      --allowedTools "Bash(*) Read(*) Edit(*) Write(*) mcp__gitlab"
      --debug
```

GitLab은 GitHub Action의 `plugins` 파라미터에 해당하는 기능이 없으므로, MCP 서버를 `--mcp-config`로 직접 설정하거나, 플러그인을 사전 구성해야 한다.

### 4.4 자동화 스크립팅 패턴: Justfile

플러그인 관리를 위한 실전 Justfile 패턴:

```justfile
# 마켓플레이스 설치 (이미 설치 시 자동 업데이트)
[group("plugins"), script("bash")]
mpi url:
    output=$(command claude plugin marketplace add "{{ url }}" 2>&1)
    if echo "$output" | grep -qi "already installed"; then
        name=$(echo "$output" | sed -n "s/.*Marketplace '\([^']*\)'.*/\1/p")
        echo "이미 설치됨, 업데이트: $name"
        just mpup "$name"
    else
        echo "$output"
    fi

# 마켓플레이스 제거 (소속 플러그인 먼저 정리)
[group("plugins"), script("bash")]
mpr name:
    plugins=$(jq -r '.plugins | keys[] | select(endswith("@{{ name }}")) | split("@")[0]' \
      ~/.claude/plugins/installed_plugins.json 2>/dev/null)
    for plugin in $plugins; do
        echo "플러그인 제거: $plugin"
        command claude plugin uninstall "$plugin" 2>&1 || true
    done
    command claude plugin marketplace remove "{{ name }}"

# 마켓플레이스 업데이트
[group("plugins")]
@mpup name:
    command claude plugin marketplace update "{{ name }}"

# 설치된 플러그인 목록
[group("plugins")]
@pl:
    jq -r '.plugins | keys[] | split("@") | "\(.[0]) (from \(.[1]))"' \
      ~/.claude/plugins/installed_plugins.json
```

핵심 설계 패턴: **멱등적 `mpi`**(이미 설치 시 업데이트로 자동 전환), **클린 `mpr`**(마켓플레이스 소속 플러그인 먼저 제거 후 마켓플레이스 제거로 고아 방지), `jq`를 사용한 `installed_plugins.json` 파싱.

---

## 5. 커뮤니티 플러그인 생태계 (2026년 현황)

### 5.1 Anthropic 공식 마켓플레이스

**claude-plugins-official** (자동 가용): Anthropic이 관리하는 공식 디렉토리로 `/plugins`(내부 플러그인)와 `/external_plugins`(서드파티) 두 섹션으로 구성된다. LSP 플러그인(TypeScript, Python, Rust, Go, Java, C/C++ 등), MCP 통합(GitHub, Playwright, Supabase, Jira/Confluence, Linear, Notion, GitLab, Sentry, Slack, Context7), 생산성 도구가 포함된다. **"Anthropic Verified" 배지**가 추가 품질/보안 리뷰를 거친 플러그인을 표시한다.

**claude-code-plugins** (anthropics/claude-code 번들 — 수동 추가 필요): 13개 데모 플러그인:

| 플러그인 | 목적 |
|---------|------|
| **code-review** | 5개 병렬 Sonnet 에이전트, 신뢰도 기반 스코어링 |
| **feature-dev** | 코드베이스 탐색 → 아키텍처 설계 → 품질 리뷰 워크플로 |
| **plugin-dev** | 8단계 플러그인 생성 워크플로, 7개 전문 스킬 |
| **pr-review-toolkit** | 6개 전문 에이전트 (코멘트, 테스트, 사일런트 실패, 타입 설계 등) |
| **security-guidance** | PreToolUse 훅 기반 9가지 보안 패턴 모니터링 |
| **frontend-design** | 프로덕션급 UI 생성, "AI 슬롭" 회피 |
| **hookify** | 대화 패턴에서 커스텀 훅 자동 생성 |
| **ralph-wiggum** | 자율 반복 개발 루프 |

### 5.2 Anthropic knowledge-work-plugins (Cowork 11개 플러그인)

`anthropics/knowledge-work-plugins` 저장소의 11개 공식 Cowork 플러그인:

| 플러그인 | 목적 | 주요 커넥터 |
|---------|------|-----------|
| **productivity** | 태스크, 캘린더, 일일 워크플로 | Slack, Notion, Asana, Linear, Jira, Monday |
| **sales** | 프로스펙트 리서치, 콜 준비, 파이프라인 리뷰 | HubSpot, Close, Clay, ZoomInfo |
| **customer-support** | 티켓 분류, 응답 초안, 에스컬레이션 | Intercom, HubSpot, Guru |
| **product-management** | 스펙, 로드맵, 사용자 리서치 | Linear, Figma, Amplitude, Pendo |
| **marketing** | 콘텐츠 초안, 캠페인 기획, 브랜드 보이스 | Canva, Figma, HubSpot, Ahrefs |
| **legal** | 계약 리뷰, NDA 분류, 컴플라이언스 | Box, Egnyte, Jira |
| **finance** | 분개, 조정, 재무제표, 차이 분석 | Snowflake, Databricks, BigQuery |
| **data** | SQL 쿼리, 통계 분석, 대시보드 | Snowflake, Databricks, BigQuery, Hex |
| **enterprise-search** | 크로스 툴 통합 검색 | Slack, Notion, Guru, Jira, Asana |
| **bio-research** | 전임상 연구, 문헌 검색, 유전체 분석 | PubMed, BioRender, ChEMBL, Benchling |
| **cowork-plugin-management** | 새 플러그인 생성/기존 플러그인 커스터마이징 | — |

설치 방법:
```bash
claude plugin marketplace add anthropics/knowledge-work-plugins
claude plugin install sales@knowledge-work-plugins
```

### 5.3 주요 커뮤니티 마켓플레이스

**ComposioHQ/awesome-claude-plugins**: 18개 이상의 플러그인(commit, code-review, test-writer-fixer, debugger, bug-fix, backend-architect, mcp-builder, agent-sdk-dev, perf, audit-project, connect-apps, frontend-design, artifacts-builder, theme-factory, canvas-design, senior-frontend, security-guidance, developer-growth-analysis). 500+ 앱 연동 커넥터를 제공하는 `connect-apps` 플러그인이 특징적이다.

**claudebase/marketplace**: "Developer Kit" 플러그인으로 **24개 스킬 + 14개 에이전트 + 21개 커맨드**를 단일 패키지로 제공. 풀스택 개발, 보안, 테스팅, DevOps 자동화를 포괄한다.

**paddo/claude-tools**: 6개 전문 플러그인(gemini-tools, codex, dns, headless, mobile, miro). "하이브리드 워크플로" 철학으로 외부 모델의 강점을 활용한다. `gemini-tools`는 Gemini 3 Pro를 통한 시각 분석과 UI 생성, `codex`는 OpenAI Codex를 통한 아키텍처 리뷰를 제공한다.

**gmickel/gmickel-claude-marketplace**: Flow-Next 플러그인이 핵심. 계획 우선 오케스트레이션 시스템으로 `/flow-next:plan`, `/flow-next:work`, `/flow-next:epic-review` 워크플로를 제공한다. **Ralph 자율 모드**는 "잠자는 동안 기능 출시"를 목표로 반복당 새 컨텍스트, 멀티모델 리뷰 게이트, 영수증 기반 게이팅을 구현한다. `flowctl` CLI로 태스크 관리를 지원한다.

### 5.4 LiteLLM 엔터프라이즈 마켓플레이스 프록시

LiteLLM AI Gateway는 Claude Code 플러그인의 **중앙 레지스트리** 역할을 한다. Admin UI에서 플러그인 등록/활성화/비활성화/삭제를 관리하고, 공개 엔드포인트(`GET /claude-code/marketplace.json`)와 인증 필요 관리 엔드포인트(`POST /claude-code/plugins`, `POST .../enable`, `POST .../disable`, `DELETE`)를 제공한다. 멀티테넌트 지원, 팀별 예산/속도 제한, 비용 추적, 모델 라우팅, 감사 로깅이 엔터프라이즈 핵심 기능이다.

---

## 6. 보안과 거버넌스 고려사항

### 6.1 플러그인 샌드박싱과 권한 경계

Claude Code는 **네이티브 OS 레벨 샌드박싱**을 제공한다. macOS에서는 Apple Seatbelt 프레임워크, Linux에서는 Bubblewrap(`bwrap`)을 사용하며, 두 가지 격리 계층을 적용한다: (1) **파일시스템 격리** — CWD와 하위 디렉토리에만 읽기/쓰기, 나머지는 읽기 전용 (SSH 키, .bashrc 등 제외), (2) **네트워크 격리** — 명시적 승인 도메인만 연결 허용, 샌드박스 외부 프록시 서버를 통한 라우팅. 내부 테스트에서 권한 프롬프트를 **84% 감소**시켰다.

**알려진 제한사항**: 네트워크 필터링은 도메인을 제한하지만 **트래픽을 검사하지 않아** github.com 같은 광범위 도메인에서 데이터 유출 가능성이 있다. 도메인 프론팅으로 우회할 수 있으며, `allowUnixSockets` 설정이 시스템 서비스 접근으로 이어질 수 있다.

### 6.2 MCP 커넥터 보안

MCP 서버는 stdio(로컬 프로세스), HTTP(원격), SSE 트랜스포트를 지원한다. 원격 MCP 서버에는 **OAuth 2.0 인증**이 지원되며, 클라이언트 시크릿은 시스템 키체인에 저장된다. Anthropic은 명시적으로 경고한다: **"신뢰할 수 없는 콘텐츠를 가져올 수 있는 MCP 서버는 프롬프트 인젝션 위험에 노출"**될 수 있다. Team/Enterprise 플랜에서는 Owner만 커스텀 커넥터를 추가할 수 있다.

엔터프라이즈 MCP 보안을 위해 Azure API Management를 OAuth 2.0 게이트웨이로 사용하거나, MintMCP 같은 도구 레벨 RBAC 및 감사 로깅 솔루션을 활용할 수 있다.

### 6.3 플러그인 검증과 감사

플러그인 설치 시 `plugin.json` 스키마 검증이 수행되며, 커맨드는 `plugin-name:command-name`으로 네임스페이싱되어 충돌을 방지한다. 공식 디렉토리(claude.com/plugins)에 등록된 플러그인은 **기본 자동 리뷰**를 거치며, "Anthropic Verified" 배지는 추가 품질/보안 리뷰를 의미한다. 다만 Anthropic도 "리뷰에는 한계가 있으며 신뢰하는 개발자의 플러그인만 설치해야 한다"고 명시한다.

커뮤니티 감사 도구로는 Variant Systems의 **code-audit**(7개 분석기: 시크릿, 보안, 의존성, 구조, 테스트), **levnikolaevich/claude-code-skills**(7개 그룹 28개 감사 스킬) 등이 있다.

### 6.4 엔터프라이즈 거버넌스 패턴

`managed-settings.json`은 개발자가 **오버라이드할 수 없는** 조직 전체 정책을 제공한다:

- **권한 티어**: Deny(차단), Ask(승인 필요), Allow(자동 승인)
- **훅 제어**: `allowManagedHooksOnly: true` → 관리 훅만 실행, 사용자/프로젝트/플러그인 훅 차단
- **MCP 서버 허용 목록**: 외부 통합 제한
- **마켓플레이스 제한**: `strictKnownMarketplaces`로 허용된 마켓플레이스 소스만 추가 가능
- **트랜스크립트 보존**: 7-14일 정리 정책

**권장 거버넌스 롤아웃 프레임워크**:
- **1-30일**: 스타터 플러그인 포크, Productivity/Enterprise Search 배포
- **30-60일**: Sales/Support 확장, `/approve` 단계와 감사 로깅 추가, KPI 추적
- **60-90일**: Legal/Finance 단계적 권한으로 도입, 체크섬 포함 서명된 플러그인 레지스트리 생성, MCP 경로 보안 리뷰

플러그인은 **버전 관리된 프로젝트 의존성**으로 취급하여 변경 제어와 CI 게이트를 적용해야 한다. `.claude/settings.json`에서 플러그인 버전과 마켓플레이스를 고정하여 드리프트를 방지한다.

### 6.5 서드파티 플러그인의 프롬프트 인젝션 위험

검증된 주요 공격 벡터는 다음과 같다:

**악성 마켓플레이스 플러그인**: SKILL.md/커맨드 파일에 숨겨진 프롬프트 인젝션이 가능하며, 악성 훅이 human-in-the-loop 권한 승인을 우회할 수 있다. claudemarketplaces.com 같은 자동 스크래핑 레지스트리는 악성 저장소를 발행 후 **1시간 이내에 등록**하며, Anthropic 사칭 저장소도 발견된 바 있다.

**Cowork 파일 유출**: 업로드된 파일을 통한 간접 프롬프트 인젝션으로 Anthropic API 도메인(허용 목록)을 악용한 데이터 유출이 시연되었다.

**CLI 명령어 인젝션 CVE**: CVE-2025-54794(경로 제한 우회, CVSS 7.7)와 CVE-2025-54795(명령어 인젝션을 통한 코드 실행, CVSS 8.7)가 화이트리스트 커맨드 검증의 부적절한 입력 새니타이징을 악용했다.

**방어 수단**: Anthropic의 강화학습 기반 프롬프트 인젝션 내성, 신뢰할 수 없는 콘텐츠 분류기, 격리된 컨텍스트 윈도우(웹 페치용), `curl`/`wget` 기본 차단, 매칭되지 않는 커맨드의 수동 승인 기본값(fail-closed), 커뮤니티 방어 도구(Lasso Security PostToolUse Defender, Safety Net 플러그인)를 조합하여 심층 방어를 구축해야 한다. **핵심 원칙은 "신뢰하는 개발자의 플러그인만 설치"**하고, 엔터프라이즈에서는 `managed-settings.json`으로 허용된 마켓플레이스만 접근 가능하게 제한하는 것이다.

---

## 결론: CLI-Cowork 통합 플러그인 전략의 핵심

Claude Code 플러그인 시스템은 단순한 확장 메커니즘이 아니라, **개발자(CLI)와 비개발자(Cowork) 간의 지식 전달 파이프라인**으로 기능한다. `.claude/` 디렉토리에서의 빠른 프로토타이핑, `.claude-plugin/` 포맷으로의 변환, Git 기반 마켓플레이스를 통한 배포라는 3단계 워크플로가 이 양방향 브릿지의 핵심이다.

엔터프라이즈 도입 시 가장 중요한 세 가지 포인트: **첫째**, `managed-settings.json`의 `strictKnownMarketplaces`와 `allowManagedHooksOnly`로 조직 경계를 설정하라. **둘째**, LiteLLM 프록시 또는 프라이빗 GitHub 마켓플레이스를 통해 승인된 플러그인만 배포하고, 플러그인 버전을 프로젝트 의존성처럼 고정하라. **셋째**, `context: fork`와 프로그레시브 디스클로저를 활용하여 컨텍스트 윈도우 효율성을 극대화하되, 서드파티 플러그인의 SKILL.md와 훅 코드를 반드시 리뷰하라.

아직 해결되지 않은 과제도 있다. 헤드리스 모드에서의 프로그래밍 방식 플러그인 설치는 미지원(Issue #12840, "not planned")이며, Cowork 활동은 아직 감사 로그와 Compliance API에 캡처되지 않는다. GitLab CI/CD 통합은 베타이며 GitHub Action의 `plugins` 파라미터에 해당하는 기능이 없다. 이러한 갭에도 불구하고, 플러그인 생태계의 성장 속도(출시 4개월 만에 9,000+ 플러그인)와 Markdown+JSON 기반의 낮은 진입 장벽은 Claude Code 플러그인이 AI 에이전트 워크플로의 사실상 표준 패키징 포맷으로 자리잡고 있음을 보여준다.