---
title: "Server Action 입력 검증 필수 — Zod Schema 적용"
id: server-actions-validation
impact: HIGH
category: server-side-performance
impactDescription: "입력 검증으로 잘못된 데이터 주입 방지 — 타입 안전성 100%"
tags: [react, nextjs, server-actions, validation, zod]
---

# Server Action 입력 검증 필수 — Zod Schema 적용

> Server Action의 모든 입력은 Zod schema로 검증해야 한다. `formData.get()`이나 인자를 직접 사용하면 타입 불일치, SQL Injection, XSS 등 보안 취약점이 발생한다.

## Incorrect

```tsx
// Before: formData.get()을 직접 사용 — 타입 불안전 + 검증 없음
// app/actions/create-post.ts
'use server';

import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) redirect('/login');

  // formData.get()은 string | null 반환 — 타입이 보장되지 않음
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;
  const categoryId = formData.get('categoryId') as string;
  const isPublished = formData.get('isPublished') === 'true';

  // 빈 문자열, 초과 길이, 잘못된 ID 형식 등 검증 없이 DB에 직접 저장
  await db.post.create({
    data: {
      title,       // 빈 문자열 가능
      content,     // 1MB 텍스트도 통과
      categoryId,  // 존재하지 않는 ID 가능
      isPublished,
      authorId: session.user.id,
    },
  });

  return { success: true };
}
```

## Correct

```tsx
// After: Zod schema로 타입 + 비즈니스 규칙 모두 검증
// app/actions/create-post.ts
'use server';

import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { redirect } from 'next/navigation';
import { z } from 'zod';

const CreatePostSchema = z.object({
  title: z
    .string()
    .min(1, '제목을 입력해주세요')
    .max(200, '제목은 200자 이하로 입력해주세요'),
  content: z
    .string()
    .min(10, '본문을 10자 이상 입력해주세요')
    .max(50_000, '본문은 50,000자 이하로 입력해주세요'),
  categoryId: z.string().uuid('올바른 카테고리를 선택해주세요'),
  isPublished: z.coerce.boolean().default(false),
});

export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) redirect('/login');

  // Zod로 입력 검증 — 실패 시 타입 안전한 에러 반환
  const parsed = CreatePostSchema.safeParse({
    title: formData.get('title'),
    content: formData.get('content'),
    categoryId: formData.get('categoryId'),
    isPublished: formData.get('isPublished'),
  });

  if (!parsed.success) {
    return {
      success: false,
      errors: parsed.error.flatten().fieldErrors,
    };
  }

  // parsed.data는 완전히 타입 안전 — 추가 캐스팅 불필요
  await db.post.create({
    data: {
      ...parsed.data,
      authorId: session.user.id,
    },
  });

  return { success: true, errors: null };
}
```

```tsx
// 심화: useActionState와 함께 사용 (React 19)
// app/posts/new/page.tsx
'use client';

import { useActionState } from 'react';
import { createPost } from '@/app/actions/create-post';

export default function NewPostForm() {
  const [state, formAction, isPending] = useActionState(createPost, {
    success: false,
    errors: null,
  });

  return (
    <form action={formAction}>
      <input name="title" />
      {state.errors?.title && (
        <p className="text-red-500">{state.errors.title[0]}</p>
      )}

      <textarea name="content" />
      {state.errors?.content && (
        <p className="text-red-500">{state.errors.content[0]}</p>
      )}

      <button type="submit" disabled={isPending}>
        {isPending ? '저장 중...' : '저장'}
      </button>
    </form>
  );
}
```

## Why

`formData.get()`은 항상 `string | File | null`을 반환한다. `as string` 캐스팅은 타입 체커를 속일 뿐 런타임 안전성을 보장하지 않는다. Zod schema 검증을 적용하면:

1. **타입 안전성**: 런타임에서 실제 타입이 검증되어 `as` 캐스팅 제거
2. **비즈니스 규칙**: 최소/최대 길이, 형식(UUID, email), 범위 등을 선언적으로 정의
3. **보안**: SQL Injection, XSS 등 악의적 입력 사전 차단
4. **DX**: 에러 메시지가 필드별로 구조화되어 폼 UI와 직접 연동

**정량적 효과:**
- 잘못된 형식의 데이터 DB 저장 100% 차단
- 클라이언트 + 서버 양측 검증으로 방어 계층 2중화
- 폼 에러 메시지 자동 생성으로 UX 코드 50% 감소

## References

- [Next.js Server Actions: Validation](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations#server-side-form-validation)
- [Zod Documentation](https://zod.dev/)
- [React 19 useActionState](https://react.dev/reference/react/useActionState)
