# SIGIL 파이프라인 — PM 도구 연동 가이드

**용도**: SIGIL Stage 진행 시 작업/태스크를 외부 PM 도구 또는 내부 Todo 문서에 등록하는 구조 정의

---

## 1. 2-Tier Fallback 구조

```
[1차] 외부 PM 도구 연동 가능?
  ├─ Yes → Tier 1: Notion MCP에 자동 등록
  └─ No  → Tier 2: 내부 Markdown Todo 문서로 관리
```

**자동 판단**: pipeline-orchestrator가 파이프라인 시작 시 Notion MCP 연결 상태를 확인하여 Tier 자동 선택.
Human이 수동으로 Tier를 지정할 수도 있음.

---

## 2. Tier 1 — Notion Database 등록 구조

### 2.1 Database 스키마

| 속성 | 타입 | 값 예시 | 필수 |
|------|------|--------|:----:|
| Title | Title | "S1 시장 조사 보고서 작성" | **필수** |
| Stage | Select | S1 / S2 / S3 / S4 / Trine | **필수** |
| Status | Status | Not Started / In Progress / Done | **필수** |
| 담당 | Select | AI / Human / AI+Human | **필수** |
| Priority | Select | P0 / P1 / P2 / P3 | **필수** |
| 기한 | Date | 2026-03-01 | 선택 |
| 프로젝트 | Select | {project name} | **필수** |
| 산출물 경로 | URL/Text | `{folderMap.research}/{project}/...` | 선택 |
| DoD 항목 | Checkbox | 연동된 DoD 체크리스트 항목 | 선택 |
| 비고 | Rich Text | 추가 메모 | 선택 |

### 2.2 Stage별 등록 항목

#### S1 완료 시
| 태스크 | 담당 | 우선순위 |
|--------|:----:|:--------:|
| 리서치 결과 리뷰 | Human | P0 |
| 방향 확정 결정 | Human | P0 |
| S2 컨셉 작업 시작 | AI | P1 |

#### S2 완료 시
| 태스크 | 담당 | 우선순위 |
|--------|:----:|:--------:|
| Go/No-Go 스코어 확인 | Human | P0 |
| Lean Canvas 리뷰 | Human | P1 |
| Mom Test 인터뷰 계획 수립 (AI 초안) | AI | P1 |
| Mom Test 인터뷰 실행 | Human | P1 |
| Pretotype 실행 계획 (AI 초안) | AI | P2 |
| Pretotype 실행 | Human | P2 |
| S3 기획서 작성 시작 | AI | P1 |

#### S3 완료 시
| 태스크 | 담당 | 우선순위 |
|--------|:----:|:--------:|
| 기획서 리뷰 | Human | P0 |
| PPT 버전 확인 | Human | P1 |
| S4 기획 패키지 작성 시작 | AI | P1 |

#### S4 완료 시
| 태스크 | 담당 | 우선순위 |
|--------|:----:|:--------:|
| 기획 패키지 최종 리뷰 | Human | P0 |
| Trine 세션 시작 | AI+Human | P0 |

### 2.3 Notion MCP 호출 패턴

```
[게이트 통과 시 자동 실행]
1. notion-search → 프로젝트 Database 존재 확인
2. 없으면 → notion-create-database (위 스키마 기반)
3. notion-create-pages → 다음 Stage 태스크 배치 등록
4. 기존 태스크 → notion-update-page → Status 업데이트
```

---

## 3. Tier 2 — 내부 Todo 문서 Fallback

### 3.1 파일 경로

```
{folderMap.product}/{project}/YYYY-MM-DD-todo.md
```

### 3.2 문서 구조

```markdown
# {프로젝트명} — SIGIL Todo Tracker

**최종 업데이트**: YYYY-MM-DD
**현재 Stage**: S{N}

---

## S1 Research
| # | 태스크 | 담당 | 상태 | 비고 |
|:-:|--------|:----:|:----:|------|
| 1 | 시장 조사 보고서 | AI | ✅ | 완료일: YYYY-MM-DD |
| 2 | 경쟁사 분석 | AI | ✅ | |
| 3 | 리서치 결과 리뷰 | Human | ✅ | 승인일: YYYY-MM-DD |

**게이트**: ✅ 통과 (YYYY-MM-DD)

## S2 Concept
| # | 태스크 | 담당 | 상태 | 비고 |
|:-:|--------|:----:|:----:|------|
| 1 | Lean Canvas 작성 | AI | 🔄 | |
| 2 | Go/No-Go 스코어링 | AI | ⬜ | |
| 3 | Mom Test 인터뷰 계획 | AI | ⬜ | |
| 4 | Mom Test 인터뷰 실행 | Human | ⬜ | |

**게이트**: ⬜ 대기

## S3 Design Document
(Stage 진입 시 자동 생성)

## S4 Planning Package
(Stage 진입 시 자동 생성)

## Trine 개발 진행
(S4 완료 후 자동 생성 — 스펙 단위 칸반)

| # | Spec | Session | SP | Status | PR | 완료일 |
|:-:|------|:-------:|:--:|:------:|:--:|:------:|
| 1 | {Spec 이름} | S{N} | {SP} | ⬜ Todo | — | — |
| ... | ... | ... | ... | ... | ... | ... |

**상태 흐름**: ⬜ Todo → 🔄 Doing → 🧪 QA → ✅ Done
```

### 3.3 상태 표기

| 표기 | 의미 |
|:----:|------|
| ⬜ / ⬜ Todo | pending (미시작) |
| 🔄 / 🔄 Doing | in-progress (브랜치 생성 후) |
| 🧪 QA | Check 3 진입 (품질 검수 중) |
| ✅ / ✅ Done | done (완료 / PR Merge) |
| ❌ | blocked (차단됨) |
| ⏭️ | skipped (스킵) |

---

## 4. Trine 세션 Todo 연동

S4 상세 개발 계획서의 "Trine 세션 로드맵"이 확정되면, 스펙 단위 칸반 테이블을 동일 문서(Tier 2) 또는 Notion(Tier 1)에 자동 등록한다.

### 스펙 단위 칸반 생성 기준

S4 개발 계획의 Trine 세션 로드맵에서 추출:
- **Standard 세션**: 세션 = Spec 1개 = 행 1개
- **Multi-Spec 세션**: 도메인별 Spec = 행 N개 (SP는 마지막 행에 세션 합계 표기)

### 상태 전환 (AI 자동 감지)

| 이벤트 | Status 변경 | 감지 주체 |
|--------|:----------:|:---------:|
| 브랜치 생성 | ⬜ Todo → 🔄 Doing | AI (직접 실행) |
| Check 3 진입 | 🔄 Doing → 🧪 QA | AI (직접 실행) |
| PR Merge 완료 | 🧪 QA → ✅ Done + PR 번호 + 완료일 | AI (감지) |

---

## 사용법

1. pipeline-orchestrator가 파이프라인 시작 시 Tier 1/2 자동 선택
2. 각 [STOP] 게이트 통과 시 다음 Stage 태스크를 자동 등록
3. 태스크 상태는 작업 진행에 따라 자동 업데이트
4. Human 태스크는 등록만 하고 실행은 Human이 직접 수행
5. Trine 세션 시작 시 세션별 Todo를 자동 등록
