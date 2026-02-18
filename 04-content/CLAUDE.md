# 04-content - 콘텐츠 제작 자동화 시스템

> 기존 `03-product-planning` (콘텐츠 파트) 분리 독립
> **약점 영역**: ★★☆☆☆ → **AI 보완**: ★★★★★

---

## Cowork Plugin

```bash
claude plugin install marketing@knowledge-work-plugins --scope project
```

---

## Agent Teams

- **technical-writer** ✅ — 주요 작성자 (블로그, 뉴스레터, 문서)
- **seo-analyzer** ✅ — SEO 최적화
- **fact-checker** ✅ — 사실 검증
- **academic-researcher** ✅ — 깊이 있는 콘텐츠 자료
- **market-researcher** ✅ — 트렌드 키워드 수집

---

## 활용 스킬 (8개)

- **content-creator** ✅ — SEO 최적화 콘텐츠, 브랜드 보이스
- **content-research-writer** ✅ — 리서치 기반 작성
- **copywriting** ✅ — 설득력 있는 카피
- **copy-editing** ✅ — 편집 및 교정
- **content-strategy** ✅ — 콘텐츠 전략 수립
- **social-content** ✅ — 소셜 미디어 콘텐츠 변환
- **seo-audit** ✅ — SEO 감사
- **programmatic-seo** ✅ — 대량 콘텐츠 생성

---

## 핵심 시스템: 콘텐츠 파이프라인

```
1. market-researcher        → 트렌드 키워드 선정
2. content-research-writer  → 자료 수집 및 리서치
3. technical-writer         → 초안 작성
4. seo-analyzer             → 키워드, 메타태그 최적화
5. fact-checker             → 사실 확인 및 검증
6. copy-editing             → 최종 편집 및 교정
7. social-content           → SNS용 포맷 변환
```

---

## 자동화 스케줄

- **주 2회**: 블로그 포스트 초안 생성
- **주간**: SEO 최적화 및 콘텐츠 발행
- **월간**: 콘텐츠 캘린더 계획 수립

---

## 출력 구조

```
04-content/
├── blog-posts/         YYYY-MM-DD-{title-slug}.md
├── newsletters/        YYYY-MM-DD-newsletter-{number}.md
├── docs/               YYYY-MM-DD-{topic}.md
└── social-media/       YYYY-MM-DD-{platform}-posts.md
```

---

## 외부 도구 연계

- **Writesonic**: AI 콘텐츠 대량 생성
- **SurferSEO**: SEO 최적화 (키워드 밀도, 경쟁 분석)
- **Jasper**: AI 카피라이팅

---

## 사용 예시

**블로그 포스트 생성**:
```
"AI 자동화 도구 Top 10 블로그 포스트 작성해줘"
→ market-researcher: 트렌드 키워드 확인
→ content-research-writer: 자료 수집
→ technical-writer: 초안 작성 (2000자)
→ seo-analyzer: SEO 최적화
→ fact-checker: 사실 검증
→ copy-editing: 최종 교정
→ social-content: LinkedIn/Twitter용 변환
→ 출력: blog-posts/2026-02-18-ai-automation-top-10.md
```

**뉴스레터 작성**:
```
"2월 SaaS 트렌드 뉴스레터 작성해줘"
→ market-researcher: 이달의 주요 SaaS 뉴스 수집
→ technical-writer: 뉴스레터 초안
→ copy-editing: 교정
→ 출력: newsletters/2026-02-18-newsletter-001.md
```

---

*Last Updated: 2026-02-18*
