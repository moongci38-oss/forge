# Forge — Unified Planning + Dev Pipeline

> Phase 1~12 통합 파이프라인.
> `planning/` (Phase 1~4 기획) + `dev/` (Phase 6~12 개발) + `shared/` (공통 도구).

---

## Workspace Context

**소유자**: 1인 기업 운영자 (풀스택 개발자 겸 사업가)
**비전**: 백엔드 개발자 1명이 AI Subagent로 6개 약점 영역을 80% 이상 보완

### 멀티 프로젝트 워크스페이스

| 프로젝트 | 경로 | 설명 |
|---------|------|------|
| **Forge** | `./` | 통합 파이프라인 (현재) |
| **Forge Outputs** | `/home/damools/forge-outputs/` | 산출물 저장소 (private) |
| **Portfolio** | `{YOUR_PORTFOLIO_PATH}` | Next.js + NestJS 웹 개발 |
| **GODBLADE** | `{YOUR_GAME_PROJECT_PATH}` | Unity 게임 프로젝트 (C#) |

### 디렉토리 구조

```
forge/
├── pipeline.md       ← 통합 파이프라인 (Phase 1~12)
├── planning/         ← Phase 1~4 기획 파이프라인
│   ├── rules-source/ ← 기획 규칙 원본
│   ├── templates/    ← 기획 템플릿 (PRD, GDD, Spec 등)
│   └── prompts/      ← 기획 메서드 프롬프트
├── dev/              ← Phase 6~12 개발+배포 파이프라인
│   ├── rules/        ← 개발 규칙
│   ├── templates/    ← 개발 템플릿
│   ├── scripts/      ← 개발 스크립트
│   ├── schemas/      ← JSON 스키마
│   ├── gitlab-spec-kit/ ← GitLab 연동
│   └── prompts/      ← 개발 파이프라인 프롬프트
├── shared/           ← 양쪽 공통
│   ├── docs/         ← 공유 문서
│   ├── scripts/      ← 관리 스크립트 (manage-rules, manage-skills 등)
│   └── cross-project/ ← 크로스 프로젝트 규칙
├── .claude/          ← Claude Code 설정 (팀 공유)
│   ├── rules/        ← 컴파일 규칙 (forge-planning.md, forge-core.md)
│   ├── agents/       ← 에이전트 정의
│   ├── skills/       ← 스킬 정의
│   ├── commands/     ← 슬래시 커맨드
│   ├── hooks/        ← 보안/자동화 훅
│   └── prompts/      ← 오케스트레이션 프롬프트
└── forge-workspace.json ← 프로젝트 매핑 + Notion DB

forge-outputs/          ← 산출물 (private repo)
├── 01-research/      ← 리서치 결과
├── 02-product/       ← 제품 기획 산출물
├── 03-marketing/     ← 마케팅 콘텐츠
├── 04-content/       ← 콘텐츠
├── 05-design/        ← 디자인 에셋
├── 10-operations/    ← 운영/핸드오프
└── docs/             ← 문서 (planning, reviews, tech)
```

---

## Golden Rules

### Core Principle
- **forge/ = 시스템** (파이프라인, 규칙, 도구, 스킬, 스크립트)
- **forge-outputs/ = 결과물** (리서치, 기획서, 에셋, 리뷰, 문서 등 모든 산출물)
- **forge/에 산출물 저장 금지.** 모든 산출물은 forge-outputs/로.
- 통합 파이프라인: `forge/pipeline.md` (Phase 1~12)

### Do's
- 리서치 결과는 출처(URL, 날짜) 반드시 포함
- 문서 작성 시 한국어 기본, 전문 용어는 영어 병기
- 병렬 처리 가능한 작업은 Subagent 사용을 우선 검토

### Don'ts
- B 영역 접근/출력 금지 (06-finance, 07-legal, 08-admin — forge-outputs에 보관)
- 검증 없는 시장 데이터를 사실로 단정 금지
- 스킬/컴포넌트 라이브러리 원본 직접 수정 금지

---

## 팀 온보딩

1. 레포 클론: `git clone ssh://git@ssh.lumir-ai.com:32361/lumir/forge.git`
2. `.env.example` → `.env` 복사 후 API 키 설정
3. `forge-workspace.json`에서 프로젝트 경로 확인
4. Claude Code에서 `/forge` 등 슬래시 커맨드 사용

---

## Component System

| 타입 | 위치 | 관리 |
|------|------|------|
| Skills | `.claude/skills/` | `shared/scripts/manage-skills.sh` |
| Agents | `.claude/agents/` | `shared/scripts/manage-components.sh` |
| Commands | `.claude/commands/` | `shared/scripts/manage-components.sh` |
| Rules | `.claude/rules/` | `shared/scripts/manage-rules.sh` |

### 도구 관리 CLI

| 도구 | 명령 |
|------|------|
| 스킬 | `bash shared/scripts/manage-skills.sh {list\|enable\|disable\|audit}` |
| 컴포넌트 | `bash shared/scripts/manage-components.sh {list\|enable\|disable\|token-estimate}` |
| 규칙 | `bash shared/scripts/manage-rules.sh {list\|validate\|build\|stats}` |

---

## 규칙 시스템 (Rules-as-Code)

| 위치 | 내용 |
|------|------|
| `.claude/rules/` | 컴파일된 규칙 (세션 시작 시 자동 로드) |
| `planning/rules-source/` | 기획 규칙 원본 (Frontmatter 포함) |
| `planning/rules-source/always/` | 항상 적용 규칙 원본 |
| `shared/cross-project/` | 크로스 프로젝트 규칙 |
| `dev/rules/` | 개발 규칙 (개발 프로젝트에 배포) |
| `~/.claude/rules/` | 전역 규칙 |

---

## 병렬 실행 (Subagent 기본)

> Subagent가 기본 병렬 도구. Agent Teams는 Competing Hypotheses/Watchdog 전용.

---

## Output Preferences

- **문서**: Markdown 기본
- **언어**: 한국어 기본, 해외 대상 자료는 영어

---

## 사용 환경

| 환경 | 사용자 | 주요 작업 |
|------|--------|----------|
| **Claude Code (CLI)** | 개발자 | Subagent 병렬 실행, 스크립트 실행, Git 작업 |
| **Claude Desktop Cowork** | 비개발자 | 리서치, 문서 작성, 콘텐츠 기획 |

---

# 세션 정보 (Dynamic)

## MCP Servers

| 서버 | Scope | 설명 |
|------|:-----:|------|
| **filesystem** | project | 워크스페이스 파일 접근 |
| **Sequential Thinking** | project | 복잡한 전략 계획 수립 |
| **Notion** | project | Notion 페이지/DB 연동 |
| **NanoBanana** | user | Google Gemini AI 이미지 생성/편집 |
| **Stitch** | user | AI UI 목업 생성 |
| **Lighthouse** | user | 웹 성능/접근성/SEO 감사 |
| **Sentry** | user | 프로덕션 에러 추적 |
| **Brave Search** | user | 웹 검색 |
| **Draw.io** | user | 다이어그램 생성 |

## Plugins

| 플러그인 | 용도 | 상태 |
|---------|------|:----:|
| **product-management** | 기획, PRD, 로드맵 | ✅ |
| **marketing** | 캠페인, 콘텐츠, SEO | ✅ |
| **data** | 데이터 분석, 대시보드 | ✅ |
| **playground** | 시각적 탐색 | ✅ |
| **code-review** | PR 코드 리뷰 | ✅ |
| **security-guidance** | 보안 가이드 | ✅ |
| **superpowers** | 워크플로 스킬 | ✅ |
| **skill-creator** | 스킬 생성/평가/개선 | ✅ |

---

*Last Updated: 2026-03-19 (Forge 통합 마이그레이션)*
