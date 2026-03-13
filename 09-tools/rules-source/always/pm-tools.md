---
id: pm-tools
title: "PM 도구 연동 규칙 (Notion Tasks)"
scope: always
impact: HIGH
---

# PM 도구 연동 규칙 (Notion Tasks)

> Notion Tasks DB와 Trine 파이프라인 이벤트 간 상태 자동 전환 규칙.
> Human override 우선 원칙, Hotfix P0 강제, 버그/기능 자동 등록.

## Notion DB 구조

```
📋 Projects DB  ←─ 관리자 대시보드 (전체 현황)
      │ 1:N (Tasks 관계 양방향)
      ▼
📌 Tasks DB     ←─ 프로젝트별 뷰 + 전체 칸반
```

- **DB URL**: `sigil-workspace.json`의 `notionDBs` 섹션에서 참조 (하드코딩 금지)

## 상태 자동 전환 규칙

### 흐름

```
할 일 ──[브랜치 생성]──▶ 진행중 ──[Check 3 진입]──▶ QA ──[PR Merge]──▶ 완료
  ▲                                                            │
  └────────────── Human 언제든 수동 override 가능 ──────────────┘
```

### Trine 이벤트 → Notion Tasks 자동 전환

| Trine 이벤트 | 상태 전환 | 추가 액션 |
|-------------|---------|---------|
| 브랜치 생성 (`feat/*`, `fix/*`) | 할 일 → 진행중 | 브랜치명 자동 기록 |
| Check 3 진입 (verify.sh 실행) | 진행중 → QA | — |
| PR Merge 완료 | QA → 완료 | PR URL + 완료일 자동 기록 |
| Hotfix 브랜치 생성 (`hotfix/*`) | 할 일 → 진행중 | 우선순위=P0-긴급 강제 설정 |
| Hotfix PR Merge | 진행중 → 완료 | QA 단계 선택적 적용 |

## Human Override 원칙

- Notion UI에서 언제든 상태 직접 변경 가능
- AI 자동 전환과 충돌 시 **Human 설정이 우선**
- 판단 기준: `등록자` **또는** `last_edited_by`가 Human이고 상태가 AI 예상값과 다르면 → **스킵** (덮어쓰지 않음)
- AI는 스킵 시 확인 메시지 출력: "Human이 수동 변경한 상태입니다. 덮어쓰지 않습니다."
- AI가 등록한 Task라도 Human이 Notion에서 상태를 수동 변경한 경우, `last_edited_by`를 확인하여 Human 의도를 존중한다

## 버그/기능 자동 등록

- 사용자가 **명시적으로 등록을 요청**할 때만 Tasks DB에 등록 (예: "등록해줘", "추가해줘", "올려줘", "만들어줘")
- 단순 언급/논의는 등록 트리거가 아님 — "이 버그가 있는 것 같다"는 등록 아님, "이 버그 등록해줘"는 등록
- 등록 시 필수: 프로젝트 연결 (`sigil-workspace.json` 참조로 프로젝트명 → Projects DB 매핑)
- 등록자 = AI, 우선순위 = P2-보통 (기본값)
- Hotfix 등록 시 예외: 우선순위 = P0-긴급 강제

### 자동 등록 API 패턴

```
1. notion-search → Tasks DB에서 중복 확인
2. 없으면 → notion-create-pages (data_source_id: Tasks DB)
   - 프로젝트 관계 필수 설정
   - 등록자 = AI
3. 있으면 → notion-update-page (상태만 변경)
```

## Notion MCP 연결 상태 감지

Trine 세션 시작 시 Notion MCP 연결 상태를 먼저 확인한다.

| 상태 | 판단 방법 | 행동 |
|------|---------|------|
| 연결 가능 | `notion-search` 호출 성공 | Tier 1 (Notion + todo.md) |
| 연결 불가 | `notion-search` 호출 실패/타임아웃 | Tier 2 Fallback (todo.md만) |

- Tier 2 전환 시 세션 내내 Notion 갱신 스킵 (매 이벤트마다 재시도하지 않음)
- 세션 중간에 연결 복구 시에도 Tier 전환하지 않음 (일관성 유지)

## DB 미존재 시 처리

- Projects DB 또는 Tasks DB가 없으면 `notion-create-database`로 먼저 생성
- 생성 후 이 규칙의 DB URL 업데이트 필요 (Human 확인 후)

## Trine + Notion 이중 처리

PR Merge 후 아래 두 곳을 모두 완료 처리한다:

| 대상 | 처리 방법 |
|------|---------|
| `docs/planning/active/sigil/todo.md` (Spec 칸반) | ✅ Done + PR 번호 + 완료일 기록 |
| Notion Tasks DB (해당 Task) | 상태=완료 + PR URL + 완료일 자동 기록 |

> **순서**: todo.md 갱신 완료 → Notion Tasks 갱신. Notion 갱신 실패 시 경고만 출력하고 파이프라인을 중단하지 않는다.

## Source of Truth 원칙

**`docs/planning/active/sigil/todo.md`가 유일한 Source of Truth**이다. Notion Tasks는 대시보드/공유 뷰로만 사용하며, 역동기화하지 않는다.

### 갱신 순서

todo.md 갱신이 항상 **먼저** 완료된 후 Notion Tasks를 갱신한다. Notion 갱신 실패 시 todo.md만으로 파이프라인은 중단 없이 진행한다.

### 갱신 주체 역할 매트릭스

| 대상 | 갱신 주체 | 시점 | 비고 |
|------|----------|------|------|
| todo.md (⬜→🔄 Doing) | GitHub Actions (자동) | branch create | todo-tracker.yml |
| todo.md (🔄→🧪 QA) | trine-pm-updater (AI) | Check 3 진입 | AI 세션 내 |
| todo.md (🧪→✅ Done) | GitHub Actions (자동) | PR merge | todo-tracker.yml |
| Notion Tasks 상태 전환 | trine-pm-updater (AI) | Trine 이벤트 후 | todo.md 갱신 완료 후에만 |
| Notion Tasks (Hotfix) | AI 직접 | Hotfix 등록 시 | P0-긴급 강제 |

## 담당자 역할

| 역할 | 속성명 | 활성 단계 | 설명 |
|------|--------|----------|------|
| **작업자** | 작업자 | 할 일→진행중 | 구현/수정 담당. 브랜치 생성 주체 |
| **QA 담당자** | QA 담당자 | QA | 기능 검증 및 버그 재현 테스트 |
| **검수자** | 검수자 | QA→완료 | PR 리뷰 + 최종 머지 승인 |

> 1인 운영 시: 작업자=검수자=Human, QA 담당자=AI (자동 체크)

## Human 등록 경로

| 경로 | 방법 | 등록자 표기 |
|------|------|-----------|
| Notion 직접 입력 | Tasks DB 또는 프로젝트 페이지 칸반 | Human |
| AI에게 말로 요청 | "portfolio-blog에 댓글 버그 등록해줘" | AI |
| Trine 파이프라인 | 브랜치/PR 이벤트 자동 생성 | AI |

## Do

- Trine 이벤트(브랜치/Check3/PR) 발생 시 Notion Tasks 상태 자동 전환
- Human이 수동 변경한 상태는 덮어쓰지 않음 (등록자+상태 비교로 판단)
- Hotfix 등록 시 P0-긴급 강제, QA 단계 선택적 적용
- Tasks 등록 시 프로젝트 연결 필수 (sigil-workspace.json 참조)
- PR Merge 후 todo.md + Notion Tasks 양쪽 모두 완료 처리

## Don't

- Human이 수동 변경한 Notion 상태를 덮어쓰지 않는다
- Projects DB 연결 없이 Task를 생성하지 않는다
- Hotfix 등록 시 P0-긴급 미설정으로 등록하지 않는다
- DB 미존재 상태에서 Tasks 추가를 시도하지 않는다 (생성 먼저)

## AI 행동 규칙

1. Trine 이벤트 발생 시 해당 Task 검색 후 상태 자동 전환
2. Human override 판단: `등록자=Human` **또는** `last_edited_by=Human`이고 현재 상태≠예상 상태 → 스킵
3. 버그/기능 등록은 **명시적 요청**("등록해줘", "추가해줘" 등) 시에만 실행. 단순 언급/논의는 등록 트리거가 아님
4. Hotfix 등록 시 Priority=P0-긴급 강제 설정
5. Tasks 등록 시 `프로젝트` 관계 필수 연결 (누락 시 등록 중단 + Human에게 프로젝트 확인 요청)
6. DB 미존재 시 notion-create-database로 먼저 생성
7. PR Merge 후 todo.md(Spec 칸반) + Notion Tasks 양쪽 모두 완료 처리
8. 작업자 필드가 비어있으면 Human에게 담당자 배정 요청
9. todo.md 갱신을 Notion 갱신보다 항상 먼저 수행한다. Notion 실패 시 경고만 출력하고 파이프라인을 계속한다.
10. Trine 세션 시작 시 `notion-search`로 MCP 연결 상태를 확인한다. 실패 시 Tier 2 Fallback 선언 후 세션 내 Notion 갱신 전체 스킵.
11. Notion DB URL은 `sigil-workspace.json`의 `notionDBs`에서 참조한다. 규칙/템플릿에 하드코딩하지 않는다.

## Iron Laws

- **IRON-1**: Human이 수동 변경한 Notion 상태를 덮어쓰지 않는다
- **IRON-2**: Hotfix 등록 시 P0-긴급을 반드시 설정한다
- **IRON-3**: Projects DB 연결 없이 Task를 생성하지 않는다
