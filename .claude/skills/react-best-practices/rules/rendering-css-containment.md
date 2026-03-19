---
title: "CSS containment으로 리페인트 범위 제한"
id: rendering-css-containment
impact: MEDIUM
category: rendering-performance
impactDescription: "브라우저 레이아웃 계산 범위 제한 — 리페인트 비용 50-70% 감소"
tags: [react, nextjs, performance, css, containment, content-visibility]
---

# CSS containment으로 리페인트 범위 제한

> 브라우저는 DOM의 한 부분이 변경되면 관련된 넓은 범위의 레이아웃을 재계산한다. CSS containment을 적용하면 브라우저에게 "이 요소의 변경은 외부에 영향을 미치지 않음"을 알려주어 리페인트 범위를 제한한다.

## Incorrect

```tsx
// Before: containment 없음 — 채팅 메시지 추가 시 전체 페이지 레이아웃 재계산
function ChatPage() {
  return (
    <div className="flex h-screen">
      <aside className="w-64">
        <ChannelList />  {/* 채팅과 무관하지만 레이아웃 재계산 대상 */}
      </aside>
      <main className="flex-1 flex flex-col">
        <ChatHeader />
        {/* 새 메시지가 추가될 때마다 전체 페이지 레이아웃 재계산 */}
        <div className="flex-1 overflow-y-auto">
          {messages.map((msg) => (
            <div key={msg.id} className="p-4 border-b">
              <span className="font-bold">{msg.author}</span>
              <p>{msg.content}</p>
            </div>
          ))}
        </div>
        <ChatInput />
      </main>
    </div>
  );
}

// 장문 게시글 목록 — 뷰포트 밖 콘텐츠도 모두 레이아웃 계산
function BlogPostList({ posts }: { posts: BlogPost[] }) {
  return (
    <div>
      {posts.map((post) => (
        <article key={post.id} className="mb-8 p-6 border rounded-lg">
          <h2 className="text-2xl font-bold">{post.title}</h2>
          <p className="text-gray-600">{post.excerpt}</p>
          <div className="mt-4">{post.content}</div>  {/* 긴 콘텐츠 */}
        </article>
      ))}
    </div>
  );
}
```

## Correct

```tsx
// After: CSS containment으로 리페인트 범위 격리
function ChatPage() {
  return (
    <div className="flex h-screen">
      {/* 사이드바 — 채팅 영역 변경에 영향받지 않음 */}
      <aside className="w-64" style={{ contain: 'layout style paint' }}>
        <ChannelList />
      </aside>
      <main className="flex-1 flex flex-col">
        <ChatHeader />
        {/* 메시지 영역 — 이 안의 변경이 외부로 전파되지 않음 */}
        <div
          className="flex-1 overflow-y-auto"
          style={{ contain: 'layout style paint' }}
        >
          {messages.map((msg) => (
            <div key={msg.id} className="p-4 border-b">
              <span className="font-bold">{msg.author}</span>
              <p>{msg.content}</p>
            </div>
          ))}
        </div>
        <ChatInput />
      </main>
    </div>
  );
}

// content-visibility: auto — 뷰포트 밖 콘텐츠의 렌더링을 완전히 건너뜀
function BlogPostList({ posts }: { posts: BlogPost[] }) {
  return (
    <div>
      {posts.map((post) => (
        <article
          key={post.id}
          className="mb-8 p-6 border rounded-lg"
          style={{
            contentVisibility: 'auto',             // 뷰포트 밖이면 렌더 스킵
            containIntrinsicSize: '0 500px',       // 예상 높이 — CLS 방지
          }}
        >
          <h2 className="text-2xl font-bold">{post.title}</h2>
          <p className="text-gray-600">{post.excerpt}</p>
          <div className="mt-4">{post.content}</div>
        </article>
      ))}
    </div>
  );
}
```

```tsx
// Tailwind CSS에서 사용 — 커스텀 유틸리티 추가
// globals.css
/* @layer utilities {
  .contain-layout {
    contain: layout;
  }
  .contain-paint {
    contain: layout style paint;
  }
  .contain-strict {
    contain: strict;
  }
  .content-auto {
    content-visibility: auto;
    contain-intrinsic-size: 0 500px;
  }
} */

// 컴포넌트에서 활용
function DashboardWidget({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="contain-paint rounded-lg border p-4">
      <h3 className="font-semibold mb-2">{title}</h3>
      {children}
    </div>
  );
}

function Dashboard() {
  return (
    <div className="grid grid-cols-3 gap-4">
      {/* 각 위젯의 업데이트가 다른 위젯에 영향 없음 */}
      <DashboardWidget title="매출">
        <RevenueChart />  {/* 차트 업데이트가 옆 위젯에 영향 없음 */}
      </DashboardWidget>
      <DashboardWidget title="사용자">
        <UserStats />
      </DashboardWidget>
      <DashboardWidget title="주문">
        <OrderTable />
      </DashboardWidget>
    </div>
  );
}
```

## Why

브라우저의 렌더링 파이프라인: **Style → Layout → Paint → Composite**

기본적으로 DOM의 한 요소가 변경되면 브라우저는 관련된 넓은 범위의 레이아웃을 재계산한다. CSS containment은 브라우저에게 최적화 힌트를 제공한다:

- **`contain: layout`**: 이 요소의 내부 레이아웃은 외부에 영향을 미치지 않음
- **`contain: paint`**: 이 요소의 콘텐츠는 경계 박스 밖으로 그려지지 않음
- **`contain: style`**: 이 요소의 CSS 카운터/quotes가 외부에 영향을 미치지 않음
- **`content-visibility: auto`**: 뷰포트 밖이면 렌더링 자체를 건너뜀 (가장 강력)

**정량적 효과:**
- `contain: layout style paint`: 해당 요소 내부 변경 시 리페인트 범위 50-70% 감소
- `content-visibility: auto`: 100개 블로그 포스트 → 뷰포트 밖 90개의 렌더링 건너뜀 — 초기 렌더 시간 7x 단축 (Chrome 기준)
- 대시보드 위젯 업데이트: 해당 위젯만 리페인트 (인접 위젯 보호)
- DevTools Performance 탭에서 "Recalculate Style", "Layout" 시간 감소 확인

## References

- [MDN — CSS Containment](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_containment)
- [MDN — content-visibility](https://developer.mozilla.org/en-US/docs/Web/CSS/content-visibility)
- [Web.dev — content-visibility: the new CSS property that boosts your rendering performance](https://web.dev/articles/content-visibility)
