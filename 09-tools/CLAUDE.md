# 09-tools - AI 워크스페이스 운영 도구

> **영역**: C. 시스템 영역 (Tools & Systems)
> 기존 `07-operations/dev-tools/` 이동 + `06-project-management/` 통합

---

## 활용 스킬

- **kaizen** ✅ — 지속적 개선, 프로세스 최적화
- **requirements-clarity** ✅ — 요구사항 명확화
- **concise-planning** ✅ — 간결한 계획 수립

---

## 폴더 구조

```
09-tools/
├── skills-library/        스킬 원본 라이브러리
│   ├── aitmpl/            aitmpl.com 공식 스킬
│   ├── marketingskills/   마케팅 전문 스킬
│   └── community/         커뮤니티 스킬
├── components-library/    컴포넌트 원본
│   ├── agents/            에이전트 원본
│   ├── commands/          슬래시 커맨드 원본
│   ├── hooks/             훅 원본
│   └── mcps/              MCP 설정 원본
├── automation/            cron 스크립트, 자동화
├── prompts/               프롬프트 라이브러리
├── project-mgmt/          프로젝트 추적 템플릿
└── processes/             워크플로 문서
```

---

## 스킬 관리

```bash
# 목록 확인
bash scripts/manage-skills.sh list

# 스킬 활성화
bash scripts/manage-skills.sh enable aitmpl/business-marketing/product-strategist
bash scripts/manage-skills.sh enable marketingskills/seo-audit

# 스킬 비활성화
bash scripts/manage-skills.sh disable product-strategist

# portfolio-project에 dev 스킬 동기화
bash scripts/manage-skills.sh sync ~/mywsl_workspace/portfolio-project
```

## 컴포넌트 관리

```bash
# 목록 확인
bash scripts/manage-components.sh list
bash scripts/manage-components.sh list agents

# 에이전트 활성화
bash scripts/manage-components.sh enable agents seo-analyzer

# portfolio-project에 동기화
bash scripts/manage-components.sh sync ~/mywsl_workspace/portfolio-project
```

---

## 라이브러리 원본 경로

```
09-tools/skills-library/          ← manage-skills.sh 참조 경로
09-tools/components-library/      ← manage-components.sh 참조 경로
```

⚠️ **라이브러리 원본 직접 수정 금지** — 항상 스크립트로 관리

---

## 자동화 스케줄

- **주간**: 신규 스킬/컴포넌트 검토 (aitmpl.com)
- **월간**: 라이브러리 업데이트 및 portfolio-project 동기화

---

## Agent Teams

- **orchestrator** ✅ — 워크플로우 전체 조정
- **technical-writer** ✅ — 프로세스 문서화

---

*Last Updated: 2026-02-18*
