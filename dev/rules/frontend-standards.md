# Frontend Standards (Global)

> All frontend projects (Portfolio, Business, GodBlade web) follow these standards.

## Smooth Scroll: Lenis

**Lenis**를 모든 프론트엔드 프로젝트의 표준 스무스 스크롤 라이브러리로 지정한다.

### 설치

```bash
pnpm add lenis
```

### 루트 레이아웃 설정 (Next.js App Router)

```tsx
// app/layout.tsx 또는 ClientProviders.tsx
"use client";

import { ReactLenis } from "lenis/react";

export function LenisProvider({ children }: { children: React.ReactNode }) {
  return (
    <ReactLenis
      root
      options={{
        lerp: 0.1,
        duration: 1.2,
        smoothWheel: true,
      }}
    >
      {children}
    </ReactLenis>
  );
}
```

### Framer Motion과의 공존

Lenis(스크롤 보간)와 Framer Motion(컴포넌트 애니메이션)은 서로 다른 레이어를 담당하므로 충돌 없이 공존한다.

| 라이브러리 | 담당 | 사용 예시 |
|-----------|------|---------|
| **Lenis** | 페이지 스크롤 보간 (60fps) | 루트 레이아웃에 한 번 설정 |
| **Framer Motion** | 컴포넌트 애니메이션 | `whileInView`, `AnimatePresence`, `useScroll` |

**주의사항:**
- Lenis는 `root` 옵션으로 body 스크롤만 오버라이드
- Framer Motion의 `useScroll`은 Lenis와 함께 동작 (window scroll event 기반)
- `prefers-reduced-motion: reduce` 시 Lenis의 `lerp`을 1로 설정하여 즉시 스크롤

### GSAP 비도입 근거

| 항목 | Framer Motion | GSAP |
|------|:---:|:---:|
| React 통합 | 네이티브 | 래퍼 필요 |
| SSR/Hydration | 자동 처리 | `useGSAP` 훅 필수 |
| 번들 사이즈 | 이미 설치됨 | +30KB (gzipped ~12KB) |
| Strict Mode | 호환 | cleanup 필수 |

Framer Motion이 `useScroll`, `useSpring`, `useTransform`으로 고급 스크롤 애니메이션을 이미 커버하므로, GSAP 추가는 이중 시스템을 만든다. **도입하지 않는다.**

## Animation Library: Framer Motion

- 모든 컴포넌트 애니메이션은 Framer Motion 사용
- `whileInView`로 스크롤 진입 애니메이션 (scroll reveal)
- `AnimatePresence`로 마운트/언마운트 전환
- `prefers-reduced-motion: reduce` 시 애니메이션 비활성화 필수

## AI 에이전트 행동 규칙

1. 새 프론트엔드 프로젝트 셋업 시 Lenis + Framer Motion 설치 확인
2. GSAP 도입 제안 금지 — Framer Motion으로 충분
3. 스무스 스크롤 요청 시 Lenis 사용 (CSS `scroll-behavior: smooth` 대신)
4. `prefers-reduced-motion` 지원 필수

---

*Last Updated: 2026-03-06*
