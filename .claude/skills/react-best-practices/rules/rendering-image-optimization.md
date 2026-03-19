---
title: "next/image + 반응형 sizes + priority 설정"
id: rendering-image-optimization
impact: MEDIUM
category: rendering-performance
impactDescription: "이미지 최적화 자동 — LCP 이미지 50% 로딩 개선"
tags: [react, nextjs, performance, image, core-web-vitals, lcp]
---

# next/image + 반응형 sizes + priority 설정

> 일반 `<img>` 태그는 최적화 없이 원본 이미지를 로드하여 페이지 성능을 저하시킨다. next/image는 자동 WebP 변환, 반응형 srcset, lazy loading, placeholder를 제공한다.

## Incorrect

```tsx
// Before: 일반 img 태그 — 최적화 없음
function HeroSection() {
  return (
    <section>
      {/* 원본 4K 이미지(5MB)를 모바일에서도 그대로 로드 */}
      <img src="/images/hero-banner.png" alt="히어로 배너" />
    </section>
  );
}

function ProductGallery({ products }: { products: Product[] }) {
  return (
    <div className="grid grid-cols-4 gap-4">
      {products.map((product) => (
        <div key={product.id}>
          {/* sizes 없음 — 뷰포트 전체 너비 기준으로 이미지 로드 */}
          {/* lazy loading 없음 — 스크롤 아래 이미지도 즉시 로드 */}
          {/* width/height 없음 — CLS(레이아웃 시프트) 발생 */}
          <img src={product.imageUrl} alt={product.name} />
          <h3>{product.name}</h3>
        </div>
      ))}
    </div>
  );
}
```

## Correct

```tsx
// After: next/image로 자동 최적화
import Image from 'next/image';

function HeroSection() {
  return (
    <section className="relative h-[60vh]">
      {/* priority: LCP(Largest Contentful Paint) 대상 이미지 — preload 힌트 자동 삽입 */}
      {/* sizes: 뷰포트 크기별 실제 표시 크기 — 정확한 srcset 선택 */}
      <Image
        src="/images/hero-banner.png"
        alt="히어로 배너"
        fill
        sizes="100vw"
        priority  // LCP 이미지 — lazy loading 비활성화 + preload
        className="object-cover"
        placeholder="blur"
        blurDataURL="data:image/jpeg;base64,/9j/4AAQSkZJRg..."  // 저해상도 프리뷰
      />
    </section>
  );
}

function ProductGallery({ products }: { products: Product[] }) {
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      {products.map((product) => (
        <div key={product.id}>
          <div className="relative aspect-square">
            <Image
              src={product.imageUrl}
              alt={product.name}
              fill
              // sizes: 뷰포트별 이미지 표시 너비 — 적절한 해상도 선택
              // lg(1024px+): 4열 → 25vw, md(768px+): 3열 → 33vw, 그 외: 2열 → 50vw
              sizes="(min-width: 1024px) 25vw, (min-width: 768px) 33vw, 50vw"
              className="object-cover rounded-lg"
              // 기본 lazy loading — 뷰포트 근처까지 스크롤해야 로드
            />
          </div>
          <h3 className="mt-2">{product.name}</h3>
        </div>
      ))}
    </div>
  );
}
```

```tsx
// 외부 이미지 도메인 설정 — next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
        pathname: '/images/**',
      },
    ],
    // 생성할 srcset 크기 지정 (기본값 사용 가능)
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    formats: ['image/avif', 'image/webp'], // AVIF 우선, WebP 폴백
  },
};

export default nextConfig;
```

## Why

`<img>` 태그의 문제:
1. **원본 크기 전송**: 모바일에서 4K 이미지를 불필요하게 다운로드
2. **포맷 미최적화**: PNG/JPEG 대신 WebP/AVIF로 40-60% 용량 절감 가능
3. **CLS 발생**: width/height 없으면 이미지 로드 후 레이아웃이 밀림
4. **모든 이미지 즉시 로드**: 스크롤 아래 이미지도 초기 로드에 포함

next/image가 자동 처리하는 것:
- **srcset 생성**: sizes 속성 기반으로 적절한 해상도 선택
- **포맷 변환**: 브라우저 지원에 따라 AVIF > WebP > 원본 순서
- **lazy loading**: 뷰포트 근처까지 스크롤해야 로드 (priority 제외)
- **크기 예약**: width/height 또는 fill로 CLS 방지

**정량적 효과:**
- LCP 이미지: priority + preload로 로딩 시간 50% 개선
- 이미지 용량: PNG 1MB → WebP 200KB (80% 감소)
- CLS 스코어: 이미지 크기 예약으로 CLS 0 달성
- 초기 로드 데이터: lazy loading으로 below-the-fold 이미지 로드 제거

## References

- [Next.js Image 최적화](https://nextjs.org/docs/app/building-your-application/optimizing/images)
- [next/image API Reference](https://nextjs.org/docs/app/api-reference/components/image)
- [Web.dev — Optimize images](https://web.dev/articles/fast#optimize_your_images)
