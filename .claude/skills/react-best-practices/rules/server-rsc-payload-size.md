---
title: "RSC Payload 최소화 — 필요 데이터만 전달"
id: server-rsc-payload-size
impact: HIGH
category: server-side-performance
impactDescription: "RSC payload 크기 60-80% 감소 — hydration 속도 향상"
tags: [react, nextjs, rsc, payload, performance]
---

# RSC Payload 최소화 — 필요 데이터만 전달

> Server Component에서 Client Component로 데이터를 전달할 때, 전체 DB row 대신 필요한 필드만 선택하여 RSC Payload 크기를 최소화해야 한다.

## Incorrect

```tsx
// Before: 전체 DB row를 Client Component에 전달 — 불필요한 데이터가 RSC payload에 포함
// app/users/page.tsx (Server Component)
import { db } from '@/lib/db';
import { UserCard } from '@/components/UserCard';

export default async function UsersPage() {
  // 전체 User 객체 — password hash, internal notes, 대용량 필드 포함
  const users = await db.user.findMany({
    include: {
      profile: true,      // bio, avatar, socialLinks, metadata...
      settings: true,      // 알림 설정, 개인정보 설정...
      posts: true,         // 모든 게시글 전체 내용!
      loginHistory: true,  // 로그인 이력 전체!
    },
  });

  return (
    <div className="grid grid-cols-3 gap-4">
      {/* 전체 user 객체가 RSC payload로 직렬화되어 클라이언트로 전송 */}
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}

// components/UserCard.tsx (Client Component)
'use client';

// 실제로는 name, avatar, postCount만 사용하지만 전체 객체를 받음
export function UserCard({ user }: { user: User }) {
  return (
    <div onClick={() => console.log(user.id)}>
      <img src={user.profile.avatarUrl} alt={user.name} />
      <h3>{user.name}</h3>
      <p>{user.posts.length} posts</p>
    </div>
  );
}
```

## Correct

```tsx
// After: 필요 필드만 select + Client Component에 최소 데이터 전달
// app/users/page.tsx (Server Component)
import { db } from '@/lib/db';
import { UserCard } from '@/components/UserCard';

export default async function UsersPage() {
  // 필요한 필드만 select — DB 레벨에서 최적화
  const users = await db.user.findMany({
    select: {
      id: true,
      name: true,
      profile: {
        select: { avatarUrl: true },
      },
      _count: {
        select: { posts: true },
      },
    },
  });

  // Client Component에 전달할 최소 데이터만 매핑
  const userCards = users.map((user) => ({
    id: user.id,
    name: user.name,
    avatarUrl: user.profile?.avatarUrl ?? '/default-avatar.png',
    postCount: user._count.posts,
  }));

  return (
    <div className="grid grid-cols-3 gap-4">
      {userCards.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
}

// components/UserCard.tsx (Client Component)
'use client';

interface UserCardProps {
  user: {
    id: string;
    name: string;
    avatarUrl: string;
    postCount: number;
  };
}

// 명시적 인터페이스로 필요 데이터만 받음
export function UserCard({ user }: UserCardProps) {
  return (
    <div onClick={() => console.log(user.id)}>
      <img src={user.avatarUrl} alt={user.name} />
      <h3>{user.name}</h3>
      <p>{user.postCount} posts</p>
    </div>
  );
}
```

```tsx
// 심화: 서버에서만 사용하는 데이터는 Server Component에서 렌더링
// app/users/[id]/page.tsx (Server Component)
import { db } from '@/lib/db';
import { InteractiveSection } from '@/components/InteractiveSection';

export default async function UserDetailPage({
  params,
}: {
  params: { id: string };
}) {
  const user = await db.user.findUnique({
    where: { id: params.id },
    include: { profile: true, posts: { take: 5 } },
  });

  if (!user) return null;

  return (
    <div>
      {/* 서버에서만 렌더링 — RSC payload에 포함되지 않음 */}
      <h1>{user.name}</h1>
      <p>{user.profile?.bio}</p>
      <ul>
        {user.posts.map((post) => (
          <li key={post.id}>{post.title}</li>
        ))}
      </ul>

      {/* Client Component에는 인터랙션에 필요한 최소 데이터만 */}
      <InteractiveSection userId={user.id} userName={user.name} />
    </div>
  );
}
```

## Why

RSC Payload는 Server Component의 렌더링 결과를 클라이언트에 전송하는 직렬화된 데이터다. Client Component에 전달되는 props는 모두 이 payload에 포함된다. 전체 DB row를 전달하면:

1. **네트워크 비용**: 불필요한 데이터가 직렬화되어 전송량 증가
2. **파싱 비용**: 클라이언트에서 대용량 JSON 파싱으로 메인 스레드 블로킹
3. **보안 위험**: password hash, internal notes 등 민감 데이터 클라이언트 노출
4. **Hydration 지연**: payload가 클수록 hydration 완료 시간 증가

**정량적 효과:**
- 100명 유저 목록 기준: 전체 row 전달 ~500KB → 필요 필드만 ~50KB (90% 감소)
- 일반적인 케이스에서 RSC payload 60-80% 감소
- Hydration 시간 비례 단축 (payload 크기에 직접 비례)

## References

- [Next.js Server Components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)
- [React Server Components RFC: Serialization](https://github.com/reactjs/rfcs/blob/main/text/0188-server-components.md)
- [Prisma: Select Fields](https://www.prisma.io/docs/orm/prisma-client/queries/select-fields)
