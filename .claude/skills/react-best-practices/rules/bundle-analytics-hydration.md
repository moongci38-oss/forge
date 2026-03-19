---
title: "Analytics/추적 스크립트는 hydration 이후 로드"
id: bundle-analytics-hydration
impact: CRITICAL
category: bundle-size-optimization
impactDescription: "TBT(Total Blocking Time) 200-500ms 감소"
tags: [react, nextjs, performance, bundle, analytics, hydration, script]
---

# Analytics/추적 스크립트는 hydration 이후 로드

> Analytics, 추적, 광고 스크립트를 초기 로드에 포함하면 hydration을 블로킹하여 인터랙션 지연이 발생한다. hydration 완료 후에 로드한다.

## Incorrect

```tsx
// Before: <head>에 직접 스크립트 태그 포함 — 페이지 파싱/렌더링 블로킹
// app/layout.tsx

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <head>
        {/* 렌더 블로킹 스크립트 — 페이지 로드 지연 */}
        <script src="https://www.googletagmanager.com/gtag/js?id=G-XXXXX" />
        {/* 인라인 스크립트도 파싱 블로킹 */}
        {/* gtag('config', 'G-XXXXX') 등의 초기화 코드 */}
      </head>
      <body>{children}</body>
    </html>
  );
}
```

```tsx
// 또한 나쁨: 탑 레벨 import로 analytics SDK 포함
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react';
import { initMixpanel } from '@/lib/mixpanel';
import { initSentry } from '@/lib/sentry';

// 이 초기화 코드가 초기 번들에 포함됨
initMixpanel();
initSentry();
```

## Correct

```tsx
// After: next/script의 적절한 strategy 활용
// app/layout.tsx

import Script from 'next/script';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>
        {children}

        {/* afterInteractive: hydration 완료 후 로드 (기본값) */}
        <Script
          src="https://www.googletagmanager.com/gtag/js?id=G-XXXXX"
          strategy="afterInteractive"
        />
        <Script
          id="gtag-init"
          strategy="afterInteractive"
          src="/scripts/gtag-init.js"
        />

        {/* lazyOnload: 모든 리소스 로드 후 — 최저 우선순위 */}
        <Script
          id="fb-pixel"
          strategy="lazyOnload"
          src="/scripts/fb-pixel-init.js"
        />
      </body>
    </html>
  );
}
```

```tsx
// Vercel Analytics — 자동으로 최적화된 로딩
// app/layout.tsx

import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body>
        {children}
        {/* 자동으로 afterInteractive 전략 사용 */}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
```

```tsx
// 동적 import로 analytics SDK 초기화 지연
// lib/analytics.ts

export async function initAnalytics() {
  if (typeof window === 'undefined') return;

  // hydration 이후 동적 import
  const [{ default: mixpanel }, { init: initSentry }] = await Promise.all([
    import('mixpanel-browser'),
    import('@sentry/nextjs'),
  ]);

  mixpanel.init(process.env.NEXT_PUBLIC_MIXPANEL_TOKEN!);
  initSentry({ dsn: process.env.NEXT_PUBLIC_SENTRY_DSN });
}

// app/providers.tsx
'use client';

import { useEffect } from 'react';
import { initAnalytics } from '@/lib/analytics';

export function AnalyticsProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // hydration 완료 후 실행
    initAnalytics();
  }, []);

  return <>{children}</>;
}
```

## Why

Analytics/추적 스크립트는 일반적으로 50-200KB이며, 초기 로드에 포함하면:

1. **HTML 파싱 블로킹**: `<script>` 태그가 파서를 멈춤
2. **메인 스레드 점유**: JS 실행이 hydration을 지연
3. **네트워크 경쟁**: 핵심 리소스와 대역폭 경쟁

`next/script`의 strategy 옵션으로 로드 시점을 제어:
- `beforeInteractive`: 반드시 hydration 전에 필요한 스크립트 (극히 드묾)
- `afterInteractive`: hydration 직후 (기본값, 대부분의 analytics)
- `lazyOnload`: 모든 리소스 로드 후 (우선순위 낮은 추적)
- `worker` (실험적): Web Worker에서 실행

**정량적 효과:**
- TBT(Total Blocking Time): 200-500ms 감소
- FID(First Input Delay): 100-300ms 개선
- INP(Interaction to Next Paint): 초기 인터랙션 반응 속도 개선
- Lighthouse 성능 점수: 5-15점 상승

## References

- [Next.js Script Component](https://nextjs.org/docs/app/building-your-application/optimizing/scripts)
- [Web.dev Third-Party Scripts](https://web.dev/articles/optimizing-content-efficiency-loading-third-party-javascript)
- [Vercel Analytics](https://vercel.com/docs/analytics)
