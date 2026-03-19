---
title: "깊은 복사는 structuredClone 사용"
id: js-structuredClone
impact: LOW
category: javascript-performance
impactDescription: "JSON.parse(JSON.stringify) 대비 안전하고 빠른 deep clone"
tags: [react, javascript, performance, clone, immutability]
---

# 깊은 복사는 structuredClone 사용

> 객체의 깊은 복사가 필요할 때 `JSON.parse(JSON.stringify())`나 재귀 함수 대신 네이티브 `structuredClone()`을 사용한다.

## Incorrect

```tsx
// Before: JSON 직렬화로 깊은 복사 — 데이터 손실 위험
'use client';

import { useState } from 'react';

interface FormState {
  user: {
    name: string;
    birthDate: Date;
    settings: Map<string, string>;
    tags: Set<string>;
    pattern: RegExp;
  };
}

function UserForm({ initialData }: { initialData: FormState }) {
  const [formData, setFormData] = useState(() => {
    // JSON.parse(JSON.stringify())는 다음 타입을 손실/변환:
    // - Date → string (복원 시 Date 객체가 아닌 문자열)
    // - Map/Set → {} (빈 객체로 변환)
    // - RegExp → {} (빈 객체로 변환)
    // - undefined → 제거됨
    // - Infinity, NaN → null
    // - 순환 참조 → 에러 발생
    const cloned = JSON.parse(JSON.stringify(initialData));
    return cloned; // 타입은 FormState이지만 실제 데이터는 손상됨
  });

  const handleReset = () => {
    // 매번 직렬화/역직렬화 비용 발생
    setFormData(JSON.parse(JSON.stringify(initialData)));
  };

  return <form>{/* 폼 렌더링 */}</form>;
}
```

## Correct

```tsx
// After: structuredClone으로 안전한 깊은 복사
'use client';

import { useState, useCallback } from 'react';

interface FormState {
  user: {
    name: string;
    birthDate: Date;
    settings: Map<string, string>;
    tags: Set<string>;
  };
}

function UserForm({ initialData }: { initialData: FormState }) {
  const [formData, setFormData] = useState(() => {
    // structuredClone은 다음 타입을 올바르게 복사:
    // - Date → Date (객체 유지)
    // - Map → Map (키-값 유지)
    // - Set → Set (값 유지)
    // - ArrayBuffer, Blob, File 등
    return structuredClone(initialData);
  });

  const handleReset = useCallback(() => {
    setFormData(structuredClone(initialData));
  }, [initialData]);

  const updateNestedField = useCallback((key: string, value: string) => {
    setFormData((prev) => {
      // 불변 업데이트: 필요한 부분만 복사
      const next = structuredClone(prev);
      next.user.settings.set(key, value);
      return next;
    });
  }, []);

  return <form>{/* 폼 렌더링 */}</form>;
}
```

```tsx
// 실전: 상태 스냅샷 히스토리 (Undo/Redo)
'use client';

import { useState, useCallback, useRef } from 'react';

function useUndoable<T>(initialState: T) {
  const [state, setState] = useState(initialState);
  const historyRef = useRef<T[]>([structuredClone(initialState)]);
  const indexRef = useRef(0);

  const set = useCallback((updater: T | ((prev: T) => T)) => {
    setState((prev) => {
      const next =
        typeof updater === 'function'
          ? (updater as (prev: T) => T)(prev)
          : updater;

      // 현재 상태의 스냅샷을 히스토리에 저장
      const snapshot = structuredClone(next);
      historyRef.current = historyRef.current.slice(0, indexRef.current + 1);
      historyRef.current.push(snapshot);
      indexRef.current++;

      return next;
    });
  }, []);

  const undo = useCallback(() => {
    if (indexRef.current > 0) {
      indexRef.current--;
      setState(structuredClone(historyRef.current[indexRef.current]));
    }
  }, []);

  const redo = useCallback(() => {
    if (indexRef.current < historyRef.current.length - 1) {
      indexRef.current++;
      setState(structuredClone(historyRef.current[indexRef.current]));
    }
  }, []);

  return { state, set, undo, redo };
}
```

## Why

`JSON.parse(JSON.stringify())`는 깊은 복사의 "해킹"에 불과하며, 여러 JavaScript 타입을 올바르게 처리하지 못한다. `structuredClone()`은 브라우저 네이티브 API로 HTML structured clone algorithm을 구현하여 대부분의 타입을 안전하게 복사한다.

**정량적 효과:**
- Date, Map, Set, ArrayBuffer 등 타입 보존: JSON 방식은 손실, structuredClone은 100% 보존
- 성능: 단순 객체에서 JSON 방식과 동등, 복잡한 객체에서 10-30% 빠름
- 순환 참조: JSON 방식은 에러, structuredClone은 올바르게 처리
- 번들 크기: 별도 라이브러리(lodash.cloneDeep) 불필요 — 네이티브 API

**지원하지 않는 타입:** Function, Symbol, DOM 노드, WeakMap, WeakSet (이들은 복사 자체가 의미 없음)

## References

- [MDN: structuredClone()](https://developer.mozilla.org/en-US/docs/Web/API/Window/structuredClone)
- [web.dev: Deep-copying in JavaScript using structuredClone](https://web.dev/blog/structured-clone)
- [HTML Spec: Structured Clone Algorithm](https://html.spec.whatwg.org/multipage/structured-data.html#structured-clone)
