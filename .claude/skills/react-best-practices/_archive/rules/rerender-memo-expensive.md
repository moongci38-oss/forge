---
title: "비용 높은 계산은 useMemo로 캐싱"
id: rerender-memo-expensive
impact: MEDIUM
category: rerender-optimization
impactDescription: "무거운 계산 반복 방지 — CPU 사용 60-90% 감소"
tags: [react, nextjs, performance, rerender, useMemo]
---

# 비용 높은 계산은 useMemo로 캐싱

> 매 렌더마다 대규모 배열 필터링, 정렬, 집계를 반복하면 메인 스레드가 블로킹된다. useMemo로 의존성이 변하지 않으면 이전 결과를 재사용한다.

## Incorrect

```tsx
// Before: 매 렌더마다 10,000개 상품을 필터링 + 정렬
interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
  rating: number;
  inStock: boolean;
}

function ProductCatalog({
  products,
  searchQuery,
  selectedCategory,
  sortBy,
}: {
  products: Product[];
  searchQuery: string;
  selectedCategory: string;
  sortBy: 'price' | 'rating' | 'name';
}) {
  // 매 렌더마다 실행 — 부모가 리렌더되면 products가 동일해도 재계산
  const filtered = products
    .filter((p) => p.inStock)
    .filter((p) => selectedCategory === 'all' || p.category === selectedCategory)
    .filter((p) => p.name.toLowerCase().includes(searchQuery.toLowerCase()));

  // 매 렌더마다 O(n log n) 정렬 실행
  const sorted = [...filtered].sort((a, b) => {
    if (sortBy === 'price') return a.price - b.price;
    if (sortBy === 'rating') return b.rating - a.rating;
    return a.name.localeCompare(b.name);
  });

  // 매 렌더마다 집계 계산
  const stats = {
    total: sorted.length,
    avgPrice: sorted.reduce((sum, p) => sum + p.price, 0) / sorted.length,
    avgRating: sorted.reduce((sum, p) => sum + p.rating, 0) / sorted.length,
  };

  return (
    <div>
      <CatalogStats stats={stats} />
      <ProductList products={sorted} />
    </div>
  );
}
```

## Correct

```tsx
// After: useMemo로 의존성 변경 시에만 재계산
function ProductCatalog({
  products,
  searchQuery,
  selectedCategory,
  sortBy,
}: {
  products: Product[];
  searchQuery: string;
  selectedCategory: string;
  sortBy: 'price' | 'rating' | 'name';
}) {
  // 필터링 — products, searchQuery, selectedCategory가 변할 때만 실행
  const filtered = useMemo(
    () =>
      products
        .filter((p) => p.inStock)
        .filter(
          (p) => selectedCategory === 'all' || p.category === selectedCategory,
        )
        .filter((p) =>
          p.name.toLowerCase().includes(searchQuery.toLowerCase()),
        ),
    [products, searchQuery, selectedCategory],
  );

  // 정렬 — filtered 또는 sortBy가 변할 때만 실행
  const sorted = useMemo(() => {
    const copy = [...filtered];
    copy.sort((a, b) => {
      if (sortBy === 'price') return a.price - b.price;
      if (sortBy === 'rating') return b.rating - a.rating;
      return a.name.localeCompare(b.name);
    });
    return copy;
  }, [filtered, sortBy]);

  // 통계 — sorted가 변할 때만 실행
  const stats = useMemo(() => {
    if (sorted.length === 0) return { total: 0, avgPrice: 0, avgRating: 0 };
    return {
      total: sorted.length,
      avgPrice: sorted.reduce((sum, p) => sum + p.price, 0) / sorted.length,
      avgRating: sorted.reduce((sum, p) => sum + p.rating, 0) / sorted.length,
    };
  }, [sorted]);

  return (
    <div>
      <CatalogStats stats={stats} />
      <ProductList products={sorted} />
    </div>
  );
}
```

## Why

React 컴포넌트는 부모가 리렌더될 때마다 함수 본문 전체가 재실행된다. 10,000개 배열의 filter + sort는 O(n) + O(n log n) 연산이며, 키보드 입력, 스크롤 등 빈번한 업데이트에서 이것이 매번 실행되면 프레임 드롭이 발생한다.

`useMemo`는 의존성 배열의 값이 이전 렌더와 동일하면 캐시된 결과를 반환한다. 필터 → 정렬 → 집계를 체인으로 연결하면, 예를 들어 `sortBy`만 변경 시 필터링은 건너뛰고 정렬부터 실행된다.

**정량적 효과:**
- 10,000개 배열 filter + sort: 렌더당 ~15ms → useMemo 캐시 히트 시 ~0.01ms (99% 감소)
- 타이핑 중 searchQuery 변경: filter만 재실행 (sort 의존성 불변이면 sort 캐시 히트)
- React Profiler "Render duration" 기준 CPU 사용 60-90% 감소
- 16ms 프레임 예산 내 안정적 유지

**주의:** 단순 계산(배열 길이, 문자열 조합 등)에는 useMemo 불필요 — 메모이제이션 오버헤드가 더 클 수 있다.

## References

- [React 공식 문서 — useMemo](https://react.dev/reference/react/useMemo)
- [React 공식 문서 — You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
- [When to useMemo and useCallback](https://kentcdodds.com/blog/usememo-and-usecallback)
