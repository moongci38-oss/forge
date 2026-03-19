---
title: "로딩 상태에 Skeleton UI 사용 — spinner 최소화"
id: rendering-skeleton-ui
impact: MEDIUM
category: rendering-performance
impactDescription: "체감 로딩 시간 40% 단축 — 레이아웃 시프트 방지"
tags: [react, nextjs, performance, skeleton, loading, ux]
---

# 로딩 상태에 Skeleton UI 사용 — spinner 최소화

> 로딩 중 빈 화면이나 스피너를 보여주면 사용자가 대기 시간을 길게 체감한다. Skeleton UI는 콘텐츠의 레이아웃을 미리 보여주어 체감 로딩 시간을 단축하고 CLS(레이아웃 시프트)를 방지한다.

## Incorrect

```tsx
// Before: 전체 페이지에 스피너 하나 — 콘텐츠 구조 힌트 없음
// app/products/page.tsx
import { Suspense } from 'react';

function ProductsPage() {
  return (
    <Suspense
      fallback={
        // 전체 페이지가 스피너 하나로 대체 — 사용자가 어떤 콘텐츠가 올지 모름
        <div className="flex items-center justify-center h-screen">
          <div className="animate-spin h-10 w-10 border-4 border-blue-500 rounded-full border-t-transparent" />
        </div>
      }
    >
      <ProductList />
    </Suspense>
  );
}

// 또는: 로딩 중 아무것도 안 보여줌 — 콘텐츠 도착 시 큰 CLS 발생
function ProductCard({ product }: { product: Product }) {
  const [imageLoaded, setImageLoaded] = useState(false);

  return (
    <div>
      {/* 이미지 로드 전 높이 0 → 로드 후 높이 확보 → CLS */}
      {imageLoaded ? (
        <img src={product.imageUrl} alt={product.name} />
      ) : null}
      <h3>{product.name}</h3>
    </div>
  );
}
```

## Correct

```tsx
// After: 콘텐츠 레이아웃을 반영한 Skeleton UI
// app/products/loading.tsx — Next.js App Router가 자동으로 Suspense fallback으로 사용
export default function ProductsLoading() {
  return (
    <div className="container mx-auto px-4 py-8">
      {/* 헤더 스켈레톤 — 실제 헤더와 동일한 구조 */}
      <div className="mb-8">
        <div className="h-8 w-48 bg-gray-200 rounded animate-pulse" />
        <div className="h-4 w-96 bg-gray-200 rounded animate-pulse mt-2" />
      </div>

      {/* 필터바 스켈레톤 */}
      <div className="flex gap-3 mb-6">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="h-10 w-24 bg-gray-200 rounded-full animate-pulse" />
        ))}
      </div>

      {/* 상품 그리드 스켈레톤 — 실제 그리드와 동일한 레이아웃 */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {Array.from({ length: 12 }).map((_, i) => (
          <ProductCardSkeleton key={i} />
        ))}
      </div>
    </div>
  );
}

function ProductCardSkeleton() {
  return (
    <div className="rounded-lg border overflow-hidden">
      {/* 이미지 영역 — aspect-ratio로 높이 예약 */}
      <div className="aspect-square bg-gray-200 animate-pulse" />
      <div className="p-4">
        {/* 상품명 */}
        <div className="h-5 w-3/4 bg-gray-200 rounded animate-pulse" />
        {/* 가격 */}
        <div className="h-4 w-1/2 bg-gray-200 rounded animate-pulse mt-2" />
        {/* 별점 */}
        <div className="h-4 w-1/3 bg-gray-200 rounded animate-pulse mt-2" />
      </div>
    </div>
  );
}
```

```tsx
// 세분화된 Suspense 경계 — 부분별 독립 로딩
// app/products/[id]/page.tsx
import { Suspense } from 'react';

async function ProductDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  return (
    <div className="container mx-auto px-4 py-8">
      {/* 상품 정보 — 빠르게 로드 (캐시) */}
      <Suspense fallback={<ProductInfoSkeleton />}>
        <ProductInfo productId={id} />
      </Suspense>

      {/* 리뷰 — 느릴 수 있음 (DB 조회) */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ReviewSection productId={id} />
      </Suspense>

      {/* 추천 상품 — 가장 느림 (ML 모델 추론) */}
      <Suspense fallback={<RecommendationsSkeleton />}>
        <Recommendations productId={id} />
      </Suspense>
    </div>
  );
}

function ReviewsSkeleton() {
  return (
    <div className="mt-8">
      <div className="h-7 w-32 bg-gray-200 rounded animate-pulse mb-4" />
      {Array.from({ length: 3 }).map((_, i) => (
        <div key={i} className="mb-4 p-4 border rounded-lg">
          <div className="flex items-center gap-3 mb-2">
            <div className="h-10 w-10 bg-gray-200 rounded-full animate-pulse" />
            <div className="h-4 w-24 bg-gray-200 rounded animate-pulse" />
          </div>
          <div className="h-4 w-full bg-gray-200 rounded animate-pulse" />
          <div className="h-4 w-3/4 bg-gray-200 rounded animate-pulse mt-1" />
        </div>
      ))}
    </div>
  );
}
```

## Why

UX 연구에 따르면 사용자는 "진행 중"이라는 시각적 피드백이 있을 때 대기 시간을 더 짧게 체감한다. Skeleton UI는 단순 스피너보다 효과적인 이유:

1. **콘텐츠 예측**: 어떤 유형의 콘텐츠가 로드될지 미리 보여줌
2. **진행감**: 위에서 아래로 콘텐츠가 채워지는 느낌
3. **CLS 방지**: 콘텐츠와 동일한 레이아웃으로 공간을 미리 확보
4. **부분 로딩**: Suspense와 결합하여 빠른 영역 먼저 표시

Next.js App Router에서의 활용:
- `loading.tsx`: 해당 라우트의 자동 Suspense fallback
- 세분화된 `<Suspense>`: 페이지 내 영역별 독립 로딩

**정량적 효과:**
- 체감 로딩 시간: 스피너 대비 40% 단축 (Google UX 연구)
- CLS 스코어: 스켈레톤이 공간을 예약하여 0에 가까움
- 이탈률: 로딩 UX 개선으로 5-15% 감소 (업계 벤치마크)
- FCP(First Contentful Paint): 스켈레톤이 즉시 렌더되어 FCP 개선

## References

- [Next.js Loading UI and Streaming](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
- [React 공식 문서 — Suspense](https://react.dev/reference/react/Suspense)
- [Web.dev — Optimize Largest Contentful Paint](https://web.dev/articles/optimize-lcp)
