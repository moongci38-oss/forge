# Claude Skills, 감으로 쓰면 끝납니다. Anthropic이 내놓은 검증 시스템 완전 분석
> 샘 호트만 : AI 엔지니어의 시선 | 2026-03-13 | 5.8K views | 12:47
> 원본: https://youtu.be/uhlqLjPYVYc
> 자막: 자동생성 (신뢰도 Medium) — 한국어 일반 회화, 일부 영어 기술 용어 오인식 주의

## TL;DR

Anthropic이 skill-creator를 대폭 업그레이드하여 빌트인 Evaluation 테스트와 A/B 테스트를 도입했다. 이를 통해 스킬 품질을 "감" 대신 데이터로 검증할 수 있게 되었으며, 스킬 유형(능력 향상형 vs 선호도 인코딩형)에 따라 테스트 전략을 다르게 적용해야 한다.

## 카테고리
tech/ai | #Claude-Skills #skill-creator #Evaluation #A/B-Test #Description-최적화 #Claude-Code

## 핵심 포인트

1. **빌트인 Evaluation 테스트 도입**: 스킬을 여러 변형으로 동시 실행하고 자연어 기준으로 자동 채점 [🕐 01:21](https://youtu.be/uhlqLjPYVYc?t=81)
2. **테스트 기준을 직접 정의해야 가치가 있다**: "테스트 돌려줘"만 하면 기능 가치가 반감 — 구체적 성공 기준 설정 필수 [🕐 02:57](https://youtu.be/uhlqLjPYVYc?t=177)
3. **A/B 테스트 = 블라인드 심사**: 심사위원 에이전트가 A/B 모르는 상태에서 순수 결과물만 평가 [🕐 04:05](https://youtu.be/uhlqLjPYVYc?t=245)
4. **스킬 vs 스킬 없음 비교 가능**: 모델 업그레이드 시 스킬이 오히려 방해가 될 수 있음을 데이터로 판단 [🕐 04:49](https://youtu.be/uhlqLjPYVYc?t=289)
5. **스킬 2가지 유형**: 능력 향상형(Capability Uplift) vs 선호도 인코딩형(Encoded Preference) [🕐 05:42](https://youtu.be/uhlqLjPYVYc?t=342)
6. **능력 향상형은 모델 업그레이드에 취약**: 새 모델마다 A/B 테스트 필요 [🕐 05:42](https://youtu.be/uhlqLjPYVYc?t=342)
7. **선호도 인코딩형은 충실도(Fidelity) 테스트가 핵심**: 워크플로우 순서, 참조 파일, 아웃풋 포맷 검증 [🕐 05:42](https://youtu.be/uhlqLjPYVYc?t=342)
8. **Description 최적화 기능**: 트리거 정확도 개선, 공식 스킬 6개 중 5개에서 효과 확인 [🕐 07:06](https://youtu.be/uhlqLjPYVYc?t=426)
9. **3가지 실전 원칙**: 테스트 기준 직접 정의 / 새 모델마다 A/B 테스트 / 선호도형은 충실도 반복 테스트 [🕐 08:27](https://youtu.be/uhlqLjPYVYc?t=507)
10. **패러다임 전환**: 테스트 없는 스킬 = 검증 안 된 코드 — "감에서 데이터 기반으로" [🕐 09:39](https://youtu.be/uhlqLjPYVYc?t=579)

## 댓글 인사이트
> 상위 댓글 11개 분석

### 커뮤니티 반응 패턴
- **동의/확인**: 다수 긍정 반응. "능력 향상형과 선호도 인코딩형 구분이 매우 인상적" (@한현석-i4z), "Skill 2.0 업데이트로 뭐가 달라진건지 이해가 잘되었습니다" (@henu7717)
- **보충 정보**: 채널 운영자(@ai.sam_hottman)가 설치 명령어와 공식 블로그 링크 보충. "전기세" → "전기요금" 용어 정정 (@이문기-m7j)
- **실용 질문**: Evaluation/A/B 테스트 프롬프트 방법에 대한 구체적 질문 (@henu7717), TTS 도구 문의 (@Sunhwan98)

### 주목할 댓글
> "skill creator 스킬이 업데이트 되었길래 그렇구나 하고 업데이트만 했는데, 이런 의미가 있었군요." — @이문기-m7j 👍 1

> "능력 향상형과 선호도 인코딩형 구분이 매우 인상적이네요! 잘 정리해주셔서 테스트 전략 자체가 달라야 한다는게 확 와닿았습니다" — @한현석-i4z 👍 1

> "기존 프로젝트에서 사용중이었던 커스텀 스킬들은 전부 점검해봐야겠네요. Evaluation, A/B 테스트에 대해서는 각각 프롬프트를 해줘야하나요?" — @henu7717 👍 1

## 설명란 자료 요약

| # | 링크 | 유형 | 핵심 내용 |
|:-:|------|:----:|---------|
| 1 | [Anthropic 공식 블로그](https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills) | 공식문서 | skill-creator 업데이트 발표. Evaluation, A/B, Description 최적화 3가지 기능 상세 |
| 2 | [GitHub: anthropics/skills](https://github.com/anthropics/skills) | 오픈소스 | skill-creator 포함 공식 스킬 레포지토리 |
| 3 | [오픈카톡방](https://open.kakao.com/o/g40dUv0f) | 커뮤니티 | 샘호트만 AI 정보 공유 커뮤니티 |

> 나머지 링크는 제휴 마케팅(n8n, hostinger, Make, Lovable 등) — 영상 내용과 무관

## 비판적 분석

### 주장 1: "테스트 없는 스킬은 검증 안 된 코드와 같다"
- **제시된 근거**: 소프트웨어 개발에서 테스트 코드 없이 배포하는 것과 동일 비유
- **근거 유형**: 유추적 논증
- **한계**: 스킬은 자연어 지시문이므로 코드 테스트와 1:1 대응이 완벽하지 않음. 코드 테스트는 결정론적이지만 LLM 출력은 확률적이므로 동일 입력에도 결과가 달라질 수 있음
- **반론/대안**: Anthropic 공식 문서에서도 "built-in way to run evaluations"이 아직 없다고 인정 (best-practices 문서). 사용자가 자체 evaluation system을 만들어야 하는 부분이 있음

### 주장 2: "모델이 좋아지면 스킬이 오히려 방해가 될 수 있다"
- **제시된 근거**: 택시 기사에게 내비게이션 강제하는 비유
- **근거 유형**: 경험적 추론 + 유추
- **한계**: 실제 데이터 없이 가설적 주장. 어느 시점에서 스킬이 "족쇄"가 되는지 정량적 기준 부재
- **반론/대안**: Anthropic best-practices 문서에서 "능력 향상형"과 "선호도 인코딩형" 구분을 공식 지원하며, 선호도 인코딩형은 모델 성능과 무관하게 가치 유지됨. 이 구분은 영상에서도 올바르게 설명됨

### 주장 3: "공식 스킬 6개 중 5개에서 트리거 정확도 개선"
- **제시된 근거**: Anthropic 공식 블로그 인용
- **근거 유형**: 실증 (1차 출처)
- **한계**: 개선 폭(몇 % 향상)과 측정 방법론 미공개
- **반론/대안**: 공식 블로그에서 확인 — 실제로 Description 최적화 기능이 트리거 성능을 개선했다고 보고. 수치적 세부사항은 블로그에서도 미공개

## 팩트체크 대상

| 주장 | 검증 필요 이유 | 검증 결과 |
|------|-------------|---------|
| "스킬 크리에이터의 대규모 업그레이드" | 업데이트 규모 판단 | **확인됨** — Anthropic 공식 블로그(2026-03)에서 Evaluation, A/B Test, Description 최적화 3가지 주요 기능 추가 발표 |
| "멀티에이전트가 병렬로 돌아가기 때문에 5개 테스트 동시 처리" | 기술 정확성 확인 | **부분 확인** — skill-creator가 서브에이전트를 활용한 병렬 실행을 지원하나, 정확한 구현 메커니즘은 공식 문서에 상세 미기재 |
| "6개 중 5개 스킬에서 트리거 정확도 개선" | 수치 검증 | **확인됨** — Anthropic 공식 블로그 원문과 일치 |

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| skill-creator 업데이트 | [Anthropic 공식 블로그](https://claude.com/blog/improving-skill-creator-test-measure-and-refine-agent-skills) (2026-03) | Eval, A/B, Description 최적화 3가지 기능. "testing turns a skill that seems to work into one you know works" | 일치 |
| Skill authoring best practices | [Anthropic 공식 문서](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) (2026-03) | Evaluation-driven development 권장. 최소 3개 시나리오 테스트 필수. Haiku/Sonnet/Opus 모두 테스트 | 보완 |
| 커뮤니티 반응 | [Reddit r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/comments/1rj8xao/) (2026-03) | 44 upvotes, 16 comments. eval scripts와 새 포맷에 대한 활발한 논의 | 보완 |
| 실전 활용 가이드 | [Geeky Gadgets](https://www.geeky-gadgets.com/anthropic-skill-creator/) (2026-03) | 스킬 노후화(skill obsolescence)와 비신뢰적 평가 방법 해결을 위한 프레임워크 | 보완 |
| Enterprise Skills | [Anthropic Enterprise 문서](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise) | "격리된 환경에서 Evaluation 필수, 공존 테스트(coexistence testing) 권장" — 프로덕션 배포 전 체크 | 보완 |

## 심층 분석: skill-creator 2.0

### 공식 블로그 분석

Anthropic 공식 블로그에서 확인된 3가지 핵심 기능:

1. **Evaluation 테스트**: 테스트 프롬프트 + 예상 결과를 정의하여 Claude가 기대 동작 수행 확인. 각 테스트는 독립 컨텍스트에서 실행 (교차 오염 방지)
2. **A/B 테스트**: 비교자 에이전트가 블라인드 평가. 변경 사항의 실제 효과를 객관적으로 판단
3. **Description 최적화**: 샘플 프롬프트와 비교하여 false positive/negative 감소. 공식 스킬 6/6 중 5개에서 트리거 성능 향상

### Anthropic 공식 best-practices와 비교

| 영상 내용 | 공식 문서 | 일치 여부 |
|----------|---------|:--------:|
| 능력 향상형 vs 선호도 인코딩형 | 공식 문서에서는 "Capability Uplift" 용어 미사용, 대신 "degrees of freedom" (high/medium/low)로 분류 | △ 유사 |
| 테스트 기준 직접 정의 필수 | "Build evaluations first" + "Evaluation-driven development" 패턴 권장 | ✅ 일치 |
| 새 모델마다 A/B 테스트 | "Test with all models you plan to use" — Haiku/Sonnet/Opus 전부 테스트 권장 | ✅ 일치 |
| Description 최적화로 트리거 개선 | "Description is critical for skill selection" — 100+ 스킬 중 선택 정확도가 Description에 의존 | ✅ 일치 |

### 우리 시스템과의 코드/설정 레벨 비교

**현재 Forge 스킬 시스템**:
- `.claude/skills/` 하위 30+ 활성 스킬 운영
- `skill-creator` 플러그인: forge-core.md에 "skill-creator 플러그인 기본" 언급이나, **자동화된 Evaluation/A/B 인프라는 미구현**
- Description: 각 SKILL.md frontmatter의 `description` 필드로 수동 관리 중
- 테스트: 수동 실행 후 눈으로 확인 (영상에서 지적한 "블랙박스" 상태와 동일)

**Anthropic best-practices 대비 갭**:
- SKILL.md 500줄 제한 권장 → 우리 일부 스킬 초과 가능성 있음
- "최소 3개 evaluation 시나리오" → 현재 0개
- "Haiku/Sonnet/Opus 전부 테스트" → 모델별 테스트 미수행
- "Evaluation-driven development" → 현재는 "문서 먼저, 테스트 나중" 패턴

## GTC (Ground Truth Check) 결과

### GTC-1: 관련성 필터
- **skill-creator**: forge-core.md에 권장 언급만 있고, 자동화 인프라 미구성
- **MCP 서버**: `.mcp.json`에 sequential-thinking만 등록 — skill-creator는 Claude Code 플러그인으로 별도 설치 필요
- **활성 스킬 30+개**: audit-*, daily-*, game-*, forge-* 등 — skill evaluation 전용 스킬 없음

### GTC-2: 기구현 확인
- **Skill evaluation 자동화**: 미구현
- **A/B test 인프라**: 미구현
- **Description 최적화 자동화**: 미구현
- **"eval" 관련 Grep**: 31개 파일 매칭되나 대부분 React best-practices 규칙 (skill eval 무관)

### GTC-3: 핵심 커버리지
- **Portfolio**: S4 PASS 완료, Trine 개발 중 (Spec 1-5 완료)
- **GodBlade**: 활성 매핑됨
- **Forge 파이프라인**: 정상 운영 중

### GTC-4: 영향도 검증
- 현재 장애/에러 유발: **아니오** — 스킬이 동작하고 있으나 품질 검증 없이 운영 중
- 이번 주 작업 blocking: **아니오** — Portfolio Spec 개발이 우선
- 비용 측정 가능한 증가: **아니오** — 불필요한 스킬 로드에 의한 토큰 낭비 가능성은 있으나 측정 불가
- deprecated/breaking change 기한: **아니오**
- → **P1 승격 불가. 모든 개선 제안은 P2 이하로 제한**

## 시스템 비교 분석

| 제안/발견 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|:--:|:----:|:----:|
| Evaluation 테스트로 스킬 품질 검증 | 미적용 — 수동 확인만 | 자동 테스트 기준 없음 | M | M |
| A/B 테스트로 스킬 유무 비교 | 미적용 | 스킬 필요성 데이터 판단 불가 | M | M |
| Description 최적화로 트리거 정확도 개선 | 수동 Description 관리 | 최적화 도구 미활용 | M | L |
| 능력 향상형 vs 선호도 인코딩형 분류 | 미분류 — 30+ 스킬 혼재 | 유형별 테스트 전략 없음 | L | L |
| 새 모델마다 스킬 포트폴리오 점검 | 미수행 | 불필요 스킬 누적 가능 | L | L |
| SKILL.md 500줄 제한 준수 | 미확인 | 일부 초과 가능 | L | L |

## 필수 개선 제안

### P0 — 즉시 적용 가능
(없음 — GTC-4 기준 P0 해당 항목 없음)

### P1 — 이번 주
(없음 — GTC-4 기준 P1 승격 불가. 현재 blocking/장애/비용증가/기한 없음)

### P2 — 이번 달

- **[Forge Skills]** `[Harness]` Description 최적화: 30+ 스킬의 description 필드를 skill-creator의 Description 최적화 기능으로 일괄 점검 → 트리거 정확도 개선 기대
- **[Forge Skills]** `[Harness]` 스킬 유형 분류: 30+ 스킬을 능력 향상형/선호도 인코딩형으로 분류하고 유형별 테스트 전략 수립
- **[Forge Skills]** `[Harness]` Evaluation 기준 세팅: 핵심 스킬 5개(forge, yt, daily-system-review, weekly-research, frontend-design)에 자연어 Evaluation 기준 3개씩 정의
- **[Forge Skills]** `[Harness]` 모델 전환 A/B 체크: Opus 4.6 기준 능력 향상형 스킬의 "스킬 있음 vs 없음" 비교 실행하여 불필요 스킬 정리

### 모니터링

- **[Forge Skills]** `[Cost]` 스킬 로드 빈도 모니터링: 실제 트리거되지 않는 스킬 식별 → 비활성화 후보 선정
- **[Forge Skills]** `[Harness]` SKILL.md 크기 점검: 500줄 초과 스킬 식별 및 분리

## ACHCE 축 분류

| 축 | 관련 제안/인사이트 | 우선순위 |
|---|----------------|:------:|
| **Agentic** | 멀티에이전트 병렬 Evaluation 실행 | P2 |
| **Context** | Description 최적화 → 트리거 정확도 = 컨텍스트 효율 | P2 |
| **Harness** | Evaluation 기준 정의, A/B 테스트, 유형 분류, 충실도 검증 | P2 |
| **Cost** | 불필요 스킬 로드 → 토큰 낭비 감소, SKILL.md 크기 최적화 | 모니터링 |
| **Human-AI Escal** | 테스트 기준을 Human이 직접 정의 → AI가 자동 채점 (적절한 분업) | P2 |

## 실행 가능 항목
- [ ] skill-creator로 기존 스킬 Description 최적화 실행 (대상: Forge 전체) `[Harness]`
- [ ] 30+ 스킬을 능력 향상형/선호도 인코딩형으로 분류 `[Harness]`
- [ ] 핵심 스킬 5개에 Evaluation 기준 3개씩 정의 `[Harness]`
- [ ] 능력 향상형 스킬 A/B 테스트 (스킬 유무 비교) `[Harness]`
- [ ] SKILL.md 500줄 초과 스킬 식별 및 분리 `[Cost]`

## 관련성
- **Portfolio**: 2/5 — 직접적 관련 없음. 스킬 개선이 간접적으로 개발 품질에 기여
- **GodBlade**: 1/5 — 거의 무관. Unity 프로젝트와 Claude Skills 시스템은 독립적
- **비즈니스**: 4/5 — Forge 스킬 시스템이 전체 파이프라인 품질의 핵심. 30+ 스킬의 품질 보증 체계 도입은 중기적으로 중요

## 핵심 인용
> "Testing turns a skill that seems to work into one you know works." — Anthropic 공식 블로그

> "테스트 없는 스킬은 검증 안 된 코드와 같습니다." — 샘호트만

> "모델 성능이 올라가면 여러분이 공들여 만든 스킬이 오히려 방해가 될 수 있습니다." — 샘호트만

> "한 번에 하나씩 이터레이션을 반복하는게 핵심입니다." — 샘호트만

## 추가 리서치 필요
- Anthropic skill-creator Evaluation 실행 가이드 (검색 키워드: `skill-creator eval run guide`, `claude code skill evaluation howto`)
- 스킬 유형 분류 프레임워크 (검색 키워드: `capability uplift vs encoded preference skill classification`)
- SKILL.md 크기 최적화 사례 (검색 키워드: `claude skill progressive disclosure optimization`)
