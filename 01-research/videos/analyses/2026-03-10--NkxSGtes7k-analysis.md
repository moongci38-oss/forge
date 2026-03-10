# Anthropic이 Claude Code Skills 2.0을 출시했습니다
> Tech Bridge | 미공개 | 조회수 미공개 | 약 13분
> 원본: https://youtu.be/-NkxSGtes7k
> 자막: 자동생성 (신뢰도 Low) — "엔스로픽", "코리", "서베이전트", "코에서" 등 고유명사/기술용어 오인식 주의

---

## 1. TL;DR

Anthropic이 Claude Code의 Skills를 더 쉽게 만들고 평가할 수 있는 **Skill Creator Plugin 2.0**을 출시했다. 직감에 의존하던 스킬 개발에서 벗어나, A/B 테스트 기반 벤치마크와 트리거 최적화 루프를 통해 스킬이 실제로 성능 향상을 만드는지 데이터로 검증할 수 있게 됐다.

---

## 2. 카테고리

`tech/ai` `tech/dev-tools`

`#claude-code` `#anthropic` `#skills` `#agentic-workflow` `#prompt-engineering` `#benchmarking` `#ab-testing` `#developer-tools`

---

## 3. 핵심 포인트

1. [🕐 00:21](https://youtu.be/-NkxSGtes7k?t=21) **현재의 스킬 개발 방식은 '직감 의존'** — 작업 후 "스킬로 만들어줘"라고 요청하고 몇 번 테스트 후 배포하는 방식이 일반적이었으나, 이 방식은 스킬이 실제로 도움이 되는지 알 수 없다는 근본적 문제가 있다.

2. [🕐 00:52](https://youtu.be/-NkxSGtes7k?t=52) **모델 업데이트로 인한 스킬 무용화 문제** — 새 모델 출시 시 스킬에 내장된 기능이 모델 자체에 포함되어, 스킬이 오히려 모델의 잠재력을 제한(self-sandbagging)할 수 있다.

3. [🕐 01:52](https://youtu.be/-NkxSGtes7k?t=112) **Anthropic의 스킬 2대 분류** — ① 능력 향상형(Capability): 모델이 부족한 영역 보완 (PDF, PowerPoint 등). ② 선호도 인코딩형(Preference): 특정 워크플로우/컴플라이언스 자동화. 전자는 모델 발전과 함께 은퇴 시점이 오고, 후자는 장기적으로 유효하다.

4. [🕐 02:46](https://youtu.be/-NkxSGtes7k?t=166) **능력 향상형 스킬의 수명** — PDF 스킬을 예로 들어, Opus 4.5나 Opus 5에서 PDF 처리가 개선되면 해당 스킬이 불필요해진다. Skill Creator가 이 판단을 자동화할 수 있다.

5. [🕐 04:10](https://youtu.be/-NkxSGtes7k?t=250) **Skill Creator Plugin 설치 및 구성** — `/plugins`에서 설치 후 프로젝트 레벨 적용. 이전 버전(user 레벨)과 신규 버전 충돌 주의, 구버전 삭제 필요.

6. [🕐 05:12](https://youtu.be/-NkxSGtes7k?t=312) **스킬 생성 + 자동 평가 데모** — "감사 스킬 만들어줘"라는 간단한 명령으로 스킬 생성 → 테스트 케이스 자동 생성 → 스킬 있음/없음 6개 병렬 실행 → 블라인드 비교 채점까지 자동화된다.

7. [🕐 06:13](https://youtu.be/-NkxSGtes7k?t=373) **블라인드 A/B 비교 구조** — 채점 에이전트(Comparator)는 어느 쪽이 스킬을 사용했는지 모른 상태로 두 출력을 비교하여 객관성을 확보한다.

8. [🕐 08:30](https://youtu.be/-NkxSGtes7k?t=510) **실측 벤치마크 결과** — 감사 스킬 활성화 시 성공률 +13.5%, 작업 완료 시간 -22%, 단 토큰 사용량은 소폭 증가.

9. [🕐 09:35](https://youtu.be/-NkxSGtes7k?t=575) **두 가지 평가 유형** — ① 능력 평가: "어느 쪽 감사가 더 우수한가" 같은 품질 비교. ② 절차적 평가: 보험 청구 분류처럼 20-30개 예시 입력 → 정답과 대조하여 정확도 측정.

10. [🕐 10:42](https://youtu.be/-NkxSGtes7k?t=642) **트리거 최적화 루프** — 스킬이 안정적으로 발동되지 않을 때, Skill Creator가 20개의 쿼리로 최적화 루프를 실행. 60% 훈련/40% 테스트 세트로 분리해 머신러닝과 유사한 방식으로 스킬 설명(description)을 자동 개선한다.

---

## 4. 비판적 분석

### 주장 1: "현재 스킬 개발은 직감에만 의존하고, 이는 근본적으로 결함이 있다"

- **주장**: 대부분의 사람들은 직감에만 의존해서 스킬을 개발한다
- **제시된 근거**: 작업 후 "스킬로 만들어줘" 방식으로 개발하고 몇 번 테스트 후 배포하는 패턴이 일반적이다
- **근거 유형**: 경험적 관찰 (제작자 개인 경험 및 커뮤니티 관찰)
- **한계**: 얼마나 많은 사용자가 이 방식을 쓰는지 데이터 없음. 숙련된 프롬프트 엔지니어는 이미 체계적 방법론을 사용 중일 수 있다
- **반론**: 단순한 선호도 인코딩형 스킬(e.g. 릴리즈 워크플로우)은 A/B 테스트 없이도 충분히 검증 가능하다. 모든 스킬에 이 수준의 엄밀성이 필요한지는 ROI 관점에서 의문

### 주장 2: "스킬은 모델 업데이트로 '자기 제한(self-sandbagging)'이 될 수 있다"

- **주장**: 새 모델이 스킬의 기능을 내장하게 되면 스킬이 오히려 성능을 제한한다
- **제시된 근거**: 논리적 추론 — 스킬 프롬프트가 모델이 이미 알고 있는 것을 재지시함으로써 혼선을 줄 수 있다
- **근거 유형**: 논리적 추론 (실증 데이터 없음)
- **한계**: 실제로 이런 성능 저하가 얼마나 빈번하고 심각한지 측정한 데이터를 제시하지 않음
- **반론**: 스킬의 추가적인 컨텍스트(프로젝트별 규칙, 코딩 컨벤션 등)는 모델이 아무리 발전해도 유효하다. Self-sandbagging은 일부 능력 향상형 스킬에만 해당하는 문제이며 과도하게 일반화된 주장이다

### 주장 3: "스킬 활성화 시 성공률 +13.5%, 속도 +22% 향상"

- **주장**: 감사 스킬을 사용하면 성공률과 속도가 유의미하게 향상된다
- **제시된 근거**: 감사 스킬 A/B 테스트 결과 수치 (영상 내 데모)
- **근거 유형**: 실증 데이터 (단, 단일 영상 내 데모 수준)
- **한계**: 테스트 케이스 수(6회 실행)가 매우 적어 통계적 유의성 불명확. 감사라는 특정 태스크에만 해당하며 다른 스킬 유형에서의 일반화 불가. 채점 기준(expectations)을 제작자가 직접 정의하므로 객관성 문제
- **반론**: 블라인드 비교 설계는 긍정적이나, 채점 에이전트 자체도 Claude이므로 같은 회사 모델로 평가하는 순환 구조 문제가 있다

### 주장 4: "몇 개의 Claude 스킬로 일부 사람들의 업무가 대체되고 있다"

- **주장**: Claude 스킬이 실제 인간 업무를 대체하고 있다
- **제시된 근거**: 제작자의 개인적 관찰
- **근거 유형**: 의견 (근거 없는 주장)
- **한계**: 어떤 직군, 어느 수준의 업무가 대체되는지 구체성이 전혀 없다
- **반론/대안**: "업무 자동화"와 "직업 대체"는 구별이 필요하다. 반복적 워크플로우 자동화는 업무 효율화이며, 직업 대체는 훨씬 복잡한 경제적·사회적 맥락이 필요하다

**과장/편향**: 영상 전체가 Anthropic의 공식 블로그 포스트를 기반으로 제작되어 Anthropic 제품에 대한 비판적 시각이 없다. 제작자가 Claude Code 마스터클래스를 판매 중이므로 Claude Code 생태계에 대한 과도한 긍정적 편향 존재.

**이 조언이 유효하지 않은 상황**: 스킬을 가끔 사용하거나 빠른 프로토타이핑 단계, 소규모 개인 프로젝트에서는 Skill Creator의 A/B 테스트 오버헤드가 실제 개발 시간보다 클 수 있다.

---

## 5. 팩트체크 대상

- **주장**: "스킬 활성화 시 성공률 13.5% 향상, 작업 완료 시간 22% 단축" | **검증 필요 이유**: 6회 실행이라는 극히 적은 표본, 단일 태스크(감사), 채점 기준이 제작자 정의. 재현 가능한 실험인지 불명확 | **검증 방법**: 동일 Skill Creator를 사용해 10개 이상 다양한 스킬 타입에서 50회 이상 실행 후 통계 검증; Anthropic 공식 블로그의 원문 데이터 확인

- **주장**: "몇 달 전에 만든 스킬은 이제 모델이 내장하고 있어 더 이상 필요하지 않을 수 있다" | **검증 필요 이유**: Claude의 각 버전별 능력 변화에 대한 공식 changelog나 벤치마크 없이 주장됨. Self-sandbagging 현상의 실제 빈도/규모가 불명확 | **검증 방법**: Anthropic의 공식 모델 릴리즈 노트 및 벤치마크 비교; 특정 능력(PDF, PowerPoint 등)을 구버전과 신버전 Claude에서 스킬 유무로 직접 비교 테스트

- **주장**: "몇 개의 Claude 스킬로 일부 사람들의 업무가 대체되고 있다" | **검증 필요 이유**: 완전히 출처 불명의 관찰적 주장으로, 어떤 직종, 어떤 수준의 업무, 어느 규모인지 전혀 명시되지 않음 | **검증 방법**: Anthropic 또는 독립 연구기관의 Claude 사용 사례 리포트; 자동화로 인한 업무 변화 사례 구체화 자료 탐색

---

## 6. 실행 가능 항목

**즉시 (이번 주)**
- [ ] 현재 Business 워크스페이스의 핵심 스킬 목록화 및 Skill Creator로 재평가 우선순위 선정 (Business)
- [ ] Skill Creator Plugin 최신 버전 설치 확인 및 기존 버전 충돌 해소 (Business/Portfolio)

**단기 (이번 달)**
- [ ] 가장 자주 사용하는 스킬 상위 3개에 Skill Creator A/B 테스트 적용 → 실제 성능 개선 여부 데이터화 (Business)
- [ ] 수개월 이상 된 능력 향상형 스킬들에 대해 "여전히 필요한가" 점검 — 신규 모델에서 스킬 없이도 동등한 성능이 나오는지 확인 (Business/Portfolio)
- [ ] Trine 파이프라인에서 사용 중인 스킬들 (spec-compliance-checker, code-reviewer 등)에 절차적 평가 케이스 구성 (Portfolio)

**중기 (이번 분기)**
- [ ] 선호도 인코딩형 스킬 (릴리즈 워크플로우, PR 생성 등)의 트리거 최적화 루프 실행 — 안정적 발동 여부 검증 (Portfolio/Business)
- [ ] 새 모델 출시 시 스킬 재평가 프로세스를 정기 루틴으로 수립 (Business)

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|---------|---------|---|---------|
| Skill Creator로 스킬 생성 | Skills 2.0 적용 완료 (user-invocable, context:fork 등 메타데이터 체계 정비됨) | Skill Creator Plugin 자체를 평가 도구로 사용하는 루틴이 없음 | 중 |
| A/B 테스트로 스킬 성능 검증 | 현재 없음 — 수동 테스트만 수행 | Skill Creator의 병렬 평가 기능을 활용한 데이터 기반 검증 부재 | 높음 |
| 트리거 최적화 루프 | 스킬 description 수동 작성 중 | 안정적 트리거를 위한 자동 description 최적화 루프 미적용 | 높음 |
| 능력 향상형 스킬 정기 은퇴 검토 | manage-skills.sh로 스킬 관리하지만 모델 업데이트 대응 루틴 없음 | 모델 신버전 출시 시 스킬 유효성 재평가 프로세스 필요 | 중 |
| 절차적 평가 (입력-출력 예시 기반) | Trine Check 3.5 (spec-compliance-checker)가 유사 역할 수행 | 구조화된 입출력 예시 데이터셋 없이 AI 판단에만 의존 | 중 |
| 스킬 성능 리포트(HTML 뷰어) | 없음 | Skill Creator 벤치마크 리포트를 docs/reviews/에 저장하는 루틴 필요 | 낮음 |

---

## 8. 관련성

- Portfolio: 4/5 — Trine 파이프라인의 다수 스킬/에이전트에 직접 적용 가능. 특히 spec-compliance-checker, code-reviewer, daily-system-review 등 핵심 스킬의 성능 검증에 즉시 활용 가능
- GodBlade: 1/5 — Unity C# 개발 환경이므로 Claude Code Skills 생태계와 직접 연관성 낮음
- 비즈니스: 4/5 — SIGIL 파이프라인 스킬(research-coordinator, pipeline-orchestrator 등) 및 자동화 워크플로우 스킬 최적화에 직접 적용 가능. 특히 선호도 인코딩형 스킬(주간 리서치, 일일 시스템 리뷰 등)의 트리거 안정성 검증에 유용

---

## 핵심 인용

> "현실적으로 하루에 여러 번 사용하고 앞으로도 계속 사용할 스킬이 있다면, 실제로 더 나은 결과를 제공하는지 그리고 안정적으로 트리거되는지 확인하는데 드는 약간의 시간은 장기적으로 충분히 보상받을 것입니다."

→ 고빈도 사용 스킬에 한정해 투자하라는 실용적 조언. 모든 스킬에 적용하는 것은 비효율적임을 암묵적으로 인정하는 발언.

---

## 추가 리서치 필요

- `Claude Code Skills benchmark methodology` — Anthropic 공식 평가 방법론 상세 문서
- `skill creator plugin anthropic github` — 공식 레포지토리에서 최신 버전 및 변경사항 확인
- `Claude Code self-sandbagging skills` — 스킬이 모델 성능을 저하시키는 현상에 대한 실증 사례
- `prompt optimization loop LLM evaluation` — 스킬 description 자동 최적화와 유사한 DSPy, TextGrad 등 관련 방법론 비교
- `Anthropic skills 2.0 blog post` — 영상에서 언급된 원문 블로그 포스트 직접 확인 (수치 출처 검증용)

---

## 추가 리서치 결과

> 조사일: 2026-03-10 | 조사 항목: 5개

### 1. Anthropic Skills 2.0 공식 문서 및 블로그 포스트 확인

- **결론**: Anthropic 공식 블로그에 별도의 "Skills 2.0 발표" 포스트는 확인되지 않았다. 공식 문서(`code.claude.com/docs/en/skills`)에 스킬 전체 사양이 정리되어 있으며, Skill Creator는 `claude.com/plugins/skill-creator`에서 직접 설치 가능하다. 영상이 언급한 성능 수치(+13.5% 성공률, -22% 완료 시간)는 공식 문서 어디에도 재현되지 않았다 — 영상 제작자의 개인 데모 결과로 판단된다.
- **공식 문서에서 확인된 스킬 분류**: ① Reference content(참조형) — 지식/패턴을 인라인으로 주입, ② Task content(작업형) — 단계별 지시, `disable-model-invocation: true` 권장. 영상의 "Capability/Preference" 이분법은 Anthropic 공식 분류가 아닌 영상 제작자 해석이다.
- **출처**: [Extend Claude with skills - 공식 문서](https://code.claude.com/docs/en/skills) (2026-03-10 접근), [Skill Creator Plugin 공식 페이지](https://claude.com/plugins/skill-creator) (2026-03-10 접근)
- **신뢰도**: High (공식 Anthropic 문서 직접 확인)
- **비즈니스 적용**: 적용 가능 — 영상의 "Capability vs Preference" 분류 대신 공식 문서의 "Reference vs Task" 분류 체계로 기존 스킬을 재정비하는 것이 더 정확하다. `user-invocable: false`, `disable-model-invocation: true`, `context: fork` 등 현재 Business 워크스페이스에서 이미 사용 중인 메타데이터가 공식 표준과 일치함을 확인했다.

### 2. Skill Creator Plugin 공식 레포지토리 및 최신 버전

- **결론**: 공식 레포지토리는 `github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator`에 위치한다. Skill Creator는 4가지 모드(Create, Eval, Improve, Benchmark)와 4개의 전문 에이전트(Executor, Grader, Comparator, Analyzer)로 구성된다. 플러그인 페이지 기준 19,066 설치를 달성했다. 별도 버전 번호는 공개되지 않으며, main 브랜치 기반으로 지속 업데이트된다.
- **이전 버전 충돌 주의사항**: 영상에서 언급된 user 레벨 구버전과 project 레벨 신버전 충돌은 실제로 존재하는 이슈다. `/plugins`에서 기존 버전 삭제 후 재설치 권장.
- **출처**: [anthropics/claude-plugins-official - skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) (2026-03-10 접근), [Skill Creator Plugin 공식 페이지](https://claude.com/plugins/skill-creator) (2026-03-10 접근)
- **신뢰도**: High (Anthropic 공식 GitHub 확인)
- **비즈니스 적용**: 적용 가능 — Business 워크스페이스에 Skill Creator 설치 시 project 레벨로 설치(`--scope project`)하고, 기존 user 레벨 구버전 여부를 먼저 점검해야 한다.

### 3. Claude Code "self-sandbagging" 스킬 성능 저하 현상 실증 사례

- **결론**: 영상에서 언급된 "self-sandbagging"(스킬이 모델 성능을 오히려 제한하는 현상)에 대한 직접적인 실증 데이터는 존재하지 않는다. "AI Sandbagging" 관련 학술 논문(arXiv:2406.07358)이 존재하지만, 이는 **전혀 다른 개념**이다 — 이 논문의 sandbagging은 모델이 평가 중 의도적으로 낮은 성능을 보이는 전략적 행동(safety 연구 주제)이며, 스킬 프롬프트에 의한 의도치 않은 성능 저하와는 무관하다. 커뮤니티에서 "모델 업데이트 후 스킬이 예상대로 동작하지 않는" 사례는 보고되고 있으나, 이는 스킬이 모델을 "제한"하기보다는 스킬 description과 새 모델의 해석 방식 불일치에 의한 트리거 실패에 가깝다.
- **실용적 결론**: Self-sandbagging은 실증 데이터 없는 논리적 추론 수준의 주장이며, 능력 향상형 스킬(예: PDF 처리)에 대해 정기적으로 "스킬 없이도 동등한 성능이 나오는가"를 테스트하는 것이 현실적 대응이다.
- **출처**: [AI Sandbagging 논문 - arXiv](https://arxiv.org/abs/2406.07358) (2026-03-10 접근), [Practical Guide to Evaluating Claude Code Skills](https://www.fabianmagrini.com/2026/03/practical-guide-to-evaluating-and.html) (2026-03-10 접근)
- **신뢰도**: Medium (학술 논문 확인했으나 영상의 self-sandbagging 개념과 다른 현상)
- **비즈니스 적용**: 참고만 — 스킬 성능 저하 우려 시 "스킬 유/무 A/B 테스트"로 실측하는 것이 가장 정확하다. 선제적 스킬 삭제보다 Skill Creator Benchmark로 데이터 확인 후 판단 권장.

### 4. 프롬프트 자동 최적화 방법론 비교 (DSPy, TextGrad vs Skill Creator 트리거 최적화)

- **결론**: DSPy(Stanford)와 TextGrad는 현재 가장 널리 사용되는 프롬프트 자동 최적화 프레임워크다. DSPy는 "프로그래밍 언어로서의 프롬프트" 패러다임으로, 모듈화된 파이프라인 전체를 최적화한다(컴파일 타임). TextGrad는 "텍스트를 통한 역전파(backpropagation)"로 단일 복잡한 문제를 반복 정제한다(런타임). Skill Creator의 트리거 최적화 루프(60/40 훈련/테스트 분리 + description 자동 개선)는 DSPy의 접근법과 구조적으로 유사하지만, Claude Code 생태계에 특화된 경량 버전이다. 2025년 비교 연구에서 세 가지 방법론(DSPy, APE, TextGrad) 모두 기준 프롬프트 대비 일관되게 성능 향상을 보였다.
- **Business 워크스페이스 관련성**: Skill Creator의 트리거 최적화 루프가 DSPy/TextGrad 대비 Claude Code 내에서 즉시 사용 가능하고 별도 파이썬 환경 설정이 불필요하다는 실용적 장점이 있다. 고급 최적화가 필요한 경우 DSPy를 외부에서 사용하는 것도 옵션이나, 대부분의 Business 스킬에는 Skill Creator 트리거 최적화로 충분하다.
- **출처**: [DSPy 공식 문서](https://dspy.ai) (2026-03-10 접근), [Beyond Prompt Engineering: TEXTGRAD and DSPy - Medium](https://medium.com/@adnanmasood/beyond-prompt-engineering-how-llm-optimization-frameworks-like-textgrad-and-dspy-are-building-the-6790d3bf0b34) (2026-03-10 접근), [DSPy GitHub](https://github.com/stanfordnlp/dspy) (2026-03-10 접근)
- **신뢰도**: High (공식 문서 및 비교 연구 다중 확인)
- **비즈니스 적용**: 참고만 — Skill Creator 트리거 최적화 루프가 Business 스킬에 대한 1차 선택지. DSPy/TextGrad는 Claude Code 외부에서 프롬프트 파이프라인을 체계적으로 최적화해야 할 때 검토.

### 5. Claude Code Skills 벤치마크 방법론 상세

- **결론**: Anthropic 공식 벤치마크 방법론 문서는 별도로 공개되어 있지 않다. Skill Creator의 Benchmark 모드는 다음 구조를 따른다: (1) 테스트 케이스(프롬프트 + 기대 출력) 정의, (2) 스킬 활성화/비활성화 각 N회 병렬 실행, (3) Grader 에이전트의 블라인드 채점, (4) 통계적 신뢰도를 포함한 분산 분석(variance analysis) 결과 집계. 영상의 6회 실행은 최소 권장 횟수보다 적으며, 공식 문서에서는 "statistical confidence measures"를 언급하고 있어 더 많은 실행이 권장됨을 시사한다. 두 가지 평가 유형(능력 평가 / 절차적 평가)은 공식 Skill Creator 기능과 일치한다.
- **영상 수치 검증**: "+13.5% 성공률, -22% 완료 시간"은 공식 문서 어디에도 수록되지 않은 영상 제작자의 개인 데모 결과다. Anthropic이 공개한 SEO 감사, 보험 청구 분류 등의 사례에서 "실질적 개선"을 언급하지만 구체적 수치는 공개하지 않는다.
- **출처**: [Skill Creator Plugin 공식 페이지](https://claude.com/plugins/skill-creator) (2026-03-10 접근), [Claude Code Skills 2.0 분석 - Geeky Gadgets](https://www.geeky-gadgets.com/anthropic-skill-creator/) (2026-03-10 접근), [Practical Guide to Evaluating Claude Code Skills](https://www.fabianmagrini.com/2026/03/practical-guide-to-evaluating-and.html) (2026-03-10 접근)
- **신뢰도**: Medium (공식 플러그인 페이지 확인, 상세 방법론 문서 미공개)
- **비즈니스 적용**: 적용 가능 — Business 스킬 벤치마크 시 최소 20회 이상 실행하여 분산을 측정하고, 영상의 6회 결과를 참고 수치로만 취급할 것. Benchmark 결과는 `docs/reviews/`에 저장하는 루틴 수립 권장.

### 미조사 항목

없음 — 5개 항목 모두 조사 완료.
