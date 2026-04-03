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

## 설치 경로 (CRITICAL - 외부 사용자)

Forge를 외부에서 클론할 때:

```bash
# 홈 디렉토리에 forge 클론
git clone https://git.lumir-ai.com/lumir/forge ~/forge

# 또는 다른 경로에 클론 후 환경변수 설정
git clone https://git.lumir-ai.com/lumir/forge /custom/path/forge
export FORGE_ROOT=/custom/path/forge
export FORGE_OUTPUTS=/custom/path/forge-outputs
```

**중요**: 모든 Forge 커맨드/스킬은 `FORGE_ROOT` 환경변수를 기본값 `~/forge`로 사용합니다. 다른 경로를 사용하면 `FORGE_ROOT`를 명시적으로 설정해야 합니다.

## 커맨드 실행 모드 (HIGH)

Forge 커맨드/스킬은 **쓰기 모드에서 실행**해야 한다. 내부 [STOP] 게이트가 인간 승인 지점 역할을 하므로 plan mode가 별도로 필요 없다.

### Plan Mode 감지 규칙

멀티 Phase 커맨드(`/forge`, `/sdd`, `/pge`, `/grants`, `/prd`, `/gdd`, `/forge-fix`, `/forge-deploy`, `/forge-release`, `/rd-plan` 등) 실행 시:

1. Claude가 현재 plan mode(도구 사용이 제한된 상태)임을 인식하면:
   ```
   [STOP] 이 커맨드는 쓰기 모드에서 실행해야 합니다.
   Escape로 plan mode를 해제하거나 "쓰기 모드로 전환"을 요청한 후 재실행하세요.
   이 커맨드의 내부 [STOP] 게이트가 승인 지점 역할을 합니다.
   ```
2. 경고를 출력한 후 **즉시 중단**한다. Plan mode에서 부분 실행하지 않는다.

### 모드 구분

| 상황 | 모드 |
|------|------|
| `/forge`, `/sdd`, `/pge`, `/grants-write` 등 커맨드 | 쓰기 모드 필수 |
| `"이 부분 수정해줘"` 등 직접 파일 수정 요청 | plan mode 권장 |
| 파일 탐색·조회·읽기만 | 어느 모드든 무관 |

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

## 하네스 설계 원칙 (MEDIUM)

> AI 출력 품질의 핵심 변수는 모델이 아니라 **구조(하네스)**다.

### Planner-Generator-Evaluator 분해 기준

업무를 3개 역할로 분해한다:

| 역할 | 책임 | 에이전트 모델 |
|------|------|:----------:|
| **Planner** | 요구사항 분석, 작업 분해, 실행 계획 수립 | Opus 4.6 |
| **Generator** | 계획에 따른 실제 구현/생성 | Sonnet 4.6 |
| **Evaluator** | 산출물 품질 검증, Rubric 기준 판정 | Sonnet 4.6 |

**분해 트리거**: 산출물 품질이 결과를 결정하는 작업 (코드 기능 구현, 문서 작성, 기획서 초안 등)

**분해 불필요**: 단순 정보 조회, 파일 탐색, 1회성 수정

### 자기평가 분리 원칙

- Generator가 자신의 산출물을 Evaluator로서 평가하지 않는다
- 평가는 별도 에이전트(또는 별도 세션)가 수행한다
- hooks, qa 스킬, code-reviewer 에이전트가 이 원칙의 구현체

### 평가기준표(Rubric) 명시 원칙

- Evaluator가 사용할 평가 기준을 Generator 실행 **전**에 명시한다
- 기준이 모호하면 Generator 결과물도 모호해진다
- qa 스킬의 Rubric(기능성 40%/코드품질 30%/아키텍처 20%/문서 10%)이 표준 기준
- **"museum quality"** — 라이브러리 기본값·AI 슬롭 패턴을 명시적으로 불합격 처리하는 구체적 언어를 Rubric에 포함한다

### 하네스 설계 핵심 원칙 (Anthropic 공식)

> "하네스의 모든 컴포넌트는 모델이 혼자 할 수 없는 것에 대한 가정을 인코딩한다."
> — Anthropic Engineering Blog, 2026-03-24

- 하네스를 설계할 때는 "모델이 이것을 스스로 할 수 없는가?"를 먼저 질문한다
- 필요 없는 컴포넌트는 추가하지 않는다 (하네스 복잡도 = 유지보수 비용)
- Evaluator 판단이 인간 판단과 다르면 Rubric을 반복 보정한다 (calibration loop)

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
