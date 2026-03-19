---
title: "뷰포트 진입 시점에 로드 — IntersectionObserver 활용"
id: rendering-intersection-observer
impact: MEDIUM
category: rendering-performance
impactDescription: "초기 로드 리소스 60-80% 감소 — 보이는 콘텐츠만 로드"
tags: [react, nextjs, performance, lazy-loading, intersection-observer]
---

# 뷰포트 진입 시점에 로드 — IntersectionObserver 활용

> 페이지 로드 시 모든 이미지, 비디오, 무거운 컴포넌트를 한 번에 로드하면 초기 로드 시간이 증가한다. IntersectionObserver로 뷰포트에 진입할 때만 로드하면 초기 리소스를 크게 줄일 수 있다.

## Incorrect

```tsx
// Before: 페이지의 모든 섹션이 초기 로드 시 한 번에 렌더/로드
function LandingPage() {
  return (
    <div>
      <HeroSection />
      {/* 스크롤해야 보이는 영역인데 초기 로드에 모두 포함 */}
      <FeatureShowcase />           {/* 무거운 애니메이션 라이브러리 */}
      <TestimonialsCarousel />      {/* 고객 후기 + 이미지 20장 */}
      <PricingTable />
      <InteractiveDemo />           {/* 별도 번들 + API 호출 */}
      <BlogPreview />               {/* 최신 글 6개 + 썸네일 */}
      <ContactForm />
      <Footer />
    </div>
  );
}

// 이미지 갤러리 — 모든 이미지를 한 번에 로드
function ImageGallery({ images }: { images: string[] }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {images.map((src, i) => (
        // 50개 이미지가 페이지 로드 시 동시에 요청됨
        <img key={i} src={src} alt={`Gallery ${i}`} className="w-full" />
      ))}
    </div>
  );
}
```

## Correct

```tsx
// After: IntersectionObserver 기반 커스텀 훅으로 뷰포트 진입 감지
import { useRef, useState, useEffect, type ReactNode } from 'react';

function useInView(options?: IntersectionObserverInit) {
  const ref = useRef<HTMLDivElement>(null);
  const [isInView, setIsInView] = useState(false);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) {
        setIsInView(true);
        // 한 번 보이면 더 이상 관찰 불필요
        observer.unobserve(element);
      }
    }, {
      rootMargin: '200px', // 뷰포트 200px 전에 미리 로드 시작
      ...options,
    });

    observer.observe(element);
    return () => observer.disconnect();
  }, [options]);

  return { ref, isInView };
}

// 뷰포트 진입 시에만 렌더하는 래퍼 컴포넌트
function LazySection({
  children,
  fallback,
  className,
}: {
  children: ReactNode;
  fallback?: ReactNode;
  className?: string;
}) {
  const { ref, isInView } = useInView();

  return (
    <div ref={ref} className={className}>
      {isInView ? children : (fallback ?? <div className="min-h-[400px]" />)}
    </div>
  );
}

function LandingPage() {
  return (
    <div>
      {/* 히어로는 즉시 렌더 (Above the fold) */}
      <HeroSection />

      {/* 스크롤 시 순차적으로 로드 */}
      <LazySection fallback={<FeatureShowcaseSkeleton />}>
        <FeatureShowcase />
      </LazySection>

      <LazySection fallback={<TestimonialsSkeleton />}>
        <TestimonialsCarousel />
      </LazySection>

      <LazySection>
        <PricingTable />
      </LazySection>

      {/* 무거운 컴포넌트는 dynamic import와 결합 */}
      <LazySection fallback={<DemoSkeleton />}>
        <DynamicInteractiveDemo />
      </LazySection>

      <LazySection>
        <BlogPreview />
      </LazySection>

      <ContactForm />
      <Footer />
    </div>
  );
}

// dynamic import — 뷰포트 진입 시에만 JS 번들 로드
import dynamic from 'next/dynamic';

const DynamicInteractiveDemo = dynamic(
  () => import('@/components/InteractiveDemo'),
  {
    loading: () => <DemoSkeleton />,
    ssr: false, // 클라이언트에서만 로드
  },
);
```

```tsx
// 이미지 갤러리 — 뷰포트 진입 시 로드 (next/image는 자동 lazy)
import Image from 'next/image';

function ImageGallery({ images }: { images: GalleryImage[] }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {images.map((image) => (
        <div key={image.id} className="relative aspect-square">
          {/* next/image는 기본적으로 lazy loading — 뷰포트 근처에서 로드 */}
          <Image
            src={image.url}
            alt={image.alt}
            fill
            sizes="(min-width: 768px) 33vw, 100vw"
            className="object-cover rounded-lg"
          />
        </div>
      ))}
    </div>
  );
}

// 일반 img 태그 사용 시 — loading="lazy" 속성 활용
function SimpleGallery({ images }: { images: string[] }) {
  return (
    <div className="grid grid-cols-3 gap-4">
      {images.map((src, i) => (
        <img
          key={i}
          src={src}
          alt={`Gallery ${i}`}
          loading="lazy"       // 브라우저 네이티브 lazy loading
          decoding="async"     // 메인 스레드 블로킹 방지
          className="w-full aspect-square object-cover"
        />
      ))}
    </div>
  );
}
```

## Why

초기 페이지 로드 시 뷰포트에 보이지 않는 콘텐츠까지 로드하는 것은 리소스 낭비이다:

1. **네트워크 대역폭**: 보이지 않는 이미지 50장이 초기 로드에 포함
2. **JavaScript 번들**: 스크롤해야 보이는 대화형 컴포넌트의 JS가 초기 번들에 포함
3. **메인 스레드**: 모든 컴포넌트의 초기 렌더가 동시에 실행

IntersectionObserver는 브라우저가 네이티브로 제공하는 고성능 뷰포트 감지 API이다. 스크롤 이벤트와 달리 메인 스레드를 블로킹하지 않는다.

`rootMargin: '200px'`은 뷰포트에 도달하기 200px 전에 미리 로드를 시작하여, 사용자가 스크롤할 때 콘텐츠가 이미 준비되어 있게 한다.

**정량적 효과:**
- 초기 HTTP 요청: 60개 → 15개 (이미지 + JS 번들 포함, 60-80% 감소)
- 초기 전송 데이터: 5MB → 1.2MB (below-the-fold 리소스 제거)
- Time to Interactive(TTI): 메인 스레드 여유로 1-3초 개선
- `rootMargin` 200px로 빠른 스크롤 시에도 콘텐츠 미리 로드

## References

- [MDN — IntersectionObserver](https://developer.mozilla.org/en-US/docs/Web/API/IntersectionObserver)
- [Next.js Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)
- [Web.dev — Lazy loading images](https://web.dev/articles/lazy-loading-images)
