---
title: "Render Props → Custom Hook 전환"
id: composition-render-props-hooks
impact: HIGH
category: composition-patterns
impactDescription: "코드 복잡도 감소 + 로직 재사용성 향상 — wrapper hell 제거"
tags: [react, patterns, hooks, render-props, refactoring]
---

# Render Props → Custom Hook 전환

> Render Props 패턴의 로직 공유는 Custom Hook으로 대체한다. Hook은 wrapper hell 없이 동일한 로직 재사용을 제공한다.

## Incorrect

```tsx
// Before: Render Props 패턴 — wrapper hell + 깊은 중첩
'use client';

import { type ReactNode } from 'react';

// Render Props로 마우스 위치 추적
interface MouseTrackerProps {
  render: (position: { x: number; y: number }) => ReactNode;
}

function MouseTracker({ render }: MouseTrackerProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handler = (e: MouseEvent) => setPosition({ x: e.clientX, y: e.clientY });
    window.addEventListener('mousemove', handler);
    return () => window.removeEventListener('mousemove', handler);
  }, []);

  return <>{render(position)}</>;
}

// Render Props로 윈도우 크기 추적
interface WindowSizeProps {
  children: (size: { width: number; height: number }) => ReactNode;
}

function WindowSize({ children }: WindowSizeProps) {
  const [size, setSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    const handler = () =>
      setSize({ width: window.innerWidth, height: window.innerHeight });
    handler();
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);

  return <>{children(size)}</>;
}

// Render Props로 fetch 데이터
interface DataFetcherProps<T> {
  url: string;
  render: (data: { data: T | null; loading: boolean; error: string | null }) => ReactNode;
}

function DataFetcher<T>({ url, render }: DataFetcherProps<T>) {
  const [state, setState] = useState<{
    data: T | null;
    loading: boolean;
    error: string | null;
  }>({ data: null, loading: true, error: null });

  useEffect(() => {
    fetch(url)
      .then((res) => res.json())
      .then((data) => setState({ data, loading: false, error: null }))
      .catch((err) => setState({ data: null, loading: false, error: err.message }));
  }, [url]);

  return <>{render(state)}</>;
}

// 사용 시: wrapper hell — 3단 중첩
function Dashboard() {
  return (
    <MouseTracker
      render={(mouse) => (
        <WindowSize>
          {(windowSize) => (
            <DataFetcher<DashboardData>
              url="/api/dashboard"
              render={({ data, loading }) => (
                // 들여쓰기 지옥 — 가독성 최악
                <div>
                  <Cursor x={mouse.x} y={mouse.y} />
                  <Layout columns={windowSize.width > 768 ? 3 : 1}>
                    {loading ? <Skeleton /> : <Stats data={data!} />}
                  </Layout>
                </div>
              )}
            />
          )}
        </WindowSize>
      )}
    />
  );
}
```

## Correct

```tsx
// After: Custom Hook으로 전환 — 플랫한 구조 + 명확한 로직 분리
'use client';

import { useState, useEffect, useCallback } from 'react';

// Hook: 마우스 위치 추적
function useMousePosition() {
  const [position, setPosition] = useState({ x: 0, y: 0 });

  useEffect(() => {
    const handler = (e: MouseEvent) =>
      setPosition({ x: e.clientX, y: e.clientY });
    window.addEventListener('mousemove', handler);
    return () => window.removeEventListener('mousemove', handler);
  }, []);

  return position;
}

// Hook: 윈도우 크기 추적
function useWindowSize() {
  const [size, setSize] = useState({ width: 0, height: 0 });

  useEffect(() => {
    const handler = () =>
      setSize({ width: window.innerWidth, height: window.innerHeight });
    handler();
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);

  return size;
}

// Hook: 데이터 fetch
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const controller = new AbortController();
    setLoading(true);

    fetch(url, { signal: controller.signal })
      .then((res) => res.json())
      .then((json) => {
        setData(json);
        setLoading(false);
      })
      .catch((err) => {
        if (err.name !== 'AbortError') {
          setError(err.message);
          setLoading(false);
        }
      });

    return () => controller.abort();
  }, [url]);

  return { data, loading, error };
}
```

```tsx
// 사용: 플랫한 구조 — 중첩 0
'use client';

function Dashboard() {
  // 각 Hook이 독립적으로 상태 관리 — 조합이 자유로움
  const mouse = useMousePosition();
  const windowSize = useWindowSize();
  const { data, loading } = useFetch<DashboardData>('/api/dashboard');

  const columns = windowSize.width > 768 ? 3 : 1;

  return (
    <div>
      <Cursor x={mouse.x} y={mouse.y} />
      <Layout columns={columns}>
        {loading ? <Skeleton /> : <Stats data={data!} />}
      </Layout>
    </div>
  );
}
```

```tsx
// Hook 합성: 여러 Hook을 조합한 상위 Hook
function useDashboard() {
  const mouse = useMousePosition();
  const windowSize = useWindowSize();
  const { data, loading, error } = useFetch<DashboardData>('/api/dashboard');

  const isMobile = windowSize.width < 768;
  const columns = isMobile ? 1 : 3;

  return {
    mouse,
    isMobile,
    columns,
    data,
    loading,
    error,
  };
}

// 최종 컴포넌트 — 극도로 간결
function Dashboard() {
  const { mouse, columns, data, loading } = useDashboard();

  if (loading) return <DashboardSkeleton />;

  return (
    <div>
      <Cursor x={mouse.x} y={mouse.y} />
      <Layout columns={columns}>
        <Stats data={data!} />
      </Layout>
    </div>
  );
}
```

## Why

Render Props 패턴은 React Hooks 이전에 로직 재사용을 위한 주요 패턴이었다. 하지만 여러 Render Props를 조합하면 깊은 중첩(wrapper hell)이 발생하고, 코드 가독성과 유지보수성이 급격히 저하된다. Custom Hook은 동일한 로직 재사용을 플랫한 구조로 제공하며, Hook 간 조합이 자유롭다.

**정량적 효과:**
- 중첩 깊이: 3-5단 → 0단 (플랫 구조)
- 코드 라인: Render Props 조합 30줄 → Hook 호출 3줄 (90% 감소)
- 로직 재사용: Hook은 다른 Hook 내부에서 자유롭게 호출 가능
- 테스트: Hook은 renderHook으로 독립 테스트 가능 — Render Props보다 테스트 용이
- TypeScript: Hook의 반환 타입이 자동 추론 — Render Props의 제네릭보다 간결

**Render Props 유효 사례:** 애니메이션 라이브러리(Framer Motion)나 헤드리스 UI처럼 JSX 렌더링 제어가 핵심인 경우는 여전히 유효하다.

## References

- [React: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
- [React: Render Props (legacy)](https://legacy.reactjs.org/docs/render-props.html)
- [Testing Library: renderHook](https://testing-library.com/docs/react-testing-library/api#renderhook)
