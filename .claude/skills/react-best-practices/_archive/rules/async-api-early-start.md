---
title: "API 호출은 라우트 레벨에서 시작"
id: async-api-early-start
impact: CRITICAL
category: eliminating-waterfalls
impactDescription: "네트워크 워터폴 제거, TTFB 30-50% 개선"
tags: [react, nextjs, performance, data-fetching, server-components]
---

# API 호출은 라우트 레벨에서 시작

> 깊이 중첩된 컴포넌트에서 fetch를 시작하면 부모 컴포넌트 렌더링 완료 후에야 fetch가 시작된다. 라우트 최상위(page.tsx/layout.tsx)에서 시작한다.

## Incorrect

```tsx
// Before: 중첩 컴포넌트에서 fetch — 부모 렌더 후에야 시작됨
// app/products/[id]/page.tsx

async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  return (
    <div>
      <Header />
      <ProductLayout>
        {/* ProductDetail 컴포넌트가 렌더링될 때 비로소 fetch 시작 */}
        <ProductDetail productId={id} />
        <ReviewSection productId={id} />
      </ProductLayout>
      <Footer />
    </div>
  );
}

// app/products/[id]/_components/ProductDetail.tsx
async function ProductDetail({ productId }: { productId: string }) {
  // Header, ProductLayout 렌더 완료 후에야 이 fetch가 시작됨
  const product = await fetchProduct(productId);

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      {/* PriceDisplay가 렌더링될 때 비로소 pricing fetch 시작 — 2단 워터폴 */}
      <PriceDisplay productId={productId} />
    </div>
  );
}

// app/products/[id]/_components/PriceDisplay.tsx
async function PriceDisplay({ productId }: { productId: string }) {
  // ProductDetail 렌더 완료 후에야 시작됨 — 3단 워터폴
  const pricing = await fetchPricing(productId);
  return <span>{pricing.formattedPrice}</span>;
}
```

## Correct

```tsx
// After: 라우트 레벨에서 모든 데이터를 fetch하고 props로 전달
// app/products/[id]/page.tsx

import { Suspense } from 'react';
import { ProductSkeleton, ReviewSkeleton } from '@/components/skeletons';

async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // 라우트 레벨에서 즉시 병렬 fetch 시작
  const [product, pricing] = await Promise.all([
    fetchProduct(id),
    fetchPricing(id),
  ]);

  return (
    <div>
      <Header />
      <ProductLayout>
        {/* 이미 로드된 데이터를 props로 전달 — fetch 워터폴 없음 */}
        <ProductDetail product={product} pricing={pricing} />
        {/* 리뷰는 느릴 수 있으므로 Suspense로 스트리밍 */}
        <Suspense fallback={<ReviewSkeleton />}>
          <ReviewSection productId={id} />
        </Suspense>
      </ProductLayout>
      <Footer />
    </div>
  );
}

// 컴포넌트는 순수 프레젠테이션 — fetch 없음
function ProductDetail({
  product,
  pricing,
}: {
  product: Product;
  pricing: Pricing;
}) {
  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <span>{pricing.formattedPrice}</span>
    </div>
  );
}
```

```tsx
// Alternative: React cache()로 중복 제거 — 여러 컴포넌트가 같은 데이터 필요 시
// lib/data.ts
import { cache } from 'react';

export const getProduct = cache(async (id: string): Promise<Product> => {
  const res = await fetch(`/api/products/${id}`);
  return res.json();
});

// page.tsx에서 호출해도, 하위 컴포넌트에서 호출해도 1번만 fetch
// 하지만 가능하면 page.tsx에서 시작하는 것이 의도가 명확함
```

## Why

React Server Components는 위에서 아래로 순차 렌더링된다. 중첩 컴포넌트에서 fetch를 시작하면 **부모 → 자식 → 손자** 순서로 워터폴이 생긴다. 각 단계에서 부모 렌더 시간 + 네트워크 대기 시간이 누적된다.

라우트 레벨에서 모든 데이터를 시작하면:
1. URL 매칭 즉시 모든 fetch가 병렬 시작
2. 컴포넌트 렌더 시간이 fetch 대기에 영향을 미치지 않음
3. 데이터 흐름이 명확해짐 (어디서 fetch하는지 한눈에 파악)

**정량적 효과:**
- 3단 워터폴(부모 렌더 50ms + fetch 200ms x 3단): 750ms → 병렬 200ms = **73% 단축**
- TTFB(Time to First Byte): 서버에서 첫 HTML 바이트까지의 시간 30-50% 개선
- 브라우저 DevTools Network 탭에서 워터폴 차트로 시각적 확인 가능

## References

- [Next.js Data Fetching Patterns](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching)
- [React Server Components](https://react.dev/reference/rsc/server-components)
- [Next.js Caching and Revalidating](https://nextjs.org/docs/app/building-your-application/caching)
