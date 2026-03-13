# Notion 프로젝트 관리 시스템 — 구조 가이드

**용도**: Trine+SIGIL 파이프라인의 작업/버그/기능을 Notion에서 통합 관리하는 구조 정의

---

## DB 아키텍처

```
📋 Projects DB  ←─ 관리자 대시보드 (전체 현황 한눈에)
      │ 1:N (양방향 관계)
      ▼
📌 Tasks DB     ←─ 프로젝트별 뷰 (해당 프로젝트 태스크만)
```

### Notion DB URLs

> **Source of Truth**: `sigil-workspace.json`의 `notionDBs` 섹션에서 참조.
> 아래 URL은 참조용이며, 변경 시 반드시 `sigil-workspace.json`을 업데이트한다.

- **Projects DB**: `notionDBs.projects`
- **Tasks DB**: `notionDBs.tasks`
- **Daily System Review DB**: `notionDBs.dailyReview`
- **Weekly Research DB**: `notionDBs.weeklyResearch`

---

## 1. Projects DB 스키마

| 속성 | 타입 | 옵션/설명 |
|------|------|----------|
| 프로젝트 이름 | Title | — |
| 상태 | Status | 할 일 / 진행 중 / 완료 |
| 우선순위 | Select | 높음(빨강) / 보통(노랑) / 낮음(초록) |
| 시작일 | Date | — |
| 담당자 | Person | — |
| SIGIL 단계 | Select | S1(파랑) / S2(초록) / S3(노랑) / S4(주황) / Trine(보라) / 완료(회색) |
| 오픈 버그 수 | Rollup | Tasks → 유형=버그/핫픽스 + 상태≠완료 집계 |
| 진행중 태스크 | Rollup | Tasks → 상태=진행중 집계 |
| Tasks | Relation | → Tasks DB (양방향) |
| 설명 | Rich Text | — |

### Projects DB 뷰

| 뷰 이름 | 타입 | 목적 |
|--------|------|------|
| 전체 현황 | Board (상태별) | 모든 프로젝트 진행 단계 한눈에 |
| 모든 프로젝트 | Table | 오픈 버그 수, 진행중 태스크 포함 전체 목록 |
| 로드맵 | Timeline | 프로젝트 일정 간트 |
| 긴급 이슈 | Filter (오픈 버그>0) | 버그 있는 프로젝트만 |

---

## 2. Tasks DB 스키마

| 속성 | 타입 | 옵션/설명 |
|------|------|----------|
| 제목 | Title | 기능명 / 버그 설명 |
| 프로젝트 | Relation | → Projects DB (필수) |
| 유형 | Select | 신규기능(파) / 기능추가(초) / 업그레이드(보라) / 버그(주황) / 핫픽스(빨강) |
| 우선순위 | Select | P0-긴급(빨강) / P1-높음(주황) / P2-보통(노랑) / P3-낮음(초록) |
| 상태 | Status | 할 일 → 진행중 → QA → 완료 |
| 작업자 | Person | 할 일/진행중 단계 담당자 |
| QA 담당자 | Person | QA 단계 검증 담당자 |
| 검수자 | Person | 최종 완료 승인자 (PR 리뷰어) |
| 등록자 | Select | AI(파랑) / Human(초록) |
| 브랜치 | Text | feat/auth-login |
| PR | URL | GitHub PR 링크 |
| Spec | Text | Spec 파일명 |
| SP | Number | Story Points |
| 마감일 | Date | — |
| 완료일 | Date | PR merge 날짜 자동 기록 |
| 설명 | Rich Text | 재현 방법, 요청 배경 등 |

### Tasks DB 뷰

| 뷰 이름 | 타입 | 필터 | 목적 |
|--------|------|------|------|
| 전체 칸반 | Board (상태별) | 없음 | 모든 프로젝트 통합 칸반 |
| P0 긴급 | Table | 우선순위=P0-긴급 | 핫픽스 즉시 확인 |
| 버그/핫픽스 | Board | 유형=버그 or 핫픽스 | 이슈 전용 뷰 |
| 기능 백로그 | Table | 유형=신규기능 or 기능추가 or 업그레이드, 상태=할 일 | 개발 대기 목록 |

---

## 3. 상태 자동 전환 규칙

### 흐름

```
할 일 ──[브랜치 생성]──▶ 진행중 ──[Check 3 진입]──▶ QA ──[PR Merge]──▶ 완료
  ▲                                                          │
  └────────────── Human 언제든 수동 override 가능 ────────────┘
```

### Trine 이벤트 매핑

| Trine 이벤트 | 상태 전환 | 추가 액션 |
|-------------|---------|---------|
| 브랜치 생성 (`feat/*`, `fix/*`) | 할 일 → 진행중 | 브랜치명 자동 기록 |
| Check 3 진입 | 진행중 → QA | — |
| PR Merge | QA → 완료 | PR URL + 완료일 자동 기록 |
| Hotfix 브랜치 (`hotfix/*`) | 할 일 → 진행중 | P0-긴급 강제 설정 |
| Hotfix PR Merge | 진행중 → 완료 | QA 선택적 |

### Human Override 원칙

- Human이 Notion에서 직접 변경한 상태는 AI가 덮어쓰지 않음
- 판단 기준: `등록자=Human`이고 상태가 AI 예상값과 다르면 → 스킵

---

## 4. 담당자 역할 정의

| 역할 | 속성명 | 활성 단계 | 설명 |
|------|--------|----------|------|
| **작업자** | 작업자 | 할 일→진행중 | 구현/수정 담당 |
| **QA 담당자** | QA 담당자 | QA | 기능 검증 테스트 |
| **검수자** | 검수자 | QA→완료 | PR 리뷰 + 최종 머지 승인 |

> 1인 운영 시: 작업자=검수자=Human, QA 담당자=AI

---

## 5. Human 등록 경로

| 경로 | 방법 | 등록자 표기 |
|------|------|-----------|
| Notion 직접 입력 | Tasks DB 또는 프로젝트 페이지 칸반 | Human |
| AI에게 말로 요청 | "portfolio-blog에 댓글 버그 등록해줘" | AI |
| Trine 파이프라인 | 브랜치/PR 이벤트 자동 생성 | AI |

---

## 6. 프로젝트 개별 페이지 내 Linked View

각 프로젝트 페이지에 Tasks DB Linked View 3개 삽입:
- **칸반** — 해당 프로젝트 전체 태스크, 상태별 그룹
- **버그** — 유형=버그/핫픽스 필터
- **기능 목록** — 유형=신규기능/기능추가/업그레이드 필터

---

## 7. Tier 2 Fallback — 내부 Todo 문서

Notion MCP 미연결 시 `docs/planning/active/sigil/todo.md` 사용.

### 상태 표기

| 표기 | 의미 |
|:----:|------|
| ⬜ Todo | pending (미시작) |
| 🔄 Doing | in-progress (브랜치 생성 후) |
| 🧪 QA | Check 3 진입 (품질 검수 중) |
| ✅ Done | done (완료 / PR Merge) |

### Trine 개발 칸반 (S4 Gate PASS 후 자동 생성)

```markdown
## Trine 개발 진행

| # | Spec | Type | Session | SP | Status | PR | 완료일 |
|:-:|------|:----:|:-------:|:--:|:------:|:--:|:------:|
| 1 | {Spec 이름} | feat | S{N} | {SP} | ⬜ Todo | — | — |
```

**Type 컬럼 값**: `feat` (신규기능) / `fix` (버그수정) / `hotfix` (긴급수정) / `upgrade` (기능개선)

> Notion MCP 미연결 시 (Tier 2 Fallback) Type 컬럼으로 최소한의 유형/우선순위 정보를 보존한다.

**상태 흐름**: ⬜ Todo → 🔄 Doing (브랜치 생성) → 🧪 QA (Check 3) → ✅ Done (PR Merge)
