---

## [신규] Opus 4.6 신기능 심층 가이드: 멀티 에이전트 자동화의 다음 단계

**2026년 2월 5일 출시된 Opus 4.6은 Claude Code 에이전트 오케스트레이션의 패러다임을 한 단계 끌어올렸다.** Agent Teams의 실전 투입 수준 성숙, Adaptive Thinking의 자동 추론 예산 조절, Compaction API의 장기 실행 에이전트 지원, 1M 토큰 컨텍스트 확장이 핵심이다. 동시에 Assistant 프리필링 제거 등 **API 브레이킹 체인지**가 포함되어 기존 파이프라인 마이그레이션이 필수적이다. 이 섹션은 각 기능의 **아키텍처 설계 판단 프레임워크와 즉시 사용 가능한 구현 패턴**을 제공한다.

---

### Opus 4.6 성능 프로파일: 어디에 투입할 것인가

모델 선택의 핵심은 **태스크-모델 매칭**이다. Opus 4.6이 압도적 우위를 보이는 영역과 Sonnet 4.5/Haiku 4.5가 더 효율적인 영역을 정확히 구분해야 한다.

| 벤치마크 | Opus 4.6 | Opus 4.5 | 변화 | 실무 의미 |
|---------|----------|----------|------|----------|
| **Terminal-Bench 2.0** | 65.4% | 59.8% | +5.6pp | CLI 에이전트 작업 신뢰도 향상 |
| **ARC-AGI-2** | 68.8% | 37.6% | **+83%** | 추상 추론·패턴 인식 비약적 개선 |
| **τ2-bench Retail** | 91.9% | 88.9% | +3.0pp | 복잡한 멀티스텝 에이전트 태스크 |
| **BrowseComp** | 84.0% | 67.8% | +16.2pp | 웹 에이전트·정보 수집 정확도 |
| **OSWorld** | 72.7% | 66.3% | +6.4pp | 컴퓨터 사용 에이전트 |
| **Finance Agent** | 60.7% | 55.9% | +4.8pp | 금융 도메인 자율 에이전트 |
| **BigLaw Bench** | 90.2% | — | 신규 | 법률 문서 분석·계약 검토 |
| **MRCR v2 1M** | 76% | — | 신규 | 1M 롱 컨텍스트 정보 검색 |
| **SWE-bench Verified** | 80.8% | 80.9% | -0.1pp | 코딩 성능은 동급 유지 |

> **아키텍트 판단 기준**: SWE-bench(코딩)는 동급이므로 **순수 코딩 작업에는 Sonnet 4.5가 비용 대비 최적**이다. Opus 4.6은 **복잡한 추론이 필요한 아키텍처 설계, 멀티스텝 에이전트, 보안 감사, 법률/금융 분석**에 집중 투입한다.

**모델 라우팅 전략 (비용 최적화)**:

```
┌─ 탐색/검색 태스크 ──→ Haiku 4.5    ($1/$5 MTok)    — 2배 속도, 3배 절감
├─ 코딩/구현 태스크 ──→ Sonnet 4.5   ($3/$15 MTok)   — SWE-bench 동급
├─ 아키텍처/추론 ────→ Opus 4.6     ($5/$25 MTok)   — ARC-AGI 83% 향상
└─ 긴급/속도 중시 ───→ Opus 4.6 Fast ($30/$150 MTok) — 2.5배 속도
```

---

### Agent Teams 실전 구현 가이드

Agent Teams는 기존 서브에이전트의 "단일 오케스트레이터 → 다수 워커" 한계를 넘어, **피어-투-피어 메시징 기반의 자율 분산 에이전트 시스템**을 제공한다. Nicholas Carlini의 C 컴파일러 데모(16개 에이전트, 100,000줄 Rust, GCC 테스트 99% 통과, 비용 $20,000)가 실전 가능성을 입증했다.

#### 활성화 및 환경 설정

```bash
# 환경변수로 활성화
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

# 또는 settings.json에 영구 설정
# ~/.claude/settings.json
{
  "experiments": {
    "agentTeams": true
  }
}
```

**필수 의존성**: Agent Teams는 각 팀원이 **독립된 터미널 세션**에서 실행되므로, 터미널 멀티플렉서가 필수다.

```bash
# tmux 설치 (권장)
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt install tmux

# tmux 세션 시작
tmux new-session -s agent-team

# iTerm2 (macOS 대안) — 네이티브 탭/패널 지원
# VS Code 통합 터미널은 현재 미지원
```

#### Lead/Teammates 아키텍처 상세

```
┌─────────────────────────────────────────────────┐
│                  Team Lead                       │
│  - 태스크 분해 (Decomposition)                    │
│  - 결과 종합 (Synthesis)                          │
│  - 품질 검증 (Verification)                       │
├─────────────────────────────────────────────────┤
│     ▼ 메시지 큐 (JSON 파일 기반)  ▲              │
│     ~/.claude/teams/{team}/inboxes/              │
├──────────┬──────────┬──────────┬────────────────┤
│ Teammate │ Teammate │ Teammate │   Teammate     │
│    A     │    B     │    C     │      D         │
│ (Auth)   │ (API)    │ (DB)    │   (Tests)      │
│ 독립 CWD  │ 독립 CWD  │ 독립 CWD │  독립 CWD       │
│ 독립 컨텍스트│ 독립 컨텍스트│ 독립 컨텍스트│ 독립 컨텍스트    │
└──────────┴──────────┴──────────┴────────────────┘
```

**메시지 큐 구조**: `~/.claude/teams/{team-name}/inboxes/` 디렉토리에 JSON 파일 기반 메시지가 저장된다. 각 Teammate는 자신의 인박스를 폴링하며, 다른 Teammate에게 직접 메시지를 보낼 수 있다(피어-투-피어).

**공유 태스크 리스트**: 모든 팀원이 접근 가능한 태스크 리스트에서 의존성 기반 자동 언블로킹이 작동한다. Teammate A가 "인증 모듈 완료"를 마크하면, "인증 테스트 작성"이 자동으로 언블로킹되어 Teammate D가 작업을 시작할 수 있다.

#### 4대 오케스트레이션 패턴: 언제 어떤 패턴을 사용할 것인가

**패턴 1: Fan-out/Fan-in** — 가장 범용적, 독립적 병렬 처리에 최적

```
사용 시점: 모듈 간 의존성이 낮은 병렬 작업
예시: 마이크로서비스별 독립 리팩토링, 다국어 번역, 멀티 모듈 테스트

Lead: "auth, payment, notification 모듈을 각각 리팩토링하라"
  ├─→ Teammate A: auth 모듈 리팩토링 (독립 실행)
  ├─→ Teammate B: payment 모듈 리팩토링 (독립 실행)
  └─→ Teammate C: notification 모듈 리팩토링 (독립 실행)
      ↓ 모두 완료
Lead: 결과 종합, 인터페이스 정합성 검증, 통합 테스트 실행
```

**패턴 2: Pipeline** — 순차적 의존성이 있는 워크플로

```
사용 시점: 전 단계 결과가 다음 단계 입력이 되는 경우
예시: 스키마 설계 → API 구현 → 프론트엔드 바인딩

Teammate A (Architect): DB 스키마 설계 → 완료 마킹
  ↓ 의존성 언블로킹
Teammate B (Backend): API 엔드포인트 구현 → 완료 마킹
  ↓ 의존성 언블로킹
Teammate C (Frontend): UI 컴포넌트 + API 바인딩
```

**패턴 3: Competing Hypotheses** — 최적 해법 탐색

```
사용 시점: 정답이 불확실하고 여러 접근법을 비교해야 할 때
예시: 성능 최적화 (캐싱 vs 쿼리 최적화 vs 인덱싱), 아키텍처 결정

Lead: "API 응답 시간 50% 개선 방안을 각각 구현하라"
  ├─→ Teammate A: Redis 캐싱 레이어 구현
  ├─→ Teammate B: 쿼리 최적화 + 인덱스 재설계
  └─→ Teammate C: CDN + Edge Computing 적용
      ↓ 모두 완료
Lead: 벤치마크 비교 → 최적 솔루션 선택 → 나머지 폐기
```

**패턴 4: Watchdog** — 안전성이 중요한 프로덕션 변경

```
사용 시점: 실행 중 모니터링과 롤백이 필요한 경우
예시: DB 마이그레이션, 프로덕션 배포, 대규모 리팩토링

Teammate A (Worker): DB 스키마 마이그레이션 실행
Teammate B (Watchdog): 실시간 모니터링
  - 쿼리 성능 저하 감지 → Worker에 "중단" 메시지
  - 데이터 정합성 체크 → 이상 시 롤백 트리거
  - 완료 시 → Lead에 "검증 통과" 보고
```

#### 파일 충돌 방지: 실전 규칙

Agent Teams의 **가장 큰 실전 리스크는 동일 파일 동시 편집**이다. 마지막 쓰기가 이전 내용을 덮어쓰므로, 반드시 영역 분리가 필요하다.

```markdown
# CLAUDE.md에 팀 규칙 추가 (필수)

## Agent Teams 파일 소유권 규칙
- auth 담당 에이전트: /src/auth/**, /tests/auth/** 만 수정
- payment 담당 에이전트: /src/payment/**, /tests/payment/** 만 수정
- 공유 파일 (/src/shared/**, /src/types/**): Lead만 수정 가능
- package.json, tsconfig.json: Lead만 수정, 의존성 추가 시 Lead에게 메시지
- 동시 수정 금지 파일: .env, docker-compose.yml, CI 설정
```

#### 비용 계획: Carlini 사례 역산

```
16 에이전트 × 2,000 세션 × ~100K 토큰/세션 (평균)
= 입력 ~20억 토큰 + 출력 ~1.4억 토큰
= ($5 × 2,000) + ($25 × 140) = $10,000 + $3,500 ≈ $13,500 (기본)
+ 프롬프트 캐싱, 재시도 등 오버헤드 → 총 ~$20,000

소규모 프로젝트 추정 (4 에이전트, 200 세션):
= ($5 × 200) + ($25 × 14) = $1,000 + $350 ≈ $1,350
```

> **비용 최적화 팁**: 탐색·읽기 중심 Teammate에는 **Haiku 4.5**를, 구현 Teammate에는 **Sonnet 4.5**를, Lead에만 **Opus 4.6**을 배정하면 비용을 **60-70% 절감**할 수 있다.

#### 제약사항 체크리스트

| 제약 | 상태 | 워크어라운드 |
|------|------|------------|
| 세션 재개 불가 | 현재 제약 | Git commit으로 중간 상태 영속화 |
| 팀 중첩 불가 | 현재 제약 | SDK로 외부 오케스트레이션 |
| VS Code 통합 터미널 미지원 | 현재 제약 | tmux 또는 iTerm2 사용 |
| 동일 파일 동시 편집 충돌 | 구조적 제약 | CLAUDE.md에 소유권 규칙 명시 |
| 토큰 비용 팀원 수 비례 | 구조적 제약 | 모델 계층화 (Haiku/Sonnet/Opus) |

---

### Adaptive Thinking: 자동 추론 예산 조절

기존 Extended Thinking은 `budget_tokens`로 추론 토큰 예산을 **수동 지정**해야 했다. Adaptive Thinking은 모델이 **문맥 단서를 기반으로 추론 깊이를 자동 결정**하는 새로운 패러다임이다.

#### 핵심 개념: budget_tokens → effort

| 파라미터 | 기존 (Opus 4.5) | 신규 (Opus 4.6) |
|---------|----------------|----------------|
| 설정 방식 | `budget_tokens: 10240` (수동) | `effort: "high"` (자동) |
| 추론 깊이 | 고정 토큰 예산 | 태스크 복잡도에 따라 유동적 |
| 오버슈팅 | 단순 태스크에도 예산 전부 소진 가능 | 단순 태스크는 자동으로 추론 생략 |
| 인터리브드 | 별도 활성화 필요 | **자동 활성화** |

#### effort 레벨별 동작 방식

| effort | 동작 | 추론 토큰 소비 | 적합한 태스크 |
|--------|------|--------------|-------------|
| `low` | 추론 생략 가능, 즉답 우선 | 최소 (0~1K) | 단순 변환, 포매팅, 조회 |
| `medium` | 필요 시 짧은 추론 | 중간 (1K~5K) | 일반 코딩, 리팩토링 |
| `high` (기본) | 항상 추론, 중간 깊이 | 표준 (5K~20K) | 디버깅, 설계, 코드 리뷰 |
| `max` | **Opus 4.6 전용**, 무제한 깊이 | 최대 (20K+) | 아키텍처 설계, 보안 감사, 복잡한 추론 |

#### API 구현: Python SDK

```python
import anthropic

client = anthropic.Anthropic()

# Adaptive Thinking 기본 사용
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=16000,
    thinking={
        "type": "adaptive"        # budget_tokens 대신 adaptive
    },
    output_config={
        "effort": "high"          # low | medium | high | max
    },
    messages=[{
        "role": "user",
        "content": "이 마이크로서비스 아키텍처의 장애 전파 경로를 분석하고 서킷브레이커 전략을 설계하라."
    }]
)

# 응답에서 추론 블록과 텍스트 블록 분리
for block in response.content:
    if block.type == "thinking":
        print(f"[추론] {block.thinking}")       # 내부 추론 과정
    elif block.type == "text":
        print(f"[응답] {block.text}")            # 최종 응답
```

#### API 구현: TypeScript SDK

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const response = await client.messages.create({
  model: "claude-opus-4-6",
  max_tokens: 16000,
  thinking: {
    type: "adaptive"
  },
  output_config: {
    effort: "max"                // Opus 4.6 전용 최대 추론 깊이
  },
  messages: [{
    role: "user",
    content: "이 코드베이스의 보안 취약점을 분석하고 OWASP Top 10 기준으로 분류하라."
  }]
});

// 인터리브드 씽킹: 도구 호출 사이에도 추론 블록이 삽입됨
for (const block of response.content) {
  switch (block.type) {
    case "thinking":
      console.log(`[추론 단계] ${block.thinking}`);
      break;
    case "tool_use":
      console.log(`[도구 호출] ${block.name}(${JSON.stringify(block.input)})`);
      break;
    case "text":
      console.log(`[최종 응답] ${block.text}`);
      break;
  }
}
```

#### Claude Code CLI에서의 Adaptive Thinking 활용

CLI 환경에서는 키워드 기반으로 추론 깊이를 제어한다. Opus 4.6에서 Adaptive Thinking이 기본 활성화되므로 별도 설정 없이 사용 가능하다.

```bash
# 세션 중 추론 토글: Tab 키
# 키워드 기반 추론 깊이 제어 (프롬프트에 포함)

# 표준 추론 (effort: high 상당)
"think. 이 함수의 시간 복잡도를 분석하라."

# 심층 추론 (effort: high+ 상당)
"think hard. 이 분산 시스템의 일관성 모델을 평가하라."

# 최대 추론 (effort: max 상당, Opus 4.6 전용)
"ultrathink. 전체 아키텍처를 분석하고 마이그레이션 계획을 수립하라. 코드는 작성하지 마라."
```

#### 인터리브드 씽킹: 도구 호출 사이의 추론

Opus 4.6의 핵심 혁신 중 하나다. 기존에는 모든 추론이 응답 시작 시 한 번에 이루어졌으나, **인터리브드 씽킹은 도구 호출 결과를 받은 후 다시 추론**하여 다음 액션을 결정한다.

```
기존 (Opus 4.5):
  [추론 블록] → [도구 호출 A] → [도구 호출 B] → [최종 응답]
  (첫 추론에서 모든 계획을 세워야 함)

신규 (Opus 4.6 Interleaved):
  [추론 블록 1] → [도구 호출 A] → [추론 블록 2] → [도구 호출 B] → [추론 블록 3] → [최종 응답]
  (각 도구 결과를 보고 다음 행동을 재추론)
```

이는 에이전틱 워크플로에서 **탐색적 문제 해결**(코드베이스를 읽으면서 점진적으로 이해도를 높이는 패턴)의 품질을 크게 향상시킨다.

#### 설계 판단: effort 레벨 라우팅 매트릭스

```python
# 실전 라우팅 예시: 태스크 유형별 effort 자동 선택
EFFORT_ROUTING = {
    # 단순 작업 → low (추론 토큰 절약)
    "format": "low",
    "rename": "low",
    "translate": "low",

    # 일반 개발 → medium
    "implement": "medium",
    "refactor": "medium",
    "fix_bug": "medium",

    # 복잡한 분석 → high (기본값)
    "code_review": "high",
    "debug_complex": "high",
    "design_api": "high",

    # 아키텍처/보안 → max (Opus 4.6 전용)
    "architecture_design": "max",
    "security_audit": "max",
    "migration_plan": "max",
    "incident_analysis": "max",
}
```

---

### Compaction API: 장기 실행 에이전트의 컨텍스트 생존 전략

장기 실행 에이전트 워크플로의 최대 병목은 **컨텍스트 윈도우 소진**이다. Compaction API는 서버 사이드에서 대화 히스토리를 자동 요약하여, 에이전트가 컨텍스트 한도에 도달하지 않고 수십·수백 턴의 작업을 지속할 수 있게 한다.

#### 핵심 메커니즘

```
[에이전트 루프 진행 중...]
  Turn 1~50: 정상 실행 (토큰 누적)
  Turn 51: 입력 토큰이 임계값(기본 150K) 초과
  ──→ Compaction API 자동 작동
  ──→ Turn 1~40 히스토리를 서버 사이드 요약 (~5K 토큰으로 압축)
  ──→ [요약 블록] + Turn 41~51 원본 유지
  Turn 52~: 새로운 공간에서 계속 실행
```

#### API 구현: 자동 컴팩션

```python
import anthropic

client = anthropic.Anthropic()

# 방법 1: 자동 컴팩션 (기본 — 투명하게 작동)
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=8192,
    # 베타 헤더 필요
    extra_headers={
        "anthropic-beta": "compact-2026-01-12"
    },
    # 컨텍스트 오버플로 시 자동 컴팩션
    context_window_overflow="compact",
    messages=long_conversation_history     # 150K+ 토큰의 대화 히스토리
)

# 응답에 compaction 블록이 포함될 수 있음
for block in response.content:
    if block.type == "compaction":
        print(f"[컴팩션 발생] 요약된 컨텍스트: {len(block.summary)} tokens")
    elif block.type == "text":
        print(f"[응답] {block.text}")
```

#### API 구현: 일시정지 후 재개 패턴 (외부 오케스트레이터 통합)

```python
import anthropic

client = anthropic.Anthropic()

def run_long_agent_loop(initial_messages: list):
    """외부 오케스트레이터가 컴팩션 시점을 제어하는 패턴"""
    messages = initial_messages

    while True:
        response = client.messages.create(
            model="claude-opus-4-6",
            max_tokens=8192,
            extra_headers={"anthropic-beta": "compact-2026-01-12"},
            context_window_overflow="compact",
            # 컴팩션 발생 시 즉시 반환 (자동 계속하지 않음)
            pause_after_compaction=True,
            messages=messages,
            tools=agent_tools
        )

        # 컴팩션으로 일시정지된 경우
        if response.stop_reason == "compaction":
            print("[컴팩션 일시정지] 외부 컨텍스트 주입 기회")

            # 1. 컴팩션된 메시지 히스토리 추출
            compacted_messages = response.compacted_messages

            # 2. 외부 컨텍스트 주입 (예: 최신 git status, 환경 변수 등)
            injected_context = {
                "role": "user",
                "content": f"[시스템 컨텍스트 리프레시]\n"
                          f"현재 Git 브랜치: {get_git_branch()}\n"
                          f"수정된 파일: {get_modified_files()}\n"
                          f"이전 작업 계속 진행하라."
            }

            # 3. 컴팩션된 히스토리 + 새 컨텍스트로 재개
            messages = compacted_messages + [injected_context]
            continue

        # 도구 호출 처리
        if response.stop_reason == "tool_use":
            tool_result = execute_tool(response)
            messages.append({"role": "assistant", "content": response.content})
            messages.append({"role": "user", "content": tool_result})
            continue

        # 정상 종료
        if response.stop_reason == "end_turn":
            return response

        break
```

#### Claude Code `/compact`와의 관계

| 측면 | `/compact` (CLI) | Compaction API |
|------|------------------|----------------|
| 실행 주체 | 사용자 수동 실행 | 서버 자동 실행 |
| 트리거 | `/compact` 명령 | 토큰 임계값 초과 |
| 제어 수준 | 즉시 실행 | `pause_after_compaction`으로 세밀 제어 |
| 외부 컨텍스트 주입 | 불가 | `compacted_messages` + 주입 가능 |
| 적합한 환경 | 대화형 CLI 세션 | SDK 기반 에이전트 루프 |

> **실전 권장**: CLI 대화형 세션에서는 기존 `/compact`를 70% 시점에 선제 실행하고, SDK 기반 자동화 파이프라인에서는 Compaction API의 `pause_after_compaction`으로 **외부 상태 동기화와 컨텍스트 리프레시를 결합**하는 패턴이 최적이다.

#### 에이전트 루프 + Compaction + Hook 통합 패턴

```python
from claude_agent_sdk import query, ClaudeAgentOptions

async def resilient_agent_loop(task: str, max_iterations: int = 100):
    """Compaction을 활용한 장기 실행 에이전트"""
    iteration = 0
    context_refreshes = 0

    while iteration < max_iterations:
        try:
            async for message in query(
                prompt=task if iteration == 0 else "이전 작업을 계속하라.",
                options=ClaudeAgentOptions(
                    model="claude-opus-4-6",
                    max_turns=20,           # 20턴마다 체크포인트
                    cwd="/path/to/project",
                    permission_mode='plan',
                    # Compaction 설정
                    compact_on_overflow=True,
                    pause_on_compaction=True
                )
            ):
                if message.type == "compaction":
                    context_refreshes += 1
                    # Hook: 컴팩션 발생 시 진행 상태 저장
                    save_checkpoint(message.summary, iteration)
                    print(f"[컴팩션 #{context_refreshes}] 컨텍스트 리프레시")

                yield message

        except ContextOverflowError:
            # 폴백: 수동 컴팩션 강제 실행
            print("[경고] 컨텍스트 오버플로 — 강제 컴팩션")
            iteration += 1
            continue

        break
```

---

### 1M 토큰 컨텍스트 + 128K 출력: 대규모 코드베이스 작업

Opus 4.6은 **Opus급 최초로 1M 토큰 컨텍스트**(베타)를 지원한다. MRCR v2 8-needle 1M 벤치마크에서 76%(Sonnet 4.5: 18.5%)로, **롱 컨텍스트에서의 정보 검색 정확도가 4배 이상** 향상되었다.

#### 활성화 방법

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=128000,                    # 128K 출력 (기존 64K의 2배)
    # 1M 컨텍스트 베타 활성화
    extra_headers={
        "anthropic-beta": "context-1m-2025-08-07"
    },
    messages=[{
        "role": "user",
        "content": [
            # 대규모 코드베이스를 통째로 컨텍스트에 로드
            {"type": "text", "text": entire_codebase_text},    # ~800K 토큰
            {"type": "text", "text": "이 전체 코드베이스의 아키텍처를 분석하고, "
                                     "모든 API 엔드포인트의 보안 취약점을 식별하라."}
        ]
    }]
)
```

#### 가격 정책: 롱 컨텍스트 비용 계획

| 컨텍스트 범위 | 입력 가격 (MTok) | 출력 가격 (MTok) | 비고 |
|-------------|----------------|----------------|------|
| ~200K (기본) | $5 | $25 | 표준 가격 |
| 200K 초과 | **$10** | **$37.50** | **2배 프리미엄** |
| Fast Mode | $30 | $150 | 2.5배 속도 |

```
1M 컨텍스트 비용 계산 예시:
- 입력: 200K × $5 + 800K × $10 = $1 + $8 = $9 /요청
- 출력 128K: 128K × $37.50 = $4.8 /요청
- 단일 요청 최대 비용: ~$13.80
→ 프롬프트 캐싱 적용 시 입력 비용 최대 90% 절감 가능
```

#### 실전 활용 패턴

**패턴 1: 전체 코드베이스 단일 로드 분석**

```python
# 리포지토리 전체를 컨텍스트에 로드하여 아키텍처 분석
import os

def load_codebase(root_dir: str, extensions: tuple = ('.py', '.ts', '.tsx')) -> str:
    """코드베이스를 단일 문자열로 로드 (1M 컨텍스트용)"""
    files = []
    for dirpath, _, filenames in os.walk(root_dir):
        for f in filenames:
            if f.endswith(extensions):
                filepath = os.path.join(dirpath, f)
                with open(filepath) as fh:
                    files.append(f"=== {filepath} ===\n{fh.read()}")
    return "\n\n".join(files)

codebase = load_codebase("/path/to/project")
# ~800K 토큰의 코드베이스를 한 번에 분석 가능
```

**패턴 2: 128K 출력으로 전체 앱 단일 응답 생성**

```python
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=128000,           # 128K = 약 96,000단어 = 전체 앱 파일
    thinking={"type": "adaptive"},
    output_config={"effort": "max"},
    messages=[{
        "role": "user",
        "content": "Next.js 14 + Prisma + tRPC 기반의 SaaS 대시보드 애플리케이션을 "
                   "전체 파일 구조와 함께 단일 응답으로 생성하라. "
                   "인증, RBAC, 결제 통합, 실시간 차트를 포함하라."
    }]
)
# 단일 응답으로 전체 프로젝트 파일 생성 가능
```

> **아키텍트 주의사항**: 1M 컨텍스트는 **모든 정보를 한 번에 로드**할 수 있다는 장점이 있지만, 200K 초과 시 입력 비용이 2배로 증가한다. 프롬프트 캐싱(`cache_control`)을 반드시 적용하고, 반복 분석이 필요한 경우 캐싱된 컨텍스트를 재사용하라.

---

### API 브레이킹 체인지: 마이그레이션 필수 사항

Opus 4.6은 **2개의 브레이킹 체인지**를 포함한다. 기존 파이프라인이 Opus 4.5에서 동작했더라도 Opus 4.6으로 전환 시 반드시 확인해야 한다.

#### 브레이킹 체인지 1: Assistant 메시지 프리필링 제거

**가장 영향이 큰 변경**이다. 마지막 메시지가 `role: "assistant"`인 경우 **400 에러**가 반환된다. LangChain, CrewAI 등 오픈소스 에이전트 프레임워크 상당수가 이 패턴에 의존하고 있어, 프레임워크 업데이트 확인이 필수적이다.

**영향받는 패턴과 마이그레이션**:

```python
# ❌ 기존 (Opus 4.5) — 이제 400 에러 발생
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "JSON으로 사용자 정보를 반환하라."},
        {"role": "assistant", "content": "{"}      # ← 프리필링: 400 에러!
    ]
)

# ❌ JSON 포맷 강제 프리필링 — 400 에러
messages=[
    {"role": "user", "content": "분석 결과를 반환하라."},
    {"role": "assistant", "content": "```json\n{"}  # ← 400 에러!
]

# ❌ 응답 접두사 프리필링 — 400 에러
messages=[
    {"role": "user", "content": "코드를 생성하라."},
    {"role": "assistant", "content": "물론입니다. "}  # ← 400 에러!
]
```

```python
# ✅ 마이그레이션 방법 1: output_config.format (권장)
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    output_config={
        "format": {
            "type": "json_schema",
            "json_schema": {
                "name": "user_info",
                "schema": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string"},
                        "email": {"type": "string"},
                        "role": {"type": "string"}
                    },
                    "required": ["name", "email", "role"]
                }
            }
        }
    },
    messages=[
        {"role": "user", "content": "JSON으로 사용자 정보를 반환하라."}
    ]
)

# ✅ 마이그레이션 방법 2: 시스템 프롬프트로 포맷 지정
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    system="응답은 반드시 유효한 JSON 객체로만 반환하라. 설명 텍스트 없이 JSON만 출력하라.",
    messages=[
        {"role": "user", "content": "사용자 정보를 반환하라."}
    ]
)
```

#### 브레이킹 체인지 2: 도구 호출 인자 JSON 이스케이핑 차이

유니코드 이스케이프(`\uXXXX`)와 슬래시 이스케이핑(`\/`)의 미세한 차이가 발생한다. **표준 JSON 파서를 사용하면 영향 없음**. 정규식으로 원시 파싱하는 코드에서만 검증이 필요하다.

```python
# ❌ 위험: 정규식 원시 파싱
import re
args_match = re.search(r'"path":\s*"([^"]*)"', tool_call_json)

# ✅ 안전: 표준 JSON 파서 사용
import json
args = json.loads(tool_call_json)
path = args["path"]
```

#### 완전 마이그레이션 체크리스트

```python
# === Opus 4.5 → Opus 4.6 마이그레이션 체크리스트 ===

# 1. 모델 ID 변경 (날짜 접미사 제거)
# Before:
model = "claude-opus-4-5-20251127"
# After:
model = "claude-opus-4-6"

# 2. Assistant 프리필링 제거
# Before:
messages = [
    {"role": "user", "content": "..."},
    {"role": "assistant", "content": "{"}     # 삭제!
]
# After:
messages = [{"role": "user", "content": "..."}]
output_config = {"format": {"type": "json_schema", "json_schema": {...}}}

# 3. Extended Thinking → Adaptive Thinking
# Before:
thinking = {"type": "enabled", "budget_tokens": 10240}
# After:
thinking = {"type": "adaptive"}
output_config = {"effort": "high"}    # low | medium | high | max

# 4. output_format → output_config.format
# Before:
output_format = {"type": "json"}
# After:
output_config = {"format": {"type": "json_schema", "json_schema": {...}}}

# 5. Deprecated 베타 헤더 제거 (GA 전환)
# 제거 대상:
#   - "effort-2025-11-24"
#   - "fine-grained-tool-streaming-2025-05-14"
#   - "interleaved-thinking-2025-05-14"
# 이 기능들은 이제 기본 활성화됨

# 6. 도구 호출 JSON 파싱 검증
# json.loads() 사용 여부 확인 — 정규식 파싱은 위험
```

#### LangChain / CrewAI 사용자 주의사항

```python
# LangChain ChatAnthropic 사용 시
# pip install langchain-anthropic>=0.3.x 확인 필요
# 프리필링 의존 코드가 내부적으로 수정되었는지 릴리스 노트 확인

from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(
    model="claude-opus-4-6",
    # 주의: with_structured_output()가 내부적으로 프리필링을 사용했을 수 있음
    # 최신 버전에서는 output_config.format으로 전환됨
)

# CrewAI 사용 시
# crewai>=0.100.x 에서 Opus 4.6 호환성 확인
# crew.yaml의 model 필드 업데이트
```

---

### 가격 구조 총정리와 비용 최적화 전략

| 구분 | 입력 (MTok) | 출력 (MTok) | 비고 |
|------|-----------|-----------|------|
| **Opus 4.6 기본** | $5 | $25 | 200K 이내 |
| **Opus 4.6 롱 컨텍스트** | $10 | $37.50 | 200K 초과 |
| **Opus 4.6 Fast Mode** | $30 | $150 | 2.5배 속도 |
| **Sonnet 4.5** | $3 | $15 | SWE-bench 동급 |
| **Haiku 4.5** | $1 | $5 | 탐색/검색 최적 |
| **프롬프트 캐싱** | 기본의 10% | — | 반복 입력 최대 90% 절감 |
| **배치 API** | 50% 할인 | 50% 할인 | 비실시간 워크로드 |

**FinOps 실전 전략**:

```python
# 1. 모델 라우팅으로 비용 60-70% 절감
def select_model(task_complexity: str) -> dict:
    routing = {
        "simple": {"model": "claude-haiku-4-5-20251001", "effort": "low"},
        "standard": {"model": "claude-sonnet-4-5-20250929", "effort": "medium"},
        "complex": {"model": "claude-opus-4-6", "effort": "high"},
        "critical": {"model": "claude-opus-4-6", "effort": "max"},
    }
    return routing[task_complexity]

# 2. 프롬프트 캐싱 적용 (대규모 시스템 프롬프트)
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=8192,
    system=[{
        "type": "text",
        "text": large_system_prompt,           # 10K+ 토큰의 시스템 프롬프트
        "cache_control": {"type": "ephemeral"} # 5분간 캐싱 → 90% 비용 절감
    }],
    messages=[{"role": "user", "content": "..."}]
)

# 3. 배치 API로 비실시간 워크로드 50% 절감
batch = client.batches.create(
    requests=[
        {"custom_id": f"review-{i}", "params": {
            "model": "claude-opus-4-6",
            "max_tokens": 4096,
            "messages": [{"role": "user", "content": pr_diff}]
        }}
        for i, pr_diff in enumerate(pr_diffs)
    ]
)
```

---

### 통합 실전 패턴: Agent Teams + Hook + MCP + Compaction

지금까지의 신기능을 조합한 **엔터프라이즈급 자동화 파이프라인** 구축 패턴을 제시한다.

#### 패턴: 자율 코드 리뷰 파이프라인

```
GitHub PR 생성
  ↓ GitHub Action 트리거
  ↓
┌─ Agent Teams (Opus 4.6 Lead) ────────────────────────┐
│                                                       │
│  Lead: PR 분석 → 태스크 분배                            │
│    ├─→ Teammate A (Sonnet 4.5): 코드 품질 리뷰          │
│    │   - MCP: GitHub (파일 변경 읽기)                    │
│    │   - Hook PostToolUse: 자동 린팅 체크                │
│    │                                                   │
│    ├─→ Teammate B (Opus 4.6, effort: max): 보안 감사    │
│    │   - MCP: Sentry (기존 취약점 조회)                  │
│    │   - Compaction API: 대규모 diff 분석 시 자동 압축    │
│    │                                                   │
│    └─→ Teammate C (Haiku 4.5): 테스트 커버리지 분석      │
│        - MCP: PostgreSQL (테스트 히스토리 조회)           │
│                                                       │
│  Lead: 결과 종합 → 구조화된 JSON 리뷰 생성               │
│  Hook Stop: 리뷰 품질 검증 (누락 항목 체크)               │
└───────────────────────────────────────────────────────┘
  ↓
GitHub PR Comment 자동 게시
Slack 알림 (심각도 High 이상)
```

#### GitHub Actions 설정 예시

```yaml
name: Opus 4.6 멀티 에이전트 코드 리뷰
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          model: claude-opus-4-6
          prompt: |
            이 PR을 멀티 에이전트로 리뷰하라:
            1. 코드 품질 (SOLID, 에러 핸들링, 테스트 가능성)
            2. 보안 (OWASP Top 10, 인증/인가, 입력 검증)
            3. 성능 (N+1, 메모리 누수, 병목)
            결과를 JSON 형식으로 출력하라.
          claude_args: >-
            --max-turns 10
            --output-format json
            --allowedTools "Read,Grep,Glob,Bash(git *)"
```

#### CLAUDE.md에 Opus 4.6 전용 규칙 추가

```markdown
## Opus 4.6 프로젝트 규칙

### 모델 라우팅
- 아키텍처 설계/보안 감사: Opus 4.6 (effort: max)
- 일반 코딩/리팩토링: Sonnet 4.5 (effort: medium)
- 코드 탐색/검색: Haiku 4.5 (effort: low)

### Adaptive Thinking 가이드라인
- PR 리뷰: "think hard" 키워드 사용
- 아키텍처 변경: "ultrathink" 키워드 사용
- 단순 포맷/린트 수정: 추론 불필요, Tab으로 비활성화

### 컨텍스트 관리
- 70% 도달 시 /compact 선제 실행 (기존 규칙 유지)
- 1M 컨텍스트 사용 시 200K 초과 비용 2배 주의
- Agent Teams 사용 시 파일 소유권 규칙 준수

### 마이그레이션 주의
- Assistant 프리필링 금지 (Opus 4.6 정책)
- JSON 출력은 output_config.format 사용
- 도구 호출 결과는 반드시 json.loads()로 파싱
```

---

### Opus 4.6 도입 로드맵: 점진적 적용 전략

즉시 도입 가능한 것부터 검증이 필요한 것까지 3단계로 나눈다.

**Phase 1: 즉시 적용 (Week 1-2)**
- Adaptive Thinking 전환 (`budget_tokens` → `effort`)
- API 브레이킹 체인지 마이그레이션 (프리필링 제거, 모델 ID 변경)
- CLAUDE.md에 Opus 4.6 모델 라우팅 규칙 추가
- effort 레벨별 비용 모니터링 대시보드 구축

**Phase 2: 파일럿 적용 (Week 3-4)**
- Compaction API 통합 (SDK 에이전트 루프)
- 1M 컨텍스트 + 프롬프트 캐싱 (대규모 코드베이스 분석)
- effort: max를 활용한 보안 감사 파이프라인 파일럿

**Phase 3: 확장 적용 (Month 2+)**
- Agent Teams 파일럿 프로젝트 (모듈 경계 명확한 프로젝트 선정)
- GitHub Actions + Agent Teams 통합 자동화
- FinOps 메트릭 기반 모델 라우팅 자동화

> **핵심 원칙**: Agent Teams는 실험적 기능이다. 프로덕션 크리티컬 워크플로에는 서브에이전트 + SDK 조합이 여전히 안정적이며, Agent Teams는 **읽기 중심 태스크**(코드베이스 리뷰, 병렬 분석, 멀티 가설 디버깅)에서 먼저 검증한 후 쓰기 작업으로 확장하는 것이 안전하다.
