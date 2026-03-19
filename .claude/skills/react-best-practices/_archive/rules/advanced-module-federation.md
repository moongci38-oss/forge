---
title: "Module Federation으로 마이크로 프론트엔드"
id: advanced-module-federation
impact: LOW
category: advanced-patterns
impactDescription: "팀별 독립 배포 — 빌드 시간 80% 감소"
tags: [react, nextjs, module-federation, micro-frontend, architecture]
---

# Module Federation으로 마이크로 프론트엔드

> 대규모 프론트엔드 애플리케이션을 Module Federation으로 분할하여 팀별 독립 빌드/배포를 구현한다.

## Incorrect

```tsx
// Before: 모노리식 프론트엔드 — 모든 기능이 하나의 빌드에 포함
// next.config.ts

import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // 모든 팀의 코드가 단일 빌드에 포함
  // - 빌드 시간: 10분+
  // - 하나의 팀 변경이 전체 재빌드 필요
  // - 모든 팀이 동일 배포 주기에 종속
  // - 패키지 버전 충돌 빈번
};

export default nextConfig;
```

```tsx
// 단일 앱에 모든 기능 직접 임포트
// app/page.tsx

import { Dashboard } from '@/features/dashboard';     // 팀 A
import { ProductCatalog } from '@/features/products';  // 팀 B
import { UserManagement } from '@/features/users';     // 팀 C
import { Analytics } from '@/features/analytics';      // 팀 D

// 모든 팀의 코드가 초기 번들에 포함 — 번들 5MB+
export default function HomePage() {
  return (
    <div>
      <Dashboard />
      <ProductCatalog />
      <UserManagement />
      <Analytics />
    </div>
  );
}
```

## Correct

```tsx
// After: Module Federation으로 팀별 독립 앱 구성
// Host App — next.config.ts
import type { NextConfig } from 'next';
import { NextFederationPlugin } from '@module-federation/nextjs-mf';

const nextConfig: NextConfig = {
  webpack(config, { isServer }) {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'host',
        remotes: {
          // 각 원격 앱은 독립 빌드/배포
          dashboard: `dashboard@${process.env.DASHBOARD_URL}/_next/static/${
            isServer ? 'ssr' : 'chunks'
          }/remoteEntry.js`,
          products: `products@${process.env.PRODUCTS_URL}/_next/static/${
            isServer ? 'ssr' : 'chunks'
          }/remoteEntry.js`,
        },
        shared: {
          react: { singleton: true, requiredVersion: false },
          'react-dom': { singleton: true, requiredVersion: false },
        },
      })
    );
    return config;
  },
};

export default nextConfig;
```

```tsx
// Host App — 원격 컴포넌트 동적 로딩
// app/page.tsx

import { Suspense, lazy } from 'react';
import { DashboardSkeleton, ProductSkeleton } from '@/components/skeletons';

// 원격 앱 컴포넌트를 동적으로 로딩
const RemoteDashboard = lazy(() =>
  import('dashboard/DashboardWidget').catch(() => ({
    default: () => <FallbackDashboard />,
  }))
);

const RemoteProducts = lazy(() =>
  import('products/ProductCatalog').catch(() => ({
    default: () => <FallbackProducts />,
  }))
);

export default function HomePage() {
  return (
    <div>
      {/* 각 원격 모듈이 독립적으로 로딩 — 장애 격리 */}
      <Suspense fallback={<DashboardSkeleton />}>
        <RemoteDashboard />
      </Suspense>
      <Suspense fallback={<ProductSkeleton />}>
        <RemoteProducts />
      </Suspense>
    </div>
  );
}
```

```tsx
// Remote App (Dashboard) — next.config.ts
import type { NextConfig } from 'next';
import { NextFederationPlugin } from '@module-federation/nextjs-mf';

const nextConfig: NextConfig = {
  webpack(config, { isServer }) {
    config.plugins.push(
      new NextFederationPlugin({
        name: 'dashboard',
        filename: 'static/chunks/remoteEntry.js',
        exposes: {
          // 팀 A가 독립적으로 관리하는 컴포넌트
          './DashboardWidget': './components/DashboardWidget',
          './RealtimeChart': './components/RealtimeChart',
        },
        shared: {
          react: { singleton: true, requiredVersion: false },
          'react-dom': { singleton: true, requiredVersion: false },
        },
      })
    );
    return config;
  },
};

export default nextConfig;
```

```tsx
// Remote App (Dashboard) — 노출 컴포넌트
// components/DashboardWidget.tsx
'use client';

import { useState, useEffect } from 'react';

export default function DashboardWidget() {
  const [metrics, setMetrics] = useState<DashboardMetrics | null>(null);

  useEffect(() => {
    // 독립적인 데이터 페칭 — 호스트 앱에 의존하지 않음
    fetch('/api/dashboard/metrics')
      .then((res) => res.json())
      .then(setMetrics);
  }, []);

  if (!metrics) return <DashboardSkeleton />;

  return (
    <div className="dashboard-widget">
      <h2>대시보드</h2>
      <MetricCard title="매출" value={metrics.revenue} />
      <MetricCard title="사용자" value={metrics.activeUsers} />
    </div>
  );
}
```

## Why

모노리식 프론트엔드는 규모가 커질수록 빌드 시간이 증가하고, 팀 간 코드 충돌이 빈번해진다. Module Federation은 Webpack 5의 네이티브 기능으로, 런타임에 다른 빌드의 모듈을 동적으로 로딩한다. 각 팀이 독립 앱으로 빌드/배포하면서도 하나의 통합된 사용자 경험을 제공한다.

**정량적 효과:**
- 빌드 시간: 10분 모노리식 → 팀별 2분 (80% 감소)
- 배포 독립성: 팀 A 변경이 팀 B 재빌드 불필요
- 장애 격리: 원격 앱 장애 시 호스트 앱 정상 동작 (Suspense fallback)
- 초기 번들: 필요한 원격 모듈만 온디맨드 로딩 — 초기 JS 60% 감소

**적용 조건:** 3개 이상 팀이 독립 기능을 개발하는 중대형 프로젝트에 적합. 소규모 프로젝트에서는 오버엔지니어링.

## References

- [Module Federation 공식 문서](https://module-federation.io/)
- [Next.js Module Federation Plugin](https://github.com/module-federation/nextjs-mf)
- [Webpack: Module Federation](https://webpack.js.org/concepts/module-federation/)
