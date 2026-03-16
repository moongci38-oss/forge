# 2026-03-14 시스템 개선 계획서

> 생성일: 2026-03-16 | 근거 문서: `01-research/daily/2026-03-14/ai-system-analysis.md`

---

## 오늘의 액션 아이템

### P1 (높음 — 이번 주)

| # | 액션 | 영향 범위 | 예상 작업량 |
|:-:|------|----------|:-----------:|
| 1 | **MCP Elicitation 훅 적용 가능성 검토** (신규) | trine 파이프라인 [STOP] 게이트 | 2h |
| 2 | **Claude Code 버전 업데이트** (이월 P1-2, 신기능 도입) | Claude Code CLI | 0.5h |
| 3 | **claude-api 스킬 Structured Outputs + Tool Streaming 반영** (이월 P1-3) | `.claude/skills/claude-api/` | 2h |
| 4 | **Claude Code Review 프리뷰 신청** (이월 P1-4) | Trine Check 3.7 | 1h |
| 5 | **MCP Streamable HTTP + Elicitation 통합 마이그레이션 계획 수립** (이월 P1-5 확장) | 9개 MCP 서버 설정 | 2h |

### P2 (보통 — 이번 달)

| # | 액션 | 영향 범위 | 예상 작업량 |
|:-:|------|----------|:-----------:|
| 6 | **trine-context-management.md에 /context 액션블 연동 추가** (신규) | `~/.claude/trine/rules/trine-context-management.md` | 1h |
| 7 | **1M 컨텍스트 전략 수립 + context-management.md 업데이트** (이월 P2-7) | `~/.claude/trine/rules/trine-context-management.md`, `trine-context-engineering.md` | 2h |
| ~~8~~ | ~~**GitHub Action v1.0 도입 검토**~~ | ~~이미 도입 완료 (todo-tracker.yml 등)~~ | — |
| 9 | **에이전트 협업 효율 메트릭 설계** (이월 P2-9) | Trine 파이프라인 | 2h |
| 10 | **장기 코드 품질 추적 메트릭 설계** (이월 P2-10) | Business Notion DB | 2h |
| 11 | **MCP 서버 버전 점검** (이월 P1-1, 정기 점검) | `~/.claude.json`, `.mcp.json` (9개 MCP 서버) | 1h |
| 12 | **trine-workflow.md에 refuse 조건 추가** (이월 P2-8) | `~/.claude/trine/rules/trine-workflow.md` | 1.5h |

---

## 각 액션 상세

### P1-1: MCP Elicitation 훅 적용 가능성 검토 (신규)

- **액션명**: MCP Elicitation 훅 → trine [STOP] 게이트 강화 PoC
- **영향 범위**: trine 파이프라인 [STOP] 게이트 로직 (trine-workflow.md, session-state.mjs)
- **예상 작업량**: 2h
- **의존성**: 없음
- **작업 내용**:
  1. Claude Code v2.1.76 Elicitation/ElicitationResult 훅 사양 확인 (GitHub 릴리즈 노트 + 공식 문서)
  2. 현재 trine [STOP] 게이트 (텍스트 메시지 → Human 수동 확인) vs Elicitation 다이얼로그 비교
  3. 적용 가능 시나리오 도출: Phase 2 Spec 승인 폼, P0 긴급 대응 확인 다이얼로그 등
  4. PoC 범위 결정 (trine-workflow.md 업데이트 필요 여부 포함)
- **참조 소스**: github.com/anthropics/claude-code/releases/tag/v2.1.76

---

### P2-12: trine-workflow.md에 refuse 조건 추가 (이월 P2-8)

- **액션명**: Trine 에이전트 명시적 refuse 조건 섹션 추가
- **영향 범위**: `~/.claude/trine/rules/trine-workflow.md`
- **예상 작업량**: 1.5h
- **의존성**: 없음
- **작업 내용**:
  1. MOSAIC 논문(2603.03205) plan-check-act/refuse 루프 핵심 아이디어 정리
  2. 위험 작업 패턴 목록화 (프로덕션 직접 삭제, force push, 보안 체크리스트 우회 등)
  3. trine-workflow.md "Auto-Fix 규칙" 섹션 다음에 "Refuse 조건" 섹션 추가:
     - 즉시 refuse 대상: 프로덕션 직접 삭제/force push/보안 체크리스트 우회
     - 확인 후 진행 대상: 외부 서비스 게시, 대용량 파일 삭제
  4. trine-workflow.md 컴파일 (manage-rules.sh build)
- **참조 소스**: arXiv 2603.03205

---

### P1-2: Claude Code 버전 업데이트 (이월 P1-2)

- **액션명**: Claude Code 최신 버전 확인 + 업데이트
- **영향 범위**: Claude Code CLI 전체
- **예상 작업량**: 0.5h
- **의존성**: 없음
- **작업 내용**:
  1. `claude --version` 확인
  2. 최신 버전 확인 (github.com/anthropics/claude-code/releases)
  3. 업데이트 필요 시 `npm update -g @anthropic-ai/claude-code`
  4. Elicitation, /context 액션블 등 신기능 동작 확인
- **참조 소스**: github.com/anthropics/claude-code/releases

---

### P1-3: claude-api 스킬 신기능 반영 (이월 P1-3)

- **액션명**: claude-api 스킬에 Structured Outputs + Tool Streaming GA 패턴 추가
- **영향 범위**: `/home/damools/business/.claude/skills/claude-api/SKILL.md`
- **예상 작업량**: 2h
- **의존성**: 없음
- **작업 내용**:
  1. Anthropic API Structured Outputs GA 사양 확인 (docs.anthropic.com)
  2. Subagent JSON 반환 패턴을 Structured Outputs로 표준화하는 예제 추가
  3. Tool Streaming 활용 실시간 피드백 패턴 예제 추가
  4. trine-context-engineering.md Subagent 결과 반환 규칙과 일관성 확인
- **참조 소스**: docs.anthropic.com/en/docs/changelog, trine-context-engineering.md "Subagent 결과 반환 규칙"

---

### P1-4: Claude Code Review 프리뷰 신청 (이월 P1-4)

- **액션명**: Claude Code Review 프리뷰 등록 + Trine Check 3.7 통합 검토
- **영향 범위**: Trine 파이프라인 Check 3.7, PR 리뷰 워크플로우
- **예상 작업량**: 1h
- **의존성**: 없음
- **작업 내용**:
  1. anthropic.com 또는 Claude Code 공식 채널에서 프리뷰 신청
  2. 기존 Trine Check 3.7 (`~/.claude/trine/agents/code-reviewer.md`) + Gemini Code Assist와의 역할 분리 검토
  3. 프리뷰 접근 시 PoC 실행 계획 문서화
- **참조 소스**: anthropic.com/news, `~/.claude/trine/agents/code-reviewer.md`

---

### P1-5: MCP Streamable HTTP + Elicitation 통합 마이그레이션 계획 (이월 P1-5 확장)

- **액션명**: MCP 통합 마이그레이션 계획 수립 (Streamable HTTP + Elicitation 훅 포함)
- **영향 범위**: 9개 MCP 서버 설정, `~/.claude.json`, `.mcp.json`
- **예상 작업량**: 2h
- **의존성**: P1-1 완료 후 (Elicitation 훅 범위 확정 후)
- **작업 내용**:
  1. MCP Streamable HTTP 사양 상세 확인 (modelcontextprotocol GitHub)
  2. 현행 9개 MCP 서버 중 영향받는 서버 식별
  3. Elicitation 훅 도입이 마이그레이션 계획에 미치는 영향 통합
  4. 마이그레이션 타임라인 수립 및 문서화: `docs/planning/active/plans/YYYY-MM-DD-mcp-migration-plan.md`
- **참조 소스**: GitHub modelcontextprotocol, v2.1.76 릴리즈 노트

---

### P2-6: trine-context-management.md에 /context 액션블 연동 추가 (신규)

- **액션명**: trine Phase 전환 체크리스트에 /context 커맨드 활용 명시
- **영향 범위**: `~/.claude/trine/rules/trine-context-management.md`
- **예상 작업량**: 1h
- **의존성**: 없음
- **작업 내용**:
  1. v2.1.74 /context 액션블 제안 기능 사양 확인 (컨텍스트 헤비 도구, 메모리 블로트, 용량 경고)
  2. trine-context-management.md "/compact 트리거 시점" 테이블에 "/context 확인 → 컨텍스트 헤비 도구 감지 시" 행 추가
  3. Phase 전환 프로토콜에 "50% 이상 시 /context 먼저 실행 후 /compact 판단" 흐름 추가
- **참조 소스**: v2.1.74 릴리즈 노트, trine-context-management.md

---

### P2-7: 1M 컨텍스트 전략 수립 (이월 P2-7)

- **액션명**: Opus 4.6 1M 컨텍스트 베타 접근 + trine-context-management.md 임계값 재조정
- **영향 범위**: `~/.claude/trine/rules/trine-context-management.md`, `trine-context-engineering.md`
- **예상 작업량**: 2h
- **의존성**: 1M 베타 접근 가능 여부 확인 후 진행
- **참조 소스**: docs.anthropic.com/en/release-notes, 2026-03-13 ai-system-analysis.md §2

---

### ~~P2-8: GitHub Action v1.0 도입 검토~~ — ✅ 이미 완료

> `todo-tracker.yml`, `develop-integration.yml` 등 GitHub Actions 이미 도입·운용 중. 이월 불필요.

---

### P2-9: 에이전트 협업 효율 메트릭 설계 (이월 P2-9)

- **액션명**: Subagent Fan-out 효율 메트릭 정의 + 수집 방법 설계
- **영향 범위**: Trine 파이프라인 Subagent 오케스트레이션
- **예상 작업량**: 2h
- **의존성**: 없음
- **참조 소스**: arXiv 2603.00309 (DIG to Heal), EmCoop

---

### P2-11: MCP 서버 버전 점검 (이월 P1-1, 정기 점검)

- **액션명**: 9개 MCP 서버 버전 현황 확인 + 구 버전 업데이트
- **영향 범위**: `~/.claude.json` (user-scope MCP), `/home/damools/business/.mcp.json` (project-scope MCP)
- **예상 작업량**: 1h
- **의존성**: 없음
- **작업 내용**:
  1. 9개 MCP 서버 각각의 설치 버전 확인 (filesystem, notion, sentry, stitch, nanobanana, brave-search, drawio, sequential-thinking, lighthouse)
  2. 각 서버의 GitHub 릴리즈 페이지에서 최신 버전 확인
  3. 구 버전 서버 발견 시 업데이트
  4. CVE-2026-26118 패턴(Azure MCP 서버 취약점) 해당 여부 확인
- **참조 소스**: 각 서버 GitHub releases, `business-core.md` 보안 체크리스트

---

### P2-10: 장기 코드 품질 추적 메트릭 설계 (이월 P2-10)

- **액션명**: Check 3 통과율/autoFix 횟수 등 메트릭 정의 + Notion DB 스키마 설계
- **영향 범위**: Business Notion DB, Trine 파이프라인
- **예상 작업량**: 2h
- **의존성**: 없음
- **참조 소스**: SWE-CI (arXiv 2603.03823), Business Notion 연동 (MEMORY.md)

---

## 누적 미처리 액션 (이전 계획서에서 이월)

> 2026-03-13 계획서 (`01-research/daily/2026-03-13/system-improvement-plan.md`)의 전체 10개 액션이 미처리 상태로 이월됨. 2026-03-14 신규 분석 결과를 반영하여 우선순위를 일부 조정.

| 이전 # | 이전 액션 | 이전 우선순위 | 2026-03-14 계획서 위치 | 우선순위 변화 | 변화 근거 |
|:------:|----------|:----------:|:--------------------:|:----------:|----------|
| P1-1 | MCP 보안 점검 (9개 서버) | P1 | P2-11 | **하향** | 즉각 위협 없음 — 정기 점검으로 전환 |
| P1-2 | Claude Code 버전 업데이트 | P1 | P1-2 | 유지 | 신기능 도입 (긴급성 없음) |
| P1-3 | claude-api 스킬 Structured Outputs | P1 | P1-3 | 유지 | 신규 신호 없음 |
| P1-4 | Claude Code Review 프리뷰 신청 | P1 | P1-4 | 유지 | 신규 신호 없음 |
| P1-5 | MCP Streamable HTTP 마이그레이션 계획 | P1 | P1-5 (Elicitation 통합 확장) | 유지 (범위 확장) | MCP Elicitation 신기능 연계 |
| P2-6 | GitHub Action v1.0 도입 | P2 | ~~P2-8~~ | **완료** | 이미 도입 완료 (todo-tracker.yml, develop-integration.yml 등) |
| P2-7 | 1M 컨텍스트 전략 | P2 | P2-7 | 유지 | 신규 신호 없음 |
| P2-8 | trine-workflow refuse 조건 | P2 | P2-12 | 유지 | MOSAIC 논문 참조 가치 있으나 긴급하지 않음 |
| P2-9 | 에이전트 협업 메트릭 | P2 | P2-9 | 유지 | 신규 신호 없음 |
| P2-10 | 장기 코드 품질 추적 | P2 | P2-10 | 유지 | 신규 신호 없음 |

**신규 추가 (2026-03-14 발견):**

| # | 액션 | 근거 | 우선순위 |
|:-:|------|------|:--------:|
| 신규-1 | MCP Elicitation 훅 적용 가능성 검토 | v2.1.76 신기능 — [STOP] 게이트 강화 가능 | P1 |
| 신규-2 | trine-context-management.md에 /context 액션블 연동 | v2.1.74 /context 커맨드 강화 | P2 |

---

## 모니터링 항목 (액션 불필요, 동향만 주시)

| 항목 | 이유 | 재평가 시점 |
|------|------|-----------|
| autoMemoryDirectory 설정 | 현 MEMORY.md 구조 정상 동작, 불필요한 변경 지양 | 사용 사례 발생 시 |
| Tesla 메가 AI 칩 팹 | 하드웨어 레이어, 직접 영향 없음 | 분기 재평가 |
| US AI 칩 수출 규정 변화 | 글로벌 정책, 단기 직접 영향 없음 | 분기 재평가 |
| Meta 레이오프 | 산업 동향 참고 | 분기 재평가 |
| 로컬 LLM 특화 모델 | Nemotron 사례 — 소형 모델 실용성 참고, 직접 도입 불필요 | 3개월 후 재평가 |
| A2A (Agent-to-Agent) 통신 | MCP 로드맵 단계, 사양 미확정 | 사양 확정 후 |

---

*Generated by Daily System Review Pipeline v1.0 | Lead: Sonnet 4.6*
