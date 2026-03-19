---
title: "조건부 기능은 동적 import로 분리"
id: bundle-conditional-module
impact: CRITICAL
category: bundle-size-optimization
impactDescription: "사용하지 않는 기능의 번들 비용 0으로 감소"
tags: [react, nextjs, performance, bundle, dynamic-import, feature-flag]
---

# 조건부 기능은 동적 import로 분리

> 피처 플래그, 사용자 권한, 디바이스 유형에 따라 선택적으로 사용되는 모듈은 동적 import로 분리한다. 조건이 충족될 때만 코드를 로드한다.

## Incorrect

```tsx
// Before: 탑 레벨 import — 기능 사용 여부와 무관하게 번들에 포함
// app/editor/page.tsx

import { BasicEditor } from '@/components/BasicEditor';
import { AdvancedEditor } from '@/components/AdvancedEditor';   // 150KB
import { AIAssistant } from '@/components/AIAssistant';         // 200KB
import { CollabModule } from '@/components/CollabModule';       // 100KB
import { ExportToPDF } from '@/components/ExportToPDF';         // 80KB

export default function EditorPage({ user }: { user: User }) {
  return (
    <div>
      <BasicEditor />
      {/* Pro 사용자만 사용 — 하지만 모든 사용자 번들에 포함 */}
      {user.plan === 'pro' && <AdvancedEditor />}
      {/* AI 기능 플래그 — 비활성 상태에서도 번들에 포함 */}
      {user.features.ai && <AIAssistant />}
      {/* 팀 플랜만 — 개인 사용자에게도 번들 비용 발생 */}
      {user.plan === 'team' && <CollabModule />}
      {/* 내보내기 — 거의 사용 안 함 */}
      <ExportToPDF />
    </div>
  );
}
// 무료 사용자도 530KB의 불필요한 JS를 다운로드
```

## Correct

```tsx
// After: 조건부 동적 import — 필요할 때만 로드
// app/editor/page.tsx

'use client';

import { useState, useCallback } from 'react';
import dynamic from 'next/dynamic';
import { BasicEditor } from '@/components/BasicEditor';

// 동적 import — 번들에서 제외, 필요 시 별도 청크로 로드
const AdvancedEditor = dynamic(
  () => import('@/components/AdvancedEditor'),
  { loading: () => <EditorUpgradeSkeleton /> }
);

const AIAssistant = dynamic(
  () => import('@/components/AIAssistant'),
  { loading: () => <AISkeleton /> }
);

const CollabModule = dynamic(
  () => import('@/components/CollabModule'),
  { loading: () => <CollabSkeleton /> }
);

export default function EditorPage({ user }: { user: User }) {
  return (
    <div>
      <BasicEditor />
      {/* Pro 사용자에게만 청크 로드 */}
      {user.plan === 'pro' && <AdvancedEditor />}
      {/* AI 플래그 활성화된 사용자에게만 */}
      {user.features.ai && <AIAssistant />}
      {/* 팀 플랜에게만 */}
      {user.plan === 'team' && <CollabModule />}
      {/* 내보내기는 버튼 클릭 시 로드 — 아래 참조 */}
      <ExportButton />
    </div>
  );
}

// 사용자 액션 트리거 동적 import
function ExportButton() {
  const [isExporting, setIsExporting] = useState(false);

  const handleExport = useCallback(async () => {
    setIsExporting(true);
    // 클릭 시점에 모듈 로드
    const { exportToPDF } = await import('@/lib/export-pdf');
    await exportToPDF();
    setIsExporting(false);
  }, []);

  return (
    <button onClick={handleExport} disabled={isExporting}>
      {isExporting ? 'Exporting...' : 'Export PDF'}
    </button>
  );
}
```

```tsx
// Server Component에서 조건부 렌더링 — 더 깔끔한 패턴
// app/editor/page.tsx

import dynamic from 'next/dynamic';
import { auth } from '@/lib/auth';

const AdvancedEditor = dynamic(() => import('@/components/AdvancedEditor'));
const AIAssistant = dynamic(() => import('@/components/AIAssistant'));

export default async function EditorPage() {
  const session = await auth();
  const user = session?.user;

  return (
    <div>
      <BasicEditor />
      {/* 서버에서 조건 판단 — 해당 사용자에게만 dynamic import 지시 */}
      {user?.plan === 'pro' && <AdvancedEditor />}
      {user?.features.ai && <AIAssistant />}
    </div>
  );
}
```

```tsx
// 피처 플래그 기반 동적 import 유틸
// lib/feature-loader.ts

import dynamic from 'next/dynamic';
import type { ComponentType } from 'react';

type FeatureConfig = {
  loader: () => Promise<{ default: ComponentType<any> }>;
  fallback?: React.ReactNode;
};

const featureMap: Record<string, FeatureConfig> = {
  'ai-assistant': {
    loader: () => import('@/components/AIAssistant'),
    fallback: <AISkeleton />,
  },
  'collab': {
    loader: () => import('@/components/CollabModule'),
    fallback: <CollabSkeleton />,
  },
};

export function loadFeature(featureName: string) {
  const config = featureMap[featureName];
  if (!config) return null;

  return dynamic(config.loader, {
    loading: () => config.fallback ?? null,
  });
}
```

## Why

대부분의 SaaS 애플리케이션에서 사용자별로 실제 사용하는 기능은 전체의 30-50%이다. 탑 레벨 import로 모든 기능을 포함하면 사용하지 않는 코드가 번들의 50-70%를 차지할 수 있다.

동적 import의 핵심 이점:
1. **조건 충족 시에만 네트워크 요청** 발생
2. **번들 분석기에서 각 기능의 청크 크기를 독립 확인** 가능
3. **피처 플래그와 자연스럽게 통합** 가능

**정량적 효과:**
- 무료 사용자: Pro+AI+Collab+Export = 530KB 절약 (번들 비용 0)
- Pro 사용자: AI+Collab+Export = 380KB 절약
- 전체 사용자 평균 번들 크기 40-60% 감소
- 피처 플래그 비활성 기능의 번들 비용 완전 제거

**적용 대상 판단:**
- 사용자 권한/플랜에 따른 기능
- 피처 플래그로 제어되는 기능
- 사용 빈도가 낮은 기능 (내보내기, 고급 설정)
- 특정 디바이스/브라우저에서만 필요한 기능

## References

- [Next.js Lazy Loading](https://nextjs.org/docs/app/building-your-application/optimizing/lazy-loading)
- [Dynamic Import MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/import)
- [Webpack Magic Comments](https://webpack.js.org/api/module-methods/#magic-comments)
