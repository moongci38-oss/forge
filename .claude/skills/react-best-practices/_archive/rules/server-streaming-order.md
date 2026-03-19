---
title: "Streaming 순서 최적화 — 중요 콘텐츠 우선 스트리밍"
id: server-streaming-order
impact: HIGH
category: server-side-performance
impactDescription: "체감 로딩 시간 40-60% 단축 — 중요 콘텐츠 먼저 표시"
tags: [react, nextjs, streaming, suspense, performance]
---

# Streaming 순서 최적화 — 중요 콘텐츠 우선 스트리밍

> 단일 Suspense 경계로 전체 페이지를 감싸면 가장 느린 데이터가 모든 UI를 블로킹한다. 중요도에 따라 Suspense 경계를 중첩 분리하여 핵심 콘텐츠부터 스트리밍해야 한다.

## Incorrect

```tsx
// Before: 단일 Suspense 경계 — 모든 데이터가 준비될 때까지 전체 스켈레톤 표시
// app/product/[id]/page.tsx

import { Suspense } from 'react';
import { FullPageSkeleton } from '@/components/skeletons';

export default function ProductPage({ params }: { params: { id: string } }) {
  return (
    // 하나의 Suspense가 모든 비동기 컴포넌트를 감쌈
    // 추천 상품(3초)이 완료될 때까지 상품명(50ms)도 안 보임
    <Suspense fallback={<FullPageSkeleton />}>
      <ProductContent productId={params.id} />
    </Suspense>
  );
}

async function ProductContent({ productId }: { productId: string }) {
  // 모든 데이터를 순차/병렬로 가져온 후 한꺼번에 렌더링
  const product = await fetchProduct(productId);          // 50ms
  const reviews = await fetchReviews(productId);          // 800ms
  const recommendations = await fetchRecommendations(productId); // 3000ms

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.price}</p>
      <ReviewList reviews={reviews} />
      <RecommendationGrid items={recommendations} />
    </div>
  );
}
```

## Correct

```tsx
// After: 중요도별 중첩 Suspense 경계 — 핵심 콘텐츠부터 순차 스트리밍
// app/product/[id]/page.tsx

import { Suspense } from 'react';
import {
  ProductSkeleton,
  ReviewsSkeleton,
  RecommendationsSkeleton,
} from '@/components/skeletons';

export default async function ProductPage({
  params,
}: {
  params: { id: string };
}) {
  // 핵심 데이터: 가장 빨리 로드 — Suspense 밖에서 await
  const product = await fetchProduct(params.id); // 50ms

  return (
    <div>
      {/* 1단계: 핵심 콘텐츠 즉시 표시 (50ms) */}
      <h1>{product.name}</h1>
      <p className="text-2xl font-bold">{product.price}</p>
      <ProductImageGallery images={product.images} />

      {/* 2단계: 중요하지만 느린 데이터 — 독립 스트리밍 (800ms) */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ReviewSection productId={params.id} />
      </Suspense>

      {/* 3단계: 부가 정보 — 가장 느린 데이터 (3000ms) */}
      <Suspense fallback={<RecommendationsSkeleton />}>
        <RecommendationSection productId={params.id} />
      </Suspense>
    </div>
  );
}

// 각 섹션이 독립적으로 데이터를 fetch하고 스트리밍
async function ReviewSection({ productId }: { productId: string }) {
  const reviews = await fetchReviews(productId); // 800ms
  return <ReviewList reviews={reviews} />;
}

async function RecommendationSection({ productId }: { productId: string }) {
  const recommendations = await fetchRecommendations(productId); // 3000ms
  return <RecommendationGrid items={recommendations} />;
}
```

```tsx
// 심화: loading.tsx + 페이지 레벨 Suspense 조합
// app/product/[id]/loading.tsx
// → 라우트 전환 시 즉시 표시되는 스켈레톤
export default function Loading() {
  return <ProductSkeleton />;
}

// app/product/[id]/layout.tsx
// → 레이아웃 영역은 Suspense 밖 — 네비게이션 즉시 표시
export default function ProductLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div>
      <Breadcrumb /> {/* 즉시 렌더링 */}
      {children}     {/* loading.tsx → page.tsx 순서로 스트리밍 */}
    </div>
  );
}
```

## Why

Suspense 경계는 "이 영역의 데이터가 준비될 때까지 fallback을 보여줘"라는 의미다. 하나의 Suspense로 전체 페이지를 감싸면, **가장 느린 데이터 소스가 모든 콘텐츠의 표시를 블로킹**한다. 50ms만에 준비되는 상품명도 3초짜리 추천 상품 때문에 함께 대기하게 된다.

중요도별로 Suspense 경계를 분리하면:
1. 핵심 콘텐츠(상품명, 가격)는 즉시 표시
2. 중요 부가 정보(리뷰)는 준비되는 대로 스트리밍
3. 비핵심 정보(추천)는 마지막에 교체

**정량적 효과:**
- 체감 First Contentful Paint: 3000ms → 50ms (상품 기본 정보)
- 체감 로딩 시간 40-60% 단축 (사용자가 핵심 정보를 먼저 소비)
- LCP(Largest Contentful Paint) 직접 개선 — 메인 콘텐츠 우선 표시

## References

- [Next.js Streaming with Suspense](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming#streaming-with-suspense)
- [React Suspense](https://react.dev/reference/react/Suspense)
- [Patterns: Sequential vs Parallel Data Fetching](https://nextjs.org/docs/app/building-your-application/data-fetching/fetching#sequential-data-fetching)
