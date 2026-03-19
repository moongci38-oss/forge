# Forge — Unified AI Pipeline System

> **Planning + Development in one repo**
>
> 아이디어에서 프로덕션까지, AI Subagent가 Phase 1~12 통합 파이프라인을 자동화.

```
Part A (기획):  Phase 1 Research → Phase 2 Concept → Phase 3 Design Doc → Phase 4 Planning
                                                                                ↓
                                                                   Phase 5 Handoff + Setup
                                                                                ↓
Part B (개발):  Phase 6 Session → Phase 7 Spec → Phase 8 Implement → Phase 9~12 Deploy
```

## What is Forge?

Forge는 **1인 기업/소규모 팀**이 AI Agent를 활용하여 기획부터 개발까지 체계적으로 수행하기 위한 통합 파이프라인입니다.

- **Planning** (Phase 1~4): 기획 파이프라인 — 리서치, 컨셉, 기획서, 기획패키지
- **Dev** (Phase 6~12): 개발+배포 파이프라인 — SDD+DDD+TDD
- **13개 전문 AI 에이전트**, **40+ 스킬**, **10개 슬래시 커맨드**
- **Rules-as-Code**: 컴파일 가능한 규칙 시스템으로 파이프라인 거버넌스 자동화

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Node.js 18+

## Quick Start

```bash
# 1. Clone
git clone git@github.com:moongci38-oss/forge.git ~/forge
cd ~/forge

# 2. 워크스페이스 설정
cp forge-workspace.example.json forge-workspace.json
# → forge-workspace.json에서 프로젝트 경로 설정

# 3. 환경 변수
cp .env.example .env
# → .env에 API 키 설정

# 4. MCP 서버 전역 등록
bash shared/scripts/setup-mcp.sh
# → ~/.claude.json에 10개 전역 MCP 서버 자동 등록 (멱등)

# 5. Claude Code 실행
claude
```

### MCP 서버

`setup-mcp.sh`가 등록하는 전역 MCP 서버:

| 서버 | 용도 | API 키 |
|------|------|:------:|
| Brave Search | 웹 검색 | `BRAVE_API_KEY` |
| NanoBanana | Gemini 이미지 생성 | `GEMINI_API_KEY` |
| Replicate | AI 모델 실행 | `REPLICATE_API_TOKEN` |
| Stitch | UI 목업 생성 | `STITCH_API_KEY` |
| Ludo | 게임 에셋 생성 | `LUDO_API_KEY` |
| Sentry | 에러 추적 | - |
| Notion | 노션 연동 | - |
| Lighthouse | 웹 성능 감사 | - |
| Draw.io | 다이어그램 생성 | - |
| Magic UI | UI 컴포넌트 | - |

> 프로젝트별 MCP(DB, Unity 등)는 각 프로젝트의 `.mcp.json`에서 관리합니다.

## Structure

```
forge/
├── pipeline.md         ← 통합 파이프라인 (Phase 1~12)
├── planning/           ← Phase 1~4 기획 파이프라인
│   ├── rules-source/   ← 기획 규칙 원본
│   ├── templates/      ← 기획 템플릿 (PRD, GDD, Spec 등)
│   └── prompts/        ← 기획 메서드 프롬프트
├── dev/                ← Phase 6~12 개발+배포 파이프라인
│   ├── rules/          ← 개발 규칙
│   ├── templates/      ← 개발 템플릿
│   ├── scripts/        ← 개발 스크립트
│   └── schemas/        ← JSON 스키마
├── shared/             ← 양쪽 공통
│   ├── docs/           ← 공유 문서
│   ├── scripts/        ← 관리 스크립트
│   └── cross-project/  ← 크로스 프로젝트 규칙
├── .claude/            ← Claude Code 설정 (팀 공유)
│   ├── agents/         ← AI 에이전트 (13개)
│   ├── skills/         ← 스킬 패키지 (40+개)
│   ├── commands/       ← 슬래시 커맨드 (10개)
│   ├── hooks/          ← 보안/자동화 훅 (6개)
│   └── rules/          ← 컴파일된 규칙
├── forge-workspace.json
├── .env.example
└── CLAUDE.md
```

## CLI Scripts

```bash
# 파이프라인
bash shared/scripts/forge.sh                    # Forge CLI
bash shared/scripts/forge-gate-check.sh         # Gate 통과 검증
bash shared/scripts/forge-validate-workspace.sh # 워크스페이스 검증

# 컴포넌트 관리
bash shared/scripts/manage-rules.sh {list|validate|build|stats}
bash shared/scripts/manage-skills.sh {list|enable|disable|audit}
bash shared/scripts/manage-components.sh {list|enable|disable}
```

## Slash Commands

| 커맨드 | 설명 |
|--------|------|
| `/prd` | PRD 작성 (앱/웹) |
| `/gdd` | GDD 작성 (게임) |
| `/research` | 시장조사 시작 |
| `/lean-canvas` | Lean Canvas 작성 |
| `/forge` | Planning → Dev 핸드오프 |
| `/daily-system-review` | AI 시스템 일일 분석 |
| `/weekly-research` | 주간 리서치 파이프라인 |
| `/yt` | YouTube 영상 분석 |

## Customization

### 프로젝트 추가

`forge-workspace.json`에 프로젝트를 추가합니다:

```json
{
  "projects": {
    "my-project": {
      "devTarget": "/path/to/dev-project",
      "symlinkBase": "docs/planning/active/forge"
    }
  }
}
```

### 규칙 커스터마이징

```bash
# 규칙 소스 수정
vim planning/rules-source/always/my-rule.md

# 빌드
bash shared/scripts/manage-rules.sh build
```

## Public vs Private

| 구분 | 상태 | 내용 |
|------|:----:|------|
| **PUBLIC** | tracked | agents, skills, commands, hooks, rules, templates, scripts |
| **PRIVATE** | gitignored | forge-workspace.json, .mcp.json, .env, 프로젝트 산출물 |

산출물은 별도 private repo (`forge-outputs`)에서 관리합니다.

## Prefab Visual Library

에셋 재사용을 위한 Prefab Library를 별도 클론합니다:

```bash
git clone git@github.com:moongci38-oss/prefab-visual-library.git ~/prefab-visual-library
```

`forge-workspace.json`의 `prefabLibraryRoot`에서 경로를 참조합니다.
`library-search` 스킬로 기존 에셋을 검색하여 MCP 생성 비용을 절감합니다.

## License

MIT
