---
title: "정적/경량 로직은 Edge Runtime 활용"
id: server-edge-runtime
impact: HIGH
category: server-side-performance
impactDescription: "Cold start 10x 빠름 (250ms -> 25ms) — 글로벌 저지연"
tags: [react, nextjs, edge, runtime, performance]
---

# 정적/경량 로직은 Edge Runtime 활용

> 리다이렉트, 리라이트, 인증 토큰 검증, A/B 테스트 분기 등 경량 로직은 Edge Runtime에서 실행하면 cold start가 10배 빨라진다. Node.js 전용 API가 필요 없는 경우 Edge를 우선 고려한다.

## Incorrect

```tsx
// Before: 단순 리다이렉트/인증 체크를 Node.js Runtime으로 실행
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// runtime을 지정하지 않음 — 기본 Node.js Runtime
// Cold start: ~250ms, 특정 리전에서만 실행
export function middleware(request: NextRequest) {
  const token = request.cookies.get('session-token')?.value;

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  return NextResponse.next();
}

// app/api/og/route.ts
// 단순 JSON 응답인데 Node.js Runtime 사용
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get('title') ?? 'Default Title';

  return Response.json({
    title,
    description: `Page about ${title}`,
    image: `https://og.example.com/${encodeURIComponent(title)}`,
  });
}
```

## Correct

```tsx
// After: 경량 로직은 Edge Runtime으로 실행
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { jwtVerify } from 'jose'; // Edge 호환 JWT 라이브러리

// Middleware는 기본적으로 Edge Runtime — 명시적 선언 권장
export const config = {
  matcher: ['/dashboard/:path*', '/api/protected/:path*'],
};

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('session-token')?.value;

  if (!token) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  try {
    // jose 라이브러리는 Edge Runtime에서 동작 (jsonwebtoken은 Node.js 전용)
    const secret = new TextEncoder().encode(process.env.JWT_SECRET);
    const { payload } = await jwtVerify(token, secret);

    // 검증된 사용자 정보를 헤더로 전달
    const response = NextResponse.next();
    response.headers.set('x-user-id', payload.sub as string);
    return response;
  } catch {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}
```

```tsx
// Edge Runtime API Route — 경량 응답에 적합
// app/api/og/route.ts
export const runtime = 'edge'; // 명시적 Edge Runtime 선언

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get('title') ?? 'Default Title';

  return Response.json(
    {
      title,
      description: `Page about ${title}`,
      image: `https://og.example.com/${encodeURIComponent(title)}`,
    },
    {
      headers: {
        'Cache-Control': 'public, s-maxage=3600, stale-while-revalidate=86400',
      },
    }
  );
}
```

```tsx
// Edge Runtime 페이지 — 지역화/A/B 테스트에 적합
// app/[locale]/page.tsx
export const runtime = 'edge';

export default async function LocalizedPage({
  params,
}: {
  params: { locale: string };
}) {
  // Edge에서 가까운 CDN에서 실행 — 글로벌 저지연
  const messages = await import(`@/messages/${params.locale}.json`);

  return (
    <main>
      <h1>{messages.hero.title}</h1>
      <p>{messages.hero.description}</p>
    </main>
  );
}
```

## Why

Next.js의 Edge Runtime은 V8 Isolate 기반으로, Node.js Runtime 대비 극적으로 빠른 cold start를 제공한다. 사용자에게 가장 가까운 CDN 엣지 노드에서 실행되므로 글로벌 사용자에게 일관된 저지연 응답을 제공한다.

**Edge Runtime 적합 케이스:**
- Middleware (리다이렉트, 리라이트, 인증 토큰 검증)
- 경량 API Route (JSON 응답, OG 이미지 메타데이터)
- 지역화/A/B 테스트 분기
- 정적 페이지 + 경량 동적 로직

**Edge Runtime 부적합 케이스 (Node.js 사용):**
- 파일 시스템 접근 (`fs` 모듈)
- 무거운 npm 패키지 (Prisma, sharp 등)
- 장시간 실행 프로세스 (10초+ 초과)
- Node.js 전용 API (child_process, crypto의 일부 등)

**정량적 효과:**
- Cold start: Node.js ~250ms → Edge ~25ms (10x 개선)
- 글로벌 P99 레이턴시: 200-500ms → 50-100ms (지역 무관)
- Vercel 기준 Edge Function은 Node.js Serverless 대비 비용 효율적

## References

- [Next.js Edge Runtime](https://nextjs.org/docs/app/building-your-application/rendering/edge-and-nodejs-runtimes)
- [Next.js Middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
- [Vercel Edge Functions](https://vercel.com/docs/functions/edge-functions)
- [jose: JWT for Edge Runtime](https://github.com/panva/jose)
