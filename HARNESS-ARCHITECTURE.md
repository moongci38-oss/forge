# Forge Harness Architecture

> **Harness = CLAUDE.md (컨텍스트) + hooks (자동화) + skills (도구) + eval loops (검증)**
> 모든 컴포넌트는 아래 3축 중 하나 이상에 속한다.

```
┌─────────────────────────────────────────────────────────────┐
│                      3-AXIS HARNESS                         │
│                                                             │
│  [Context Axis]     [Tool Axis]      [Evaluation Axis]      │
│  무엇을 알고 있나   무엇을 할 수 있나  올바르게 했나          │
│                                                             │
│  CLAUDE.md          skills/          agents/               │
│  rules/             hooks/           canary                 │
│  memory/            MCP servers      spec-compliance        │
│  session-context    settings.json    audit-harness          │
└─────────────────────────────────────────────────────────────┘
```

---

## Axis 1: Context (무엇을 알고 있나)

세션 시작 시 Claude에게 주입되는 지식 레이어.

### CLAUDE.md 계단식 로드 (Cascade)

```
~/.claude/rules/                       ← 전역 규칙 (항상 로드)
~/CLAUDE.md                            ← 워크스페이스 루트
~/forge/CLAUDE.md                      ← Forge 파이프라인 원칙
~/forge/.claude/rules/                 ← Forge 전용 규칙
  ├── forge-core.md                    (Iron Laws, 8-Check 체인)
  ├── opus-4-7-best-practices.md       (모델별 행동)
  ├── success-is-silent.md             (출력 억제 규칙)
  ├── web-search-policy.md             (검색 도구 우선순위)
  ├── agent-response-format.md
  ├── autonomy-levels.md
  ├── dev-oss-security-baseline.md
  ├── forge-planning.md
  ├── plan-mode.md
  └── telegram-remote-control.md
~/.claude/rules/                       ← 사용자 전역
  ├── success-is-silent.md             (forge와 동기화)
  └── web-search-policy.md             (forge와 동기화)
```

### Memory (장기 기억)

```
~/.claude/projects/{project-hash}/memory/
  ├── MEMORY.md                        ← 색인 (200줄 제한, 항상 로드)
  ├── user_*.md                        ← 사용자 프로필
  ├── feedback_*.md                    ← 행동 교정 기록
  ├── project_*.md                     ← 프로젝트 상태
  └── reference_*.md                   ← 외부 시스템 포인터

~/forge/.claude/memory/learnings.jsonl ← 패턴 학습 (auto-learn-save.sh 기록)
```

### Session Context (휘발성)

```
SessionStart 훅 체인:
  cleanup-zombie-sessions.sh  → 좀비 프로세스 정리
  session-count-check.sh      → 멀티세션 경고
  load-learnings.sh           → learnings.jsonl → 컨텍스트 주입
  session-context.sh          → 현재 Git 브랜치·Gate 상태 주입
  telegram-remote-control.sh  → 원격 제어 채널 활성화
```

---

## Axis 2: Tool (무엇을 할 수 있나)

Claude가 실제로 행동하는 레이어.

### Skills (고수준 도구)

```
~/.claude/skills/                      ← 전역 스킬 (모든 프로젝트)
~/forge/.claude/skills/               ← Forge 전용 스킬

핵심 스킬 카테고리:
  리서치:    article, yt, yt-analyze, weekly-research, rag-search
  개발:      skill-creator, hook-creator, github-actions-creator, playwright-cli
  분석:      audit-harness, audit-context, audit-agentic, audit-cost, audit-human-ai
  생성:      game-asset-generate, style-forge, theme-factory, web-artifacts-builder
  운영:      canary, daily-system-review, kaizen, pge
  기획:      autoplan, concise-planning, forge-planning-router, pre-mortem
  에이전트:  subagent-creator, delegate-task, skill-autoresearch
```

### Agents (전문 서브에이전트)

```
~/forge/.claude/agents/
  ├── axis-harness.md          ← 하네스 3축 성숙도 평가
  ├── axis-context.md          ← 컨텍스트 축 평가
  ├── axis-agentic.md          ← 에이전트 패턴 평가
  ├── canary-judge.md          ← 배포 전 회귀 판정
  ├── fact-checker.md          ← 주장 팩트체크
  ├── article-analyst.md       ← 기사 심층 분석
  ├── research-coordinator.md  ← 리서치 조율
  ├── yt-video-analyst.md      ← YouTube 영상 분석
  ├── trine-pm-updater.md      ← Trine 단계 전환 PM 업데이트
  ├── performance-checker.md
  ├── test-quality-checker.md
  └── ui-quality-checker.md
```

### MCP Servers (외부 도구 연동)

```
~/.claude.json → MCP 서버 레지스트리

  tavily           → 웹 검색 (tavily_search, tavily_research, tavily_extract)
  exa              → 시맨틱 검색
  brave-search     → 검색 fallback
  notion           → 지식 베이스 동기화
  telegram         → 메시지 발송/수신
  nano-banana      → 이미지 생성 (Gemini)
  replicate        → LoRA 학습
  ollama           → 로컬 LLM
  sequential-thinking → 구조적 추론
  context7         → 라이브러리 문서
  drawio           → 다이어그램
```

### Hooks — Tool Guards (PreToolUse)

실행 전 차단·검증 레이어:

```
PreToolUse (Edit|Write|Bash):
  block-env-edit.sh            → .env 수정 차단 (보안)
  block-sensitive-files.sh     → 민감 파일 보호
  block-sensitive-bash.sh      → 위험 bash 명령 차단
  detect-injection.sh          → 프롬프트 인젝션 탐지
  no-force-push.sh             → git push --force 차단
  require-date-prefix.sh       → 핸드오버 파일 날짜 접두사 강제
  check-supply-chain.sh        → npm/pip 공급망 검증
  owasp-asi-04-06-08-10.sh     → OWASP Agentic Top 10 (4·6·8·10번)
```

### Hooks — Tool Side Effects (PostToolUse)

실행 후 자동 처리 레이어:

```
PostToolUse (Bash):
  post-tool-use-offload.sh     → 대형 출력(>2000자) 아카이브 → Context Rot 방지
  log-bash-commands.sh         → ~/.claude/bash-history.log 기록
  log-tool-metrics.sh          → tool-metrics.jsonl + tool-failures.jsonl 기록
  git-commit-notify.sh         → 커밋 시 Telegram 알림
  playwright-on-commit.sh      → 커밋 시 Playwright 자동 검증 (조건부)

PostToolUse (Edit|Write):
  black --quiet                → Python 파일 자동 포맷
  demo-html-tracker.sh         → demo HTML 변경 추적

PostToolUse (auto-build-rules, auto-forge-sync, 100-line-rule, ...):  [forge .claude/settings.json]
  filter-log-output.sh         → 로그 필터링
  usage-logger.sh              → 사용량 기록
  agent-token-budget.sh        → 에이전트 토큰 예산 추적
  validate-output.sh           → 출력 형식 검증
  owasp-asi-04-06-08-10.sh     → 실행 후 OWASP 재검증
```

### Hooks — Session Lifecycle

```
SessionStart:
  cleanup-zombie-sessions.sh   → 좀비 정리
  session-count-check.sh       → 멀티세션 감지 경고
  load-learnings.sh            → 학습 패턴 주입

Stop (세션 종료):
  session-plan-save.sh         → 계획 파일로 강제 저장 (휘발 방지)
  demo-html-qa-reminder.sh     → demo HTML QA 체크리스트 리마인더
  claude-notify.sh             → 종료 알림 (forge: auto-learn-save, cleanup-plans, track-override-rate)
```

---

## Axis 3: Evaluation (올바르게 했나)

독립 검증 레이어 — **동일 세션·동일 모델 자체 평가 금지**.

### Harness Check Chain (8-Check)

```
forge/CLAUDE.md에 정의된 8단계 체인:
  Check 1: 계획 적합성
  Check 2: 보안 (OWASP ASI)
  Check 3: 성능
  Check 4: 출력 형식
  Check 5: 테스트 품질
  Check 6: UI/UX
  Check 7: 코드 품질
  Check 8: 배포 준비
```

### Evaluation Skills

```
~/.claude/skills/
  audit-harness/               → 4축 하네스 감사 (Check Chain + OWASP Agentic Top 10)
  audit-context/               → 컨텍스트 축 성숙도 점수
  audit-agentic/               → 에이전트 패턴 감사
  audit-cost/                  → 비용 효율 감사
  audit-human-ai/              → Human-AI 협업 패턴 감사
  canary/                      → 배포 전 회귀 탐지
  spec-compliance-checker/     → Spec 적합성 검증
  benchmark/                   → 성능 벤치마크
  qa/                          → 테스트 품질 검증
```

### Evaluation Agents

```
~/forge/.claude/agents/
  axis-harness.md              → CLEAR 프레임워크 + OTel + OWASP 성숙도 점수
  axis-context.md              → 컨텍스트 축 전문 평가
  canary-judge.md              → 배포 판정 (Pass/Fail)
  fact-checker.md              → 사실 검증
  test-quality-checker.md      → 테스트 커버리지 평가
  performance-checker.md       → API 성능 정적 분석
  ui-quality-checker.md        → Lighthouse/a11y 검증
```

### Runtime Eval Patterns

```
독립 Evaluator 패턴 (인라인):
  Agent(subagent_type="general-purpose") {
    "당신은 독립 검증자입니다. 이 산출물을 평가하세요..."
  }

  → PASS: 파이프라인 계속
  → FAIL: 지적 항목 보완 후 재실행 (1회 한도)
  → 2회 FAIL: [STOP] Human 에스컬레이션

Ralph Loop (CI 실패 자동 재시도):
  /ralph-loop "Fix all CI failures" \
    --completion-promise "The PR is merged and all checks are green"
```

---

## 컴포넌트 전체 맵

| 컴포넌트 | 파일 위치 | 축 | 이벤트/호출 시점 |
|---------|---------|:--:|---------------|
| CLAUDE.md cascade | `*/CLAUDE.md`, `*/rules/*.md` | Context | 세션 시작 자동 로드 |
| Memory index | `memory/MEMORY.md` | Context | 세션 시작 자동 로드 |
| learnings.jsonl | `forge/.claude/memory/` | Context | SessionStart > load-learnings.sh |
| session-context | `hooks/session-context.sh` | Context | SessionStart |
| Skills | `~/.claude/skills/`, `forge/.claude/skills/` | Tool | 사용자/오케스트레이터 호출 |
| Agents | `forge/.claude/agents/` | Tool + Eval | 스킬 내 Agent() 호출 |
| MCP Servers | `~/.claude.json` | Tool | 상시 연결 |
| block-env-edit | `hooks/block-env-edit.sh` | Tool Guard | PreToolUse:Edit|Write|Bash |
| detect-injection | `hooks/detect-injection.sh` | Tool Guard | PreToolUse:Bash |
| no-force-push | `hooks/no-force-push.sh` | Tool Guard | PreToolUse:Bash |
| owasp-asi (pre) | `hooks/owasp-asi-04-06-08-10.sh` | Tool Guard | PreToolUse |
| post-tool-offload | `~/.claude/hooks/post-tool-use-offload.sh` | Tool Effect | PostToolUse:Bash |
| log-tool-metrics | `~/.claude/hooks/log-tool-metrics.sh` | Tool Effect | PostToolUse:Bash |
| git-commit-notify | `hooks/git-commit-notify.sh` | Tool Effect | PostToolUse:Bash |
| validate-output | `hooks/validate-output.sh` | Eval | PostToolUse |
| owasp-asi (post) | `hooks/owasp-asi-04-06-08-10.sh` | Eval | PostToolUse |
| track-override-rate | `hooks/track-override-rate.sh` | Eval | Stop |
| auto-learn-save | `hooks/auto-learn-save.sh` | Context+Eval | Stop |
| session-plan-save | `~/.claude/hooks/session-plan-save.sh` | Context | Stop |
| audit-harness | `skills/audit-harness/` | Eval | 수동 또는 파이프라인 |
| canary | `skills/canary/` | Eval | 배포 전 자동 |
| spec-compliance | `skills/spec-compliance-checker/` | Eval | 스킬 완성 후 |
| axis-harness | `agents/axis-harness.md` | Eval | audit-harness 내 호출 |

---

## "성공은 침묵" 원칙 구현

```
Context Rot 방지 체계:

성공 경로:   도구 실행 → PostToolUse offload (>2000자 아카이브) → 침묵
실패 경로:   도구 실행 → stderr 에러 메시지 → Claude 수신 → 대응

데이터 흐름:
  ~/.claude/offload/{timestamp}-{tool}.txt  ← 대형 출력 아카이브
  ~/.claude/offload/index.jsonl             ← 메타데이터 색인
  ~/.claude/bash-history.log               ← bash 명령 이력
  ~/.claude/tool-metrics.jsonl             ← 전체 도구 실행 기록
  ~/.claude/tool-failures.jsonl            ← 실패 패턴 분류 기록

조회: bash ~/.claude/offload/query.sh [N] [tool_filter]
```

---

## audit-harness vs axis-harness

| | audit-harness (스킬) | axis-harness (에이전트) |
|--|---------------------|----------------------|
| **목적** | 현재 시스템 점검 | 설계 성숙도 평가 |
| **방식** | Check Chain + OWASP Agentic Top 10 체크리스트 | CLEAR 프레임워크 + OTel + OWASP 점수 |
| **출력** | 발견 문제 목록 + 즉시 수정 | 축별 성숙도 점수 (0-5) + 로드맵 |
| **호출** | `/audit-harness` | `Agent(subagent_type="axis-harness")` |
| **주기** | 변경 후 즉시 | 분기별 또는 대규모 리팩터 후 |

---

*Last updated: 2026-04-24*
