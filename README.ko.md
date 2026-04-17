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
- **15개 전문 AI 에이전트**, **66개 스킬**, **15개 이상 슬래시 커맨드**
- **PGE 하네스**: Planner-Generator-Evaluator 구조로 자기평가 편향 제거
- **RAG 시스템**: 하이브리드 벡터+BM25 검색 (forge-outputs 전체)
- **Rules-as-Code**: 컴파일 가능한 규칙 시스템으로 파이프라인 거버넌스 자동화
- **Notion 단독 SoT**: 작업 추적의 유일한 Source of Truth
- **텔레그램 원격 제어**: 원격에서 세션 상태 모니터링 및 제어

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

# 6. learnings 자동 로드 훅 등록 (머신당 1회)
node ~/.claude/scripts/forge-sync.mjs sync --target <project> --include-recommended
# → 이후 ~/.claude/settings.json SessionStart 훅에 추가:
# {
#   "type": "command",
#   "command": "bash /path/to/project/.claude/hooks/load-learnings.sh"
# }

# 7. Claude Code 실행
claude
```

## 디렉토리 구조

```
forge/
├── pipeline.md              ← 통합 파이프라인 (Phase 1~12)
├── planning/                ← Phase 1~4 기획 파이프라인
│   ├── rules-source/        ← 기획 규칙 원본
│   ├── templates/           ← 기획 템플릿 (PRD, GDD, Spec 등)
│   └── prompts/             ← 기획 메서드 프롬프트
├── dev/                     ← Phase 6~12 개발+배포 파이프라인
│   ├── rules/               ← 개발 규칙 (프로젝트에 배포)
│   ├── templates/           ← 개발 템플릿
│   ├── scripts/             ← 개발 스크립트 (forge-sync 등)
│   ├── schemas/             ← JSON 스키마
│   └── github-spec-kit/     ← GitHub Actions 워크플로우 + 스크립트
├── shared/                  ← 기획+개발 공통
│   ├── docs/                ← 공유 문서
│   ├── scripts/             ← 관리 스크립트 (RAG 포함)
│   └── cross-project/       ← 크로스 프로젝트 규칙
├── .claude/                 ← Claude Code 설정 (팀 공유)
│   ├── agents/              ← AI 에이전트 (15개)
│   ├── skills/              ← 스킬 패키지 (66개)
│   ├── commands/            ← 슬래시 커맨드
│   ├── hooks/               ← 보안/자동화 훅 (7개)
│   └── rules/               ← 컴파일된 규칙
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

### 자체 구축: `forge-tools` MCP 서버

Forge는 자체 MCP 서버(`shared/mcp/forge-tools-server.py`, FastMCP 3.2.3)도 함께 제공한다. 파일 I/O, Git, RAG 검색, 웹 검색/fetch, Notion, Telegram, 헬스 모니터링을 아우르는 14종 도구를 노출하며, 로컬에서는 `http://localhost:8765/mcp`로 실행되고 영구 Cloudflare 터널을 통해 `https://manager-agent.lumir-ai.com/mcp`에서 클라우드 **Managed Agents**에 연결된다. 도구 전체 목록, 인프라, 운영 제약은 아래 [Managed Agents](#managed-agents-클라우드-자동화) 섹션 참조.

> 프로젝트별 MCP(sequential-thinking, hwpx 등)는 각 프로젝트의 `.mcp.json`에서 관리합니다.

## Managed Agents (클라우드 자동화)

Claude Code 세션 없이 자율 실행되는 Anthropic 호스팅 에이전트. FastMCP 3.2.3 서버가 14종 도구를 클라우드 에이전트에게 노출하고, Cloudflare 영구 엔드포인트로 프록시된다.

**MCP 서버:** `https://manager-agent.lumir-ai.com/mcp` (영구 URL, Cloudflare 프록시)

### 등록된 에이전트

| 에이전트 | 용도 |
|---------|------|
| `daily-system-review` | 일일 AI/에이전틱 분야 변경사항 감지 → forge-outputs 저장 + git 커밋 |
| `weekly-research` | 주간 리서치 파이프라인 (Wave 0→1 병렬 수집 + 분석) |
| `system-audit` | ACHCE 5축 통합 감사 오케스트레이터 |
| `audit-agentic` | 에이전틱 AI 역량 감사 (자율성, 도구 사용, 멀티에이전트) |
| `audit-context` | 컨텍스트 엔지니어링 감사 (RAG, 메모리, 7-레이어) |
| `audit-harness` | AI 하네스 엔지니어링 감사 (가드레일, 옵저버빌리티) |
| `audit-cost` | AI 비용 효율 감사 (토큰 경제, 라우팅) |
| `audit-human-ai` | Human-AI 경계 설계 감사 (자율성 레벨, 에스컬레이션) |

Agent ID 및 환경 ID는 `shared/mcp/forge-agent-ids.json`에서 관리.

### MCP 서버 도구 (14종)

`shared/mcp/forge-tools-server.py`가 `streamable-http`로 다음 도구를 노출한다:

| 카테고리 | 도구 |
|---------|------|
| 파일 I/O | `read_file`, `write_file`, `list_files`, `append_file` |
| Git | `git_status`, `git_commit`, `git_log` |
| 실행 | `run_script` (화이트리스트 기반) |
| 검색 | `rag_search`, `web_search` (Brave API), `web_fetch` |
| 모니터링 | `run_health_check` |
| 알림 | `telegram_notify` |
| Notion | `notion_create_page` |

### 에이전트 실행

```bash
# 0. 최초 1회: MCP 서버 Python 의존성 설치 (fastmcp, anthropic)
pip install -r shared/mcp/requirements.txt

# 로컬에서 에이전트 실행 (스트리밍 + 완료 대기)
python3 shared/scripts/run-managed-agent.py daily-system-review [YYYY-MM-DD]
python3 shared/scripts/run-managed-agent.py weekly-research
python3 shared/scripts/run-managed-agent.py system-audit

# MCP 서비스 관리 (WSL 로컬, tmux 기반)
shared/scripts/forge-mcp-service.sh start|stop|restart|status
shared/scripts/forge-mcp-service.sh update-agents   # 에이전트 MCP URL만 갱신
```

### Telegram 명령 서버

`shared/scripts/telegram-command-server.py`가 원격 서버에서 실행되어 Claude Code 없이도 텔레그램으로 에이전트 실행 가능:

- `run <에이전트>` — 에이전트 원격 실행
- `status` — 서버 상태 확인
- `agents` — 에이전트 목록

### 인프라

- 원격 서버: `manager-agent.lumir-ai.com` (Ubuntu 22.04, 183.111.8.37)
- Nginx 리버스 프록시 → 포트 8765 (FastMCP, `/mcp` 엔드포인트)
- Telegram 명령 서버: `tmux forge-telegram` 세션
- MCP 서버: `tmux forge-mcp` 세션
- `.env`의 `PERMANENT_MCP_URL` → 재시작 시에도 에이전트 URL 고정

### 운영 제약

1. **`permission_policy: always_allow` 필수** — 기본값 `always_ask`는 클라우드 실행 시 승인자가 없어 MCP 도구 사용을 영구 블로킹한다.
2. **FastMCP ≥ 3.2.3 transport** — SSE 미지원. `streamable-http`만 사용. 클라이언트 URL: `http://localhost:8765/mcp` 또는 `https://manager-agent.lumir-ai.com/mcp`.
3. **도구명 동기화** — 에이전트 system prompt(SKILL.md)의 도구명이 MCP 서버와 불일치하면 `tool not found` 오류. 재등록 전 `mcp list-tools`로 확인.
4. **`BRAVE_API_KEY` 따옴표 금지** — `.env`에 따옴표 포함 시 값에 포함되어 Brave API 401 발생.

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

## 스킬 & 커맨드 전체 목록

### 기획 파이프라인

| 스킬 | 설명 |
|------|------|
| `/prd` | PRD 작성 (앱/웹) |
| `/gdd` | GDD 작성 (게임) |
| `/sdd` | SDD 작성 (서비스 설계) |
| `/research` | 시장조사 시작 |
| `/lean-canvas` | Lean Canvas 작성 |
| `/forge` | 기획 → 개발 핸드오프 |
| `/forge-status` | 파이프라인 현황 확인 |
| `/forge-onboard` | 새 팀원 온보딩 |
| `/forge-router` | 개발 요청을 Forge Dev 파이프라인으로 자동 라우팅 |
| `/forge-planning-router` | 기획 요청을 적절한 Forge 스테이지로 자동 라우팅 |

### 개발 품질

| 스킬 | 설명 |
|------|------|
| `/pge` | Planner-Generator-Evaluator 품질 하네스. Planner+Generator는 메인 컨텍스트에서 실행하고, Evaluator만 subagent로 격리하여 자기평가 편향을 차단 |
| `/qa` | Spec 기준 기능별 시나리오 자동 생성 후 발견→수정→재검증 루프 실행. Phase 8 Check 6.7 PASS 후 자동 트리거 |
| `/benchmark` | PR 생성 전 develop 대비 feature 브랜치 성능 비교 (번들 크기, 테스트 시간, API 응답 시간). Phase 9 자동 트리거 |
| `/canary` | 스테이징 통합 후 15분 헬스 모니터링 (에러율, 응답 시간, 메모리). Phase 10 자동 트리거 |
| `/investigate` | 버그/이슈 근본 원인을 4단계 구조화 프로세스로 분석. 증상→분석→가설→검증→수정 순서 강제 |
| `/autoplan` | 기획서를 CEO(비즈니스)→Design(UX)→Engineering(기술) 3관점으로 순차 리뷰. Phase 3 에이전트 회의 후 자동 트리거 |
| `/forge-fix` | 자동 버그 수정 파이프라인 |
| `/forge-check-ui` | UI 품질 검증 |
| `/forge-check-traceability` | Spec-구현 추적성 검증 |
| `/forge-resume` | 중단된 파이프라인 세션 재개 |
| `/forge-rollback` | 파이프라인 이전 Phase로 롤백 |
| `/spec-compliance-checker` | Spec과 구현 코드 간 추적성 검증 (FR 매핑, 테스트 존재 여부, API 계약, 데이터 모델). Check 3.5에서 자동 실행 |
| `/inspection-checklist` | PR 전 최종 체크리스트 — 빌드/테스트, Spec 추적성, UI 품질, 코드 리뷰, 보안 5개 영역 종합 판정 |
| `/writing-plans` | Spec을 TDD 지향 태스크 시퀀스로 변환 (파일 경로 + 2-5분 단위 액션 아이템) |
| `/concise-planning` | 코딩 작업을 위한 명확하고 원자적인 구현 체크리스트 생성 |
| `/requirements-clarity` | 구현 전 모호한 요구사항을 집중 대화로 명확화 |
| `/kaizen` | 개선 원칙 가이드라인 (카이젠, 포카요케, YAGNI 기반 범위 제어) |

### AI 시스템 감사 — 5축 ACHCE

| 스킬 | 설명 |
|------|------|
| `/system-audit` | 5축 통합 시스템 감사 (Agentic + Context + Harness + Cost + Human-AI 전체) |
| `/audit-agentic` | 에이전틱 AI 역량 감사: 자율성, 도구 사용, 멀티에이전트 조정, 성숙도 레벨 |
| `/audit-context` | 컨텍스트 엔지니어링 감사: RAG, 메모리, 컨텍스트 윈도우 관리, 지식 아키텍처 |
| `/audit-harness` | AI 하네스 엔지니어링 감사: 평가 체계, 가드레일, 옵저버빌리티, 신뢰성 |
| `/audit-cost` | AI 비용 효율 감사: 토큰 경제학, 모델 라우팅, 캐싱 전략, 추론 최적화 |
| `/audit-human-ai` | Human-AI 경계 설계 감사: 자율성 레벨, 에스컬레이션 설계, 게이트 패턴, 신뢰 캘리브레이션 |

### 리서치 & 콘텐츠

| 스킬 | 설명 |
|------|------|
| `/daily-system-review` | 전일 AI/Agentic 분야 데이터를 6-Tier로 수집하여 우리 시스템과 비교 분석 |
| `/daily-analyze` | raw-data.json이 이미 있는 날짜에 대해 수집 스킵 후 분석만 재실행 |
| `/weekly-research` | 주간 리서치 파이프라인 — Subagent 병렬로 3개 산출물 생성 |
| `/weekly-analyze` | raw-data.json이 이미 있을 때 주간 리서치 분석만 재실행 |
| `/yt` | YouTube 영상 분석: 트랜스크립트 추출, 구조화 요약, Notion 업로드 |
| `/yt-analyze` | 동일 클러스터 내 다중 영상 교차 비교 분석 (합의점/분기점/인사이트) |
| `/rag-search` | forge-outputs 문서 하이브리드 벡터+BM25 의미 기반 검색 |
| `/wiki-sync` | Karpathy 3-layer(Raw→Wiki→Meta) 추출 워크플로우. Raw 문서에서 Obsidian vault로 업데이트를 제안하고 Human 승인 후 반영 |
| `/learn` | 세션 간 학습을 learnings.jsonl에 축적하고 다음 세션에서 자동 참조 |
| `/clip` | 링크 저장 및 분석 |
| `/content-creator` | SEO 최적화 마케팅 콘텐츠 생성 (블로그, SNS, 콘텐츠 캘린더, 브랜드 보이스) |
| `/cto-advisor` | CTO급 전략 가이던스: 기술 부채 분석, 팀 스케일링, ADR 템플릿, DORA 메트릭 |
| `/product-manager-toolkit` | PM 프레임워크: RICE 우선순위, 인터뷰 NLP 분석, PRD 템플릿, DORA 메트릭 |

### 정부과제

정부과제 작성 스킬은 **프로젝트 스킬**로 운영됩니다(전역 아님). 과제마다 작성요령·양식·톤이 달라 프로젝트별 커스터마이즈가 필수이므로, 새 과제 착수 시 `forge-outputs/09-grants/{project}/.claude/skills/` 아래에 스캐폴드합니다.

| 커맨드 / 스킬 | 스코프 | 설명 |
|---------------|--------|------|
| `/grants` | 전역 (라우터) | 프로젝트의 로컬 grants 스킬로 디스패치하는 라우터 커맨드 |
| `/grants-status` | 전역 | 과제 진행 현황 확인 (프로젝트 전반) |
| `/rd-plan` | 전역 | R&D 정부과제 사업계획서 생성 파이프라인 — 목차·다이어그램·차트 자동 |
| `grants-write` (스킬) | **프로젝트** | 분석관→전략관→작성관 파이프라인. `{project}/.claude/skills/grants-write/` 위치 |
| `grants-review` (스킬) | **프로젝트** | 5축 자동 검수 (작성요령/데이터/평가위원/톤/방향성). `{project}/.claude/skills/grants-review/` 위치 |

### 문서 & 에셋

| 스킬 | 설명 |
|------|------|
| `/pptx` | PowerPoint(.pptx) 파일 생성, 읽기, 편집, 변환 |
| `/docx` | Word(.docx) 파일 생성, 읽기, 편집, 변환 |
| `/pdf` | PDF 읽기, 병합, 분할, 회전, 워터마크, OCR 처리 |
| `/xlsx` | 스프레드시트(.xlsx, .csv, .tsv) 생성, 읽기, 편집, 정리 |
| `/hwp2pdf` | HWP 파일 → PDF 변환 (이미지/표/도형 100% 보존) |
| `/generate-image` | AI 이미지 생성 (NanoBanana/FLUX/Gemini/Replicate) |
| `/sync-todo` | todo.md 작업을 Notion에 동기화 |
| `/meeting` | 미팅 내용 구조화 및 핵심 결정사항 추출 → forge-outputs에 저장 |

### 디자인 & 프론트엔드

| 스킬 | 설명 |
|------|------|
| `/frontend-design` | 프로덕션급 프론트엔드 인터페이스 생성 (React, Tailwind, shadcn/ui) |
| `/web-artifacts-builder` | 상태 관리와 라우팅이 포함된 복합 HTML 아티팩트 구축 |
| `/ux-audit` | UX 품질 9항목 감사 (색상 대비, 폰트, 터치 타겟, 레이아웃, 네비게이션, 3-상태, 반응형, 접근성). Check 3.6에서 자동 실행 |
| `/ux-copy` | UX 라이팅: 마이크로카피, 에러 메시지, 버튼 레이블, 빈 상태 텍스트, 툴팁, 온보딩 문구 |
| `/react-best-practices` | React/Next.js 성능 최적화 57룰 (8개 카테고리) |
| `/theme-factory` | 슬라이드/문서/HTML 페이지에 시각 테마 적용 또는 신규 생성 (10개 프리셋) |
| `/screenshot-analyze` | Gemini Vision으로 게임/웹/앱 스크린샷 분석 — UI 구조, 컬러 팔레트, 구현 가이드 생성 |
| `/user-research` | 사용자 리서치 계획·수행·종합: 인터뷰 가이드, 사용성 테스트, 설문 설계, 리서치 질문 |
| `/research-synthesis` | 리서치 데이터(인터뷰, 설문, NPS, 지원 티켓)를 테마·인사이트·추천사항으로 종합 |
| `/design-system-management` | 디자인 토큰, 컴포넌트 라이브러리, 패턴 문서 관리 |
| `/design-handoff` | 디자인 → 개발자 핸드오프 문서 생성 (구현 스펙, 측정값, 동작 노트) |
| `/design-critique` | 사용성·시각 계층·일관성·디자인 원칙 기준 디자인 평가 |

### 게임 개발

| 스킬 | 설명 |
|------|------|
| `/game-asset-generate` | 게임 에셋 대량 생산 오케스트레이터 (스프라이트, VFX, 배경, 3D, UI, 오디오) — Library-First + Soul 프롬프트 |
| `/game-qa` | 게임 연출/UI 3계층 QA: 파라미터 검증, 런타임 캡처 비교, Human 필요 항목 리스트업 |
| `/game-logic-visualize` | 게임 로직 시각화 (FSM, 확률 테이블, 전투 공식, 스킬 트리) → Mermaid/Draw.io/HTML 시뮬레이터 |
| `/game-reference-collect` | 경쟁작/레퍼런스 게임 시각 자료 체계적 수집·분석 (영상, 스크린샷, 로직) |
| `/style-train` | 기존 에셋 5-10개에서 스타일 추출 → style-guide.md 생성 또는 Replicate LoRA 파인튜닝 오케스트레이션 |
| `/soul-prompt-craft` | 12요소 Soul-Injected 이미지 생성 프롬프트 조립 — 모델별 최적 포맷(FLUX/Gemini/Replicate) 변환 |
| `/asset-critic` | AI 생성 에셋 6축 정량 평가 (5점 척도 루브릭) — 에셋 승인/거부 의사결정 지원 |
| `/video-reference-guide` | 게임 영상 프레임 분석 (Gemini) → 연출/이펙트 구현 가이드 생성 |

### 스킬 & 에이전트 관리

| 스킬 | 설명 |
|------|------|
| `/skill-creator` | 새 스킬 생성 또는 기존 스킬 업데이트 가이드 |
| `/skill-autoresearch` | 스킬 품질 자동 측정 및 개선 파이프라인 |
| `/hook-creator` | Claude Code 훅 생성 및 설정 (PreToolUse, PostToolUse, SessionStart 등) |
| `/subagent-creator` | 커스텀 시스템 프롬프트를 가진 전문 서브에이전트 생성 |
| `/slash-command-creator` | Claude Code 슬래시 커맨드 생성 가이드 |
| `/code-quality-rules` | 정적 훅이 잡지 못하는 의미론적 코드 품질 이슈 탐지 (로직, 아키텍처, UX) |
| `/library-search` | 에셋 생성 전 Prefab Visual Library에서 기존 에셋 검색 (비용 절감) |

## 자동화 훅 (7개)

| 훅 | 트리거 | 역할 |
|----|--------|------|
| `block-env-edit.sh` | PreToolUse | 민감 파일 편집 차단 |
| `load-learnings.sh` | SessionStart | 이전 학습 자동 로드 |
| `log-bash-commands.sh` | PostToolUse | Bash 명령 로깅 |
| `session-count-check.sh` | SessionStart | 멀티세션 충돌 경고 |
| `cleanup-zombie-sessions.sh` | SessionStart | 좀비 세션 정리 |
| `claude-notify.sh` | 완료 이벤트 | 작업 완료 알림 |
| `telegram-remote-control.sh` | 텔레그램 메시지 | 원격 세션 제어 |

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

## 커스터마이징

### 프로젝트 추가

`forge-workspace.json`에 추가:

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
vim planning/rules-source/always/my-rule.md
bash shared/scripts/manage-rules.sh build
```

## Public vs Private

| 구분 | 상태 | 내용 |
|------|:----:|------|
| **PUBLIC** | tracked | agents, skills, commands, hooks, rules, templates, scripts |
| **PRIVATE** | gitignored | forge-workspace.json, .mcp.json, .env, 프로젝트 산출물 |

산출물은 별도 private repo (`forge-outputs`)에서 관리합니다.

## 선택적 컴포넌트 설치

일부 스킬은 기본 설치 외에 추가 설치가 필요합니다.

### RAG 검색 (`/rag-search`)

forge-outputs 문서에서 하이브리드 벡터+BM25 의미 기반 검색. OpenAI 임베딩 사용.
→ **[상세 설치 가이드](shared/docs/2026-04-10-setup-rag.md)**

```bash
# 1. Python 패키지 설치
pip install -r ~/forge/shared/scripts/rag/requirements.txt

# 2. (선택) OCR 지원 — 스캔 문서 텍스트 추출용
sudo apt install tesseract-ocr tesseract-ocr-kor

# 3. ~/forge/.env에 OPENAI_API_KEY 설정 확인
#    text-embedding-3-small 임베딩에 사용됨

# 4. 인덱스 빌드 (최초 1회, 문서 추가 시 재실행)
bash ~/forge/shared/scripts/rag/setup.sh ~/forge-outputs/09-grants

# Claude Code에서 사용:
# /rag-search 플랫폼 프랜차이즈 전략
```

> forge-outputs에 새 문서가 추가될 때마다 `setup.sh` 재실행 필요.

---

### OpenSpace (`/delegate-task`, `/skill-discovery`)

HKUDS의 스킬 자동 진화 프레임워크. 백그라운드에서 동작하며 별도 조작 불필요.
→ **[상세 설치 가이드](shared/docs/2026-04-10-setup-openspace.md)**

```bash
# 1. uv 설치 (없으면)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Python 3.12 설치
uv python install 3.12

# 3. OpenSpace 클론 + 설치
cd ~
git clone https://github.com/HKUDS/OpenSpace.git
cd OpenSpace
uv venv --python 3.12 .venv
source .venv/bin/activate
uv pip install pydantic-settings==2.13.0
uv pip install -e .

# 4. 설치 확인
python -c "import openspace; print('OK')"
openspace-mcp --help

# 5. API 키 설정
echo "ANTHROPIC_API_KEY=본인키입력" > ~/OpenSpace/openspace/.env
# 또는 forge .env에서 복사:
grep ANTHROPIC_API_KEY ~/forge/.env > ~/OpenSpace/openspace/.env

# 6. ~/forge/.mcp.json에 추가
# {
#   "mcpServers": {
#     "openspace": {
#       "command": "/home/<유저명>/OpenSpace/.venv/bin/openspace-mcp",
#       "toolTimeout": 600,
#       "env": {
#         "OPENSPACE_HOST_SKILL_DIRS": "/home/<유저명>/forge/.claude/skills",
#         "OPENSPACE_WORKSPACE": "/home/<유저명>/OpenSpace"
#       }
#     }
#   }
# }

# 7. 호스트 스킬 복사
cp -r ~/OpenSpace/openspace/host_skills/delegate-task/ ~/forge/.claude/skills/
cp -r ~/OpenSpace/openspace/host_skills/skill-discovery/ ~/forge/.claude/skills/

# 8. Claude Code 재시작 (/clear) — delegate-task, skill-discovery 스킬 활성화
```

| 스킬 | 트리거 |
|------|--------|
| `delegate-task` | 복잡한 작업에서 수동 또는 자동 위임 |
| `skill-discovery` | 스킬 품질 자동 모니터링 |

**트러블슈팅**

| 문제 | 해결 |
|------|------|
| `Python 3.12 not found` | `uv python install 3.12` 재실행 |
| `pydantic_settings 설치 실패` | `uv pip install pydantic-settings==2.13.0` 먼저 실행 |
| RAG `OPENAI_API_KEY 미설정` | `~/forge/.env` 키 확인 |
| OpenSpace MCP 연결 안 됨 | `/clear` 후 재시작. `.mcp.json` 경로 확인 |
| `openspace-mcp: command not found` | `source ~/OpenSpace/.venv/bin/activate` 확인 |

---

### Obsidian 지식 위키 (`/wiki-sync`)

Andrej Karpathy의 [LLM Wiki 패턴](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)을 Claude Code + Obsidian으로 구현한 **compounding 지식 베이스**. Raw 소스(리서치, 영상 분석, 일간/주간 리포트)를 AI가 추출하여 Obsidian vault의 영구 노트로 Human 승인 후 병합합니다. WSL ↔ Obsidian 양방향 동기화, LightRAG 자동 재인덱싱, Git을 통한 모바일 접근을 지원합니다.

**아키텍처 (3-layer):**

```
Raw (forge-outputs/01-research/) → Wiki (forge-vault/concepts,tools,topics,people/) → Meta (_meta/MOC.md, questions.md)
```

```bash
# 1. Obsidian 데스크톱 설치
#    https://obsidian.md  →  "Open folder as Vault"  →  /mnt/e/forge-vault 선택
#    (WSL 사용자는 E:\forge-vault 권장, Linux는 임의 경로 가능)

# 2. Vault 레포 클론 (GitHub 공개 미러)
git clone git@github.com:moongci38-oss/forge-vault.git /mnt/e/forge-vault

# 3. forge-outputs 미러 확인
ls ~/forge-outputs/20-wiki/
# → CLAUDE.md, README.md, concepts/, tools/, topics/, people/, _meta/

# 4. 동기화 watcher 시작 (양방향 rsync + 30초 디바운스 LightRAG 재인덱싱 + 5분 자동 git push)
bash ~/forge/shared/scripts/wiki-sync.sh --watch
# 로그: /tmp/wiki-sync.log, /tmp/wiki-index.log, /tmp/wiki-push.log
# 일회성 동기화 (watcher 없음): bash ~/forge/shared/scripts/wiki-sync.sh

# 5. (선택) systemd/tmux로 상시 동작 서비스 등록
#    watch-mode 옵션은 shared/scripts/wiki-sync.sh 헤더 참조

# 6. LightRAG wiki 인덱스 최초 빌드
python3 ~/forge/shared/scripts/lightrag-pilot.py index --context wiki

# 7. 자연어 쿼리
python3 ~/forge/shared/scripts/lightrag-pilot.py query "하네스 엔지니어링이 뭐야" hybrid --context wiki
```

**Claude Code에서 사용:**

```
/wiki-sync                           # 신규 Raw 문서 스캔 → 위키 업데이트 제안 → Human 승인 → 반영 + 재인덱싱
/rag-search --context wiki {질의}     # 위키만 의미 검색
```

**건강 검진 (매월 1일 09:00 KST 자동):**

```bash
python3 ~/forge/shared/scripts/wiki-sync-lint.py      # 미승격 Raw 카운트
python3 ~/forge/shared/scripts/wiki-health-lint.py    # broken/orphan/stub 리포트
```

| 파일 | 역할 |
|------|------|
| `forge-outputs/20-wiki/README.md` | Vault 개요 + Karpathy 3-layer 원칙 |
| `forge-outputs/20-wiki/CLAUDE.md` | Schema (AI 유지보수 규칙, 자동 로드) |
| `forge-outputs/20-wiki/_meta/context.md` | 사업 맥락 (Track A/B/C) — 모든 노트 callout 기준 |
| `forge-outputs/20-wiki/_meta/index.md` | 콘텐츠 카탈로그 (카테고리별 전체 노트) |
| `~/forge/.claude/skills/wiki-sync/SKILL.md` | 5단계 워크플로우 (Scan → Read → Match → Propose → Apply) |
| `~/forge/shared/scripts/wiki-sync.sh` | 양방향 rsync watcher (vault ↔ 20-wiki) |
| `~/forge/shared/scripts/wiki-build-index.py` | 콘텐츠 카탈로그 빌더 |
| `~/forge/shared/scripts/wiki-fix-dangling-refs.py` | 깨진 `[[위키링크]]` 수리 |

> 모바일: Obsidian 앱 설치 → https://github.com/moongci38-oss/forge-vault 에서 pull. Git 플러그인이 주기적 자동 pull 처리.

---

### hwpx 도구 (HWP 양식 자동 채우기)

정부과제 HWP 양식 파일을 프로그래매틱하게 채우는 도구.

```bash
# hwpx MCP 서버 설치
pip install hwpx-mcp-server

# ~/forge/.mcp.json에 추가:
# {
#   "mcpServers": {
#     "hwpx": {
#       "type": "stdio",
#       "command": "/home/<유저명>/.local/bin/hwpx-mcp-server",
#       "args": ["--stdio"]
#     }
#   }
# }
```

---

## Prefab Visual Library

```bash
git clone git@github.com:moongci38-oss/prefab-visual-library.git ~/prefab-visual-library
```

`forge-workspace.json`의 `prefabLibraryRoot`에서 경로를 참조합니다. `/library-search`로 기존 에셋을 먼저 검색하여 생성 비용을 절감합니다.

## 라이선스

MIT
