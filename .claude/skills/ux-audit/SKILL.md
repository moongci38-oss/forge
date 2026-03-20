---
name: ux-audit
description: "Runs a 9-item UX quality audit (Color Contrast, Font Size, Touch Target, Layout Consistency, Navigation, 3-State Coverage, Responsive, Accessibility, Interaction Feedback) on frontend changes. Returns structured JSON with PASS/WARN/FAIL per item and auto-fix suggestions. Auto-triggered in Forge Dev Check 3.6 when .tsx/.jsx/.css files are changed."
allowed-tools:
  - Read
  - Grep
  - Glob
  - Agent
user-invocable: false
---

# UX Audit Skill (Check 3.6 — UX Quality Gate)

> Forge Dev Check 3.6에서 자동 트리거. 프론트엔드 변경이 포함된 PR에서 UI/UX 품질을 9항목으로 검증한다.
> 출처: "디자인 오류 90%를 해결한 방법" 영상 기반 체크리스트.

## 실행 조건

- Forge Dev Phase 3 Check 3.5 이후, PR 생성 전
- 변경 파일에 `.tsx`, `.jsx`, `.css`, `.scss`, `.html` 포함 시 트리거
- 변경 파일이 백엔드만(`.service.ts`, `.controller.ts` 등)이면 **SKIP**

## 9-Item UX Audit Checklist

### UX-1: Color Contrast (색상 대비)

| 항목 | 내용 |
|------|------|
| **설명** | 텍스트와 배경 간 색상 대비가 WCAG AA 기준을 충족하는지 검증 |
| **심각도** | **CRITICAL** |
| **PASS 기준** | 일반 텍스트 대비율 >= 4.5:1, 대형 텍스트(18px+ bold 또는 24px+) >= 3:1 |
| **FAIL 기준** | 대비율 4.5:1 미만인 텍스트-배경 조합이 1개 이상 존재 |
| **검증 방법** | CSS/Tailwind에서 텍스트 색상 + 배경 색상 쌍 추출 → 대비율 계산 |
| **자동 수정** | 대비 부족 색상을 동일 색조(hue)에서 명도(lightness)만 조정하여 4.5:1 달성. 디자인 토큰이 있으면 가장 가까운 토큰으로 교체 |

**검증 패턴:**
```
- text-gray-400 on bg-white → 대비율 계산
- color: #999 on background: #fff → 대비율 계산
- opacity 적용된 텍스트 → 유효 대비율 계산
```

---

### UX-2: Font Size / Readability (글꼴 크기 / 가독성)

| 항목 | 내용 |
|------|------|
| **설명** | 본문 텍스트 최소 크기와 줄 간격이 가독성 기준을 충족하는지 검증 |
| **심각도** | **HIGH** |
| **PASS 기준** | 본문(body) 텍스트 >= 16px, line-height >= 1.4, 캡션/보조 텍스트 >= 12px |
| **FAIL 기준** | 본문 텍스트가 16px 미만이거나 line-height가 1.2 미만 |
| **검증 방법** | 글로벌 스타일, Tailwind config, CSS에서 font-size/line-height 추출 |
| **자동 수정** | `font-size` 값을 16px(1rem)으로 상향. `line-height`를 1.5로 조정. Tailwind인 경우 `text-base leading-relaxed` 클래스로 교체 |

**검증 패턴:**
```
- font-size: 14px (body) → FAIL
- text-sm (Tailwind, 14px) on body text → FAIL
- text-xs (12px) on caption → PASS (보조 텍스트)
```

---

### UX-3: Touch Target Size (터치 영역 크기)

| 항목 | 내용 |
|------|------|
| **설명** | 버튼, 링크, 인터랙티브 요소의 터치 영역이 최소 크기를 충족하는지 검증 |
| **심각도** | **CRITICAL** |
| **PASS 기준** | 인터랙티브 요소 최소 44x44px (WCAG 2.5.5 AAA) 또는 padding 포함 44px 이상 |
| **FAIL 기준** | 클릭/탭 가능 요소가 44x44px 미만이고 padding으로도 보완되지 않음 |
| **검증 방법** | `<button>`, `<a>`, `role="button"`, `onClick` 요소의 width/height/padding 분석 |
| **자동 수정** | `min-height: 44px; min-width: 44px` 추가. 아이콘 버튼은 `p-3`(12px padding) 추가로 44px 달성. 인라인 링크는 `py-2` 추가 |

**검증 패턴:**
```
- <button class="p-1"> (8px padding, ~24px total) → FAIL
- <IconButton size="sm"> (32px) → FAIL
- <a> inline link without padding → WARN (텍스트 링크는 예외 허용)
```

---

### UX-4: Layout Consistency (레이아웃 일관성)

| 항목 | 내용 |
|------|------|
| **설명** | 간격(spacing), 정렬(alignment), 그리드 시스템이 페이지 전반에서 일관적인지 검증 |
| **심각도** | **MEDIUM** |
| **PASS 기준** | 동일 계층 요소에 동일한 spacing 토큰 사용, 4px/8px 배수 그리드 준수 |
| **FAIL 기준** | 같은 수준의 요소에 3가지 이상 다른 spacing 값 사용, 또는 홀수 px 값(5px, 7px, 13px 등) 존재 |
| **검증 방법** | 변경 파일 내 margin/padding/gap 값 수집 → 4/8px 배수 여부 + 일관성 분석 |
| **자동 수정** | 비표준 spacing을 가장 가까운 4px 배수로 반올림. Tailwind인 경우 표준 spacing 클래스(`gap-2`, `gap-4`, `p-4` 등)로 교체 |

**검증 패턴:**
```
- margin: 13px → FAIL (가장 가까운 배수: 12px 또는 16px)
- gap: 10px + gap: 12px + gap: 15px (같은 리스트) → FAIL (불일치)
- p-4 일관 사용 → PASS
```

---

### UX-5: Navigation Clarity (내비게이션 명확성)

| 항목 | 내용 |
|------|------|
| **설명** | 사용자가 현재 위치를 인지하고 원하는 곳으로 이동할 수 있는지 검증 |
| **심각도** | **HIGH** |
| **PASS 기준** | (1) 현재 페이지 active 상태 시각적 구분 존재, (2) depth 2+ 페이지에 breadcrumb 또는 back 네비게이션 존재, (3) 네비게이션 항목이 7개 이하 (Miller's Law) |
| **FAIL 기준** | active 상태 스타일 누락, 또는 하위 페이지에 상위 이동 수단 없음 |
| **검증 방법** | 네비게이션 컴포넌트에서 `active`, `aria-current`, `isActive`, `pathname` 비교 로직 확인. 라우트 depth 분석 |
| **자동 수정** | active 상태 누락 시 `aria-current="page"` + 시각 스타일(`font-bold`, `border-b-2` 등) 추가. Breadcrumb 컴포넌트 스켈레톤 생성 제안 |

**검증 패턴:**
```
- <NavLink> without activeClassName → FAIL
- /dashboard/settings/profile without breadcrumb → FAIL
- 10+ top-level nav items → WARN
```

---

### UX-6: Loading / Error / Empty States (3-State 커버리지)

| 항목 | 내용 |
|------|------|
| **설명** | 데이터를 표시하는 모든 화면에 로딩/에러/빈 상태 UI가 구현되어 있는지 검증 |
| **심각도** | **HIGH** |
| **PASS 기준** | 데이터 fetch가 있는 컴포넌트에서 loading/error/empty 3가지 상태가 모두 핸들링됨 |
| **FAIL 기준** | fetch 후 loading 또는 error 상태 처리 누락 (빈 화면 또는 무한 스피너) |
| **검증 방법** | `useQuery`, `useSWR`, `fetch`, `axios` 호출 위치에서 `isLoading`/`isError`/`data.length === 0` 분기 확인 |
| **자동 수정** | 누락된 상태별 스켈레톤 코드 제안: `if (isLoading) return <Skeleton />`, `if (error) return <ErrorMessage />`, `if (!data?.length) return <EmptyState />` |

**검증 패턴:**
```
- useQuery without isLoading check → FAIL
- fetch without .catch() or error boundary → FAIL
- list render without empty check → FAIL (data=[] 시 빈 화면)
```

---

### UX-7: Responsive Behavior (반응형 동작)

| 항목 | 내용 |
|------|------|
| **설명** | 모바일(~640px)/태블릿(641~1024px)/데스크톱(1025px+) 3개 breakpoint에서 레이아웃이 정상 동작하는지 검증 |
| **심각도** | **HIGH** |
| **PASS 기준** | (1) 가로 스크롤 없음, (2) 텍스트 잘림(overflow hidden + ellipsis) 의도적 사용만, (3) breakpoint별 레이아웃 전환 존재 |
| **FAIL 기준** | 고정 width(px) 레이아웃으로 모바일에서 가로 스크롤 발생, 또는 breakpoint 미디어 쿼리/Tailwind 반응형 클래스 완전 부재 |
| **검증 방법** | `width: {N}px` 고정 값 검출, `@media`/`sm:`/`md:`/`lg:` 반응형 클래스 존재 여부, `overflow-x: auto` 미적용 테이블/컨테이너 |
| **자동 수정** | 고정 width를 `max-width: 100%` 또는 `w-full max-w-{size}`로 교체. 테이블에 `overflow-x-auto` 래퍼 추가 |

**검증 패턴:**
```
- width: 800px (container) → FAIL (모바일 가로 스크롤)
- <table> without overflow wrapper → FAIL
- No sm:/md:/lg: classes in changed files → WARN
```

---

### UX-8: Accessibility (접근성)

| 항목 | 내용 |
|------|------|
| **설명** | ARIA 레이블, 시맨틱 HTML, 키보드 접근성이 기본 수준을 충족하는지 검증 |
| **심각도** | **CRITICAL** |
| **PASS 기준** | (1) 이미지에 `alt` 속성, (2) 폼 입력에 `label` 연결, (3) 인터랙티브 요소에 `aria-label` 또는 visible text, (4) heading 계층 순서 준수 (h1→h2→h3) |
| **FAIL 기준** | `<img>` alt 누락, `<input>` label 미연결, 아이콘 버튼에 aria-label 없음, heading 레벨 건너뛰기(h1→h3) |
| **검증 방법** | JSX/HTML에서 img/input/button/heading 태그 파싱 → 필수 속성 존재 여부 확인 |
| **자동 수정** | `alt=""` (장식 이미지) 또는 `alt="설명"` 추가. `<label htmlFor>` 연결. 아이콘 버튼에 `aria-label` 추가. heading 레벨 조정 |

**검증 패턴:**
```
- <img src="hero.png"> without alt → FAIL
- <input type="email"> without associated <label> → FAIL
- <button><Icon /></button> without aria-label → FAIL
- <h1>Title</h1> ... <h3>Section</h3> (h2 skipped) → FAIL
```

---

### UX-9: Interaction Feedback (인터랙션 피드백)

| 항목 | 내용 |
|------|------|
| **설명** | 사용자 액션에 대한 시각적 피드백(hover, focus, active, transition)이 존재하는지 검증 |
| **심각도** | **MEDIUM** |
| **PASS 기준** | (1) 클릭 가능 요소에 hover 스타일, (2) 포커스 가능 요소에 focus-visible 스타일, (3) 상태 전환에 transition (150-300ms) |
| **FAIL 기준** | 버튼/링크에 hover 스타일 완전 부재, 또는 focus 시 outline 제거 후 대체 스타일 없음 |
| **검증 방법** | 인터랙티브 요소에서 `:hover`, `:focus`, `:focus-visible`, `transition` 속성 존재 확인. `outline: none`/`outline-none` 사용 시 대체 스타일 확인 |
| **자동 수정** | `hover:opacity-80` 또는 `hover:bg-{color}-600` 추가. `focus-visible:ring-2 focus-visible:ring-offset-2` 추가. `transition-colors duration-200` 추가 |

**검증 패턴:**
```
- <button> without hover/focus styles → FAIL
- outline: none without focus-visible alternative → FAIL (접근성 위반 겸)
- state change without transition → WARN
```

---

## 심각도 요약

| 심각도 | 항목 | 실패 시 행동 |
|:------:|------|-----------|
| **CRITICAL** | UX-1 (Color Contrast), UX-3 (Touch Target), UX-8 (Accessibility) | autoFix 1회 → 실패 시 [STOP] |
| **HIGH** | UX-2 (Font Size), UX-5 (Navigation), UX-6 (3-State), UX-7 (Responsive) | autoFix 1회 → 실패 시 WARN 보고 |
| **MEDIUM** | UX-4 (Layout Consistency), UX-9 (Interaction Feedback) | WARN 보고 (자동 수정 선택적) |

## 출력 형식

검증 결과를 아래 JSON 형식으로 반환한다:

```json
{
  "checkId": "check-3.6",
  "skillName": "ux-audit",
  "status": "PASS | WARN | FAIL",
  "timestamp": "ISO-8601",
  "summary": "9항목 중 N개 PASS, M개 WARN, K개 FAIL",
  "items": [
    {
      "id": "UX-1",
      "name": "Color Contrast",
      "status": "PASS | WARN | FAIL",
      "severity": "CRITICAL | HIGH | MEDIUM",
      "details": "검증 결과 상세 설명",
      "files": ["src/components/Button.tsx:42"],
      "autoFixable": true,
      "autoFixAction": "수정 내용 설명"
    }
  ],
  "criticalFailCount": 0,
  "highFailCount": 0,
  "mediumFailCount": 0,
  "autoFixable": true
}
```

## 전체 판정 기준

| 조건 | 판정 |
|------|------|
| CRITICAL FAIL 0건 + HIGH FAIL 0건 | **PASS** |
| CRITICAL FAIL 0건 + HIGH FAIL 1건 이상 | **WARN** (진행 가능, 보고) |
| CRITICAL FAIL 1건 이상 | **FAIL** (autoFix → 재검증 → [STOP]) |

## 실행 절차

```
1. 변경 파일 목록 수집 (git diff --name-only)
2. 프론트엔드 파일 필터링 (.tsx, .jsx, .css, .scss, .html)
3. 프론트엔드 파일 없음 → SKIP 반환
4. 9항목 순차 검증 (UX-1 ~ UX-9)
5. JSON 결과 생성
6. CRITICAL FAIL → autoFix 시도 (1회) → 재검증
7. 최종 결과 반환
```

## autoFix 규칙

- Check 3.6 autoFix는 Forge Dev 전체 autoFix 카운터와 **별도** 관리 (UI 수정은 로직 수정과 독립)
- Check 3.6 autoFix 최대 **1회**
- 1회 실패 → WARN으로 보고하고 진행 (CRITICAL도 Human 에스컬레이션 대신 WARN 보고)
- 이유: UI 수정은 디자인 의도를 AI가 100% 파악할 수 없으므로, 블로킹보다 보고 우선

## 제외 패턴

아래 파일/컴포넌트는 검증에서 제외한다:

- `*.test.tsx`, `*.spec.tsx` (테스트 파일)
- `*.stories.tsx` (Storybook)
- `node_modules/`
- 자동 생성 파일 (`generated/`, `__generated__/`)
- 서드파티 CSS 라이브러리 (`vendor/`)
