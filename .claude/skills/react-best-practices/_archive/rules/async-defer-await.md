---
title: "컴포넌트 내 await 사용 금지 — Suspense + use() 활용"
id: async-defer-await
impact: CRITICAL
category: eliminating-waterfalls
impactDescription: "초기 렌더링 2-5x 개선 — 컴포넌트 블로킹 제거"
tags: [react, nextjs, performance, suspense, streaming, async]
---

# 컴포넌트 내 await 사용 금지 — Suspense + use() 활용

> 클라이언트 컴포넌트에서 직접 await하면 전체 렌더 트리가 블로킹된다. Suspense 경계를 활용하거나 Server Component로 분리한다.

## Incorrect

```tsx
// Before: 컴포넌트 내부에서 직접 await — 전체 페이지 렌더링 블로킹
// app/dashboard/page.tsx

async function DashboardPage() {
  // 이 await가 완료될 때까지 페이지 전체가 빈 화면
  const user = await fetchUser();
  const stats = await fetchDashboardStats(user.id);
  const notifications = await fetchNotifications(user.id);

  return (
    <div>
      <Header user={user} />
      <StatsPanel stats={stats} />
      <NotificationList notifications={notifications} />
    </div>
  );
}
```

## Correct

```tsx
// After: Server Component 분리 + Suspense 경계로 스트리밍
// app/dashboard/page.tsx

import { Suspense } from 'react';
import { StatsSkeleton, NotificationSkeleton } from '@/components/skeletons';

async function DashboardPage() {
  // 유저 정보만 먼저 로드 (빠름)
  const user = await fetchUser();

  return (
    <div>
      <Header user={user} />
      {/* 느린 데이터는 Suspense로 감싸서 스트리밍 */}
      <Suspense fallback={<StatsSkeleton />}>
        <StatsPanel userId={user.id} />
      </Suspense>
      <Suspense fallback={<NotificationSkeleton />}>
        <NotificationList userId={user.id} />
      </Suspense>
    </div>
  );
}

// 각 컴포넌트가 독립적으로 데이터를 로드 — 병렬 스트리밍
// app/dashboard/_components/StatsPanel.tsx
async function StatsPanel({ userId }: { userId: string }) {
  const stats = await fetchDashboardStats(userId);
  return <div>{/* stats 렌더링 */}</div>;
}
```

```tsx
// Alternative: 클라이언트에서 use() hook 활용 (React 19)
// app/dashboard/page.tsx

import { Suspense, use } from 'react';

async function DashboardPage() {
  // Promise를 생성만 하고 await하지 않음
  const statsPromise = fetchDashboardStats();

  return (
    <Suspense fallback={<StatsSkeleton />}>
      <StatsPanel statsPromise={statsPromise} />
    </Suspense>
  );
}

// 클라이언트 컴포넌트에서 use()로 Promise 소비
'use client';
function StatsPanel({ statsPromise }: { statsPromise: Promise<Stats> }) {
  const stats = use(statsPromise);
  return <div>{/* stats 렌더링 */}</div>;
}
```

## Why

React에서 `await`는 해당 컴포넌트의 렌더링을 완전히 블로킹한다. 페이지 레벨에서 여러 데이터를 순차 await하면 가장 느린 fetch가 전체 페이지 로딩 시간을 결정한다. Suspense 경계를 사용하면 각 데이터 소스가 독립적으로 스트리밍되어 빠른 데이터부터 먼저 표시된다.

**정량적 효과:**
- 3개 독립 fetch(각 200ms, 500ms, 1000ms) 순차 → 1700ms, Suspense 병렬 → 1000ms (최장 fetch 시간)
- LCP(Largest Contentful Paint) 40-60% 개선
- TTFB가 전체 페이지가 아닌 최초 콘텐츠 기준으로 측정

## References

- [React 19 use() hook](https://react.dev/reference/react/use)
- [Next.js Streaming and Suspense](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
- [Patterns: Parallel Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching#parallel-data-fetching)
