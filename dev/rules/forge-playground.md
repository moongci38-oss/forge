---
title: "Playground 연동 규칙"
id: forge-playground
impact: LOW
scope: [forge]
tags: [playground, code-map, concept-map, design-playground, visualization]
requires: [forge-workflow]
section: forge-tools
audience: dev
impactDescription: "선택적 보조 도구 — 미사용 시 텍스트 기반 방식으로 동일 결과 달성 가능"
enforcement: flexible
---

# Forge Dev Playground 연동 규칙

> Anthropic 공식 `playground` 플러그인 중 3개 템플릿을 Forge Dev 파이프라인에 선택적 연동.
> 나머지 3개(diff-review, document-critique, data-explorer)는 독립 사용 가능 (비파이프라인).

## 채택 템플릿 및 Phase 매핑

| Phase | 템플릿 | 트리거 조건 | 기존 도구와의 관계 |
|-------|--------|-----------|-----------------|
| **Phase 1** | `code-map` | Standard + 새 코드베이스 분석 시 | 기존에 없던 아키텍처 시각화 추가 |
| **Phase 1.5** | `concept-map` | 요구사항 의존성이 복잡할 때 (4+ 질문 발생) | Sequential Thinking 보완 (선형→공간) |
| **Phase 2** | `design-playground` | UI/프론트엔드 Spec에 디자인 결정 포함 시 | frontend-design 스킬 **전에** 탐색 단계 추가 |

## 행동 규칙

### 선택적 제안 (강제 아님)

- AI가 트리거 조건 충족을 감지하면 "playground 생성할까요?" **제안**
- Human 승인 후에만 생성 — Phase 진행의 필수 게이트가 아닌 **보조 도구**
- Human이 거부하면 기존 텍스트 기반 방식으로 계속 진행

### design-playground → frontend-design 연계

1. `design-playground`에서 Human이 디자인 값(radius, padding, shadow 등) 탐색/결정
2. 결정된 값을 프롬프트로 복사
3. 복사된 프롬프트를 `frontend-design` 스킬의 입력으로 활용
4. **탐색**(playground) → **결정**(프롬프트) → **구현**(스킬) 3단계 흐름

### design-playground → Spec 반영

design-playground에서 확정된 디자인 결정을 Spec 문서의 프론트엔드 섹션에 반영한다.

**반영 대상** (Spec 섹션 매핑):

| playground 결정 | Spec 반영 위치 | 예시 |
|----------------|-------------|------|
| breakpoint별 레이아웃 | 섹션 9.6 반응형 동작 | mobile: 1col → tablet: 2col → desktop: sidebar+main |
| 컴포넌트 디자인 토큰 (radius, shadow, spacing) | 섹션 9.9 인터랙션/애니메이션 | border-radius: 8px, shadow: lg, gap: 16px |
| hover/transition 패턴 | 섹션 9.9 인터랙션/애니메이션 | hover scale 1.02, transition 200ms ease |
| 색상/타이포 기본값 | Constitution 또는 Design System 문서 | primary: #3B82F6, heading: Inter 700 |

**반영 프로세스**:
1. design-playground에서 디자인 값 탐색/결정 (기존 흐름)
2. 결정 값을 Spec 섹션 9.6/9.9에 명시적으로 기록
3. Constitution에 디자인 토큰이 있으면 Constitution 참조로 대체 (중복 방지)
4. Spec 승인 시 playground 결정이 반영되었는지 검증

**자동화 수준**: AI가 playground 결과물을 읽고 Spec 해당 섹션에 자동 삽입을 제안한다. Human 승인 후 반영.

### HTML 파일 저장 경로

```
docs/assets/playground/{phase}-{name}.html
```

예시:
- `docs/assets/playground/phase1-auth-module-architecture.html`
- `docs/assets/playground/phase1.5-requirement-dependencies.html`
- `docs/assets/playground/phase2-dashboard-design.html`

## 프로젝트별 활용

### Forge Dev 파이프라인 연동 (개발 프로젝트)

| 템플릿 | 웹 프로젝트 | 게임 프로젝트 | 비즈니스 |
|--------|:----------:|:-----------:|:--------:|
| **code-map** | Phase 1 (프레임워크 구조) | Phase 1 (엔진 시스템) | - |
| **concept-map** | Phase 1.5 (요구사항) | Phase 1.5 (게임 메커닉) | 제품 기획 (02-product) |
| **design-playground** | Phase 2 (UI 컴포넌트) | - | 브랜드/UI (05-design) |

### 독립 사용 (비파이프라인)

| 템플릿 | 사용 시나리오 |
|--------|------------|
| **diff-review** | Forge Dev 외 수동 코드 리뷰 시 자유 사용 |
| **document-critique** | 비개발 문서(PRD, 제안서) 리뷰 시 |
| **data-explorer** | Business 비개발자 SQL 탐색 시 |

## Draw.io MCP 연동 (복잡한 아키텍처 시각화)

Playground가 인터랙티브 HTML 탐색에 적합한 반면, **Draw.io MCP**는 복잡한 아키텍처 다이어그램에 적합하다.

| 상황 | 도구 | 이유 |
|------|------|------|
| 인터랙티브 탐색 (디자인 토큰, 컬러) | **Playground** | HTML 기반 실시간 조작 |
| 간단한 플로우/시퀀스 (≤15 노드) | **Mermaid** | 마크다운 내장 |
| 복잡한 아키텍처/상태도 (15+ 노드) | **Draw.io MCP** | 레이어/그룹/C4 지원 |
| C4 Model Level 1-4 | **Draw.io MCP** | C4 아이콘 네이티브 |
| 복잡한 E2E 플로우 (Spec 섹션 10) | **Draw.io MCP** | 대규모 상태 전이 표현 |

### 활용 시점

- **Phase 1**: `code-map` (Playground) 또는 Draw.io로 기존 아키텍처 시각화
- **Phase 2 Spec**: 섹션 8 아키텍처 다이어그램이 Mermaid 한계(15+ 노드)를 넘을 때
- **Forge S3/S4**: 시스템 구조, C4 Model, 복잡한 상태 전이 다이어그램

### Draw.io 파일 저장 경로

```
docs/assets/diagrams/{phase}-{name}.drawio
```

## 미채택 사유 (레퍼런스)

| 템플릿 | 사유 |
|--------|------|
| diff-review | Forge Dev 5-에이전트 병렬 code-review + GitHub PR 라인 리뷰가 더 정교 |
| document-critique | Check 3.5 트레이서빌리티 + validate-spec.js + spec-writer가 70-80% 커버 |
| data-explorer | 개발자 직접 SQL + data 플러그인이 파이프라인 내에서 더 빠름 |
