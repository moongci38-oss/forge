---
title: "동일 Fetch 중복 제거 — React.cache() 래핑"
id: server-cache-dedupe
impact: HIGH
category: server-side-performance
impactDescription: "동일 요청 중복 제거 — 데이터베이스 쿼리 50-80% 감소"
tags: [react, nextjs, cache, deduplication, performance]
---

# 동일 Fetch 중복 제거 — React.cache() 래핑

> 같은 데이터를 여러 Server Component에서 사용할 때, `React.cache()`로 래핑하면 단일 요청 내에서 자동으로 중복이 제거된다. 래핑 없이 호출하면 동일 쿼리가 컴포넌트 수만큼 반복 실행된다.

## Incorrect

```tsx
// Before: 같은 유저 데이터를 여러 컴포넌트에서 각각 fetch — DB 쿼리 중복
// lib/data.ts
import { db } from '@/lib/db';

export async function getUser(userId: string) {
  // 캐시 없음 — 호출될 때마다 DB 쿼리 실행
  return db.user.findUnique({
    where: { id: userId },
    include: { profile: true, settings: true },
  });
}

// app/dashboard/page.tsx
async function DashboardPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <Header userId={params.id} />      {/* getUser() 1번째 호출 */}
      <Sidebar userId={params.id} />     {/* getUser() 2번째 호출 */}
      <MainContent userId={params.id} /> {/* getUser() 3번째 호출 */}
      <Footer userId={params.id} />      {/* getUser() 4번째 호출 */}
    </div>
  );
}

// components/Header.tsx
async function Header({ userId }: { userId: string }) {
  const user = await getUser(userId); // DB 쿼리 실행
  return <header>{user?.name}</header>;
}

// components/Sidebar.tsx
async function Sidebar({ userId }: { userId: string }) {
  const user = await getUser(userId); // 같은 쿼리 또 실행
  return <aside>{user?.profile?.bio}</aside>;
}
```

## Correct

```tsx
// After: React.cache()로 요청 단위 자동 중복 제거
// lib/data.ts
import { cache } from 'react';
import { db } from '@/lib/db';

// React.cache()로 래핑 — 같은 인자로 호출하면 단일 요청 내 결과 재사용
export const getUser = cache(async (userId: string) => {
  return db.user.findUnique({
    where: { id: userId },
    include: { profile: true, settings: true },
  });
});

// app/dashboard/page.tsx
async function DashboardPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <Header userId={params.id} />      {/* DB 쿼리 1회 실행 */}
      <Sidebar userId={params.id} />     {/* 캐시 히트 — 쿼리 안 함 */}
      <MainContent userId={params.id} /> {/* 캐시 히트 — 쿼리 안 함 */}
      <Footer userId={params.id} />      {/* 캐시 히트 — 쿼리 안 함 */}
    </div>
  );
}

// 각 컴포넌트에서 자유롭게 getUser() 호출 — 중복 걱정 없음
async function Header({ userId }: { userId: string }) {
  const user = await getUser(userId); // 첫 호출만 DB 쿼리
  return <header>{user?.name}</header>;
}

async function Sidebar({ userId }: { userId: string }) {
  const user = await getUser(userId); // 캐시에서 즉시 반환
  return <aside>{user?.profile?.bio}</aside>;
}
```

```tsx
// 심화: unstable_cache()로 요청 간 캐싱 (다수 요청에 걸쳐 재사용)
// lib/data.ts
import { unstable_cache } from 'next/cache';
import { db } from '@/lib/db';

// 요청 간 캐싱 — 다른 사용자 요청도 캐시 히트
export const getPopularPosts = unstable_cache(
  async () => {
    return db.post.findMany({
      where: { isPublished: true },
      orderBy: { viewCount: 'desc' },
      take: 10,
    });
  },
  ['popular-posts'],           // 캐시 키
  { revalidate: 3600, tags: ['posts'] } // 1시간 TTL + 태그 기반 무효화
);
```

## Why

React Server Component 트리에서 같은 데이터 함수를 여러 컴포넌트가 호출하는 것은 매우 자연스러운 패턴이다. Props drilling을 피하고 각 컴포넌트가 자신에게 필요한 데이터를 직접 fetch하는 것이 RSC의 설계 의도다. 하지만 `React.cache()` 없이 이 패턴을 사용하면 동일 쿼리가 컴포넌트 수만큼 중복 실행된다.

`React.cache()`는 **단일 요청(렌더링) 범위**에서 동일 인자에 대한 결과를 자동 재사용한다. `unstable_cache()`는 **요청 간 캐싱**으로 여러 사용자 요청에 걸쳐 결과를 재사용한다.

**정량적 효과:**
- 4개 컴포넌트가 같은 데이터 사용 시: 쿼리 4회 → 1회 (75% 감소)
- 복잡한 레이아웃에서 중복 쿼리 평균 50-80% 감소
- DB 연결 풀 부하 비례 감소

## References

- [React cache()](https://react.dev/reference/react/cache)
- [Next.js Caching: Request Memoization](https://nextjs.org/docs/app/building-your-application/caching#request-memoization)
- [Next.js unstable_cache](https://nextjs.org/docs/app/api-reference/functions/unstable_cache)
