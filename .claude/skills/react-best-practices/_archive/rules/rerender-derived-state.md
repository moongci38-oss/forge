---
title: "파생 상태는 useState 대신 계산으로 처리"
id: rerender-derived-state
impact: MEDIUM
category: rerender-optimization
impactDescription: "불필요한 상태 동기화 제거 — 버그 발생률 감소 + 렌더 사이클 절약"
tags: [react, nextjs, performance, rerender, derived-state]
---

# 파생 상태는 useState 대신 계산으로 처리

> 기존 state나 props에서 계산할 수 있는 값을 별도 useState로 관리하면, 동기화 useEffect가 필요하고 불필요한 추가 렌더가 발생한다. 렌더링 중에 직접 계산해야 한다.

## Incorrect

```tsx
// Before: 파생 값을 useState + useEffect로 동기화
function ShoppingCart({ items }: { items: CartItem[] }) {
  const [totalPrice, setTotalPrice] = useState(0);
  const [itemCount, setItemCount] = useState(0);
  const [hasDiscount, setHasDiscount] = useState(false);

  // items가 변경될 때마다 파생 상태를 수동 동기화
  // 렌더 1: items 변경 → 렌더 실행 (이전 totalPrice 표시)
  // 렌더 2: useEffect 실행 → setTotalPrice → 다시 렌더 (정확한 값 표시)
  useEffect(() => {
    const total = items.reduce((sum, item) => sum + item.price * item.qty, 0);
    setTotalPrice(total);
    setItemCount(items.length);
    setHasDiscount(total > 100_000);
  }, [items]);

  return (
    <div>
      <p>상품 수: {itemCount}</p>
      <p>합계: {totalPrice.toLocaleString()}원</p>
      {hasDiscount && <p>10% 할인 적용!</p>}
      {items.map((item) => (
        <CartItemRow key={item.id} item={item} />
      ))}
    </div>
  );
}
```

## Correct

```tsx
// After: 렌더링 중에 직접 계산 — 항상 최신값, 추가 렌더 없음
function ShoppingCart({ items }: { items: CartItem[] }) {
  // 렌더링 중에 계산 — useState/useEffect 불필요
  const totalPrice = items.reduce(
    (sum, item) => sum + item.price * item.qty,
    0,
  );
  const itemCount = items.length;
  const hasDiscount = totalPrice > 100_000;

  return (
    <div>
      <p>상품 수: {itemCount}</p>
      <p>합계: {totalPrice.toLocaleString()}원</p>
      {hasDiscount && <p>10% 할인 적용!</p>}
      {items.map((item) => (
        <CartItemRow key={item.id} item={item} />
      ))}
    </div>
  );
}
```

```tsx
// 응용: 필터링된 리스트도 파생 값
function UserList({
  users,
  searchQuery,
  roleFilter,
}: {
  users: User[];
  searchQuery: string;
  roleFilter: string;
}) {
  // Bad: useState + useEffect로 filteredUsers 관리
  // Good: 렌더링 중에 계산 (비용이 높으면 useMemo 사용)
  const filteredUsers = useMemo(
    () =>
      users
        .filter((u) =>
          u.name.toLowerCase().includes(searchQuery.toLowerCase()),
        )
        .filter((u) => roleFilter === 'all' || u.role === roleFilter),
    [users, searchQuery, roleFilter],
  );

  // 파생 값은 그냥 계산
  const resultCount = filteredUsers.length;
  const hasResults = resultCount > 0;

  return (
    <div>
      <p>{resultCount}명의 사용자</p>
      {hasResults ? (
        filteredUsers.map((user) => <UserCard key={user.id} user={user} />)
      ) : (
        <EmptyState />
      )}
    </div>
  );
}
```

## Why

useState + useEffect로 파생 상태를 관리하면 두 가지 문제가 발생한다:

1. **이중 렌더(Double render)**: items 변경 → 렌더 1 (이전 totalPrice) → useEffect → setTotalPrice → 렌더 2 (정확한 값). 사용자가 첫 렌더에서 잘못된 값을 잠깐 볼 수 있다.

2. **동기화 버그**: 새 파생 값을 추가할 때 useEffect의 의존성 배열에 빠뜨리거나, 여러 상태가 서로를 동기화하면서 무한 루프나 불일치가 발생한다.

렌더링 중에 직접 계산하면:
- **항상 최신값**: items가 변경된 동일 렌더에서 정확한 totalPrice 표시
- **단일 렌더**: useEffect로 인한 추가 렌더 제거
- **동기화 불필요**: 원본(items)에서 바로 파생하므로 불일치 불가능

**정량적 효과:**
- useEffect 기반: items 변경 시 2회 렌더 → 직접 계산: 1회 렌더 (50% 렌더 사이클 절약)
- 첫 렌더에서 정확한 값 표시 — 깜빡임(flicker) 제거
- 파생 상태 관련 버그(stale value, sync issue) 발생률 0%

## References

- [React 공식 문서 — You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)
- [React 공식 문서 — Choosing the State Structure](https://react.dev/learn/choosing-the-state-structure#avoid-redundant-state)
- [React 공식 문서 — Updating state based on props or state](https://react.dev/learn/you-might-not-need-an-effect#updating-state-based-on-props-or-state)
