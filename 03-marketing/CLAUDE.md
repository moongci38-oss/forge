# 03-marketing - 마케팅 & 그로스 자동화 시스템

> 기존 `04-marketing` 이동 (번호 재배치)
> **약점 영역**: ★☆☆☆☆ → **AI 보완**: ★★★★☆

---

## Cowork Plugins ⭐ 즉시 설치 권장

```bash
# marketing 플러그인
claude plugin install marketing@knowledge-work-plugins --scope project
# enterprise-search (크로스 폴더 검색)
claude plugin install enterprise-search@knowledge-work-plugins --scope project
```

**marketing 커넥터**: Canva, Figma, HubSpot, Ahrefs
**enterprise-search 커넥터**: Slack, Notion, Guru, Jira, Asana

### Phase 2 설치 예정
```bash
claude plugin install sales@knowledge-work-plugins --scope project
claude plugin install customer-support@knowledge-work-plugins --scope project
```

---

## Agent Teams

- **seo-analyzer** ✅ — SEO 분석 및 최적화
- **market-researcher** ✅ — 타겟 및 경쟁사 분석
- **technical-writer** ✅ — 마케팅 콘텐츠 작성
- **fact-checker** ✅ — 데이터 검증

---

## 활용 스킬 (15개)

**SEO/검색**:
- **seo-audit** ✅ — SEO 전체 감사
- **programmatic-seo** ✅ — 프로그래매틱 SEO 대량 페이지
- **schema-markup** ✅ — 구조화 데이터 최적화

**광고/캠페인**:
- **competitive-ads-extractor** ✅ — 경쟁사 광고 분석
- **paid-ads** ✅ — 유료 광고 전략
- **viral-generator-builder** ✅ — 바이럴 도구 생성
- **marketing-psychology** ✅ — 설득 메시지 작성

**이메일/소셜**:
- **email-sequence** ✅ — 자동 이메일 시퀀스

**전환율/분석**:
- **page-cro** ✅ — 랜딩 페이지 전환율 최적화
- **onboarding-cro** ✅ — 온보딩 전환율 최적화
- **paywall-upgrade-cro** ✅ — 페이월 업그레이드 최적화
- **analytics-tracking** ✅ — GA4/GTM 분석 추적
- **referral-program** ✅ — 추천 프로그램 설계

**전략**:
- **lead-research-assistant** ✅ — 리드 리서치
- **free-tool-strategy** ✅ — 무료 도구 마케팅
- **launch-strategy** ✅ — 런칭 전략 수립

---

## 핵심 시스템

### SEO 자동화
```
1. seo-analyzer              → 키워드 리서치
2. programmatic-seo          → 대량 페이지 생성
3. schema-markup             → 구조화 데이터
4. seo-audit                 → 전체 감사
```

### 캠페인 자동화
```
1. competitive-ads-extractor → 경쟁사 광고 분석
2. marketing-psychology      → 설득 메시지 작성
3. email-sequence            → 자동 이메일 시퀀스
4. viral-generator-builder   → 바이럴 도구 생성
```

### 전환율 최적화 파이프라인
```
1. page-cro         → 랜딩 페이지 분석
2. onboarding-cro   → 온보딩 흐름 개선
3. paywall-upgrade-cro → 업셀 전략
4. analytics-tracking  → GA4 이벤트 설계
```

---

## 자동화 스케줄

- **매일**: SEO 순위 모니터링 (Brave Search)
- **주간**: 캠페인 최적화 제안
- **월간**: 마케팅 성과 분석 리포트

---

## 출력 구조

```
03-marketing/
├── seo/              YYYY-MM-DD-keyword-analysis.md
├── campaigns/        YYYY-MM-DD-{campaign-name}.md
├── email-sequences/  YYYY-MM-DD-{sequence-name}.md
├── ads/              YYYY-MM-DD-{platform}-ads.md
└── analytics/        YYYY-MM-{month}-marketing-report.md
```

---

## 외부 도구 연계

- **Semrush**: SEO 도구 (키워드, 경쟁사 트래픽)
- **Blaze**: AI 마케팅 자동화
- **Jasper**: AI 카피라이팅

---

## 사용 예시

**SEO 감사**:
```
"사이트 SEO 전체 감사해줘"
→ seo-analyzer: 현재 SEO 상태 분석
→ seo-audit: 개선사항 리스트
→ schema-markup: 구조화 데이터 추가 제안
→ 출력: seo/2026-02-18-seo-audit.md
```

**이메일 시퀀스**:
```
"SaaS 무료 체험 → 유료 전환 이메일 시퀀스 (5개)"
→ email-sequence: 5단계 시퀀스 작성
→ marketing-psychology: 설득 요소 강화
→ 출력: email-sequences/2026-02-18-trial-to-paid.md
```

---

*Last Updated: 2026-02-18*
