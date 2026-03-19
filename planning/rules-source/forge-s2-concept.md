---
title: "S2 컨셉 확정"
id: forge-s2-concept
impact: HIGH
scope: [forge]
tags: [pipeline, concept, s2, go-no-go]
requires: [forge-structure]
section: forge-pipeline
audience: all
impactDescription: "Go/No-Go 미수행 시 Kill Criteria 해당 프로젝트 진행 → 리소스 낭비. 비전/타겟 미승인 상태로 기획 시작"
enforcement: rigid
---

# S2 컨셉 확정

## S2. Concept (컨셉 확정)

- `/lean-canvas` + 제품/게임 컨셉
- **필수 방법론**: Pretotyping + Mom Test + Lean Validation + TAM/SAM/SOM + OKR
- **선택 방법론**: OST (Opportunity Solution Tree), PR/FAQ
- **플러그인 보강** (선택적):
  - `product-management:roadmap-management` — 로드맵 우선순위 결정 시 RICE/ICE 자동 스코어링 보조
- **산출물**: `{folderMap.product}/{project}/YYYY-MM-DD-s2-concept.md`
- **게이트**: **[STOP]** 비전/타겟/차별점 승인

## S2 Gate: Go/No-Go 스코어링

S2 [STOP] 게이트에서 프로젝트 진행 여부를 정량 평가한다.

| 영역 | 가중치 | 평가 기준 |
|------|:-----:|---------|
| 시장 기회 | 30% | TAM/SAM/SOM, 성장률, 타이밍 |
| 기술 실현성 | 25% | 기술 스택 검증, 리소스 가용성 |
| 비즈니스 모델 | 25% | 수익화 경로, 유닛 이코노믹스 |
| 위험 관리 | 20% | 규제, 경쟁, 기술 리스크 |

- **80점+ = Go** → S3 진행
- **60-79점 = 조건부** → 보완 후 재평가
- **60점 미만 = No-Go** → 피벗 또는 중단

### Kill Criteria (하나라도 해당 시 즉시 No-Go)

- TAM < $1M (시장 규모 부족)
- 경쟁사 70%+ 시장 점유 (진입 장벽)
- 핵심 기술 불가 (현재 기술로 구현 불가)
- 규제 장벽 (법적으로 출시 불가)

## Do

- 필수 방법론(Pretotyping, Mom Test, Lean Validation, TAM/SAM/SOM, OKR)을 적용한다
- Go/No-Go 스코어링은 Kill Criteria 검토 후 실행한다
- 산출물은 `{folderMap.product}/{project}/`에 저장한다

## Don't

- Kill Criteria에 해당하는 프로젝트를 Go로 판정하지 않는다
- Go/No-Go 스코어링 없이 S3로 진행하지 않는다
- 비전/타겟/차별점 승인 없이 [STOP] 게이트를 통과하지 않는다
- 트레이드오프 없는 디렉션을 수립하지 않는다 ("최고의 X이면서 최고의 Y" 금지)
- Axis 1/3을 Human 확인 없이 확정하지 않는다

## Pretotyping 실행 경로

S2에서 Pretotyping은 아래 3가지 경로로 수행한다. 프로젝트 성격과 Human의 의지에 따라 선택한다.

| 경로 | 방법 | 소요 시간 | 적합 상황 |
|------|------|:--------:|----------|
| **A. Replit Agent** | Replit Agent로 클릭 가능한 HTML 프로토타입 즉시 생성 → 실사용자 피드백 | 1-2시간 | UI/UX 검증이 핵심인 웹/앱 |
| **B. Stitch MCP** | AI UI 목업 생성 → 스크린샷으로 아이디어 검증 | 30분 | 빠른 시각적 검증 |
| **C. 문서 Pretotype** | Landing Page 초안(MD) 또는 PR/FAQ 작성 → 반응 측정 | 1시간 | 콘텐츠/가격 모델 검증 |

**Replit Agent 활용 가이드 (경로 A)**:
1. Replit.com → "Create App" → 기능 설명 1-2문장 입력
2. Agent가 자동 생성한 HTML/JS 앱을 Deploy (무료 플랜)
3. 공유 링크를 5-10명에게 보내 피드백 수집
4. 피드백을 S2 컨셉 문서에 반영 → Go/No-Go 스코어에 "실사용자 검증" 가산점 적용

> Replit Pretotyping은 Mom Test 인터뷰를 대체하지 않는다. 사용성/UI 가설 검증에 특화되며, 문제-해결 적합성(Problem-Solution Fit)은 Mom Test로 별도 검증한다.

## 기획 디렉션 5축 (Planning Direction 5-Axis)

S2 컨셉 확정 시 5축 디렉션을 수립한다. **트레이드오프 없는 디렉션은 디렉션이 아니다.** "최고의 UX이면서 최고의 성능"처럼 양립 불가능한 목표를 동시 추구하는 것은 금지한다.

| # | 축 | 정의 | 형식 요건 | PASS/FAIL |
|:-:|---|------|---------|:---------:|
| 1 | **전략 방향** | 핵심 트레이드오프 (무엇을 취하고 무엇을 버리는가) | "A > B" 또는 "A, not B" 형식 필수 | ">" 또는 "not" 포함 여부 |
| 2 | **경험 원칙** | 측정 가능한 사용자 경험 원칙 | 수치/시간/횟수 포함 필수 | 숫자 포함 여부 |
| 3 | **범위 경계** | Do / Don't 목록 (구현 포함/제외 기능) | Do 2개+ / Don't 2개+ 필수 | 최소 수량 충족 |
| 4 | **품질 기준** | 비타협 NFR (Go/No-Go와 구별: 실현 가능성이 아닌 품질 수준) | 측정 가능한 값 포함 | 값 포함 여부 |
| 5 | **벤치마크** | 1-3개 레퍼런스 + 참조 이유 | 최소 1개 + 이유 | 레퍼런스 존재 |

> **Axis 4 vs Go/No-Go 구분**: Go/No-Go는 "이 기술로 구현 가능한가?" (실현 가능성), Axis 4는 "구현할 때 어떤 수준을 반드시 달성해야 하는가?" (품질 비타협선).

### Don't 태그 형식

범위 경계의 Don't 항목은 S4 Wave 2B 자동 매칭을 위해 구조화된 태그 형식을 사용한다:

```
Don't:
- `social-login`: 소셜 로그인 연동 미지원
- `nested-comments`: 대댓글/스레드 형식 미지원
- `real-time-chat`: 실시간 채팅 기능 미포함
```

### 작성 주체 (3.1.1)

| 단계 | 주체 | 행동 |
|------|------|------|
| 후보 제시 | AI | S1 리서치 기반 축당 2-3개 후보 제시 |
| 형식 검증 | AI | 트레이드오프 형식 자동 검증 (PASS/FAIL 루브릭) |
| 최종 확정 | **Human** | S2 [STOP] 게이트에서 최종 선택/수정/승인 |

> **Iron Law**: AI는 Axis 1 (전략 방향)과 Axis 3 (범위 경계)을 Human 확인 없이 확정할 수 없다.

### 디렉션 변경 경로 (3.1.2)

| 유형 | 조건 | 절차 | gate-log |
|------|------|------|----------|
| **경량 수정** | 1-2축 조정 | 영향받는 S3/S4 항목만 리뷰 | `directionVersion: v{N+1}` 기록 |
| **전면 수정** | 전략 피벗 | S2 [STOP] 재승인 + S3/S4 재작성 | `directionVersion: v{N+1}` + 피벗 사유 |

**변경 트리거:**
- 에이전트 2명 이상의 제안이 동일 축을 위반 → [STOP] Human
- S4 cto-advisor CRITICAL 이슈 → 해당 축 경량 수정 허용
- S4 진행 중 변경: Wave 2 전 = 경량 리뷰, Wave 2 후 = Wave 2B만 재실행, 전략 피벗 = 전면 재승인

### 엣지 케이스

- **2개 축 상충**: Axis 1 (전략 방향) 우선. 해소 불가 시 [STOP] Human
- **Human이 모호한 5축 작성**: AI가 구체화 옵션 제시, 최대 2회 재작성. 3회 실패 → [STOP] + 작성 가이드 제공
- **레거시 프로젝트 거부**: 필터 스킵, Wave 2B 스킵. gate-log에 `directionSkipped: true` 기록

## AI 행동 규칙

1. S2 Go/No-Go 스코어링은 Kill Criteria 검토 후 실행한다
2. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
3. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
4. S2 Gate에서 [Human] 항목(Mom Test, Pretotype) 미실행 시 gate-log 비고에 "계획서로 갈음" 명시 기록한다
5. Pretotyping 경로 선택 시 프로젝트 성격(UI 중심 vs 콘텐츠 중심)에 따라 A/B/C 중 적합한 경로를 제안한다
6. S2 컨셉 문서에 기획 디렉션 5축 섹션이 포함되었는지 확인한다. 누락 시 작성을 안내한다
7. Axis 1/3은 Human 확인 없이 확정하지 않는다 (Iron Law)
8. Don't 항목은 태그 형식(`tag-name`)으로 작성하여 S4 Wave 2B 자동 매칭을 지원한다
