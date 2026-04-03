# 종합 적용 계획 보고서
> 분석 영상: ①하네스 엔지니어링 EP.04 (AI 사용성연구소) | ②AI 모델 성능 경쟁과 하네스 엔지니어링 (안될공학) | 작성일: 2026-04-03

---

## 핵심 요약
두 영상 모두 Anthropic 공식 블로그(2026-03-24)의 **Planner-Generator-Evaluator 3-에이전트 하네스 구조**를 중심으로, AI 성능의 핵심 변수가 모델이 아닌 **구조(하네스)** 임을 실증·분석한다. 우리 Forge 시스템은 이미 이 구조의 개념적 기반(axis-harness, qa, investigate 에이전트)을 갖추고 있으나, **자동 오케스트레이션과 평가 Rubric 명시화**가 부재하다. 즉시 적용 가능한 핵심은 P0: **qa 스킬에 가중치 기반 합격/불합격 기준 추가** 1건이다.

---

## 영상별 주요 인사이트 종합

| 영상 | 핵심 제안 | 우리 시스템 적용 여부 |
|------|---------|:-----------------:|
| EP.04 (AI 사용성연구소) | Planner-Generator-Evaluator 자동 체인 + Rubric 명시화 | 부분 (개별 에이전트 존재, 체인 없음) |
| EP.04 | /clear + CLAUDE.md = Context Reset 패턴 | 적용 |
| EP.04 | 평가기준표 문구가 Generator 결과물을 결정 | 미적용 |
| 안될공학 | 업무 분해 → 하네스 설계 역량이 서비스 경쟁력 | 부분 (Forge 파이프라인이 이 방향) |
| 안될공학 | API-first + AI가 잘 쓸 수 있는 권한 구조 | 미적용 (제품 전략 수준) |
| 안될공학 | NVIDIA Dynamo (데이터센터 에이전트 OS) | 미사용 (우리 규모에 해당 없음) |

---

## 현재 시스템 대비 갭 분석

| 기능/패턴 | 영상 출처 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|---------|:--:|:----:|:----:|
| 평가 Rubric (가중치+합격기준) | EP.04 | `qa` 스킬에 체크리스트만 | Rubric 없음 | H | L |
| Planner-Generator-Evaluator 자동 체인 | EP.04 | 개별 에이전트 분리됨, 자동 호출 없음 | 오케스트레이터 없음 | M | M |
| 하네스 설계 원칙 가이드라인 | 안될공학 | `forge-core.md`에 병렬 실행 원칙만 | 하네스 설계 가이드 없음 | M | L |
| 자기평가 분리 원칙 명시 | EP.04 | hooks로 일부 통제 | 명시적 정책 없음 | L | L |
| NVIDIA Dynamo | 안될공학 | 미사용 | 우리 규모에 해당 없음 | L | — |

---

## 꼭 필요한 적용 항목 (선별 기준: 영향도 High + 실현 가능)

### P0 — 즉시 적용 (이번 주)

- **[Forge]** `qa` 스킬 Rubric 명시화
  - 현황: 체크리스트만 존재, 합격/불합격 판정 기준 없음
  - 변경: 가중치 기반 4항목 Rubric 추가 (예: 기능성 40%, 코드 품질 30%, 아키텍처 20%, 문서 10%)
  - "AI 슬롭 불합격" 등 구체적 언어 추가
  - 기대 효과: qa 스킬 실행 시 일관된 합격 기준으로 산출물 품질 향상
  - 소요 시간: 30분

### P1 — 단기 (이번 달)

- **[Forge]** `forge-core.md`에 하네스 설계 원칙 섹션 추가
  - 현황: 병렬 실행 원칙만 있음
  - 변경: "업무를 Planner-Generator-Evaluator로 분해하는 기준" + "자기평가 분리 원칙" 추가
  - 기대 효과: 에이전트 스폰 시 일관된 역할 분리 패턴 적용

### P2 — 중기 (다음 분기)

- **[Forge]** Planner-Generator-Evaluator 자동 오케스트레이션 스킬
  - 현황: `planner`, `generator`, `evaluator` 개념이 여러 에이전트에 분산됨
  - 변경: 오케스트레이터 스킬이 3개 에이전트를 자동 순차 호출 + 피드백 루프 (최대 3회)
  - 기대 효과: 대형 기능 개발 시 품질 향상 자동화

---

## 제외 항목 (이유 포함)

| 항목 | 제외 이유 |
|------|---------|
| NVIDIA Dynamo 도입 | 데이터센터 규모 인프라. 우리 워크로드에 해당 없음 |
| Playwright MCP 설치 | 현재 `.mcp.json`에 없고, blocking 이슈 없음. 필요 시 별도 검토 |
| Context Reset 자동화 | 이미 /clear + CLAUDE.md 패턴으로 적용됨 |
| Speculative Decoding 활용 | 모델 서빙 레이어 통제 밖 |
| API-first 제품 전략 | 중기 비즈니스 전략 결정 필요. 단기 적용 부적합 |

---

## 실행 체크리스트

- [ ] **P0**: `qa` 스킬 Rubric 명시화 (담당: Forge, 이번 주)
- [ ] **P1**: `forge-core.md` 하네스 설계 원칙 섹션 추가 (담당: Forge, 이번 달)
- [ ] **P2 준비**: Planner-Generator-Evaluator 오케스트레이터 스킬 설계 시작 (담당: Forge)

---

## 참고 영상

| 영상 | URL | 분석 파일 |
|------|-----|---------|
| 하네스 엔지니어링 EP.04 (AI 사용성연구소) | https://youtu.be/hjIxPpJyYHs | `01-research/videos/analyses/2026-04-03-hjIxPpJyYHs-...-analysis.md` |
| AI 모델 성능 경쟁과 하네스 엔지니어링 (안될공학) | https://youtu.be/g6YesZMG40s | `01-research/videos/analyses/2026-04-03-g6YesZMG40s-...-analysis.md` |
| Anthropic 공식 블로그 (2026-03-24) | https://www.anthropic.com/engineering/harness-design-long-running-apps | 팩트체크 근거 |
