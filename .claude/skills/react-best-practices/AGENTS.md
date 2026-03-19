# react-best-practices

> 프론트엔드 성능 최적화 65룰 (React 19 + Next.js 15). Check 3.7P가 검증.

## CRITICAL (항상 적용)

- **async-defer-await**: 컴포넌트 내 `await` 사용 금지 → `Suspense` + `use()` 또는 서버 컴포넌트 분리. 초기 렌더링 2-5x 개선.
- **async-promise-all**: 독립 fetch는 `Promise.all()` 병렬화 — 순차 await 금지. N개 fetch 시 N배 속도.
- **async-partial-parallel**: 부분 의존 fetch에서 독립 부분 먼저 시작 → 의존 부분만 순차. 워터폴 50-70% 단축.
- **async-api-early-start**: API 호출은 라우트 레벨(page/layout)에서 시작 — 중첩 컴포넌트 내 fetch 금지. TTFB 30-50% 개선.
- **async-suspense-streaming**: `<Suspense fallback>` 경계로 스트리밍 SSR — 느린 데이터를 별도 스트림. 체감 LCP 60-80% 단축.
- **bundle-barrel-imports**: barrel import(`index.ts` 재수출) 금지 → 직접 경로 import. 번들 20-40% 감소.
- **bundle-dynamic-import**: 초기 렌더에 불필요한 무거운 컴포넌트는 `next/dynamic` 또는 `React.lazy()`. 초기 JS 30-60% 감소.
- **bundle-analytics-hydration**: Analytics/추적 스크립트는 hydration 이후 로드 — `next/script afterInteractive`. TBT 200-500ms 감소.
- **bundle-conditional-module**: 선택적 기능 모듈은 동적 import — 사용 시점에만 로드. 미사용 기능 번들 비용 0.
- **bundle-preload-on-interaction**: 무거운 라우트/컴포넌트는 hover/focus 시 프리로드 — 페이지 로드 시 prefetch 금지. 체감 네비게이션 2-3x.

## HIGH (우선 검토)

- **server-actions-auth**: Server Action 첫 줄에 `auth()` 체크 필수 — 인증 없는 mutation 금지.
- **server-actions-validation**: Server Action 입력은 Zod schema로 검증 — raw input 직접 사용 금지.
- **server-cache-dedupe**: 동일 fetch 중복 제거 — `React.cache()` 또는 `unstable_cache()` 래핑. DB 쿼리 50-80% 감소.
- **server-rsc-payload-size**: RSC Payload에 필요 데이터만 포함 — 전체 DB row 전달 금지. Payload 60-80% 감소.
- **server-streaming-order**: 중첩 Suspense로 중요 콘텐츠 우선 스트리밍 — 체감 로딩 40-60% 단축.
- **server-edge-runtime**: 경량 로직은 Edge Runtime — Cold start 10x 빠름 (250ms→25ms).
- **server-revalidation-strategy**: 캐시 무효화 전략 — time-based vs on-demand 적절 선택. 불필요한 재검증 70% 감소.
- **composition-server-client-boundary**: `'use client'`는 인터랙션이 필요한 최소 범위에만 — 페이지 전체 client 금지. JS 번들 40-70% 감소.
- **composition-provider-pattern**: Provider 중첩 최소화 — compose 패턴으로 레이아웃 정리. 초기 렌더 20-30% 개선.
- **composition-compound-components**: Boolean prop 지옥 대신 Compound Component 패턴 — API 명확성 + 확장성.
- **composition-error-boundary**: 기능별 Error Boundary 분리 — 에러 시 전체 앱 크래시 방지.
