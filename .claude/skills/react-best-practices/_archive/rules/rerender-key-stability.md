---
title: "list key에 index 사용 금지 — 안정적 ID 사용"
id: rerender-key-stability
impact: MEDIUM
category: rerender-optimization
impactDescription: "리스트 아이템 순서 변경 시 DOM 재생성 방지 — 렌더 비용 90% 감소"
tags: [react, nextjs, performance, rerender, key, list]
---

# list key에 index 사용 금지 — 안정적 ID 사용

> 배열 index를 key로 사용하면, 아이템 추가/삭제/정렬 시 React가 DOM 노드를 잘못 매칭하여 전체 리스트를 재생성한다. 각 아이템의 고유 ID를 key로 사용해야 한다.

## Incorrect

```tsx
// Before: index를 key로 사용 — 아이템 순서 변경 시 전체 DOM 재생성
function TaskList() {
  const [tasks, setTasks] = useState<Task[]>([
    { id: 'a1', title: '디자인 리뷰', status: 'done' },
    { id: 'b2', title: 'API 개발', status: 'in-progress' },
    { id: 'c3', title: '테스트 작성', status: 'todo' },
  ]);

  const addToTop = (task: Task) => {
    // 맨 앞에 추가 시 모든 index가 밀림
    // key=0이었던 "디자인 리뷰"가 key=1로 변경 → React가 다른 아이템으로 인식
    setTasks((prev) => [task, ...prev]);
  };

  const sortByStatus = () => {
    setTasks((prev) => [...prev].sort((a, b) => a.status.localeCompare(b.status)));
    // 정렬 후 index가 재배치 → 모든 DOM 노드 재생성
  };

  return (
    <ul>
      {tasks.map((task, index) => (
        // index를 key로 사용 — 순서 변경 시 DOM 재사용 실패
        <TaskItem key={index} task={task} />
      ))}
    </ul>
  );
}

function TaskItem({ task }: { task: Task }) {
  // 내부 상태(예: input 편집 중 값)가 다른 아이템으로 이동됨
  const [isEditing, setIsEditing] = useState(false);
  const [editValue, setEditValue] = useState(task.title);

  return (
    <li>
      {isEditing ? (
        <input value={editValue} onChange={(e) => setEditValue(e.target.value)} />
      ) : (
        <span onClick={() => setIsEditing(true)}>{task.title}</span>
      )}
    </li>
  );
}
```

## Correct

```tsx
// After: 고유 ID를 key로 사용 — 순서 변경 시 DOM 노드 재사용
function TaskList() {
  const [tasks, setTasks] = useState<Task[]>([
    { id: 'a1', title: '디자인 리뷰', status: 'done' },
    { id: 'b2', title: 'API 개발', status: 'in-progress' },
    { id: 'c3', title: '테스트 작성', status: 'todo' },
  ]);

  const addToTop = (task: Task) => {
    setTasks((prev) => [task, ...prev]);
    // key='a1'인 "디자인 리뷰"는 여전히 key='a1' → DOM 노드 재사용
  };

  const sortByStatus = () => {
    setTasks((prev) => [...prev].sort((a, b) => a.status.localeCompare(b.status)));
    // 각 아이템의 key가 동일 → React가 DOM 노드 위치만 이동 (재생성 없음)
  };

  return (
    <ul>
      {tasks.map((task) => (
        // 고유 ID를 key로 사용 — 순서 무관하게 DOM 매칭
        <TaskItem key={task.id} task={task} />
      ))}
    </ul>
  );
}

function TaskItem({ task }: { task: Task }) {
  const [isEditing, setIsEditing] = useState(false);
  const [editValue, setEditValue] = useState(task.title);

  // 정렬해도 이 컴포넌트의 내부 상태가 올바른 아이템에 유지됨
  return (
    <li>
      {isEditing ? (
        <input value={editValue} onChange={(e) => setEditValue(e.target.value)} />
      ) : (
        <span onClick={() => setIsEditing(true)}>{task.title}</span>
      )}
    </li>
  );
}
```

```tsx
// ID가 없는 데이터의 경우 — 생성 시점에 ID 부여
function createTask(title: string): Task {
  return {
    id: crypto.randomUUID(), // 브라우저 내장 UUID 생성
    title,
    status: 'todo',
  };
}

// 절대 하지 말 것: key에 Math.random() 사용
// 매 렌더마다 새 key → 매번 전체 DOM 재생성 (index보다 나쁨)
{tasks.map((task) => (
  <TaskItem key={Math.random()} task={task} /> // 최악
))}
```

## Why

React의 reconciliation 알고리즘은 key를 사용하여 이전 렌더와 현재 렌더의 엘리먼트를 매칭한다.

- **index key**: 맨 앞에 아이템 추가 시 → 기존 0번이 1번으로 → React가 "0번 엘리먼트의 props가 변경됨"으로 인식 → 모든 노드의 props 업데이트 + 내부 상태 불일치
- **고유 ID key**: 맨 앞에 아이템 추가 시 → 기존 'a1' key는 여전히 'a1' → React가 정확히 매칭 → 새 아이템 DOM만 생성

내부 상태 문제도 심각하다. index key를 사용하면 편집 중인 input의 값이 정렬 후 다른 아이템으로 "이동"하는 버그가 발생한다.

**정량적 효과:**
- 100개 리스트 맨 앞에 아이템 추가 시: index key → 100개 DOM 업데이트, ID key → 1개 DOM 생성
- 정렬 시: index key → 100개 DOM props 업데이트, ID key → DOM 위치 재배치만 (렌더 비용 90% 감소)
- 내부 상태 불일치 버그 발생률: 0% (ID key 사용 시)

## References

- [React 공식 문서 — Rendering Lists](https://react.dev/learn/rendering-lists#keeping-list-items-in-order-with-key)
- [React 공식 문서 — Why does React need keys?](https://react.dev/learn/rendering-lists#why-does-react-need-keys)
- [React 공식 문서 — Preserving and Resetting State](https://react.dev/learn/preserving-and-resetting-state)
