# Forge — 통합 AI 파이프라인 시스템

[English](README.md)

> **아이디어에서 프로덕션까지 — AI Subagent가 Phase 1~12 통합 파이프라인을 자동화.**

```
기획:  Phase 1 리서치 → Phase 2 컨셉 → Phase 3 기획서 → Phase 4 기획 패키지
                                                                    ↓
                                                       Phase 5 핸드오프 + 셋업
                                                                    ↓
개발:  Phase 6 세션 → Phase 7 Spec → Phase 8 구현 → Phase 9~12 배포
```

## Forge란?

Forge는 **1인 기업/소규모 팀**이 AI Agent를 활용하여 기획부터 배포까지 체계적으로 수행하기 위한 통합 파이프라인입니다.

- **기획** (Phase 1~4): 리서치, 컨셉 검증, 기획서, 기획 패키지
- **개발** (Phase 6~12): Spec 기반 개발 — SDD+DDD+TDD
- **13개 전문 AI 에이전트**, **40+ 스킬**, **10개 슬래시 커맨드**
- **Rules-as-Code**: 컴파일 가능한 규칙 시스템으로 파이프라인 거버넌스 자동화
- **Notion 단독 SoT**: 작업 추적의 유일한 Source of Truth

### 핵심 워크플로

```
Spec 작성 → Notion 등록 → 브랜치 생성 → 진행중 → PR → 완료
```

Hotfix 포함 모든 작업은 Spec 문서 작성 후 브랜치를 생성합니다. 예외 없음.

## 사전 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Node.js 18+

## 빠른 시작

```bash
# 1. 클론
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

# 5. CLI 도구 설치 (MCP와 병행 사용)
bash shared/scripts/setup-cli.sh
# → Lighthouse, Sentry CLI 설치 (CI/배치용)

# 6. Claude Code 실행
claude
```

## 디렉토리 구조

```
forge/
├── pipeline.md         ← 통합 파이프라인 (Phase 1~12)
├── planning/           ← Phase 1~4 기획 파이프라인
│   ├── rules-source/   ← 기획 규칙 원본
│   ├── templates/      ← 기획 템플릿 (PRD, GDD, Spec 등)
│   └── prompts/        ← 기획 메서드 프롬프트
├── dev/                ← Phase 6~12 개발+배포 파이프라인
│   ├── rules/          ← 개발 규칙 (프로젝트에 배포)
│   ├── templates/      ← 개발 템플릿
│   ├── scripts/        ← 개발 스크립트 (forge-sync 등)
│   ├── schemas/        ← JSON 스키마
│   └── github-spec-kit/← GitHub 워크플로 + 스크립트
├── shared/             ← 기획+개발 공통
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

## 작업 관리

**Notion Tasks DB가 유일한 Source of Truth.** `todo.md`는 S4 Gate PASS 시 초기 일괄 등록용으로만 사용.

| 동작 | 트리거 | 메커니즘 |
|------|--------|---------|
| 초기 등록 | S4 Gate PASS | `sync-notion-tasks.py register <todo-file>` |
| 진행중 전환 | 브랜치 생성 | GitHub Actions → Notion API |
| 완료 전환 | PR merge | GitHub Actions → Notion API |
| 수동 등록 | 요청 시 | AI가 Notion MCP로 직접 또는 Notion에서 직접 입력 |

**등록 기준:** Spec 문서 작성 + 브랜치 생성이 필요한 작업만 등록.

**Human Override:** `last_edited_by`가 사람이고 상태가 AI 예상값과 다르면 AI가 덮어쓰지 않음 (PM-IRON-1).

## MCP 서버

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

## CLI 스크립트

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

## 슬래시 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/prd` | PRD 작성 (앱/웹) |
| `/gdd` | GDD 작성 (게임) |
| `/research` | 시장조사 시작 |
| `/lean-canvas` | Lean Canvas 작성 |
| `/forge` | 기획 → 개발 핸드오프 |
| `/daily-system-review` | AI 시스템 일일 분석 |
| `/weekly-research` | 주간 리서치 파이프라인 |
| `/yt` | YouTube 영상 분석 |

## 프로젝트 동기화

Forge는 `forge-sync.mjs`를 통해 규칙, 템플릿, 워크플로, 스크립트를 등록된 프로젝트에 배포합니다.

```bash
# 새 프로젝트 등록
node ~/.claude/scripts/forge-sync.mjs init /path/to/project --name my-project

# 전체 프로젝트 동기화
node ~/.claude/scripts/forge-sync.mjs sync

# 동기화 상태 확인
node ~/.claude/scripts/forge-sync.mjs status
```

`init` 시 `.specify/config.json`이 자동 생성되며 Notion DB 설정이 포함됩니다.

## 커스터마이징

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

`forge-workspace.json`의 `prefabLibraryRoot`에서 경로를 참조합니다. `library-search` 스킬로 기존 에셋을 검색하여 MCP 생성 비용을 절감합니다.

## 라이선스

MIT
