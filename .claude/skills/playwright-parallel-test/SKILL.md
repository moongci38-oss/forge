---
name: playwright-parallel-test
description: Run parallel UI tests using 3 subagents with Playwright CLI. Tests form validation, navigation/routing, and responsive layout simultaneously. Use when the user wants to run comprehensive UI tests, parallel browser tests, or says "UI 테스트", "폼 테스트", "parallel test".
user-invocable: true
---

# Playwright Parallel UI Test

3개 서브에이전트가 각각 다른 관점에서 동시에 UI를 테스트하는 메타스킬.

## 사전 조건

- `playwright-cli`가 설치되어 있어야 함 (`npx playwright-cli --help`)
- 테스트 대상 dev 서버가 실행 중이어야 함 (기본: `http://localhost:3000`)
- 프로젝트 루트에서 실행

## 실행 절차

### Step 1: 대상 확인

사용자에게 아래를 확인한다:

1. **테스트 URL**: dev 서버 주소 (기본: `http://localhost:3000`)
2. **테스트 범위**: 특정 페이지/폼 또는 전체 사이트
3. **헤디드 여부**: 브라우저를 보면서 할지 (기본: 헤드리스)

사용자가 URL만 제공하면 나머지는 기본값으로 진행한다.

### Step 2: 3-Agent 병렬 스폰

아래 3개 서브에이전트를 **동시에** Agent 도구로 스폰한다.

#### Agent A: 폼/입력 검증 (Form Validation)

```
프롬프트:
"playwright-cli로 {URL}의 모든 폼을 테스트하라.

테스트 시나리오:
1. 빈 값 제출 → 에러 메시지 확인
2. 유효하지 않은 이메일 형식 → 검증 에러
3. 최소/최대 길이 위반 → 검증 에러
4. 정상 값 제출 → 성공 확인
5. 특수문자 입력 → XSS 방지 확인

각 테스트:
- playwright-cli open {URL}
- playwright-cli snapshot → 폼 요소 식별
- 시나리오별 fill + click + snapshot
- 결과를 마크다운 테이블로 정리
- playwright-cli close

{헤디드 옵션: --headed 또는 생략}
결과 형식: PASS/FAIL 테이블 + 스크린샷 경로"
```

#### Agent B: 네비게이션/라우팅 (Navigation & Routing)

```
프롬프트:
"playwright-cli로 {URL}의 네비게이션과 라우팅을 테스트하라.

테스트 시나리오:
1. 메인 네비게이션 링크 전체 클릭 → 올바른 페이지 도달 확인
2. 404 페이지 → 존재하지 않는 경로 접근
3. 뒤로가기/앞으로가기 → 히스토리 정상 동작
4. 외부 링크 → target=_blank 확인
5. 앵커 링크 → 스크롤 위치 확인

각 테스트:
- playwright-cli open {URL}
- playwright-cli snapshot → 네비 요소 식별
- 링크별 click + goto + snapshot
- 페이지 타이틀/URL 확인
- playwright-cli close

결과 형식: 라우트별 PASS/FAIL 테이블"
```

#### Agent C: 반응형 레이아웃 (Responsive Layout)

```
프롬프트:
"playwright-cli로 {URL}의 반응형 레이아웃을 테스트하라.

뷰포트 3종:
1. Mobile: 375x812 (iPhone 14)
2. Tablet: 768x1024 (iPad)
3. Desktop: 1920x1080

각 뷰포트에서:
- playwright-cli open {URL}
- playwright-cli resize {width} {height}
- playwright-cli snapshot → 레이아웃 깨짐 확인
- playwright-cli screenshot --filename=responsive-{viewport}.png
- 햄버거 메뉴 동작 확인 (모바일)
- 텍스트 잘림/오버플로우 확인
- playwright-cli close

결과 형식: 뷰포트별 PASS/FAIL + 스크린샷 경로"
```

### Step 3: 결과 종합

3개 에이전트 결과를 수집하여 종합 리포트를 생성한다:

```markdown
# UI 테스트 결과 — {URL}
> 일시: {date} | 방식: 3-Agent 병렬

## 요약
| 영역 | 테스트 수 | PASS | FAIL | 비율 |
|------|:-------:|:----:|:----:|:----:|
| 폼 검증 | N | N | N | N% |
| 네비게이션 | N | N | N | N% |
| 반응형 | N | N | N | N% |
| **합계** | **N** | **N** | **N** | **N%** |

## FAIL 항목 상세
(있는 경우만)

## 스크린샷
(반응형 테스트 스크린샷 경로)
```

### Step 4: 리포트 저장

- Trine 세션 중: `docs/reviews/{date}-ui-test-results.md`
- 독립 실행: stdout 출력만 (파일 저장 안 함)

## 사용 예시

```
사용자: "/playwright-parallel-test http://localhost:3000"
사용자: "UI 테스트 돌려줘"
사용자: "폼 테스트 + 반응형 테스트 병렬로"
```

## 주의사항

- dev 서버가 실행 중이지 않으면 테스트 시작 전 안내
- WSL 환경에서는 헤드리스 기본 (WSLg 설정 없으면 헤디드 불가)
- 인증이 필요한 페이지는 사전에 state-save로 세션 저장 필요
