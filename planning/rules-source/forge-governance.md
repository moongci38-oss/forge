---
title: "Forge 거버넌스"
id: forge-governance
impact: HIGH
scope: [forge]
tags: [pipeline, gate, governance, model, pm]
requires: [forge-structure]
section: forge-pipeline
audience: all
impactDescription: "모델 계층화 미적용 시 토큰 비용 200-300% 증가. 게이트 로그 누락 시 프로젝트 이력 추적 불가"
enforcement: rigid
---

# Forge 거버넌스

> **통합 파이프라인 Phase 매핑**: S1=Phase 1, S2=Phase 2, S3=Phase 3, S4=Phase 4
> **통합 문서**: `forge/pipeline.md` (Phase 1~12)

## 병렬 실행 도구 매핑

| 패턴 | 도구 | 적용 시점 |
|------|:----:|----------|
| **Fan-out/Fan-in** | **Subagent** | Phase 1 리서치 (독립 영역 병렬), 멀티 프로젝트 병렬 |
| **Competing Hypotheses** | **Agent Teams** | Phase 3 기획서 에이전트 회의 |
| **Pipeline** | 순차 Subagent | Phase 1→2→3→4 순차 의존 |

## 모델 계층화

```
pipeline-orchestrator (Lead)    → Opus 4.6   (판단, 종합, 회의 심판)
기획서 작성 (gdd/prd)           → Sonnet 4.6 (문서 작성, 분석)
기획 패키지 작성 (technical-writer) → Sonnet 4.6 (S4 산출물 작성)
리서치/검색 Teammates            → Haiku 4.5  (검색, 팩트체크, 트렌드 수집)
```

## PM 도구 연동

### 2-Tier Fallback

| Tier | 조건 | 도구 |
|:----:|------|------|
| Tier 1 | Notion MCP 연결 가능 | Notion 자동 등록 |
| Tier 2 | Notion 연결 불가 | 내부 Markdown Todo 문서 |

- pipeline-orchestrator가 파이프라인 시작 시 Tier 자동 선택
- 각 게이트([STOP] 또는 [AUTO-PASS]) 통과 시 다음 Stage 태스크를 자동 등록
- 상세 구조: `{folderMap.templates}/notion-task-template.md` 참조

## Forge Dev 연동

### S4 완료 시 자동 액션

1. 기획 패키지 산출물 존재 확인
2. **Handoff 요약 문서 자동 생성**: `{folderMap.handoff}/{target-project}/YYYY-MM-DD-forge-handoff.md`
3. Forge Dev 진입 안내 메시지 Human에게 제공
4. **Human이 개발 프로젝트로 이동하면 Forge Dev 자동 발동** (Implicit Entry)

### Forge 산출물 → Forge Dev 매핑

| Forge 산출물 | Forge Dev 활용 시점 |
|-------------|----------------|
| S1 리서치 | Phase 1 컨텍스트 참고 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석, Phase 2 Spec 작성 입력 |
| S4 기획 패키지 | Phase 1 세션 이해, Phase 2 Spec 작성 입력 |
| S4 Forge Dev 세션 로드맵 | Forge Dev 세션별 범위/산출물 가이드 |

## 게이트 유형

| 유형 | 동작 | 사용 |
|------|------|------|
| **[STOP]** | AI 검증 → 파이프라인 중단 → Human 승인 대기 | 전략적 판단 필요 (S2, S3) |
| **[AUTO-PASS]** | AI 검증 → 알림 출력 → 자동 진행 | 기계적 검증 충분 (S1, S4) |

[AUTO-PASS] 알림 형식:
- `✅ {Stage} Gate AUTO-PASS: {DoD 요약}`
- `→ {다음 Stage}로 자동 진행합니다. 이상 있으면 말씀해주세요.`
- Human은 언제든 "잠깐, {Stage} 다시 봐줘"로 소급 개입 가능
- 자동 검증 FAIL 시 → [STOP]으로 에스컬레이션

## 게이트 로그 메커니즘

각 게이트([STOP] 또는 [AUTO-PASS]) 통과 시 프로젝트 폴더에 `gate-log.md`를 자동 생성/업데이트한다.

```markdown
## Gate Log — {프로젝트명}

| Stage | 결과 | 일자 | 세션 | 조건 | humanDecision | humanOverride | reviewDuration | 비고 |
|:-----:|:----:|------|:----:|------|:------------:|:---:|:---:|------|
| S1 | ✅ AUTO | YYYY-MM-DD | 1 | DoD 자동 검증 통과 | auto | false | — | 신뢰도 High 72% |
| S2 | ✅ PASS | YYYY-MM-DD | 1 | Go/No-Go 85점 | approved | true | reviewed | AI 추천 수정 후 승인 |
| S3 | — | — | — | — | — | — | — | |
| S4 | — | — | — | — | — | — | — | |
```

**필드 설명**:
- `humanOverride`: true = Human이 AI 추천을 수정 후 승인 / false = AI 추천 그대로 승인
- `reviewDuration`: "instant" (<30초) 또는 "reviewed" (30초+) — 고무도장 승인 감지용

**월간 리뷰 지표**:
- Override Rate = humanOverride=true 건수 / 전체 [STOP] 게이트 수
- Rubber-Stamp Rate = reviewDuration="instant" 건수 / 전체 [STOP] 게이트 수

## Stage별 DoD (Definition of Done)

각 게이트 통과 전 DoD 체크리스트를 검증한다.
상세 체크리스트: `{folderMap.templates}/dod-checklist.md`

## Stage별 방법론 참조

> 상세 방법론 설명은 `docs/planning/done/2026-02-27-forge-pipeline-architecture.md` 참조

| Stage | 필수 방법론 | 선택 방법론 |
|:-----:|-----------|-----------|
| S1 | AI-augmented Research, JTBD, Competitive Intelligence, Evidence-Based Mgmt | SOAR, PESTLE |
| S2 | Pretotyping, Mom Test, Lean Validation, TAM/SAM/SOM, OKR | OST, PR/FAQ |
| S3 | Shape Up Pitch, User Story Mapping, Modern PRD | Outcome-based Roadmap, Event Storming |
| S4 | Now/Next/Later, RICE/ICE, C4 Model, ADR | WSJF |
| 거버넌스 | Stage-Gate, Go/No-Go, DACI, Double Diamond | Pre-mortem |
| 관리 | Personal Kanban, Decision Log | — |

## 병렬 멀티 프로젝트

각 프로젝트가 독립 Subagent로 병렬 실행 가능:

```
Project A (게임 S1~S4) ────→ Forge Dev
Project B (앱 S1~S4) ──────→ Forge Dev
Project C (웹 S1~S4) ──────→ Forge Dev
```

## Playground 활용 가이드 (선택적)

Playground Plugin이 설치된 환경에서, 기획 중 시각적 탐색이 필요하면 아래 매핑에 따라 Playground 템플릿을 활용한다.

| Stage | 템플릿 | 활용 시점 |
|:-----:|:------:|----------|
| S1 | concept-map | 시장 구조, 경쟁사 관계, 기술 트렌드 맵핑 |
| S1 | data-explorer | TAM/SAM/SOM 수치, 시장 데이터 시각 탐색 |
| S2 | concept-map | 컨셉 관계도, 핵심 가치 제안 맵핑 |
| S3/S4 | design-playground | UI 레이아웃, 컬러, 타이포그래피 의사결정 |
| S4 | code-map | 아키텍처 시각화, 모듈 관계도 |
| 모든 Gate | document-critique | [STOP] Gate에서 구조화된 문서 리뷰 |

- Playground는 **권장 도구**이며 필수가 아니다
- 생성된 HTML 파일은 일회성 탐색 도구로 사용. Git에 커밋하지 않는다
- `playground:playground` 스킬 호출로 생성한다

## S4 시작 시 보고

S4 Wave 1 시작 전:
1. 3종 산출물 작성 순서를 Human에게 간략 보고 (승인 대기 아님)
2. 관리자 산출물 포함 여부 확인
3. 즉시 Wave 1 진행

> S3는 에이전트 회의(Competing Hypotheses)가 구조 검증 역할을 대체하므로 별도 Intra-Gate를 수행하지 않는다.

## Do

- 시각적 탐색이 필요한 기획 단계에서 Playground 활용을 검토한다
- Stage별 DoD 체크리스트를 게이트 판단 전 확인한다
- 게이트 통과 시 gate-log.md를 자동 업데이트한다
- PM 도구 Tier를 파이프라인 시작 시 자동 판단하고, 게이트 통과 시 태스크를 등록한다
- 모델 계층화(Opus/Sonnet/Haiku)를 작업 성격에 맞게 적용한다

## Don't

- 게이트 통과 시 gate-log.md 업데이트를 생략하지 않는다
- DoD 체크리스트 검증 없이 게이트를 통과하지 않는다

## AI 행동 규칙

1. Stage별 DoD 체크리스트를 게이트 판단 전 확인한다
2. 게이트 통과 시 gate-log.md를 자동 업데이트한다
3. PM 도구 Tier를 파이프라인 시작 시 자동 판단하고, 게이트 통과 시 태스크를 등록한다
4. S4 완료 후 Forge Dev Handoff 문서를 자동 생성하고 진입을 안내한다
