---
title: "Service Worker 캐싱 전략"
id: advanced-service-worker
impact: LOW
category: advanced-patterns
impactDescription: "오프라인 지원 + 반복 방문 즉시 로드 — 네트워크 요청 90% 감소"
tags: [react, nextjs, performance, service-worker, pwa, caching]
---

# Service Worker 캐싱 전략

> Service Worker를 활용하여 정적 자산과 API 응답을 전략적으로 캐싱하고, 오프라인 지원과 반복 방문 시 즉시 로드를 구현한다.

## Incorrect

```tsx
// Before: Service Worker 없음 — 매 방문마다 모든 리소스 네트워크에서 다운로드
// 오프라인 시 앱 완전 사용 불가

// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {/* Service Worker 등록 없음 */}
        {/* 캐싱 전략 없음 — 브라우저 기본 캐시에만 의존 */}
        {/* 오프라인 접근 불가 */}
        {children}
      </body>
    </html>
  );
}

// 모든 API 호출이 매번 네트워크로 전달
// 동일한 데이터를 반복 요청 — 대역폭 낭비
async function fetchProducts() {
  // 캐시 헤더에만 의존 — 세밀한 캐싱 전략 불가
  const res = await fetch('/api/products');
  return res.json();
}
```

## Correct

```tsx
// After: Workbox 기반 Service Worker + 전략적 캐싱
// next.config.ts
import type { NextConfig } from 'next';
import withPWA from 'next-pwa';

const nextConfig: NextConfig = withPWA({
  dest: 'public',
  register: true,
  skipWaiting: true,
  runtimeCaching: [
    // 정적 자산 — Cache First (빠른 로딩, 배경 업데이트)
    {
      urlPattern: /\/_next\/static\/.*/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'static-assets',
        expiration: {
          maxEntries: 200,
          maxAgeSeconds: 30 * 24 * 60 * 60, // 30일
        },
      },
    },
    // 이미지 — Cache First + 크기 제한
    {
      urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp|avif)$/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'images',
        expiration: {
          maxEntries: 100,
          maxAgeSeconds: 7 * 24 * 60 * 60, // 7일
        },
      },
    },
    // API 응답 — Stale While Revalidate (즉시 캐시 응답 + 배경 갱신)
    {
      urlPattern: /\/api\/products.*/i,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'api-products',
        expiration: {
          maxEntries: 50,
          maxAgeSeconds: 60 * 60, // 1시간
        },
        cacheableResponse: {
          statuses: [0, 200],
        },
      },
    },
    // 페이지 네비게이션 — Network First (최신 콘텐츠 우선)
    {
      urlPattern: /^https?.*/,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'pages',
        networkTimeoutSeconds: 3, // 3초 내 응답 없으면 캐시 사용
        expiration: {
          maxEntries: 30,
          maxAgeSeconds: 24 * 60 * 60, // 24시간
        },
      },
    },
  ],
})({});

export default nextConfig;
```

```tsx
// Service Worker 등록 컴포넌트
// components/ServiceWorkerRegistration.tsx
'use client';

import { useEffect } from 'react';

export function ServiceWorkerRegistration() {
  useEffect(() => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker
        .register('/sw.js')
        .then((registration) => {
          // 업데이트 감지 — 사용자에게 새 버전 알림
          registration.addEventListener('updatefound', () => {
            const newWorker = registration.installing;
            if (!newWorker) return;

            newWorker.addEventListener('statechange', () => {
              if (
                newWorker.state === 'installed' &&
                navigator.serviceWorker.controller
              ) {
                // 새 버전 사용 가능 — 사용자에게 리프레시 안내
                showUpdateNotification();
              }
            });
          });
        })
        .catch((err) => {
          console.error('Service Worker 등록 실패:', err);
        });
    }
  }, []);

  return null;
}

function showUpdateNotification() {
  // 앱 내 토스트로 업데이트 안내
  if (confirm('새 버전이 있습니다. 새로고침할까요?')) {
    window.location.reload();
  }
}
```

```tsx
// 오프라인 폴백 페이지
// app/offline/page.tsx

export default function OfflinePage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="text-center">
        <h1 className="text-2xl font-bold">오프라인 상태</h1>
        <p className="mt-2 text-gray-600">
          인터넷 연결을 확인한 후 다시 시도해주세요.
        </p>
        <button
          onClick={() => window.location.reload()}
          className="mt-4 rounded bg-blue-500 px-4 py-2 text-white"
        >
          다시 시도
        </button>
      </div>
    </div>
  );
}
```

## Why

Service Worker는 브라우저와 네트워크 사이에서 프록시 역할을 하여 네트워크 요청을 가로채고 캐싱 전략에 따라 응답을 제공한다. 적절한 캐싱 전략은 반복 방문 시 네트워크 요청을 90% 이상 감소시키고, 오프라인에서도 핵심 기능을 사용할 수 있게 한다.

**캐싱 전략 선택:**
| 전략 | 적용 대상 | 특성 |
|------|----------|------|
| Cache First | 정적 자산, 폰트, 이미지 | 캐시 우선 — 최고 속도 |
| Network First | HTML 페이지, 인증 API | 최신 데이터 우선 — 오프라인 폴백 |
| Stale While Revalidate | 상품 목록, 비실시간 API | 즉시 캐시 응답 + 배경 갱신 |

**정량적 효과:**
- 반복 방문: 네트워크 요청 90% 감소 — 즉시 로드
- 오프라인: 핵심 기능 사용 가능 — 사용자 이탈 방지
- Core Web Vitals: LCP 50-80% 개선 (캐시 히트 시)
- 대역폭: 월간 데이터 전송량 70% 절감

## References

- [Workbox: Caching Strategies](https://developer.chrome.com/docs/workbox/caching-strategies-overview)
- [next-pwa](https://github.com/shadowwalker/next-pwa)
- [web.dev: Service Worker Overview](https://web.dev/articles/service-workers-cache-storage)
