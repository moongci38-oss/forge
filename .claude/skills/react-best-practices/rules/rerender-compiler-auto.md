---
title: "React Compiler 활용 — 수동 memo 최소화"
id: rerender-compiler-auto
impact: MEDIUM
category: rerender-optimization
impactDescription: "자동 memo 최적화 — useMemo/useCallback 보일러플레이트 90% 제거"
tags: [react, nextjs, performance, rerender, react-compiler, react-19]
---

# React Compiler 활용 — 수동 memo 최소화

> React 19+에서 React Compiler는 useMemo, useCallback, memo를 자동으로 삽입한다. 수동 메모이제이션은 edge case에만 사용하고, 나머지는 Compiler에 맡겨 보일러플레이트를 제거한다.

## Incorrect

```tsx
// Before: React 19+ 프로젝트에서 모든 곳에 수동 memo (과도한 보일러플레이트)
function ProductDashboard({ products }: { products: Product[] }) {
  // Compiler가 자동 처리할 수 있는 모든 곳에 수동 memo
  const categories = useMemo(
    () => [...new Set(products.map((p) => p.category))],
    [products],
  );

  const sortedProducts = useMemo(
    () => [...products].sort((a, b) => a.name.localeCompare(b.name)),
    [products],
  );

  const handleSelect = useCallback(
    (id: string) => {
      console.log('Selected:', id);
    },
    [],
  );

  const handleDelete = useCallback(
    (id: string) => {
      console.log('Deleted:', id);
    },
    [],
  );

  const handleEdit = useCallback(
    (id: string, name: string) => {
      console.log('Edited:', id, name);
    },
    [],
  );

  return (
    <div>
      <CategoryFilter categories={categories} />
      <MemoizedProductList
        products={sortedProducts}
        onSelect={handleSelect}
        onDelete={handleDelete}
        onEdit={handleEdit}
      />
    </div>
  );
}

// 모든 컴포넌트에 memo 래핑
const MemoizedProductList = memo(function ProductList({
  products,
  onSelect,
  onDelete,
  onEdit,
}: ProductListProps) {
  return (
    <ul>
      {products.map((p) => (
        <MemoizedProductItem
          key={p.id}
          product={p}
          onSelect={onSelect}
          onDelete={onDelete}
          onEdit={onEdit}
        />
      ))}
    </ul>
  );
});

const MemoizedProductItem = memo(function ProductItem(props: ProductItemProps) {
  return <li>{props.product.name}</li>;
});
```

## Correct

```tsx
// After: React Compiler가 활성화된 프로젝트 — 수동 memo 제거
// next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  experimental: {
    reactCompiler: true, // React Compiler 활성화
  },
};

export default nextConfig;
```

```tsx
// 컴포넌트 — 수동 memo 없이 깔끔한 코드
function ProductDashboard({ products }: { products: Product[] }) {
  // React Compiler가 자동으로 메모이제이션 삽입
  const categories = [...new Set(products.map((p) => p.category))];
  const sortedProducts = [...products].sort((a, b) =>
    a.name.localeCompare(b.name),
  );

  const handleSelect = (id: string) => {
    console.log('Selected:', id);
  };

  const handleDelete = (id: string) => {
    console.log('Deleted:', id);
  };

  const handleEdit = (id: string, name: string) => {
    console.log('Edited:', id, name);
  };

  return (
    <div>
      <CategoryFilter categories={categories} />
      <ProductList
        products={sortedProducts}
        onSelect={handleSelect}
        onDelete={handleDelete}
        onEdit={handleEdit}
      />
    </div>
  );
}

// memo() 래핑 없이 일반 컴포넌트 — Compiler가 필요한 곳에 자동 적용
function ProductList({
  products,
  onSelect,
  onDelete,
  onEdit,
}: ProductListProps) {
  return (
    <ul>
      {products.map((p) => (
        <ProductItem
          key={p.id}
          product={p}
          onSelect={onSelect}
          onDelete={onDelete}
          onEdit={onEdit}
        />
      ))}
    </ul>
  );
}

function ProductItem({ product, onSelect }: ProductItemProps) {
  return (
    <li onClick={() => onSelect(product.id)}>
      {product.name}
    </li>
  );
}
```

```tsx
// Edge case: Compiler가 처리하지 못하는 경우에만 수동 memo 유지
// 예: 외부 라이브러리의 비순수 함수, 동적 의존성
function ChartDashboard({ rawData }: { rawData: DataPoint[] }) {
  // d3 라이브러리 호출 — Compiler가 부수효과를 감지하지 못할 수 있음
  const chartConfig = useMemo(
    () => computeChartLayout(rawData), // 외부 라이브러리의 무거운 계산
    [rawData],
  );

  return <D3Chart config={chartConfig} />;
}
```

## Why

React Compiler(이전 React Forget)는 빌드 타임에 컴포넌트 코드를 분석하여 자동으로 메모이제이션을 삽입한다. 개발자가 수동으로 useMemo/useCallback/memo를 작성할 필요가 없어진다.

Compiler의 작동 방식:
1. **빌드 타임 분석**: 각 컴포넌트의 값과 의존성을 정적 분석
2. **자동 캐싱**: 값이 변하지 않으면 이전 결과를 재사용하는 코드를 자동 삽입
3. **세밀한 최적화**: 개발자보다 정확한 의존성 추적 (누락/과다 의존성 방지)

수동 memo를 제거해야 하는 이유:
- **가독성 향상**: useMemo/useCallback 래핑 없이 자연스러운 JavaScript 코드
- **유지보수 용이**: 의존성 배열 관리 부담 제거
- **실수 방지**: 잘못된 의존성 배열로 인한 stale closure 버그 제거

**정량적 효과:**
- useMemo/useCallback 보일러플레이트 90% 제거 — 코드량 감소
- 의존성 배열 관련 버그 발생률 0% (Compiler가 정확히 추적)
- 성능은 수동 memo와 동등하거나 더 나음 (Compiler가 더 세밀한 캐싱 적용)

**주의:** Compiler 미적용 프로젝트(React 18 이하)에서는 수동 memo가 여전히 필요하다.

## References

- [React Compiler 공식 문서](https://react.dev/learn/react-compiler)
- [Next.js — React Compiler](https://nextjs.org/docs/app/api-reference/config/next-config-js/reactCompiler)
- [React 19 Release](https://react.dev/blog/2024/12/05/react-19)
