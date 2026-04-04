# 클로드코드 잘 쓰는 10단계 — 순서 틀리면 90%가 포기합니다
> 메이커 에반 | Maker Evan | 조회수 20.6K | 11분 57초
> 원본: https://youtu.be/d-iNXwtwdFU
> 자막: 자동생성 (신뢰도 Medium)

---

## TL;DR
Claude Code 입문자가 흔히 저지르는 실수(순서 역전)를 짚고, 기초 이해→실전 제작→스킬→MCP→컨텍스트 엔지니어링→토큰 최적화→소비 파악→맥스 플랜→하니스 구성의 10단계 로드맵을 제시한다. "치매 아인슈타인" 비유로 Claude Code의 context compaction 문제와 관리 전략을 쉽게 설명한다.

## 카테고리
tech/ai | #ClaudeCode #컨텍스트엔지니어링 #토큰최적화 #MCP #클로드코드사용법

---

## 핵심 포인트
1. **Claude Code의 핵심 약점: 세션 간 기억 없음** [🕐 01:42](https://youtu.be/d-iNXwtwdFU?t=102) — "치매 아인슈타인" 비유, 새 세션 시작 시 모든 컨텍스트 초기화
2. **1단계: 플러그인 없이 기본 상태 1주일 운영** [🕐 02:30](https://youtu.be/d-iNXwtwdFU?t=150) — 동작 원리 이해 없이 도구 쌓으면 블랙박스 됨
3. **3단계: 스킬 = 반복 작업 레시피** [🕐 04:18](https://youtu.be/d-iNXwtwdFU?t=258) — 호출 시에만 로드 → 토큰 기본 소모 거의 없음
4. **4단계: MCP = Claude에 팔다리 부착** [🕐 05:00](https://youtu.be/d-iNXwtwdFU?t=300) — GitHub MCP로 PR/이슈 직접 생성, 브라우저 MCP로 웹 자동화
5. **MCP 5개 연결 시 컨텍스트 41% 소비** [🕐 05:22](https://youtu.be/d-iNXwtwdFU?t=322) — 커뮤니티 실측 수치, 사용 안 하는 MCP는 즉시 비활성화
6. **6단계: 컨텍스트 엔지니어링이 전체 10단계 중 가장 중요** [🕐 06:05](https://youtu.be/d-iNXwtwdFU?t=365) — CLAUDE.md = 치매 아인슈타인의 장기 메모리
7. **Context Compaction 발동 증상과 대처** [🕐 07:00](https://youtu.be/d-iNXwtwdFU?t=420) — compaction 후 지시 위반/버그 재발 → /clear 적극 활용, 작업 단위 쪼개기
8. **CLAUDE.md는 짧고 핵심적으로** [🕐 07:30](https://youtu.be/d-iNXwtwdFU?t=450) — 1,000줄+ 금지, AI가 못 따르는 규칙은 의미 없음. /init 생성본보다 Claude가 잘 못하는 부분을 직접 기록하는 것이 효과적
9. **7단계 토큰 절약 3원칙** [🕐 08:00](https://youtu.be/d-iNXwtwdFU?t=480) — 필요한 파일만 제공, 작업 난이도별 모델 선택(Sonnet→단순, Opus→복잡), MCP 대신 CLI/스킬
10. **10단계: 하니스 = AI가 일관되게 동작하도록 잡아주는 구조** [🕐 10:00](https://youtu.be/d-iNXwtwdFU?t=600) — 기초 없이 하니스 먼저 쓰면 기능만 쌓이고 이해 없음

---

## 비판적 분석

### 주장 1: "MCP 서버 5개 켜면 전체 컨텍스트의 41%가 사라진다"
- **제시된 근거**: "커뮤니티에서 측정한 수치"
- **근거 유형**: 커뮤니티 실측 (출처 미명시)
- **한계**: MCP 서버 종류/설정에 따라 편차 큼, 영상 제작 시점 이후 Claude Code 업데이트로 변동 가능
- **반론/대안**: Reddit r/ClaudeCode에서 "83.3k tokens (41.6%)" 실측 보고 존재 → 수치는 확인되나 MCP 구성에 따라 다름

### 주장 2: "CLAUDE.md는 짧게 써야 효과적이다"
- **제시된 근거**: 긴 CLAUDE.md는 토큰 낭비 + Claude가 전부 따르지 못함
- **근거 유형**: 경험적 관찰
- **한계**: "짧다"의 기준 미제시, 프로젝트 복잡도에 따라 필요 정보량이 다름
- **반론/대안**: Anthropic 공식 docs에서는 CLAUDE.md에 충분한 컨텍스트 제공 권장. 계층적 구조(루트 + 서브디렉토리 CLAUDE.md)로 분산하는 방법도 있음

### 주장 3: "1단계에서 10단계를 건너뛰면 안 된다"
- **제시된 근거**: 초보자가 흔히 하는 실수
- **근거 유형**: 관찰/경험
- **한계**: 이미 다른 AI 도구에 익숙한 개발자는 단계를 건너뛰어도 무방, 순서 강제는 학습 효율보다 판매/구독 유도 효과도 있음
- **반론/대안**: 팀 환경에서는 개인 학습 곡선보다 팀 규칙 공유(CLAUDE.md 표준화)가 더 중요

---

## 팩트체크 대상
- **주장**: "MCP 5개 시 41% 컨텍스트 소비" | **검증 필요 이유**: 커뮤니티 출처 불명 | **검증 방법**: Reddit r/ClaudeCode 검색
- **주장**: "context compaction 후 규칙 위반 발생" | **검증 필요 이유**: 재현 가능한 버그인지 확인 필요 | **검증 방법**: Claude Code 공식 docs, 커뮤니티 사례
- **주장**: "Claude Code Max 플랜: 5x = $100/월, 20x = $200/월" | **검증 필요 이유**: 가격 변경 가능 | **검증 방법**: Anthropic 공식 pricing 확인

---

## 팩트체크 결과

| # | 주장 | 판정 | 근거 |
|:-:|------|:----:|------|
| 1 | "MCP 5개 시 41% 컨텍스트 소비" | ✅ 확인 | Reddit r/ClaudeCode 실측: "83.3k tokens (41.6%) of context immediately after /clear" — 수치 일치. [출처: reddit.com/r/ClaudeCode 2025] |
| 2 | "compaction 후 규칙 위반 발생" | ✅ 확인 | Claude Code 공식 docs: "auto-compaction which summarizes conversation history when approaching context limits" — 요약 과정에서 상세 지시 유실 가능. 커뮤니티 다수 사례 보고 |
| 3 | "Max 5x=$100, 20x=$200" | ⚠️ 부분 확인 | 영상 제작 시점 기준 맞으나 Anthropic pricing은 지속 변동. 공식 확인 필요 |

---

## 웹 리서치 결과

| 주제 | 출처 | 핵심 인사이트 | 영상과의 관계 |
|------|------|-------------|:-----------:|
| MCP 토큰 오버헤드 | [Scott Spence 블로그](https://scottspence.com/posts/optimising-mcp-server-context-usage-in-claude-code) | MCP tools 82.0k tokens (41.0%) 실측, 최적화 방법 제시 | 일치 |
| Context compaction | [Claude Code 공식 docs](https://code.claude.com/docs/en/costs) | 자동 compaction 공식 확인, prompt caching으로 비용 절감 | 일치 |
| Context buffer 33K→45K | [claudefa.st](https://claudefa.st/blog/guide/mechanics/context-buffer-management) | autocompact buffer가 45K에서 33K로 변경됨 — 더 빨리 compaction 발동 | 보완 |

---

## Step 2.87: Claude Code 컨텍스트 관리 심층 분석

**context compaction 현황 (2026년 3월 기준):**
- autocompact buffer: 33K tokens (최근 45K→33K 하향 조정)
- 즉, 이전보다 더 빠르게 compaction 발동됨
- compaction 발동 기준: 전체 컨텍스트에서 33K 남았을 때 자동 요약

**MCP 오버헤드 실측:**
- 현재 forge 프로젝트 MCP: sequential-thinking, drawio, replicate, nano-banana, stitch = 5개
- 41% 오버헤드 = 실질 사용 가능 컨텍스트가 59%로 제한
- 스킬(`.claude/skills/`) 방식은 호출 시에만 로드 → 기본 오버헤드 없음 (이미 forge에서 올바르게 적용 중)

**우리 시스템과 비교:**
- CLAUDE.md 구조: forge-core.md + forge-planning.md = 패시브 요약 (~2,250 토큰) → 이미 최적화됨
- Skills 호출 방식: 이미 lazy loading 적용 중
- /clear 활용: 세션 관리 규칙화 여부 확인 필요

---

## GTC 결과

**GTC-2 (기구현 확인):**
- CLAUDE.md 패시브/딥 로딩 구조: 이미 forge에서 구현됨
- Skills lazy loading: 이미 구현됨
- MCP 프로젝트별 분산: 이미 구현됨 (글로벌 2개, forge 5개)

**GTC-4 (P1 승격 게이트):**
- forge MCP 5개 × 41% = 현재 forge 세션에서 컨텍스트 41% 고정 소비 중
- 이 중 자주 사용 안 하는 MCP (drawio, replicate, stitch)를 conditional로 전환하면 즉시 효과

---

## 시스템 비교 분석

| 제안/발견 | 우리 현황 | 갭 | 영향도 | 난이도 |
|----------|---------|:--:|:----:|:----:|
| CLAUDE.md 짧고 핵심적으로 | forge-core.md + planning.md 패시브 요약 구조 | 이미 최적화됨 | — | — |
| Skills lazy loading | 이미 적용 | 이미 적용 | — | — |
| 사용 안 하는 MCP 비활성화 | forge: 5개 항시 활성 | drawio/replicate/stitch → 필요 시에만 활성화 고려 | H | L |
| /clear 적극 활용 습관화 | 명시적 규칙 없음 | 세션 시작 가이드라인 추가 고려 | M | L |
| 작업 단위 쪼개기 (1세션 1작업) | 부분 적용 (계획은 있음) | 실제 습관화 여부 불명 | M | L |

---

## 필수 개선 제안

### P1 — 이번 주
- **[Forge]** MCP 조건부 활성화: forge 프로젝트에서 drawio, replicate, stitch를 .mcp.json에서 제거하고 필요 시 `mcp add` 방식으로 전환. 현재 5개 MCP가 세션마다 41% 컨텍스트 고정 소비 중 → 3개 제거 시 약 25% 절감 가능. 실제 비용 및 compaction 빈도 감소로 장기 세션 품질 향상

### P2 — 이번 달
- **[Forge]** CLAUDE.md에 "/clear 사용 시점" 가이드 추가: 관련 없는 새 작업 시작 전 /clear 필수 적용 명시

---

## 실행 가능 항목
- [ ] forge .mcp.json에서 drawio, replicate, stitch 조건부 분리 검토 (Forge, 30min)
- [ ] 세션 시작 프로토콜에 /clear 사용 기준 명시 (Forge CLAUDE.md, 15min)

---

## 관련성
- **Portfolio**: 4/5 — MCP 토큰 최적화, context compaction 관리 직접 적용 가능
- **GodBlade**: 3/5 — 스킬 활용, 컨텍스트 관리 동일하게 적용
- **비즈니스**: 2/5 — AI 도구 활용 효율화 관점

---

## 핵심 인용
> "클로드 코드를 잘 쓰는 사람과 못 쓰는 사람의 차이는 이 치매 아인슈타인을 어떻게 세팅하고 관리하느냐예요." — 메이커 에반

## 추가 리서치 필요
- autocompact buffer 33K 변경 이후 최적 세션 관리 전략 (검색 키워드: `claude code context buffer 33k autocompact strategy 2026`)
- 팀 환경 CLAUDE.md 표준화 사례 (검색 키워드: `claude code CLAUDE.md team standards best practices`)
