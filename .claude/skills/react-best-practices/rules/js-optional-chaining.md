---
title: "안전한 프로퍼티 접근 — optional chaining 활용"
id: js-optional-chaining
impact: LOW
category: javascript-performance
impactDescription: "null 체크 보일러플레이트 80% 감소 — 안전한 접근"
tags: [react, javascript, typescript, optional-chaining, null-safety]
---

# 안전한 프로퍼티 접근 — optional chaining 활용

> 중첩 객체 접근 시 수동 null 체크 대신 optional chaining(`?.`)과 nullish coalescing(`??`)을 활용하여 안전하고 간결한 코드를 작성한다.

## Incorrect

```tsx
// Before: 수동 null 체크 체인 — 보일러플레이트 과다
'use client';

interface ApiResponse {
  data?: {
    user?: {
      profile?: {
        address?: {
          city?: string;
          zipCode?: string;
        };
        preferences?: {
          theme?: string;
          language?: string;
          notifications?: {
            email?: boolean;
            push?: boolean;
          };
        };
      };
      posts?: Array<{
        title?: string;
        metadata?: {
          tags?: string[];
        };
      }>;
    };
  };
}

function UserProfile({ response }: { response: ApiResponse }) {
  // 매 레벨마다 null 체크 — 코드 줄 수와 복잡도 급증
  let city = '미지정';
  if (
    response &&
    response.data &&
    response.data.user &&
    response.data.user.profile &&
    response.data.user.profile.address &&
    response.data.user.profile.address.city
  ) {
    city = response.data.user.profile.address.city;
  }

  let theme = 'light';
  if (
    response &&
    response.data &&
    response.data.user &&
    response.data.user.profile &&
    response.data.user.profile.preferences &&
    response.data.user.profile.preferences.theme
  ) {
    theme = response.data.user.profile.preferences.theme;
  }

  // 배열 접근도 매번 존재 확인 필요
  let firstPostTitle = '게시글 없음';
  if (
    response &&
    response.data &&
    response.data.user &&
    response.data.user.posts &&
    response.data.user.posts.length > 0 &&
    response.data.user.posts[0].title
  ) {
    firstPostTitle = response.data.user.posts[0].title;
  }

  let firstPostTags: string[] = [];
  if (
    response &&
    response.data &&
    response.data.user &&
    response.data.user.posts &&
    response.data.user.posts[0] &&
    response.data.user.posts[0].metadata &&
    response.data.user.posts[0].metadata.tags
  ) {
    firstPostTags = response.data.user.posts[0].metadata.tags;
  }

  return (
    <div>
      <p>도시: {city}</p>
      <p>테마: {theme}</p>
      <p>첫 게시글: {firstPostTitle}</p>
      <p>태그: {firstPostTags.join(', ')}</p>
    </div>
  );
}
```

## Correct

```tsx
// After: optional chaining + nullish coalescing으로 간결하게
'use client';

function UserProfile({ response }: { response: ApiResponse }) {
  // ?. 체인으로 안전 접근, ?? 로 기본값 설정
  const city = response.data?.user?.profile?.address?.city ?? '미지정';
  const theme = response.data?.user?.profile?.preferences?.theme ?? 'light';
  const firstPostTitle = response.data?.user?.posts?.[0]?.title ?? '게시글 없음';
  const firstPostTags = response.data?.user?.posts?.[0]?.metadata?.tags ?? [];

  // 메서드 호출도 안전하게
  const emailEnabled =
    response.data?.user?.profile?.preferences?.notifications?.email ?? false;

  // 조건부 메서드 실행
  const tagCount = firstPostTags?.length ?? 0;

  return (
    <div>
      <p>도시: {city}</p>
      <p>테마: {theme}</p>
      <p>첫 게시글: {firstPostTitle}</p>
      <p>태그 ({tagCount}): {firstPostTags.join(', ')}</p>
      {emailEnabled && <p>이메일 알림 활성</p>}
    </div>
  );
}
```

```tsx
// 실전: API 응답 파싱 유틸리티
function parseApiResponse(response: ApiResponse) {
  const user = response.data?.user;

  return {
    // 기본 프로필
    displayName: user?.profile?.address?.city ?? 'Unknown',

    // 설정 — || 대신 ?? 사용 (0, '', false도 유효한 값)
    fontSize: user?.profile?.preferences?.fontSize ?? 16,    // 0이 유효
    nickname: user?.profile?.preferences?.nickname ?? '익명', // ''이 유효할 수 있음

    // 배열 안전 접근 + 변환
    recentTags: user?.posts
      ?.flatMap((post) => post.metadata?.tags ?? [])
      ?.slice(0, 10) ?? [],

    // 함수 호출 안전 처리
    formattedDate: user?.profile?.createdAt
      ? new Intl.DateTimeFormat('ko-KR').format(new Date(user.profile.createdAt))
      : '날짜 없음',
  };
}
```

## Why

수동 null 체크는 중첩이 깊어질수록 코드가 기하급수적으로 복잡해진다. Optional chaining(`?.`)은 체인 중 `null`이나 `undefined`를 만나면 즉시 `undefined`를 반환하므로 에러 없이 안전하게 접근할 수 있다. Nullish coalescing(`??`)은 `||`과 달리 `null`/`undefined`만 기본값으로 대체하므로 `0`, `''`, `false`를 유효한 값으로 유지한다.

**정량적 효과:**
- null 체크 보일러플레이트: 6-8줄 → 1줄 (80% 감소)
- TypeError 런타임 에러 방지: "Cannot read property of undefined" 제거
- `??` vs `||`: falsy 값(0, '', false) 보존 — 미묘한 버그 방지
- TypeScript 타입 추론: optional chaining과 완벽 호환 — 자동 타입 좁히기

## References

- [MDN: Optional chaining](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining)
- [MDN: Nullish coalescing](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Nullish_coalescing)
- [TypeScript: Optional Chaining](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#optional-chaining)
