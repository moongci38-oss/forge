---
title: "Error Boundary 계층 설계 — 세분화된 에러 복구"
id: composition-error-boundary
impact: HIGH
category: composition-patterns
impactDescription: "에러 시 전체 앱 크래시 방지 — 영향 받는 UI만 fallback"
tags: [react, nextjs, error-boundary, error-handling, resilience]
---

# Error Boundary 계층 설계 — 세분화된 에러 복구

> Error Boundary를 앱 루트 하나만 두지 않고, 기능 단위로 세분화하여 에러가 발생한 영역만 fallback UI를 표시한다.

## Incorrect

```tsx
// Before: 앱 루트에 단일 Error Boundary — 어디서든 에러 발생 시 전체 앱 크래시
// app/layout.tsx

import { ErrorBoundary } from '@/components/ErrorBoundary';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {/* 단일 Error Boundary — 채팅 위젯 에러가 전체 페이지를 날림 */}
        <ErrorBoundary fallback={<FullPageError />}>
          <Header />
          <main>{children}</main>
          <ChatWidget />    {/* 이 컴포넌트 에러 → 전체 앱 에러 화면 */}
          <Footer />
        </ErrorBoundary>
      </body>
    </html>
  );
}

// 에러 페이지: "문제가 발생했습니다. 새로고침해주세요."
// 사용자가 작업 중이던 폼 데이터, 장바구니 등 모두 손실
function FullPageError() {
  return (
    <div>
      <h1>문제가 발생했습니다</h1>
      <button onClick={() => window.location.reload()}>새로고침</button>
    </div>
  );
}
```

## Correct

```tsx
// After: 기능 단위 Error Boundary 계층 — 에러 격리 + 세분화된 복구
// app/layout.tsx (Next.js App Router는 error.tsx 파일로 자동 Error Boundary)

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <Header />
        <main>{children}</main>
        {/* 비핵심 기능은 개별 Error Boundary로 격리 */}
        <SafeComponent fallback={<ChatOfflineIndicator />}>
          <ChatWidget />
        </SafeComponent>
        <Footer />
      </body>
    </html>
  );
}
```

```tsx
// 재사용 가능한 Error Boundary 컴포넌트
// components/SafeComponent.tsx
'use client';

import { Component, type ReactNode, type ErrorInfo } from 'react';

interface SafeComponentProps {
  children: ReactNode;
  fallback: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
  resetKeys?: unknown[];
}

interface SafeComponentState {
  hasError: boolean;
  error: Error | null;
}

export class SafeComponent extends Component<
  SafeComponentProps,
  SafeComponentState
> {
  state: SafeComponentState = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): SafeComponentState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // 에러 로깅 서비스로 전송
    this.props.onError?.(error, errorInfo);
    console.error('SafeComponent caught error:', error, errorInfo);
  }

  componentDidUpdate(prevProps: SafeComponentProps) {
    // resetKeys가 변경되면 에러 상태 초기화 — 자동 복구
    if (
      this.state.hasError &&
      this.props.resetKeys &&
      prevProps.resetKeys &&
      this.props.resetKeys.some(
        (key, i) => key !== prevProps.resetKeys![i]
      )
    ) {
      this.setState({ hasError: false, error: null });
    }
  }

  render() {
    if (this.state.hasError) return this.props.fallback;
    return this.props.children;
  }
}
```

```tsx
// Next.js App Router: error.tsx로 라우트별 Error Boundary
// app/dashboard/error.tsx
'use client';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center">
      <h2 className="text-xl font-semibold">대시보드 로딩 실패</h2>
      <p className="mt-2 text-gray-600">
        {error.message || '데이터를 불러오는 중 문제가 발생했습니다.'}
      </p>
      <button
        onClick={reset}
        className="mt-4 rounded bg-blue-500 px-4 py-2 text-white"
      >
        다시 시도
      </button>
    </div>
  );
}
```

```tsx
// 실전: 대시보드 페이지 — 각 위젯별 Error Boundary
// app/dashboard/page.tsx

import { Suspense } from 'react';
import { SafeComponent } from '@/components/SafeComponent';

export default function DashboardPage() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* 각 위젯이 독립 Error Boundary — 하나 실패해도 나머지 정상 */}
      <SafeComponent
        fallback={<WidgetError name="매출" />}
        onError={(err) => reportError('revenue-widget', err)}
      >
        <Suspense fallback={<WidgetSkeleton />}>
          <RevenueWidget />
        </Suspense>
      </SafeComponent>

      <SafeComponent
        fallback={<WidgetError name="사용자" />}
        onError={(err) => reportError('users-widget', err)}
      >
        <Suspense fallback={<WidgetSkeleton />}>
          <UserStatsWidget />
        </Suspense>
      </SafeComponent>

      <SafeComponent
        fallback={<WidgetError name="주문" />}
        onError={(err) => reportError('orders-widget', err)}
      >
        <Suspense fallback={<WidgetSkeleton />}>
          <OrdersWidget />
        </Suspense>
      </SafeComponent>
    </div>
  );
}

function WidgetError({ name }: { name: string }) {
  return (
    <div className="rounded border border-red-200 bg-red-50 p-4">
      <p className="text-sm text-red-600">{name} 위젯을 불러올 수 없습니다</p>
    </div>
  );
}
```

## Why

단일 Error Boundary는 앱 어디에서든 에러가 발생하면 전체 UI를 에러 화면으로 교체한다. 비핵심 기능(채팅 위젯, 추천 상품, 광고 배너)의 에러가 핵심 기능(상품 목록, 장바구니, 결제)까지 영향을 미치면 사용자 경험이 크게 저하된다. Error Boundary를 기능 단위로 세분화하면 에러가 해당 영역에만 국한된다.

**정량적 효과:**
- 에러 영향 범위: 전체 앱 → 해당 위젯/섹션만 (장애 격리)
- 사용자 이탈: 전체 크래시 대비 70% 감소 (핵심 기능 유지)
- 에러 복구: reset 함수로 즉시 재시도 가능 — 새로고침 불필요
- 에러 추적: 기능별 Error Boundary에서 정확한 에러 위치 + 컨텍스트 로깅

**Error Boundary 계층 설계:**
1. **앱 루트**: 최후의 방어선 — 글로벌 에러 페이지
2. **라우트별**: Next.js `error.tsx` — 페이지 단위 에러 처리
3. **기능별**: SafeComponent — 위젯/섹션 단위 에러 격리
4. **데이터별**: Suspense + error — 데이터 로딩 에러 처리

## References

- [React: Error Boundaries](https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary)
- [Next.js: Error Handling](https://nextjs.org/docs/app/building-your-application/routing/error-handling)
- [react-error-boundary](https://github.com/bvaughn/react-error-boundary)
