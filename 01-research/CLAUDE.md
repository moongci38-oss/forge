# 01-research - 시장조사 & 분석 자동화 시스템

> **약점 영역**: ★☆☆☆☆ → **AI 보완**: ★★★★☆

---

## Cowork Plugin: enterprise-search ⭐ 즉시 설치 권장

```bash
claude plugin install enterprise-search@knowledge-work-plugins --scope project
```

**커넥터**: Slack, Notion, Guru, Jira, Asana
**제공 기능**: 이전 리서치 자산 통합 검색, 중복 조사 방지

### Phase 2 설치 예정
```bash
claude plugin install data@knowledge-work-plugins --scope project
```

---

## Agent Teams

### 조정자
- **research-coordinator** ✅ — 리서치 요청 분석 → 태스크 분배 → 결과 종합

### 전문가 팀
- **market-researcher** ✅ — 시장 규모, 경쟁사, 트렌드
- **academic-researcher** ✅ — 학술 논문, 연구 리포트
- **fact-checker** ✅ — 데이터 검증, 출처 확인

---

## 활용 스킬

- **research-engineer** ✅ — 체계적 리서치, 기술 동향 분석
- **competitor-alternatives** ✅ — 경쟁사 비교, 대안 서비스 매핑
- **lead-research-assistant** ✅ — 리드/고객 리서치 자동화
- **seo-audit** ✅ — SEO 키워드 기반 시장 수요 파악
- **context7-auto-research** ✅ — 최신 라이브러리/프레임워크 문서

---

## 핵심 시스템: 9가지 자료 타입

| 타입 | 담당 에이전트 | 출처 | 주기 |
|------|------------|------|------|
| 논문 | academic-researcher | arXiv, Semantic Scholar | 월간 |
| 기사 | market-researcher | Brave Search, HN, TechCrunch | 매일 |
| 공식문서 | (Context7 직접 사용) | Context7 | 주간 |
| 백서 | academic-researcher | Gartner, McKinsey | 분기 |
| 오픈소스 | (Brave Search + GitHub) | GitHub Trending | 주간 |
| 영상 | (수동 + 요약 요청) | YouTube 컨퍼런스 | 월간 |
| 커뮤니티 | market-researcher | Reddit, HN | 주간 |
| SNS/트렌드 | market-researcher | Product Hunt, X | 매일 |
| 케이스 스터디 | research-coordinator | 서적, 리포트 | 필요 시 |

---

## 자동화 워크플로우

### 매일 (일일 트렌드 수집)
```
"market-researcher로 AI, SaaS, Micro SaaS 최신 동향을 Brave Search로 조사하여
trends/YYYY-MM-DD-daily.md에 저장. 출처(URL, 날짜) 반드시 포함"
```

### 주간 (종합 리포트)
```
"research-coordinator로 지난 7일 트렌드를 종합 분석하여
weekly/YYYY-WW-report.md 생성"
```

### 월간 (심층 분석)
```
"research-coordinator로 논문, 백서 포함 종합 분석 리포트
monthly/YYYY-MM-comprehensive-report.md 생성"
```

---

## 출력 구조

```
01-research/
├── trends/          YYYY-MM-DD-{topic}-trend.md
├── competitors/     YYYY-MM-DD-{company}-analysis.md
├── market-data/     YYYY-MM-DD-{market}-report.md
├── templates/       리서치 템플릿
└── weekly/          YYYY-WW-report.md
```

---

## 사용 예시

**경쟁사 분석**:
```
"Notion 경쟁사 분석해줘"
→ research-coordinator
  ├─ market-researcher: Brave Search로 경쟁사 수집
  ├─ competitor-alternatives: 비교표 생성
  ├─ seo-audit: 키워드 전략 분석
  └─ fact-checker: 데이터 검증
→ 출력: competitors/2026-02-18-notion-analysis.md
```

---

*Last Updated: 2026-02-18*
