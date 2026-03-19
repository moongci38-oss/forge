---
id: logic-race-condition
title: "비동기 cleanup 없이 상태 업데이트 금지"
severity: critical
category: logic
---

# 비동기 cleanup 없이 상태 업데이트 금지

## 문제
비동기 작업(fetch, setTimeout) 완료 시점에 컴포넌트가 이미 언마운트되었으면 "Can't perform a React state update on an unmounted component" 경고가 발생한다. 메모리 누수와 예측 불가능한 상태 업데이트를 유발한다.

## 감지 패턴
- `useEffect` 내 `fetch`/`setTimeout`/`setInterval`에서 상태 업데이트하면서 AbortController/cleanup이 없는 경우
- async 함수 내에서 `await` 후 `setState` 호출하면서 마운트 상태 확인 없는 경우
- 이벤트 리스너 콜백에서 상태 업데이트하면서 cleanup 없는 경우

## Bad Example
```typescript
// BAD: fetch 완료 시 컴포넌트가 이미 언마운트됐을 수 있음
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    async function load() {
      const response = await fetch(`/api/users/${userId}`);
      const data = await response.json();
      setUser(data); // 언마운트 후 호출 가능 - race condition
    }
    load();
  }, [userId]);

  return <div>{user?.name}</div>;
}
```

## Good Example
```typescript
// GOOD: AbortController로 fetch 취소
function UserProfile({ userId }: { userId: string }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const controller = new AbortController();

    async function load() {
      try {
        const response = await fetch(`/api/users/${userId}`, {
          signal: controller.signal,
        });
        const data = await response.json();
        setUser(data);
      } catch (error) {
        if (error instanceof DOMException && error.name === 'AbortError') {
          return; // 정상적인 취소 - 무시
        }
        throw error;
      }
    }

    load();
    return () => controller.abort();
  }, [userId]);

  return <div>{user?.name}</div>;
}

// GOOD: React Query 사용 시 자동 처리됨
function UserProfile({ userId }: { userId: string }) {
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => api.getUser(userId),
  });

  return <div>{user?.name}</div>;
}
```

## 검증 방법
1. `useEffect` 내부에서 비동기 작업(fetch, setTimeout, setInterval) 후 `setState`를 호출하는 패턴을 검색한다
2. 해당 useEffect에 cleanup 함수가 반환되는지 확인한다
3. fetch의 경우 AbortController signal이 전달되는지 확인한다
4. cleanup 없으면 CRITICAL FAIL - AbortController 추가 또는 React Query 전환을 권장한다
