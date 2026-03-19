# [기능명] 태스크 분배

## 1. 개요

### 1.1 목표
### 1.2 관련 문서

- Spec: `.specify/specs/{spec-name}.md`
- Plan: `.specify/plans/{plan-name}.md`

---

## 2. 팀 구성

| 역할 | 모델 | 담당 영역 |
|------|------|----------|
| Team Lead | Opus/Sonnet | Shared 파일 + 검증 |
| Teammate A | Sonnet 4.6 | {domain-a} |
| Teammate B | Sonnet 4.6 | {domain-b} |

---

## 3. 파일 소유권

| Role | 소유 파일 패턴 | 수정 불가 |
|------|-------------|----------|

---

## 4. 태스크 목록

### Task 1: [태스크명]
- **담당**: Teammate A
- **의존성**: 없음
- **파일**:
- **완료 기준**:

### Task 2: [태스크명]
- **담당**: Teammate B
- **의존성**: Task 1 (Shared 타입)
- **파일**:
- **완료 기준**:

### Task 3: [태스크명] (Lead)
- **담당**: Lead
- **의존성**: Task 1, Task 2
- **파일**:
- **완료 기준**:

---

## 5. 실행 순서 (Wave 기반)

> **규칙**: 의존성 없는 태스크만 같은 Wave에서 병렬 스폰. 의존 태스크는 선행 Wave 완료 후 스폰.

```
① Lead: Shared 타입 정의
② Lead: TaskCreate × N (의존성 명시)
③ Lead: 의존성 그래프 → Wave 분류
   - Wave 1: 의존성 없는 태스크 (예: Task 1)
   - Wave 2: Wave 1 완료 후 스폰 (예: Task 1에 의존하는 Task 2)
④ Teammates: Wave 단위 병렬 실행 (같은 Wave 내만 병렬)
⑤ Lead: 결과 통합 (Task 3)
⑥ Lead: Walkthrough + 검증
```

---

## 6. API 계약 (Teammate 간)

> Teammate 간 협의가 필요한 인터페이스 정의
