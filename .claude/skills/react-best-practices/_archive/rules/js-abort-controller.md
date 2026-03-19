---
title: "fetch 취소는 AbortController 활용"
id: js-abort-controller
impact: LOW
category: javascript-performance
impactDescription: "컴포넌트 언마운트 시 네트워크 요청 취소 — 메모리 누수 방지"
tags: [react, javascript, performance, fetch, abort-controller, cleanup]
---

# fetch 취소는 AbortController 활용

> 컴포넌트 언마운트 시 진행 중인 fetch 요청을 AbortController로 취소하여 메모리 누수와 상태 업데이트 경고를 방지한다.

## Incorrect

```tsx
// Before: fetch 취소 없음 — 언마운트 후 상태 업데이트 시도 = 메모리 누수
'use client';

import { useEffect, useState } from 'react';

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    setLoading(true);

    // userId가 빠르게 변경되면 이전 요청이 여전히 진행 중
    // 이전 요청의 응답이 나중에 도착하면 잘못된 데이터로 상태 업데이트
    fetch(`/api/users/${userId}`)
      .then((res) => res.json())
      .then((data) => {
        // 컴포넌트가 이미 언마운트되었거나 userId가 변경되었을 수 있음
        // React 18+에서는 경고 표시, 메모리 누수 발생
        setUser(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });

    // cleanup 함수 없음 — 이전 요청 취소 불가
  }, [userId]);

  return loading ? <Skeleton /> : <div>{user?.name}</div>;
}
```

## Correct

```tsx
// After: AbortController로 이전 요청 취소 — 경쟁 조건 방지
'use client';

import { useEffect, useState } from 'react';

function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);
    setError(null);

    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then((res) => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then((data) => {
        setUser(data);
        setLoading(false);
      })
      .catch((err) => {
        // AbortError는 정상적인 취소 — 무시
        if (err.name === 'AbortError') return;
        setError(err.message);
        setLoading(false);
      });

    // userId 변경 또는 언마운트 시 이전 요청 취소
    return () => controller.abort();
  }, [userId]);

  if (error) return <ErrorMessage message={error} />;
  return loading ? <Skeleton /> : <div>{user?.name}</div>;
}
```

```tsx
// 재사용 가능한 useFetch Hook
'use client';

import { useEffect, useState, useCallback, useRef } from 'react';

interface UseFetchResult<T> {
  data: T | null;
  loading: boolean;
  error: string | null;
  refetch: () => void;
}

function useFetch<T>(url: string, options?: RequestInit): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const controllerRef = useRef<AbortController | null>(null);

  const fetchData = useCallback(async () => {
    // 이전 요청 취소
    controllerRef.current?.abort();
    controllerRef.current = new AbortController();

    setLoading(true);
    setError(null);

    try {
      const res = await fetch(url, {
        ...options,
        signal: controllerRef.current.signal,
      });

      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const json = await res.json();
      setData(json);
    } catch (err) {
      if (err instanceof Error && err.name !== 'AbortError') {
        setError(err.message);
      }
    } finally {
      setLoading(false);
    }
  }, [url, options]);

  useEffect(() => {
    fetchData();
    return () => controllerRef.current?.abort();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
}

// 사용 예시
function Dashboard() {
  const { data: stats, loading, error, refetch } = useFetch<DashboardStats>(
    '/api/dashboard/stats'
  );

  if (loading) return <DashboardSkeleton />;
  if (error) return <ErrorMessage message={error} onRetry={refetch} />;
  return <StatsDisplay stats={stats!} />;
}
```

```tsx
// 타임아웃 + 재시도 패턴
async function fetchWithTimeout(
  url: string,
  options: RequestInit & { timeout?: number; retries?: number } = {}
) {
  const { timeout = 5000, retries = 3, ...fetchOptions } = options;

  for (let attempt = 0; attempt < retries; attempt++) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(url, {
        ...fetchOptions,
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return response;
    } catch (err) {
      clearTimeout(timeoutId);
      if (attempt === retries - 1) throw err;
      // 지수 백오프
      await new Promise((r) => setTimeout(r, Math.pow(2, attempt) * 1000));
    }
  }
}
```

## Why

React 컴포넌트가 언마운트되거나 의존성이 변경되면 이전 fetch 요청이 완료된 후 이미 존재하지 않는 컴포넌트의 상태를 업데이트하려 시도한다. 이는 메모리 누수를 발생시키고, 빠른 네비게이션 시 경쟁 조건(race condition)으로 잘못된 데이터를 표시할 수 있다.

**정량적 효과:**
- 메모리 누수: 언마운트 후 상태 업데이트 100% 방지
- 경쟁 조건: userId 빠른 변경 시 잘못된 데이터 표시 0%
- 네트워크 대역폭: 불필요한 응답 수신 방지 — 모바일 데이터 절약
- 타임아웃 지원: AbortController로 fetch 타임아웃 구현 가능 (setTimeout + abort)

## References

- [MDN: AbortController](https://developer.mozilla.org/en-US/docs/Web/API/AbortController)
- [React: Synchronizing with Effects (cleanup)](https://react.dev/learn/synchronizing-with-effects#fetching-data)
- [web.dev: Abortable fetch](https://web.dev/articles/abortable-fetch)
