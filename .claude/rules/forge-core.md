# Forge Core Rules (Passive Summary)

> 점진적 로딩: Passive 요약 (~1,500 토큰). 상세 규칙은 해당 작업 시 Deep 로딩.
> Deep 원본: `planning/rules-source/always/` + `shared/cross-project/`
> 수동 관리 파일 — manage-rules.sh build가 덮어쓰지 않음

---

## 산출물 경로 (CRITICAL)

- forge/ = 시스템 / forge-outputs/ (`~/forge-outputs/`) = 결과물
- `forge-outputs/`는 forge/의 **형제 폴더**. CWD 상대경로 사용 금지.

> Iron Laws 전체: `pipeline.md` §Iron Laws (Single Source of Truth)

## 보안 (CRITICAL)

- 민감 정보 커밋 금지, 06-finance/07-legal/08-admin 외부 출력 금지, 하드코딩 시크릿 금지
- 읽기 금지: `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/`, `.ssh/`, `.aws/`, `.env*`
- 시스템 경로 보호: `forge/dev/`, `~/.claude/rules/`, `~/.claude/scripts/` 삭제/이동 금지

> Iron Laws (SECURITY-IRON-1~4): `pipeline.md` §Iron Laws

### MCP 설정 경로
- 프로젝트: `프로젝트루트/.mcp.json` | 전역: `~/.claude.json` 내 mcpServers
- `~/.claude/.mcp.json`은 인식 안 됨 — 사용 금지

> Deep: `planning/rules-source/always/security.md`

---

## Git (HIGH)

- Conventional Commits: feat/fix/docs/style/refactor/test/chore
- 브랜치: main(프로덕션), feature/*, fix/*
- Squash merge 전용, PR 필수
- AI 커밋: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- main 직접 커밋/force push 금지, .env 커밋 금지, --no-verify 금지

> Deep: `planning/rules-source/always/git.md`

---

## 병렬 실행 (HIGH)

> Iron Laws (PARALLEL-IRON-1~2): `pipeline.md` §Iron Laws

### 도구 선택
- 독립 병렬 작업 → **Subagent** (기본) | 에이전트 간 소통/비교 → **Agent Teams** (특수)
- 모델: Lead→Opus 4.6 | 구현/작성→Sonnet 4.6 | 탐색/검색→Haiku 4.5
- Worktree: 같은 파일 병렬 수정 시 `isolation: "worktree"` 사용
- Wave 기반: 선행 완료 후 다음 Wave 스폰

> Deep: `shared/cross-project/agent-teams.md` (Agent Teams 상세)

---

## PM 도구 / Notion (HIGH)

- **Notion Tasks = 유일한 Source of Truth** (todo.md는 초기 등록용만)
- Notion Tasks: Dev 이벤트(브랜치/Check3/PR)에 상태 자동 전환
- Human override 우선: `last_edited_by=person`이고 상태 불일치 시 AI가 덮어쓰기 금지
- 버그/기능 등록: **명시적 요청**("등록해줘") 시에만. 단순 언급은 트리거 아님
- Hotfix: P0-긴급 강제, Projects DB 연결 필수
- DB URL: `forge-workspace.json`의 `notionDBs`에서 참조 (하드코딩 금지)

> Deep: `planning/rules-source/always/pm-tools.md`

---

## 파일명 규칙 (MEDIUM)

- 기본: `{YYYY-MM-DD}-{description}.{ext}`
- 폴더별 상세 규칙은 Deep 참조

> Deep: `planning/rules-source/always/file-naming.md`

## 리서치 방법론 (MEDIUM)

- 경쟁 가설 2개 이상, 출처 다중 검증, 신뢰도 등급(High/Medium/Low) 표기 필수
- 수치: 범위 우선, 예측은 출처 기관+발표일 필수

> Deep: `planning/rules-source/always/research-methodology.md`

## 콘텐츠 품질 (MEDIUM)

- AI 생성 → 사실 검증 → 품질 체크 → Human 확인 → 발행
- 블로그: SEO 75+, H2 3개+, 출처 URL+날짜 필수
- 과장 수식어("혁신적", "최고의") 근거 없이 사용 금지

> Deep: `planning/rules-source/always/content-quality.md`

## Cowork 환경 (MEDIUM)

- MCP→내장 도구 매핑: filesystem→Read/Write, playwright→WebFetch, sequential-thinking→Task
- 기술 용어 대신 일반 용어, 병렬 작업 자동 판단

> Deep: `planning/rules-source/always/cowork-environment.md`

## MCP vs CLI (MEDIUM)

- 멀티스텝/함수호출 → MCP | 단일명령/고빈도 → CLI
- 고빈도 단순 작업에 MCP 사용 중이면 CLI 전환 검토
- 혼합 도구: Sentry(`sentry-cli`=릴리스/CI, MCP=이슈조회), Lighthouse(`lighthouse`=배치감사, MCP=인터랙티브), Brave Search(`curl`=스크립트, MCP=대화내검색)
- CLI+MCP 선택: 스크립트/자동화/CI→CLI | 대화내 인터랙티브→MCP

> Deep: `planning/rules-source/always/mcp-vs-cli.md`

## 리소스 생성 (MEDIUM)

- Diamond Architecture: P0(스타일)→P1(방향)→P2(프로토)→P3(대량)→P4(검증)
- style-guide.md 없이 대량 생성 금지, T1(핵심 브랜딩) AI 자율 생성 금지
- 1장씩 순차 생성 + Human 피드백

> Deep: `planning/rules-source/always/resource-generation.md`

## 크로스 프로젝트 (MEDIUM)

- forge-outputs/`10-operations/` 폴더가 Forge ↔ 개발 프로젝트 허브
- Forge에서만 handoff-to-dev 작성, 개발에서만 handoff-from-dev 작성

> Deep: `shared/cross-project/cross-project-pipeline.md`

## 스킬 생성 (LOW)

- skill-creator 플러그인 기본, writing-skills 병용

> Deep: `shared/cross-project/skill-creation.md`

---

## 세션 관리 (MEDIUM)

- **/clear 사용 기준**: 새 작업 시작 시, AI 이상 동작(반복/무한루프/엉뚱한 응답) 시
- **멀티세션 감지**: SessionStart 훅이 2시간 내 활성 세션 3개+ 감지 시 경고 출력
- **learnings 참조**: 프로젝트에 `.claude/learnings.jsonl` 있으면 세션 시작 시 최근 항목 로드
- **/learn**: 새 패턴/해결법 발견 시 저장 제안, 같은 실수 반복 시 검색

### 장시간 서브에이전트 실행 워크플로우

장시간 에이전트 작업 중 요구사항 변경이 필요한 경우 tmux 이중 pane 패턴을 사용한다:

- **실행 pane**: 서브에이전트 자율 실행 중 — 중단하지 않음
- **대화 pane**: 진행 중 요구사항 변경 논의 → 파일로 저장 → 에이전트 완료 후 반영

컨텍스트 오염 없이 피드백을 전달할 때는 변경 사항을 파일에 기록하고 에이전트가 디스크에서 읽도록 한다.

### 서브에이전트 비용 관리

대규모 서브에이전트 스폰 전 작업 범위를 먼저 확인한다. 예상 범위가 불명확하면 소규모 파일럿 실행 후 확장한다.

---

## Deep 로딩 라우팅

| 작업 컨텍스트 | Deep 로드 대상 |
|-------------|---------------|
| 보안/민감 파일 접근 | `always/security.md` |
| Git 커밋/브랜치/PR | `always/git.md` |
| 병렬 작업/서브에이전트 | `cross-project/agent-teams.md` |
| Notion/PM 도구 | `always/pm-tools.md` |
| 파일 생성/명명 | `always/file-naming.md` |
| 리서치 실행 | `always/research-methodology.md` |
| 콘텐츠 작성 | `always/content-quality.md` |
| Cowork 세션 | `always/cowork-environment.md` |
| MCP/CLI 도구 선택 | `always/mcp-vs-cli.md` |
| 에셋/이미지 생성 | `always/resource-generation.md` |
| 크로스 프로젝트 | `cross-project/cross-project-pipeline.md` |
| 스킬 생성 | `cross-project/skill-creation.md` |

Deep 원본 경로: `planning/rules-source/{scope}/{filename}` 또는 `shared/{scope}/{filename}`
