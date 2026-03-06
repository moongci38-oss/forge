# 03-marketing - 마케팅 & 그로스

> **영역**: A. 제품 사업 (Track A)
> SIGIL 콘텐츠 트랙 마케팅 전략 + 일반 마케팅 산출물 저장소

---

## SIGIL 연결

SIGIL 콘텐츠 트랙 프로젝트의 마케팅 전략은 `projects/{project}/`에 저장.
파이프라인 규칙은 `.claude/rules/sigil-compiled.md` 참조.

---

## 출력 구조

```
03-marketing/
├── projects/         SIGIL 프로젝트별 마케팅 전략
│   └── {project}/    YYYY-MM-DD-{topic}.md
├── seo/              YYYY-MM-DD-keyword-analysis.md
├── campaigns/        YYYY-MM-DD-{campaign-name}.md
├── email-sequences/  YYYY-MM-DD-{sequence-name}.md
├── ads/              YYYY-MM-DD-{platform}-ads.md
└── analytics/        YYYY-MM-{month}-marketing-report.md
```

---

## 활용 에이전트 & 스킬

**에이전트**: search-ai-optimization-expert, market-researcher, technical-writer, fact-checker

**스킬**: seo-audit, competitive-ads-extractor, viral-generator-builder, email-sequence, lead-research-assistant, campaign, content-creator, marketing (plugin skills)

---

## 에이전트 행동 규칙

1. 특정 프로젝트의 마케팅 산출물은 `projects/{project}/` 하위에 저장한다
2. 프로젝트 폴더 내 파일명에서 프로젝트명을 제거한다
3. 일반 마케팅은 기존 폴더(seo/, campaigns/ 등)에 저장한다

---

*Last Updated: 2026-03-06*
