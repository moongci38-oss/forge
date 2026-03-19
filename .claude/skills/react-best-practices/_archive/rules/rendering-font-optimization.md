---
title: "next/font로 폰트 최적화 — FOUT/FOIT 방지"
id: rendering-font-optimization
impact: MEDIUM
category: rendering-performance
impactDescription: "CLS 0으로 폰트 깜빡임 제거 — 셀프 호스팅으로 외부 요청 제거"
tags: [react, nextjs, performance, font, cls, core-web-vitals]
---

# next/font로 폰트 최적화 — FOUT/FOIT 방지

> 외부 폰트 CDN(Google Fonts 등)을 link 태그로 로드하면 FOUT(Flash of Unstyled Text) 또는 FOIT(Flash of Invisible Text)가 발생한다. next/font는 빌드 타임에 폰트를 셀프 호스팅하여 외부 요청을 제거한다.

## Incorrect

```tsx
// Before: Google Fonts를 외부 CDN에서 로드
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <head>
        {/* 외부 DNS 조회 + CSS 다운로드 + 폰트 파일 다운로드 = 3단 워터폴 */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link
          href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap"
          rel="stylesheet"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style={{ fontFamily: '"Noto Sans KR", "Inter", sans-serif' }}>
        {/* 폰트 로드 전: 시스템 폰트로 표시 → 폰트 도착 후 전환 → CLS 발생 */}
        {children}
      </body>
    </html>
  );
}
```

## Correct

```tsx
// After: next/font로 빌드 타임 셀프 호스팅
// app/layout.tsx
import { Noto_Sans_KR } from 'next/font/google';
import { Inter } from 'next/font/google';

// 빌드 타임에 Google Fonts에서 다운로드 → .next/static/media/ 에 셀프 호스팅
const notoSansKR = Noto_Sans_KR({
  subsets: ['latin'],
  weight: ['400', '500', '700'],
  display: 'swap',          // 폰트 로드 전 시스템 폰트 표시 (FOIT 방지)
  preload: true,             // <link rel="preload"> 자동 삽입
  variable: '--font-noto',   // CSS 변수로 사용 가능
});

const inter = Inter({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  display: 'swap',
  variable: '--font-inter',
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    // CSS 변수가 html 요소에 적용됨
    <html lang="ko" className={`${notoSansKR.variable} ${inter.variable}`}>
      <body className={notoSansKR.className}>
        {/* 폰트가 .next/static/ 에서 로드 — 외부 요청 제로 */}
        {/* CSS 변수로 Tailwind에서 사용 가능 */}
        {children}
      </body>
    </html>
  );
}
```

```tsx
// Tailwind CSS에서 폰트 변수 사용 — tailwind.config.ts
import type { Config } from 'tailwindcss';

const config: Config = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['var(--font-noto)', 'system-ui', 'sans-serif'],
        display: ['var(--font-inter)', 'system-ui', 'sans-serif'],
      },
    },
  },
};

export default config;
```

```tsx
// 로컬 폰트 파일 사용 시
import localFont from 'next/font/local';

const pretendard = localFont({
  src: [
    { path: '../public/fonts/Pretendard-Regular.woff2', weight: '400' },
    { path: '../public/fonts/Pretendard-Medium.woff2', weight: '500' },
    { path: '../public/fonts/Pretendard-Bold.woff2', weight: '700' },
  ],
  display: 'swap',
  variable: '--font-pretendard',
});
```

## Why

외부 폰트 CDN 로드 시 발생하는 문제:

1. **네트워크 워터폴**: DNS 조회(~100ms) → CSS 다운로드(~100ms) → 폰트 파일 다운로드(~200ms) = ~400ms 추가 블로킹
2. **FOUT**: 시스템 폰트 → 웹 폰트로 전환 시 텍스트 깜빡임 + 레이아웃 시프트
3. **FOIT**: `font-display: block` 시 폰트 로드 전 텍스트가 보이지 않음
4. **프라이버시**: 사용자의 IP가 Google 서버로 전송됨

next/font의 최적화:
- **빌드 타임 다운로드**: Google Fonts에서 빌드 시 다운로드 → `.next/static/media/`에 셀프 호스팅
- **CSS 인라인**: `@font-face` 선언이 HTML에 인라인됨 — 추가 CSS 요청 없음
- **preload 자동**: `<link rel="preload" as="font">` 자동 삽입
- **size-adjust**: 시스템 폰트와 웹 폰트의 크기 차이를 보정하여 CLS 0 달성

**정량적 효과:**
- 외부 요청: 3개(DNS + CSS + Font) → 0개 (셀프 호스팅)
- 폰트 로드 시간: ~400ms → ~50ms (같은 도메인에서 로드)
- CLS: size-adjust로 폰트 전환 시 레이아웃 시프트 0
- GDPR 준수: Google 서버로의 사용자 데이터 전송 제거

## References

- [Next.js Font 최적화](https://nextjs.org/docs/app/building-your-application/optimizing/fonts)
- [next/font API Reference](https://nextjs.org/docs/app/api-reference/components/font)
- [Web.dev — Best practices for fonts](https://web.dev/articles/font-best-practices)
