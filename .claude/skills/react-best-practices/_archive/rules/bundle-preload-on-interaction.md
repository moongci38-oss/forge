---
title: "인터랙션 시점에 프리로드 — 페이지 로드 시 prefetch 금지"
id: bundle-preload-on-interaction
impact: CRITICAL
category: bundle-size-optimization
impactDescription: "체감 네비게이션 속도 2-3x 개선"
tags: [react, nextjs, performance, bundle, preload, prefetch, interaction]
---

# 인터랙션 시점에 프리로드 — 페이지 로드 시 prefetch 금지

> 모든 라우트를 페이지 로드 시 prefetch하면 대역폭을 낭비한다. 사용자 의도 신호(hover, focus)에 따라 선택적으로 프리로드한다.

## Incorrect

```tsx
// Before: 모든 링크가 기본 prefetch — 불필요한 네트워크 요청 대량 발생
// components/Navigation.tsx

import Link from 'next/link';

export function Navigation() {
  return (
    <nav>
      {/* Next.js Link는 기본적으로 뷰포트에 보이면 자동 prefetch */}
      {/* 10개 링크 = 10개 라우트의 JS/데이터를 미리 로드 */}
      <Link href="/dashboard">Dashboard</Link>
      <Link href="/analytics">Analytics</Link>
      <Link href="/reports">Reports</Link>
      <Link href="/settings">Settings</Link>
      <Link href="/billing">Billing</Link>
      <Link href="/team">Team</Link>
      <Link href="/integrations">Integrations</Link>
      <Link href="/docs">Documentation</Link>
      <Link href="/changelog">Changelog</Link>
      <Link href="/support">Support</Link>
    </nav>
  );
}
// 페이지 로드 시 10개 라우트의 RSC Payload + JS 청크를 모두 다운로드
// 사용자가 실제 클릭하는 것은 1-2개 뿐
```

## Correct

```tsx
// After: prefetch 비활성화 + hover 시 선택적 프리로드
// components/Navigation.tsx

import Link from 'next/link';

export function Navigation() {
  return (
    <nav>
      {/* 자주 방문하는 핵심 경로만 prefetch 허용 */}
      <Link href="/dashboard" prefetch={true}>
        Dashboard
      </Link>

      {/* 나머지는 prefetch 비활성화 */}
      <Link href="/analytics" prefetch={false}>
        Analytics
      </Link>
      <Link href="/reports" prefetch={false}>
        Reports
      </Link>
      <Link href="/settings" prefetch={false}>
        Settings
      </Link>
      <Link href="/billing" prefetch={false}>
        Billing
      </Link>
      <Link href="/team" prefetch={false}>
        Team
      </Link>
      <Link href="/integrations" prefetch={false}>
        Integrations
      </Link>
      <Link href="/docs" prefetch={false}>
        Documentation
      </Link>
      <Link href="/changelog" prefetch={false}>
        Changelog
      </Link>
      <Link href="/support" prefetch={false}>
        Support
      </Link>
    </nav>
  );
}
```

```tsx
// 고급 패턴: hover/focus 시 동적 프리로드
// components/SmartLink.tsx

'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useCallback, type ComponentProps } from 'react';

type SmartLinkProps = ComponentProps<typeof Link> & {
  preloadOnHover?: boolean;
};

export function SmartLink({
  href,
  preloadOnHover = true,
  children,
  ...props
}: SmartLinkProps) {
  const router = useRouter();

  const handleMouseEnter = useCallback(() => {
    if (preloadOnHover && typeof href === 'string') {
      // hover 시 라우트 프리페치 시작
      router.prefetch(href);
    }
  }, [href, preloadOnHover, router]);

  const handleFocus = useCallback(() => {
    if (preloadOnHover && typeof href === 'string') {
      // 키보드 네비게이션(Tab) 시에도 프리페치
      router.prefetch(href);
    }
  }, [href, preloadOnHover, router]);

  return (
    <Link
      href={href}
      prefetch={false}
      onMouseEnter={handleMouseEnter}
      onFocus={handleFocus}
      {...props}
    >
      {children}
    </Link>
  );
}
```

```tsx
// 무거운 컴포넌트의 인터랙션 기반 프리로드
// components/FeatureCard.tsx

'use client';

import { useCallback } from 'react';

export function FeatureCard() {
  const handleMouseEnter = useCallback(() => {
    // hover 시점에 무거운 모듈을 미리 로드
    // 클릭 시에는 이미 캐시에 있으므로 즉시 렌더링
    import('@/components/HeavyFeature');
  }, []);

  const handleClick = useCallback(async () => {
    const { HeavyFeature } = await import('@/components/HeavyFeature');
    // 이미 프리로드되어 있으므로 즉시 사용 가능
    // ... 렌더링 로직
  }, []);

  return (
    <div
      onMouseEnter={handleMouseEnter}
      onClick={handleClick}
      role="button"
      tabIndex={0}
    >
      <h3>Heavy Feature</h3>
      <p>Hover to preload, click to activate</p>
    </div>
  );
}
```

```tsx
// viewport 진입 시 프리로드 — IntersectionObserver 활용
// hooks/usePreloadOnVisible.ts

'use client';

import { useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';

export function usePreloadOnVisible(href: string) {
  const ref = useRef<HTMLElement>(null);
  const router = useRouter();

  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          router.prefetch(href);
          observer.disconnect(); // 1번만 프리페치
        }
      },
      { rootMargin: '200px' } // 뷰포트 200px 전에 시작
    );

    observer.observe(element);
    return () => observer.disconnect();
  }, [href, router]);

  return ref;
}
```

## Why

Next.js의 기본 prefetch 동작은 뷰포트에 보이는 모든 `<Link>`의 라우트를 자동으로 프리페치한다. 네비게이션에 10개 링크가 있으면 10개 라우트의 RSC Payload + JS 청크를 모두 다운로드한다. 대부분의 사용자는 이 중 1-2개만 클릭한다.

**인터랙션 기반 프리로드 전략:**

| 시점 | 용도 | 신뢰도 |
|------|------|:------:|
| hover (mouseenter) | 데스크톱 네비게이션 | 높음 (80%+ 클릭 확률) |
| focus (Tab 키) | 키보드 네비게이션 | 높음 |
| viewport 진입 | 스크롤 기반 콘텐츠 | 중간 |
| 페이지 로드 | 핵심 경로 1-2개만 | 확실 |

**정량적 효과:**
- 네트워크 요청: 10개 → 1-2개 (페이지 로드 시)
- 대역폭 절약: 80-90% (불필요한 prefetch 제거)
- hover → click 평균 200-300ms 지연 — 이 시간에 프리페치 완료
- 체감 네비게이션 속도: 프리페치 없는 것 대비 2-3x 빠름

**모바일 고려사항:**
- 모바일에는 hover가 없으므로 viewport 진입 기반 프리로드 사용
- `touchstart` 이벤트로 터치 시작 시 프리페치 시작 가능

## References

- [Next.js Link prefetch](https://nextjs.org/docs/app/api-reference/components/link#prefetch)
- [Next.js Router prefetch](https://nextjs.org/docs/app/api-reference/functions/use-router#userouter)
- [Web.dev Preload Critical Assets](https://web.dev/articles/preload-critical-assets)
