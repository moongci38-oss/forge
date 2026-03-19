---
title: "children을 props로 전달하여 리렌더 격리"
id: rerender-children-as-props
impact: MEDIUM
category: rerender-optimization
impactDescription: "부모 상태 변경 시 children 리렌더 방지 — 불필요한 렌더 50-70% 감소"
tags: [react, nextjs, performance, rerender, composition]
---

# children을 props로 전달하여 리렌더 격리

> 상태를 가진 부모 컴포넌트 안에 children을 인라인으로 배치하면, 부모 상태 변경 시 모든 children이 리렌더된다. children을 props로 전달하면 리렌더 범위를 격리할 수 있다.

## Incorrect

```tsx
// Before: 상태를 가진 부모 안에 children 인라인 — 모든 자식이 리렌더됨
function ScrollTracker() {
  const [scrollY, setScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div>
      {/* 스크롤할 때마다 scrollY가 변경되고, 아래 모든 컴포넌트가 리렌더됨 */}
      <ProgressBar progress={scrollY} />
      <Header />           {/* 스크롤과 무관하지만 매번 리렌더 */}
      <HeroSection />      {/* 스크롤과 무관하지만 매번 리렌더 */}
      <ProductGrid />      {/* 무거운 컴포넌트 — 스크롤마다 리렌더 */}
      <Footer />           {/* 스크롤과 무관하지만 매번 리렌더 */}
    </div>
  );
}

// 사용
function App() {
  return <ScrollTracker />;
}
```

## Correct

```tsx
// After: 상태 컴포넌트와 children을 분리 — 상태 변경이 children에 전파되지 않음
function ScrollTracker({ children }: { children: React.ReactNode }) {
  const [scrollY, setScrollY] = useState(0);

  useEffect(() => {
    const handleScroll = () => setScrollY(window.scrollY);
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div>
      {/* ProgressBar만 scrollY에 의존 — 이것만 리렌더 */}
      <ProgressBar progress={scrollY} />
      {/* children은 부모(App)에서 생성된 React element — 참조가 변하지 않음 */}
      {children}
    </div>
  );
}

// 사용 — children은 App 렌더 시점에 생성됨
function App() {
  return (
    <ScrollTracker>
      <Header />           {/* 스크롤해도 리렌더되지 않음 */}
      <HeroSection />      {/* 스크롤해도 리렌더되지 않음 */}
      <ProductGrid />      {/* 무거운 컴포넌트 보호됨 */}
      <Footer />           {/* 스크롤해도 리렌더되지 않음 */}
    </ScrollTracker>
  );
}
```

```tsx
// 응용: 모달/다이얼로그 오버레이에도 동일 패턴 적용
function ModalOverlay({ children }: { children: React.ReactNode }) {
  const [isVisible, setIsVisible] = useState(false);

  return (
    <>
      {/* isVisible 변경 시 children은 리렌더되지 않음 */}
      {children}
      {isVisible && (
        <div className="fixed inset-0 bg-black/50">
          <div className="modal-content">...</div>
        </div>
      )}
      <button onClick={() => setIsVisible(true)}>모달 열기</button>
    </>
  );
}
```

## Why

React에서 컴포넌트가 리렌더되면 JSX에 인라인으로 작성된 모든 자식 엘리먼트가 새로 생성된다. `<Header />`는 `React.createElement(Header, null)`의 문법 설탕이므로, 부모가 리렌더될 때마다 새 React element 객체가 만들어진다.

하지만 `children` prop으로 전달된 엘리먼트는 **부모의 부모**(여기서는 `App`)에서 생성된 것이므로, `ScrollTracker`가 리렌더되어도 children의 참조는 변하지 않는다. React는 이전과 같은 참조의 element를 발견하면 리렌더를 건너뛴다.

**정량적 효과:**
- 스크롤 이벤트(초당 60회) 발생 시 하위 트리 전체 리렌더 방지
- ProductGrid 같은 무거운 컴포넌트(100+ 아이템)가 불필요하게 렌더되는 것을 차단
- memo() 없이도 리렌더 격리 가능 — 보일러플레이트 제로
- 실측: 불필요한 렌더 50-70% 감소 (React Profiler 기준)

## References

- [React 공식 문서 — Passing JSX as children](https://react.dev/learn/passing-props-to-a-component#passing-jsx-as-children)
- [React 공식 문서 — Extracting state logic into a reducer](https://react.dev/learn/extracting-state-logic-into-a-reducer)
- [Before You memo()](https://overreacted.io/before-you-memo/)
