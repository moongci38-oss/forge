---
title: "Layout 패턴 — 공유 UI 최적화"
id: composition-layout-pattern
impact: HIGH
category: composition-patterns
impactDescription: "네비게이션 시 레이아웃 리렌더 제거 — 공유 UI 유지"
tags: [react, nextjs, layout, navigation, performance, architecture]
---

# Layout 패턴 — 공유 UI 최적화

> Next.js의 layout.tsx를 활용하여 공유 UI(네비게이션, 사이드바)를 페이지 전환 시 리렌더하지 않고 유지한다. 페이지 컴포넌트에 공통 UI를 반복하지 않는다.

## Incorrect

```tsx
// Before: 각 페이지에 공통 UI 반복 — 네비게이션마다 리렌더
// app/dashboard/page.tsx

import { Header } from '@/components/Header';
import { Sidebar } from '@/components/Sidebar';
import { Footer } from '@/components/Footer';

export default async function DashboardPage() {
  const data = await fetchDashboardData();

  return (
    <div className="flex min-h-screen flex-col">
      {/* 모든 페이지에 Header/Sidebar/Footer 반복 */}
      <Header />
      <div className="flex flex-1">
        <Sidebar />
        <main className="flex-1 p-6">
          <DashboardContent data={data} />
        </main>
      </div>
      <Footer />
    </div>
  );
}

// app/settings/page.tsx — 동일한 레이아웃 반복
export default async function SettingsPage() {
  const settings = await fetchSettings();

  return (
    <div className="flex min-h-screen flex-col">
      {/* 동일한 Header/Sidebar/Footer 반복 */}
      <Header />
      <div className="flex flex-1">
        <Sidebar />
        <main className="flex-1 p-6">
          <SettingsContent settings={settings} />
        </main>
      </div>
      <Footer />
    </div>
  );
}

// 문제:
// 1. /dashboard → /settings 네비게이션 시 Header/Sidebar 상태 리셋
// 2. Sidebar 스크롤 위치 손실
// 3. Header의 알림 드롭다운 닫힘
// 4. 코드 중복 — DRY 원칙 위반
```

## Correct

```tsx
// After: layout.tsx로 공유 UI 한 번 선언 — 네비게이션 시 유지됨
// app/dashboard/layout.tsx (Server Component)

import { Header } from '@/components/Header';
import { Sidebar } from '@/components/Sidebar';
import { Footer } from '@/components/Footer';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // layout은 네비게이션 시 리렌더하지 않음
  // Header, Sidebar 상태(스크롤 위치, 토글, 드롭다운)가 유지됨
  return (
    <div className="flex min-h-screen flex-col">
      <Header />
      <div className="flex flex-1">
        <Sidebar />
        <main className="flex-1 p-6">
          {/* children만 교체됨 — 나머지 UI 유지 */}
          {children}
        </main>
      </div>
      <Footer />
    </div>
  );
}
```

```tsx
// 페이지는 고유 콘텐츠만 렌더링
// app/dashboard/page.tsx (Server Component)

export default async function DashboardPage() {
  const data = await fetchDashboardData();
  return <DashboardContent data={data} />;
}

// app/dashboard/settings/page.tsx
export default async function SettingsPage() {
  const settings = await fetchSettings();
  return <SettingsContent settings={settings} />;
}
```

```tsx
// 중첩 레이아웃 — 계층적 공유 UI
// app/layout.tsx — 전역 레이아웃
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <GlobalHeader />
        {children}
      </body>
    </html>
  );
}

// app/dashboard/layout.tsx — 대시보드 전용 레이아웃
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex">
      <DashboardSidebar />
      <div className="flex-1">{children}</div>
    </div>
  );
}

// app/dashboard/@modal/(.)settings/page.tsx — 병렬 라우트 + 인터셉트
// 설정 페이지를 모달로 표시 — 레이아웃 유지
```

```tsx
// 조건부 레이아웃: 인증 상태에 따라 다른 레이아웃
// app/(authenticated)/layout.tsx
import { redirect } from 'next/navigation';
import { getSession } from '@/lib/auth';

export default async function AuthenticatedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const session = await getSession();
  if (!session) redirect('/login');

  return (
    <div className="flex">
      <AuthenticatedSidebar user={session.user} />
      <main className="flex-1">{children}</main>
    </div>
  );
}

// app/(public)/layout.tsx — 비인증 레이아웃
export default function PublicLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div>
      <PublicNavbar />
      <main>{children}</main>
      <PublicFooter />
    </div>
  );
}
```

## Why

Next.js의 `layout.tsx`는 라우트 세그먼트 간 공유 UI를 정의하는 특별한 파일이다. 중요한 점은 layout이 네비게이션 시 **리렌더되지 않는다**는 것이다. React는 layout의 상태를 보존하고 `children` prop만 새 페이지로 교체한다. 각 페이지에 공통 UI를 반복하면 이 최적화를 활용하지 못한다.

**정량적 효과:**
- 네비게이션 속도: 공유 UI 리렌더 제거 — 페이지 전환 50-70% 빠름
- UI 상태 보존: Sidebar 스크롤, 드롭다운, 입력값 유지
- 코드 중복: 페이지당 20-30줄 레이아웃 코드 제거
- 서버 렌더링: layout은 Server Component로 유지 가능 — JS 번들 최소화
- Streaming: layout이 먼저 렌더링 → children이 스트리밍 → 빠른 FCP

## References

- [Next.js: Layouts](https://nextjs.org/docs/app/building-your-application/routing/layouts-and-templates)
- [Next.js: Route Groups](https://nextjs.org/docs/app/building-your-application/routing/route-groups)
- [Next.js: Parallel Routes](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)
