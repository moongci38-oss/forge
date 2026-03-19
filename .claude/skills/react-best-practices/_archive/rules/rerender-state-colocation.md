---
title: "상태는 사용하는 컴포넌트에 최대한 가까이 배치"
id: rerender-state-colocation
impact: MEDIUM
category: rerender-optimization
impactDescription: "상태 변경 영향 범위 최소화 — 리렌더 트리 70% 축소"
tags: [react, nextjs, performance, rerender, state-management]
---

# 상태는 사용하는 컴포넌트에 최대한 가까이 배치

> 상태를 실제 사용하는 컴포넌트보다 높은 레벨에 두면, 상태 변경 시 불필요한 형제 컴포넌트까지 리렌더된다. 상태를 가능한 한 낮은 레벨로 이동(colocation)해야 한다.

## Incorrect

```tsx
// Before: 검색어 상태가 페이지 최상위에 위치 — 전체 페이지 리렌더
function DashboardPage() {
  // 검색어는 SearchResults에서만 사용하지만 페이지 레벨에 있음
  const [searchQuery, setSearchQuery] = useState('');
  // 선택된 탭은 TabPanel에서만 사용하지만 페이지 레벨에 있음
  const [activeTab, setActiveTab] = useState('overview');

  return (
    <div className="dashboard">
      {/* searchQuery 변경 시 이 모든 컴포넌트가 리렌더됨 */}
      <Sidebar />                          {/* 검색과 무관 */}
      <NotificationPanel />                {/* 검색과 무관 */}
      <StatsOverview />                    {/* 검색과 무관 — 무거운 차트 포함 */}
      <SearchInput
        value={searchQuery}
        onChange={setSearchQuery}
      />
      <SearchResults query={searchQuery} />
      <TabPanel
        activeTab={activeTab}
        onTabChange={setActiveTab}
      />
      <RecentActivity />                   {/* 검색과 무관 */}
    </div>
  );
}
```

## Correct

```tsx
// After: 상태를 사용하는 컴포넌트에 가까이 배치 — 리렌더 범위 격리
function DashboardPage() {
  return (
    <div className="dashboard">
      <Sidebar />
      <NotificationPanel />
      <StatsOverview />
      {/* 검색 상태는 SearchSection 내부에 격리 */}
      <SearchSection />
      {/* 탭 상태는 TabSection 내부에 격리 */}
      <TabSection />
      <RecentActivity />
    </div>
  );
}

// 검색 관련 상태를 사용하는 가장 가까운 공통 부모
function SearchSection() {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <div>
      {/* searchQuery 변경 시 이 영역만 리렌더 */}
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <SearchResults query={searchQuery} />
    </div>
  );
}

// 탭 관련 상태를 사용하는 가장 가까운 공통 부모
function TabSection() {
  const [activeTab, setActiveTab] = useState('overview');

  return (
    <TabPanel activeTab={activeTab} onTabChange={setActiveTab} />
  );
}
```

```tsx
// 응용: 호버 상태도 해당 컴포넌트에 격리
// Bad — 부모에 호버 상태
function CardGrid() {
  const [hoveredId, setHoveredId] = useState<string | null>(null);
  return cards.map((card) => (
    <Card
      key={card.id}
      isHovered={hoveredId === card.id}
      onHover={() => setHoveredId(card.id)}
      onLeave={() => setHoveredId(null)}
    />
  ));
}

// Good — 각 카드가 자기 호버 상태 관리
function CardGrid() {
  return cards.map((card) => <Card key={card.id} data={card} />);
}

function Card({ data }: { data: CardData }) {
  const [isHovered, setIsHovered] = useState(false);
  return (
    <div
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      className={isHovered ? 'card--hovered' : 'card'}
    >
      {data.title}
    </div>
  );
}
```

## Why

React의 리렌더 규칙: **상태가 변경된 컴포넌트와 그 모든 하위 컴포넌트**가 리렌더된다. 상태가 높은 레벨에 있을수록 리렌더되는 트리가 커진다.

State Colocation은 상태를 실제로 필요로 하는 컴포넌트의 **가장 가까운 공통 부모**에 배치하는 원칙이다. 이렇게 하면:

1. **리렌더 범위 최소화**: 변경된 상태의 영향이 해당 서브트리에만 국한
2. **코드 응집도 증가**: 관련 상태와 UI가 한 곳에 모임
3. **디버깅 용이**: 어떤 상태 변경이 어떤 컴포넌트에 영향을 미치는지 명확

**정량적 효과:**
- 검색어 입력 시: 7개 컴포넌트 리렌더 → 2개 컴포넌트 리렌더 (70% 축소)
- StatsOverview(차트 렌더링 50ms)가 키 입력마다 리렌더되는 것 방지
- memo() 없이도 자연스러운 리렌더 최적화 달성

## References

- [State: A Component's Memory](https://react.dev/learn/state-a-components-memory)
- [Choosing the State Structure](https://react.dev/learn/choosing-the-state-structure)
- [Colocation by Kent C. Dodds](https://kentcdodds.com/blog/colocation)
