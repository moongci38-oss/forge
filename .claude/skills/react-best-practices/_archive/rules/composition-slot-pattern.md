---
title: "Slot 패턴으로 유연한 컴포넌트 합성"
id: composition-slot-pattern
impact: HIGH
category: composition-patterns
impactDescription: "컴포넌트 커스터마이징 유연성 극대화 — hard-coded 내부 UI 제거"
tags: [react, nextjs, patterns, slots, composition, children]
---

# Slot 패턴으로 유연한 컴포넌트 합성

> 컴포넌트 내부 구조를 하드코딩하지 않고, props로 슬롯을 받아 사용자가 원하는 UI를 주입할 수 있게 한다. children과 named slots를 조합하여 유연한 API를 설계한다.

## Incorrect

```tsx
// Before: 내부 구조 하드코딩 — 커스터마이징 불가
'use client';

interface CardProps {
  title: string;
  subtitle?: string;
  imageUrl?: string;
  badge?: string;
  description: string;
  tags?: string[];
  authorName?: string;
  authorAvatar?: string;
  date?: string;
  actionLabel?: string;
  onAction?: () => void;
  showFooter?: boolean;
  footerText?: string;
  variant?: 'default' | 'compact' | 'featured';
}

// 모든 변형을 조건부 렌더링으로 처리 — 복잡도 급증
function Card({
  title,
  subtitle,
  imageUrl,
  badge,
  description,
  tags,
  authorName,
  authorAvatar,
  date,
  actionLabel,
  onAction,
  showFooter,
  footerText,
  variant = 'default',
}: CardProps) {
  return (
    <div className={`card card--${variant}`}>
      {imageUrl && (
        <div className="card-image">
          <img src={imageUrl} alt={title} />
          {badge && <span className="card-badge">{badge}</span>}
        </div>
      )}
      <div className="card-body">
        <h3>{title}</h3>
        {subtitle && <p className="subtitle">{subtitle}</p>}
        <p>{description}</p>
        {tags && (
          <div className="tags">
            {tags.map((tag) => (
              <span key={tag} className="tag">{tag}</span>
            ))}
          </div>
        )}
      </div>
      {(authorName || date) && (
        <div className="card-meta">
          {authorAvatar && <img src={authorAvatar} alt="" />}
          {authorName && <span>{authorName}</span>}
          {date && <time>{date}</time>}
        </div>
      )}
      {showFooter && (
        <div className="card-footer">
          {footerText && <span>{footerText}</span>}
          {actionLabel && <button onClick={onAction}>{actionLabel}</button>}
        </div>
      )}
    </div>
  );
}

// 문제: 카드에 커스텀 액션 버튼 3개를 넣고 싶으면?
// → props를 더 추가해야 함 (actionLabel2, onAction2, ...)
```

## Correct

```tsx
// After: Slot 패턴 — 각 영역을 props로 주입
import { type ReactNode } from 'react';

interface CardProps {
  children: ReactNode;
  header?: ReactNode;
  footer?: ReactNode;
  media?: ReactNode;
  className?: string;
}

function Card({ children, header, footer, media, className = '' }: CardProps) {
  return (
    <div className={`rounded-lg border bg-white shadow-sm ${className}`}>
      {media && <div className="overflow-hidden rounded-t-lg">{media}</div>}
      {header && <div className="border-b px-4 py-3">{header}</div>}
      <div className="px-4 py-3">{children}</div>
      {footer && <div className="border-t px-4 py-3">{footer}</div>}
    </div>
  );
}

export { Card };
```

```tsx
// 사용: 각 슬롯에 원하는 UI를 자유롭게 주입
'use client';

import { Card } from '@/components/Card';

// 기본 카드
function BasicCard() {
  return (
    <Card header={<h3 className="font-semibold">제목</h3>}>
      <p>카드 본문 내용</p>
    </Card>
  );
}

// 이미지 카드 + 커스텀 Footer
function ProductCard({ product }: { product: Product }) {
  return (
    <Card
      media={
        <div className="relative">
          <img
            src={product.imageUrl}
            alt={product.name}
            className="h-48 w-full object-cover"
          />
          {product.isNew && (
            <span className="absolute right-2 top-2 rounded bg-blue-500 px-2 py-1 text-xs text-white">
              NEW
            </span>
          )}
        </div>
      }
      header={
        <div className="flex items-center justify-between">
          <h3 className="font-semibold">{product.name}</h3>
          <span className="text-lg font-bold">
            {product.price.toLocaleString()}원
          </span>
        </div>
      }
      footer={
        <div className="flex gap-2">
          <button className="flex-1 rounded bg-blue-500 py-2 text-white">
            장바구니
          </button>
          <button className="rounded border px-4 py-2">♡</button>
        </div>
      }
    >
      <p className="text-sm text-gray-600">{product.description}</p>
      <div className="mt-2 flex gap-1">
        {product.tags.map((tag) => (
          <span key={tag} className="rounded bg-gray-100 px-2 py-0.5 text-xs">
            {tag}
          </span>
        ))}
      </div>
    </Card>
  );
}

// 완전 커스텀: 대시보드 위젯 카드
function DashboardWidgetCard({
  title,
  action,
  children,
}: {
  title: string;
  action: ReactNode;
  children: ReactNode;
}) {
  return (
    <Card
      header={
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-medium text-gray-500">{title}</h3>
          {action}
        </div>
      }
    >
      {children}
    </Card>
  );
}
```

```tsx
// 고급: TypeScript 제네릭 슬롯 — 타입 안전한 슬롯 패턴
interface TableProps<T> {
  data: T[];
  columns: Array<{
    key: keyof T;
    header: ReactNode;
    render?: (value: T[keyof T], row: T) => ReactNode;
  }>;
  emptyState?: ReactNode;
  toolbar?: ReactNode;
  pagination?: ReactNode;
}

function Table<T extends { id: string }>({
  data,
  columns,
  emptyState,
  toolbar,
  pagination,
}: TableProps<T>) {
  if (data.length === 0 && emptyState) {
    return <div>{emptyState}</div>;
  }

  return (
    <div>
      {toolbar && <div className="mb-4">{toolbar}</div>}
      <table className="w-full">
        <thead>
          <tr>
            {columns.map((col) => (
              <th key={String(col.key)}>{col.header}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.map((row) => (
            <tr key={row.id}>
              {columns.map((col) => (
                <td key={String(col.key)}>
                  {col.render
                    ? col.render(row[col.key], row)
                    : String(row[col.key])}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
      {pagination && <div className="mt-4">{pagination}</div>}
    </div>
  );
}
```

## Why

하드코딩된 내부 구조의 컴포넌트는 새로운 요구사항이 생길 때마다 props를 추가해야 한다. 시간이 지나면 props가 20개 이상으로 늘어나고, 어떤 조합이 유효한지 파악하기 어려워진다. Slot 패턴은 컴포넌트의 레이아웃만 제공하고 내용을 사용자가 결정하게 하여 무한한 커스터마이징을 가능하게 한다.

**정량적 효과:**
- Props 수: 15+ 개별 props → 3-4개 슬롯 props (80% 감소)
- 변형(variants): 조건부 렌더링 분기 제거 — 슬롯에 원하는 UI 직접 전달
- 타입 안전성: ReactNode 타입으로 모든 JSX 허용 — 불가능한 조합 없음
- 확장성: 새 슬롯 추가만으로 기능 확장 — 기존 사용 코드 변경 불필요
- 재사용성: 동일 Card 컴포넌트로 상품 카드, 프로필 카드, 위젯 카드 모두 구현

## References

- [React: Passing JSX as children](https://react.dev/learn/passing-props-to-a-component#passing-jsx-as-children)
- [React: Composition vs Inheritance](https://legacy.reactjs.org/docs/composition-vs-inheritance.html)
- [Radix UI: Slot pattern](https://www.radix-ui.com/primitives/docs/utilities/slot)
