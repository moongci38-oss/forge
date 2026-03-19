---
title: "Barrel import(index.ts) 금지 — 직접 경로 import"
id: bundle-barrel-imports
impact: CRITICAL
category: bundle-size-optimization
impactDescription: "번들 크기 20-40% 감소 (불필요한 코드 제거)"
tags: [react, nextjs, performance, bundle, tree-shaking, imports]
---

# Barrel import(index.ts) 금지 — 직접 경로 import

> barrel file(index.ts 재수출)을 통해 import하면 tree shaking이 실패하여 사용하지 않는 코드까지 번들에 포함된다.

## Incorrect

```tsx
// Before: barrel file을 통한 import — 전체 모듈이 번들에 포함
// components/index.ts (barrel file)
export { Button } from './Button';
export { Modal } from './Modal';
export { DataTable } from './DataTable';      // 무거운 테이블 컴포넌트
export { RichEditor } from './RichEditor';    // 무거운 에디터 컴포넌트
export { Chart } from './Chart';              // 무거운 차트 컴포넌트

// app/home/page.tsx
import { Button } from '@/components';
// Button만 사용했지만 번들러가 barrel file의
// Modal, DataTable, RichEditor, Chart까지 포함시킬 수 있음
// 특히 re-export에 side-effect가 있으면 tree shaking 불가

export default function HomePage() {
  return <Button>Click me</Button>;
}
```

```tsx
// 더 나쁜 패턴: 중첩 barrel file
// lib/index.ts
export * from './utils';
export * from './hooks';
export * from './constants';

// lib/utils/index.ts
export * from './string';
export * from './date';
export * from './crypto';  // 무거운 crypto 라이브러리 포함

// app/about/page.tsx
import { formatDate } from '@/lib';
// formatDate만 필요하지만 crypto 모듈까지 번들에 포함될 수 있음
```

## Correct

```tsx
// After: 직접 경로로 import — 필요한 모듈만 정확히 포함
// app/home/page.tsx
import { Button } from '@/components/Button';
// Button 컴포넌트만 번들에 포함됨

export default function HomePage() {
  return <Button>Click me</Button>;
}

// app/about/page.tsx
import { formatDate } from '@/lib/utils/date';
// date 유틸만 번들에 포함, crypto는 제외됨
```

```tsx
// next.config.ts에서 barrel file 최적화 설정
// next.config.ts
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // barrel file 자동 최적화 (Next.js 13.1+)
  experimental: {
    optimizePackageImports: [
      '@/components',
      '@/lib',
      // 서드파티 라이브러리도 설정 가능
      'lucide-react',
      '@heroicons/react',
      'date-fns',
    ],
  },
};

export default nextConfig;
```

```tsx
// 허용되는 barrel file 패턴: 타입 전용 re-export
// types/index.ts — 타입은 런타임에 제거되므로 번들에 영향 없음
export type { User } from './user';
export type { Product } from './product';
export type { Order } from './order';

// app/checkout/page.tsx
import type { User, Order } from '@/types';
// 타입만 import — 번들 크기 영향 0
```

## Why

Barrel file은 개발자 편의를 위한 패턴이지만, 번들 최적화에 심각한 영향을 미친다:

1. **Tree shaking 실패**: 번들러가 side-effect 가능성을 고려하여 전체 모듈을 포함
2. **중첩 re-export**: `export * from`이 연쇄되면 번들러가 추적을 포기
3. **초기 로드 증가**: 사용하지 않는 컴포넌트/유틸이 번들에 포함되어 FCP/LCP 지연

**정량적 효과:**
- 50개 컴포넌트 barrel에서 1개만 사용: 직접 import로 번들 20-40% 감소
- `lucide-react` 아이콘 라이브러리: barrel import 시 전체 아이콘 포함 → 직접 import 시 사용 아이콘만
- Next.js `optimizePackageImports`로 서드파티 barrel 자동 최적화 가능

**대안:**
- Next.js 13.1+의 `optimizePackageImports` 설정으로 서드파티 라이브러리 barrel 최적화
- 자체 코드는 가능하면 직접 경로 import 유지
- 타입 전용 barrel file은 허용 (컴파일 시 제거됨)

## References

- [Next.js optimizePackageImports](https://nextjs.org/docs/app/api-reference/config/next-config-js/optimizePackageImports)
- [Webpack Tree Shaking](https://webpack.js.org/guides/tree-shaking/)
- [How Barrel Files Can Slow Down Your App](https://marvinh.dev/blog/speeding-up-javascript-ecosystem-part-7/)
