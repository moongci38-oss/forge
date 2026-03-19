---
title: "Suspense 경계로 스트리밍 SSR 활용"
id: async-suspense-streaming
impact: CRITICAL
category: eliminating-waterfalls
impactDescription: "체감 로딩 시간 60-80% 단축 (LCP 개선)"
tags: [react, nextjs, performance, suspense, streaming, ssr]
---

# Suspense 경계로 스트리밍 SSR 활용

> 전체 페이지 데이터가 준비될 때까지 기다리지 말고, 빠른 부분을 먼저 보여주고 느린 부분을 스트리밍한다.

## Incorrect

```tsx
// Before: 전체 데이터 완료까지 빈 화면 — 가장 느린 fetch가 LCP 결정
// app/feed/page.tsx

async function FeedPage() {
  // 모든 데이터를 한 번에 로드
  const [user, feed, trending, ads] = await Promise.all([
    fetchUser(),              // 100ms
    fetchPersonalizedFeed(),  // 2000ms (느림 — ML 모델 추론)
    fetchTrending(),          // 800ms
    fetchAds(),               // 300ms
  ]);

  // 2000ms 후에야 전체 페이지가 한 번에 렌더링됨
  return (
    <div>
      <NavBar user={user} />
      <Feed items={feed} />
      <Sidebar>
        <TrendingSection items={trending} />
        <AdSection ads={ads} />
      </Sidebar>
    </div>
  );
}
```

## Correct

```tsx
// After: Suspense 경계로 독립 스트리밍 — 빠른 부분 즉시 표시
// app/feed/page.tsx

import { Suspense } from 'react';
import {
  FeedSkeleton,
  TrendingSkeleton,
  AdSkeleton,
} from '@/components/skeletons';

async function FeedPage() {
  // 빠른 데이터만 먼저 로드 (100ms)
  const user = await fetchUser();

  return (
    <div>
      {/* 100ms 후 즉시 표시 */}
      <NavBar user={user} />

      {/* 각 섹션이 독립적으로 스트리밍됨 */}
      <Suspense fallback={<FeedSkeleton />}>
        <PersonalizedFeed />
      </Suspense>

      <Sidebar>
        <Suspense fallback={<TrendingSkeleton />}>
          <TrendingSection />
        </Suspense>
        <Suspense fallback={<AdSkeleton />}>
          <AdSection />
        </Suspense>
      </Sidebar>
    </div>
  );
}

// 각 Server Component가 자체 데이터를 로드
async function PersonalizedFeed() {
  const feed = await fetchPersonalizedFeed(); // 2000ms
  return <Feed items={feed} />;
}

async function TrendingSection() {
  const trending = await fetchTrending(); // 800ms
  return <Trending items={trending} />;
}

async function AdSection() {
  const ads = await fetchAds(); // 300ms
  return <Ads ads={ads} />;
}
```

```tsx
// loading.tsx 활용 — 라우트 레벨 자동 Suspense
// app/feed/loading.tsx

export default function FeedLoading() {
  return (
    <div>
      <NavBarSkeleton />
      <FeedSkeleton />
      <SidebarSkeleton />
    </div>
  );
}

// 세분화된 Suspense와 loading.tsx 조합
// app/feed/page.tsx — loading.tsx가 전체 페이지 폴백 담당
//                     내부 Suspense가 개별 섹션 폴백 담당
```

```tsx
// 중첩 Suspense — 우선순위별 계층화
// app/article/[id]/page.tsx

async function ArticlePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  return (
    <article>
      {/* 최우선: 글 본문 (가장 빨리 표시해야 함) */}
      <Suspense fallback={<ArticleSkeleton />}>
        <ArticleContent id={id} />
      </Suspense>

      {/* 차순위: 관련 글 */}
      <Suspense fallback={<RelatedSkeleton />}>
        <RelatedArticles id={id} />
      </Suspense>

      {/* 낮은 순위: 댓글 (스크롤 아래) */}
      <Suspense fallback={<CommentsSkeleton />}>
        <Comments articleId={id} />
      </Suspense>
    </article>
  );
}
```

## Why

전통적 SSR은 모든 데이터가 준비된 후 HTML을 한 번에 전송한다. 가장 느린 API가 전체 페이지 로딩 시간을 결정한다. **Suspense 스트리밍 SSR**은 HTML을 청크 단위로 점진적으로 전송한다:

1. 서버가 빠른 부분의 HTML + Skeleton 폴백을 즉시 전송
2. 느린 데이터가 준비되면 해당 부분의 HTML을 추가 전송
3. 브라우저가 Skeleton을 실제 콘텐츠로 교체

**정량적 효과:**
- TTFB: 2000ms → 100ms (첫 의미 있는 콘텐츠까지의 시간)
- LCP: NavBar + Skeleton이 즉시 표시되므로 체감 로딩 60-80% 단축
- 사용자는 NavBar를 보고 페이지가 로딩 중임을 인지 → 이탈률 감소
- 각 Suspense 경계가 독립적이므로 하나가 실패해도 나머지는 정상 표시

**Suspense 배치 전략:**
- 빠른 데이터: Suspense 없이 직접 await (NavBar, Header 등)
- 중간 데이터: 개별 Suspense (300-1000ms)
- 느린 데이터: 반드시 Suspense (1000ms+)
- 뷰포트 하단: Suspense + lazy loading 조합

## References

- [React Suspense](https://react.dev/reference/react/Suspense)
- [Next.js Loading UI and Streaming](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)
- [Streaming Server Rendering](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming#streaming-with-suspense)
