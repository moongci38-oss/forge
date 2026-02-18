# Skills Library

마스터 스킬 저장소. 모든 스킬의 원본이 여기에 보관된다.

## 구조

```
skills-library/
├── aitmpl/                  ← aitmpl.com (davila7/claude-code-templates)
│   ├── development/         ← 개발 스킬
│   │   ├── nestjs-expert/
│   │   ├── nextjs-best-practices/
│   │   └── postgres-best-practices/
│   ├── business-marketing/  ← 비즈니스/마케팅 스킬
│   │   ├── product-strategist/
│   │   ├── marketing-ideas/
│   │   ├── content-research-writer/
│   │   ├── copywriting/
│   │   ├── pricing-strategy/
│   │   └── ceo-advisor/
│   ├── ai-research/         ← AI 연구 스킬
│   │   └── brainstorming/
│   └── security/            ← 보안 스킬 (추후 추가)
│
├── marketingskills/         ← coreyhaines31/marketingskills (25 skills)
│   ├── page-cro/
│   ├── copywriting/
│   ├── email-sequence/
│   ├── seo-audit/
│   └── ... (25개)
│
└── community/               ← 기타 커뮤니티 스킬
```

## 활성화 방법

```bash
# 비개발 워크스페이스에 활성화
bash ~/business/scripts/manage-skills.sh enable aitmpl/business-marketing/product-strategist

# 포트폴리오 프로젝트에 개발 스킬 동기화
bash ~/business/scripts/manage-skills.sh sync ~/mywsl_workspace/portfolio-project
```

## 스킬 추가

### aitmpl에서
```bash
bash ~/business/scripts/manage-skills.sh install-aitmpl <skill-slug>
```

### 수동 추가
1. `skills-library/<source>/<category>/<skill-name>/` 디렉토리 생성
2. `SKILL.md` 파일 작성 (frontmatter + 내용)
3. `manage-skills.sh enable`로 활성화

## 출처

| Source | URL | Skills |
|--------|-----|--------|
| aitmpl | https://aitmpl.com | 600+ |
| marketingskills | https://github.com/coreyhaines31/marketingskills | 25 |

## 카테고리별 스킬 수 (aitmpl 전체)

| Category | Count |
|----------|-------|
| ai-research | 120 |
| development | 154 |
| business-marketing | 46 |
| creative-design | 39 |
| productivity | 36 |
| security | 35 |
| scientific | 139 |
| enterprise-communication | 33 |
| document-processing | 17 |
| workflow-automation | 14 |
| web-development | 11 |
| railway | 12 |
| utilities | 11 |
| sentry | 6 |
| media | 5 |
| video | 4 |
| database | 3 |
| analytics | 1 |
