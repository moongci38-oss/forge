# Subagent & Agent Teams 사용 정책

## 1. 직접 도구 사용 (Agent 불필요)

| 상황 | 도구 |
|------|------|
| 경로 이미 알고 있는 파일 읽기 | `Read` |
| 특정 심볼·문자열 검색 | `Grep` |
| 파일 패턴 검색 | `Glob` |
| 쉘 작업·명령 실행 | `Bash` |
| 탐색 3회 이하로 해결 가능 | 직접 도구 |

## 2. Subagent (단일 Agent 스폰)

**사용 조건** — 아래 중 하나 충족 시:
- 탐색 3회 초과 광범위 코드베이스 탐색 → `Explore` subagent
- 대용량 출력이 메인 컨텍스트 오염 위험 (결과 격리 목적)
- 전문 agent type 매핑 (`code-reviewer`, `performance-checker`, `doc-writer` 등)
- 단일 독립 작업 하나만 위임

**금지**:
- 결과 합성·판단 위임 금지 — "findings 보고 fix해" 패턴 금지
- 메인이 직접 합성. 이해 위임(delegate understanding) 절대 금지.

## 3. Agent Teams (복수 Agent 협업)

**사용 조건** — 아래 중 하나 충족 시:
- 산출물 3개 이상 병렬 생성 (서로 독립된 작업)
- 전문성이 다른 역할 동시 필요 (예: CTO + UX + Writer)
- Competing Hypotheses — 동일 입력으로 독립 초안 여러 개 → 비교 선택
- Wave 기반 단계 검증 — Wave1 생성 → Wave2 검증 → Wave3 리뷰
- 오케스트레이터가 결과를 종합하는 구조

**규칙**:
- 독립 작업 → 단일 메시지에서 동시 스폰
- 병렬 동시 최대 3개 — 4개 이상은 Wave 분리
- A 결과 → B 입력 의존성 있으면 병렬 금지, 반드시 순차 실행

## 판단 플로우

```
작업 받음
  ↓
경로/심볼 이미 앎? → YES → 직접 도구
  ↓ NO
독립 작업 1개? → YES → 단일 Subagent
  ↓ NO
독립 작업 2~3개 OR 전문 역할 분리 필요?
  → YES → Agent Teams (단일 메시지 병렬 스폰)
  → 4개 이상 → Wave 분리 후 Agent Teams
```
