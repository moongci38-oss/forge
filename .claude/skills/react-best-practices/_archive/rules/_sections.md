# react-best-practices Rule Sections

이 파일은 React 성능 최적화 룰 카테고리를 정의한다. 룰은 파일명 접두사로 카테고리에 자동 할당된다.

| 순서 | 카테고리 | 접두사 | Impact | 룰 수 | 상태 |
|:--:|---------|--------|:------:|:-----:|:----:|
| 1 | Eliminating Waterfalls | async- | CRITICAL | 5 | ✅ |
| 2 | Bundle Size Optimization | bundle- | CRITICAL | 5 | ✅ |
| 3 | Server-Side Performance | server- | HIGH | 7 | ✅ |
| 4 | Client-Side Data Fetching | client- | MEDIUM-HIGH | 4 | ✅ |
| 5 | Re-render Optimization | rerender- | MEDIUM | 12 | ⬜ |
| 6 | Rendering Performance | rendering- | MEDIUM | 9 | ⬜ |
| 7 | JavaScript Performance | js- | LOW-MEDIUM | 12 | ⬜ |
| 8 | Advanced Patterns | advanced- | LOW | 3 | ⬜ |
| 9 | Composition Patterns | composition- | HIGH | 8 | ⬜ |

---

## 1. Eliminating Waterfalls (async)
**Impact:** CRITICAL
**Description:** 비동기 워터폴(순차 await, 중첩 fetch 체인)을 제거하여 데이터 로딩 속도를 2-10x 개선. React/Next.js에서 가장 흔한 성능 병목.

## 2. Bundle Size Optimization (bundle)
**Impact:** CRITICAL
**Description:** 불필요한 코드 제거, 동적 로딩, 코드 분할로 초기 JS 번들 크기를 30-60% 감소. Core Web Vitals(LCP, FID, TBT) 직접 영향.

## 3. Server-Side Performance (server)
**Impact:** HIGH
**Description:** Server Actions 보안, RSC Payload 최적화, 캐싱 전략, Edge Runtime 활용. Next.js App Router 서버 사이드 성능의 핵심.

## 4. Client-Side Data Fetching (client)
**Impact:** MEDIUM-HIGH
**Description:** SWR/React Query 패턴, 낙관적 업데이트, 무한 스크롤, 프리페치. 클라이언트 상호작용 체감 속도 개선.

## 5. Re-render Optimization (rerender)
**Impact:** MEDIUM
**Description:** 불필요한 리렌더 방지 — Context 분리, 메모이제이션, 상태 코로케이션, React Compiler 활용. 인터랙션 반응 속도 개선.

## 6. Rendering Performance (rendering)
**Impact:** MEDIUM
**Description:** 가상화, 이미지/폰트 최적화, CSS containment, Skeleton UI, CLS 방지. 시각적 렌더링 품질과 성능.

## 7. JavaScript Performance (js)
**Impact:** LOW-MEDIUM
**Description:** debounce/throttle, Web Worker, rAF, AbortController 등 JavaScript 런타임 최적화. 개별 영향은 작지만 누적 효과 큼.

## 8. Advanced Patterns (advanced)
**Impact:** LOW
**Description:** Module Federation, Service Worker, WASM 등 고급 최적화. 특수 상황에서 적용.

## 9. Composition Patterns (composition)
**Impact:** HIGH
**Description:** Server/Client 경계 설계, Provider 최적화, Compound Components, Error Boundary 계층. 아키텍처 레벨 성능 설계.
