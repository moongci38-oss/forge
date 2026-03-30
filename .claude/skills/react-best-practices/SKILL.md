---
name: react-best-practices
description: "React/Next.js 성능 최적화 57룰. async 워터폴 제거, 번들 최적화, RSC 성능, 리렌더 방지 등 8카테고리 프론트엔드 성능 도메인 지식 (React, Next.js, App Router, Server Components)"
context: fork
model: sonnet
---

# React Best Practices

React 19 + Next.js 15 App Router 환경에서의 프론트엔드 성능 최적화 가이드.
Forge Dev Check 3.7P(Performance)에서 자동 검증하며, 코드 리뷰 시 참조한다.

8개 카테고리 57룰 + 1개 합성 패턴 카테고리 8룰 = 총 65룰.
Wave 1에서 CRITICAL 10룰, Wave 2에서 나머지 55룰을 구현하여 전체 65룰 완성.

## Output Requirements

Every react-best-practices review MUST include ALL of the following:

1. **Rule ID citation**: Every issue MUST cite at least one rule ID (e.g., `async-defer-await`, `bundle-dynamic-import`, `rsc-client-boundary`) from the index below
2. **Severity**: Each issue MUST be labeled `CRITICAL` or `WARNING`
3. **Code fix**: Each issue MUST include a concrete code snippet showing the fix

## When to Apply

- React/Next.js 컴포넌트 작성 및 리뷰 시
- 데이터 페칭 패턴 설계 시
- 번들 크기 최적화 시
- Server/Client Component 경계 결정 시
- 성능 병목 진단 및 해결 시
- Forge Dev Check 3.7P 성능 검증 시

## Rule Index (전체 65룰)

### 1. Eliminating Waterfalls (CRITICAL) — `async-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 1 | async-defer-await | 컴포넌트 내 await 사용 금지 — Suspense + use() 활용 | ✅ |
| 2 | async-promise-all | 독립 fetch는 Promise.all() 병렬화 | ✅ |
| 3 | async-partial-parallel | 부분 의존성 fetch 최적화 — 독립 부분 먼저 시작 | ✅ |
| 4 | async-api-early-start | API 호출은 라우트 레벨에서 시작 | ✅ |
| 5 | async-suspense-streaming | Suspense 경계로 스트리밍 SSR 활용 | ✅ |

### 2. Bundle Size Optimization (CRITICAL) — `bundle-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 6 | bundle-barrel-imports | Barrel import(index.ts) 금지 — 직접 경로 import | ✅ |
| 7 | bundle-dynamic-import | 무거운 컴포넌트는 dynamic import | ✅ |
| 8 | bundle-analytics-hydration | Analytics/추적 스크립트는 hydration 이후 로드 | ✅ |
| 9 | bundle-conditional-module | 조건부 기능은 동적 import로 분리 | ✅ |
| 10 | bundle-preload-on-interaction | 인터랙션 시점에 프리로드 — 페이지 로드 시 prefetch 금지 | ✅ |

### 3. Server-Side Performance (HIGH) — `server-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 11 | server-actions-auth | Server Action 첫 줄에 인증 체크 필수 | ✅ |
| 12 | server-actions-validation | Server Action 입력값 Zod 검증 필수 | ✅ |
| 13 | server-cache-dedupe | 동일 요청 중복 제거 — React cache() 활용 | ✅ |
| 14 | server-rsc-payload-size | RSC Payload 크기 최소화 — 필요한 데이터만 전달 | ✅ |
| 15 | server-streaming-order | Streaming 순서 최적화 — 중요 콘텐츠 우선 | ✅ |
| 16 | server-edge-runtime | 정적/경량 로직은 Edge Runtime 활용 | ✅ |
| 17 | server-revalidation-strategy | 캐시 무효화 전략 — time-based vs on-demand | ✅ |

### 4. Client-Side Data Fetching (MEDIUM-HIGH) — `client-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 18 | client-swr-stale-while-revalidate | SWR/React Query로 stale-while-revalidate 패턴 | ✅ |
| 19 | client-optimistic-updates | 낙관적 업데이트로 체감 속도 개선 | ✅ |
| 20 | client-infinite-scroll | 무한 스크롤은 커서 기반 페이지네이션 | ✅ |
| 21 | client-prefetch-on-hover | 호버 시 데이터 프리페치 | ✅ |

### 5. Re-render Optimization (MEDIUM) — `rerender-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 22 | rerender-children-as-props | children을 props로 전달하여 리렌더 격리 | ✅ |
| 23 | rerender-context-split | Context를 도메인별로 분리 — 전역 Context 금지 | ✅ |
| 24 | rerender-memo-expensive | 비용 높은 계산은 useMemo로 캐싱 | ✅ |
| 25 | rerender-callback-stability | 이벤트 핸들러는 useCallback으로 참조 안정성 확보 | ✅ |
| 26 | rerender-state-colocation | 상태는 사용하는 컴포넌트에 최대한 가까이 배치 | ✅ |
| 27 | rerender-derived-state | 파생 상태는 useState 대신 계산으로 처리 | ✅ |
| 28 | rerender-key-stability | list key에 index 사용 금지 — 안정적 ID 사용 | ✅ |
| 29 | rerender-ref-for-dom | DOM 접근은 ref 사용 — state로 DOM 제어 금지 | ✅ |
| 30 | rerender-zustand-selectors | Zustand selector로 구독 범위 최소화 | ✅ |
| 31 | rerender-form-uncontrolled | 폼은 가능하면 비제어 컴포넌트 사용 | ✅ |
| 32 | rerender-transition-api | 비긴급 업데이트는 useTransition/useDeferredValue | ✅ |
| 33 | rerender-compiler-auto | React Compiler 활용 — 수동 memo 최소화 | ✅ |

### 6. Rendering Performance (MEDIUM) — `rendering-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 34 | rendering-virtualize-lists | 대규모 리스트는 가상화(virtualization) 필수 | ✅ |
| 35 | rendering-image-optimization | next/image + 반응형 sizes + priority 설정 | ✅ |
| 36 | rendering-font-optimization | next/font로 폰트 최적화 — FOUT/FOIT 방지 | ✅ |
| 37 | rendering-css-containment | CSS containment으로 리페인트 범위 제한 | ✅ |
| 38 | rendering-animation-gpu | 애니메이션은 transform/opacity만 사용 — layout 트리거 금지 | ✅ |
| 39 | rendering-skeleton-ui | 로딩 상태에 Skeleton UI 사용 — spinner 최소화 | ✅ |
| 40 | rendering-intersection-observer | 뷰포트 진입 시점에 로드 — IntersectionObserver 활용 | ✅ |
| 41 | rendering-layout-shift | CLS 방지 — 이미지/광고에 사전 크기 지정 | ✅ |
| 42 | rendering-critical-css | Critical CSS 인라인 — 나머지 비동기 로드 | ✅ |

### 7. JavaScript Performance (LOW-MEDIUM) — `js-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 43 | js-debounce-throttle | 빈번한 이벤트는 debounce/throttle 적용 | ✅ |
| 44 | js-web-worker | CPU 집약 작업은 Web Worker로 분리 | ✅ |
| 45 | js-avoid-layout-thrashing | DOM 읽기/쓰기 배치 — layout thrashing 방지 | ✅ |
| 46 | js-requestAnimationFrame | 시각적 업데이트는 rAF 사용 | ✅ |
| 47 | js-event-delegation | 이벤트 위임 패턴 — 개별 리스너 최소화 | ✅ |
| 48 | js-structuredClone | 깊은 복사는 structuredClone 사용 | ✅ |
| 49 | js-weakmap-cache | 객체 키 캐시는 WeakMap 사용 — 메모리 누수 방지 | ✅ |
| 50 | js-string-template | 문자열 연결 대신 template literal 사용 | ✅ |
| 51 | js-optional-chaining | 안전한 프로퍼티 접근 — optional chaining 활용 | ✅ |
| 52 | js-array-methods | 적절한 배열 메서드 선택 — find vs filter vs some | ✅ |
| 53 | js-abort-controller | fetch 취소는 AbortController 활용 | ✅ |
| 54 | js-idle-callback | 비긴급 작업은 requestIdleCallback으로 지연 | ✅ |

### 8. Advanced Patterns (LOW) — `advanced-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 55 | advanced-module-federation | Module Federation으로 마이크로 프론트엔드 | ✅ |
| 56 | advanced-service-worker | Service Worker 캐싱 전략 | ✅ |
| 57 | advanced-wasm-compute | WASM으로 CPU 집약 연산 오프로드 | ✅ |

### 9. Composition Patterns (HIGH) — `composition-`

| # | ID | 룰 제목 | Wave |
|:-:|------|---------|:----:|
| 58 | composition-server-client-boundary | Server/Client 경계 최적화 — 'use client' 최소화 | ✅ |
| 59 | composition-provider-pattern | Provider 계층 최적화 — 불필요한 중첩 제거 | ✅ |
| 60 | composition-compound-components | Compound Component 패턴으로 유연한 API | ✅ |
| 61 | composition-render-props-hooks | Render Props → Custom Hook 전환 | ✅ |
| 62 | composition-error-boundary | Error Boundary 계층 설계 — 세분화된 에러 복구 | ✅ |
| 63 | composition-layout-pattern | Layout 패턴 — 공유 UI 최적화 | ✅ |
| 64 | composition-slot-pattern | Slot 패턴으로 유연한 컴포넌트 합성 | ✅ |
| 65 | composition-hoc-to-hooks | HOC → Hook 전환 가이드 | ✅ |

## How to Use

개별 룰 파일을 참조하여 상세한 코드 예제와 설명을 확인한다:

```
rules/async-defer-await.md
rules/bundle-barrel-imports.md
rules/_sections.md
```

각 룰 파일에 포함된 내용:
- 문제 설명과 성능 영향 (정량적)
- 잘못된 코드 예제 (Before)
- 올바른 코드 예제 (After)
- 이유 설명과 참조 문서

## Compressed Reference

전체 65룰의 압축 원라이너 참조: `AGENTS.md`
