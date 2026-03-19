---
title: "시각적 업데이트는 rAF 사용"
id: js-requestAnimationFrame
impact: LOW
category: javascript-performance
impactDescription: "프레임 타이밍 최적화 — 60fps 보장"
tags: [react, performance, animation, requestAnimationFrame, fps]
---

# 시각적 업데이트는 rAF 사용

> 시각적 DOM 업데이트(애니메이션, 스크롤 동기화, 프로그레스 바)는 requestAnimationFrame을 사용하여 브라우저 렌더링 주기에 맞춘다.

## Incorrect

```tsx
// Before: setInterval로 애니메이션 — 프레임 드롭 + 배터리 낭비
'use client';

import { useEffect, useRef, useState } from 'react';

function ProgressBar({ targetPercent }: { targetPercent: number }) {
  const [currentPercent, setCurrentPercent] = useState(0);

  useEffect(() => {
    // setInterval은 브라우저 렌더링 주기와 무관하게 실행
    // 16.67ms(60fps) 간격을 지정해도 정확하지 않음
    const interval = setInterval(() => {
      setCurrentPercent((prev) => {
        if (prev >= targetPercent) {
          clearInterval(interval);
          return targetPercent;
        }
        return prev + 1;
      });
    }, 16); // 16ms 간격 — 실제로는 불규칙적

    return () => clearInterval(interval);
  }, [targetPercent]);

  // 매 업데이트마다 React 리렌더 발생
  return (
    <div className="progress-bar">
      <div style={{ width: `${currentPercent}%` }} />
    </div>
  );
}
```

## Correct

```tsx
// After: requestAnimationFrame으로 브라우저 렌더링 주기에 동기화
'use client';

import { useEffect, useRef, useCallback } from 'react';

function ProgressBar({ targetPercent }: { targetPercent: number }) {
  const barRef = useRef<HTMLDivElement>(null);
  const currentRef = useRef(0);

  useEffect(() => {
    let animationId: number;

    const animate = () => {
      if (!barRef.current) return;

      // 현재값과 목표값의 차이를 보간 — 부드러운 이징
      const diff = targetPercent - currentRef.current;
      if (Math.abs(diff) < 0.1) {
        currentRef.current = targetPercent;
        barRef.current.style.width = `${targetPercent}%`;
        return; // 애니메이션 완료 — rAF 루프 종료
      }

      currentRef.current += diff * 0.1; // easing factor
      barRef.current.style.width = `${currentRef.current}%`;

      // 다음 프레임에서 계속 — React 리렌더 없이 DOM 직접 업데이트
      animationId = requestAnimationFrame(animate);
    };

    animationId = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(animationId);
  }, [targetPercent]);

  return (
    <div className="progress-bar">
      <div ref={barRef} style={{ width: '0%' }} />
    </div>
  );
}
```

```tsx
// 고급: useAnimationFrame 커스텀 Hook
'use client';

import { useEffect, useRef, useCallback } from 'react';

function useAnimationFrame(
  callback: (deltaTime: number) => boolean | void // false 반환 시 중지
) {
  const callbackRef = useRef(callback);
  const frameRef = useRef<number>();
  const previousTimeRef = useRef<number>();

  callbackRef.current = callback;

  useEffect(() => {
    const animate = (time: number) => {
      if (previousTimeRef.current !== undefined) {
        const deltaTime = time - previousTimeRef.current;
        const shouldContinue = callbackRef.current(deltaTime);
        if (shouldContinue === false) return;
      }
      previousTimeRef.current = time;
      frameRef.current = requestAnimationFrame(animate);
    };

    frameRef.current = requestAnimationFrame(animate);
    return () => {
      if (frameRef.current) cancelAnimationFrame(frameRef.current);
    };
  }, []);
}

// 사용 예시: 실시간 카운터 애니메이션
function AnimatedCounter({ target }: { target: number }) {
  const counterRef = useRef<HTMLSpanElement>(null);
  const currentRef = useRef(0);

  useAnimationFrame((deltaTime) => {
    if (!counterRef.current) return false;

    const speed = deltaTime * 0.005; // 프레임 독립적 속도
    currentRef.current += (target - currentRef.current) * speed;

    if (Math.abs(target - currentRef.current) < 0.5) {
      counterRef.current.textContent = target.toString();
      return false; // 애니메이션 종료
    }

    counterRef.current.textContent = Math.round(currentRef.current).toString();
  });

  return <span ref={counterRef}>0</span>;
}
```

## Why

`setInterval`/`setTimeout`은 브라우저의 렌더링 파이프라인과 동기화되지 않는다. 16.67ms 간격을 지정해도 실제 실행 타이밍은 불규칙적이며, 렌더링 프레임 중간에 DOM을 변경하면 프레임 드롭이 발생한다. `requestAnimationFrame`은 브라우저가 다음 렌더링 프레임을 준비할 때 정확히 호출되므로 부드러운 60fps 애니메이션을 보장한다.

**정량적 효과:**
- setInterval 애니메이션: 40-50fps (프레임 드롭 빈번) → rAF: 안정적 60fps
- 탭 비활성 시: setInterval 계속 실행 → rAF 자동 중지 (배터리 절약)
- ref 기반 DOM 직접 업데이트: React 리렌더 0회 — 상태 업데이트 대비 GC 압력 최소화
- deltaTime 기반 보간: 모니터 주사율(60Hz/120Hz/144Hz)에 관계없이 일관된 속도

## References

- [MDN: requestAnimationFrame](https://developer.mozilla.org/en-US/docs/Web/API/Window/requestAnimationFrame)
- [web.dev: Optimize JavaScript Execution](https://web.dev/articles/optimize-javascript-execution)
- [React: Manipulating the DOM with refs](https://react.dev/learn/manipulating-the-dom-with-refs)
