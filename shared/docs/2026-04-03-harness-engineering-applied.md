# 하네스 엔지니어링 Forge 전체 적용 기록

> 작성일: 2026-04-03
> 출처: AI 사용성연구소 EP.04 + Anthropic Engineering Blog (2026-03-24) + harness-project.zip
> 범위: Forge 전체 스킬/에이전트 57개 파일, 9개 커밋

---

## 핵심 원칙 요약

> **AI 출력 품질의 핵심 변수는 모델이 아니라 구조(하네스)다.**

### 1. Planner-Generator-Evaluator 분해

| 역할 | 책임 | 모델 |
|------|------|:----:|
| **Planner** | 요구사항 분석, 실행 계획, Rubric 포함 | Opus 4.6 |
| **Generator** | 계획에 따른 구현/생성, 자체검토 후 핸드오프 | Sonnet 4.6 |
| **Evaluator** | Rubric 기준 판정, 피드백 작성 | Sonnet 4.6 |

### 2. Rubric 선행 원칙

Evaluator가 사용할 평가 기준을 Generator 실행 **전**에 명시한다.
기준 없이 생성 → 검수에서 반드시 FAIL.

### 3. 관대함 방지 (Anti-Leniency)

> 출처: harness-project.zip `evaluator.md`

아래 생각이 들면 감점:
- "나쁘지 않은데..." → 감점
- "이 정도면 괜찮지 않나?" → 감점
- "전반적으로 잘 만들었으니 이 부분은 넘어가자" → 금지

### 4. 피드백 3요소

모든 피드백은 **위치 + 이유 + 방법** 3요소 필수.

```
나쁜 예: "코드가 지저분합니다"
좋은 예: "auth.ts 45~60줄에 중복 로직이 있습니다(위치).
          같은 토큰 검증 코드가 3번 반복되어 AI 슬롭입니다(이유).
          공통 함수 validateToken()으로 추출하세요(방법)."
```

### 5. 자기평가 분리

Generator가 자신의 산출물을 Evaluator로서 평가하지 않는다.
반드시 별도 에이전트가 수행.

### 6. Museum Quality

"Bootstrap 기본 느낌", AI 슬롭(무의미 반복·복붙·미사용 코드)을
Rubric에 명시적 불합격 언어로 포함한다.

### 7. Anthropic 핵심 원칙

> "하네스의 모든 컴포넌트는 모델이 혼자 할 수 없는 것에 대한 가정을 인코딩한다."
> — Anthropic Engineering Blog, 2026-03-24

- 필요 없는 컴포넌트는 추가하지 않는다 (복잡도 = 유지보수 비용)
- Evaluator 판단이 인간 판단과 다르면 Rubric을 반복 보정 (calibration loop)
- Planner는 ambitious scope — 보수적으로 축소하지 않는다

---

## 파일 기반 통신 프로토콜

에이전트 간 컨텍스트를 파일로 전달한다.

| 파일 | 작성자 | 읽는 자 | 내용 |
|------|--------|---------|------|
| `PGE_SPEC.md` | Planner | Generator, Evaluator | 설계서 + 기능 목록 + Rubric |
| `PGE_SELF_CHECK.md` | Generator | Evaluator | 자체 점검 결과 |
| `PGE_QA_REPORT.md` | Evaluator | Generator (피드백 시) | 판정 + 개선 지시 |

---

## QA Rubric (표준 기준)

> qa 스킬 기준. 전 파이프라인 공통 적용.

| 항목 | 가중치 | 즉시 불합격 |
|------|:------:|-----------|
| 기능성 | 40% | FR 미충족 1개라도 있으면 즉시 FAIL |
| 코드 품질 | 30% | AI 슬롭 감지 시 0점 |
| 아키텍처 | 20% | Spec 설계 의도 위반 시 0점 |
| 문서 | 10% | 주요 변경 미반영 시 5점 이하 |

**PASS**: 70점 이상 + 기능성 즉시 FAIL 없음

---

## 적용 범위 (총 57개 파일)

### Evaluator 역할 적용 (22개)

관대함 방지 + 피드백 3요소 + SELF_CHECK 맹신 금지

| 스킬/에이전트 | 적용 내용 |
|-------------|---------|
| `qa` | Rubric 4항목, AI Slop 체크리스트, 도메인별 즉시 불합격 기준 |
| `code-reviewer-base` | 피드백 위치+이유+방법 JSON 매핑, 관대함 방지 |
| `grants-review` | 5축 Rubric 관대함 방지, 1:1 직접 대조 |
| `grants-review-evaluator` | 평가위원 채점 관대함 방지 |
| `grants-review-guidelines` | 작성요령 누락 "괜찮겠지" 금지 |
| `grants-review-data` | 출처 불명 수치 "대략 맞겠지" 금지 |
| `spec-compliance-checker` | Spec 1:1 대조 관대함 방지 |
| `asset-critic` | 6축 Rubric 엄격 적용 |
| `ux-audit` | UX 패턴 관대함 방지 |
| `audit-*` (5개) | 각 감사 영역별 관대함 방지 |
| `axis-*` (5개) | ACHCE 5축 평가 관대함 방지 |
| `benchmark` | 성능 기준 관대함 방지 |
| `canary-judge` | 카나리 판정 관대함 방지 |
| `cto-advisor` | 기술 검토 관대함 방지 |
| `performance-checker` | 성능 측정 관대함 방지 |
| `test-quality-checker` | 테스트 품질 관대함 방지 |
| `ui-quality-checker` | UI 품질 관대함 방지 |
| `security-best-practices-reviewer` | 보안 관대함 방지 |
| `ux-researcher` | UX 리서치 관대함 방지 |
| `inspection-checklist` | 점검 기준 관대함 방지 |
| `code-quality-rules` | 코드 품질 기준 관대함 방지 |
| `react-best-practices` | React 패턴 관대함 방지 |
| `system-audit` | 시스템 감사 관대함 방지 |

### Generator 역할 적용 (15개)

Rubric 선행 확인 + Museum quality + 자체 점검 후 핸드오프

| 스킬/에이전트 | 적용 내용 |
|-------------|---------|
| `grants-writer` | 5축 Rubric 선행, 즉시 불합격 3가지, 자체 점검 체크리스트 |
| `grants-write (Phase 2.5)` | Writer에 Rubric 전달 전 Phase 2.5 추가 |
| `frontend-design` | Typography/Color/Layout/Motion/AI Slop Rubric |
| `content-creator` | SEO/Brand Voice/CTA/AI Slop/Fact-check Rubric |
| `game-asset-generate` | asset-critic 연결, 6축 Rubric 확인, AI 슬롭 패턴 명시 |
| `pptx` | 슬라이드 품질 Rubric 선행 |
| `soul-prompt-craft` | 프롬프트 품질 Museum quality |
| `style-train` | 스타일 일관성 Rubric |
| `subagent-creator` | 에이전트 설계 품질 기준 |
| `hook-creator` | 훅 품질 Rubric |
| `slash-command-creator` | 커맨드 품질 기준 |
| `rd-plan` | R&D 계획 품질 Rubric |
| `gdd-writer` | GDD 품질 Museum quality |
| `technical-writer` | 기술문서 품질 Rubric |
| `doc-writer` | 문서 품질 Museum quality |
| `spec-writer-base` | Spec 품질 기준 |

### Planner 역할 적용 (10개)

Ambitious scope + AI 기능 직조 + Rubric 포함

| 스킬/에이전트 | 적용 내용 |
|-------------|---------|
| `investigate` | 수정 전 QA Rubric 선행, 디버그 계획 ambitious scope |
| `concise-planning` | 계획 야심 있게, AI 기능 통합 |
| `writing-plans` | 작성 계획 Rubric 포함 |
| `requirements-clarity` | 요구사항 분석 ambitious |
| `autoplan` | 자동 계획 Rubric 포함 |
| `product-manager-toolkit` | PM 계획 ambitious scope |
| `grants-analyst` | 분석 보고서 ambitious scope |
| `grants-strategist` | 전략 방향 ambitious scope |
| `codebase-analyzer` | 코드베이스 분석 Rubric |
| `research-coordinator` | 리서치 조율 ambitious scope |
| `pipeline-orchestrator` | 파이프라인 조율 Rubric 포함 |

### 적용 불필요 (17개)

단순 조회/변환/라우팅 전용 도구 — 하네스 필요 없음

`hwp2pdf`, `library-search`, `rag-search`, `learn`, `playwright-*`, 기타 분석/수집 도구

---

## 신규 생성 파일

### `/pge` 스킬 (`skills/pge/SKILL.md`)

PGE 자동 오케스트레이터. 전용 파이프라인이 없는 작업용 ad-hoc PGE.

```
/pge <task>
/pge --rubric custom
/pge --cycles 2
```

- Phase 0: Rubric 확정
- Phase 1: Planner (Opus 4.6) — 설계 + Rubric 포함
- Phase 2: Generator (Sonnet 4.6) — 구현 + 자체검토
- Phase 3: Evaluator (Sonnet 4.6) — Rubric 기준 판정
- Phase 4: 피드백 루프 (최대 3사이클)

---

## 커밋 이력

| 커밋 | 내용 |
|------|------|
| `72698c6` | P0 qa Rubric + P1 forge-core.md 하네스 설계 원칙 + P2 /pge 스킬 신규 |
| `7bb1146` | grants-write Phase 2.5 Rubric 선행 + investigate QA 기준 |
| `b77b48f` | qa Playwright 테스트 + 도메인별 즉시 불합격 기준 |
| `ae16ea7` | Anthropic 블로그 원칙 (museum quality, calibration loop, ambitious scope) |
| `4d519ae` | harness-project.zip (관대함 방지, 피드백 3요소, 파일 프로토콜, 완료 보고) |
| `9397006` | 1차 일괄 6파일 (code-reviewer, grants-review, spec-compliance, asset-critic, frontend-design, content-creator) |
| `e0a9733` | 2차 일괄 5파일 (grants-review 3 에이전트, ux-audit, game-asset-generate) |
| `1a6a946` | grants-writer 에이전트 Generator 원칙 |
| `9df0bf4` | 전수조사 3차 44파일 (Evaluator 14 + Generator 8 + Planner 11 + 기타) |

---

## 출처

| 자료 | 핵심 기여 |
|------|---------|
| AI 사용성연구소 EP.04 | "구체적인 불합격 언어가 Generator 품질을 결정한다" |
| Anthropic Engineering Blog (2026-03-24) | "모든 컴포넌트는 모델이 혼자 할 수 없는 것에 대한 가정을 인코딩한다" |
| harness-project.zip `evaluator.md` | 관대함 방지 원칙, "이 정도면 괜찮지 않나?" 감점 |
| harness-project.zip `generator.md` | Museum quality, 자체검토 체크리스트 |
| harness-project.zip `planner.md` | Ambitious scope, AI 기능 직조 |
| harness-project.zip 파일 프로토콜 | PGE_SPEC / SELF_CHECK / QA_REPORT 3파일 통신 |
