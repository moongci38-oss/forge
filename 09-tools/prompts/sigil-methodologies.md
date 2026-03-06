# SIGIL 파이프라인 필수/선택 방법론 구현 가이드

> SIGIL S1~S4 규칙에서 참조하는 방법론의 핵심 요약 + 적용 방법.
> 에이전트가 방법론 적용 시 이 문서를 참조한다.

---

## S1 리서치 방법론

### AI-augmented Research (필수)

AI 도구를 활용한 체계적 리서치 프레임워크.

**적용 방법**:
1. 가설 수립 → AI로 대량 소스 스캔 → 패턴 추출
2. Human이 패턴 검증 → AI로 심화 조사
3. 결과를 신뢰도 등급(High/Medium/Low)으로 분류

**도구 매핑**: WebSearch + academic-researcher + fact-checker 병렬

### JTBD — Jobs To Be Done (필수)

사용자가 "고용"하는 작업 중심으로 니즈를 분석.

**핵심 질문**:
- 사용자가 이 제품/게임으로 어떤 "일"을 해결하려 하는가?
- 현재 어떤 대안을 사용하고 있는가?
- 전환 동기(Push/Pull)와 저항(Anxiety/Habit)은 무엇인가?

**산출물 형식**:
```
When [상황], I want to [동기], so I can [기대 결과].
```

### Competitive Intelligence 자동화 (필수)

경쟁사 데이터를 체계적으로 수집/분석.

**적용 방법**:
1. 직접 경쟁사 3~5개 + 간접 경쟁사 2~3개 식별
2. 기능 비교 매트릭스 (Feature Parity Grid) 작성
3. 가격/포지셔닝 맵 작성
4. 강점/약점/기회 도출

**도구 매핑**: market-researcher + WebSearch + `/competitor` 커맨드

### Evidence-Based Management (필수)

데이터 기반 의사결정 프레임워크.

**4대 핵심 가치 영역 (KVA)**:
| 영역 | 측정 | 예시 |
|------|------|------|
| Current Value | 현재 전달 가치 | 매출, 사용자 만족도 |
| Unrealized Value | 미실현 잠재 가치 | TAM 대비 침투율, 미충족 니즈 |
| Time-to-Market | 시장 진입 속도 | 릴리즈 주기, 리드 타임 |
| Ability to Innovate | 혁신 역량 | 기술 부채 비율, 실험 비율 |

### SOAR 분석 (선택)

Strengths, Opportunities, Aspirations, Results — 긍정 중심 전략 분석.
SWOT의 대안으로, 약점/위협 대신 열망/결과에 집중.

### PESTLE 분석 (선택)

Political, Economic, Social, Technological, Legal, Environmental 거시환경 분석.
규제 산업(게임 심의, 금융 등)이나 글로벌 진출 시 적용.

---

## S2 컨셉 방법론

### Lean Canvas (필수)

`/lean-canvas` 커맨드로 자동 생성. 9개 블록:
Problem, Solution, Key Metrics, UVP, Unfair Advantage, Channels, Customer Segments, Cost Structure, Revenue Streams

### Go/No-Go 스코어링 (필수)

| 평가 항목 | 가중치 | 점수(0-100) |
|----------|:------:|:-----------:|
| 시장 규모 (TAM) | 25% | |
| 기술 실현성 | 20% | |
| 경쟁 우위 | 20% | |
| 수익 모델 명확성 | 15% | |
| 팀 역량 적합도 | 10% | |
| 진입 타이밍 | 10% | |

- 80+ = Go
- 60-79 = 조건부 (리스크 완화 후 재평가)
- <60 = No-Go

### Kill Criteria (필수)

아래 중 하나라도 해당되면 즉시 No-Go:
- TAM < $1M
- 경쟁사 70%+ 시장 점유
- 핵심 기술 구현 불가
- 규제/법적 장벽 해소 불가

---

## S3 기획서 방법론

### Competing Hypotheses — 에이전트 회의 (필수)

2~3명의 에이전트가 독립 초안 작성 → 비교 → 최적안 선택.

**프로토콜**:
1. pipeline-orchestrator가 2+ gdd-writer 또는 PRD 작성 에이전트 스폰
2. 각 에이전트는 독립적으로 기획서 초안 작성
3. 비교표 생성 (장점/단점/리스크)
4. 최적안 선택 + 선택 근거 기록 (`agent-meeting-template.md`)

### Shape Up Pitch (앱/웹 프로젝트)

Basecamp의 Shape Up 방법론에서 Pitch 형식 차용.

**Pitch 구조**:

| 섹션 | 내용 | 작성 지침 |
|------|------|----------|
| **Problem** | 해결할 문제 | 유저 관점에서 구체적 상황 기술. JTBD 형식 활용 |
| **Appetite** | 투자할 시간/리소스 | "6주" 또는 "2주" 단위. 시간이 범위를 결정 (역방향) |
| **Solution** | 해결 방향 | Fat Marker 스케치: 핵심 UI 요소만 표현, 세부 디자인 배제 |
| **Rabbit Holes** | 빠질 수 있는 함정 | 복잡도를 과소평가하기 쉬운 영역 명시 |
| **No-gos** | 명시적으로 하지 않을 것 | 스코프 크리프 방지. "이것은 이번에 안 한다" 명확화 |

**핵심 원칙**:
- Appetite가 먼저 → 시간 내에 맞추는 솔루션을 설계 (시간 > 범위)
- Shaping은 추상화 수준을 조절: 너무 구체적이면 디자이너/개발자 자율성 제한, 너무 추상적이면 리스크 증가
- Betting Table: Pitch는 "승인"이 아니라 "베팅" — 리소스를 투입할 가치가 있는가로 판단

---

## S4 기획 패키지 방법론

### C4 Model (개발 계획 — 아키텍처)

4단계 추상화로 시스템 아키텍처 시각화:

| 레벨 | 대상 | S4 산출물 |
|------|------|----------|
| C1 Context | 시스템 경계 + 외부 시스템 | 개발 계획 — 아키텍처 개요 |
| C2 Container | 앱/서버/DB/API 단위 | 개발 계획 — 컨테이너 다이어그램 |
| C3 Component | 컨테이너 내부 모듈 | 개발 계획 — 모듈 설계 |
| C4 Code | 클래스/함수 레벨 | Trine Phase 2에서 상세화 |

### ADR — Architecture Decision Record (개발 계획)

기술적 의사결정을 기록하는 표준 형식:

```markdown
## ADR-{N}: {제목}
- **상태**: 제안됨 / 승인됨 / 폐기됨
- **맥락**: 왜 이 결정이 필요한가
- **결정**: 무엇을 선택했는가
- **대안**: 검토한 다른 옵션
- **결과**: 이 결정의 예상 영향
```

### Wave Protocol (S4 품질 보증)

| Wave | 목적 | 참여 |
|------|------|------|
| W1 | 초안 작성 | technical-writer |
| W2 | Spec 검증 (트레이서빌리티) | pipeline-orchestrator |
| W3 | CTO + UX 리뷰 | cto-advisor + ux-researcher |
| W4 | 최종본 확정 | pipeline-orchestrator |

### MoSCoW 우선순위 (개발 계획)

| 분류 | 의미 | 비율 가이드 |
|------|------|:---------:|
| Must have | 없으면 릴리즈 불가 | ~60% |
| Should have | 중요하지만 우회 가능 | ~20% |
| Could have | 있으면 좋음 | ~20% |
| Won't have | 이번 스코프 제외 | 명시적 제외 |

---

## 플러그인/도구 매핑

각 방법론 적용 시 활용 가능한 플러그인과 도구.

| 방법론 | 도구/플러그인 | 사용 시점 |
|--------|-------------|----------|
| AI-augmented Research | WebSearch + academic-researcher + fact-checker | S1 병렬 리서치 |
| Competitive Intelligence | `/competitor` + `marketing:competitive-analysis` | S1 경쟁사 분석 |
| JTBD | `product-management:user-research-synthesis` | S1 유저 니즈 분석 |
| Evidence-Based Management | `data:data-exploration` + `data:statistical-analysis` | S1 정량 분석 |
| Lean Canvas | `/lean-canvas` | S2 비즈니스 모델 |
| Go/No-Go Scoring | `product-management:metrics-review` | S2 사업성 평가 |
| Competing Hypotheses | Agent Teams (Fan-out) | S3 에이전트 회의 |
| Shape Up Pitch | `product-management:feature-spec` | S3 앱/웹 기획서 |
| C4 Model / ADR | cto-advisor | S4 아키텍처 검토 |
| Wave Protocol | technical-writer + cto-advisor + ux-researcher | S4 품질 보증 |
| MoSCoW | `product-management:roadmap-management` | S4 우선순위 |
| UX 검증 | ux-researcher + `frontend-design` 플러그인 | S4 Wave 3 |

---

*Last Updated: 2026-03-06*
