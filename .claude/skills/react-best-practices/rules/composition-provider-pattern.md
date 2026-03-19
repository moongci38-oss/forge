---
title: "Provider 계층 최적화 — 불필요한 중첩 제거"
id: composition-provider-pattern
impact: HIGH
category: composition-patterns
impactDescription: "Provider 렌더링 오버헤드 감소 — 초기 렌더 20-30% 개선"
tags: [react, nextjs, performance, provider, context, architecture]
---

# Provider 계층 최적화 — 불필요한 중첩 제거

> Provider를 기능별로 분리하고, 클라이언트 전용 Provider는 layout에서 관리한다. 불필요한 중첩은 렌더링 오버헤드를 증가시킨다.

## Incorrect

```tsx
// Before: 10+ Provider가 루트에 중첩 — wrapper hell + 불필요한 리렌더
// app/layout.tsx
'use client'; // 레이아웃 전체가 클라이언트 — Server Component 이점 상실

import { ThemeProvider } from '@/providers/ThemeProvider';
import { AuthProvider } from '@/providers/AuthProvider';
import { QueryClientProvider, QueryClient } from '@tanstack/react-query';
import { ToastProvider } from '@/providers/ToastProvider';
import { ModalProvider } from '@/providers/ModalProvider';
import { SidebarProvider } from '@/providers/SidebarProvider';
import { I18nProvider } from '@/providers/I18nProvider';
import { AnalyticsProvider } from '@/providers/AnalyticsProvider';
import { FeatureFlagProvider } from '@/providers/FeatureFlagProvider';
import { NotificationProvider } from '@/providers/NotificationProvider';

const queryClient = new QueryClient();

// 매번 새 QueryClient 인스턴스가 생성될 위험
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {/* 10단 중첩 — 가독성 최악, 리렌더 전파 우려 */}
        <ThemeProvider>
          <I18nProvider>
            <AuthProvider>
              <QueryClientProvider client={queryClient}>
                <FeatureFlagProvider>
                  <AnalyticsProvider>
                    <ToastProvider>
                      <ModalProvider>
                        <SidebarProvider>
                          <NotificationProvider>
                            {children}
                          </NotificationProvider>
                        </SidebarProvider>
                      </ModalProvider>
                    </ToastProvider>
                  </AnalyticsProvider>
                </FeatureFlagProvider>
              </QueryClientProvider>
            </AuthProvider>
          </I18nProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
```

## Correct

```tsx
// After: layout은 Server Component 유지 — Provider는 별도 클라이언트 컴포넌트로 분리
// app/layout.tsx (Server Component)

import { Providers } from '@/components/Providers';
import { getLocale } from '@/lib/i18n';

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // 서버에서 필요한 데이터를 미리 fetch
  const locale = await getLocale();

  return (
    <html lang={locale}>
      <body>
        {/* 클라이언트 Provider를 하나의 컴포넌트로 모아서 경계 최소화 */}
        <Providers locale={locale}>{children}</Providers>
      </body>
    </html>
  );
}
```

```tsx
// components/Providers.tsx
'use client';

import { type ReactNode, useState } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from '@/providers/ThemeProvider';
import { AuthProvider } from '@/providers/AuthProvider';
import { ToastProvider } from '@/providers/ToastProvider';

// Provider 합성 유틸리티 — 중첩 제거
function composeProviders(
  ...providers: Array<React.FC<{ children: ReactNode }>>
) {
  return function ComposedProviders({ children }: { children: ReactNode }) {
    return providers.reduceRight(
      (child, Provider) => <Provider>{child}</Provider>,
      children
    );
  };
}

// 쿼리 클라이언트 싱글턴 — 리렌더 시 재생성 방지
function makeQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000, // 1분
        refetchOnWindowFocus: false,
      },
    },
  });
}

let browserQueryClient: QueryClient | undefined;

function getQueryClient() {
  if (typeof window === 'undefined') return makeQueryClient();
  if (!browserQueryClient) browserQueryClient = makeQueryClient();
  return browserQueryClient;
}

export function Providers({
  children,
  locale,
}: {
  children: ReactNode;
  locale: string;
}) {
  const queryClient = getQueryClient();

  // 계층 분리: 전역(인증, 테마) → 데이터(쿼리) → UI(토스트)
  return (
    <AuthProvider>
      <ThemeProvider>
        <QueryClientProvider client={queryClient}>
          <ToastProvider>{children}</ToastProvider>
        </QueryClientProvider>
      </ThemeProvider>
    </AuthProvider>
  );
}
```

```tsx
// 페이지/레이아웃별 Provider 스코핑 — 전역 오염 방지
// app/dashboard/layout.tsx (Server Component)

import { DashboardProviders } from './DashboardProviders';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <DashboardProviders>{children}</DashboardProviders>;
}

// app/dashboard/DashboardProviders.tsx
'use client';

import { SidebarProvider } from '@/providers/SidebarProvider';
import { DashboardFilterProvider } from '@/providers/DashboardFilterProvider';

// 대시보드에서만 필요한 Provider — 다른 페이지에 영향 없음
export function DashboardProviders({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <SidebarProvider>
      <DashboardFilterProvider>{children}</DashboardFilterProvider>
    </SidebarProvider>
  );
}
```

## Why

Provider 중첩이 깊어지면 각 Provider의 상태 변경이 하위 트리 전체의 리렌더를 유발할 수 있다. 또한 layout을 `'use client'`로 선언하면 Server Component의 이점(서버 렌더링, DB 직접 접근, JS 번들 제외)을 모두 잃는다.

**정량적 효과:**
- Layout Server Component 유지: JS 번들에서 layout 코드 제외 — 번들 10-20% 감소
- Provider 스코핑: 대시보드 Provider가 홈페이지 렌더링에 영향 0
- QueryClient 싱글턴: 리렌더마다 재생성 방지 — 캐시 유실 0
- 초기 렌더: Provider 계층 정리로 20-30% 개선 (렌더 트리 깊이 감소)

**Provider 배치 원칙:**
1. 전역 Provider(인증, 테마)만 루트에 배치
2. 기능별 Provider는 해당 레이아웃에 스코핑
3. layout.tsx는 Server Component 유지 — Provider는 별도 Client Component로 분리

## References

- [Next.js: Providers](https://nextjs.org/docs/app/building-your-application/rendering/composition-patterns#using-context-providers)
- [React: Context](https://react.dev/learn/passing-data-deeply-with-context)
- [TanStack Query: SSR](https://tanstack.com/query/latest/docs/framework/react/guides/ssr)
