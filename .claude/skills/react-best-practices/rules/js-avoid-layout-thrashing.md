---
title: "DOM 읽기/쓰기 배치 — layout thrashing 방지"
id: js-avoid-layout-thrashing
impact: LOW
category: javascript-performance
impactDescription: "강제 리플로우 제거 — DOM 조작 성능 10x 개선"
tags: [react, performance, dom, layout-thrashing, reflow]
---

# DOM 읽기/쓰기 배치 — layout thrashing 방지

> DOM 읽기와 쓰기를 교차 실행하면 브라우저가 매번 레이아웃을 강제 재계산한다. 읽기를 먼저 배치하고 쓰기를 나중에 배치한다.

## Incorrect

```tsx
// Before: 읽기/쓰기 교차 — 매 반복마다 강제 리플로우 발생
'use client';

import { useEffect, useRef } from 'react';

function AnimatedList({ items }: { items: ListItem[] }) {
  const itemRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    // 각 아이템의 높이를 읽고 즉시 스타일을 변경
    // 읽기 → 쓰기 → 읽기 → 쓰기 반복 = layout thrashing
    itemRefs.current.forEach((el) => {
      if (!el) return;

      const height = el.offsetHeight;        // 읽기 → 레이아웃 계산 강제
      el.style.transform = `scale(${100 / height})`; // 쓰기 → 레이아웃 무효화

      const width = el.offsetWidth;           // 읽기 → 다시 레이아웃 계산 강제!
      el.style.marginLeft = `${(300 - width) / 2}px`; // 쓰기 → 다시 무효화
    });
    // N개 아이템 × 2번 강제 리플로우 = 2N번 레이아웃 재계산
  }, [items]);

  return (
    <div>
      {items.map((item, i) => (
        <div key={item.id} ref={(el) => { itemRefs.current[i] = el; }}>
          {item.content}
        </div>
      ))}
    </div>
  );
}
```

## Correct

```tsx
// After: 읽기를 먼저 배치하고, 쓰기를 나중에 배치
'use client';

import { useEffect, useRef } from 'react';

function AnimatedList({ items }: { items: ListItem[] }) {
  const itemRefs = useRef<(HTMLDivElement | null)[]>([]);

  useEffect(() => {
    const elements = itemRefs.current.filter(Boolean) as HTMLDivElement[];

    // Phase 1: 모든 읽기를 먼저 배치 (1번의 레이아웃 계산)
    const measurements = elements.map((el) => ({
      height: el.offsetHeight,
      width: el.offsetWidth,
    }));

    // Phase 2: 모든 쓰기를 나중에 배치 (1번의 레이아웃 무효화)
    elements.forEach((el, i) => {
      const { height, width } = measurements[i];
      el.style.transform = `scale(${100 / height})`;
      el.style.marginLeft = `${(300 - width) / 2}px`;
    });
    // 총 1번의 레이아웃 계산 + 1번의 무효화 = 2번 (vs 2N번)
  }, [items]);

  return (
    <div>
      {items.map((item, i) => (
        <div key={item.id} ref={(el) => { itemRefs.current[i] = el; }}>
          {item.content}
        </div>
      ))}
    </div>
  );
}
```

```tsx
// 고급: requestAnimationFrame으로 쓰기 배치 보장
'use client';

import { useEffect, useRef } from 'react';

function useLayoutBatch(callback: () => void, deps: unknown[]) {
  useEffect(() => {
    // 다음 프레임에서 DOM 조작 실행 — 현재 프레임의 읽기와 분리
    const frameId = requestAnimationFrame(() => {
      callback();
    });
    return () => cancelAnimationFrame(frameId);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);
}

function ResizablePanel({ width }: { width: number }) {
  const panelRef = useRef<HTMLDivElement>(null);

  useLayoutBatch(() => {
    if (!panelRef.current) return;
    // rAF 내부에서 읽기/쓰기 배치
    const currentHeight = panelRef.current.offsetHeight;
    panelRef.current.style.width = `${width}px`;
    panelRef.current.style.minHeight = `${currentHeight}px`;
  }, [width]);

  return <div ref={panelRef}>{/* 패널 콘텐츠 */}</div>;
}
```

## Why

브라우저는 DOM 변경 후 레이아웃을 "지연" 재계산한다(배치 최적화). 하지만 DOM을 변경한 직후 레이아웃 속성(`offsetHeight`, `getBoundingClientRect` 등)을 읽으면 브라우저가 즉시 레이아웃을 재계산(강제 리플로우)해야 한다. 읽기/쓰기를 교차하면 매번 강제 리플로우가 발생하여 성능이 급격히 저하된다.

**정량적 효과:**
- 100개 DOM 요소 조작: 교차 실행 50ms → 배치 실행 5ms (10x 개선)
- 강제 리플로우: 200회 → 1회
- Chrome DevTools에서 "Forced reflow" 경고 제거

**강제 리플로우를 유발하는 속성들:**
- `offsetHeight`, `offsetWidth`, `offsetTop`, `offsetLeft`
- `scrollHeight`, `scrollWidth`, `scrollTop`
- `clientHeight`, `clientWidth`
- `getComputedStyle()`, `getBoundingClientRect()`

## References

- [web.dev: Avoid large, complex layouts and layout thrashing](https://web.dev/articles/avoid-large-complex-layouts-and-layout-thrashing)
- [MDN: Reflow](https://developer.mozilla.org/en-US/docs/Glossary/Reflow)
- [What forces layout/reflow (Paul Irish)](https://gist.github.com/paulirish/5d52fb081b3570c81e3a)
