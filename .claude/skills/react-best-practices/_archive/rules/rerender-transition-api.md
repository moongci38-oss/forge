---
title: "비긴급 업데이트는 useTransition/useDeferredValue"
id: rerender-transition-api
impact: MEDIUM
category: rerender-optimization
impactDescription: "긴급 업데이트(입력) 블로킹 방지 — 검색 필터 등 체감 반응성 2-5x"
tags: [react, nextjs, performance, rerender, concurrent, useTransition]
---

# 비긴급 업데이트는 useTransition/useDeferredValue

> 검색어 입력 시 필터링 결과를 동기적으로 업데이트하면, 무거운 렌더링이 입력 반응성을 블로킹한다. useTransition으로 비긴급 업데이트를 분리하면 입력은 즉시 반응한다.

## Incorrect

```tsx
// Before: 검색어 변경과 리스트 필터링이 동기적 — 입력 블로킹
function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('');

  // 10,000개 상품 필터링 + 각 아이템 렌더링이 동기적으로 실행
  // 타이핑할 때마다 필터링 완료까지 input이 멈춤
  const filteredProducts = products.filter((p) =>
    p.name.toLowerCase().includes(query.toLowerCase()) ||
    p.description.toLowerCase().includes(query.toLowerCase()),
  );

  return (
    <div>
      {/* 입력할 때마다 filteredProducts 계산 + 리스트 렌더링 완료까지 블로킹 */}
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="상품 검색..."
      />
      {/* 10,000개 중 일부가 매 키 입력마다 동기적으로 렌더 */}
      <div className="product-grid">
        {filteredProducts.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
}
```

## Correct

```tsx
// After: useTransition으로 필터링을 비긴급 업데이트로 분리
function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('');
  const [filteredQuery, setFilteredQuery] = useState('');
  const [isPending, startTransition] = useTransition();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;

    // 긴급: input value 즉시 업데이트 — 타이핑 반응 즉시
    setQuery(value);

    // 비긴급: 필터링은 브라우저가 여유 있을 때 처리
    startTransition(() => {
      setFilteredQuery(value);
    });
  };

  const filteredProducts = useMemo(
    () =>
      products.filter(
        (p) =>
          p.name.toLowerCase().includes(filteredQuery.toLowerCase()) ||
          p.description.toLowerCase().includes(filteredQuery.toLowerCase()),
      ),
    [products, filteredQuery],
  );

  return (
    <div>
      {/* input은 항상 즉시 반응 */}
      <input
        value={query}
        onChange={handleChange}
        placeholder="상품 검색..."
      />
      {/* 필터링 중 시각적 피드백 */}
      <div className={`product-grid ${isPending ? 'opacity-60' : ''}`}>
        {filteredProducts.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
}
```

```tsx
// Alternative: useDeferredValue — 더 간결한 패턴
function ProductSearch({ products }: { products: Product[] }) {
  const [query, setQuery] = useState('');
  // query의 "지연된 버전" — React가 긴급 업데이트 후 여유 시 업데이트
  const deferredQuery = useDeferredValue(query);
  const isStale = query !== deferredQuery;

  const filteredProducts = useMemo(
    () =>
      products.filter(
        (p) =>
          p.name.toLowerCase().includes(deferredQuery.toLowerCase()) ||
          p.description.toLowerCase().includes(deferredQuery.toLowerCase()),
      ),
    [products, deferredQuery],
  );

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="상품 검색..."
      />
      <div className={`product-grid ${isStale ? 'opacity-60' : ''}`}>
        {filteredProducts.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
}
```

## Why

React 18+의 Concurrent Features는 업데이트를 **긴급(urgent)**과 **비긴급(non-urgent)**으로 분류한다.

- **긴급**: 사용자 입력(타이핑, 클릭) — 즉시 반영되어야 함
- **비긴급**: 입력에 따른 결과 업데이트(필터링, 검색 결과) — 약간 늦어도 됨

`useTransition`은 비긴급 업데이트를 **인터럽트 가능**하게 만든다. 새 키 입력이 들어오면 진행 중인 비긴급 렌더를 중단하고 새 긴급 업데이트를 먼저 처리한다.

`useDeferredValue`는 값의 "지연된 버전"을 제공한다. 내부적으로 같은 메커니즘이지만, 값을 prop으로 받아서 직접 state를 제어할 수 없을 때 유용하다.

**정량적 효과:**
- 10,000개 리스트 필터링: 동기 → 키 입력 100-300ms 블로킹 / Transition → 키 입력 즉시 반응 (16ms 이내)
- 체감 반응성 2-5x 개선 (입력 딜레이 체감 제거)
- `isPending` / `isStale`로 사용자에게 "업데이트 중" 피드백 제공 가능

## References

- [React 공식 문서 — useTransition](https://react.dev/reference/react/useTransition)
- [React 공식 문서 — useDeferredValue](https://react.dev/reference/react/useDeferredValue)
- [React 공식 문서 — Updating state in a transition](https://react.dev/reference/react/useTransition#updating-the-parent-component-in-a-transition)
