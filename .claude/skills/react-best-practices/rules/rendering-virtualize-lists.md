---
title: "대규모 리스트는 가상화 필수"
id: rendering-virtualize-lists
impact: MEDIUM
category: rendering-performance
impactDescription: "1000+ 아이템 리스트 DOM 노드 95% 감소 — 스크롤 60fps 유지"
tags: [react, nextjs, performance, virtualization, tanstack-virtual]
---

# 대규모 리스트는 가상화 필수

> 수천 개 아이템을 모두 DOM에 렌더하면 초기 렌더 시간이 급증하고 스크롤이 끊긴다. 가상화(virtualization)로 뷰포트에 보이는 아이템만 렌더하면 DOM 노드 수를 95% 줄일 수 있다.

## Incorrect

```tsx
// Before: 10,000개 아이템을 모두 DOM에 렌더
function TransactionHistory({ transactions }: { transactions: Transaction[] }) {
  return (
    <div className="h-[600px] overflow-y-auto">
      <table>
        <thead>
          <tr>
            <th>날짜</th>
            <th>설명</th>
            <th>금액</th>
            <th>상태</th>
          </tr>
        </thead>
        <tbody>
          {/* 10,000개 행 전부 DOM에 존재 — 초기 렌더 2-5초 */}
          {transactions.map((tx) => (
            <tr key={tx.id}>
              <td>{tx.date}</td>
              <td>{tx.description}</td>
              <td>{tx.amount.toLocaleString()}원</td>
              <td><StatusBadge status={tx.status} /></td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
// DOM 노드: ~10,000 x 4 = ~40,000개 → 메모리 사용량 폭증, 스크롤 프레임 드롭
```

## Correct

```tsx
// After: @tanstack/react-virtual로 뷰포트 아이템만 렌더
import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef } from 'react';

function TransactionHistory({ transactions }: { transactions: Transaction[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: transactions.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 48, // 각 행의 예상 높이(px)
    overscan: 5, // 뷰포트 위아래로 5개 추가 렌더 (스크롤 시 깜빡임 방지)
  });

  return (
    <div ref={parentRef} className="h-[600px] overflow-y-auto">
      <table>
        <thead>
          <tr>
            <th>날짜</th>
            <th>설명</th>
            <th>금액</th>
            <th>상태</th>
          </tr>
        </thead>
        <tbody>
          {/* 전체 높이를 유지하는 spacer */}
          <tr>
            <td
              colSpan={4}
              style={{ height: `${virtualizer.getTotalSize()}px`, padding: 0 }}
            />
          </tr>
        </tbody>
      </table>
      {/* 뷰포트에 보이는 아이템만 absolute 포지션으로 렌더 */}
      <div className="relative" style={{ height: `${virtualizer.getTotalSize()}px` }}>
        {virtualizer.getVirtualItems().map((virtualRow) => {
          const tx = transactions[virtualRow.index];
          return (
            <div
              key={tx.id}
              className="absolute left-0 right-0 flex items-center border-b"
              style={{
                height: `${virtualRow.size}px`,
                transform: `translateY(${virtualRow.start}px)`,
              }}
            >
              <span className="w-1/4">{tx.date}</span>
              <span className="w-1/4">{tx.description}</span>
              <span className="w-1/4">{tx.amount.toLocaleString()}원</span>
              <span className="w-1/4"><StatusBadge status={tx.status} /></span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
```

```tsx
// 그리드 가상화 — 이미지 갤러리 등 2D 레이아웃
import { useVirtualizer } from '@tanstack/react-virtual';

function ImageGallery({ images }: { images: GalleryImage[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  const columns = 4;
  const rowCount = Math.ceil(images.length / columns);

  const rowVirtualizer = useVirtualizer({
    count: rowCount,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 250, // 각 행 높이
    overscan: 2,
  });

  return (
    <div ref={parentRef} className="h-[80vh] overflow-y-auto">
      <div style={{ height: `${rowVirtualizer.getTotalSize()}px`, position: 'relative' }}>
        {rowVirtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.index}
            className="absolute left-0 right-0 grid grid-cols-4 gap-4 px-4"
            style={{
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {Array.from({ length: columns }).map((_, colIndex) => {
              const imageIndex = virtualRow.index * columns + colIndex;
              const image = images[imageIndex];
              if (!image) return <div key={colIndex} />;
              return (
                <div key={image.id} className="aspect-square rounded-lg overflow-hidden">
                  <img
                    src={image.thumbnailUrl}
                    alt={image.alt}
                    className="w-full h-full object-cover"
                    loading="lazy"
                  />
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Why

브라우저는 DOM 노드 수에 비례하여 메모리를 사용하고, 스크롤 시 visible 여부와 무관하게 모든 노드의 레이아웃을 계산한다. 10,000개 행은 ~40,000개 DOM 노드(4열 기준)를 생성한다.

가상화는 **뷰포트에 보이는 아이템 + overscan 개수**만 DOM에 유지한다. 600px 높이 컨테이너에 48px 행이면 약 13개 + overscan 10개 = ~23개 행만 렌더한다.

**정량적 효과:**
- DOM 노드: 40,000개 → ~100개 (95% 감소)
- 초기 렌더: 2-5초 → 50ms 이하
- 메모리: ~200MB → ~5MB (DOM 크기 비례)
- 스크롤 FPS: 20-30fps → 안정적 60fps
- overscan으로 빠른 스크롤 시 빈 공간(white flash) 최소화

## References

- [TanStack Virtual 공식 문서](https://tanstack.com/virtual/latest)
- [react-window (경량 대안)](https://github.com/bvaughn/react-window)
- [Web.dev — Virtualize long lists](https://web.dev/articles/virtualize-long-lists-react-window)
