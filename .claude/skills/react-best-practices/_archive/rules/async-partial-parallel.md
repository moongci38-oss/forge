---
title: "부분 의존성 fetch 최적화 — 독립 부분 먼저 시작"
id: async-partial-parallel
impact: CRITICAL
category: eliminating-waterfalls
impactDescription: "부분 의존성 워터폴 50-70% 단축"
tags: [react, nextjs, performance, async, waterfall, parallel]
---

# 부분 의존성 fetch 최적화 — 독립 부분 먼저 시작

> 일부 fetch가 다른 fetch 결과에 의존하더라도, 독립적인 fetch는 먼저 시작하여 워터폴을 최소화한다.

## Incorrect

```tsx
// Before: 전부 순차 실행 — 독립적인 fetch도 불필요하게 대기
// app/profile/[id]/page.tsx

async function ProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // Step 1: 유저 정보 (200ms)
  const user = await fetchUser(id);

  // Step 2: 유저의 팀 정보 — user.teamId 필요 (의존성 있음, 300ms)
  const team = await fetchTeam(user.teamId);

  // Step 3: 최근 활동 — user.id만 필요하지만 team 완료까지 대기 (400ms)
  const activity = await fetchRecentActivity(user.id);

  // Step 4: 추천 콘텐츠 — 독립적이지만 모든 것이 끝날 때까지 대기 (350ms)
  const recommendations = await fetchRecommendations();

  // 총 시간: 200 + 300 + 400 + 350 = 1250ms
  return <Profile user={user} team={team} activity={activity} recs={recommendations} />;
}
```

## Correct

```tsx
// After: 의존성 그래프를 분석하여 최대한 병렬화
// app/profile/[id]/page.tsx

async function ProfilePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // Wave 1: 독립적인 fetch들을 먼저 동시 시작
  const userPromise = fetchUser(id);
  const recommendationsPromise = fetchRecommendations(); // 유저 정보 불필요

  // Wave 1 중 user만 기다림 (recommendations는 계속 진행 중)
  const user = await userPromise;

  // Wave 2: user 결과에 의존하는 fetch들을 동시 시작
  const [team, activity, recommendations] = await Promise.all([
    fetchTeam(user.teamId),       // user.teamId 필요
    fetchRecentActivity(user.id), // user.id 필요
    recommendationsPromise,       // 이미 진행 중인 Promise
  ]);

  // 총 시간: 200 + max(300, 400, 이미 진행 중) ≈ 600ms (52% 단축)
  return <Profile user={user} team={team} activity={activity} recs={recommendations} />;
}
```

```tsx
// 더 복잡한 의존성 그래프 예시
// app/checkout/page.tsx

async function CheckoutPage() {
  // Wave 1: 완전 독립 (동시 시작)
  const cartPromise = fetchCart();
  const shippingOptionsPromise = fetchShippingOptions();
  const promotionsPromise = fetchActivePromotions();

  // Wave 1에서 cart만 기다림
  const cart = await cartPromise;

  // Wave 2: cart에 의존하는 것들 + 이미 진행 중인 것들
  const [pricing, inventory, shippingOptions, promotions] = await Promise.all([
    calculatePricing(cart.items),        // cart 의존
    checkInventory(cart.items),          // cart 의존
    shippingOptionsPromise,              // 이미 Wave 1에서 시작됨
    promotionsPromise,                   // 이미 Wave 1에서 시작됨
  ]);

  return (
    <Checkout
      cart={cart}
      pricing={pricing}
      inventory={inventory}
      shipping={shippingOptions}
      promotions={promotions}
    />
  );
}
```

## Why

실전 코드에서는 완전히 독립적이거나 완전히 의존적인 경우보다, 부분적 의존성이 훨씬 흔하다. 핵심은 **의존성 그래프를 분석하여 "Wave"를 나누는 것**이다:

1. Wave 1: 모든 독립 fetch 동시 시작
2. 의존성이 필요한 시점에서만 await
3. Wave 2: 의존 fetch + 아직 진행 중인 Wave 1 Promise를 함께 Promise.all()

**정량적 효과:**
- 4개 fetch(200+300+400+350ms): 순차 1250ms → 최적화 600ms = **52% 단축**
- Promise를 "변수에 할당만 하고 await하지 않는" 패턴이 핵심
- 이미 시작된 Promise를 Promise.all()에 넣어도 중복 실행되지 않음

## References

- [Next.js Preloading Data](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching#preloading-data)
- [JavaScript Promise Execution Model](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
