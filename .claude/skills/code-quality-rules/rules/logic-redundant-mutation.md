---
id: logic-redundant-mutation
title: "동일 상태 연속 덮어쓰기 금지"
severity: warning
category: logic
---

# 동일 상태 연속 덮어쓰기 금지

## 문제
같은 상태를 연속으로 여러 번 변경하면 중간 값은 렌더링되지 않고 마지막 값만 적용된다. 불필요한 코드 복잡도를 만들고, React 배칭에 의해 의도와 다른 결과가 발생할 수 있다.

## 감지 패턴
- 같은 `setState`를 한 함수 내에서 2회 이상 연속 호출
- 같은 상태 키에 대해 순차적으로 덮어쓰는 로직
- 배열 상태에 여러 번 개별 push하는 패턴 (filter + concat 반복)

## Bad Example
```typescript
// BAD: 같은 setState를 연속 호출 - 마지막만 적용됨
function handleSubmit() {
  setLoading(true);
  setError(null);
  setLoading(true); // 중복 - 의미 없음
}

// BAD: 같은 상태를 여러 번 덮어쓰기
function updateFilters(newFilter: Filter) {
  setFilters(prev => [...prev, newFilter]);
  setFilters(prev => prev.filter(f => f.isActive)); // 위 결과 무시될 수 있음
  setFilters(prev => [...prev].sort((a, b) => a.order - b.order)); // 의도 불명확
}
```

## Good Example
```typescript
// GOOD: 상태 변경을 한 번에 처리
function handleSubmit() {
  setLoading(true);
  setError(null);
}

// GOOD: 상태 변환을 단일 업데이트로 합침
function updateFilters(newFilter: Filter) {
  setFilters(prev =>
    [...prev, newFilter]
      .filter(f => f.isActive)
      .sort((a, b) => a.order - b.order)
  );
}
```

## 검증 방법
1. 함수 스코프 내에서 동일한 `set*` 함수가 2회 이상 호출되는지 검색한다
2. 연속된 호출이 같은 상태를 대상으로 하는지 확인한다
3. 중간 값이 렌더링에 사용되는지, 아니면 마지막 값만 의미 있는지 판단한다
4. 단일 업데이트로 합칠 수 있으면 WARNING으로 판정한다
