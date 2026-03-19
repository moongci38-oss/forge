---
title: "Server Action 인증 필수 — 첫 줄 auth() 체크"
id: server-actions-auth
impact: HIGH
category: server-side-performance
impactDescription: "인증 우회 공격 방지 — 미인증 데이터 변경 100% 차단"
tags: [react, nextjs, server-actions, security, auth]
---

# Server Action 인증 필수 — 첫 줄 auth() 체크

> Server Action은 공개 HTTP 엔드포인트와 동일하다. 첫 줄에서 반드시 인증을 확인하고, 미인증 시 즉시 차단해야 한다.

## Incorrect

```tsx
// Before: 인증 없이 Server Action 직접 실행 — 누구나 호출 가능
// app/actions/update-profile.ts
'use server';

import { db } from '@/lib/db';

export async function updateProfile(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  // 인증 체크 없이 바로 DB 업데이트
  // 공격자가 직접 POST 요청으로 다른 사용자 데이터 변경 가능
  await db.user.update({
    where: { email },
    data: { name },
  });

  return { success: true };
}
```

## Correct

```tsx
// After: 첫 줄 auth() + 본인 확인 후 mutation 실행
// app/actions/update-profile.ts
'use server';

import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { redirect } from 'next/navigation';

export async function updateProfile(formData: FormData) {
  // 1. 첫 줄: 인증 확인
  const session = await auth();
  if (!session?.user) {
    redirect('/login');
  }

  const name = formData.get('name') as string;

  // 2. 본인 데이터만 수정 가능하도록 세션 ID 사용
  await db.user.update({
    where: { id: session.user.id },
    data: { name },
  });

  return { success: true };
}
```

```tsx
// 심화: 역할 기반 권한 체크
// app/actions/admin-actions.ts
'use server';

import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { redirect } from 'next/navigation';

export async function deleteUser(userId: string) {
  const session = await auth();
  if (!session?.user) {
    redirect('/login');
  }

  // 관리자 역할 확인
  if (session.user.role !== 'admin') {
    throw new Error('Unauthorized: Admin access required');
  }

  await db.user.delete({ where: { id: userId } });
  return { success: true };
}
```

## Why

Server Action은 `'use server'` 선언만으로 자동으로 POST 엔드포인트가 생성된다. 브라우저 개발자 도구나 curl로 누구나 직접 호출할 수 있으므로, **클라이언트 측 UI 숨김은 보안이 아니다**. 인증 체크가 없으면 IDOR(Insecure Direct Object Reference) 공격으로 타 사용자 데이터를 변경하거나 삭제할 수 있다.

**정량적 효과:**
- 미인증 mutation 시도 100% 차단
- IDOR 취약점 완전 방지 (세션 기반 소유권 검증)
- OWASP Top 10 A01:2021 Broken Access Control 대응

## References

- [Next.js Server Actions Security](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations#security)
- [Next.js Authentication](https://nextjs.org/docs/app/building-your-application/authentication)
- [OWASP Broken Access Control](https://owasp.org/Top10/A01_2021-Broken_Access_Control/)
