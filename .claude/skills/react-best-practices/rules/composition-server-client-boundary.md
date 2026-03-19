---
title: "'use client'는 인터랙션 필요한 최소 범위에만 — 페이지 전체 client 금지"
id: composition-server-client-boundary
impact: HIGH
category: composition-patterns
impactDescription: "서버 컴포넌트 비율 최대화 — JS 번들 40-70% 감소"
tags: [react, nextjs, performance, server-components, client-boundary, architecture]
---

# 'use client'는 인터랙션 필요한 최소 범위에만 — 페이지 전체 client 금지

> 'use client' 지시어는 인터랙션이 필요한 최소 리프 컴포넌트에만 적용한다. 페이지나 레이아웃 레벨에 선언하면 하위 모든 컴포넌트가 클라이언트 번들에 포함된다.

## Incorrect

```tsx
// Before: 페이지 전체를 'use client'로 선언 — 모든 하위 컴포넌트가 JS 번들에 포함
// app/products/page.tsx
'use client'; // 페이지 레벨 — 하위 전체가 클라이언트 번들

import { useState } from 'react';
import { ProductList } from '@/components/ProductList';
import { ProductFilter } from '@/components/ProductFilter';
import { ProductDescription } from '@/components/ProductDescription';
import { RelatedProducts } from '@/components/RelatedProducts';
import { ReviewSection } from '@/components/ReviewSection';
import { Footer } from '@/components/Footer';

export default function ProductPage() {
  const [filter, setFilter] = useState('all');
  // 'use client'가 페이지 레벨이므로:
  // - ProductDescription (순수 텍스트, 상호작용 없음) → 불필요하게 클라이언트 번들에 포함
  // - RelatedProducts (서버에서 데이터 fetch 가능) → 클라이언트에서 fetch 강제
  // - ReviewSection (정적 리뷰 목록) → 불필요하게 클라이언트 번들에 포함
  // - Footer (완전 정적) → 불필요하게 클라이언트 번들에 포함

  return (
    <div>
      <ProductFilter filter={filter} onFilterChange={setFilter} />
      <ProductList filter={filter} />
      <ProductDescription />    {/* 상호작용 없음 — Server Component면 충분 */}
      <RelatedProducts />        {/* 서버 데이터 — Server Component 적합 */}
      <ReviewSection />          {/* 대부분 정적 — 좋아요 버튼만 인터랙티브 */}
      <Footer />                 {/* 완전 정적 — Server Component 적합 */}
    </div>
  );
}
```

## Correct

```tsx
// After: 페이지는 Server Component — 인터랙티브 부분만 'use client'
// app/products/page.tsx (Server Component — 'use client' 없음)

import { Suspense } from 'react';
import { ProductFilterSection } from '@/components/ProductFilterSection';
import { ProductDescription } from '@/components/ProductDescription';
import { RelatedProducts } from '@/components/RelatedProducts';
import { ReviewSection } from '@/components/ReviewSection';
import { Footer } from '@/components/Footer';
import { getProduct } from '@/lib/data';

export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  // 서버에서 직접 데이터 fetch — API 호출 없이 DB 접근 가능
  const product = await getProduct(id);

  return (
    <div>
      {/* 인터랙티브 부분만 클라이언트 컴포넌트로 분리 */}
      <ProductFilterSection productId={id} />

      {/* 순수 렌더링 — Server Component (JS 번들 0) */}
      <ProductDescription description={product.description} />

      {/* 서버 데이터 fetch — Server Component */}
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedProducts categoryId={product.categoryId} />
      </Suspense>

      {/* 정적 리뷰 목록 + 인터랙티브 좋아요 버튼 분리 */}
      <Suspense fallback={<ReviewSkeleton />}>
        <ReviewSection productId={id} />
      </Suspense>

      <Footer />
    </div>
  );
}
```

```tsx
// 인터랙티브 최소 범위만 'use client'
// components/ProductFilterSection.tsx
'use client';

import { useState } from 'react';
import { ProductList } from './ProductList';

// 필터 상태를 관리하는 최소 범위만 클라이언트
export function ProductFilterSection({ productId }: { productId: string }) {
  const [filter, setFilter] = useState('all');

  return (
    <div>
      <select value={filter} onChange={(e) => setFilter(e.target.value)}>
        <option value="all">전체</option>
        <option value="new">신상품</option>
        <option value="sale">할인</option>
      </select>
      <ProductList productId={productId} filter={filter} />
    </div>
  );
}
```

```tsx
// 리뷰 섹션: 서버에서 렌더링 + 좋아요 버튼만 클라이언트
// components/ReviewSection.tsx (Server Component)
import { getReviews } from '@/lib/data';
import { LikeButton } from './LikeButton';

export async function ReviewSection({ productId }: { productId: string }) {
  const reviews = await getReviews(productId);

  return (
    <section>
      <h2>리뷰 ({reviews.length})</h2>
      {reviews.map((review) => (
        <div key={review.id}>
          {/* 정적 콘텐츠 — Server Component에서 렌더링 */}
          <p>{review.content}</p>
          <span>{review.author}</span>
          <time>{review.createdAt}</time>

          {/* 인터랙티브 부분만 Client Component */}
          <LikeButton reviewId={review.id} initialCount={review.likes} />
        </div>
      ))}
    </section>
  );
}

// components/LikeButton.tsx
'use client';
import { useState } from 'react';

// 최소 리프 컴포넌트에만 'use client'
export function LikeButton({
  reviewId,
  initialCount,
}: {
  reviewId: string;
  initialCount: number;
}) {
  const [count, setCount] = useState(initialCount);
  const [liked, setLiked] = useState(false);

  return (
    <button
      onClick={() => {
        setLiked(!liked);
        setCount((c) => (liked ? c - 1 : c + 1));
      }}
    >
      {liked ? '♥' : '♡'} {count}
    </button>
  );
}
```

## Why

Next.js App Router에서 모든 컴포넌트는 기본적으로 Server Component이다. `'use client'`를 선언하면 해당 컴포넌트와 그 하위 임포트 트리 전체가 클라이언트 JavaScript 번들에 포함된다. 페이지 레벨에 `'use client'`를 선언하면 정적 텍스트, 이미지, 데이터 표시 등 상호작용이 필요 없는 컴포넌트까지 JS 번들에 포함되어 불필요한 번들 크기 증가를 초래한다.

**정량적 효과:**
- JS 번들: 페이지 전체 client → 리프만 client로 40-70% 감소
- 서버 데이터 접근: Server Component에서 직접 DB 접근 가능 — API 레이어 불필요
- TTFB: Server Component는 서버에서 렌더링되어 즉시 HTML 전달
- Hydration 비용: 클라이언트 컴포넌트 수에 비례 — 최소화할수록 빠른 인터랙션

**경계 설계 원칙:** `'use client'`는 "클라이언트 경계"를 선언한다. 경계를 최대한 아래(리프)로 내리면 서버 컴포넌트 비율이 최대화된다.

## References

- [Next.js: Server and Client Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [React: Server Components](https://react.dev/reference/rsc/server-components)
- [Next.js: Client Components](https://nextjs.org/docs/app/building-your-application/rendering/client-components)
