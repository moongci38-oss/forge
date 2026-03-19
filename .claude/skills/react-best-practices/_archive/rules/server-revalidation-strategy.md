---
title: "캐시 무효화 전략 — time-based vs on-demand 적절 선택"
id: server-revalidation-strategy
impact: HIGH
category: server-side-performance
impactDescription: "불필요한 재검증 70% 감소 — 서버 부하 및 응답시간 개선"
tags: [react, nextjs, cache, revalidation, isr]
---

# 캐시 무효화 전략 — time-based vs on-demand 적절 선택

> `revalidate: 0`(캐싱 비활성)을 모든 곳에 사용하면 SSR과 동일한 부하가 발생한다. 데이터 특성에 따라 time-based revalidation과 on-demand revalidation을 적절히 조합해야 한다.

## Incorrect

```tsx
// Before: 모든 fetch에 revalidate: 0 — 캐시를 전혀 활용하지 않음
// app/blog/page.tsx

// 방법 1: 페이지 레벨 no-cache
export const dynamic = 'force-dynamic'; // 모든 요청마다 서버 렌더링

export default async function BlogPage() {
  // 방법 2: 개별 fetch에 no-cache
  const posts = await fetch('https://api.example.com/posts', {
    cache: 'no-store', // 매번 API 호출 — 100 req/s면 100 API call/s
  });

  const categories = await fetch('https://api.example.com/categories', {
    cache: 'no-store', // 카테고리는 거의 안 바뀌는데 매번 호출
  });

  const siteConfig = await fetch('https://api.example.com/config', {
    cache: 'no-store', // 사이트 설정은 하루에 한 번 바뀌는데 매번 호출
  });

  return <BlogList posts={await posts.json()} />;
}
```

## Correct

```tsx
// After: 데이터 특성별 적절한 캐싱 전략 적용
// app/blog/page.tsx

export default async function BlogPage() {
  // 1. 거의 안 바뀌는 데이터 → 긴 TTL + 태그 기반 on-demand 무효화
  const siteConfig = await fetch('https://api.example.com/config', {
    next: { revalidate: 86400, tags: ['site-config'] }, // 24시간 TTL
  });

  // 2. 가끔 바뀌는 데이터 → 적절한 TTL
  const categories = await fetch('https://api.example.com/categories', {
    next: { revalidate: 3600, tags: ['categories'] }, // 1시간 TTL
  });

  // 3. 자주 바뀌는 데이터 → 짧은 TTL + on-demand 보완
  const posts = await fetch('https://api.example.com/posts', {
    next: { revalidate: 60, tags: ['posts'] }, // 1분 TTL
  });

  return (
    <BlogList
      posts={await posts.json()}
      categories={await categories.json()}
    />
  );
}
```

```tsx
// On-demand Revalidation: 데이터 변경 시 즉시 캐시 무효화
// app/actions/blog-actions.ts
'use server';

import { revalidateTag, revalidatePath } from 'next/cache';
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const CreatePostSchema = z.object({
  title: z.string().min(1).max(200),
  content: z.string().min(10),
  categoryId: z.string().uuid(),
});

export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) redirect('/login');

  const parsed = CreatePostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    categoryId: formData.get('categoryId'),
  });

  if (!parsed.success) {
    return { success: false, errors: parsed.error.flatten().fieldErrors };
  }

  await db.post.create({
    data: { ...parsed.data, authorId: session.user.id },
  });

  // 관련 캐시만 정밀 무효화 — 전체가 아닌 태그 기반
  revalidateTag('posts');               // 게시글 목록 캐시 무효화
  revalidatePath('/blog');              // 블로그 페이지 캐시 무효화
  // revalidateTag('categories')는 건드리지 않음 — 불필요한 재검증 방지

  return { success: true, errors: null };
}
```

```tsx
// 심화: 데이터 특성별 전략 가이드
// lib/cache-config.ts

export const CACHE_STRATEGIES = {
  // 정적 데이터: 거의 안 바뀜 → 긴 TTL + on-demand
  STATIC: { revalidate: 86400 },       // 24시간

  // 준정적 데이터: 하루 몇 번 변경 → 중간 TTL + on-demand
  SEMI_STATIC: { revalidate: 3600 },   // 1시간

  // 동적 데이터: 자주 변경 → 짧은 TTL + on-demand
  DYNAMIC: { revalidate: 60 },         // 1분

  // 실시간 데이터: 항상 최신 필요 → 캐시 없음
  REALTIME: { revalidate: 0 },         // 캐시 없음 (정말 필요한 경우만)
} as const;

// 사용 예시
const data = await fetch(url, {
  next: { ...CACHE_STRATEGIES.SEMI_STATIC, tags: ['my-data'] },
});
```

## Why

`revalidate: 0`이나 `cache: 'no-store'`를 기본값처럼 사용하면 Next.js의 핵심 이점인 자동 캐싱을 완전히 포기하게 된다. 모든 요청이 서버 렌더링을 트리거하므로 순수 SSR과 동일한 부하가 발생한다.

데이터는 변경 빈도에 따라 4가지 카테고리로 분류할 수 있다:

| 카테고리 | 변경 빈도 | 전략 | 예시 |
|---------|----------|------|------|
| 정적 | 거의 없음 | 긴 TTL (24h) + on-demand | 사이트 설정, 푸터 |
| 준정적 | 하루 몇 회 | 중간 TTL (1h) + on-demand | 카테고리, 메뉴 |
| 동적 | 분 단위 | 짧은 TTL (1m) + on-demand | 게시글 목록 |
| 실시간 | 초 단위 | revalidate: 0 | 주식 시세, 채팅 |

**정량적 효과:**
- 적절한 TTL 적용 시 원본 서버 요청 70-90% 감소
- TTFB: 캐시 히트 시 ~50ms vs 캐시 미스 시 ~500ms (10x 차이)
- on-demand revalidation으로 데이터 신선도 유지하면서 캐시 효율 극대화

## References

- [Next.js Caching: Revalidating](https://nextjs.org/docs/app/building-your-application/caching#revalidating)
- [Next.js revalidateTag](https://nextjs.org/docs/app/api-reference/functions/revalidateTag)
- [Next.js revalidatePath](https://nextjs.org/docs/app/api-reference/functions/revalidatePath)
- [Next.js ISR (Incremental Static Regeneration)](https://nextjs.org/docs/app/building-your-application/data-fetching/incremental-static-regeneration)
