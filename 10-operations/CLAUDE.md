# 10-operations - 서비스 운영

> **영역**: A. 제품 사업 (Track A, 서비스 런칭 이후)
> 시장조사 → 기획 → 마케팅 → **운영** 사이클의 마지막 단계

## SIGIL 연결

SIGIL S2 Go/No-Go에서 운영 지표(`metrics/`)를 참고하여 시장 기회를 평가한다.
Handoff 문서(`handoff-to-dev/`, `handoff-from-dev/`)는 SIGIL↔Trine 전환 시 사용.

---

## Agent Teams

- **market-researcher** ✅ — 사용자 지표 해석, 경쟁사 모니터링
- **technical-writer** ✅ — 릴리즈 노트, 운영 문서 작성
- **ux-researcher** ✅ — 고객 피드백 분석, UX 개선 제안
- **fact-checker** ✅ — 지표 데이터 검증
- **pipeline-orchestrator** ✅ — 복잡한 운영 워크플로우 조정

---

## 활용 스킬

- **product-manager-toolkit** ✅ — 지표 기반 의사결정, 우선순위
- **agile-product-owner** ✅ — 스프린트 리뷰, 백로그 반영
- **kaizen** ✅ — 운영 프로세스 지속적 개선
- **analytics-tracking** ✅ — GA4/GTM 이벤트 모니터링
- **page-cro** ✅ — 전환율 개선 실험

---

## 핵심 업무 & 출력 구조

```
10-operations/
├── metrics/       서비스 지표 대시보드
│                  YYYY-MM-metrics-report.md
│                  → MRR, DAU, 이탈률, NPS 월간 기록
│
├── releases/      릴리즈 노트
│                  YYYY-MM-DD-v{version}-release.md
│                  → 배포 기록, 변경사항, 영향 범위
│
├── incidents/     장애 & 이슈 기록
│                  YYYY-MM-DD-incident-{slug}.md
│                  → 원인, 대응, 재발 방지책
│
└── support/       고객 피드백 & 지원
                   YYYY-MM-DD-feedback-summary.md
                   → 반복 문의, 기능 요청, 불만 패턴
```

---

## 자동화 워크플로우

### 월간 지표 리포트
```
"지난달 서비스 지표 정리해줘"
→ analytics-tracking: GA4 주요 이벤트 데이터 요약
→ product-manager-toolkit: 지표 해석 및 액션 아이템
→ 출력: metrics/2026-02-metrics-report.md
```

### 릴리즈 노트 작성
```
"v1.2.0 릴리즈 노트 작성해줘"
→ technical-writer: 변경사항 → 사용자 언어로 변환
→ 출력: releases/2026-02-18-v1.2.0-release.md
```

### 고객 피드백 분석
```
"이번 달 고객 문의 패턴 분석해줘"
→ ux-researcher: 피드백 카테고리화 및 인사이트
→ agile-product-owner: 백로그 반영 우선순위
→ 출력: support/2026-02-feedback-summary.md
```

### 장애 회고 (Post-mortem)
```
"오늘 결제 오류 장애 회고 문서 작성해줘"
→ technical-writer: 타임라인, 원인, 재발방지
→ 출력: incidents/2026-02-18-incident-payment-error.md
```

---

## 운영 사이클 연결

```
10-operations/metrics/     → 인사이트 발견
       ↓
02-product/roadmap/        → 다음 기능 우선순위 결정
       ↓
02-product/product-specs/  → PRD 작성
       ↓
portfolio-project/         → 개발 구현
       ↓
10-operations/releases/    → 릴리즈 노트 발행
```

---

*Last Updated: 2026-03-06*
