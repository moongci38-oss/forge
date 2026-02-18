# 05-design - 디자인 & UX 자동화 시스템

> **약점 영역**: ★☆☆☆☆ → **AI 보완**: ★★★★★ (가장 높음)

---

## Agent Teams

- **ux-researcher** ✅ — UX 분석 및 개선 제안
- **screenshot-capturer** ✅ — Playwright 기반 자동 캡처
- **screenshot-business-analyzer** ✅ — UI 비즈니스 로직 추출
- **portfolio-analyzer** ✅ — 포트폴리오 프로젝트 분석

---

## 핵심 시스템: 개발자 디자인 워크플로

```
1. v0.dev              → shadcn/ui 기반 컴포넌트 프로토타입 (외부)
2. Figma AI            → 전체 페이지 레이아웃 정리 (외부)
3. Midjourney          → 히어로 이미지/일러스트 생성 (외부)
4. screenshot-capturer → Playwright로 포트폴리오 UI 캡처
5. screenshot-business-analyzer → 비즈니스 로직 추출
6. ux-researcher       → UX 개선 제안
7. (portfolio-project에서) → Claude Code로 코드 구현
```

---

## 외부 도구 연계 (핵심!)

| 도구 | 용도 | 평가 |
|------|------|:----:|
| **v0.dev** | React 컴포넌트 즉시 생성 | ★★★★★ |
| **Figma AI** | 디자인 생성 및 편집 | ★★★★★ |
| **Lovable** | 풀스택 앱 빌더 | ★★★★★ |
| **Bolt.new** | 브라우저에서 즉시 생성 | ★★★★☆ |
| **Midjourney** | 비주얼 에셋, 일러스트 | ★★★★☆ |

---

## 출력 구조

```
05-design/
├── screenshots/    YYYY-MM-DD-{project}-{page}.png
├── ui-analysis/    YYYY-MM-DD-{project}-analysis.md
├── brand-assets/   {asset-name}.{ext}
└── mockups/        YYYY-MM-DD-{page}-mockup.md
```

---

## 자동화 스케줄

- **주간**: 포트폴리오 프로젝트 UI 업데이트 확인
- **필요 시**: 스크린샷 자동 캡처 및 UX 분석

---

## 사용 예시

**포트폴리오 UI 캡처**:
```
"portfolio-project 랜딩 페이지 스크린샷 캡처하고 UX 분석해줘"
→ screenshot-capturer: Playwright로 스크린샷 캡처
→ screenshot-business-analyzer: UI 구조 분석
→ ux-researcher: UX 개선 제안 (모바일/데스크톱)
→ 출력: screenshots/2026-02-18-portfolio-landing.png
         ui-analysis/2026-02-18-portfolio-ux-analysis.md
```

**v0.dev 프롬프트 생성**:
```
"포트폴리오 히어로 섹션 v0.dev 프롬프트 작성해줘"
→ ux-researcher: UX 모범 사례 조사
→ 출력: mockups/2026-02-18-hero-v0-prompt.md
```

---

*Last Updated: 2026-02-18*
