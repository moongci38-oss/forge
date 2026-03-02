# 파일명 규칙

## 기본 형식
```
{YYYY-MM-DD}-{description}.{ext}
```

## 예시
```
✅ 2026-02-16-market-analysis-saas.md
✅ 2026-02-16-pricing-model-v2.xlsx
✅ 2026-Q1-marketing-report.md

❌ marketAnalysis.md        (날짜 없음)
❌ 2026_02_16_report.md    (언더스코어 사용)
❌ analysis-02-16.md       (연도 누락)
```

## 폴더별 규칙

### 01-research/
- `projects/{project}/YYYY-MM-DD-s{N}-{topic}.md` (SIGIL 프로젝트별 리서치)
- `trends/YYYY-MM-DD-{topic}-trend.md`
- `competitors/YYYY-MM-DD-{company}-analysis.md`
- `market-data/YYYY-MM-DD-{market}-report.md`
- `weekly/YYYY-WW-report.md`

### 02-product/
- `projects/{project}/YYYY-MM-DD-s{N}-{topic}.md` (SIGIL 프로젝트별 컨셉/PRD/GDD)
- `lean-canvas/YYYY-MM-DD-{product}-canvas.md`
- `pricing-models/YYYY-MM-DD-{model}-comparison.md`
- `business-plans/YYYY-MM-DD-{product}-plan.md`
- `product-specs/YYYY-MM-DD-{product}-prd.md`
- `roadmap/YYYY-MM-DD-{product}-roadmap.md`
- `gtm-strategy/YYYY-MM-DD-{product}-gtm.md`

### 03-marketing/
- `projects/{project}/YYYY-MM-DD-{topic}.md` (프로젝트별 마케팅 전략)
- `seo/YYYY-MM-DD-keyword-analysis.md`
- `campaigns/YYYY-MM-DD-{campaign-name}.md`
- `email-sequences/YYYY-MM-DD-{sequence-name}.md`
- `ads/YYYY-MM-DD-{platform}-ads.md`
- `analytics/YYYY-MM-{month}-marketing-report.md`

### 04-content/
- `projects/{project}/YYYY-MM-DD-s{N}-{topic}.md` (SIGIL 프로젝트별 콘텐츠)
- `blog-posts/YYYY-MM-DD-{title-slug}.md`
- `newsletters/YYYY-MM-DD-newsletter-{number}.md`
- `docs/YYYY-MM-DD-{topic}.md`
- `social-media/YYYY-MM-DD-{platform}-posts.md`

### 05-design/
- `projects/{project}/YYYY-MM-DD-{topic}.{ext}` (프로젝트별 디자인 자산)
- `screenshots/YYYY-MM-DD-{project}-{page}.png`
- `ui-analysis/YYYY-MM-DD-{project}-analysis.md`
- `brand-assets/YYYY-MM-DD-{asset-name}.{ext}`
- `mockups/YYYY-MM-DD-{page}-mockup.md`

### 06-finance/ ⛔
- `invoices/YYYY-MM-DD-{client}.pdf`
- `expenses/YYYY-MM-expenses.xlsx`
- `tax-reports/YYYY-부가세-신고.pdf`

### 07-legal/ ⛔
- `contracts/YYYY-MM-DD-{client}-contract.pdf`
- `policies/terms-of-service.md`
- `nda/YYYY-MM-DD-{party}-nda.pdf`

### 08-admin/
- `calendar/YYYY-annual-calendar.md`
- `insurance/YYYY-MM-DD-{type}-policy.pdf`

### docs/ (프로젝트 공통 구조)
- `guides/YYYY-MM-DD-{topic}-guide.md`
- `tech/YYYY-MM-DD-{topic}.md`
- `planning/active/YYYY-MM-DD-{plan-name}.md`
- `planning/done/YYYY-MM-DD-{plan-name}.md`
- `reviews/YYYY-MM-DD-{review-name}.md`
- `infrastructure/YYYY-MM-DD-{topic}.md`
- `shared/` — trine-sync 자동 배포, 수동 편집 금지
- `trine/` — trine-sync 자동 배포, 수동 편집 금지
