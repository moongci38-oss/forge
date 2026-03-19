---
title: "이벤트 핸들러는 useCallback으로 참조 안정성 확보"
id: rerender-callback-stability
impact: MEDIUM
category: rerender-optimization
impactDescription: "memo된 자식에 전달되는 콜백 안정화 — 불필요한 자식 리렌더 제거"
tags: [react, nextjs, performance, rerender, useCallback, memo]
---

# 이벤트 핸들러는 useCallback으로 참조 안정성 확보

> 인라인 화살표 함수를 memo된 자식 컴포넌트에 전달하면, 부모가 리렌더될 때마다 새 함수 참조가 생성되어 memo를 무효화한다. useCallback으로 참조를 안정화해야 한다.

## Incorrect

```tsx
// Before: 인라인 함수가 memo를 무효화
function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [filter, setFilter] = useState('all');

  // filter가 변경될 때마다 새 함수 참조 생성
  // → 모든 TodoItem이 리렌더됨 (memo가 있어도 무효)
  return (
    <div>
      <FilterBar value={filter} onChange={setFilter} />
      {todos.map((todo) => (
        <MemoizedTodoItem
          key={todo.id}
          todo={todo}
          // 매 렌더마다 새 함수 — MemoizedTodoItem의 memo 무효화
          onToggle={() => {
            setTodos((prev) =>
              prev.map((t) =>
                t.id === todo.id ? { ...t, done: !t.done } : t,
              ),
            );
          }}
          // 매 렌더마다 새 함수
          onDelete={() => {
            setTodos((prev) => prev.filter((t) => t.id !== todo.id));
          }}
        />
      ))}
    </div>
  );
}

const MemoizedTodoItem = memo(function TodoItem({
  todo,
  onToggle,
  onDelete,
}: {
  todo: Todo;
  onToggle: () => void;
  onDelete: () => void;
}) {
  return (
    <li>
      <input type="checkbox" checked={todo.done} onChange={onToggle} />
      <span>{todo.title}</span>
      <button onClick={onDelete}>삭제</button>
    </li>
  );
});
```

## Correct

```tsx
// After: useCallback으로 함수 참조 안정화 — memo가 정상 작동
function TodoList() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [filter, setFilter] = useState('all');

  // id를 파라미터로 받는 안정적 콜백 — 의존성 없음
  const handleToggle = useCallback((id: string) => {
    setTodos((prev) =>
      prev.map((t) => (t.id === id ? { ...t, done: !t.done } : t)),
    );
  }, []);

  const handleDelete = useCallback((id: string) => {
    setTodos((prev) => prev.filter((t) => t.id !== id));
  }, []);

  return (
    <div>
      <FilterBar value={filter} onChange={setFilter} />
      {todos.map((todo) => (
        <MemoizedTodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}  // 안정적 참조 — filter 변경 시에도 동일
          onDelete={handleDelete}  // 안정적 참조
        />
      ))}
    </div>
  );
}

const MemoizedTodoItem = memo(function TodoItem({
  todo,
  onToggle,
  onDelete,
}: {
  todo: Todo;
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
}) {
  return (
    <li>
      <input
        type="checkbox"
        checked={todo.done}
        onChange={() => onToggle(todo.id)}
      />
      <span>{todo.title}</span>
      <button onClick={() => onDelete(todo.id)}>삭제</button>
    </li>
  );
});
```

## Why

`memo()`는 props의 얕은 비교(shallow comparison)로 리렌더 여부를 결정한다. 함수는 참조 타입이므로 매 렌더마다 새로 생성된 인라인 함수는 이전 함수와 `!==`이다. 결과적으로 memo가 있어도 **매번 리렌더**된다.

`useCallback`은 의존성 배열이 변하지 않으면 이전과 동일한 함수 참조를 반환한다. `setTodos`의 함수형 업데이트(`prev => ...`)를 사용하면 의존성에 `todos`를 넣지 않아도 되므로 의존성 배열을 `[]`로 유지할 수 있다.

**정량적 효과:**
- 100개 TodoItem 리스트에서 filter 변경 시: 100개 리렌더 → 0개 리렌더
- 각 TodoItem 렌더 비용이 2ms라면: 200ms → 0ms (filter 변경 시)
- todo 하나 토글 시: 1개만 리렌더 (해당 todo의 props만 변경)

**주의:** memo되지 않은 자식에 useCallback을 쓰면 효과 없음 — memo와 함께 사용해야 의미가 있다. React 19의 React Compiler를 사용하면 자동 처리된다.

## References

- [React 공식 문서 — useCallback](https://react.dev/reference/react/useCallback)
- [React 공식 문서 — memo](https://react.dev/reference/react/memo)
- [React 공식 문서 — Optimizing re-renders with memo](https://react.dev/reference/react/memo#minimizing-props-changes)
