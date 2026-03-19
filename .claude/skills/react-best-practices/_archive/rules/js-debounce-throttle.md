---
title: "빈번한 이벤트는 debounce/throttle 적용"
id: js-debounce-throttle
impact: LOW
category: javascript-performance
impactDescription: "이벤트 핸들러 호출 90% 감소 — scroll/resize/input 최적화"
tags: [react, nextjs, performance, debounce, throttle, events]
---

# 빈번한 이벤트는 debounce/throttle 적용

> scroll, resize, input 등 고빈도 이벤트에 debounce/throttle을 적용하여 불필요한 핸들러 실행을 방지한다.

## Incorrect

```tsx
// Before: 매 키 입력마다 API 호출 — 네트워크 폭주 + 서버 부하
'use client';

import { useState } from 'react';

function SearchInput() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);

  // 매 키 입력(onChange)마다 API 호출 발생
  const handleChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setQuery(value);

    // "react"를 입력하면 "r", "re", "rea", "reac", "react" 총 5번 API 호출
    const res = await fetch(`/api/search?q=${value}`);
    const data = await res.json();
    setResults(data);
  };

  return (
    <div>
      <input value={query} onChange={handleChange} placeholder="검색어 입력" />
      <ResultList results={results} />
    </div>
  );
}
```

## Correct

```tsx
// After: useDeferredValue + debounce 조합으로 최적화
'use client';

import { useState, useDeferredValue, useCallback, useEffect } from 'react';

// 범용 debounce hook
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

function SearchInput() {
  const [query, setQuery] = useState('');
  // 300ms 동안 입력이 없을 때만 검색 실행
  const debouncedQuery = useDebounce(query, 300);
  const [results, setResults] = useState<SearchResult[]>([]);

  useEffect(() => {
    if (!debouncedQuery) {
      setResults([]);
      return;
    }

    const controller = new AbortController();

    fetch(`/api/search?q=${debouncedQuery}`, { signal: controller.signal })
      .then((res) => res.json())
      .then(setResults)
      .catch((err) => {
        if (err.name !== 'AbortError') console.error(err);
      });

    return () => controller.abort();
  }, [debouncedQuery]);

  return (
    <div>
      <input
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="검색어 입력"
      />
      <ResultList results={results} />
    </div>
  );
}
```

```tsx
// throttle 예시: 스크롤 이벤트 최적화
'use client';

import { useEffect, useRef, useCallback } from 'react';

function useThrottle<T extends (...args: unknown[]) => void>(
  callback: T,
  delay: number
): T {
  const lastCall = useRef(0);
  const timeoutRef = useRef<ReturnType<typeof setTimeout>>();

  return useCallback(
    ((...args: unknown[]) => {
      const now = Date.now();
      const remaining = delay - (now - lastCall.current);

      if (remaining <= 0) {
        lastCall.current = now;
        callback(...args);
      } else {
        clearTimeout(timeoutRef.current);
        timeoutRef.current = setTimeout(() => {
          lastCall.current = Date.now();
          callback(...args);
        }, remaining);
      }
    }) as T,
    [callback, delay]
  );
}

function InfiniteScrollList() {
  // 100ms 간격으로 스크롤 위치 체크 — 초당 최대 10회
  const handleScroll = useThrottle(() => {
    const { scrollTop, scrollHeight, clientHeight } = document.documentElement;
    if (scrollHeight - scrollTop - clientHeight < 200) {
      loadMore();
    }
  }, 100);

  useEffect(() => {
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [handleScroll]);

  return <div>{/* 리스트 렌더링 */}</div>;
}
```

## Why

브라우저의 scroll, resize, input 이벤트는 초당 수십~수백 회 발생한다. 매 이벤트마다 API 호출이나 상태 업데이트를 실행하면 네트워크 폭주, 불필요한 리렌더, 메인 스레드 블로킹이 발생한다.

**debounce vs throttle 선택 기준:**
- **debounce**: 마지막 이벤트 후 일정 시간 뒤 1회 실행 (검색 입력, 폼 유효성 검사)
- **throttle**: 일정 간격마다 최대 1회 실행 (스크롤, 리사이즈, 마우스 이동)

**정량적 효과:**
- 검색 입력 debounce(300ms): "react hooks" 입력 시 API 호출 11회 → 1회 (90% 감소)
- 스크롤 throttle(100ms): 초당 이벤트 60-120회 → 10회 (90% 감소)
- 서버 부하: 동시 사용자 1000명 기준, 분당 API 호출 수십만 → 수만으로 감소

## References

- [React useDeferredValue](https://react.dev/reference/react/useDeferredValue)
- [MDN: Debounce and Throttle](https://developer.mozilla.org/en-US/docs/Glossary/Debounce)
- [Web.dev: Debouncing and Throttling](https://web.dev/articles/debounce-throttle)
