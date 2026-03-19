---
title: "적절한 배열 메서드 선택 — find vs filter vs some"
id: js-array-methods
impact: LOW
category: javascript-performance
impactDescription: "불필요한 배열 순회 방지 — early return으로 성능 향상"
tags: [react, javascript, performance, array, iteration]
---

# 적절한 배열 메서드 선택 — find vs filter vs some

> 배열 작업 시 목적에 맞는 메서드를 선택하여 불필요한 전체 순회를 방지한다. 단일 검색은 find, 존재 여부는 some, 다수 필터는 filter.

## Incorrect

```tsx
// Before: 목적에 맞지 않는 배열 메서드 사용 — 불필요한 전체 순회
'use client';

interface Product {
  id: string;
  name: string;
  category: string;
  price: number;
  inStock: boolean;
}

function ProductPage({ products }: { products: Product[] }) {
  // 단일 제품 검색인데 filter 사용 — 10,000개 전부 순회
  const targetProduct = products.filter((p) => p.id === 'prod-123')[0];

  // 존재 여부 확인인데 filter 사용 — 전체 순회 후 길이 확인
  const hasOutOfStock = products.filter((p) => !p.inStock).length > 0;

  // 특정 카테고리 존재 여부인데 findIndex 사용
  const hasPremium = products.findIndex((p) => p.category === 'premium') !== -1;

  // 조건 충족 여부 확인인데 reduce 사용 — 과도한 코드
  const allInStock = products.reduce(
    (acc, p) => acc && p.inStock,
    true
  );

  // 중복 체이닝 — 동일 배열 3번 순회
  const expensiveItems = products
    .filter((p) => p.price > 100000)        // 1차 순회: 10,000개
    .filter((p) => p.inStock)               // 2차 순회: 결과 배열
    .filter((p) => p.category === 'premium'); // 3차 순회: 결과 배열

  return <div>{/* 렌더링 */}</div>;
}
```

## Correct

```tsx
// After: 목적에 맞는 배열 메서드 — early return 활용
'use client';

import { useMemo } from 'react';

function ProductPage({ products }: { products: Product[] }) {
  // 단일 검색: find — 찾으면 즉시 반환 (평균 N/2 순회)
  const targetProduct = products.find((p) => p.id === 'prod-123');

  // 존재 여부: some — 하나라도 충족하면 즉시 true 반환
  const hasOutOfStock = products.some((p) => !p.inStock);

  // 존재 여부: some (findIndex보다 의미 명확)
  const hasPremium = products.some((p) => p.category === 'premium');

  // 전체 조건 충족: every — 하나라도 실패하면 즉시 false 반환
  const allInStock = products.every((p) => p.inStock);

  // 조건 결합: 한 번의 순회로 다중 조건 필터
  const expensiveItems = useMemo(
    () =>
      products.filter(
        (p) => p.price > 100000 && p.inStock && p.category === 'premium'
      ),
    [products]
  );

  return <div>{/* 렌더링 */}</div>;
}
```

```tsx
// 배열 메서드 선택 가이드 — 실전 패턴
'use client';

import { useMemo } from 'react';

function useProductFilters(products: Product[], filters: FilterState) {
  return useMemo(() => {
    // 1. 단일 요소 검색 → find (O(N) worst, O(N/2) avg)
    const featured = products.find((p) => p.featured);

    // 2. 존재 여부 확인 → some / every (early return)
    const hasDiscount = products.some((p) => p.discountRate > 0);
    const allVerified = products.every((p) => p.verified);

    // 3. 변환 + 필터 → reduce로 한 번에 (map + filter 체이닝 대체)
    const { items, totalPrice } = products.reduce(
      (acc, product) => {
        if (matchesFilters(product, filters)) {
          acc.items.push({
            ...product,
            displayPrice: formatPrice(product.price),
          });
          acc.totalPrice += product.price;
        }
        return acc;
      },
      { items: [] as DisplayProduct[], totalPrice: 0 }
    );

    // 4. 인덱스 기반 접근 → at() (음수 인덱스 지원)
    const lastProduct = products.at(-1);
    const secondLast = products.at(-2);

    // 5. 고유값 추출 → Set
    const categories = [...new Set(products.map((p) => p.category))];

    // 6. 그룹핑 → Object.groupBy (ES2024)
    const byCategory = Object.groupBy(products, (p) => p.category);

    return { featured, items, totalPrice, categories, byCategory };
  }, [products, filters]);
}
```

## Why

배열 메서드마다 순회 특성이 다르다. `filter`는 항상 전체 배열을 순회하지만, `find`/`some`/`every`는 조건 충족 시 즉시 반환(early return)한다. 잘못된 메서드 선택은 대규모 데이터에서 수배의 불필요한 연산을 발생시킨다.

**정량적 효과:**
- `filter()[0]` → `find()`: 10,000개 배열에서 첫 번째 요소 검색 시 평균 5,000회 → 1회 순회
- `filter().length > 0` → `some()`: 최선의 경우 1회 비교로 즉시 반환
- 3중 filter 체이닝 → 단일 filter: 순회 횟수 3x → 1x
- `Object.groupBy`: 수동 reduce 대비 코드 50% 감소 + 엔진 최적화

**메서드 선택 표:**
| 목적 | 메서드 | 순회 특성 |
|------|--------|----------|
| 단일 검색 | `find()` | 찾으면 중지 |
| 존재 여부 | `some()` | 하나라도 true면 중지 |
| 전체 조건 | `every()` | 하나라도 false면 중지 |
| 다수 필터 | `filter()` | 전체 순회 |
| 변환 | `map()` | 전체 순회 |
| 집계 | `reduce()` | 전체 순회 |

## References

- [MDN: Array methods](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array)
- [MDN: Object.groupBy()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/groupBy)
- [MDN: Array.prototype.at()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/at)
