# 하네스 엔지니어링 — 이거 모르면 클로드코드 아무리 써도 소용없습니다 | EP.04
> AI 사용성연구소 | 조회수 20.7K | 재생시간 15:34
> 원본: https://youtu.be/hjIxPpJyYHs
> 자막: 자동생성 (신뢰도 Medium)

---

## TL;DR
Anthropic의 공식 하네스 엔지니어링 블로그를 기반으로, Planner-Generator-Evaluator 3-에이전트 구조를 실제 Claude Code로 구현하는 과정을 데모한다. 같은 모델·프롬프트라도 구조가 다르면 결과물 품질이 22배 이상 차이난다는 핵심 주장을 게임 제작으로 실증한다.

## 카테고리
tech/ai | #하네스엔지니어링 #ClaudeCode #멀티에이전트 #컨텍스트리셋

---

## 핵심 포인트

1. **AI 성능은 모델이 아니라 구조가 결정한다** [🕐 00:09](https://youtu.be/hjIxPpJyYHs?t=0) — 엔트로픽 공식 발표: 프롬프트 엔지니어링 이후 다음 단계는 하네스 엔지니어링

2. **컨텍스트 어그자이어티(Context Anxiety)** [🕐 01:00](https://youtu.be/hjIxPpJyYHs?t=60) — 단일 에이전트는 컨텍스트가 길어질수록 앞 내용을 잊고 조기에 작업을 종료하는 현상 발생

3. **Context Reset 패턴** [🕐 01:25](https://youtu.be/hjIxPpJyYHs?t=85) — 교대 근무 방식으로 AI를 맑은 상태에서 재시작. /clear + CLAUDE.md 상태 기록이 이 패턴과 동일

4. **자기평가의 함정** [🕐 02:00](https://youtu.be/hjIxPpJyYHs?t=120) — AI가 자기 결과물에 후한 점수를 줌. 만드는 AI와 채점하는 AI를 분리하는 것이 핵심

5. **3-에이전트 구조: Planner-Generator-Evaluator** [🕐 03:00](https://youtu.be/hjIxPpJyYHs?t=180) — Planner(기획 확장) → Generator(코딩) → Evaluator(MCP로 실제 테스트) → 불합격 시 피드백 루프 최대 3회

6. **평가기준표(Rubric)가 생성물의 품질을 결정** [🕐 04:30](https://youtu.be/hjIxPpJyYHs?t=270) — 디자인 품질 40%, 독창성 30%, 기술완성도 15%, 기능성 15%. AI 슬롭 방지가 핵심

7. **비용-성능 트레이드오프** [🕐 07:00](https://youtu.be/hjIxPpJyYHs?t=420) — 단일 에이전트: 9달러/20분 vs 풀 하네스: 200달러/6시간. 22배 품질 향상

8. **Evaluator가 Playwright MCP로 실제 테스트 수행** [🕐 08:00](https://youtu.be/hjIxPpJyYHs?t=480) — 사람이 클릭하듯 직접 게임을 플레이하며 버그를 검출

9. **모델이 좋아져도 하네스는 사라지지 않는다** [🕐 13:30](https://youtu.be/hjIxPpJyYHs?t=810) — 규칙이 줄어드는 것이지 구조 자체는 더 어려운 과제에 계속 필요

10. **3대 핵심 결론** [🕐 14:00](https://youtu.be/hjIxPpJyYHs?t=840) — ①구조가 결과를 결정 ②만드는 AI와 평가하는 AI 분리 ③평가 기준표 없이는 평가도 불가능

---

## 비판적 분석

### 주장 1: "같은 AI라도 구조가 다르면 결과가 완전히 다르게 나온다 — 22배 성능 차이"
- **제시된 근거**: 게임 제작 실험. 단일: 9달러/조악한 게임 vs 하네스: 200달러/완성도 높은 게임
- **근거 유형**: 경험 (단발 실험, n=1)
- **한계**: 동일 조건 통제 실험 아님. "22배"는 주관적 품질 평가. Anthropic 공식 블로그 데이터(v1: $200, v2: $124.70)와 구체적 수치가 일치하나 재현성은 미검증
- **반론/대안**: 단순 품질 비교가 아닌 시간당 ROI 관점에서 보면, 200달러/6시간이 항상 최적은 아님. Opus 4.6 이후 v2(3시간 50분/$124.70)로 효율성이 크게 개선됨

### 주장 2: "AI는 자기 결과물을 스스로 공정하게 평가하지 못한다"
- **제시된 근거**: Anthropic 엔지니어 관찰. 요리사 비유(음식 평론가와 요리사 분리)
- **근거 유형**: 실증 (Anthropic 공식 인용) + 비유
- **한계**: 모델 버전별 차이 있음. Claude Opus 4.6은 자기비판 능력이 개선됐다는 보고 존재
- **반론/대안**: 충분히 엄격한 system prompt로 single-agent self-critique가 가능하다는 연구도 있음

### 주장 3: "평가 기준표의 문구 자체가 Generator의 결과물을 바꾼다"
- **제시된 근거**: "AI 슬롭 불합격", "Bootstrap 기본 느낌 불합격" 등 구체적 불합격 기준 제시
- **근거 유형**: 경험 (직접 구현 결과)
- **한계**: 어떤 기준표 문구가 얼마나 효과적인지에 대한 체계적 연구는 없음
- **반론/대안**: Anthropic 공식 블로그는 "museum quality" 같은 구체적 언어의 효과를 확인함. Few-shot 예제로 평가자를 보정하는 방법이 더 효과적일 수 있음

---

## 팩트체크 대상
- **주장**: "같은 모델, 같은 프롬프트, 다른 구조로 22배 차이" | **검증 필요 이유**: 단일 실험, 주관적 품질 평가 | **검증 방법**: Anthropic 공식 블로그 데이터 대조
- **주장**: "Opus 4.5 이후 Context Reset이 불필요해짐" | **검증 필요 이유**: 모델 진화로 하네스 요소가 변화한다는 주요 주장 | **검증 방법**: Anthropic 공식 문서 확인
- **주장**: "Evaluator가 Playwright MCP로 실제 게임을 플레이하며 테스트" | **검증 필요 이유**: MCP 활용 방식의 구체성 | **검증 방법**: 공식 블로그 + 하네스 프로젝트 파일 확인

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "22배 품질 차이" | ✅ 확인 | Anthropic 공식 블로그(2026-03-24): 단일 에이전트 $9/20분 vs 전체 하네스 $200/6시간. "dramatically improved output quality" 공식 확인. 수치적으로도 일치 |
| 2 | "Opus 4.5 이후 Context Reset 불필요" | ✅ 확인 | Anthropic 공식 블로그: "Opus 4.5 largely removed that behavior on its own". Opus 4.6에서는 1M 토큰 컨텍스트로 context anxiety가 실질적으로 해소됨 |
| 3 | "Playwright MCP로 실제 테스트" | ✅ 확인 | 공식 블로그에서 "Evaluator uses Playwright MCP to test the application like a real user" 명시 |

---

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| 하네스 공식 블로그 | [Anthropic Engineering (2026-03-24)](https://www.anthropic.com/engineering/harness-design-long-running-apps) | Planner는 1-4문장 요청을 완전한 제품 스펙으로 확장. v2에서 Opus 4.6 사용으로 3시간 50분/$124.70으로 개선. "find the simplest solution" 철학 강조 | 일치 |
| 하네스 단순화 진화 | [working-ref.com](https://www.working-ref.com/en/reference/anthropic-harness-design-philosophy-evolution) | Stage 1→2→3으로 Opus 4.6 도입 후 스프린트 구조 제거, 최종 단일 평가로 단순화 | 보완 |
| GAN-style 에이전트 루프 | [Epsilla Blog](https://www.epsilla.com/blogs/anthropic-harness-engineering-multi-agent-gan-architecture) | Generator-Evaluator 분리는 GAN(생성적 적대 신경망) 구조와 유사. "engineering conflict → engineering progress" | 보완 |
| Opus 4.6 context anxiety 해소 | [mejba.me](https://www.mejba.me/blog/anthropic-long-running-agent-harness) | 1M 토큰 컨텍스트 윈도우로 멀티시간 자율 세션에서 context anxiety가 실질적으로 사라짐 | 보완 |

---

## 시스템 비교 분석

### GTC-1 관련성 필터 결과
- **우리 시스템의 하네스 구조**: `.claude/skills/`, `.claude/agents/`, `.claude/hooks/` — 하네스 구조 자체는 이미 구현됨
- **`axis-harness.md`**: Planner-Generator-Evaluator 패턴 감사 에이전트 보유
- **`investigate` 스킬**: 런타임 에러 분석 (Evaluator 역할 부분 담당)
- **`qa` 스킬**: Phase 8 QA 파이프라인
- **Playwright MCP**: 현재 `.mcp.json`에 없음 (sequential-thinking, nano-banana, google-docs만 보유)

### GTC-2 기구현 확인
- Context Reset 패턴: `/clear` + `CLAUDE.md` 상태 기록 — **이미 구현됨** (영상도 동일하게 언급)
- 3-에이전트 구조 개념: `axis-harness.md`에 이론적 프레임워크 존재
- 평가기준표(Rubric): `qa` 스킬에 체크리스트 형태 존재

### GTC-3 현재 파이프라인 갭
- Generator-Evaluator 분리가 실제 워크플로우에서 자동화되어 있지 않음
- Playwright 기반 실제 UI 자동 테스트 없음

| 영상/리서치 제안 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------------|---------|:--:|:----:|:----:|
| Planner-Generator-Evaluator 자동 파이프라인 | `.claude/agents/` 개별 존재, 자동 체인 없음 | 자동 호출 오케스트레이션 없음 | M | M |
| 평가기준표(Rubric) 명시화 | `qa` 스킬에 일부 체크리스트 | 가중치·합격기준 없음 | M | L |
| Playwright MCP Evaluator | 미설치 | Playwright MCP 자체 없음 | L | M |
| 자기평가 분리 원칙 | hooks로 일부 통제 | 명시적 self-critique 방지 구조 없음 | L | L |

---

## 필수 개선 제안

### P0 — 즉시 적용 가능
- **[Forge]** 평가기준표 명시화: `qa` 스킬에 가중치 기반 합격/불합격 기준 추가 → AI 슬롭 방지 → 산출물 품질 즉시 개선. 30분 내 적용 가능

### P2 — 이번 달
- **[Forge]** Planner-Generator-Evaluator 자동 체인: 현재 개별 에이전트를 오케스트레이터가 순차 호출하는 스킬 구성 → 대형 기능 개발 시 품질 향상. 현재 시스템에 즉각적 blocking 없음

---

## 실행 가능 항목
- [ ] `qa` 스킬에 가중치 기반 Rubric 추가 (적용 대상: Forge, Portfolio, GodBlade)
- [ ] CLAUDE.md에 하네스 구조 사용 케이스 가이드 추가 (적용 대상: Forge)
- [ ] 하네스 프로젝트 파일 다운로드 및 구조 분석 (적용 대상: Forge Dev)

---

## 관련성
- **Portfolio**: 4/5 — 프론트엔드 UI 품질 개선에 직접 적용 가능 (Evaluator로 디자인 슬롭 방지)
- **GodBlade**: 3/5 — 게임 레벨 에디터/UI 생성에 적용 가능
- **비즈니스**: 3/5 — 문서 자동화 파이프라인에 Planner-Generator-Reviewer 패턴 적용 가능

---

## 핵심 인용
> "같은 모델, 같은 프롬프트, 다른 건 이제 구조뿐이에요. 그래서 차이가 나는 이유입니다." — AI 사용성연구소

> "평가 기준표의 문구 자체가 Generator의 결과물을 바꿉니다." — AI 사용성연구소

---

## 추가 리서치 필요
- Anthropic 하네스 프로젝트 파일 구조 상세 (검색 키워드: `anthropic harness project files download`, `planner generator evaluator CLAUDE.md`)
- Few-shot Evaluator 보정 방법론 (검색 키워드: `LLM evaluator calibration few-shot examples`)
