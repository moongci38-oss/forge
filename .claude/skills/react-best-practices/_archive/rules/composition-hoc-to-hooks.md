---
title: "HOC → Hook 전환 가이드"
id: composition-hoc-to-hooks
impact: HIGH
category: composition-patterns
impactDescription: "HOC wrapper hell 제거 — 디버깅 + 타입 추론 향상"
tags: [react, patterns, hooks, hoc, refactoring, typescript]
---

# HOC → Hook 전환 가이드

> Higher-Order Component(HOC) 패턴은 Custom Hook으로 대체한다. Hook은 wrapper hell, prop 충돌, 타입 추론 문제를 모두 해결한다.

## Incorrect

```tsx
// Before: HOC 중첩 — wrapper hell + 타입 추론 불가
'use client';

import { type ComponentType } from 'react';

// HOC 1: 인증 체크
function withAuth<P extends object>(WrappedComponent: ComponentType<P>) {
  return function AuthenticatedComponent(props: P) {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
      checkAuth().then((u) => {
        setUser(u);
        setLoading(false);
      });
    }, []);

    if (loading) return <Spinner />;
    if (!user) return <RedirectToLogin />;

    // user를 props로 전달 — P 타입에 user가 없으므로 타입 에러
    return <WrappedComponent {...props} user={user} />;
  };
}

// HOC 2: 테마 주입
function withTheme<P extends object>(WrappedComponent: ComponentType<P>) {
  return function ThemedComponent(props: P) {
    const theme = useContext(ThemeContext);
    return <WrappedComponent {...props} theme={theme} />;
  };
}

// HOC 3: 분석 추적
function withAnalytics<P extends object>(
  WrappedComponent: ComponentType<P>,
  eventName: string
) {
  return function TrackedComponent(props: P) {
    useEffect(() => {
      trackEvent(eventName, { component: WrappedComponent.displayName });
    }, []);
    return <WrappedComponent {...props} />;
  };
}

// HOC 4: 권한 체크
function withPermission<P extends object>(
  WrappedComponent: ComponentType<P>,
  requiredRole: string
) {
  return function PermissionComponent(props: P) {
    const user = useContext(UserContext);
    if (!user?.roles.includes(requiredRole)) return <AccessDenied />;
    return <WrappedComponent {...props} />;
  };
}

// HOC 중첩 사용 — wrapper hell
// React DevTools: WithAuth(WithTheme(WithAnalytics(WithPermission(Dashboard))))
const DashboardPage = withAuth(
  withTheme(
    withAnalytics(
      withPermission(Dashboard, 'admin'),
      'dashboard_view'
    )
  )
);

// 문제:
// 1. React DevTools에서 4단 wrapper — 디버깅 불가
// 2. props 출처 불명확 — user, theme이 어디서 오는지 추적 어려움
// 3. TypeScript: HOC 제네릭 체이닝으로 타입 추론 실패
// 4. HOC 순서에 따라 동작이 달라질 수 있음
```

## Correct

```tsx
// After: Custom Hook으로 전환 — 플랫 구조 + 완벽한 타입 추론
'use client';

import { useState, useEffect, useContext, useCallback } from 'react';

// Hook: 인증 체크
function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth()
      .then(setUser)
      .finally(() => setLoading(false));
  }, []);

  return { user, loading, isAuthenticated: !!user };
}

// Hook: 테마
function useTheme() {
  return useContext(ThemeContext);
}

// Hook: 분석 추적
function useAnalytics(eventName: string) {
  const track = useCallback(
    (data?: Record<string, unknown>) => {
      trackEvent(eventName, data);
    },
    [eventName]
  );

  // 마운트 시 페이지뷰 자동 추적
  useEffect(() => {
    track({ type: 'page_view' });
  }, [track]);

  return { track };
}

// Hook: 권한 체크
function usePermission(requiredRole: string) {
  const { user } = useAuth();
  const hasPermission = user?.roles.includes(requiredRole) ?? false;

  return { hasPermission, user };
}
```

```tsx
// 사용: 플랫 구조 — 명확한 데이터 흐름
'use client';

function DashboardPage() {
  // 각 Hook의 반환값이 명시적 — TypeScript 완벽 추론
  const { user, loading, isAuthenticated } = useAuth();
  const theme = useTheme();
  const { track } = useAnalytics('dashboard_view');
  const { hasPermission } = usePermission('admin');

  // 조건부 렌더링이 컴포넌트 내부에서 명시적으로 처리됨
  if (loading) return <Spinner />;
  if (!isAuthenticated) return <RedirectToLogin />;
  if (!hasPermission) return <AccessDenied />;

  return (
    <div className={theme.darkMode ? 'dark' : ''}>
      <DashboardContent
        user={user!}
        onAction={(action) => track({ action })}
      />
    </div>
  );
}
```

```tsx
// 고급: Hook 합성 — 관련 로직을 하나의 Hook으로 결합
function useDashboardGuard() {
  const auth = useAuth();
  const permission = usePermission('admin');

  return {
    isReady: !auth.loading,
    isAllowed: auth.isAuthenticated && permission.hasPermission,
    user: auth.user,
    reason: !auth.isAuthenticated
      ? 'unauthenticated'
      : !permission.hasPermission
        ? 'forbidden'
        : null,
  };
}

// 사용: 가드 로직이 단일 Hook으로 캡슐화
function DashboardPage() {
  const { isReady, isAllowed, user, reason } = useDashboardGuard();
  const theme = useTheme();
  useAnalytics('dashboard_view');

  if (!isReady) return <Spinner />;
  if (!isAllowed) return <AccessDenied reason={reason!} />;

  return <DashboardContent user={user!} />;
}
```

```tsx
// HOC가 여전히 유효한 경우: 레이아웃 래핑이 필요한 경우
// (단, 내부 로직은 Hook으로 구현)

function withPageLayout<P extends object>(
  PageComponent: ComponentType<P>,
  layoutConfig: LayoutConfig
) {
  function LayoutWrapper(props: P) {
    // 로직은 Hook으로
    const { sidebarOpen, toggleSidebar } = useSidebar();

    return (
      <PageLayout
        sidebar={layoutConfig.sidebar}
        sidebarOpen={sidebarOpen}
        onToggleSidebar={toggleSidebar}
      >
        <PageComponent {...props} />
      </PageLayout>
    );
  }

  LayoutWrapper.displayName = `WithLayout(${
    PageComponent.displayName || PageComponent.name
  })`;

  return LayoutWrapper;
}
```

## Why

HOC 패턴은 React Hooks 이전에 크로스커팅 관심사(인증, 테마, 분석)를 처리하는 주요 패턴이었다. 하지만 여러 HOC를 중첩하면 React DevTools에서 래퍼가 겹겹이 쌓이고, props 출처를 추적하기 어렵고, TypeScript의 제네릭 체이닝이 복잡해진다.

**정량적 효과:**
- React DevTools: 4단 wrapper → 컴포넌트 1개 (디버깅 효율 극대화)
- TypeScript: HOC 제네릭 추론 실패 → Hook 반환 타입 100% 자동 추론
- Props 충돌: HOC간 동명 prop 충돌 위험 → Hook은 변수명으로 구분 (충돌 0)
- 테스트: renderHook으로 Hook 독립 테스트 가능 — HOC는 컴포넌트 렌더링 필요
- 코드량: HOC 정의 + 사용 30줄 → Hook 정의 + 사용 15줄 (50% 감소)

**HOC가 유효한 경우:**
1. Next.js의 `withLayout` 같은 JSX 구조 래핑
2. 라이브러리 인터페이스 (react-redux connect 호환)
3. 단, 내부 로직은 Hook으로 구현하고 HOC는 얇은 래퍼로만 사용

## References

- [React: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
- [React: Higher-Order Components (legacy)](https://legacy.reactjs.org/docs/higher-order-components.html)
- [Dan Abramov: Making Sense of Hooks](https://medium.com/@dan_abramov/making-sense-of-react-hooks-fdbde8803889)
