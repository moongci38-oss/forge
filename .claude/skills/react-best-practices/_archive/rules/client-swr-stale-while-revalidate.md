---
title: "SWR/React Query로 Stale-While-Revalidate 패턴"
id: client-swr-stale-while-revalidate
impact: HIGH
category: client-data-fetching
impactDescription: "체감 로딩 시간 제거 — 캐시된 데이터 즉시 표시 후 백그라운드 갱신"
tags: [react, swr, react-query, caching, performance]
---

# SWR/React Query로 Stale-While-Revalidate 패턴

> 클라이언트에서 데이터를 가져올 때 `useEffect` + `useState`를 직접 사용하면 매번 로딩 스피너가 표시된다. SWR이나 React Query를 사용하면 캐시된 데이터를 즉시 표시하고 백그라운드에서 갱신하여 로딩 깜빡임을 제거한다.

## Incorrect

```tsx
// Before: useEffect + useState로 매번 로딩 스피너 — 캐시 없음
// components/UserDashboard.tsx
'use client';

import { useState, useEffect } from 'react';

interface DashboardData {
  stats: { revenue: number; users: number; orders: number };
  recentOrders: Order[];
}

export function UserDashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      setIsLoading(true);
      try {
        const res = await fetch('/api/dashboard');
        if (!res.ok) throw new Error('Failed to fetch');
        const json = await res.json();
        if (!cancelled) setData(json);
      } catch (err) {
        if (!cancelled) setError(err as Error);
      } finally {
        if (!cancelled) setIsLoading(false);
      }
    }

    fetchData();
    return () => { cancelled = true; };
  }, []);
  // 문제점:
  // 1. 매번 로딩 스피너 (이전 데이터 캐시 없음)
  // 2. 탭 전환 후 돌아오면 stale 데이터 표시
  // 3. 에러 후 재시도 로직 없음
  // 4. 같은 데이터를 다른 컴포넌트에서도 별도 fetch

  if (isLoading) return <DashboardSkeleton />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return null;

  return <DashboardContent data={data} />;
}
```

## Correct

```tsx
// After: useSWR로 stale-while-revalidate — 캐시 데이터 즉시 표시
// components/UserDashboard.tsx
'use client';

import useSWR from 'swr';

const fetcher = (url: string) => fetch(url).then((res) => {
  if (!res.ok) throw new Error('Failed to fetch');
  return res.json();
});

interface DashboardData {
  stats: { revenue: number; users: number; orders: number };
  recentOrders: Order[];
}

export function UserDashboard() {
  const { data, error, isLoading, isValidating } = useSWR<DashboardData>(
    '/api/dashboard',
    fetcher,
    {
      revalidateOnFocus: true,      // 탭 전환 후 돌아오면 자동 갱신
      revalidateOnReconnect: true,  // 네트워크 재연결 시 자동 갱신
      dedupingInterval: 5000,       // 5초 내 중복 요청 방지
      errorRetryCount: 3,           // 에러 시 3회 재시도
    }
  );

  // 첫 로딩만 스켈레톤 — 이후 방문 시 캐시 데이터 즉시 표시
  if (isLoading) return <DashboardSkeleton />;
  if (error) return <ErrorMessage error={error} />;
  if (!data) return null;

  return (
    <div>
      {/* 백그라운드 갱신 중 표시 (선택적) */}
      {isValidating && <RefreshIndicator />}
      <DashboardContent data={data} />
    </div>
  );
}
```

```tsx
// 심화: 전역 SWR 설정 + 다른 컴포넌트에서 같은 데이터 재사용
// app/providers.tsx
'use client';

import { SWRConfig } from 'swr';

const globalFetcher = async (url: string) => {
  const res = await fetch(url);
  if (!res.ok) {
    const error = new Error('API request failed');
    throw error;
  }
  return res.json();
};

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <SWRConfig
      value={{
        fetcher: globalFetcher,
        revalidateOnFocus: true,
        dedupingInterval: 5000,
        errorRetryCount: 3,
        errorRetryInterval: 1000,
      }}
    >
      {children}
    </SWRConfig>
  );
}

// components/DashboardWidget.tsx — 다른 컴포넌트에서도 같은 키로 호출
'use client';

import useSWR from 'swr';

export function RevenueWidget() {
  // 같은 키('/api/dashboard')로 호출 — SWR이 자동으로 캐시 공유
  // 추가 네트워크 요청 없이 UserDashboard와 같은 데이터 사용
  const { data } = useSWR<DashboardData>('/api/dashboard');

  return <div>Revenue: ${data?.stats.revenue.toLocaleString()}</div>;
}
```

## Why

`useEffect` + `useState` 패턴의 근본적인 문제는 **컴포넌트가 마운트될 때마다 빈 상태에서 시작**한다는 것이다. 페이지 이동 후 돌아오면 이미 가져온 데이터임에도 로딩 스피너부터 다시 표시된다.

SWR의 Stale-While-Revalidate 전략:
1. **캐시에서 즉시 반환** (stale) — 사용자에게 즉시 데이터 표시
2. **백그라운드에서 갱신** (revalidate) — 최신 데이터로 조용히 업데이트
3. **자동 중복 제거** — 같은 키의 요청은 하나만 실행

**정량적 효과:**
- 재방문 시 로딩 시간: useEffect ~500ms (네트워크 대기) → SWR 0ms (캐시 즉시)
- 같은 API를 3개 컴포넌트가 사용: useEffect 3회 fetch → SWR 1회 fetch + 2회 캐시 히트
- 탭 전환 후 stale 데이터 표시 시간: useEffect 무한대 → SWR 0초 (자동 revalidate)

## References

- [SWR Documentation](https://swr.vercel.app/)
- [SWR: Understanding Stale-While-Revalidate](https://swr.vercel.app/docs/revalidation)
- [React Query (TanStack Query)](https://tanstack.com/query/latest)
- [HTTP Stale-While-Revalidate RFC 5861](https://datatracker.ietf.org/doc/html/rfc5861)
