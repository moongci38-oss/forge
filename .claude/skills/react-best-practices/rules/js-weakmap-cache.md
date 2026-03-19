---
title: "객체 키 캐시는 WeakMap 사용 — 메모리 누수 방지"
id: js-weakmap-cache
impact: LOW
category: javascript-performance
impactDescription: "GC가 자동으로 미사용 캐시 정리 — 메모리 누수 0"
tags: [react, javascript, performance, cache, memory, weakmap]
---

# 객체 키 캐시는 WeakMap 사용 — 메모리 누수 방지

> 객체를 키로 사용하는 캐시는 Map 대신 WeakMap을 사용하여 참조가 사라진 객체의 캐시를 자동으로 정리한다.

## Incorrect

```tsx
// Before: Map으로 객체 캐시 — 컴포넌트 언마운트 후에도 캐시 유지 = 메모리 누수
'use client';

import { useMemo } from 'react';

// 모듈 레벨 Map — 객체 참조가 사라져도 Map이 잡고 있어 GC 불가
const computationCache = new Map<object, number>();

function expensiveComputation(data: DataObject): number {
  if (computationCache.has(data)) {
    return computationCache.get(data)!;
  }

  // CPU 집약 연산
  const result = data.values.reduce((sum, v) => sum + Math.sqrt(v), 0);
  computationCache.set(data, result);
  // data 객체가 어디에서도 사용되지 않아도
  // Map이 참조를 유지하므로 GC가 수거하지 못함
  return result;
}

function AnalyticsPanel({ datasets }: { datasets: DataObject[] }) {
  // 컴포넌트가 언마운트되어도 cache에 모든 dataset이 남아있음
  const results = datasets.map((d) => expensiveComputation(d));

  return <div>{/* 결과 렌더링 */}</div>;
}
```

## Correct

```tsx
// After: WeakMap으로 객체 캐시 — 참조 소멸 시 자동 GC
'use client';

// WeakMap은 키 객체에 대한 약한 참조만 유지
// 키 객체가 다른 곳에서 참조되지 않으면 GC가 캐시 엔트리도 함께 수거
const computationCache = new WeakMap<DataObject, number>();

function expensiveComputation(data: DataObject): number {
  if (computationCache.has(data)) {
    return computationCache.get(data)!;
  }

  const result = data.values.reduce((sum, v) => sum + Math.sqrt(v), 0);
  computationCache.set(data, result);
  // data가 더 이상 참조되지 않으면 캐시 엔트리도 자동 정리됨
  return result;
}

function AnalyticsPanel({ datasets }: { datasets: DataObject[] }) {
  const results = datasets.map((d) => expensiveComputation(d));
  // 컴포넌트 언마운트 후 datasets 참조가 사라지면 캐시도 자동 정리
  return <div>{/* 결과 렌더링 */}</div>;
}
```

```tsx
// 실전: DOM 요소 메타데이터 캐시
'use client';

import { useEffect, useRef, useCallback } from 'react';

interface ElementMeasurement {
  width: number;
  height: number;
  measuredAt: number;
}

// DOM 요소별 측정값 캐시 — 요소 제거 시 자동 정리
const measurementCache = new WeakMap<HTMLElement, ElementMeasurement>();

function useCachedMeasurement(refreshInterval = 1000) {
  const measure = useCallback((element: HTMLElement): ElementMeasurement => {
    const cached = measurementCache.get(element);
    const now = Date.now();

    // 캐시가 유효하면 재사용
    if (cached && now - cached.measuredAt < refreshInterval) {
      return cached;
    }

    // 새로 측정
    const rect = element.getBoundingClientRect();
    const measurement: ElementMeasurement = {
      width: rect.width,
      height: rect.height,
      measuredAt: now,
    };

    measurementCache.set(element, measurement);
    return measurement;
  }, [refreshInterval]);

  return measure;
}

// WeakRef와 FinalizationRegistry를 활용한 고급 캐시
const cache = new WeakMap<object, WeakRef<object>>();
const registry = new FinalizationRegistry((key: object) => {
  // WeakRef 대상이 GC되면 WeakMap에서도 정리
  const ref = cache.get(key);
  if (ref && ref.deref() === undefined) {
    cache.delete(key);
  }
});
```

## Why

`Map`은 키에 대한 강한 참조(strong reference)를 유지한다. 캐시 키로 사용된 객체가 프로그램의 다른 곳에서 더 이상 필요 없어도 Map이 참조를 유지하므로 GC가 수거하지 못한다. SPA에서 라우트 전환, 컴포넌트 마운트/언마운트가 반복되면 캐시가 무한히 증가하여 메모리 누수가 된다.

`WeakMap`은 키에 대한 약한 참조(weak reference)를 유지하므로, 키 객체에 대한 다른 참조가 모두 사라지면 GC가 캐시 엔트리를 자동으로 정리한다.

**정량적 효과:**
- 장시간 SPA 세션: Map 캐시 메모리 무한 증가 → WeakMap 자동 정리로 메모리 안정
- 메모리 누수: Map 기반 캐시 100% 누수 가능 → WeakMap 0% 누수
- DOM 요소 캐시: 요소 제거 시 자동 정리 — 수동 cleanup 로직 불필요

**제한사항:** WeakMap은 원시값(string, number)을 키로 사용할 수 없다. 원시값 캐시는 LRU Map이나 TTL 기반 캐시를 사용한다.

## References

- [MDN: WeakMap](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap)
- [MDN: WeakRef](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakRef)
- [JavaScript.info: WeakMap and WeakSet](https://javascript.info/weakmap-weakset)
