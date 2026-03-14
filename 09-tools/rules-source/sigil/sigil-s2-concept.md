---
title: "S2 컨셉 확정"
id: sigil-s2-concept
impact: HIGH
scope: [sigil]
tags: [pipeline, concept, s2, go-no-go]
requires: [sigil-structure]
section: sigil-pipeline
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

## AI 행동 규칙

1. S2 Go/No-Go 스코어링은 Kill Criteria 검토 후 실행한다
2. 각 Stage 산출물은 해당 폴더의 `projects/{project}/` 하위에 저장한다
3. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다 (폴더가 이미 프로젝트를 나타냄)
4. S2 Gate에서 [Human] 항목(Mom Test, Pretotype) 미실행 시 gate-log 비고에 "계획서로 갈음" 명시 기록한다
5. Pretotyping 경로 선택 시 프로젝트 성격(UI 중심 vs 콘텐츠 중심)에 따라 A/B/C 중 적합한 경로를 제안한다
