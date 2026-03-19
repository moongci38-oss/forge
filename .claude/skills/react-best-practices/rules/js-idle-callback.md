---
title: "비긴급 작업은 requestIdleCallback으로 지연"
id: js-idle-callback
impact: LOW
category: javascript-performance
impactDescription: "유휴 시간 활용 — 메인 스레드 차단 없이 작업 처리"
tags: [react, javascript, performance, idle-callback, scheduling]
---

# 비긴급 작업은 requestIdleCallback으로 지연

> 분석 전송, 프리페치, 비필수 DOM 업데이트 등 비긴급 작업은 requestIdleCallback으로 브라우저 유휴 시간에 실행한다.

## Incorrect

```tsx
// Before: 페이지 로드 직후 비긴급 작업 즉시 실행 — 초기 렌더링 블로킹
'use client';

import { useEffect } from 'react';

function ProductPage({ product }: { product: Product }) {
  useEffect(() => {
    // 페이지 로드와 동시에 비긴급 작업이 메인 스레드 차지
    // LCP, FID에 악영향

    // 1. 분석 이벤트 전송 (비긴급)
    trackPageView({ productId: product.id, category: product.category });

    // 2. 추천 상품 프리페치 (비긴급)
    fetch(`/api/recommendations/${product.id}`);

    // 3. 최근 본 상품 로컬 저장 (비긴급)
    const recentlyViewed = JSON.parse(
      localStorage.getItem('recentlyViewed') || '[]'
    );
    recentlyViewed.unshift(product.id);
    localStorage.setItem(
      'recentlyViewed',
      JSON.stringify(recentlyViewed.slice(0, 20))
    );

    // 4. A/B 테스트 플래그 동기화 (비긴급)
    syncFeatureFlags();
  }, [product]);

  return <div>{/* 상품 페이지 렌더링 */}</div>;
}
```

## Correct

```tsx
// After: 비긴급 작업을 requestIdleCallback으로 유휴 시간에 실행
'use client';

import { useEffect, useCallback } from 'react';

// requestIdleCallback 폴리필 (Safari 미지원)
const scheduleIdle =
  typeof requestIdleCallback !== 'undefined'
    ? requestIdleCallback
    : (cb: () => void) => setTimeout(cb, 1);

const cancelIdle =
  typeof cancelIdleCallback !== 'undefined'
    ? cancelIdleCallback
    : clearTimeout;

function ProductPage({ product }: { product: Product }) {
  useEffect(() => {
    const idleIds: number[] = [];

    // 비긴급 작업을 유휴 시간에 스케줄링
    // 브라우저가 렌더링/인터랙션 처리 후 여유 시간에 실행

    // 1. 분석 이벤트 — 가장 낮은 우선순위
    idleIds.push(
      scheduleIdle(
        () => {
          trackPageView({
            productId: product.id,
            category: product.category,
          });
        },
        { timeout: 5000 } // 최대 5초 내에는 실행 보장
      )
    );

    // 2. 추천 상품 프리페치 — 유휴 시간 활용
    idleIds.push(
      scheduleIdle(
        () => {
          fetch(`/api/recommendations/${product.id}`);
        },
        { timeout: 10000 }
      )
    );

    // 3. 로컬 스토리지 업데이트 — 유휴 시간
    idleIds.push(
      scheduleIdle(() => {
        try {
          const recentlyViewed = JSON.parse(
            localStorage.getItem('recentlyViewed') || '[]'
          );
          recentlyViewed.unshift(product.id);
          localStorage.setItem(
            'recentlyViewed',
            JSON.stringify(recentlyViewed.slice(0, 20))
          );
        } catch {
          // localStorage 접근 실패 무시
        }
      })
    );

    return () => idleIds.forEach(cancelIdle);
  }, [product]);

  return <div>{/* 상품 페이지 렌더링 */}</div>;
}
```

```tsx
// 고급: 유휴 시간에 대량 작업을 청크 단위로 처리
'use client';

import { useEffect, useRef } from 'react';

function useIdleChunkedWork<T>(
  items: T[],
  processItem: (item: T) => void,
  chunkSize = 5
) {
  const processedRef = useRef(0);

  useEffect(() => {
    processedRef.current = 0;

    function processChunk(deadline: IdleDeadline) {
      // 유휴 시간이 남아있고, 처리할 아이템이 있는 동안 계속 실행
      while (
        deadline.timeRemaining() > 1 && // 최소 1ms 여유
        processedRef.current < items.length
      ) {
        const end = Math.min(
          processedRef.current + chunkSize,
          items.length
        );

        for (let i = processedRef.current; i < end; i++) {
          processItem(items[i]);
        }

        processedRef.current = end;
      }

      // 아직 처리할 아이템이 남아있으면 다음 유휴 시간에 계속
      if (processedRef.current < items.length) {
        requestIdleCallback(processChunk);
      }
    }

    const id = requestIdleCallback(processChunk);
    return () => cancelIdleCallback(id);
  }, [items, processItem, chunkSize]);
}

// 사용 예시: 이미지 프리로딩
function ProductGallery({ images }: { images: string[] }) {
  // 유휴 시간에 이미지를 순차 프리로드
  useIdleChunkedWork(
    images,
    (src) => {
      const img = new Image();
      img.src = src;
    },
    3 // 한 번에 3개씩
  );

  return (
    <div>
      {images.map((src) => (
        <img key={src} src={src} loading="lazy" alt="" />
      ))}
    </div>
  );
}
```

## Why

브라우저의 메인 스레드는 렌더링, 사용자 입력, JavaScript 실행을 모두 처리한다. 페이지 로드 직후 비긴급 작업을 즉시 실행하면 초기 렌더링과 사용자 상호작용을 방해한다. `requestIdleCallback`은 브라우저가 프레임을 렌더링하고 남은 유휴 시간(보통 프레임당 0-16ms)에 작업을 실행하므로 사용자 경험에 영향을 주지 않는다.

**정량적 효과:**
- 초기 페이지 로드: 비긴급 작업 지연으로 LCP 100-300ms 개선
- INP(Interaction to Next Paint): 메인 스레드 블로킹 제거 — 즉각 반응
- `timeout` 옵션: 지정 시간 내 실행 보장 — 분석 데이터 손실 방지
- Long Task: 50ms 초과 블로킹 작업 → 청크 분할로 5ms 이하 유지

**주의:** Safari는 `requestIdleCallback`을 미지원하므로 `setTimeout` 폴리필이 필요하다.

## References

- [MDN: requestIdleCallback](https://developer.mozilla.org/en-US/docs/Web/API/Window/requestIdleCallback)
- [web.dev: Using requestIdleCallback](https://web.dev/articles/using-requestidlecallback)
- [React Scheduler: IdleCallback 영감](https://github.com/facebook/react/tree/main/packages/scheduler)
