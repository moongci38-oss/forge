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

- **Projects DB URL**: https://www.notion.so/f5e9b91fa40441d4a8cef2f98ae8d26e
- **Tasks DB URL**: https://www.notion.so/afe1ec3c2cce4123ab91d1ec381f0c2c

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
- 판단 기준: `등록자=Human`이고 상태가 AI 예상값과 다르면 → **스킵** (덮어쓰지 않음)
- AI는 스킵 시 확인 메시지 출력: "Human이 수동 변경한 상태입니다. 덮어쓰지 않습니다."

## 버그/기능 자동 등록

- 사용자가 버그/기능을 언급하면 Tasks DB에 자동 등록
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

## DB 미존재 시 처리

- Projects DB 또는 Tasks DB가 없으면 `notion-create-database`로 먼저 생성
- 생성 후 이 규칙의 DB URL 업데이트 필요 (Human 확인 후)

## Trine + Notion 이중 처리

PR Merge 후 아래 두 곳을 모두 완료 처리한다:

| 대상 | 처리 방법 |
|------|---------|
| `docs/planning/active/sigil/todo.md` (Spec 칸반) | ✅ Done + PR 번호 + 완료일 기록 |
| Notion Tasks DB (해당 Task) | 상태=완료 + PR URL + 완료일 자동 기록 |

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
2. Human override 판단: `등록자=Human`이고 현재 상태≠예상 상태 → 스킵
3. 버그/기능 요청 언급 시 Projects DB에서 프로젝트 확인 후 Tasks DB 자동 등록
4. Hotfix 등록 시 Priority=P0-긴급 강제 설정
5. Tasks 등록 시 `프로젝트` 관계 필수 연결 (누락 시 등록 중단 + Human에게 프로젝트 확인 요청)
6. DB 미존재 시 notion-create-database로 먼저 생성
7. PR Merge 후 todo.md(Spec 칸반) + Notion Tasks 양쪽 모두 완료 처리
8. 작업자 필드가 비어있으면 Human에게 담당자 배정 요청

## Iron Laws

- **IRON-1**: Human이 수동 변경한 Notion 상태를 덮어쓰지 않는다
- **IRON-2**: Hotfix 등록 시 P0-긴급을 반드시 설정한다
- **IRON-3**: Projects DB 연결 없이 Task를 생성하지 않는다
