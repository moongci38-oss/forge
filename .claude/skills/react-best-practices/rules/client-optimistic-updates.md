---
title: "낙관적 업데이트로 체감 속도 개선"
id: client-optimistic-updates
impact: HIGH
category: client-data-fetching
impactDescription: "mutation 체감 속도 즉시 반응 — 사용자 대기 시간 0ms"
tags: [react, optimistic-update, mutation, ux, performance]
---

# 낙관적 업데이트로 체감 속도 개선

> 서버 응답을 기다린 후 UI를 업데이트하면 사용자는 매번 지연을 체감한다. 낙관적 업데이트로 UI를 즉시 변경하고, 서버 실패 시에만 롤백하면 체감 속도가 즉각 반응으로 바뀐다.

## Incorrect

```tsx
// Before: 서버 응답을 기다린 후 UI 업데이트 — 매번 로딩 지연
// components/TodoList.tsx
'use client';

import { useState } from 'react';

interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

export function TodoList({ initialTodos }: { initialTodos: Todo[] }) {
  const [todos, setTodos] = useState(initialTodos);
  const [isUpdating, setIsUpdating] = useState<string | null>(null);

  async function toggleTodo(id: string) {
    setIsUpdating(id); // 로딩 스피너 표시

    try {
      // 서버 응답 대기 (200-500ms)
      const res = await fetch(`/api/todos/${id}/toggle`, { method: 'PATCH' });
      if (!res.ok) throw new Error('Failed');

      const updated = await res.json();

      // 응답 후에야 UI 업데이트
      setTodos((prev) =>
        prev.map((todo) => (todo.id === id ? updated : todo))
      );
    } catch {
      alert('업데이트 실패');
    } finally {
      setIsUpdating(null); // 로딩 스피너 제거
    }
  }

  return (
    <ul>
      {todos.map((todo) => (
        <li key={todo.id}>
          <button
            onClick={() => toggleTodo(todo.id)}
            disabled={isUpdating === todo.id} // 클릭 후 200-500ms 동안 비활성
          >
            {isUpdating === todo.id ? '처리 중...' : todo.completed ? 'v' : 'o'}
          </button>
          <span>{todo.title}</span>
        </li>
      ))}
    </ul>
  );
}
```

## Correct

```tsx
// After: SWR mutate로 낙관적 업데이트 — UI 즉시 반영 + 실패 시 롤백
// components/TodoList.tsx
'use client';

import useSWR, { useSWRConfig } from 'swr';

interface Todo {
  id: string;
  title: string;
  completed: boolean;
}

export function TodoList() {
  const { data: todos, mutate } = useSWR<Todo[]>('/api/todos');

  async function toggleTodo(id: string) {
    if (!todos) return;

    // 낙관적 업데이트: 서버 요청 전에 UI를 즉시 변경
    await mutate(
      async () => {
        const res = await fetch(`/api/todos/${id}/toggle`, { method: 'PATCH' });
        if (!res.ok) throw new Error('Failed');
        return res.json(); // 서버 응답으로 최종 데이터 교체
      },
      {
        // 서버 요청 전에 캐시를 즉시 업데이트 (낙관적)
        optimisticData: todos.map((todo) =>
          todo.id === id ? { ...todo, completed: !todo.completed } : todo
        ),
        // 실패 시 이전 데이터로 자동 롤백
        rollbackOnError: true,
        // 서버 응답 후 캐시를 다시 검증하지 않음 (응답 데이터가 최종)
        revalidate: false,
      }
    );
  }

  if (!todos) return <TodoSkeleton />;

  return (
    <ul>
      {todos.map((todo) => (
        <li key={todo.id}>
          <button onClick={() => toggleTodo(todo.id)}>
            {/* 클릭 즉시 상태 변경 — 로딩 없음 */}
            {todo.completed ? 'v' : 'o'}
          </button>
          <span>{todo.title}</span>
        </li>
      ))}
    </ul>
  );
}
```

```tsx
// React 19 useOptimistic을 사용한 Server Action 낙관적 업데이트
// components/LikeButton.tsx
'use client';

import { useOptimistic, useTransition } from 'react';
import { toggleLike } from '@/app/actions/like-actions';

interface LikeButtonProps {
  postId: string;
  initialLiked: boolean;
  initialCount: number;
}

export function LikeButton({
  postId,
  initialLiked,
  initialCount,
}: LikeButtonProps) {
  const [isPending, startTransition] = useTransition();

  const [optimistic, setOptimistic] = useOptimistic(
    { liked: initialLiked, count: initialCount },
    (current, newLiked: boolean) => ({
      liked: newLiked,
      count: newLiked ? current.count + 1 : current.count - 1,
    })
  );

  function handleClick() {
    startTransition(async () => {
      // UI 즉시 업데이트 (낙관적)
      setOptimistic(!optimistic.liked);
      // Server Action 실행 — 실패 시 자동 롤백
      await toggleLike(postId);
    });
  }

  return (
    <button onClick={handleClick} disabled={isPending}>
      {optimistic.liked ? 'Unlike' : 'Like'} ({optimistic.count})
    </button>
  );
}
```

## Why

사용자가 버튼을 클릭한 후 서버 응답까지 200-500ms를 대기하면, 이 지연이 누적되어 "느린 앱"이라는 인상을 준다. 특히 토글, 좋아요, 삭제 같은 빈번한 인터랙션에서 체감이 크다.

낙관적 업데이트는 **서버 성공을 가정하고 UI를 즉시 변경**한다. 대부분의 mutation은 성공하므로 (95%+), 실패 시에만 롤백하는 것이 UX 측면에서 훨씬 유리하다.

**정량적 효과:**
- 사용자 체감 반응 시간: 200-500ms → 0ms (즉시 반응)
- 클릭 후 UI 업데이트 지연: 완전 제거
- 사용자 이탈률: 인터랙션 지연이 100ms 증가할 때마다 이탈률 ~7% 증가 (Amazon 조사)

## References

- [SWR: Optimistic Updates](https://swr.vercel.app/docs/mutation#optimistic-updates)
- [React 19 useOptimistic](https://react.dev/reference/react/useOptimistic)
- [TanStack Query: Optimistic Updates](https://tanstack.com/query/latest/docs/framework/react/guides/optimistic-updates)
