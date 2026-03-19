---
title: "무거운 컴포넌트는 dynamic import"
id: bundle-dynamic-import
impact: CRITICAL
category: bundle-size-optimization
impactDescription: "초기 JS 번들 30-60% 감소"
tags: [react, nextjs, performance, bundle, code-splitting, dynamic-import]
---

# 무거운 컴포넌트는 dynamic import

> 초기 렌더에 필요하지 않은 무거운 컴포넌트(차트, 에디터, 맵 등)는 동적 import로 코드 분할한다.

## Incorrect

```tsx
// Before: 정적 import — 초기 번들에 무거운 라이브러리 포함
// app/dashboard/page.tsx

import { Chart } from '@/components/Chart';       // recharts ~200KB
import { RichEditor } from '@/components/Editor';  // tiptap ~300KB
import { MapView } from '@/components/Map';        // mapbox-gl ~500KB

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <MetricsSummary />
      {/* 차트는 스크롤 아래에 위치 — 초기 뷰포트에 안 보임 */}
      <Chart data={chartData} />
      {/* 에디터는 탭 전환 후에만 표시 */}
      <RichEditor />
      {/* 지도는 별도 탭 */}
      <MapView />
    </div>
  );
}
// 초기 JS 번들: 1000KB+ (Chart + Editor + Map 모두 포함)
```

## Correct

```tsx
// After: next/dynamic으로 무거운 컴포넌트 분리
// app/dashboard/page.tsx

import dynamic from 'next/dynamic';

// 무거운 컴포넌트를 동적 로딩 — 초기 번들에서 제외
const Chart = dynamic(() => import('@/components/Chart'), {
  loading: () => <ChartSkeleton />,
  // SSR 불필요한 브라우저 전용 라이브러리
  ssr: false,
});

const RichEditor = dynamic(() => import('@/components/Editor'), {
  loading: () => <EditorSkeleton />,
  ssr: false,
});

const MapView = dynamic(() => import('@/components/Map'), {
  loading: () => <MapSkeleton />,
  ssr: false,
});

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>
      <MetricsSummary />
      {/* 각 컴포넌트가 필요할 때 별도 청크로 로드됨 */}
      <Chart data={chartData} />
      <RichEditor />
      <MapView />
    </div>
  );
}
// 초기 JS 번들: ~100KB (Chart/Editor/Map 제외)
// 각 컴포넌트는 별도 청크로 필요 시 로드
```

```tsx
// 조건부 렌더링과 dynamic import 조합
// app/settings/page.tsx

'use client';

import { useState } from 'react';
import dynamic from 'next/dynamic';

const AdvancedSettings = dynamic(
  () => import('@/components/AdvancedSettings'),
  { loading: () => <p>Loading advanced settings...</p> }
);

export default function SettingsPage() {
  const [showAdvanced, setShowAdvanced] = useState(false);

  return (
    <div>
      <BasicSettings />
      <button onClick={() => setShowAdvanced(true)}>
        Show Advanced Settings
      </button>
      {/* 버튼 클릭 시에만 AdvancedSettings 청크 로드 */}
      {showAdvanced && <AdvancedSettings />}
    </div>
  );
}
```

```tsx
// React.lazy() + Suspense 패턴 (클라이언트 컴포넌트)
// app/editor/page.tsx

'use client';

import { lazy, Suspense } from 'react';

const CodeEditor = lazy(() => import('@/components/CodeEditor'));

export default function EditorPage() {
  return (
    <div>
      <EditorToolbar />
      <Suspense fallback={<EditorSkeleton />}>
        <CodeEditor />
      </Suspense>
    </div>
  );
}
```

## Why

JavaScript 번들 크기는 Core Web Vitals에 직접 영향을 미친다:
- **LCP**: JS 파싱/실행 시간이 렌더 블로킹
- **FID/INP**: 큰 번들은 메인 스레드를 오래 점유
- **TBT**: Total Blocking Time 증가

무거운 라이브러리를 동적 import로 분리하면 초기 페이지 로드에 필요한 JS만 다운로드된다.

**정량적 효과:**
- recharts(200KB) + tiptap(300KB) + mapbox(500KB) = 1000KB 제거
- 초기 번들: 30-60% 감소
- FCP: 200-500ms 개선 (JS 파싱 시간 단축)
- `ssr: false` 옵션으로 서버에서 불필요한 렌더링도 방지

**동적 import 대상 판단 기준:**
- 번들 크기 50KB 이상인 컴포넌트
- 초기 뷰포트에 보이지 않는 컴포넌트
- 사용자 인터랙션 후에만 필요한 컴포넌트
- `window`/`document`에 의존하는 브라우저 전용 라이브러리

## References

- [Next.js Dynamic Imports](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)
- [React lazy](https://react.dev/reference/react/lazy)
- [Webpack Code Splitting](https://webpack.js.org/guides/code-splitting/)
