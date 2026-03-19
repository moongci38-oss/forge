---
id: api-unnecessary-call
title: "mutation 후 불필요한 refetch 금지"
severity: warning
category: api
---

# mutation 후 불필요한 refetch 금지

## 문제
useMutation의 onSuccess에서 별도 fetch를 호출하면 이미 mutation 응답에 포함된 데이터를 중복 요청한다. 네트워크 비용 증가 + 불필요한 로딩 상태 노출.

## 감지 패턴
- `onSuccess` 콜백 내에서 `fetch()`, `axios.get()`, `useQuery`의 `refetch()` 직접 호출
- mutation 응답 데이터를 사용하지 않고 별도 GET 요청으로 동일 리소스 재조회
- `queryClient.invalidateQueries` 대신 수동 fetch 호출

## Bad Example
```typescript
const updateUser = useMutation({
  mutationFn: (data: UpdateUserDto) => api.updateUser(data),
  onSuccess: () => {
    // BAD: mutation 완료 후 별도 fetch로 같은 데이터 재조회
    fetch('/api/users/me').then(res => res.json()).then(setUser);
  },
});
```

## Good Example
```typescript
const queryClient = useQueryClient();

const updateUser = useMutation({
  mutationFn: (data: UpdateUserDto) => api.updateUser(data),
  onSuccess: (updatedUser) => {
    // GOOD: 캐시 무효화로 React Query가 자동 refetch
    queryClient.invalidateQueries({ queryKey: ['user', 'me'] });
    // 또는 mutation 응답으로 직접 캐시 업데이트
    // queryClient.setQueryData(['user', 'me'], updatedUser);
  },
});
```

## 검증 방법
1. 프로젝트 내 `useMutation` 사용처를 검색한다
2. `onSuccess` 콜백에서 `fetch`, `axios.get`, `.refetch()` 호출이 있는지 확인한다
3. 해당 fetch가 mutation과 동일한 리소스를 대상으로 하는지 판단한다
4. `invalidateQueries` 또는 `setQueryData`로 대체 가능한지 확인한다
