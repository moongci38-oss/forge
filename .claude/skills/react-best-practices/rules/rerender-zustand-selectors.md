---
title: "Zustand selector로 구독 범위 최소화"
id: rerender-zustand-selectors
impact: MEDIUM
category: rerender-optimization
impactDescription: "스토어 업데이트 시 관련 컴포넌트만 리렌더 — 무관한 렌더 95% 제거"
tags: [react, nextjs, performance, rerender, zustand, state-management]
---

# Zustand selector로 구독 범위 최소화

> Zustand 스토어에서 전체 state를 구독하면, 스토어의 어떤 값이 변경되든 해당 컴포넌트가 리렌더된다. selector로 필요한 값만 구독해야 한다.

## Incorrect

```tsx
// Before: 전체 스토어 구독 — 무관한 변경에도 리렌더
import { create } from 'zustand';

interface AppStore {
  // 사용자
  user: User | null;
  setUser: (user: User | null) => void;
  // 장바구니
  cartItems: CartItem[];
  addToCart: (item: CartItem) => void;
  removeFromCart: (id: string) => void;
  // UI
  sidebarOpen: boolean;
  toggleSidebar: () => void;
  // 알림
  notifications: Notification[];
  addNotification: (n: Notification) => void;
  clearNotifications: () => void;
}

const useAppStore = create<AppStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  cartItems: [],
  addToCart: (item) => set((s) => ({ cartItems: [...s.cartItems, item] })),
  removeFromCart: (id) =>
    set((s) => ({ cartItems: s.cartItems.filter((i) => i.id !== id) })),
  sidebarOpen: false,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
  notifications: [],
  addNotification: (n) =>
    set((s) => ({ notifications: [...s.notifications, n] })),
  clearNotifications: () => set({ notifications: [] }),
}));

// 전체 스토어를 구조분해 — 장바구니 변경 시 Header도 리렌더됨
function Header() {
  const { user, sidebarOpen, toggleSidebar, notifications } = useAppStore();

  return (
    <header>
      <button onClick={toggleSidebar}>메뉴</button>
      <span>{user?.name}</span>
      <span>알림 {notifications.length}</span>
    </header>
  );
}

// 전체 스토어를 구조분해 — 사이드바 토글 시 CartSummary도 리렌더됨
function CartSummary() {
  const { cartItems, removeFromCart } = useAppStore();

  return (
    <div>
      {cartItems.map((item) => (
        <div key={item.id}>
          {item.name} <button onClick={() => removeFromCart(item.id)}>삭제</button>
        </div>
      ))}
    </div>
  );
}
```

## Correct

```tsx
// After: selector로 필요한 값만 구독 — 정확한 범위만 리렌더
function Header() {
  // 각각 독립적으로 구독 — cartItems 변경은 이 컴포넌트에 영향 없음
  const user = useAppStore((state) => state.user);
  const sidebarOpen = useAppStore((state) => state.sidebarOpen);
  const toggleSidebar = useAppStore((state) => state.toggleSidebar);
  const notificationCount = useAppStore((state) => state.notifications.length);

  return (
    <header>
      <button onClick={toggleSidebar}>메뉴</button>
      <span>{user?.name}</span>
      <span>알림 {notificationCount}</span>
    </header>
  );
}

function CartSummary() {
  // cartItems만 구독 — 사이드바 토글, 알림 변경에 영향 없음
  const cartItems = useAppStore((state) => state.cartItems);
  const removeFromCart = useAppStore((state) => state.removeFromCart);

  return (
    <div>
      {cartItems.map((item) => (
        <div key={item.id}>
          {item.name} <button onClick={() => removeFromCart(item.id)}>삭제</button>
        </div>
      ))}
    </div>
  );
}
```

```tsx
// 고급: 여러 값을 하나의 selector로 묶을 때 — shallow 비교 사용
import { useShallow } from 'zustand/react/shallow';

function CartFooter() {
  // useShallow로 객체의 얕은 비교 — 내부 값이 동일하면 리렌더 안 함
  const { totalPrice, itemCount } = useAppStore(
    useShallow((state) => ({
      totalPrice: state.cartItems.reduce(
        (sum, item) => sum + item.price * item.qty,
        0,
      ),
      itemCount: state.cartItems.length,
    })),
  );

  return (
    <div>
      <span>상품 {itemCount}개</span>
      <span>합계: {totalPrice.toLocaleString()}원</span>
    </div>
  );
}

// 고급: 스토어 분리 (규모가 커지면)
const useCartStore = create<CartStore>((set) => ({
  items: [],
  addItem: (item) => set((s) => ({ items: [...s.items, item] })),
  removeItem: (id) => set((s) => ({ items: s.items.filter((i) => i.id !== id) })),
}));

const useUIStore = create<UIStore>((set) => ({
  sidebarOpen: false,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));
```

## Why

Zustand의 `useStore()`는 selector 없이 호출하면 스토어 전체를 구독한다. 스토어의 어떤 필드가 변경되든 `Object.is` 비교가 실패하여 컴포넌트가 리렌더된다.

selector를 사용하면 Zustand가 **selector 반환값**만 비교한다. `state => state.user`는 user가 변경될 때만 리렌더를 트리거한다.

**주의사항:**
- selector가 매 호출마다 새 객체를 생성하면(`state => ({ a: state.a, b: state.b })`) 매번 리렌더됨 → `useShallow` 사용
- 액션 함수(`toggleSidebar` 등)는 참조가 변하지 않으므로 별도 selector로 추출해도 리렌더 없음

**정량적 효과:**
- 사이드바 토글 시: 전체 스토어 구독 → 모든 컴포넌트 리렌더 / selector → sidebarOpen 구독자만 리렌더 (95% 제거)
- 장바구니 아이템 추가 시: Header, Footer 등 무관한 컴포넌트 리렌더 제거
- 대규모 앱에서 React Profiler "Rendered because hooks changed" 항목 대폭 감소

## References

- [Zustand 공식 문서](https://zustand.docs.pmnd.rs/)
- [Zustand — Auto Generating Selectors](https://zustand.docs.pmnd.rs/guides/auto-generating-selectors)
- [Zustand — Preventing rerenders with useShallow](https://zustand.docs.pmnd.rs/guides/prevent-rerenders-with-use-shallow)
