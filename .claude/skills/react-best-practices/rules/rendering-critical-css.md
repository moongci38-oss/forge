---
title: "Critical CSS 인라인 — 나머지 비동기 로드"
id: rendering-critical-css
impact: MEDIUM
category: rendering-performance
impactDescription: "FCP 30-50% 개선 — 첫 렌더에 필요한 CSS만 인라인"
tags: [react, nextjs, performance, css, fcp, critical-rendering-path]
---

# Critical CSS 인라인 — 나머지 비동기 로드

> 전체 CSS를 하나의 큰 번들로 로드하면 파싱 완료까지 첫 렌더가 블로킹된다. 첫 화면에 필요한 Critical CSS만 인라인하고 나머지는 비동기로 로드하면 FCP를 크게 개선한다.

## Incorrect

```tsx
// Before: 거대한 단일 CSS 번들이 렌더링을 블로킹
// app/layout.tsx

// 전체 앱의 모든 스타일을 하나의 파일에 import
import '@/styles/globals.css';        // 기본 스타일
import '@/styles/components.css';     // 모든 컴포넌트 스타일
import '@/styles/animations.css';     // 애니메이션 (대부분 페이지에서 불필요)
import '@/styles/admin-dashboard.css';// 관리자 전용 (일반 사용자에게 불필요)
import '@/styles/print.css';          // 인쇄 스타일 (거의 사용 안 함)

// 총 300KB CSS → 파싱 완료까지 첫 렌더 블로킹
// 사용자가 보는 첫 화면에 필요한 CSS는 20KB에 불과

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>{children}</body>
    </html>
  );
}
```

```tsx
// Before: 사용하지 않는 CSS 유틸리티가 번들에 포함
// globals.css에 Tailwind를 사용하지만 purge 미설정
// @tailwind base;
// @tailwind components;
// @tailwind utilities;
// → 전체 Tailwind CSS (~3.5MB 미압축)가 포함됨
```

## Correct

```tsx
// After: Next.js App Router의 자동 CSS 최적화 활용
// app/layout.tsx

// globals.css에는 정말 전역적인 스타일만 포함
import '@/styles/globals.css';

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>{children}</body>
    </html>
  );
}
```

```css
/* globals.css — 최소한의 전역 스타일 */
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Tailwind는 빌드 시 사용된 클래스만 포함 (자동 purge) */
/* 미사용 클래스 제거 → 3.5MB → ~10-30KB */
```

```tsx
// 라우트별 CSS 자동 분리 — Next.js가 자동 처리
// app/admin/layout.tsx
import '@/styles/admin.css';  // admin 라우트에서만 로드됨

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return <div className="admin-wrapper">{children}</div>;
}

// app/(public)/layout.tsx
// admin.css가 여기서는 로드되지 않음 — 자동 코드 스플리팅
export default function PublicLayout({ children }: { children: React.ReactNode }) {
  return <div>{children}</div>;
}
```

```tsx
// 무거운 CSS-in-JS 또는 애니메이션 라이브러리 — 동적 import로 지연 로드
import dynamic from 'next/dynamic';

// 무거운 차트 컴포넌트 — 해당 CSS도 함께 지연 로드
const DashboardCharts = dynamic(
  () => import('@/components/DashboardCharts'),
  {
    loading: () => <ChartsSkeleton />,
    ssr: false,
  },
);

// 인쇄 스타일 — 인쇄 시에만 필요
function PrintButton() {
  const handlePrint = async () => {
    // 인쇄 스타일을 동적으로 로드
    await import('@/styles/print.css');
    window.print();
  };

  return <button onClick={handlePrint}>인쇄</button>;
}
```

```tsx
// Tailwind CSS 최적화 설정 — tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  // content 경로를 정확히 지정 — 사용된 클래스만 포함
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    // node_modules의 UI 라이브러리도 포함 (필요 시)
    './node_modules/@acme/ui/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      // 커스텀 테마만 extend — 기본 값 대체 시 사용되지 않는 값 제거됨
    },
  },
};

export default config;
```

```tsx
// next.config.ts — CSS 최적화 설정
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // CSS 최적화 (기본 활성화)
  // Next.js가 자동으로:
  // 1. 라우트별 CSS 코드 스플리팅
  // 2. Critical CSS 인라인 (첫 렌더에 필요한 스타일)
  // 3. 나머지 CSS 비동기 로드
  // 4. 프로덕션에서 CSS 압축(minification)
  experimental: {
    optimizeCss: true, // Critters 기반 Critical CSS 추출 (실험적)
  },
};

export default nextConfig;
```

## Why

CSS는 렌더링 블로킹 리소스이다. 브라우저는 CSSOM(CSS Object Model)을 완성해야 첫 화면을 그릴 수 있다. 300KB의 CSS 번들은 파싱에 50-200ms가 소요되며, 이 시간 동안 사용자는 빈 화면을 본다.

Critical CSS 전략:
1. **첫 화면에 필요한 CSS만 `<style>` 태그로 인라인**: 추가 HTTP 요청 없이 즉시 적용
2. **나머지 CSS는 `<link rel="preload">` 또는 비동기로 로드**: 첫 렌더 블로킹 없음
3. **라우트별 CSS 분리**: 관리자 CSS가 일반 사용자 번들에 포함되지 않음

Next.js App Router의 자동 최적화:
- **CSS 코드 스플리팅**: 각 라우트에서 import한 CSS만 해당 라우트에 포함
- **Tailwind purge**: 빌드 시 사용된 클래스만 포함 (3.5MB → 10-30KB)
- **`optimizeCss: true`**: Critters 라이브러리로 Critical CSS를 자동 추출하여 인라인

**정량적 효과:**
- FCP(First Contentful Paint): CSS 블로킹 시간 감소로 30-50% 개선
- CSS 번들 크기: Tailwind purge → 3.5MB → ~20KB (99.4% 감소)
- 라우트별 분리: 관리자 전용 CSS 50KB가 일반 사용자에게 로드되지 않음
- `optimizeCss`로 Critical CSS 인라인: 추가 CSS HTTP 요청 제거

## References

- [Next.js CSS 최적화](https://nextjs.org/docs/app/building-your-application/optimizing/css)
- [Web.dev — Extract critical CSS](https://web.dev/articles/extract-critical-css)
- [Tailwind CSS — Optimizing for Production](https://tailwindcss.com/docs/optimizing-for-production)
