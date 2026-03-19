---
title: "이벤트 위임 패턴 — 개별 리스너 최소화"
id: js-event-delegation
impact: LOW
category: javascript-performance
impactDescription: "이벤트 리스너 수 90% 감소 — 메모리 사용 최적화"
tags: [react, performance, events, delegation, memory]
---

# 이벤트 위임 패턴 — 개별 리스너 최소화

> 다수의 자식 요소에 개별 이벤트 리스너를 부착하는 대신, 부모 요소에서 이벤트 버블링을 활용하여 이벤트를 위임한다.

## Incorrect

```tsx
// Before: 각 아이템마다 개별 이벤트 핸들러 — 1000개 리스너 생성
'use client';

import { useCallback } from 'react';

interface TodoItem {
  id: string;
  text: string;
  completed: boolean;
}

function TodoList({ items }: { items: TodoItem[] }) {
  // 각 아이템마다 새 함수 참조 생성 — 메모리 낭비
  return (
    <ul>
      {items.map((item) => (
        <li key={item.id}>
          <span>{item.text}</span>
          {/* 아이템 1000개 = onClick 핸들러 3000개 (×3 버튼) */}
          <button onClick={() => handleComplete(item.id)}>완료</button>
          <button onClick={() => handleEdit(item.id)}>수정</button>
          <button onClick={() => handleDelete(item.id)}>삭제</button>
        </li>
      ))}
    </ul>
  );
}
```

## Correct

```tsx
// After: 부모에서 이벤트 위임 — 리스너 1개로 모든 아이템 처리
'use client';

import { useCallback } from 'react';

function TodoList({ items }: { items: TodoItem[] }) {
  // 부모 요소에 단일 이벤트 핸들러
  const handleClick = useCallback(
    (e: React.MouseEvent<HTMLUListElement>) => {
      const target = e.target as HTMLElement;
      const button = target.closest('button[data-action]');
      if (!button) return;

      const action = button.getAttribute('data-action');
      const itemId = button.closest('li')?.getAttribute('data-item-id');
      if (!action || !itemId) return;

      switch (action) {
        case 'complete':
          handleComplete(itemId);
          break;
        case 'edit':
          handleEdit(itemId);
          break;
        case 'delete':
          handleDelete(itemId);
          break;
      }
    },
    []
  );

  return (
    // 단일 onClick으로 모든 자식 이벤트 처리
    <ul onClick={handleClick}>
      {items.map((item) => (
        <li key={item.id} data-item-id={item.id}>
          <span>{item.text}</span>
          <button data-action="complete">완료</button>
          <button data-action="edit">수정</button>
          <button data-action="delete">삭제</button>
        </li>
      ))}
    </ul>
  );
}
```

```tsx
// 실전 패턴: 테이블 셀 클릭 이벤트 위임
'use client';

import { useCallback } from 'react';

interface Column<T> {
  key: keyof T;
  header: string;
  sortable?: boolean;
}

function DataTable<T extends { id: string }>({
  data,
  columns,
  onRowClick,
  onSort,
}: {
  data: T[];
  columns: Column<T>[];
  onRowClick: (id: string) => void;
  onSort: (key: string) => void;
}) {
  // 테이블 전체에 1개 리스너 — 행/헤더 클릭 모두 처리
  const handleTableClick = useCallback(
    (e: React.MouseEvent<HTMLTableElement>) => {
      const target = e.target as HTMLElement;

      // 헤더 정렬 클릭
      const th = target.closest('th[data-sort-key]');
      if (th) {
        onSort(th.getAttribute('data-sort-key')!);
        return;
      }

      // 행 클릭
      const tr = target.closest('tr[data-row-id]');
      if (tr) {
        onRowClick(tr.getAttribute('data-row-id')!);
      }
    },
    [onRowClick, onSort]
  );

  return (
    <table onClick={handleTableClick}>
      <thead>
        <tr>
          {columns.map((col) => (
            <th
              key={String(col.key)}
              data-sort-key={col.sortable ? String(col.key) : undefined}
              style={{ cursor: col.sortable ? 'pointer' : 'default' }}
            >
              {col.header}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((row) => (
          <tr key={row.id} data-row-id={row.id} style={{ cursor: 'pointer' }}>
            {columns.map((col) => (
              <td key={String(col.key)}>{String(row[col.key])}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

## Why

React는 내부적으로 이벤트 위임을 사용하지만, JSX에서 `onClick={() => fn(id)}` 패턴으로 인라인 함수를 작성하면 각 요소마다 새 함수 객체가 생성된다. 대량 리스트에서는 이 함수 객체가 메모리를 차지하고 GC 압력을 높인다. 부모 요소에서 `data-*` 속성을 활용한 이벤트 위임은 함수 참조를 1개로 줄인다.

**정량적 효과:**
- 1000개 아이템 × 3 버튼: 함수 객체 3000개 → 1개 (99.97% 감소)
- 메모리 사용: ~48KB 절감 (함수 객체당 ~16바이트)
- 리렌더 시 GC 대상: 3000개 → 0개
- 동적 아이템 추가/제거 시 리스너 관리 불필요

**주의:** 소규모 리스트(20개 이하)에서는 인라인 핸들러가 가독성 면에서 더 나을 수 있다. 이벤트 위임은 대규모 리스트에서 효과적이다.

## References

- [React: Responding to Events](https://react.dev/learn/responding-to-events)
- [MDN: Event delegation](https://developer.mozilla.org/en-US/docs/Learn/JavaScript/Building_blocks/Event_bubbling#event_delegation)
- [JavaScript.info: Event delegation](https://javascript.info/event-delegation)
