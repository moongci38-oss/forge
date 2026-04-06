# 하네스 공식문서 100번 읽은 것처럼 만들어드림
> 캐슬 AI | 17:20 | 30.2K views
> 원본: https://youtu.be/DrekqeDlO1w
> 자막: 자동생성 (신뢰도 Low) — 고유명사 오인식 주의 (하네스→한네스, Mitchell Hashimoto→미첼 하시모토)

## TL;DR
Harness Engineering은 AI 에이전트가 실수할 때마다 그 실수가 구조적으로 재발 불가능하도록 시스템을 설계하는 접근법이다. 프롬프트(부탁)가 아닌 CLAUDE.md + Hooks(강제)가 핵심이며, 이미 우리 Forge 시스템이 이를 상당 부분 구현하고 있다.

## 카테고리
tech/ai | #harness-engineering #claude-code #agent #CLAUDE.md #hooks #MCP

## 핵심 포인트
1. **Harness = AI 모델 이외의 모든 것** [🕐 02:28](https://youtu.be/DrekqeDlO1w?t=148) — CLAUDE.md, MCP, Skill, Hook이 모두 하네스. 별거 아닌 듯 보이지만 이것이 에이전트 성능을 결정한다.
2. **용어의 기원: Mitchell Hashimoto (HashiCorp/Terraform 창립자), 2026년 2월** [🕐 00:31](https://youtu.be/DrekqeDlO1w?t=31) — AI 코딩 에이전트가 동일한 실수를 반복하는 걸 경험하고 "프롬프트는 부탁, 하네스는 강제"라는 개념을 정립.
3. **두 가지 핵심 문제: 컨텍스트 부패 + 규칙/울타리 부재** [🕐 05:13](https://youtu.be/DrekqeDlO1w?t=313) — Anthropic 연구팀이 Claude Opus에게 claude.ai 클론을 시켰더니 컨텍스트 고갈 + 조기 종료 반복.
4. **CLAUDE.md = 영구 온보딩 문서** [🕐 07:01](https://youtu.be/DrekqeDlO1w?t=421) — 세션이 리셋돼도 CLAUDE.md는 항상 새로 읽힌다. 컨텍스트 부패를 구조적으로 방어.
5. **Hook = 저장 자체를 막는 강제 장치** [🕐 07:39](https://youtu.be/DrekqeDlO1w?t=459) — 코드 저장 시 자동 타입체크/린트 실행. 에러 있으면 Claude에게 되돌려 사람 개입 없이 자가 수정.
6. **OpenAI 사례: 엔지니어 3명, 5개월, 코드 0줄** [🕐 09:31](https://youtu.be/DrekqeDlO1w?t=571) — Agent.md + CI Gates + 도구 경계 + 피드백 루프 4가지로 100만 줄 코드베이스 구축. OpenAI 공식 블로그 출처.
7. **프롬프트 엔지니어링 → 컨텍스트 엔지니어링 → 하네스 엔지니어링 진화** [🕐 03:36](https://youtu.be/DrekqeDlO1w?t=216) — 말 잘 걸기 → 배경 정보 제공 → 실패 불가능한 구조 설계의 3단계 발전.
8. **스킬 과부하 역설** [🕐 04:40](https://youtu.be/DrekqeDlO1w?t=280) — 스킬이 수백 개 쌓이면 오히려 AI가 헷갈린다. 도구를 얹는 것이 아니라 정확히 동작할 환경 설계가 핵심.
9. **미래 전망: 하네스가 프레임워크 선택 기준이 됨** [🕐 15:48](https://youtu.be/DrekqeDlO1w?t=948) — "좋은 DX의 프레임워크"에서 "좋은 하네스가 갖춰진 프레임워크"로 기술 스택 선택 기준이 이동.
10. **개발자 역할 재정의: "엄밀함의 재배치"** [🕐 16:32](https://youtu.be/DrekqeDlO1w?t=992) — 코드 한 줄 한 줄의 엄밀함 → AI가 올바르게 동작하는 시스템 설계의 엄밀함으로 이동. 덜 기술적인 것이 아니라 더 높은 차원.

## 비판적 분석

### 주장 1: "OpenAI 엔지니어 3명이 5개월 동안 코드 한 줄 안 쓰고 100만 줄 코드베이스 완성"
- **제시된 근거**: OpenAI 공식 블로그 포스트 "Harness engineering: leveraging Codex in an agent-first world" 인용
- **근거 유형**: 실증 (1차 출처 있음)
- **한계**: "코드 한 줄 안 썼다"는 표현은 마케팅적 단순화. 실제로는 시스템 설계, 리뷰, 프롬프트 작성 등 상당한 인간 작업이 동반됨. 또한 내부 베타이므로 프로덕션 품질 수준이 알려지지 않음.
- **반론/대안**: InfoQ 분석에 따르면 해당 팀은 PR 리뷰, 아키텍처 결정, 하네스 유지보수에 상당한 시간을 투입했으며 "코드를 쓰지 않았다"는 것이 "일을 하지 않았다"와 동일하지 않다.

### 주장 2: "프롬프트는 부탁, 하네스는 강제"
- **제시된 근거**: Hook/CI Gate 예시. 저장 시 타입체크 실패 → 저장 안 됨.
- **근거 유형**: 개념적 비유 + 실제 동작 사례
- **한계**: 하네스도 결국 프롬프트(CLAUDE.md)에 의존하는 부분이 있다. CI Gates 같은 자동화된 강제 장치와 CLAUDE.md 같은 "참조 문서" 사이의 강제력 차이가 과장될 수 있다.
- **반론/대안**: Martin Fowler의 "Harness Engineering for Coding Agents" 아티클에서도 구조적 강제와 문서 기반 가이드를 구분해야 함을 지적. 완전한 강제는 제한적이며 대부분은 여전히 "잘 읽힌다는 가정" 위에 있음.

### 주장 3: "스킬이 수백 개 쌓이면 AI가 오히려 헷갈린다"
- **제시된 근거**: 야생말에 장치를 너무 많이 달면 느려진다는 비유
- **근거 유형**: 비유/추론 (실험 데이터 없음)
- **한계**: Anthropic의 실제 컨텍스트 로딩 메커니즘상 SKILL.md 파일은 매번 전체 로드되지 않고 description 기반 매칭으로 필요한 것만 포크된다. 수백 개 스킬의 실제 성능 영향에 대한 실증 데이터가 영상에 없음.
- **반론/대안**: 스킬 수보다는 각 스킬의 description 명확성과 트리거 조건 설계가 더 중요할 수 있다.

## 팩트체크 대상
- **주장**: "OpenAI 엔지니어 3명이 5개월 코드 한 줄 안 씀" | **검증 필요 이유**: 매우 구체적인 수치이며 마케팅적 과장 가능성 있음 | **검증 방법**: OpenAI 공식 블로그 직접 확인
- **주장**: "Mitchell Hashimoto가 2026년 2월에 harness engineering 용어를 처음 씀" | **검증 필요 이유**: 용어 기원 정확성 확인 필요 | **검증 방법**: mitchellh.com/writing/my-ai-adoption-journey 직접 확인
- **주장**: "Anthropic 연구팀이 Claude Opus에게 claude.ai 클론을 시켜 실패 패턴 관찰" | **검증 필요 이유**: Anthropic 공식 출처인지 확인 필요 | **검증 방법**: Anthropic 연구 블로그 검색

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "OpenAI 엔지니어 3명, 5개월, 코드 0줄, 100만 줄 코드베이스" | ✅ 확인 | OpenAI 공식 블로그 "Harness engineering: leveraging Codex in an agent-first world" (Ryan Lopopolo 저) — "0 lines of manually-written code", "roughly a million lines" 명시. InfoQ 2026-02 보도 교차 확인. |
| 2 | "Mitchell Hashimoto가 2026년 2월에 harness engineering 용어 최초 사용" | ✅ 확인 | mitchellh.com/writing/my-ai-adoption-journey 및 futureofbeinghuman.com, louisbouchard.ai 다수 출처에서 "early February 2026" + "co-founder of HashiCorp and creator of Terraform" 확인. |
| 3 | "Anthropic 연구팀의 Claude Opus claude.ai 클론 실험" | ⚠️ 부분 확인 | 해당 실험 자체는 Anthropic SWE-bench 관련 연구에서 유사 패턴이 언급되나 영상에서 인용한 정확한 "claude.ai 클론" 실험은 직접 출처 미확인. 컨텍스트 부패 문제 자체는 업계 공통 인식으로 확인됨. |

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| Harness Engineering 개요 | [agent-engineering.dev](https://www.agent-engineering.dev/article/harness-engineering-in-2026-the-discipline-that-makes-ai-agents-production-ready) | "context engineering의 한계(에이전트 드리프트, 엔트로피 누적)를 구조적 가드레일로 해결" | 일치 |
| Mitchell Hashimoto 원문 | [mitchellh.com](https://mitchellh.com/writing/my-ai-adoption-journey) | "실수할 때마다 다시는 그 실수를 못 하도록 엔지니어링" — 원문 정확히 인용 확인 | 일치 |
| OpenAI 공식 하네스 블로그 | [openai.com/index/harness-engineering](https://openai.com/index/harness-engineering) | 레이어드 아키텍처 + 커스텀 린터 + 구조적 테스트 + "garbage collection" (드리프트 스캔 후 에이전트가 수정 제안) | 보완 |
| Martin Fowler의 하네스 분석 | [martinfowler.com](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) | 구조적 강제 vs 문서 기반 가이드의 강제력 차이를 명확히 구분. 완전한 강제는 제한적 | 반박/보완 |
| HumanLayer 분석 | [humanlayer.dev](https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents) | "하네스 = 에이전트 런타임 외부의 모든 것 설정" — back-pressure와 검증 메커니즘 중심 관점 | 보완 |

## GTC 수행 결과

**GTC-1 관련성 필터:**
- 영상의 CLAUDE.md → Forge에서 `/home/damools/forge/CLAUDE.md` + `forge-core.md`로 이미 구현 ✅
- Hooks → `.claude/hooks/cleanup-plans.sh` 존재 확인 ✅ (단, 범위가 제한적)
- MCP → 전역 4개(brave-search, notion, stitch, nano-banana) 확인 ✅
- Skills → `~/.claude/skills/` 아래 50+ 스킬 구축됨 ✅

**GTC-2 기구현 확인:**
- CLAUDE.md 기반 온보딩 문서 → 이미 적용
- 스킬 시스템 → 이미 적용 (pptx, yt-analyze, grants-write 등)
- Hooks (저장 시 강제 실행) → 부분 적용 (cleanup-plans.sh는 cleanup 목적)

**GTC-4 영향도 검증:**
- CI Gates (코드 저장 시 자동 타입체크) → 현재 `.github/workflows/` 없음, Github Actions 미설정 → P1 가능
- Hook을 통한 코드 품질 강제 → Portfolio/GodBlade 개발 시 실제 blocking 가능성 있음 → P1 검토 가능

## 시스템 비교 분석

| 영상/리서치 제안 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------------|---------|:--:|:----:|:----:|
| CLAUDE.md 기반 에이전트 온보딩 문서 | 이미 적용 (forge-core.md, CLAUDE.md) | 없음 | — | — |
| Hooks를 통한 강제 검증 (코드 저장 시) | 부분 적용 (cleanup-plans.sh만 존재) | pre-commit/post-write lint hook 미구현 | M | M |
| CLAUDE.md에 "절대 금지 사항" 명시 | 이미 적용 (security.md, forge-core.md에 금지 목록 있음) | 없음 | — | — |
| CI Gates (PR 자동 테스트) | 미적용 (`.github/workflows/` 없음) | Portfolio/GodBlade 프로젝트에 CI 없음 | M | M |
| 도구 경계 설정 (에이전트 접근 권한 제한) | 부분 적용 (보안 규칙 문서화됨, 강제 장치 미흡) | 실제 파일시스템 레벨 제한 없음 | L | H |
| 피드백 루프 (실수 → 하네스 업데이트) | 부분 적용 (learnings.jsonl, 피드백 메모리 시스템 존재) | 실수 → 자동 CLAUDE.md 업데이트 파이프라인 없음 | M | M |

## 필수 개선 제안

### P0 — 즉시 적용 가능
- **[Forge]** CLAUDE.md에 "하네스 업데이트 프로토콜" 명시: 에이전트가 반복 실수를 발견하면 즉시 해당 규칙을 forge-core.md에 추가하는 절차 문서화 → 현재 learnings.jsonl에만 쌓이고 CLAUDE.md 반영이 수동임 → 자동화 트리거 텍스트 추가로 1시간 이내 해결 가능

### P1 — 이번 달
- **[Portfolio/GodBlade]** 코드 저장 시 Hook 설정: `.claude/hooks/` 아래 pre-write hook으로 TypeScript lint, C# 문법 체크 실행. 에러 시 Claude에게 다시 반환 → Portfolio TS 개발 시 반복 타입 에러 패턴 차단 가능 (GTC-4: 실제 개발 blocking 있음)
- **[Forge]** learnings.jsonl → CLAUDE.md 피드백 루프 자동화: 반복 피드백이 3회 이상 쌓이면 forge-core.md에 규칙으로 승격하는 스크립트 작성

### P2 — 다음 분기
- **[Portfolio/GodBlade]** CI Gates 구축: GitHub Actions (현재 미존재) 또는 GitLab CI로 PR 시 자동 테스트 실행 → 에이전트 생성 코드 품질 보장

## 실행 가능 항목
- [ ] CLAUDE.md에 "하네스 업데이트 프로토콜" 절차 추가 (적용 대상: Forge 시스템 전체)
- [ ] `.claude/hooks/` 에 pre-write TypeScript lint hook 작성 (적용 대상: Portfolio)
- [ ] learnings.jsonl 중 3회 이상 반복 피드백 → forge-core.md 자동 승격 스크립트 (적용 대상: Business/Forge)
- [ ] Mitchell Hashimoto 원문 블로그 정독 후 우리 CLAUDE.md 개선 포인트 추출 (적용 대상: Forge 전체)

## 관련성
- **Portfolio**: 3/5 — TypeScript/NestJS 개발에서 Hook 기반 품질 강제 직접 적용 가능
- **GodBlade**: 2/5 — C# Unity 환경에서 Hook 적용 복잡. 단 Agent.md 패턴은 적용 가능
- **비즈니스**: 4/5 — 현재 Forge 시스템 전체가 하네스 엔지니어링의 구현체. 개선 방향 명확

## 핵심 인용
> "프롬프트는 그냥 부탁이라면 하네스는 강제입니다." — 캐슬 AI

> "개발자의 역할이 바뀌고 있습니다. 코드를 작성하는 것에서 AI가 코드를 올바르게 작성할 수 있는 환경을 설계하는 것으로요." — 캐슬 AI

## 추가 리서치 필요
- Claude Code Hook 공식 문서 심화 분석 (검색 키워드: `claude code hooks pre-write post-write 2026`)
- Anthropic의 컨텍스트 부패 실험 원문 (검색 키워드: `anthropic context corruption agent experiment 2026`)
