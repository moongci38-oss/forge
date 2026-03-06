# 02-product - 제품 전략 & 기획

> **영역**: A. 제품 사업 (Track A)
> SIGIL 파이프라인 S2(컨셉), S3(PRD/GDD), S4(기획 패키지) 산출물 저장소

---

## SIGIL 연결

| Stage | 이 폴더의 역할 | 참조 규칙 |
|:-----:|-------------|----------|
| S2 | 컨셉 문서 저장 (`projects/{project}/YYYY-MM-DD-s2-concept.md`) | sigil-compiled §S2 |
| S3 | PRD/GDD 저장 (`projects/{project}/YYYY-MM-DD-s3-prd.md`) | sigil-compiled §S3 |
| S4 | 기획 패키지 7종 저장 (`projects/{project}/YYYY-MM-DD-s4-*.md`) | sigil-compiled §S4 |

> 파이프라인 규칙, DoD, Gate 프로세스는 `.claude/rules/sigil-compiled.md`에 정의됨 — 여기서 재설명하지 않는다.

---

## 출력 구조

```
02-product/
├── projects/          SIGIL 프로젝트별 산출물
│   └── {project}/     YYYY-MM-DD-s{N}-{topic}.md
├── lean-canvas/       YYYY-MM-DD-{product}-canvas.md
├── business-plans/    YYYY-MM-DD-{product}-plan.md
├── pricing-models/    YYYY-MM-DD-{model}-comparison.md
├── product-specs/     YYYY-MM-DD-{product}-prd.md
├── roadmap/           YYYY-MM-DD-{product}-roadmap.md
└── gtm-strategy/      YYYY-MM-DD-{product}-gtm.md
```

---

## 활용 에이전트 & 스킬

**에이전트**: market-researcher, ux-researcher, academic-researcher, technical-writer, fact-checker, pipeline-orchestrator

**스킬**: product-manager-toolkit, agile-product-owner, requirements-clarity, concise-planning, micro-saas-launcher, ai-product, ai-wrapper-product, cto-advisor, prd, lean-canvas, pricing, gtm

---

## 에이전트 행동 규칙

1. SIGIL 프로젝트 산출물은 `projects/{project}/` 하위에 저장한다
2. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다
3. 일반 기획(특정 프로젝트와 무관)은 기존 폴더에 저장한다

---

*Last Updated: 2026-03-06*
