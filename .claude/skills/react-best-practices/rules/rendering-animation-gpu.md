---
title: "애니메이션은 transform/opacity만 사용 — layout 트리거 금지"
id: rendering-animation-gpu
impact: MEDIUM
category: rendering-performance
impactDescription: "GPU 가속 — 60fps 보장, main thread 블로킹 제거"
tags: [react, nextjs, performance, animation, gpu, css]
---

# 애니메이션은 transform/opacity만 사용 — layout 트리거 금지

> width, height, top, left 등 레이아웃 속성을 애니메이션하면 매 프레임마다 레이아웃 재계산 + 리페인트가 발생한다. transform과 opacity는 GPU의 컴포지터 레이어에서 처리되어 메인 스레드를 블로킹하지 않는다.

## Incorrect

```tsx
// Before: layout 속성 애니메이션 — 매 프레임마다 Layout + Paint
function AnimatedSidebar({ isOpen }: { isOpen: boolean }) {
  return (
    <aside
      className="fixed top-0 left-0 h-full bg-white shadow-lg"
      style={{
        // width 애니메이션 — 매 프레임마다 전체 레이아웃 재계산
        width: isOpen ? '300px' : '0px',
        transition: 'width 0.3s ease',
        overflow: 'hidden',
      }}
    >
      <nav>
        <NavItem href="/dashboard">대시보드</NavItem>
        <NavItem href="/orders">주문 관리</NavItem>
        <NavItem href="/products">상품 관리</NavItem>
      </nav>
    </aside>
  );
}

function AnimatedCard({ isHovered }: { isHovered: boolean }) {
  return (
    <div
      style={{
        // top, left 애니메이션 — Layout 트리거
        position: 'relative',
        top: isHovered ? '-10px' : '0px',
        left: isHovered ? '0px' : '0px',
        // height 애니메이션 — Layout 트리거
        height: isHovered ? '320px' : '300px',
        // box-shadow 변경 — Paint 트리거 (Layout보다는 낫지만 여전히 무거움)
        boxShadow: isHovered
          ? '0 20px 40px rgba(0,0,0,0.3)'
          : '0 2px 4px rgba(0,0,0,0.1)',
        transition: 'all 0.3s ease',
      }}
    >
      <h3>상품 카드</h3>
    </div>
  );
}
```

## Correct

```tsx
// After: transform/opacity만 사용 — GPU 컴포지터에서 처리
function AnimatedSidebar({ isOpen }: { isOpen: boolean }) {
  return (
    <aside
      className="fixed top-0 left-0 h-full w-[300px] bg-white shadow-lg"
      style={{
        // translateX로 이동 — GPU가 레이어만 이동 (Layout/Paint 없음)
        transform: isOpen ? 'translateX(0)' : 'translateX(-100%)',
        transition: 'transform 0.3s ease',
        willChange: 'transform', // GPU 레이어 사전 생성
      }}
    >
      <nav>
        <NavItem href="/dashboard">대시보드</NavItem>
        <NavItem href="/orders">주문 관리</NavItem>
        <NavItem href="/products">상품 관리</NavItem>
      </nav>
    </aside>
  );
}

function AnimatedCard({ isHovered }: { isHovered: boolean }) {
  return (
    <div
      className="relative h-[300px]"
      style={{
        // translateY로 위로 이동 — Layout 트리거 없음
        transform: isHovered ? 'translateY(-10px) scale(1.02)' : 'translateY(0) scale(1)',
        // opacity로 그림자 효과 — Paint 트리거 없음
        opacity: 1,
        transition: 'transform 0.3s ease, opacity 0.3s ease',
      }}
    >
      {/* 그림자는 pseudo-element의 opacity로 제어 */}
      <div
        className="absolute inset-0 rounded-lg shadow-2xl"
        style={{
          opacity: isHovered ? 1 : 0,
          transition: 'opacity 0.3s ease',
        }}
      />
      <div className="relative z-10 p-4">
        <h3>상품 카드</h3>
      </div>
    </div>
  );
}
```

```tsx
// Framer Motion 사용 시 — 자동으로 GPU 가속 속성 사용
import { motion } from 'framer-motion';

function AnimatedModal({ isOpen }: { isOpen: boolean }) {
  return (
    <>
      {/* 오버레이 — opacity만 애니메이션 */}
      <motion.div
        className="fixed inset-0 bg-black/50"
        initial={{ opacity: 0 }}
        animate={{ opacity: isOpen ? 1 : 0 }}
        transition={{ duration: 0.2 }}
      />
      {/* 모달 — transform만 애니메이션 */}
      <motion.div
        className="fixed inset-x-4 top-1/2 max-w-lg mx-auto bg-white rounded-xl p-6"
        initial={{ opacity: 0, y: 20, scale: 0.95 }}
        animate={{
          opacity: isOpen ? 1 : 0,
          y: isOpen ? '-50%' : 'calc(-50% + 20px)',
          scale: isOpen ? 1 : 0.95,
        }}
        transition={{ type: 'spring', damping: 25, stiffness: 300 }}
      >
        <h2>모달 제목</h2>
        <p>모달 내용</p>
      </motion.div>
    </>
  );
}
```

## Why

브라우저의 렌더링 파이프라인:

```
JavaScript → Style → Layout → Paint → Composite
```

- **Layout 트리거 속성** (width, height, top, left, margin, padding): 변경 시 Layout → Paint → Composite 전체 실행
- **Paint 트리거 속성** (background, color, box-shadow): Layout 건너뛰고 Paint → Composite 실행
- **Composite 전용 속성** (transform, opacity): Layout + Paint 건너뛰고 GPU 컴포지터만 실행

transform/opacity는 GPU가 별도 레이어에서 처리하므로:
1. 메인 스레드가 자유로움 (JavaScript 실행과 병렬)
2. 프레임당 처리 비용이 극히 낮음
3. 60fps(16.6ms/프레임) 안정적 유지

**정량적 효과:**
- width 애니메이션: 프레임당 5-15ms (Layout + Paint) → transform: 프레임당 0.1-0.5ms (Composite only)
- 60fps 유지: Layout 트리거 → 30fps 이하 프레임 드롭 빈번 / transform → 안정적 60fps
- 메인 스레드 여유: 애니메이션 중에도 입력 반응성 유지
- DevTools Performance에서 "Layout Shift" 경고 제거

**willChange 주의:** 애니메이션이 시작되기 전에만 적용하고, 항상 켜두면 GPU 메모리를 불필요하게 점유한다.

## References

- [MDN — CSS GPU animation](https://developer.mozilla.org/en-US/docs/Web/Performance/CSS_JavaScript_animation_performance)
- [Web.dev — Stick to Compositor-Only Properties](https://web.dev/articles/stick-to-compositor-only-properties-and-manage-layer-count)
- [CSS Triggers — 속성별 렌더링 파이프라인](https://csstriggers.com/)
