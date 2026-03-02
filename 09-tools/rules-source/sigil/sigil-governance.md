---
title: "SIGIL 거버넌스"
id: sigil-governance
impact: HIGH
scope: [sigil]
tags: [pipeline, gate, governance, model, pm]
requires: [sigil-structure]
section: sigil-pipeline
audience: all
impactDescription: "모델 계층화 미적용 시 토큰 비용 200-300% 증가. 게이트 로그 누락 시 프로젝트 이력 추적 불가"
enforcement: rigid
---

# SIGIL 거버넌스

## Agent Council 모드 (선택적)

> 상세: `.claude/rules/sigil-council-mode.md` 참조
> Human이 명시적으로 선택 시에만 활성화. 기본 모드와 양자택일.

## Agent Teams 활용

| 패턴 | 적용 시점 |
|------|----------|
| **Fan-out/Fan-in** | S1 리서치 (독립 영역 병렬), 멀티 프로젝트 병렬, Agent Council 라운드 1 |
| **Competing Hypotheses** | S3 기획서 에이전트 회의 (기본 모드) |
| **Pipeline** | S1→S2→S3→S4 순차 의존 |

## 모델 계층화

```
pipeline-orchestrator (Lead)    → Opus 4.6   (판단, 종합, 회의 심판)
기획서 작성 (gdd/prd/content)   → Sonnet 4.6 (문서 작성, 분석)
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
- 각 [STOP] 게이트 통과 시 다음 Stage 태스크를 자동 등록
- 상세 구조: `09-tools/templates/notion-task-template.md` 참조

## Trine 연동 (개발 트랙)

### S4 완료 시 자동 액션

1. 기획 패키지 산출물 존재 확인
2. **Handoff 요약 문서 자동 생성**: `10-operations/handoff-to-dev/{target-project}/YYYY-MM-DD-sigil-handoff.md`
3. Trine 진입 안내 메시지 Human에게 제공
4. **실제 Trine 세션 시작은 Human 승인 후 수동 실행** (`/trine` 커맨드)

### SIGIL 산출물 → Trine 매핑

| SIGIL 산출물 | Trine 활용 시점 |
|-------------|----------------|
| S1 리서치 | Phase 1 컨텍스트 참고 |
| S3 기획서 (PRD/GDD) | Phase 1.5 요구사항 분석, Phase 2 Spec 작성 입력 |
| S4 기획 패키지 | Phase 1 세션 이해, Phase 2 Spec 작성 입력 |
| S4 Trine 세션 로드맵 | Trine 세션별 범위/산출물 가이드 |

## 게이트 로그 메커니즘

각 [STOP] 게이트 통과 시 프로젝트 폴더에 `gate-log.md`를 자동 생성/업데이트한다.

```markdown
## Gate Log — {프로젝트명}

| Stage | 결과 | 일자 | 조건 | 비고 |
|:-----:|:----:|------|------|------|
| S1 | ✅ PASS | YYYY-MM-DD | DoD 전항목 충족 | |
| S2 | ✅ PASS | YYYY-MM-DD | Go/No-Go 85점 | |
| S3 | — | — | — | |
| S4 | — | — | — | |
```

## Stage별 DoD (Definition of Done)

각 [STOP] 게이트 통과 전 DoD 체크리스트를 검증한다.
상세 체크리스트: `09-tools/templates/dod-checklist.md`

## Stage별 방법론 참조

> 상세 방법론 설명은 `docs/planning/done/2026-02-27-sigil-pipeline-architecture.md` 참조

| Stage | 필수 방법론 | 선택 방법론 |
|:-----:|-----------|-----------|
| S1 | AI-augmented Research, JTBD, Competitive Intelligence, Evidence-Based Mgmt | SOAR, PESTLE |
| S2 | Pretotyping, Mom Test, Lean Validation, TAM/SAM/SOM, OKR | OST, PR/FAQ |
| S3 | Shape Up Pitch, User Story Mapping, Modern PRD | Outcome-based Roadmap, Event Storming |
| S4 | Now/Next/Later, RICE/ICE, Agile WBS, C4 Model, ADR | WSJF |
| 거버넌스 | Stage-Gate, Go/No-Go, DACI, Double Diamond | Pre-mortem |
| 관리 | Personal Kanban, Decision Log | — |

## 병렬 멀티 프로젝트

각 프로젝트가 독립 Agent Team으로 병렬 실행 가능:

```
Project A (게임 S1~S4) ────→ Trine
Project B (앱 S1~S4) ──────→ Trine
Project C (유튜브 S1~S4) ──→ 제작
Project D (쇼폼 S1~S3) ────→ 제작
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

## Intra-Stage Gate (Stage 내부 설계 승인)

S3, S4 시작 시 에이전트가 산출물 작성에 착수하기 전, 구조/접근 방식을 먼저 Human에게 제시하고 승인을 받는다.

### S3 Intra-Gate
1. 기획서 구조 제시 (목차, 핵심 섹션, 페이지 수 예상)
2. 에이전트 회의 참가자 + 각자 담당 관점 제시
3. Human 승인 후 초안 작성 진행

### S4 Intra-Gate
1. 7종 산출물 작성 순서 + 상호 의존성 제시
2. 각 산출물별 참조할 S3 입력 문서 명시
3. Human 승인 후 Wave Protocol 진행

> 간단한 프로젝트(S2에서 규모 소로 판정)는 Intra-Gate를 생략할 수 있다.

## Do

- 시각적 탐색이 필요한 기획 단계에서 Playground 활용을 검토한다
- Stage별 DoD 체크리스트를 게이트 판단 전 확인한다
- 게이트 통과 시 gate-log.md를 자동 업데이트한다
- PM 도구 Tier를 파이프라인 시작 시 자동 판단하고, 게이트 통과 시 태스크를 등록한다
- 모델 계층화(Opus/Sonnet/Haiku)를 작업 성격에 맞게 적용한다

## Don't

- Agent Council 모드를 Human 명시 선택 없이 활성화하지 않는다
- 게이트 통과 시 gate-log.md 업데이트를 생략하지 않는다
- DoD 체크리스트 검증 없이 게이트를 통과하지 않는다

## AI 행동 규칙

1. Stage별 DoD 체크리스트를 게이트 판단 전 확인한다
2. 게이트 통과 시 gate-log.md를 자동 업데이트한다
3. PM 도구 Tier를 파이프라인 시작 시 자동 판단하고, 게이트 통과 시 태스크를 등록한다
4. 개발 트랙 S4 완료 후 Trine Handoff 문서를 자동 생성하고 진입을 안내한다
