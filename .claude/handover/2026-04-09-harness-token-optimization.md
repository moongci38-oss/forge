# 인수인계: 하네스 개선 + 토큰 최적화 (2026-04-09)

## 세션 요약

외부 리서치 5건 분석 → Forge 시스템 비교 → 실제 갭 도출 → 즉시 적용. 4 커밋.

## 커밋 내역

| 커밋 | 내용 | 파일 수 |
|------|------|:------:|
| `a68ae65` | 하네스 개선 5종 (Agent Teams 기본, 토큰 예산, 100줄 규칙, Prove-It, Canary 메트릭) | 8 |
| `bf5b03a` | P0 토큰 최적화 (환경변수, 중복 플러그인/MCP 제거) | 2 |
| `e348b03` | P1 토큰 최적화 (로그 필터 훅, 미사용 플러그인 비활성화) | 2 |
| `b86b16a` | usage-logger 버그 수정 + ux-researcher Write 제거 | 2 |

## 변경 상세

### 하네스 개선 (a68ae65)

**1. Agent Teams 기본 전환**
- 변경 파일: `shared/cross-project/agent-teams.md`, `.claude/rules/forge-core.md`
- 이전: Subagent 기본, Agent Teams 특수
- 이후: Agent Teams 기본 (공유 태스크 + 피어 메시징), Subagent는 단순 탐색/검색 전용
- 출처: 코드 에이전트 오케스트라 (Addy Osmani)

**2. 토큰 예산 + 자동 Kill**
- 신규: `.claude/hooks/agent-token-budget.sh` (PostToolUse)
- 신규: `.claude/hooks/cleanup-agent-budget.sh` (Stop)
- 동작: 세션별 도구 호출 횟수 추적, 85% 경고, 100% 중단 요청, 동일 에러 3회 전략 변경 강제
- PARALLEL-IRON-3 추가
- 출처: 코드 에이전트 오케스트라

**3. 100줄 규칙**
- 신규: `.claude/hooks/100-line-rule.sh` (PostToolUse Edit|Write)
- 신규: `.claude/hooks/reset-code-lines.sh` (PostToolUse Bash)
- 동작: 테스트 없이 코드 100줄 이상 작성 시 경고. 테스트 실행하면 카운터 리셋
- 출처: agent-skills (Addy Osmani)

**4. Prove-It 패턴**
- 수정: `~/.claude/skills/investigate/SKILL.md`
- 이전: 4단계 (조사→분석→검증→수정)
- 이후: 5단계 (조사→분석→검증→**재현 테스트**→수정)
- Stage 4에서 재현 테스트 FAIL 확인 후에만 수정 허용
- 출처: agent-skills

**5. Staged Rollout 메트릭 임계값**
- 수정: `~/.claude/skills/canary/SKILL.md`, `.claude/agents/canary-judge.md`
- 추가: Green/Yellow/Red 판단 테이블 (에러율, P95, JS에러, 비즈니스 메트릭, 메모리)
- 추가: 즉시 롤백 트리거 5개 조건
- 추가: baseline 대비 상대 판정 로직
- 출처: agent-skills

### 토큰 최적화 (bf5b03a + e348b03)

**P0 (즉시 적용)**
- `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` 환경변수 추가
- Forge 중복 플러그인 3개 제거 (code-review, security-guidance, superpowers → 전역에 존재)
- nano-banana MCP 중복 제거 (전역에 존재)

**P1**
- 신규: `.claude/hooks/filter-log-output.sh` — 빌드/테스트 출력 에러만 추출
- Forge 미사용 플러그인 3개 비활성화 (product-management, marketing, data)

**절감 효과**
- Forge 활성 플러그인: 15개 → 12개
- Forge MCP: 2개 → 1개
- 턴당 예상 절감: ~10K 토큰
- 세션당 예상 절감: 20~30%

### 로거 수정 + 에이전트 (b86b16a)

- usage-logger.sh: `CLAUDE_TOOL_NAME` 환경변수 미지원 → stdin JSON 파싱으로 변경
- ux-researcher: Write 도구 제거 (Evaluator 역할)

## 신규 스킬

- `/meeting` — 미팅/대화 내용 구조화 저장
  - 스킬: `~/.claude/skills/meeting/SKILL.md`
  - 커맨드: `forge/.claude/commands/meeting.md`
  - 저장 경로: `forge-outputs/10-operations/meetings/`
  - 출처: 델타소사이어티 Compound 엔지니어링 영감

## 드롭된 항목

| 항목 | 이유 |
|------|------|
| read-once 훅 | Hook 스펙 한계 (캐시 반환 메커니즘 없음) + 파일 기반 상태 통신과 양립 불가 |
| 에이전트 도구 분리 (11개) | 점검 결과 9/11은 이미 tools 필드로 차단됨. 1개만 수정 |
| PageIndex (벡터리스 RAG) | 현재 /rag-search로 충분 |
| AutoBE | CRUD 특화, 범용 적용 불가 |

## 후속 작업

1. **usage.log 데이터 분석** (1주 후) — 도구별 토큰 소비 패턴 파악 → 타겟팅 최적화
2. **Agent Teams 실사용 모니터링** — 기본 전환 후 실제 사용 패턴 확인
3. **토큰 예산 임계값 조정** — 실사용 데이터 기반으로 예산 수치 튜닝

## 리서치 산출물

| 영상/글 | 산출물 경로 |
|--------|-----------|
| 델타소사이어티 | `forge-outputs/01-research/videos/analyses/2026-04-09-VcL_N_csw0s-*` |
| 캐슬 AI 토큰 절약 | 분석 리포트 (세션 내 처리, 별도 파일 미생성) |
| agent-skills | `/tmp/agent-skills/` (클론, 임시) |
