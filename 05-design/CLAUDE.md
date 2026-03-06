# 05-design - 디자인 & UX

> **영역**: A. 제품 사업 (Track A)
> SIGIL S4 UI/UX 기획서 저장소 + 프로젝트 디자인 자산

## SIGIL 연결

SIGIL S4 UI/UX 기획서는 `projects/{project}/YYYY-MM-DD-s4-uiux-spec.md`에 저장.
파이프라인 규칙은 `.claude/rules/sigil-compiled.md` §S4 참조.

---

## Cowork Plugin

디자인 전용 플러그인 없음. Figma/Canva 연동이 필요할 경우:
```bash
# marketing 플러그인의 Figma, Canva 커넥터 활용
claude plugin install marketing@knowledge-work-plugins --scope project
```

---

## Agent Teams

- **ux-researcher** ✅ — UX 분석 및 개선 제안
- **screenshot-capturer** ✅ — Playwright 기반 자동 캡처
- **screenshot-business-analyzer** ✅ — UI 비즈니스 로직 추출
- **portfolio-analyzer** ✅ — 포트폴리오 프로젝트 분석

---

## 활용 스킬

> 디자인 작업은 외부 도구(v0.dev, Figma AI 등) + 에이전트 중심으로 진행.
> 코드 구현 스킬(frontend-design 등)은 portfolio-project 워크스페이스에서 사용.

- **game-changing-features** ✅ — 10x 임팩트 기능 발굴 (디자인 방향성 도출 시)
- **viral-generator-builder** ✅ — 바이럴 UI 생성기 설계 (인터랙티브 도구 기획 시)

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
├── projects/       SIGIL 프로젝트별 디자인 자산
│   └── {project}/  YYYY-MM-DD-{topic}.{ext}
├── screenshots/    YYYY-MM-DD-{project}-{page}.png
├── ui-analysis/    YYYY-MM-DD-{project}-analysis.md
├── brand-assets/   {asset-name}.{ext}
└── mockups/        YYYY-MM-DD-{page}-mockup.md
```

### projects/ 규칙

- 특정 프로젝트의 디자인 자산(UI 시안, 목업, 스크린샷)은 `projects/{project}/` 하위에 저장
- 파일명에서 프로젝트명 제거 (폴더가 이미 프로젝트를 나타냄)
- 예: `projects/baduki/2026-02-26-main-ui-mockup.md`

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

## 에이전트 행동 규칙

1. 특정 프로젝트의 디자인 산출물은 `projects/{project}/` 하위에 저장한다
2. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다
3. 일반 디자인(브랜드 자산 등)은 기존 폴더(brand-assets/, mockups/ 등)에 저장한다

---

*Last Updated: 2026-03-06*
