# Business Core Rules (Passive Summary)

> 점진적 로딩: Passive 요약 (~1,500 토큰). 상세 규칙은 해당 작업 시 Deep 로딩.
> Deep 원본: `09-tools/rules-source/always/` + `09-tools/rules-source/cross-project/`
> 수동 관리 파일 — manage-rules.sh build가 덮어쓰지 않음

---

## 보안 (CRITICAL)

### Iron Laws
- **SECURITY-IRON-1**: 민감 정보(.env, credentials, API 키) 절대 커밋 금지
- **SECURITY-IRON-2**: 06-finance/, 07-legal/, 08-admin/ 내용 외부 출력 금지
- **SECURITY-IRON-3**: 하드코딩 시크릿 코드 포함 금지
- **SECURITY-IRON-4**: `~/.claude/trine/`, `~/.claude/rules/`, `~/.claude/scripts/` 삭제/이동/덮어쓰기 금지

### 읽기 금지 영역
- `06-finance/`, `07-legal/`, `08-admin/insurance/`, `08-admin/freelancers/`, `.ssh/`, `.aws/`, `.env*`

### MCP 설정 경로
- 프로젝트: `프로젝트루트/.mcp.json` | 전역: `~/.claude.json` 내 mcpServers
- `~/.claude/.mcp.json`은 인식 안 됨 — 사용 금지

> Deep: `09-tools/rules-source/always/security.md`

---

## Git (HIGH)

- Conventional Commits: feat/fix/docs/style/refactor/test/chore
- 브랜치: main(프로덕션), feature/*, fix/*
- Squash merge 전용, PR 필수
- AI 커밋: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- main 직접 커밋/force push 금지, .env 커밋 금지, --no-verify 금지

> Deep: `09-tools/rules-source/always/git.md`

---

## 병렬 실행 (HIGH)

### Iron Laws
- **PARALLEL-IRON-1**: 파일 소유권 미선언 상태로 병렬 작업 금지
- **PARALLEL-IRON-2**: 의존성 있는 태스크 동시 스폰 금지

### 도구 선택
- 독립 병렬 작업 → **Subagent** (기본) | 에이전트 간 소통/비교 → **Agent Teams** (특수)
- 모델: Lead→Opus 4.6 | 구현/작성→Sonnet 4.6 | 탐색/검색→Haiku 4.5
- Worktree: 같은 파일 병렬 수정 시 `isolation: "worktree"` 사용
- Wave 기반: 선행 완료 후 다음 Wave 스폰

> Deep: `09-tools/rules-source/cross-project/agent-teams.md` (Agent Teams 상세)
> Deep: `09-tools/rules-source/always/parallel-execution.md` — **※ 현재 always/ 소스에 없음, cross-project/ 참조**

---

## PM 도구 / Notion (HIGH)

- Notion Tasks: Trine 이벤트(브랜치/Check3/PR)에 상태 자동 전환
- Human override 우선: `등록자=Human` 또는 `last_edited_by=Human` 시 AI가 상태 덮어쓰기 금지
- 버그/기능 등록: **명시적 요청**("등록해줘") 시에만. 단순 언급은 트리거 아님
- Hotfix: P0-긴급 강제, Projects DB 연결 필수
- Source of Truth: `docs/planning/active/sigil/todo.md` (Notion은 대시보드용)
- Notion MCP 미연결 시 Tier 2 Fallback (todo.md만)
- DB URL: `sigil-workspace.json`의 `notionDBs`에서 참조 (하드코딩 금지)

> Deep: `09-tools/rules-source/always/pm-tools.md`

---

## 파일명 규칙 (MEDIUM)

- 기본: `{YYYY-MM-DD}-{description}.{ext}`
- 폴더별 상세 규칙은 Deep 참조

> Deep: `09-tools/rules-source/always/file-naming.md`

## 리서치 방법론 (MEDIUM)

- 경쟁 가설 2개 이상, 출처 다중 검증, 신뢰도 등급(High/Medium/Low) 표기 필수
- 수치: 범위 우선, 예측은 출처 기관+발표일 필수

> Deep: `09-tools/rules-source/always/research-methodology.md`

## 콘텐츠 품질 (MEDIUM)

- AI 생성 → 사실 검증 → 품질 체크 → Human 확인 → 발행
- 블로그: SEO 75+, H2 3개+, 출처 URL+날짜 필수
- 과장 수식어("혁신적", "최고의") 근거 없이 사용 금지

> Deep: `09-tools/rules-source/always/content-quality.md`

## Cowork 환경 (MEDIUM)

- MCP→내장 도구 매핑: filesystem→Read/Write, playwright→WebFetch, sequential-thinking→Task
- 기술 용어 대신 일반 용어, 병렬 작업 자동 판단

> Deep: `09-tools/rules-source/always/cowork-environment.md`

## MCP vs CLI (MEDIUM)

- 멀티스텝/함수호출 → MCP | 단일명령/고빈도 → CLI
- 고빈도 단순 작업에 MCP 사용 중이면 CLI 전환 검토

> Deep: `09-tools/rules-source/always/mcp-vs-cli.md`

## 리소스 생성 (MEDIUM)

- Diamond Architecture: P0(스타일)→P1(방향)→P2(프로토)→P3(대량)→P4(검증)
- style-guide.md 없이 대량 생성 금지, T1(핵심 브랜딩) AI 자율 생성 금지
- 1장씩 순차 생성 + Human 피드백

> Deep: `09-tools/rules-source/always/resource-generation.md`

## 크로스 프로젝트 (MEDIUM)

- `10-operations/` 폴더가 BUSINESS ↔ 개발 프로젝트 허브
- BUSINESS에서만 handoff-to-dev 작성, 개발에서만 handoff-from-dev 작성

> Deep: `09-tools/rules-source/cross-project/cross-project-pipeline.md`

## 스킬 생성 (LOW)

- skill-creator 플러그인 기본, writing-skills 병용

> Deep: `09-tools/rules-source/cross-project/skill-creation.md`

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

Deep 원본 경로: `09-tools/rules-source/{scope}/{filename}`
