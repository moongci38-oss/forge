# SIGIL — AI Business Pipeline System

> **Strategy & Idea Generation Intelligent Loop**
>
> 아이디어에서 개발 준비 완료까지, AI Agent Teams가 리서치 → 컨셉 → 기획서 → 기획 패키지를 자동 생성하는 4-Stage 파이프라인.

```
S1 Research → S2 Concept → S3 Design Document → S4 Planning Package → Trine (개발)
     ↓             ↓              ↓                      ↓
  [STOP]        [STOP]         [STOP]                 [STOP]
  리서치 리뷰    비전 승인       기획서 승인              개발 진입
```

## What is SIGIL?

SIGIL은 **1인 기업/소규모 팀**이 AI Agent를 활용하여 비개발 업무(시장조사, 기획, 마케팅, 콘텐츠, 디자인)를 체계적으로 수행하기 위한 워크스페이스 프레임워크입니다.

- **9개 전문 AI 에이전트**: 리서치, 기획서 작성, 기술 검토, UX 검증 등
- **6개 스킬**: CTO 자문, 프론트엔드 디자인, 콘텐츠 제작, PM 도구 등
- **8개 슬래시 커맨드**: `/prd`, `/gdd`, `/research`, `/lean-canvas` 등
- **Rules-as-Code**: 컴파일 가능한 규칙 시스템으로 파이프라인 거버넌스 자동화
- **[Trine](https://github.com/moongci38-oss/trine) 연동**: S4 완료 → 개발 프로젝트로 자동 핸드오프

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI 설치
- Node.js 18+
- tmux (Agent Teams 사용 시 필수)

## Quick Start

### 1. Clone

```bash
git clone git@github.com:moongci38-oss/sigil.git ~/business
cd ~/business
```

> **Windows PowerShell**: `~`가 확장되지 않을 수 있습니다. `$HOME`을 사용하세요:
> ```powershell
> git clone git@github.com:moongci38-oss/sigil.git "$HOME\business"
> ```

### 2. 워크스페이스 설정

```bash
# sigil-workspace.json 생성 (개인 프로젝트 경로 설정)
cp sigil-workspace.example.json sigil-workspace.json
```

`sigil-workspace.json`을 편집하여 프로젝트 경로를 설정합니다:

```json
{
  "projects": {
    "my-project": {
      "devTarget": "/path/to/your/dev/project",
      "symlinkBase": "docs/planning/active/sigil"
    }
  }
}
```

### 3. MCP 서버 설정

```bash
# .mcp.json 생성 (프로젝트 MCP 서버 설정)
cp .mcp.json.example .mcp.json
```

`.mcp.json`을 편집하여 filesystem 경로 등을 설정합니다.

### 4. 환경 변수

```bash
cp .env.example .env
# .env 파일에 필요한 API 키 설정
```

### 5. Claude Code 실행

```bash
# tmux 세션에서 실행 (Agent Teams 지원)
tmux new-session -s sigil
claude
```

### 6. Trine 설치 (선택 — 개발 프로젝트 연동 시)

SIGIL S4 완료 후 개발 프로젝트로 핸드오프하려면 [Trine](https://github.com/moongci38-oss/trine)을 설치합니다:

```bash
git clone git@github.com:moongci38-oss/trine.git ~/.claude/trine
node ~/.claude/trine/scripts/setup.mjs
```

## Pipeline Stages

### S1. Research (리서치)

AI가 시장, 경쟁사, 기술, 법규를 병렬 조사합니다.

```
/research "AI 문서 자동화 SaaS 시장 조사"
```

- **에이전트**: `research-coordinator` (조율) + `academic-researcher`, `fact-checker` (병렬)
- **방법론**: JTBD, Competitive Intelligence, TAM/SAM/SOM
- **산출물**: 통합 리서치 리포트
- **게이트**: `[STOP]` 리서치 결과 Human 리뷰

### S2. Concept (컨셉 확정)

Lean Canvas 기반 비즈니스 모델을 검증합니다.

```
/lean-canvas "AI 문서 자동화 도구"
```

- **방법론**: Pretotyping, Mom Test, Lean Validation, OKR
- **Go/No-Go 스코어링**: 시장 기회(30%) + 기술 실현성(25%) + 비즈니스 모델(25%) + 위험 관리(20%)
- **산출물**: 컨셉 문서 + Lean Canvas
- **게이트**: `[STOP]` 비전/타겟/차별점 승인 (80점+ = Go)

### S3. Design Document (기획서)

에이전트 회의(Competing Hypotheses)로 최적 기획안을 도출합니다.

```
/prd    # 앱/웹 → PRD
/gdd    # 게임 → GDD
```

- **에이전트**: 2~3명이 독립 초안 작성 → 비교 → 최적안 선택/병합
- **방법론**: Shape Up Pitch, User Story Mapping, Modern PRD
- **산출물**: 기획서 (.md + .pptx)
- **게이트**: `[STOP]` 기획서 승인

### S4. Planning Package (기획 패키지)

Trine 진입 전 7종 산출물을 작성합니다.

| # | 산출물 | 내용 |
|:-:|--------|------|
| 1 | 상세 기획서 | 화면별 동작 + 데이터 흐름 |
| 2 | 사이트맵 | 페이지/화면 계층 + 네비게이션 |
| 3 | 로드맵 | 마일스톤 + Now/Next/Later |
| 4 | 개발 계획 | 기술 스택 + 아키텍처 + ADR |
| 5 | WBS | 태스크 분해 + 규모 추정 |
| 6 | UI/UX 기획서 | 와이어프레임 + 컴포넌트 스펙 |
| 7 | 테스트 전략서 | 테스트 계층/도구/커버리지 목표 |

- **에이전트**: `technical-writer` (작성) + `cto-advisor` (기술 검토) + `ux-researcher` (UX 검증)
- **Wave Protocol**: Wave 1 (초안) → Wave 2 (Spec 검증) → Wave 3 (리뷰) → Wave 4 (최종본)
- **게이트**: `[STOP]` 승인 → Trine 자동 핸드오프

## Components

### Agents (9개)

| 에이전트 | 역할 |
|---------|------|
| `pipeline-orchestrator` | 파이프라인 S1→S4 조율 + 멀티 프로젝트 병렬 |
| `research-coordinator` | S1 리서치 조율 + Fan-out/Fan-in |
| `academic-researcher` | 학술 자료, 논문, 인용 분석 |
| `fact-checker` | 팩트 검증, 출처 신뢰도 평가 |
| `gdd-writer` | Game Design Document 작성 |
| `technical-writer` | S4 기획 패키지 7종 작성 |
| `cto-advisor` | S4 기술 검토 (아키텍처, ADR) |
| `ux-researcher` | S4 UX 검증 (와이어프레임, 인터랙션) |
| `yt-video-analyst` | YouTube 영상 트랜스크립트 분석 |

### Skills (6개)

| 스킬 | 용도 |
|------|------|
| `content-creator` | SEO 최적화 마케팅 콘텐츠 제작 |
| `cto-advisor` | 기술 리더십, 아키텍처 결정 가이드 |
| `frontend-design` | 프로덕션급 프론트엔드 UI 설계 |
| `playwright-cli` | 브라우저 자동화 (테스트, 스크린샷) |
| `product-manager-toolkit` | RICE 우선순위, 고객 인터뷰, 스프린트 |
| `requirements-clarity` | 모호한 요구사항 인터랙티브 Q&A 해소 |

### Slash Commands (8개)

| 커맨드 | 설명 |
|--------|------|
| `/prd` | PRD 작성 (앱/웹) |
| `/gdd` | GDD 작성 (게임) |
| `/research` | 시장조사 시작 |
| `/lean-canvas` | Lean Canvas 작성 |
| `/generate-image` | AI 이미지 생성 (NanoBanana MCP) |
| `/yt` | YouTube 영상 분석 (트랜스크립트 + AI) |
| `/yt-analyze` | YouTube 트랜스크립트 분석 전용 |
| `/trine` | SIGIL → Trine 핸드오프 |

### Hooks (6개)

| Hook | 트리거 | 기능 |
|------|--------|------|
| `block-sensitive-files.sh` | 파일 읽기/쓰기 | 민감 폴더(06~08) 접근 차단 |
| `block-sensitive-bash.sh` | Bash 실행 | 민감 경로 명령어 차단 |
| `no-force-push.sh` | Bash 실행 | `git push --force` 차단 |
| `require-date-prefix.sh` | 파일 쓰기 | 파일명 날짜 접두사 강제 |
| `auto-build-rules.sh` | 파일 쓰기 | 규칙 소스 수정 시 자동 빌드 |
| `session-context.sh` | 세션 시작 | 워크스페이스 컨텍스트 주입 |

## Structure

```text
sigil/
├── .claude/                        # Claude Code 컴포넌트
│   ├── agents/                     # AI 에이전트 정의 (9개)
│   ├── skills/                     # 스킬 패키지 (6개)
│   ├── commands/                   # 슬래시 커맨드 (8개)
│   ├── hooks/                      # 이벤트 훅 (6개)
│   ├── rules/                      # 컴파일된 규칙 (자동 생성)
│   └── settings.json               # Claude Code 설정
│
├── 01-research/                    # 리서치 영역
│   ├── videos/                     # YouTube 분석 설정
│   └── projects/                   # [gitignored] 프로젝트별 리서치 결과물
│
├── 02-product/                     # 제품 기획 영역
│   └── projects/                   # [gitignored] PRD/GDD/컨셉 산출물
│
├── 03-marketing/                   # 마케팅 영역
│   └── projects/                   # [gitignored] 캠페인/SEO/광고 산출물
│
├── 04-content/                     # 콘텐츠 영역
│   └── projects/                   # [gitignored] 블로그/뉴스레터/소셜
│
├── 05-design/                      # 디자인 영역
│   └── projects/                   # [gitignored] UI/브랜드/목업 산출물
│
├── 09-tools/                       # 시스템 도구
│   ├── rules-source/               # 규칙 원본 (Frontmatter 포함)
│   ├── templates/                  # SIGIL 템플릿 (GDD, PRD, DoD 등)
│   ├── components-library/         # 에이전트/스킬 아카이브
│   ├── skills-library/             # 외부 스킬 라이브러리
│   └── prompts/                    # 프롬프트 템플릿
│
├── 10-operations/                  # 운영/핸드오프
│   ├── handoff-to-dev/             # SIGIL → 개발 프로젝트 전달
│   └── handoff-from-dev/           # 개발 → SIGIL 피드백
│
├── scripts/                        # 자동화 스크립트
│   ├── sigil.sh                    # SIGIL CLI (게이트 체크, 검증)
│   ├── manage-rules.sh             # Rules-as-Code 빌드
│   ├── manage-skills.sh            # 스킬 관리
│   ├── manage-components.sh        # 컴포넌트 관리
│   ├── weekly-report/              # 주간 리서치 자동화
│   └── yt-analyzer/                # YouTube 분석 파이프라인
│
├── docs/guides/                    # 셋업 가이드 (PUBLIC)
├── CLAUDE.md                       # 워크스페이스 지침
├── sigil-workspace.example.json    # 워크스페이스 설정 템플릿
├── .mcp.json.example               # MCP 서버 설정 템플릿
└── .env.example                    # 환경 변수 템플릿
```

## Rules-as-Code

규칙은 소스 파일에서 컴파일하여 사용합니다:

```bash
# 규칙 목록 확인
bash scripts/manage-rules.sh list

# 규칙 빌드 (rules-source → .claude/rules/)
bash scripts/manage-rules.sh build

# 규칙 검증
bash scripts/manage-rules.sh validate

# 토큰 통계
bash scripts/manage-rules.sh stats
```

규칙 소스: `09-tools/rules-source/` (Frontmatter 포함)
빌드 결과: `.claude/rules/` (세션 시작 시 자동 로드)

## Agent Teams

SIGIL은 Claude Code의 Agent Teams 기능을 활용하여 병렬 작업을 수행합니다.

```bash
# 환경변수 설정 (.claude/settings.json에 포함)
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# tmux 세션에서 실행 필수
tmux new-session -s sigil
claude
```

### 오케스트레이션 패턴

| 패턴 | 사용 시점 | 예시 |
|------|----------|------|
| **Fan-out/Fan-in** | 독립 병렬 작업 | S1 리서치 (시장/기술/법규 병렬) |
| **Pipeline** | 순차 의존성 | S1→S2→S3→S4 |
| **Competing Hypotheses** | 최적 해법 탐색 | S3 에이전트 회의 |

### 모델 계층화

| 역할 | 모델 | 용도 |
|------|------|------|
| Lead (오케스트레이터) | Opus 4.6 | 판단, 종합, 회의 심판 |
| 문서 작성 | Sonnet 4.6 | 기획서, 분석, 산출물 |
| 검색/탐색 | Haiku 4.5 | 팩트체크, 트렌드 수집 |

## SIGIL → Trine Integration

S4 완료 후 개발 프로젝트로 자동 핸드오프됩니다:

```
SIGIL S4 완료 → Handoff 문서 자동 생성 → 개발 프로젝트에 symlink → Trine 자동 발동
```

| SIGIL 산출물 | Trine 활용 시점 |
|-------------|----------------|
| S1 리서치 | Phase 1 컨텍스트 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석 |
| S4 상세 기획서 | Phase 2 Spec 작성 |
| S4 개발 계획 | Phase 1 세션 이해 |
| S4 UI/UX 기획서 | Phase 2 Spec UI 섹션 |
| S4 테스트 전략서 | Phase 3 Check |

## MCP Servers

| 서버 | 용도 | Scope |
|------|------|:-----:|
| **filesystem** | 워크스페이스 파일 접근 | project |
| **Sequential Thinking** | 복잡한 전략 계획 수립 | project |
| **Notion** | Notion 페이지/DB 연동 (PM 도구) | project |
| **NanoBanana** | AI 이미지 생성/편집 (Gemini) | user |
| **Stitch** | AI UI 목업 생성 | user |
| **Lighthouse** | 웹 성능/접근성 감사 | user |

## CLI Scripts

```bash
# SIGIL 파이프라인
bash scripts/sigil.sh                    # SIGIL CLI 메인
bash scripts/sigil-gate-check.sh         # Gate 통과 검증
bash scripts/sigil-wave2-trace.sh        # S4 Wave 2 트레이서빌리티
bash scripts/sigil-validate-workspace.sh # 워크스페이스 검증
bash scripts/sigil-metrics.sh            # 파이프라인 메트릭
bash scripts/sigil-research-index.sh     # 리서치 인덱스

# 컴포넌트 관리
bash scripts/manage-rules.sh {list|validate|build|stats}
bash scripts/manage-skills.sh {list|enable|disable|audit}
bash scripts/manage-components.sh {list|enable|disable|token-estimate}

# 자동화
bash scripts/weekly-report/run.sh        # 주간 리서치 리포트
bash scripts/yt-analyzer/run.sh          # YouTube 분석
```

## Customization

### 프로젝트 추가

`sigil-workspace.json`에 프로젝트를 추가합니다:

```json
{
  "projects": {
    "my-web-app": {
      "devTarget": "/path/to/web-project",
      "symlinkBase": "docs/planning/active/sigil",
      "type": "web",
      "description": "My SaaS application"
    },
    "my-game": {
      "devTarget": "/path/to/game-project",
      "symlinkBase": "docs/planning/active/sigil",
      "type": "game",
      "description": "Unity mobile game"
    }
  }
}
```

### 규칙 커스터마이징

`09-tools/rules-source/`에 규칙 소스를 추가/수정한 후 빌드합니다:

```bash
# 규칙 소스 수정
vim 09-tools/rules-source/always/my-rule.md

# 빌드
bash scripts/manage-rules.sh build
```

### 스킬/에이전트 관리

```bash
# 스킬 활성화/비활성화
bash scripts/manage-skills.sh list
bash scripts/manage-skills.sh disable content-creator

# 에이전트 활성화/비활성화
bash scripts/manage-components.sh list
bash scripts/manage-components.sh disable academic-researcher
```

## Troubleshooting

### Claude Code 미설치

```bash
npm install -g @anthropic-ai/claude-code
claude  # 최초 실행 → ~/.claude/ 자동 생성
```

### Agent Teams 동작 안 함

tmux에서 실행하지 않으면 Agent Teams가 작동하지 않습니다:

```bash
tmux new-session -s sigil
claude
```

### MCP 서버 연결 실패

```bash
# MCP 서버 상태 확인
bash scripts/mcp-health-check.sh

# .mcp.json이 프로젝트 루트에 있는지 확인
ls -la .mcp.json
```

### 규칙 빌드 실패

```bash
# 규칙 검증
bash scripts/manage-rules.sh validate

# 강제 재빌드
bash scripts/manage-rules.sh build --force
```

### 워크스페이스 검증

```bash
# 전체 검증
bash scripts/sigil-validate-workspace.sh

# sigil-workspace.json이 없으면
cp sigil-workspace.example.json sigil-workspace.json
```

## Public vs Private

이 repo는 **프레임워크만 공개**합니다:

| 구분 | 상태 | 내용 |
|------|:----:|------|
| **PUBLIC** | tracked | agents, skills, commands, hooks, rules, templates, scripts, guides |
| **PRIVATE** | gitignored | 프로젝트별 리서치, PRD/GDD, 디자인, 마케팅 산출물 |

`sigil-workspace.json`, `.mcp.json`, `.env`는 개인 설정이므로 gitignored입니다.
각각의 `.example` 파일을 복사하여 사용하세요.

## Related Projects

- **[Trine](https://github.com/moongci38-oss/trine)** — AI-Native Development System (SDD + DDD + TDD)
  - SIGIL S4 완료 후 Trine이 개발 파이프라인을 이어받습니다

## License

MIT
