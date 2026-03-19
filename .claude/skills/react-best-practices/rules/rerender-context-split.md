---
title: "Context를 도메인별로 분리 — 전역 Context 금지"
id: rerender-context-split
impact: MEDIUM
category: rerender-optimization
impactDescription: "Context 업데이트 시 관련 없는 컴포넌트 리렌더 제거 — 렌더 범위 80% 축소"
tags: [react, nextjs, performance, rerender, context]
---

# Context를 도메인별로 분리 — 전역 Context 금지

> 하나의 거대한 Context에 여러 도메인 상태를 담으면, 어떤 값이 변경되든 해당 Context를 구독하는 모든 컴포넌트가 리렌더된다. 도메인별로 분리해야 한다.

## Incorrect

```tsx
// Before: 모든 상태를 하나의 AppContext에 담음
interface AppState {
  theme: 'light' | 'dark';
  user: User | null;
  cart: CartItem[];
  notifications: Notification[];
  locale: string;
}

const AppContext = createContext<{
  state: AppState;
  dispatch: React.Dispatch<AppAction>;
} | null>(null);

function AppProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(appReducer, initialState);

  return (
    <AppContext.Provider value={{ state, dispatch }}>
      {children}
    </AppContext.Provider>
  );
}

// 장바구니 아이템이 추가될 때마다...
function ThemeToggle() {
  // theme만 필요하지만 cart, notifications 변경에도 리렌더됨
  const { state, dispatch } = useContext(AppContext)!;

  return (
    <button onClick={() => dispatch({ type: 'TOGGLE_THEME' })}>
      {state.theme === 'light' ? '🌙' : '☀️'}
    </button>
  );
}

function CartBadge() {
  // cart.length만 필요하지만 theme, locale 변경에도 리렌더됨
  const { state } = useContext(AppContext)!;

  return <span className="badge">{state.cart.length}</span>;
}
```

## Correct

```tsx
// After: 도메인별 Context 분리 — 각 영역 독립 업데이트
// providers/theme-provider.tsx
interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const toggleTheme = useCallback(
    () => setTheme((prev) => (prev === 'light' ? 'dark' : 'light')),
    [],
  );

  // value 객체를 useMemo로 안정화 — Provider 리렌더 시 불필요한 전파 방지
  const value = useMemo(() => ({ theme, toggleTheme }), [theme, toggleTheme]);

  return (
    <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}

// providers/cart-provider.tsx
interface CartContextType {
  items: CartItem[];
  addItem: (item: CartItem) => void;
  removeItem: (id: string) => void;
  totalCount: number;
}

const CartContext = createContext<CartContextType | null>(null);

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<CartItem[]>([]);

  const addItem = useCallback((item: CartItem) => {
    setItems((prev) => [...prev, item]);
  }, []);

  const removeItem = useCallback((id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }, []);

  const value = useMemo(
    () => ({ items, addItem, removeItem, totalCount: items.length }),
    [items, addItem, removeItem],
  );

  return (
    <CartContext.Provider value={value}>{children}</CartContext.Provider>
  );
}

export function useCart() {
  const ctx = useContext(CartContext);
  if (!ctx) throw new Error('useCart must be used within CartProvider');
  return ctx;
}

// app/layout.tsx — Provider 중첩 (서로 독립)
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <ThemeProvider>
          <AuthProvider>
            <CartProvider>
              {children}
            </CartProvider>
          </AuthProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}

// 컴포넌트 — 필요한 Context만 구독
function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();
  // cart 변경에 영향받지 않음
  return <button onClick={toggleTheme}>{theme}</button>;
}

function CartBadge() {
  const { totalCount } = useCart();
  // theme 변경에 영향받지 않음
  return <span className="badge">{totalCount}</span>;
}
```

## Why

React Context는 값이 변경되면 해당 Context를 `useContext`로 구독하는 **모든 컴포넌트**를 리렌더한다. selector 개념이 없으므로, 하나의 거대한 Context에 theme + auth + cart + notifications를 담으면 cart 아이템 추가 시 ThemeToggle까지 리렌더된다.

도메인별 분리 효과:
1. **업데이트 격리**: cart 변경은 CartContext 구독자만 리렌더
2. **코드 응집도**: 관련 상태 + 액션이 한 파일에 모임
3. **테스트 용이**: 개별 Provider를 독립 테스트 가능
4. **Tree-shaking**: 사용하지 않는 Provider를 제거 가능

**정량적 효과:**
- 장바구니에 아이템 추가 시: 전체 앱 리렌더 → CartContext 구독자만 리렌더 (렌더 범위 80% 축소)
- 테마 전환 시: 전체 앱 리렌더 → ThemeContext 구독자만 리렌더
- React Profiler에서 "Rendered because context changed" 항목이 해당 도메인에만 나타남

## References

- [React 공식 문서 — useContext](https://react.dev/reference/react/useContext)
- [React 공식 문서 — Scaling Up with Reducer and Context](https://react.dev/learn/scaling-up-with-reducer-and-context)
- [Preventing rerenders with React.memo and useContext](https://github.com/facebook/react/issues/15156#issuecomment-474590693)
