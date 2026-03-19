---
title: "무한 스크롤은 커서 기반 페이지네이션"
id: client-infinite-scroll
impact: HIGH
category: client-data-fetching
impactDescription: "대규모 데이터셋 일관된 성능 — offset 방식 대비 10x+ 빠름"
tags: [react, pagination, infinite-scroll, cursor, performance]
---

# 무한 스크롤은 커서 기반 페이지네이션

> Offset 기반 페이지네이션은 데이터가 많아질수록 성능이 급격히 저하된다. 커서 기반 페이지네이션은 데이터 규모에 관계없이 일관된 성능을 제공하며, 실시간 데이터 삽입/삭제 시에도 항목 누락이나 중복이 발생하지 않는다.

## Incorrect

```tsx
// Before: offset 기반 + useEffect로 무한 스크롤 — 성능 저하 + 항목 누락
// components/PostFeed.tsx
'use client';

import { useState, useEffect, useRef, useCallback } from 'react';

interface Post {
  id: string;
  title: string;
  content: string;
  createdAt: string;
}

export function PostFeed() {
  const [posts, setPosts] = useState<Post[]>([]);
  const [page, setPage] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const observerRef = useRef<IntersectionObserver | null>(null);

  const loadMore = useCallback(async () => {
    if (isLoading || !hasMore) return;
    setIsLoading(true);

    // offset 기반: 페이지가 깊어질수록 DB가 이전 모든 행을 스캔해야 함
    // page 100이면 OFFSET 2000 — DB가 2000개 행을 건너뛰어야 함
    const res = await fetch(`/api/posts?offset=${page * 20}&limit=20`);
    const newPosts = await res.json();

    // 새 게시글이 추가되면 offset이 밀려서 같은 항목이 중복 표시되거나
    // 삭제되면 한 항목을 건너뛰는 버그 발생
    setPosts((prev) => [...prev, ...newPosts]);
    setPage((prev) => prev + 1);
    setHasMore(newPosts.length === 20);
    setIsLoading(false);
  }, [page, isLoading, hasMore]);

  useEffect(() => {
    loadMore();
  }, []);  // eslint-disable-line — 의존성 관리 문제

  // IntersectionObserver 수동 관리
  const lastPostRef = useCallback(
    (node: HTMLDivElement | null) => {
      if (isLoading) return;
      if (observerRef.current) observerRef.current.disconnect();
      observerRef.current = new IntersectionObserver((entries) => {
        if (entries[0].isIntersecting && hasMore) {
          loadMore();
        }
      });
      if (node) observerRef.current.observe(node);
    },
    [isLoading, hasMore, loadMore]
  );

  return (
    <div>
      {posts.map((post, index) => (
        <div
          key={post.id}
          ref={index === posts.length - 1 ? lastPostRef : null}
        >
          <h3>{post.title}</h3>
          <p>{post.content}</p>
        </div>
      ))}
      {isLoading && <LoadingSpinner />}
    </div>
  );
}
```

## Correct

```tsx
// After: 커서 기반 + useSWRInfinite로 무한 스크롤 — 일관된 성능
// components/PostFeed.tsx
'use client';

import useSWRInfinite from 'swr/infinite';
import { useRef, useEffect, useCallback } from 'react';

interface Post {
  id: string;
  title: string;
  content: string;
  createdAt: string;
}

interface PostsResponse {
  posts: Post[];
  nextCursor: string | null; // 마지막 항목의 ID 또는 timestamp
}

// 커서 기반 키 생성 함수
function getKey(pageIndex: number, previousPageData: PostsResponse | null) {
  // 더 이상 데이터 없음
  if (previousPageData && !previousPageData.nextCursor) return null;

  // 첫 페이지
  if (pageIndex === 0) return '/api/posts?limit=20';

  // 이후 페이지 — 이전 페이지의 마지막 커서 사용
  return `/api/posts?cursor=${previousPageData!.nextCursor}&limit=20`;
}

export function PostFeed() {
  const { data, size, setSize, isLoading, isValidating } =
    useSWRInfinite<PostsResponse>(getKey, {
      revalidateFirstPage: false, // 새 페이지 로드 시 첫 페이지 재검증 방지
      revalidateOnFocus: false,   // 탭 전환 시 전체 재검증 방지
    });

  const posts = data?.flatMap((page) => page.posts) ?? [];
  const hasMore = data?.[data.length - 1]?.nextCursor != null;
  const isLoadingMore = isLoading || (size > 0 && !data?.[size - 1]);

  // IntersectionObserver로 마지막 항목 감지
  const sentinelRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!sentinelRef.current || !hasMore || isLoadingMore) return;

    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting) {
          setSize((prev) => prev + 1);
        }
      },
      { rootMargin: '200px' } // 200px 여유를 두고 미리 로드
    );

    observer.observe(sentinelRef.current);
    return () => observer.disconnect();
  }, [hasMore, isLoadingMore, setSize]);

  if (isLoading) return <FeedSkeleton />;

  return (
    <div>
      {posts.map((post) => (
        <article key={post.id}>
          <h3>{post.title}</h3>
          <p>{post.content}</p>
        </article>
      ))}

      {/* 스크롤 감지용 센티널 요소 */}
      {hasMore && (
        <div ref={sentinelRef}>
          {isLoadingMore && <LoadingSpinner />}
        </div>
      )}

      {!hasMore && posts.length > 0 && (
        <p className="text-center text-gray-500">모든 게시글을 불러왔습니다</p>
      )}
    </div>
  );
}
```

```tsx
// 서버 측: 커서 기반 API 엔드포인트
// app/api/posts/route.ts

import { db } from '@/lib/db';
import { z } from 'zod';

const QuerySchema = z.object({
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().min(1).max(100).default(20),
});

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const parsed = QuerySchema.safeParse({
    cursor: searchParams.get('cursor') ?? undefined,
    limit: searchParams.get('limit'),
  });

  if (!parsed.success) {
    return Response.json({ error: 'Invalid params' }, { status: 400 });
  }

  const { cursor, limit } = parsed.data;

  // 커서 기반 쿼리: WHERE id > cursor ORDER BY id LIMIT N
  // 데이터 규모에 관계없이 O(1) 인덱스 조회
  const posts = await db.post.findMany({
    where: cursor ? { id: { gt: cursor } } : undefined,
    orderBy: { createdAt: 'desc' },
    take: limit + 1, // 다음 페이지 존재 여부 확인용 +1
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
  });

  const hasMore = posts.length > limit;
  const results = hasMore ? posts.slice(0, limit) : posts;

  return Response.json({
    posts: results,
    nextCursor: hasMore ? results[results.length - 1].id : null,
  });
}
```

## Why

Offset 기반 페이지네이션(`OFFSET 2000 LIMIT 20`)은 DB가 2000개의 행을 스캔한 후 건너뛰어야 하므로, 데이터가 많아질수록 **선형적으로 느려진다**. 또한 스크롤 중 새 데이터가 삽입/삭제되면 offset이 밀려서 항목 중복이나 누락이 발생한다.

커서 기반 페이지네이션(`WHERE id > :cursor LIMIT 20`)은 인덱스를 직접 참조하므로 **데이터 규모에 관계없이 일관된 O(log N) 성능**을 제공한다.

| 방식 | 10만 건 쿼리 시간 | 100만 건 쿼리 시간 | 데이터 일관성 |
|------|:----------------:|:------------------:|:-----------:|
| Offset | ~50ms | ~500ms | 삽입/삭제 시 불일치 |
| Cursor | ~5ms | ~5ms | 항상 일관 |

**정량적 효과:**
- 대규모 데이터셋(100만+ 건) 쿼리: offset 대비 10-100x 빠름
- 실시간 데이터 변경 시 항목 누락/중복: offset 발생 vs cursor 발생하지 않음
- `rootMargin: '200px'`로 사전 로딩하여 스크롤 끊김 방지

## References

- [SWR Infinite Loading](https://swr.vercel.app/docs/pagination#infinite-loading)
- [Prisma: Cursor-based Pagination](https://www.prisma.io/docs/orm/prisma-client/queries/pagination#cursor-based-pagination)
- [Relay Cursor Connections Specification](https://relay.dev/graphql/connections.htm)
- [IntersectionObserver API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)
