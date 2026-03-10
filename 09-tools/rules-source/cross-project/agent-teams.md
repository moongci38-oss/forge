---
title: "병렬 실행 규칙"
id: parallel-execution
impact: HIGH
scope: [always]
tags: [subagent, parallel, orchestration, agent-teams]
section: cross-project
audience: dev
impactDescription: "파일 소유권 미선언 시 동시 편집 충돌 → 작업 소실. 의존성 있는 태스크 동시 스폰 시 빌드 실패"
enforcement: rigid
---

# 병렬 실행 규칙

> Subagent(Agent 도구)가 기본 병렬 실행 도구. Agent Teams는 에이전트 간 소통이 필요한 특수 케이스 전용.

---

## 핵심 원칙

병렬 처리가 가능한 작업은 **Subagent 사용을 우선 검토**한다.

실행 계획 수립 시 가장 먼저 아래를 판단한다:
1. 이 작업을 독립적인 서브태스크 2개 이상으로 나눌 수 있는가?
2. 그렇다면 → **Subagent 병렬 스폰** (기본)
3. 에이전트 간 소통/비교/실시간 모니터링이 필요한가? → **Agent Teams** (특수)
4. 그렇지 않다면 → 단일 순차 실행
5. 스폰 전 재확인: 의존성 없는 태스크만 동시 스폰 (Wave 기반 -- 선행 완료 후 다음 Wave 스폰)

---

## 도구 선택 기준

| 상황 | 선택 | 이유 |
|------|------|------|
| 독립 서브태스크 2개 이상 | **Subagent** (기본) | 컨텍스트 격리, tmux 불필요, resume 가능 |
| 단일 순차 작업 | 순차 Subagent 또는 직접 실행 | 팀 불필요 |
| 에이전트 간 비교/토론 필요 | **Agent Teams** (Competing Hypotheses) | 에이전트 간 소통 필수 |
| 실시간 모니터링 + 롤백 | **Agent Teams** (Watchdog) | 에이전트 간 실시간 통신 필수 |

---

## 활성화 요건

| 도구 | 요건 | 환경 제약 |
|------|------|----------|
| **Subagent** | 없음 (기본 내장) | VS Code, 터미널, tmux 모두 가능 |
| **Agent Teams** | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` | tmux 필수 -- VS Code 통합 터미널 미지원 |

Agent Teams 사용 시:
```bash
# WSL Ubuntu-22.04 (tmux 3.2a 설치됨)
wsl -d Ubuntu-22.04
tmux new-session -s agent-team
claude  # 환경변수 자동 적용
```

---

## 4대 오케스트레이션 패턴

| 패턴 | 기본 도구 | 사용 시점 | 예시 |
|------|:--------:|----------|------|
| **Fan-out/Fan-in** | **Subagent** | 독립적 병렬 작업 | 멀티 프로젝트 분석, 다국어 처리 |
| **Pipeline** | 순차 Subagent / 직접 | 순차 의존성 | 리서치→기획→마케팅→콘텐츠 |
| **Competing Hypotheses** | **Agent Teams** | 에이전트 간 비교/토론 | 전략 A/B/C 비교, 성능 최적화 |
| **Watchdog** | **Agent Teams** | 안전성 중요 변경 | 대규모 배포, 운영 변경 |

---

## Subagent 프롬프트 설계 4원칙

Subagent 스폰 시 프롬프트를 아래 4원칙으로 구성한다:

| 원칙 | 설명 |
|------|------|
| **Focused** | 하나의 명확한 목표만 부여 -- 복합 목표 금지 |
| **Self-contained** | 필요한 컨텍스트를 프롬프트에 모두 포함 -- 외부 참조 최소화 |
| **Specific scope** | 작업 범위(파일, 모듈, 영역)를 명시적으로 한정 |
| **Specific output** | 기대 산출물의 형식과 저장 위치를 명시 |

---

## 병렬 실행 파일 소유권 (동시 편집 충돌 방지)

태스크 시작 전 영역 분리를 반드시 선언한다:

```
## 병렬 실행 파일 소유권 (태스크별 선언)
- Subagent A: 01-research/** (리서치 담당)
- Subagent B: 02-product/**  (기획 담당)
- 공유 파일 (CLAUDE.md, settings.*): Lead만 수정
- 동시 수정 금지: .env, settings.json, .gitignore
```

---

## Worktree 격리 (동일 파일 병렬 수정)

Subagent의 `isolation: "worktree"` 옵션으로 동일 파일을 병렬 수정할 수 있다.

### 문제 유형별 해결 도구

| 문제 | 설명 | 해결 |
|------|------|------|
| **파일 충돌** | A와 B가 같은 파일을 수정 | **Worktree** (각자 독립 복사본 → merge) |
| **의존성** | B가 A의 결과를 입력으로 필요 | **Wave 순차** (A 완료 → B 스폰) |

### 사용법

Agent 도구에 `isolation: "worktree"` 지정 시:
1. 임시 git worktree가 생성됨 (독립 브랜치)
2. Subagent가 격리된 복사본에서 작업
3. 변경 없으면 worktree 자동 정리
4. 변경 있으면 worktree 경로 + 브랜치명 반환 → Lead가 merge 판단

### 적용 시나리오

| 시나리오 | Worktree | 파일 소유권 | 비고 |
|---------|:--------:|:----------:|------|
| 서로 다른 파일 수정 | 불필요 | **필수** | 기본 Subagent로 충분 |
| 같은 파일의 다른 부분 수정 | **권장** | 불필요 | merge 시 충돌 가능성 낮음 |
| 같은 파일의 같은 영역 수정 | 금지 | — | 의존성으로 분류 → Wave 순차 |
| 독립적이지만 안전하게 격리 | 선택 | 선택 | 보험용 격리 |

### 주의사항

- Worktree 브랜치는 Lead가 merge 책임 (자동 merge 금지)
- merge conflict 발생 시 **[STOP]** Human 에스컬레이션
- 3개 이상 worktree 동시 운영은 merge 복잡도 급증 → 권장하지 않음

---

## 모델 계층화 (비용 60-70% 절감)

```
Lead (오케스트레이터)    → Opus 4.6   — 계획·판단·종합
구현/작성 Subagent      → Sonnet 4.6 — 문서 작성, 분석
탐색/검색 Subagent      → Haiku 4.5  — 검색, 파일 읽기
```

---

## Subagent vs Agent Teams 비교

| 항목 | Subagent | Agent Teams |
|------|----------|-------------|
| 컨텍스트 | 격리 (결과만 반환) | 공유 가능 |
| tmux 필요 | 불필요 | **필수** |
| VS Code 호환 | 가능 | 미지원 |
| resume 가능 | 가능 (agentId) | 불가 |
| 에이전트 간 소통 | 불가 | 가능 |
| 세션 재개 | agentId로 가능 | Git commit으로 영속화 |
| 파일 충돌 방지 | worktree 격리 가능 | 파일 소유권 규칙 |

## Do

- 병렬 처리 가능한 작업은 Subagent 사용을 우선 검토한다
- 태스크 시작 전 파일 소유권을 반드시 선언한다
- 의존성 없는 태스크만 동시 스폰한다 (Wave 기반)
- 모델 계층화를 적용한다 (Opus/Sonnet/Haiku)
- 에이전트 간 소통이 필요한 경우에만 Agent Teams를 사용한다

## Don't

- 파일 소유권 선언 없이 병렬 작업을 시작하지 않는다
- 의존성 있는 태스크를 동시 스폰하지 않는다
- 공유 파일(CLAUDE.md, settings.*)을 Subagent이 수정하지 않는다
- 독립 병렬 작업에 Agent Teams를 사용하지 않는다 (Subagent 사용)

## AI 행동 규칙

1. 실행 계획 수립 시 병렬 분해 가능성을 가장 먼저 판단한다
2. 독립 병렬 작업은 Subagent로 스폰한다 (기본)
3. Competing Hypotheses, Watchdog 패턴만 Agent Teams로 스폰한다
4. 스폰 전 파일 소유권을 선언하고, 의존성 없는 태스크만 동시 스폰한다
5. 모델 계층화를 적용한다 (Lead→Opus, 구현→Sonnet, 탐색→Haiku)

## Iron Laws

- **IRON-1**: 파일 소유권 미선언 상태로 병렬 작업을 시작하지 않는다
- **IRON-2**: 의존성 있는 태스크를 동시 스폰하지 않는다

## Rationalization Table

| 합리화 (Thought) | 현실 (Reality) |
|-------------------|---------------|
| "간단한 작업이라 소유권 선언 없이 해도 충돌 안 날 것" | 간단한 작업에서도 동일 파일 동시 편집 충돌이 발생한다. 선언은 5초, 충돌 복구는 30분이다 |
| "이 두 태스크는 거의 독립적이니 같이 돌려도 될 것" | "거의" 독립적은 독립적이 아니다. 의존성이 0%일 때만 동시 스폰한다 |
| "Agent Teams가 더 강력하니까 기본으로 쓰자" | Agent Teams는 tmux 필수, 세션 재개 불가, VS Code 미지원. 독립 병렬은 Subagent가 우위다 |

## Red Flags

- "파일 하나만 수정하는 거라..." → STOP. 파일 소유권을 선언한다
- "선행 작업이 금방 끝나니까 같이 시작해도..." → STOP. Wave 기반으로 선행 완료 후 다음 스폰한다
- "Agent Teams로 하면 더 좋을 것 같은데..." → STOP. 에이전트 간 소통이 필요한가? 아니면 Subagent가 기본이다
