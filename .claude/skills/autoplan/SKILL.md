---
name: autoplan
description: 기획서를 CEO(비즈니스)→Design(UX)→Engineering(기술) 3관점으로 순차 리뷰하는 스킬. Phase 3 에이전트 회의 후 자동 트리거.
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 기획서를 CEO·Design·Engineering 3관점으로 순차 리뷰하여 맹점을 제거하는 기획 검증 전문가입니다.
**컨텍스트**: Phase 3 에이전트 회의 후 자동 트리거되거나 `/autoplan` 호출 시 실행됩니다.
**출력**: CEO/Design/Engineering 관점별 리뷰 결과 + 개선 항목을 마크다운 보고서(`docs/planning/active/`)로 저장합니다.

# Autoplan — 3관점 순차 리뷰

기획서(PRD/GDD)를 3개 관점에서 순차적으로 리뷰하여 맹점을 제거한다.

## 핵심 원칙

> **단일 관점은 맹점을 만든다.**
> CEO→Design→Eng 순서로 리뷰하여 비즈니스/UX/기술 모두 검증한다.

## 사용법

(manual)
/autoplan                           # 현재 Phase 3 기획서 리뷰
/autoplan --doc path/to/prd.md      # 특정 문서 리뷰
/autoplan --skip ceo                # CEO 리뷰 스킵

(auto-trigger)
Phase 3 에이전트 회의(Competing Hypotheses) 후 → 자동 실행

## 3관점 리뷰

### Review 1: CEO (비즈니스)

Subagent 역할: 비즈니스 의사결정자

| 검증 항목 | 기준 |
|----------|------|
| 비즈니스 모델 | 수익화 경로 명확, 단가/마진 계산 |
| 시장 적합성 | TAM/SAM/SOM 대비 제품 포지셔닝 |
| ROI | 개발 비용 대비 기대 수익 |
| 경쟁 우위 | 진입장벽, 차별점, MOAT |
| Kill Signal | 시장 없음, 수익 모델 없음, 경쟁 불가 |

### Review 2: Design (UX/UI)

Subagent 역할: 디자인 리드

| 검증 항목 | 기준 |
|----------|------|
| 사용자 경험 | 핵심 플로우 3클릭 이내 |
| UI 일관성 | 디자인 시스템/토큰 준수 |
| 접근성 | WCAG 2.1 AA 기준 |
| 정보 구조 | 내비게이션 직관성 |
| Kill Signal | UX 복잡도 과다, 학습곡선 급경사 |

### Review 3: Engineering (기술)

Subagent 역할: CTO/리드 엔지니어

| 검증 항목 | 기준 |
|----------|------|
| 기술 실현성 | 기술 스택으로 구현 가능 여부 |
| 아키텍처 | 확장성, 유지보수성, 성능 |
| 보안 | OWASP Top 10 대응 |
| 일정 | SP 추정 현실성 |
| Kill Signal | 기술 불가, 일정 3배+ 초과 |

## 워크플로우

1. Phase 3 기획서 + Competing Hypotheses 최종안 읽기
2. **CEO Review** (Sonnet Subagent) → 어노테이션 추가
3. **Design Review** (Sonnet Subagent) → 어노테이션 추가
4. **Engineering Review** (Sonnet Subagent) → 어노테이션 추가
5. 충돌 감지: 관점 간 상충 사항 정리
6. 충돌 없음 → Phase 3 Check 진입
7. 충돌 있음 → Human 에스컬레이션 + 충돌 리포트

## 산출물

기획서에 인라인 어노테이션 + 별도 리뷰 리포트:

`{기획서 경로}-autoplan-review.md`

```markdown
## Autoplan 3관점 리뷰 결과

### CEO Review
- [PASS] 비즈니스 모델: ...
- [WARN] ROI: ...

### Design Review
- [PASS] UX 플로우: ...
- [FAIL] 접근성: ...

### Engineering Review
- [PASS] 기술 실현성: ...
- [WARN] 일정: ...

### 충돌 사항
- CEO vs Eng: 기능 A의 우선순위 (비즈니스 가치 높음 vs 기술 복잡도 높음)
```

## 순차 실행 이유

병렬이 아닌 순차인 이유:
1. CEO 리뷰 결과가 Design 리뷰의 우선순위를 결정
2. Design 리뷰 결과가 Engineering 리뷰의 범위를 결정
3. 순차적으로 쌓이는 어노테이션이 다음 리뷰어의 컨텍스트가 됨
