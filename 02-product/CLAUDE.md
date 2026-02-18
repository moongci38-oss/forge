# 02-product - 제품 전략 & 기획 자동화 시스템

> 기존 `02-business-strategy` + `03-product-planning` (기획 파트) 통합
> **약점 영역**: ★★☆☆☆ → **AI 보완**: ★★★★★

---

## Cowork Plugins

### 즉시 설치 권장
```bash
claude plugin install product-management@knowledge-work-plugins --scope project
```
**커넥터**: Linear, Figma, Amplitude, Pendo
**제공 기능**: 스펙 작성, 로드맵 관리, 사용자 리서치 자동화, A/B 테스트 분석

### Phase 2 설치 예정
```bash
claude plugin install data@knowledge-work-plugins --scope project
claude plugin install sales@knowledge-work-plugins --scope project
```

---

## Agent Teams

- **market-researcher** ✅ — 시장 규모, 경쟁사 분석
- **ux-researcher** ✅ — 사용자 니즈 파악
- **academic-researcher** ✅ — 전략 연구 자료
- **technical-writer** ✅ — 기획서 & PRD 작성
- **fact-checker** ✅ — 데이터 검증

---

## 활용 스킬 (12개)

**전략 & 비즈니스**:
- **product-strategist** ✅ — TAM/SAM/SOM 분석, 제품 포지셔닝
- **micro-saas-launcher** ✅ — Micro SaaS MVP 검증
- **pricing-strategy** ✅ — 수익 모델 설계 및 시뮬레이션
- **ceo-advisor** ✅ — CEO 관점 의사결정
- **cto-advisor** ✅ — 기술 아키텍처 의사결정
- **launch-strategy** ✅ — GTM 전략 수립

**기획 & 실행**:
- **product-manager-toolkit** ✅ — PRD/기획서 프레임워크
- **agile-product-owner** ✅ — 애자일 PO 백로그 관리
- **requirements-clarity** ✅ — 요구사항 명확화
- **concise-planning** ✅ — 간결한 계획 수립

**AI 제품**:
- **ai-product** ✅ — AI 제품 기획
- **ai-wrapper-product** ✅ — AI API 래퍼 설계

---

## 핵심 시스템: Discovery → Strategy → Execution 파이프라인

```
1. market-researcher    → 시장 규모, 경쟁사 분석 (TAM/SAM/SOM)
2. product-strategist   → 포지셔닝 전략
3. pricing-strategy     → 수익 모델 시뮬레이션
4. micro-saas-launcher  → MVP 범위 정의
5. agile-product-owner  → 백로그 및 스프린트 계획
6. launch-strategy      → GTM 로드맵
7. technical-writer     → 최종 기획서/PRD 작성
```

---

## 자동화 스케줄

- **주간**: 시장 분석 업데이트, 백로그 리뷰
- **월간**: 전략 리뷰 및 조정 (GO/NO-GO 판단)
- **분기**: 비즈니스 전략 전체 재검토

---

## 출력 구조

```
02-product/
├── lean-canvas/       YYYY-MM-DD-{product}-canvas.md
├── business-plans/    YYYY-MM-DD-{product}-plan.md
├── pricing-models/    YYYY-MM-DD-{model}-comparison.md
├── product-specs/     YYYY-MM-DD-{product}-prd.md
├── roadmap/           YYYY-MM-DD-{product}-roadmap.md
└── gtm-strategy/      YYYY-MM-DD-{product}-gtm.md
```

---

## 외부 도구 연계

- **PrometAI**: AI 사업계획서, 재무 예측 자동 생성
- **Lean Canvas AI**: 린 캔버스 자동 작성
- **Linear**: 로드맵 & 이슈 트래킹

---

## 사용 예시

**신규 Micro SaaS 기획**:
```
"AI 이력서 작성 SaaS 기획해줘"
→ market-researcher: TAM/SAM/SOM 데이터 수집
→ product-strategist: 포지셔닝 전략
→ pricing-strategy: Freemium vs Subscription 비교
→ micro-saas-launcher: MVP 기능 범위 정의
→ agile-product-owner: 초기 백로그 작성
→ technical-writer: 최종 기획서
→ 출력: business-plans/2026-02-18-ai-resume-saas-plan.md
```

**PRD 작성**:
```
"랜딩 페이지 빌더 기능 PRD 작성해줘"
→ requirements-clarity: 요구사항 명확화
→ product-manager-toolkit: PRD 템플릿 적용
→ technical-writer: 완성된 PRD
→ 출력: product-specs/2026-02-18-landing-builder-prd.md
```

---

*Last Updated: 2026-02-18*
