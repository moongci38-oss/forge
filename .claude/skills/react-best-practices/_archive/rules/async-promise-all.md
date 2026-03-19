---
title: "독립 fetch는 Promise.all() 병렬화"
id: async-promise-all
impact: CRITICAL
category: eliminating-waterfalls
impactDescription: "N개 독립 fetch 시 N배 속도 개선 (병렬화)"
tags: [react, nextjs, performance, async, promise, parallel]
---

# 독립 fetch는 Promise.all() 병렬화

> 서로 의존성이 없는 여러 fetch를 순차 await하면 워터폴이 발생한다. Promise.all()로 병렬 실행한다.

## Incorrect

```tsx
// Before: 순차 await — 각 fetch가 이전 완료를 기다림 (워터폴)
// app/dashboard/page.tsx

async function DashboardPage() {
  // 총 시간 = 200ms + 300ms + 500ms = 1000ms (순차)
  const user = await fetchUser();           // 200ms
  const products = await fetchProducts();   // 300ms
  const analytics = await fetchAnalytics(); // 500ms

  return (
    <Dashboard
      user={user}
      products={products}
      analytics={analytics}
    />
  );
}
```

## Correct

```tsx
// After: Promise.all()로 병렬 실행 — 가장 느린 fetch 시간만 소요
// app/dashboard/page.tsx

async function DashboardPage() {
  // 총 시간 = max(200ms, 300ms, 500ms) = 500ms (병렬)
  const [user, products, analytics] = await Promise.all([
    fetchUser(),           // 200ms
    fetchProducts(),       // 300ms
    fetchAnalytics(),      // 500ms
  ]);

  return (
    <Dashboard
      user={user}
      products={products}
      analytics={analytics}
    />
  );
}
```

```tsx
// 타입 안전한 패턴 — 개별 에러 핸들링이 필요한 경우
// app/dashboard/page.tsx

async function DashboardPage() {
  const [userResult, productsResult, analyticsResult] =
    await Promise.allSettled([
      fetchUser(),
      fetchProducts(),
      fetchAnalytics(),
    ]);

  const user = userResult.status === 'fulfilled'
    ? userResult.value
    : null;
  const products = productsResult.status === 'fulfilled'
    ? productsResult.value
    : [];
  const analytics = analyticsResult.status === 'fulfilled'
    ? analyticsResult.value
    : null;

  return (
    <Dashboard
      user={user}
      products={products}
      analytics={analytics}
    />
  );
}
```

## Why

순차 await는 네트워크 워터폴을 만든다. 각 fetch가 이전 fetch의 완료를 기다려야 하므로 총 로딩 시간이 모든 fetch 시간의 합이 된다. Promise.all()은 모든 fetch를 동시에 시작하므로 가장 느린 fetch 시간만 소요된다.

**정량적 효과:**
- N개 독립 fetch: 순차 = sum(각 시간), 병렬 = max(각 시간)
- 3개 fetch(200+300+500ms): 순차 1000ms → 병렬 500ms = **2x 개선**
- 5개 fetch: 개선 비율 더 증가 (최대 N배)
- Promise.allSettled()은 하나가 실패해도 나머지 결과를 유지

**주의사항:**
- 의존성이 있는 fetch(B가 A의 결과를 필요로 함)는 Promise.all()에 함께 넣지 않는다
- 부분 의존성이 있는 경우 `async-partial-parallel` 룰 참조

## References

- [MDN Promise.all()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all)
- [MDN Promise.allSettled()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/allSettled)
- [Next.js Parallel Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching#parallel-data-fetching)
