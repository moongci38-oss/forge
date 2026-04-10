# 클로드 코드 맥스 요금제 쓰지 마세요. 토큰 절약 팁 52가지 총정리 - 3부 고급편
> 캐슬 AI | 1.8K views | 10:03
> 원본: https://youtu.be/EAysy2jly18
> 자막: 자동생성 (신뢰도 Low) — 고유명사 오인식 주의 (QMD, read-once, CCUCG 등 기술 용어 오기 다수)

---

## TL;DR
클로드 코드의 고급 토큰 절약 기법 10가지를 소개하는 영상으로, QMD 코드베이스 사전 인덱싱, read-once 훅, 훅 기반 로그 전처리, 환경변수 직접 제어, MCP 도구 설명 축약/필터링, 역할별 에이전트 분리, 멀티 터미널 전략을 다룬다. 초급(19개)·중급(23개)·고급(10개) 시리즈의 3부이며, "토큰 최적화 전에 먼저 많이 써봐야 의미 있다"는 사용 철학도 강조한다.

## 카테고리
`tech/ai` | #claude-code #token-optimization #mcp #hooks #agentic-dev

---

## 핵심 포인트

1. **QMD(코드베이스 사전 인덱싱)로 Glob→Grep→Read 3단계를 1단계로 단축** [🕐 00:25](https://youtu.be/EAysy2jly18?t=25)
   - 파일 탐색 시 Glob 전체 읽기 + Grep 키워드 검색 = 낭비. QMD가 미리 색인해 검색엔진처럼 바로 파일 찾기
   - 적용 후 탐색 토큰 90% 절감 사례 인용. CLAUDE.md에 "파일 읽기 전 항상 QMD로 먼저 검색하라" 1줄 추가

2. **read-once 훅으로 세션 내 중복 파일 읽기 차단** [🕐 01:51](https://youtu.be/EAysy2jly18?t=111)
   - Claude Code는 동일 파일을 매번 전체 토큰 비용으로 재읽음. read-once는 첫 읽기만 허용, 이후엔 diff만 전달
   - 오픈소스, 의존성 없음(bash+jq). diff 모드로 변경된 줄만 추출 가능

3. **훅으로 빌드/테스트 로그 전처리 — 실패 항목만 컨텍스트에 주입** [🕐 02:54](https://youtu.be/EAysy2jly18?t=174)
   - 수백 개 테스트 결과 전체가 컨텍스트에 유입되는 구조적 낭비
   - PreToolUse 훅으로 명령 출력 가로채기 → FAILED/ERROR 줄만 필터링해 Claude에게 전달
   - 빌드 로그도 동일 패턴. head/tail로 앞뒤 N줄만 자르는 것도 가능

4. **환경변수로 토큰 비용 직접 제어** [🕐 03:50](https://youtu.be/EAysy2jly18?t=230)
   - `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1`: 백그라운드 모델 호출 비활성화, 핵심 워크플로우 영향 없음
   - `DISABLE_COST_WARNINGS=1`: 비용 경고 메시지 끄기 (ccusage로 별도 추적)
   - `DISABLE_PROMPT_CACHING=0` 확인 필수: 반드시 켜놓아야 CLAUDE.md 등 반복 프롬프트 캐싱 적용
   - 모델별 프롬프트 캐싱 온/오프 개별 설정도 가능

5. **MCP 도구 설명(description)을 직접 다이어트** [🕐 05:16](https://youtu.be/EAysy2jly18?t=316)
   - 오픈소스 MCP는 사람 친화적 장문 설명 → 매 메시지마다 토큰 소모
   - 직접 만들거나 포크한 MCP라면 설명 축약 필수. 의미 전달되는 최소 문장으로

6. **MCP 도구 필터링 — 실제로 쓰는 도구만 노출** [🕐 05:52](https://youtu.be/EAysy2jly18?t=352)
   - GitHub MCP 30개 도구 중 8개만 사용 → 나머지 22개도 매 메시지에 유입
   - 환경변수/설정 플래그로 노출 도구 제한 가능한 서버 확인. 불가능하면 포크해서 불필요 도구 제거

7. **역할별 에이전트 분리 — 필요 최소 도구 세트 구성** [🕐 06:40](https://youtu.be/EAysy2jly18?t=400)
   - 단일 세션에 모든 도구를 몰아놓는 방식은 컨텍스트 낭비 + 오작동 리스크
   - 코드 리뷰 에이전트: 웹 도구 불필요. 고객 데이터 에이전트: 파일시스템 도구 불필요
   - 불필요 도구 제거 → 토큰 절감 + DB 실수 삭제 같은 사고 방지

8. **멀티 터미널 전략 — 작업 컨텍스트 분리** [🕐 07:28](https://youtu.be/EAysy2jly18?t=448)
   - 하나의 터미널에서 피처 개발+리팩토링+버그픽스 혼용 → 서로 다른 컨텍스트 뒤섞임
   - 터미널 창을 작업별로 분리 → 컨텍스트 충돌 없음 + 병렬 작업으로 생산성 향상

9. **최적화 전에 먼저 충분히 사용해봐라** [🕐 07:59](https://youtu.be/EAysy2jly18?t=479)
   - 운전 면허 직후 연비 운전하는 것과 같은 오류. 자연스럽게 다룰 수 있는 수준이 된 후에 최적화가 의미 있음

10. **단계적 적용 권장 순서** [🕐 08:50](https://youtu.be/EAysy2jly18?t=530)
    - 초급: `/clear` 자주 + 소형 모델 기본 사용
    - 중급: `.claudeignore` 생성 + CLAUDE.md 다이어트 + 미사용 MCP 서버 정리
    - 고급(오늘): QMD/read-once/훅 전처리 (여유 있을 때 적용)

---

## 댓글 인사이트
> 댓글 없음 (API 키 미설정, 스킵)

---

## 설명란 자료
설명란 링크 없음.

---

## 비판적 분석

### 주장 1: "QMD 적용 후 탐색 토큰 90% 절감"
- **제시된 근거**: 외부 자료 인용 (구체 출처 미제시)
- **근거 유형**: 인용(3rd party 데이터), 검증 불가
- **한계**: 90%는 탐색 단계에서만의 수치. 전체 세션 토큰 대비 실제 절감율은 코드베이스 구조/작업 패턴에 크게 의존. Medium 블로그(Simone Ruggiero) "95% 절감"도 비공개 코드베이스 기준
- **반론/대안**: Reddit 스레드에 따르면 Cymbal, JCodeMunch, codebase-memory-mcp 등 유사 도구가 다수 존재하며 성능 비교 없음. QMD가 업데이트되지 않는 코드베이스에서 stale index 문제 발생 가능

### 주장 2: "read-once 훅으로 중복 읽기를 완전히 차단할 수 있다"
- **제시된 근거**: 직접 경험적 설명
- **근거 유형**: 경험적 설명
- **한계**: 파일 변경 감지 TTL(20분) 설정이 필요하고, 컨텍스트 압축 이후 캐시가 무효화되는 엣지케이스 존재. diff 모드가 Claude의 이해를 오히려 해치는 상황도 가능
- **반론/대안**: dev.to 실측 데이터(47회 읽기 중 19회 차단, 40% 절감)는 합리적이나 영상의 "가장 큰 낭비 중 하나" 주장은 과장일 수 있음. 실제 최대 낭비는 불필요한 도구 정의 로딩일 가능성 높음

### 주장 3: "단일 세션에 모든 도구를 몰아놓는 것은 오작동 리스크"
- **제시된 근거**: DB 도구 실수 삭제 사례
- **근거 유형**: 논리적 추론 (합리적)
- **한계**: Claude Code에는 이미 허용/거부 권한 시스템이 있어 실제 오작동 빈도가 낮을 수 있음
- **반론/대안**: 도구 분리는 운영 복잡도를 높임. 권한 제어로 대체 가능한 경우 다수

---

## 팩트체크 대상
- **주장**: "QMD 적용 후 탐색 토큰 90% 절감" | **검증 필요 이유**: 수치 출처 불명확, 영상에서 "데이터를 가져왔다"고만 언급 | **검증 방법**: QMD GitHub star/issue 및 실제 벤치마크 데이터 확인
- **주장**: "MCP 서버 연결 시 턴당 최대 18,000 토큰 소모" | **검증 필요 이유**: 영상에는 구체 수치 없으나 MindStudio 자료에서 확인 가능 | **검증 방법**: MindStudio 블로그 + 실제 MCP 도구 토큰 측정
- **주장**: "DISABLE_PROMPT_CACHING=0으로 설정해야 캐싱이 켜진다" | **검증 필요 이유**: 자동 자막 오기 가능성 높음, 실제 환경변수 동작 확인 필요 | **검증 방법**: Anthropic 공식 문서 확인

---

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "QMD 적용 후 탐색 토큰 90% 절감" | ⚠️ 부분 확인 | Reddit 스레드 및 Medium 블로그에서 50K+ 토큰 절감 사례 다수 확인. 90%는 탐색 단계 기준 수치로 전체 세션 대비로는 달라짐. [Reddit r/ClaudeAI](https://www.reddit.com/r/ClaudeAI/comments/1sa2jbz/) |
| 2 | "MCP 서버 턴당 최대 18,000 토큰 소모" | ✅ 확인 | [MindStudio 블로그](https://www.mindstudio.ai/blog/claude-code-mcp-server-token-overhead): "각 연결된 MCP 서버는 모든 메시지에 도구 정의를 로드하여 턴당 최대 18,000 토큰" 명시 |
| 3 | "DISABLE_PROMPT_CACHING=0이면 캐싱 켜짐" | ✅ 확인 | [Anthropic GitHub issue #8632](https://github.com/anthropics/claude-code/issues/8632): 환경변수 설정 방식 확인. 단, 영상의 자막 오기로 "1"로 알아들을 수 있어 혼선 주의 |

---

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| QMD 코드베이스 인덱싱 | [Reddit r/ClaudeAI](https://www.reddit.com/r/ClaudeAI/comments/1sa2jbz/i_built_a_tool_that_saves_50k_tokens_per_claude/) | 세션당 50K 토큰 절감 사례. Cymbal, JCodeMunch 등 유사 도구 다수 존재 | 일치 |
| QMD 플러그인 허브 | [ClaudePluginHub](https://www.claudepluginhub.com/plugins/tobi-qmd) | QMD 공식 플러그인 페이지 존재 확인 | 보완 |
| QMD 세션 메모리 확장 | [GitHub wbelk/claude-qmd-sessions](https://github.com/wbelk/claude-qmd-sessions) | QMD를 Claude 세션 트랜스크립트 인덱싱에 활용하는 파생 프로젝트 | 보완 |
| read-once 훅 | [DEV Community](https://dev.to/boucle2026/read-once-a-claude-code-hook-that-stops-redundant-file-reads-4bjk) | 47회 읽기 중 19회 차단, 38,400 토큰(40%) 절감 실측. MIT, bash+jq만 필요 | 일치 |
| MCP 토큰 오버헤드 | [MindStudio](https://www.mindstudio.ai/blog/claude-code-mcp-server-token-overhead) | 턴당 최대 18,000 토큰. 미사용 서버 제거가 가장 효과적 | 일치 |
| 환경변수 문서 | [Claude Code Docs](https://code.claude.com/docs/en/model-config) + [GitHub issue #8632](https://github.com/anthropics/claude-code/issues/8632) | DISABLE_NON_ESSENTIAL_MODEL_CALLS, DISABLE_PROMPT_CACHING 공식 확인 | 일치 |
| 토큰 최적화 종합 | [everything-claude-code](https://github.com/affaan-m/everything-claude-code/blob/main/docs/token-optimization.md) | "서브에이전트로 파일 20개 읽어도 주 컨텍스트는 요약만 받는" 패턴 — 영상의 에이전트 분리와 동일 맥락 | 일치 |

---

## GTC (Ground Truth Check) 결과

**GTC-1 (관련성 필터)**
- QMD: 미사용. CLAUDE.md/rules에 없음. 우리 시스템에 미도입
- read-once 훅: 미사용. `/forge/.claude/hooks/`에 존재하지 않음
- 로그 전처리 훅: 부분 적용 — `agent-token-budget.sh`에 오류 패턴 감지 있으나 출력 필터링은 없음
- DISABLE_NON_ESSENTIAL_MODEL_CALLS 환경변수: `settings.json` env에 미설정
- MCP 도구 필터링: 전역 MCP 4개(brave-search, notion, stitch, nano-banana) + forge MCP 2개. 도구 필터링 미적용
- 에이전트 도구 분리: skills/agents 구조는 존재하나 MCP 레벨 도구 분리는 미적용
- 멀티 터미널: tmux 사용 중이나 worktree 방식으로 대응

**GTC-2 (기구현 확인)**
- 이미 적용된 것: 멀티 터미널(tmux), 에이전트 토큰 예산(agent-token-budget.sh), 미사용 MCP 정리는 기존 rules에서 권고됨
- 미적용: QMD, read-once, 로그 전처리, 환경변수 직접 제어

**GTC-4 (P1 승격 게이트)**
- read-once: 현재 반복 파일 읽기가 실제 장애를 유발하고 있지는 않음 → P2
- QMD: 탐색 효율화이나 현재 blocking 없음 → P2
- 로그 전처리 훅: 테스트 수백 개 실행 시 직접적 컨텍스트 절감 → P1 충족 가능 (forge 내 실제 테스트 규모 조건부)
- DISABLE_NON_ESSENTIAL_MODEL_CALLS: 1줄 설정으로 즉시 적용 가능 → P0

---

## 시스템 비교 분석

| 영상/리서치 제안 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------------|---------|:--:|:----:|:----:|
| QMD 코드베이스 사전 인덱싱 | 미적용 | Glob→Grep→Read 3단계 탐색 낭비 지속 | M | M |
| read-once 훅 | 미적용 | 세션 내 중복 파일 읽기 발생 | M | L |
| 로그 전처리 훅 (실패만 주입) | 미적용 (agent-token-budget은 오류 감지용, 필터링 아님) | 빌드/테스트 전체 로그 컨텍스트 유입 가능 | M | L |
| DISABLE_NON_ESSENTIAL_MODEL_CALLS=1 | 미설정 | 백그라운드 불필요 모델 호출 발생 가능 | L | L |
| MCP 도구 설명 축약 | 미적용 (기본 설명 그대로) | brave-search, notion, nano-banana 설명 그대로 로딩 | L | M |
| MCP 도구 필터링 | 미적용 | 사용 안 하는 도구 정의도 컨텍스트 유입 | L | M |
| 역할별 에이전트 도구 분리 | 부분 적용 (스킬 구조 존재, MCP 레벨은 미분리) | 에이전트별 MCP 셋 분리 미구성 | L | H |
| 멀티 터미널/worktree | 이미 적용 (tmux + worktree) | 없음 | — | — |
| 프롬프트 캐싱 활성화 확인 | 미확인 (DISABLE_PROMPT_CACHING 미설정) | 기본값 의존. 명시적 확인 필요 | M | L |

---

## 필수 개선 제안

### P0 — 즉시 적용 가능 (30분 이내)
- **[Forge]** `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` 환경변수 추가: `forge/.claude/settings.json`의 `env` 섹션에 추가. 핵심 워크플로우 영향 없이 백그라운드 토큰 소모 감소
- **[Forge]** 프롬프트 캐싱 명시적 확인: `settings.json` env에 `DISABLE_PROMPT_CACHING`이 없거나 `0`인지 확인 (현재 없음 = 기본 켜짐 상태로 정상)

### P1 — 이번 주 (조건부)
- **[Forge]** read-once 훅 설치: `curl -fsSL https://raw.githubusercontent.com/Bande-a-Bonnot/Boucle-framework/main/tools/read-once/install.sh | bash` 후 settings.json PreToolUse에 등록. 실측 40% 읽기 토큰 절감. **단, 설치 전 스크립트 내용 검토 필수** (외부 스크립트 직접 실행 보안 검토)
- **[Forge]** 로그 전처리 훅 추가: 기존 `agent-token-budget.sh` 패턴 참고하여 Bash PostToolUse에 FAILED/ERROR 필터링 훅 자체 구현. 외부 의존 없이 내부 구현 권장

### P2 — 이번 달
- **[Forge]** QMD 적용 검토: 코드베이스 규모가 커질수록 효과적. GodBlade/Portfolio 프로젝트에서 파일 탐색 비용이 높을 때 우선 적용. 설치 후 CLAUDE.md에 1줄 추가
- **[Forge]** MCP 도구 설명 축약: 직접 관리 가능한 nano-banana MCP의 도구 설명 검토 및 축약 적용

---

## 실행 가능 항목
- [ ] `settings.json` env에 `DISABLE_NON_ESSENTIAL_MODEL_CALLS=1` 추가 (Forge 시스템)
- [ ] `DISABLE_PROMPT_CACHING` 환경변수 현황 명시적 확인 (Forge)
- [ ] read-once 훅 GitHub 코드 검토 후 안전성 확인 시 설치 (Forge)
- [ ] 로그 전처리 훅(FAILED/ERROR 필터) 자체 구현 — hooks/ 디렉토리에 `filter-log-output.sh` (Forge)
- [ ] MCP 도구 필터링 옵션 — brave-search/notion MCP 문서 확인 (Forge)
- [ ] QMD 도입 검토 — GodBlade Unity 코드베이스 규모 고려 시 우선 적용 가능 (GodBlade)

---

## 관련성
- **Portfolio**: 2/5 — Next.js/NestJS 개발 시 Claude Code 사용한다면 read-once + QMD 효과적. 현재 직접적 blocking 없음
- **GodBlade**: 3/5 — Unity C# 코드베이스 규모가 클수록 QMD 탐색 효율화 직접 효과. `.cs` 파일 반복 읽기 많음
- **비즈니스(Forge)**: 4/5 — 정부과제, 리서치, 기획 파이프라인에서 Claude Code 집중 사용. 토큰 절감이 비용 직결. MCP 도구 정리+read-once 즉시 적용 가치 있음

---

## 핵심 인용
> "클로드 코드를 내 몸의 일부처럼 진짜 자연스럽게 다룰 수 있을만큼 많이 다뤄봐야, 그다음에 토큰을 줄이는 거에 신경 쓰는게 의미가 있다" — 캐슬 AI

---

## 추가 리서치 필요
- QMD 실제 설치/벤치마크 (검색 키워드: `qmd claude code github installation benchmark 2026`)
- read-once 훅 보안 검토 후 설치 스크립트 분석 (검색 키워드: `Bande-a-Bonnot Boucle-framework read-once`)
- CCUSAGE(ccusage) 토큰 트래킹 도구 실제 설정 (검색 키워드: `ccusage claude code token tracking dashboard`)
