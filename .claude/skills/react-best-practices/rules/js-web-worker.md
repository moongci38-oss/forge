---
title: "CPU 집약 작업은 Web Worker로 분리"
id: js-web-worker
impact: LOW
category: javascript-performance
impactDescription: "메인 스레드 블로킹 제거 — UI 반응성 유지"
tags: [react, performance, web-worker, concurrency, main-thread]
---

# CPU 집약 작업은 Web Worker로 분리

> CPU 집약적 연산(정렬, 필터링, 암호화, 파싱)은 Web Worker로 오프로드하여 메인 스레드의 UI 반응성을 보장한다.

## Incorrect

```tsx
// Before: 메인 스레드에서 대량 데이터 처리 — UI 프리징
'use client';

import { useState } from 'react';

interface DataRow {
  id: string;
  name: string;
  score: number;
  category: string;
}

function DataAnalytics({ rawData }: { rawData: DataRow[] }) {
  const [result, setResult] = useState<AnalyticsResult | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);

  const handleAnalyze = () => {
    setIsProcessing(true);

    // 10만 행 데이터 처리 — 메인 스레드 2-5초 블로킹
    // 이 동안 버튼 클릭, 스크롤, 애니메이션 모두 멈춤
    const sorted = [...rawData].sort((a, b) => b.score - a.score);
    const grouped = Object.groupBy(sorted, (item) => item.category);
    const statistics = Object.entries(grouped).map(([category, items]) => ({
      category,
      count: items!.length,
      avgScore: items!.reduce((sum, i) => sum + i.score, 0) / items!.length,
      topItems: items!.slice(0, 10),
    }));

    setResult({ statistics, totalProcessed: rawData.length });
    setIsProcessing(false); // 동기 코드이므로 UI가 이미 멈춘 상태
  };

  return (
    <div>
      <button onClick={handleAnalyze} disabled={isProcessing}>
        {isProcessing ? '분석 중...' : '데이터 분석'}
      </button>
      {result && <AnalyticsDisplay result={result} />}
    </div>
  );
}
```

## Correct

```tsx
// After: Web Worker로 CPU 집약 작업 오프로드
// workers/analytics.worker.ts
const ctx = self as unknown as DedicatedWorkerGlobalScope;

interface WorkerMessage {
  type: 'ANALYZE';
  payload: DataRow[];
}

ctx.onmessage = (event: MessageEvent<WorkerMessage>) => {
  const { type, payload } = event.data;

  if (type === 'ANALYZE') {
    // Worker 스레드에서 실행 — 메인 스레드 영향 없음
    const sorted = [...payload].sort((a, b) => b.score - a.score);
    const grouped = Object.groupBy(sorted, (item) => item.category);
    const statistics = Object.entries(grouped).map(([category, items]) => ({
      category,
      count: items!.length,
      avgScore: items!.reduce((sum, i) => sum + i.score, 0) / items!.length,
      topItems: items!.slice(0, 10),
    }));

    ctx.postMessage({ statistics, totalProcessed: payload.length });
  }
};
```

```tsx
// hooks/useAnalyticsWorker.ts — Worker 추상화 Hook
'use client';

import { useEffect, useRef, useState, useCallback } from 'react';

export function useAnalyticsWorker() {
  const workerRef = useRef<Worker | null>(null);
  const [result, setResult] = useState<AnalyticsResult | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);

  useEffect(() => {
    workerRef.current = new Worker(
      new URL('../workers/analytics.worker.ts', import.meta.url)
    );

    workerRef.current.onmessage = (event: MessageEvent<AnalyticsResult>) => {
      setResult(event.data);
      setIsProcessing(false);
    };

    return () => workerRef.current?.terminate();
  }, []);

  const analyze = useCallback((data: DataRow[]) => {
    setIsProcessing(true);
    workerRef.current?.postMessage({ type: 'ANALYZE', payload: data });
  }, []);

  return { result, isProcessing, analyze };
}
```

```tsx
// 컴포넌트에서 Worker Hook 사용
'use client';

function DataAnalytics({ rawData }: { rawData: DataRow[] }) {
  const { result, isProcessing, analyze } = useAnalyticsWorker();

  return (
    <div>
      <button onClick={() => analyze(rawData)} disabled={isProcessing}>
        {isProcessing ? '분석 중...' : '데이터 분석'}
      </button>
      {/* Worker 실행 중에도 UI 정상 동작 */}
      {result && <AnalyticsDisplay result={result} />}
    </div>
  );
}
```

## Why

JavaScript는 싱글 스레드로 동작한다. 메인 스레드에서 CPU 집약 작업을 실행하면 해당 작업이 완료될 때까지 모든 UI 상호작용(클릭, 스크롤, 애니메이션)이 멈춘다. Web Worker는 별도 스레드에서 코드를 실행하므로 메인 스레드의 반응성을 유지할 수 있다.

**정량적 효과:**
- 10만 행 정렬/그룹화: 메인 스레드 3-5초 블로킹 → Worker 사용 시 0ms 블로킹
- Long Task(50ms 초과) 발생 0건 유지
- INP(Interaction to Next Paint) 200ms 이내 유지
- Next.js의 `new URL(..., import.meta.url)` 패턴으로 Worker 번들링 자동 지원

## References

- [MDN: Web Workers API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)
- [web.dev: Use Web Workers](https://web.dev/articles/workers-basics)
- [Next.js Web Workers](https://nextjs.org/docs/app/building-your-application/optimizing/web-workers)
