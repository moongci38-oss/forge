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
| **Forge Outputs** | `~/forge-outputs/` | 산출물 저장소 (private) |
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

> 상세: `.claude/rules/forge-core.md` 참조

- **forge/ = 시스템** / **forge-outputs/ = 결과물** (Iron Law)
- 병렬 처리 가능한 작업은 Subagent 사용을 우선 검토

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
| **Draw.io** | project | 다이어그램 생성 |
| **Replicate** | project | AI 모델 (style-train, game-asset-generate) |
| **NanoBanana** | project | Google Gemini AI 이미지 생성/편집 |
| **Stitch** | project | AI UI 목업 생성 |
| **Notion** | global | Notion 페이지/DB 연동 |
| **Brave Search** | global | 웹 검색 |

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
