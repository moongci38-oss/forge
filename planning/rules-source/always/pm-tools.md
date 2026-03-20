---
id: pm-tools
title: "PM 도구 연동 규칙 (Notion Tasks)"
scope: always
impact: HIGH
---

# PM 도구 연동 규칙 (Notion Tasks)

> Notion Tasks DB가 작업 추적의 유일한 Source of Truth.
> Human override 우선 원칙, Hotfix P0 강제, 버그/기능 자동 등록.

## Notion DB 구조

```
📋 Projects DB  ←─ 관리자 대시보드 (전체 현황)
      │ 1:N (Tasks 관계 양방향)
      ▼
📌 Tasks DB     ←─ 프로젝트별 뷰 + 전체 칸반
```

- **DB URL**: `forge-workspace.json`의 `notionDBs` 섹션에서 참조 (하드코딩 금지)

## Source of Truth

**Notion Tasks DB가 유일한 Source of Truth**이다.

- `todo.md`는 S4 Gate PASS 시 초기 등록용(`register`)으로만 사용
- 이후 작업 추적은 Notion에서 직접 관리
- todo.md 자동 갱신은 하지 않음

## 상태 자동 전환 규칙

### 흐름

```
할 일 ──[브랜치 생성]──▶ 진행중 ──[Check 3 진입]──▶ QA ──[PR Merge]──▶ 완료
  ▲                                                            │
  └────────────── Human 언제든 수동 override 가능 ──────────────┘
```

### Forge Dev 이벤트 → Notion Tasks 자동 전환

| Forge Dev 이벤트 | 상태 전환 | 추가 액션 |
|-------------|---------|---------|
| 브랜치 생성 (`feat/*`, `fix/*`) | 할 일 → 진행중 | 브랜치명 자동 기록 |
| Check 3 진입 (verify.sh 실행) | 진행중 → QA | — |
| PR Merge 완료 | QA → 완료 | PR URL + 완료일 자동 기록 |
| Hotfix 브랜치 생성 (`hotfix/*`) | 할 일 → 진행중 | 우선순위=P0-긴급 강제 설정 |
| Hotfix PR Merge | 진행중 → 완료 | QA 단계 선택적 적용 |

## Human Override 원칙

- Notion UI에서 언제든 상태 직접 변경 가능
- AI 자동 전환과 충돌 시 **Human 설정이 우선**
- 판단 기준: `last_edited_by.type == "person"`이고 상태가 AI 예상값과 다르면 → **스킵** (덮어쓰지 않음)
- AI는 스킵 시 확인 메시지 출력: "Human이 수동 변경한 상태입니다. 덮어쓰지 않습니다."

## 등록 기준

**Spec 문서가 등록과 브랜치 생성의 전제 조건이다.**

```
Spec 작성 → Notion 등록 → 브랜치 생성 → 진행중 → PR → 완료
```

- **Spec 없이 브랜치 생성 금지** (예외 없음)
- **Spec 없이 Notion 등록 금지**
- Spec이 있는 작업만 Notion에 등록하고, 등록된 Task만 브랜치를 생성
- Hotfix도 Spec 작성 후 진행 (규모에 맞게 간소화 가능하나 생략 불가)
- 사용자가 **명시적으로 등록을 요청**할 때만 등록 (예: "등록해줘", "추가해줘")
- 단순 언급/논의는 등록 트리거가 아님
- 등록 시 필수: 프로젝트 연결 (`forge-workspace.json` 참조로 프로젝트명 → Projects DB 매핑)
- 등록자 = AI, 우선순위 = P2-보통 (기본값), Hotfix = P0-긴급 강제

### 자동 등록 API 패턴

```
1. notion-search → Tasks DB에서 중복 확인
2. 없으면 → notion-create-pages (data_source_id: Tasks DB)
   - 프로젝트 관계 필수 설정
   - 등록자 = AI
3. 있으면 → notion-update-page (상태만 변경)
```

## DB 미존재 시 처리

- Projects DB 또는 Tasks DB가 없으면 `notion-create-database`로 먼저 생성
- 생성 후 이 규칙의 DB URL 업데이트 필요 (Human 확인 후)

## 리서치 파이프라인 Notion 연동

`/daily-system-review` 및 `/daily-analyze` 실행 완료 후 Notion 페이지를 생성할 때,
**보고서 전체 내용을 Notion 페이지 본문(content)에 직접 삽입**한다.
파일 경로만 기록하거나 요약만 넣는 방식은 사용하지 않는다.

### 필수 절차

1. `Read("ai-system-analysis.md")` — 전체 내용 로드
2. `Read("system-improvement-plan.md")` — 전체 내용 로드
3. `mcp__notion__notion-create-pages` 호출 시 `content` 필드에 두 파일 전체를 `---` 구분선으로 이어 붙여 전달

```
content = {ai-system-analysis.md 전체} + "\n\n---\n\n" + {system-improvement-plan.md 전체}
```

### Don't

- `content`에 요약/발췌만 넣지 않는다
- 파일 경로 링크만 넣고 본문을 생략하지 않는다
- 두 파일 중 하나라도 Read 없이 content를 구성하지 않는다

## 갱신 주체 역할 매트릭스

| 대상 | 갱신 주체 | 시점 | 비고 |
|------|----------|------|------|
| Notion Tasks (할 일→진행중) | GitLab CI (자동) | branch create | sync-notion-tasks.py `doing` |
| Notion Tasks (진행중→QA) | AI (세션 내) | Check 3 진입 | notion-update-page 직접 호출 |
| Notion Tasks (→완료) | GitLab CI (자동) | PR merge | sync-notion-tasks.py `done` |
| Notion Tasks (초기 등록) | AI 또는 수동 | S4 Gate PASS | sync-notion-tasks.py `register` |
| Notion Tasks (Hotfix) | AI 직접 | Hotfix 등록 시 | P0-긴급 강제 |

### GitLab CI 자동 Notion 갱신

`todo-tracker.yml` 워크플로가 브랜치/PR 이벤트 시 `sync-notion-tasks.py`를 호출하여 Notion Tasks DB를 직접 갱신한다.

**전제 조건:**
1. GitLab CI/CD Variables에 `NOTION_API_TOKEN` 설정 (Notion Internal Integration 토큰)
2. 프로젝트 `.specify/config.json`에 `notion.tasksDbId`와 `notion.projectName` 설정
3. Notion Tasks DB에 해당 Integration 연결 (1회)

**토큰 미설정 시:** 워크플로 전체 스킵 (graceful skip)

**스크립트 액션:**

| 액션 | 트리거 | 동작 |
|------|--------|------|
| `register` | S4 Gate PASS (로컬 실행) | todo.md 전체 행을 Notion에 일괄 등록 (idempotent) |
| `doing` | GitLab CI (branch create) | Notion에서 키워드 매칭 → 상태 "진행중" + 브랜치명 기록 |
| `done` | GitLab CI (PR merge) | Notion에서 키워드 매칭 → 상태 "완료" + PR URL + 완료일 기록 |

**설정 파일 구조 (`.specify/config.json`):**
```json
{
  "notion": {
    "projectName": "GodBlade",
    "tasksDbId": "afe1ec3c2cce4123ab91d1ec381f0c2c"
  }
}
```

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
| Forge Dev 파이프라인 | 브랜치/PR 이벤트 자동 생성 | AI |

## Do

- Forge Dev 이벤트(브랜치/Check3/PR) 발생 시 Notion Tasks 상태 자동 전환
- Human이 수동 변경한 상태는 덮어쓰지 않음 (`last_edited_by` 확인)
- Hotfix 등록 시 P0-긴급 강제, QA 단계 선택적 적용
- Tasks 등록 시 프로젝트 연결 필수 (forge-workspace.json 참조)

## Don't

- Human이 수동 변경한 Notion 상태를 덮어쓰지 않는다
- Projects DB 연결 없이 Task를 생성하지 않는다
- Hotfix 등록 시 P0-긴급 미설정으로 등록하지 않는다
- DB 미존재 상태에서 Tasks 추가를 시도하지 않는다 (생성 먼저)

## AI 행동 규칙

1. Forge Dev 이벤트 발생 시 해당 Task 검색 후 상태 자동 전환
2. Human override 판단: `last_edited_by.type == "person"`이고 현재 상태 ≠ 예상 상태 → 스킵
3. 버그/기능 등록은 **명시적 요청**("등록해줘", "추가해줘" 등) 시에만 실행. 단순 언급/논의는 등록 트리거가 아님
4. Hotfix 등록 시 Priority=P0-긴급 강제 설정
5. Tasks 등록 시 `프로젝트` 관계 필수 연결 (누락 시 등록 중단 + Human에게 프로젝트 확인 요청)
6. DB 미존재 시 notion-create-database로 먼저 생성
7. 작업자 필드가 비어있으면 Human에게 담당자 배정 요청
8. Notion DB URL은 `forge-workspace.json`의 `notionDBs`에서 참조한다. 규칙/템플릿에 하드코딩하지 않는다.

## Iron Laws

- **PM-IRON-1**: Human이 수동 변경한 Notion 상태를 덮어쓰지 않는다
- **PM-IRON-2**: Hotfix 등록 시 P0-긴급을 반드시 설정한다
- **PM-IRON-3**: Projects DB 연결 없이 Task를 생성하지 않는다
