---
title: "호버 시 데이터 프리페치"
id: client-prefetch-on-hover
impact: HIGH
category: client-data-fetching
impactDescription: "네비게이션 체감 속도 2-3x — hover->click 간 데이터 준비"
tags: [react, prefetch, hover, ux, performance]
---

# 호버 시 데이터 프리페치

> 사용자가 링크를 클릭한 후에야 데이터를 가져오면 네비게이션마다 로딩 지연이 발생한다. 마우스 호버 시점에 데이터를 미리 가져오면, 클릭 시 이미 캐시된 데이터가 즉시 표시된다.

## Incorrect

```tsx
// Before: 클릭 후 데이터 페치 — 매번 로딩 대기
// components/ProductCard.tsx
'use client';

import Link from 'next/link';

interface Product {
  id: string;
  name: string;
  thumbnailUrl: string;
  price: number;
}

export function ProductCard({ product }: { product: Product }) {
  return (
    // 클릭 → 페이지 이동 → 그제서야 상세 데이터 fetch 시작
    // 사용자는 200-800ms 동안 로딩 스피너를 봐야 함
    <Link href={`/products/${product.id}`}>
      <div className="rounded-lg border p-4">
        <img src={product.thumbnailUrl} alt={product.name} />
        <h3>{product.name}</h3>
        <p>{product.price.toLocaleString()}원</p>
      </div>
    </Link>
  );
}

// app/products/[id]/page.tsx
// 클릭 후에야 이 페이지가 렌더링되고 데이터 fetch 시작
export default async function ProductDetailPage({
  params,
}: {
  params: { id: string };
}) {
  // 이 시점에서 처음 fetch — 사용자가 이미 클릭한 후
  const product = await fetchProductDetail(params.id);
  return <ProductDetail product={product} />;
}
```

## Correct

```tsx
// After: 호버 시 SWR 프리페치 — 클릭 시 캐시 히트로 즉시 표시
// components/ProductCard.tsx
'use client';

import Link from 'next/link';
import { useCallback } from 'react';
import { preload } from 'swr';

interface Product {
  id: string;
  name: string;
  thumbnailUrl: string;
  price: number;
}

const fetcher = (url: string) => fetch(url).then((r) => r.json());

export function ProductCard({ product }: { product: Product }) {
  // 호버 시 상세 데이터를 SWR 캐시에 미리 로드
  const handleMouseEnter = useCallback(() => {
    preload(`/api/products/${product.id}`, fetcher);
  }, [product.id]);

  return (
    <Link
      href={`/products/${product.id}`}
      onMouseEnter={handleMouseEnter}
      // 모바일: 터치 시작 시 프리페치 (호버 없음)
      onTouchStart={handleMouseEnter}
    >
      <div className="rounded-lg border p-4">
        <img src={product.thumbnailUrl} alt={product.name} />
        <h3>{product.name}</h3>
        <p>{product.price.toLocaleString()}원</p>
      </div>
    </Link>
  );
}

// app/products/[id]/detail-client.tsx
// 상세 페이지 Client Component — SWR 캐시에서 즉시 데이터 사용
'use client';

import useSWR from 'swr';

interface ProductDetail {
  id: string;
  name: string;
  description: string;
  price: number;
  images: string[];
  specs: Record<string, string>;
}

export function ProductDetailClient({ productId }: { productId: string }) {
  // 호버 시 이미 프리페치됨 — 캐시 히트로 즉시 데이터 반환
  const { data, isLoading } = useSWR<ProductDetail>(
    `/api/products/${productId}`
  );

  if (isLoading) return <ProductDetailSkeleton />;
  if (!data) return null;

  return (
    <div>
      <h1>{data.name}</h1>
      <p className="text-2xl">{data.price.toLocaleString()}원</p>
      <p>{data.description}</p>
    </div>
  );
}
```

```tsx
// 심화: Next.js router.prefetch + SWR 프리페치 조합
// components/ProductGrid.tsx
'use client';

import { useRouter } from 'next/navigation';
import { useCallback } from 'react';
import { preload } from 'swr';

const fetcher = (url: string) => fetch(url).then((r) => r.json());

export function ProductGrid({ products }: { products: Product[] }) {
  const router = useRouter();

  const handlePrefetch = useCallback(
    (productId: string) => {
      // 1. Next.js 라우트 프리페치 (RSC payload + JS 번들)
      router.prefetch(`/products/${productId}`);

      // 2. SWR 데이터 프리페치 (API 데이터)
      preload(`/api/products/${productId}`, fetcher);
    },
    [router]
  );

  return (
    <div className="grid grid-cols-3 gap-4">
      {products.map((product) => (
        <Link
          key={product.id}
          href={`/products/${product.id}`}
          onMouseEnter={() => handlePrefetch(product.id)}
          onFocus={() => handlePrefetch(product.id)} // 키보드 접근성
        >
          <ProductCard product={product} />
        </Link>
      ))}
    </div>
  );
}
```

```tsx
// 심화: Viewport 진입 시 자동 프리페치 (목록이 적을 때)
// hooks/usePrefetchOnVisible.ts
'use client';

import { useEffect, useRef } from 'react';
import { preload } from 'swr';

const fetcher = (url: string) => fetch(url).then((r) => r.json());

export function usePrefetchOnVisible(url: string) {
  const ref = useRef<HTMLElement>(null);

  useEffect(() => {
    if (!ref.current) return;

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          preload(url, fetcher);
          observer.disconnect(); // 한 번만 프리페치
        }
      },
      { rootMargin: '100px' }
    );

    observer.observe(ref.current);
    return () => observer.disconnect();
  }, [url]);

  return ref;
}
```

## Why

사용자의 마우스 호버에서 클릭까지 평균 200-300ms의 시간이 존재한다. 이 시간을 활용하여 데이터를 미리 가져오면, 클릭 시 이미 캐시에 데이터가 준비되어 있어 **체감 로딩 시간이 0에 가까워진다**.

프리페치 타이밍별 효과:

| 타이밍 | 프리페치 시간 | 사용자 체감 |
|--------|:-----------:|-----------|
| 클릭 후 | 0ms | 200-800ms 로딩 대기 |
| 호버 시 | 200-300ms 여유 | 대부분 즉시 표시 |
| Viewport 진입 시 | 수 초 여유 | 거의 100% 즉시 표시 |

**정량적 효과:**
- 네비게이션 체감 속도: 클릭 후 fetch 500ms → 호버 프리페치 0ms (2-3x 개선)
- 모바일: touchstart 이벤트로 ~100ms 여유 확보
- SWR 캐시 공유로 동일 데이터 중복 요청 방지

## References

- [SWR: Preloading Data](https://swr.vercel.app/docs/prefetching)
- [Next.js Link Prefetching](https://nextjs.org/docs/app/api-reference/components/link#prefetch)
- [Next.js router.prefetch](https://nextjs.org/docs/app/api-reference/functions/use-router#routerprefetch)
- [Web.dev: Prefetching Resources](https://web.dev/articles/link-prefetch)
