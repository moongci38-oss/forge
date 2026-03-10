# Claude Code + NotebookLM + Obsidian = 갓 모드입니다

**영상**: [https://youtu.be/v7_4stI79Xs](https://youtu.be/v7_4stI79Xs)
**채널**: Tech Bridge
**자막 유형**: 자동 생성 자막 (신뢰도: Medium — 고유명사 오역 다수. NotebookLM→"노트보혈램/노트보켓", Obsidian→"어브시디언/업시디언", Supabase→"소베이스/소퍼베이스", Figma→"피그머", Sentry→"센트리", PostHog→"포스트호그", Context7→"칸텍스트7", Playwright→"플레이라인". 고유명사는 문맥 추론으로 복원함.)
**분석일**: 2026-03-10

---

## 1. TL;DR

Claude Code에 NotebookLM(콘텐츠 분석), Obsidian(지식 베이스 누적), Skill Creator(워크플로우 자동화)를 통합하면, 사용할수록 점점 개인화되는 자기 개선형 리서치 파이프라인을 구축할 수 있다. 핵심 인사이트는 특정 도구 조합이 아니라, **워크플로우를 스킬로 만들고 → 스킬들을 슈퍼 스킬로 합치고 → Obsidian으로 AI를 점진적으로 훈련**하는 아키텍처 패턴 자체다.

---

## 2. 카테고리

**카테고리**: `tech/ai` · `tech/workflow`

**#tags**: `#claude-code` `#notebooklm` `#obsidian` `#skill-creator` `#ai-workflow` `#research-automation` `#personal-knowledge-management` `#pkm` `#mcp` `#self-improving-ai`

---

## 3. 핵심 포인트

1. [🕐 00:13](https://youtu.be/v7_4stI79Xs?t=13) **통합의 핵심 가치**: Claude Code + NotebookLM + Obsidian + Skill Creator 4개 도구를 결합하면 "리서치 괴물" 워크플로우 완성. 설정은 30분이면 가능하다고 주장.

2. [🕐 01:31](https://youtu.be/v7_4stI79Xs?t=91) **유연한 템플릿으로 사용**: 유튜브 검색은 예시일 뿐. PDF, 기사, 텍스트 등 어떤 정보 소스든 교체 가능. 콘텐츠 크리에이터가 아닌 일반 직장인에게도 적용 가능.

3. [🕐 02:19](https://youtu.be/v7_4stI79Xs?t=139) **슈퍼 스킬 아키텍처**: 개별 스킬(YouTube 검색, NotebookLM 분석)을 각각 만들고, Skill Creator로 이 하위 스킬들을 호출하는 하나의 슈퍼 스킬로 합침. 단일 슬래시 커맨드로 전체 파이프라인 실행.

4. [🕐 03:11](https://youtu.be/v7_4stI79Xs?t=191) **Obsidian이 기억 시스템 역할**: Claude Code가 생성하는 모든 마크다운 파일이 Obsidian 볼트에 저장. Claude Code는 볼트 전체를 컨텍스트로 읽어 "사용자가 어떻게 일하는지" 파악.

5. [🕐 03:59](https://youtu.be/v7_4stI79Xs?t=239) **자기 개선 루프(Self-Improving Loop)**: 워크플로우 실행 → 결과가 볼트에 쌓임 → CLAUDE.md가 함께 성장 → Claude Code가 사용자 스타일에 더 잘 맞춰짐. 1주: 효과 미미, 1개월: 확실한 효과, 1년: 엄청난 복리 효과.

6. [🕐 05:50](https://youtu.be/v7_4stI79Xs?t=350) **Skill Creator 설치 방법**: `/plug-in` 명령으로 Skill Creator 플러그인 검색 및 설치 → Claude Code 재시작 → `/skill-creator` 호출 → 자연어로 스킬 설명 → `.claude/` 폴더에 스킬 자동 생성.

7. [🕐 07:03](https://youtu.be/v7_4stI79Xs?t=423) **NotebookLM 연동 방법**: GitHub 레포(notebooklm-cli 계열)를 터미널에서 설치 → `nlm login` 인증 → Skill Creator로 NotebookLM 활용 스킬 생성. AI 처리가 NotebookLM(Google 인프라)에서 이루어져 Claude 토큰 절약.

8. [🕐 09:33](https://youtu.be/v7_4stI79Xs?t=573) **슈퍼 스킬 생성**: 기존 유튜브 스킬 + NotebookLM 스킬을 Skill Creator에 "의식의 흐름대로" 설명하면 두 스킬을 순서대로 호출하는 슈퍼 스킬 자동 생성. 슬래시 커맨드 사용 시 100% 실행 보장.

9. [🕐 10:59](https://youtu.be/v7_4stI79Xs?t=659) **실제 실행 결과**: "Claude Code + MCP 관련 상위 5개 영상 분석 + 인포그래픽 생성" 요청 시 약 6분 만에 완료. Supabase, Context7, Playwright, Figma, PostHog, Sentry 등을 상위 MCP로 자동 식별.

10. [🕐 13:07](https://youtu.be/v7_4stI79Xs?t=787) **CLAUDE.md의 역할**: Obsidian 볼트가 "뇌"라면 CLAUDE.md는 "뇌 속의 뇌". Claude에게 말하는 방식, 결과물 형식, 처리 선호도를 담은 규칙 파일. "최근 대화를 기반으로 CLAUDE.md 업데이트해줘"로 자동 진화 가능.

---

## 4. 비판적 분석

### 주장 1: "이 워크플로우는 30분 안에 설정 가능하다"
- **근거**: 각 도구(Skill Creator, NotebookLM CLI, 슈퍼 스킬 생성)가 단계별로 간단하다고 설명
- **근거 유형**: 경험(발표자 본인의 사용 경험)
- **한계**: 자막이 자동 생성이라 정확한 GitHub 레포명, 명령어가 불분명. NotebookLM CLI는 공식 API가 아닌 비공식 래퍼일 가능성이 높아 언제든 중단될 수 있음. 발표자의 숙련도가 이미 높아 "30분"은 과소 추정일 수 있음.
- **반론/대안**: 도구마다 별도 영상을 참조해야 하고, NotebookLM CLI 인증·설치 과정이 초보자에게는 30분 이상 소요될 가능성 있음.

### 주장 2: "NotebookLM이 처리하므로 Claude 토큰 비용이 절감된다"
- **근거**: NotebookLM의 AI 처리는 구글 인프라에서 이루어지므로 Claude API 토큰을 소모하지 않는다
- **근거 유형**: 경험(관측)
- **한계**: NotebookLM 자체도 유료 플랜이 있고, Google의 처리 비용이 간접적으로 발생. 완전히 "무료" 처리라고 보기 어려움. Claude Code가 결과를 받아 후처리하는 토큰은 별도 발생.
- **반론/대안**: 비용 절감 효과는 분석 규모와 출력 유형에 따라 크게 다름. 슬라이드 덱 등 복잡한 출력은 NotebookLM 자체 처리 시간이 15분까지 소요.

### 주장 3: "Obsidian 볼트가 쌓일수록 Claude Code 성능이 향상된다"
- **근거**: CLAUDE.md와 볼트 마크다운 파일들이 컨텍스트로 제공되어 Claude Code가 사용자 스타일을 파악한다
- **근거 유형**: 경험(개인 사용 경험) + 의견
- **한계**: 볼트 파일 수가 늘수록 컨텍스트 윈도우 한계에 부딪힐 수 있음. 무작정 모든 파일이 컨텍스트로 들어가는 게 아니라 Claude Code가 선택적으로 읽음. 성능 향상의 상한선에 대한 설명 없음.
- **반론/대안**: 컨텍스트 관리 전략(어떤 파일을 볼트에 넣을지, CLAUDE.md를 얼마나 구체화할지)이 핵심이며 이를 다루지 않음. 구조화되지 않은 볼트는 오히려 노이즈가 될 수 있음.

### 주장 4: "워크플로우를 스킬로 만들어 재사용하는 것이 핵심"
- **근거**: 슬래시 커맨드로 복잡한 파이프라인을 한 번에 실행할 수 있음
- **근거 유형**: 실증(영상에서 실제 실행 시연)
- **한계**: Skill Creator는 Claude Code 생태계에 종속된 도구. Claude Code 외 환경에서는 이식 불가. 스킬 품질이 프롬프트 설명의 명확성에 크게 의존.
- **반론/대안**: MCP 서버 + 커스텀 훅 조합으로도 유사한 파이프라인 구성 가능. 특정 플러그인에 과의존하면 해당 플러그인 업데이트/폐기 시 워크플로우 전체가 무력화될 위험.

---

## 5. 팩트체크 대상

- **주장**: "NotebookLM에 연결하는 공개 API와 GitHub 레포가 있다" | **검증 필요 이유**: 영상에서 레포명을 "노트보켓"이라고 언급하나 자막 오역으로 정확한 이름 불명확. NotebookLM 공식 API는 2026년 3월 기준 미공개 상태로 알려져 있어 비공식 래퍼일 가능성 높음 | **검증 방법**: GitHub에서 `notebooklm cli` 키워드로 검색, 스타 수 및 최근 유지보수 여부 확인. Google NotebookLM 공식 문서에서 API 제공 여부 확인.

- **주장**: "MCP 상위 5개 서버가 Supabase, Context7, Playwright, Figma, PostHog, Sentry다" | **검증 필요 이유**: YouTube 영상 분석 기반으로 자동 도출된 결과이므로 조회수/인기도 편향이 있을 수 있음. 실제 개발자 채택률과 다를 수 있음 | **검증 방법**: mcp.so, GitHub 레포 스타 수, 공식 MCP 마켓플레이스(anthropic.com)에서 실제 인기 MCP 서버 현황 교차 검증.

- **주장**: "인포그래픽 생성 포함 전체 파이프라인이 약 6분 완료된다" | **검증 필요 이유**: 영상 시연 시점의 서버 부하, 분석 대상 영상 수, NotebookLM 계정 플랜에 따라 처리 시간이 크게 달라질 수 있음 | **검증 방법**: 동일한 조건(영상 5개, 인포그래픽 출력)으로 직접 실행하여 실제 소요 시간 측정. NotebookLM 무료 vs 유료 플랜 처리 속도 차이 비교.

---

## 6. 실행 가능 항목

- [ ] **Skill Creator 플러그인 설치 및 테스트** — Claude Code에서 `/plug-in` 호출 후 Skill Creator 검색·설치 → 간단한 스킬(예: 파일 목록 조회) 하나 생성하여 동작 확인 (적용 대상: Business 워크스페이스 / Claude Code 환경)

- [ ] **NotebookLM CLI 레포 검색 및 신뢰도 평가** — GitHub에서 `notebooklm cli` 검색 → 스타 수, 최근 커밋, 이슈 활성도 확인 → 공식 API 사용 여부, 보안 리스크 판단 후 설치 여부 결정 (적용 대상: 리서치 워크플로우)

- [ ] **Obsidian 볼트를 Claude Code 작업 디렉토리와 연동** — Business 워크스페이스 루트 또는 `01-research/` 폴더를 Obsidian 볼트로 설정 → 기존 마크다운 파일들이 Obsidian 그래프 뷰에서 어떻게 연결되는지 확인 (적용 대상: Business 워크스페이스)

- [ ] **CLAUDE.md 자기 개선 패턴 적용** — Business `CLAUDE.md`에 현재 작업 스타일, 출력 선호도 섹션 추가 → 5-10회 세션 후 "최근 대화를 기반으로 CLAUDE.md 업데이트해줘" 요청 → 변경 내용 검토 및 커밋 (적용 대상: Business 워크스페이스 전반)

- [ ] **리서치 슈퍼 스킬 설계** — `01-research/` 워크플로우(WebSearch → 요약 → 분석 → 저장)를 스킬로 정의 → 이를 Skill Creator로 하위 스킬 2-3개로 분해 후 슈퍼 스킬로 합치기 (적용 대상: SIGIL S1 리서치 자동화)

- [ ] **파이프라인 출력물 유형 실험** — NotebookLM CLI가 지원하는 출력 유형(오디오 리뷰, 마인드맵, 플래시카드, 인포그래픽) 중 리서치 결과물로 유용한 유형 2개 선택 → 실제 리서치 주제로 테스트 (적용 대상: weekly-research 자동화 개선)

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|-----------|-----------|-----|---------|
| Skill Creator로 하위 스킬 → 슈퍼 스킬 합성 | Business `.claude/skills/`에 개별 스킬 존재 (`research-engineer`, `competitor-alternatives` 등), 슈퍼 스킬 없음 | 여러 스킬을 단일 파이프라인으로 호출하는 오케스트레이션 스킬 미구축 | 높음 |
| Obsidian 볼트 = AI 기억 시스템 | Business 워크스페이스 전체가 마크다운 기반이나 Obsidian 연동 없음 | Obsidian 볼트 설정 및 CLAUDE.md 자기 개선 루프 미구현 | 중간 |
| NotebookLM으로 토큰 절약형 콘텐츠 분석 | weekly-research에서 Subagent 5개로 병렬 리서치 수행 | YouTube/PDF 콘텐츠 심층 분석 시 NotebookLM 오프로딩 없음 → 토큰 비용 높음 | 중간 |
| CLAUDE.md 자동 업데이트(대화 기반 진화) | Business `CLAUDE.md`에 규칙 수동 관리 | "최근 대화 기반 CLAUDE.md 업데이트" 패턴 미적용 | 낮음 (수동 관리 충분) |
| 슬래시 커맨드로 파이프라인 단일 진입점 | `/sigil`, `/daily-system-review` 등 커맨드 존재 | SIGIL S1 리서치 전용 슬래시 커맨드 없음 (research-coordinator 직접 호출) | 중간 |
| 자기 개선 루프(볼트 누적 → 성능 향상) | Trine 세션 상태를 session-state.mjs로 관리 | 과거 세션의 분석 결과가 다음 세션에 컨텍스트로 자동 주입되는 메커니즘 없음 | 낮음 |

**시스템별 연관성 메모**:
- **SIGIL S1 리서치**: NotebookLM 오프로딩 패턴이 리서치 비용 절감에 직접 적용 가능. `research-coordinator`가 NotebookLM 스킬을 서브 태스크로 호출하는 구조 검토 가치 있음.
- **Claude Code Skills/Agents**: 슈퍼 스킬 합성 패턴은 현재 개별 스킬들을 오케스트레이션하는 `pipeline-orchestrator` 역할을 스킬 레벨에서 구현하는 방법으로 적용 가능.
- **weekly-research cron**: 현재 cron 자동화에 NotebookLM 처리를 추가하면 리서치 심도는 높이고 토큰 비용은 줄이는 개선 가능.
- **MCP**: 영상에서 언급된 상위 MCP(Supabase, Context7, Playwright, Figma)는 Business/Portfolio 프로젝트 MCP 구성과 겹치는 부분이 있어 팩트체크 후 MCP 선택 기준 보강에 활용 가능.

---

## 8. 관련성

| 프로젝트 | 점수 | 이유 |
|----------|------|------|
| **Portfolio** | 2/5 | Claude Code 스킬 아키텍처 패턴은 참고 가능하나, Portfolio는 개발 프로젝트 중심. Obsidian 볼트 연동은 직접 적용 어려움. |
| **GodBlade** | 1/5 | 게임 개발(Unity/C#)과의 직접 연관성 낮음. 리서치 파이프라인 자체는 게임 기획 리서치에 응용 가능하나 우선순위 낮음. |
| **비즈니스** | 4/5 | Business 워크스페이스는 리서치/기획/콘텐츠가 핵심. SIGIL S1 리서치 자동화, weekly-research 개선, 스킬 오케스트레이션에 직접 적용 가능. NotebookLM 토큰 절약 패턴은 비용 효율에 기여. |

---

## 핵심 인용

> "이건 스테로이드를 맞은 리서치입니다." — 워크플로우의 강화된 리서치 능력을 강조 [🕐 01:39](https://youtu.be/v7_4stI79Xs?t=99)

> "거의 자기 개선 루프가 되는 거죠. 워크플로우를 더 많이 실행할수록 제가 원하는 방식으로 분석을 하게 되고, 클로드 코드와 더 많이 대화할수록 그 모든 데이터가 더 많이 기록됩니다." [🕐 04:04](https://youtu.be/v7_4stI79Xs?t=244)

> "일주일 동안 하면 큰 효과가 없을 겁니다. 한 달이면 확실히 효과가 있을 겁니다. 1년 동안 수백 수백 개 문서와 대화를 하면 엄청나게 지속적인 효과가 있을 겁니다." [🕐 14:12](https://youtu.be/v7_4stI79Xs?t=852)

---

## 추가 리서치 필요

1. **NotebookLM CLI 비공식 래퍼 현황**: 공식 API 미제공 상태에서 어떤 레포가 가장 안정적인지, 인증 방식의 보안 리스크가 있는지 확인 필요. `01-research/` 팩트체크 항목으로 등록.

2. **Skill Creator 플러그인 공식 문서**: Claude Code 플러그인 마켓플레이스에서 Skill Creator의 정확한 스킬 생성 메커니즘, 스킬 파일 구조(`.claude/skills/` 내 형식) 확인. 기존 Business 워크스페이스 스킬 구조와의 호환성 검토.

3. **Claude Code의 Obsidian 볼트 컨텍스트 로딩 방식**: 볼트 내 모든 파일을 읽는지, 아니면 선택적으로 읽는지. 파일 수 증가 시 컨텍스트 윈도우 한계 도달 시점. `trine-context-management.md` 규칙과의 상충 여부 검토.

---

## 추가 리서치 결과

> 조사일: 2026-03-10 | 조사 항목: 4개

### 1. NotebookLM CLI 비공식 래퍼 현황

- **결론**: 공식 API와 비공식 래퍼가 **병존**한다. Google은 2025년 9월 NotebookLM Enterprise API를 알파로 출시했으나, 일반 사용자용 공개 API는 현재도 미제공. 비공식 래퍼 생태계는 활발하며 주요 레포 4개가 각기 다른 접근법을 취한다.
  - **`tmc/nlm`**: Go 기반 CLI, 노트북/소스/아티팩트 완전 관리. 가장 범용적.
  - **`teng-lin/notebooklm-py`**: Python API + Claude Code 연동 스킬 제공. 문서화 가장 상세.
  - **`jacob-bd/notebooklm-mcp-cli`**: 2026년 1월 MCP+CLI 통합 패키지로 리팩토링. Claude Code MCP 서버로 직접 연결 가능.
  - **`K-dash/nblm-rs`**: NotebookLM Enterprise API 전용 Rust 클라이언트.
  - **공식 Enterprise API**: 현재 알파 상태. 노트북 생성·소스 관리·공유 지원. Google Cloud 계정(유료) 필요. 일반 개발자 접근은 현실적으로 어려움.
- **보안 리스크**: 비공식 래퍼는 모두 구글 계정 쿠키·세션 토큰으로 인증. Google 서비스 약관(ToS) 위반 가능성 내재. 지속적 유지보수 보장 없음. **Business 워크스페이스에 직접 통합하기 전에 ToS 검토 권장.**
- **출처**: [tmc/nlm GitHub](https://github.com/tmc/nlm), [teng-lin/notebooklm-py GitHub](https://github.com/teng-lin/notebooklm-py), [jacob-bd/notebooklm-mcp-cli GitHub](https://github.com/jacob-bd/notebooklm-mcp-cli), [NotebookLM Enterprise API 공식 문서](https://docs.cloud.google.com/gemini/enterprise/notebooklm-enterprise/docs/api-notebooks) (2026-03-10 접근)
- **신뢰도**: High (다중 소스 + 공식 문서 확인)
- **비즈니스 적용**: 참고만 — `jacob-bd/notebooklm-mcp-cli`가 MCP 서버로 Claude Code에 직접 연결 가능한 구조상 가장 실용적. 단, ToS 리스크가 해소될 때까지 프로덕션 워크플로우 통합은 보류. 개인 실험 용도로는 `tmc/nlm` 또는 `notebooklm-py` 테스트 가능.

### 2. Skill Creator 플러그인 공식 문서 및 스킬 구조

- **결론**: Skill Creator는 Anthropic 공식 플러그인으로 확인됨. 스킬 파일 구조는 기존 Business 워크스페이스 `.claude/skills/` 구조와 **완전 호환**. 슈퍼 스킬(하위 스킬 호출)은 SKILL.md 내 지시문으로 구현 가능.
  - **스킬 디렉토리 구조**: `{skill-name}/SKILL.md` (필수) + `scripts/`, `references/`, `assets/` (선택)
  - **SKILL.md 구성**: YAML frontmatter(`name`, `description`, `context`, `disable-model-invocation` 등) + 마크다운 지시문
  - **슈퍼 스킬 구현**: `context: fork` + 하위 스킬 이름을 지시문에 명시하면 Claude가 해당 스킬을 순차/병렬 호출. 별도 Skill Creator 도구 없이도 SKILL.md 직접 작성으로 구현 가능.
  - **`user-invocable: false`**: 배경 지식 스킬(자동 로드 전용, `/` 메뉴 미노출) — Business 워크스페이스에서 이미 활용 중
  - **`disable-model-invocation: true`**: 수동 호출 전용 스킬 — 배포, 민감 작업에 적합
  - **컨텍스트 예산**: 스킬 설명(description)들이 컨텍스트 윈도우의 2% 예산(약 4,000토큰) 내에서 로드. 초과 시 일부 스킬 제외. `/context`로 확인 가능.
- **출처**: [Claude Code 공식 스킬 문서](https://code.claude.com/docs/en/skills), [Skill Creator Anthropic 플러그인 페이지](https://claude.com/plugins/skill-creator), [anthropics/skills GitHub](https://github.com/anthropics/skills) (2026-03-10 접근)
- **신뢰도**: High (공식 Anthropic 문서)
- **비즈니스 적용**: 적용 가능 — Business `.claude/skills/` 구조가 공식 표준과 이미 일치함. 슈퍼 스킬은 기존 스킬들을 `context: fork`로 오케스트레이션하는 SKILL.md를 작성하면 즉시 구현 가능. Skill Creator 플러그인 설치 없이도 수동 작성으로 동일한 결과 달성 가능.

### 3. 인기 MCP 서버 현황 (2026년 3월)

- **결론**: 영상에서 언급한 서버들(Context7, Playwright, Figma, Supabase)이 **실제로도 상위권**임이 확인됨. MCP 생태계는 2024년 11월 Anthropic 발표 후 급성장. 2025년 12월 Linux Foundation 기증으로 표준화 가속.
  - **Context7**: 조회 수 1위(약 11,000). 라이브러리 최신 버전별 문서를 컨텍스트에 실시간 주입. Business 워크스페이스에서 이미 활용 중.
  - **Playwright**: 2위(약 6,000). Microsoft 공식 MCP 서버. AI가 실제 브라우저 제어(accessibility tree 기반, 스크린샷 불필요).
  - **Figma**: 디자인 파일 정보 직접 접근. 포트폴리오/SIGIL S4 UI/UX 기획에 직접 활용 가능.
  - **Supabase**: 데이터베이스 작업 자동화. 백엔드 개발 가속.
  - **PostHog, Sentry**: 제품 분석·에러 모니터링 영역에서 인기. 영상의 리스트에 포함은 사실이나 "상위 5개"보다는 "주목할 만한 서버" 수준.
- **출처**: [FastMCP Top 10 MCP Servers 2026](https://fastmcp.me/blog/top-10-most-popular-mcp-servers), [Firecrawl Best MCP Servers 2026](https://www.firecrawl.dev/blog/best-mcp-servers-for-developers), [MCP 공식 서버 저장소](https://github.com/modelcontextprotocol/servers) (2026-03-10 접근)
- **신뢰도**: Medium (다중 소스이나 조회수 기반 순위로 실제 설치 수와 다를 수 있음)
- **비즈니스 적용**: 적용 가능 — Figma MCP를 Business MCP 구성에 추가하면 SIGIL S4 UI/UX 기획 시 디자인 파일 직접 참조 가능. 현재 Lighthouse/A11y MCP와 조합하면 디자인→품질검증 파이프라인 강화.

### 4. Claude Code의 컨텍스트 로딩 방식 (Obsidian 볼트 연동 관련)

- **결론**: Claude Code는 볼트 내 **모든 파일을 자동으로 읽지 않는다.** 스킬 description들만 컨텍스트에 상시 로드되며, 파일 내용은 도구(Read, Grep, Glob) 호출 시에만 로드. CLAUDE.md는 자동 로드됨.
  - **상시 로드**: CLAUDE.md 파일들, 스킬 description 요약 (컨텍스트 2% 예산)
  - **선택적 로드**: 스킬 호출 시 해당 SKILL.md 전체, 서브에이전트에 preload된 스킬
  - **수동 로드**: Read/Grep/Glob 도구로 명시적 접근 시
  - **Obsidian 볼트 ≠ 자동 컨텍스트**: 볼트 디렉토리를 워크스페이스로 설정해도 파일이 자동 주입되지 않음. CLAUDE.md에 볼트 파일 참조 지시를 포함하거나, `--add-dir` 플래그로 추가 디렉토리 지정 시 해당 디렉토리의 `.claude/skills/`는 자동 탐색됨.
  - **컨텍스트 관리**: 스킬 수가 많아질 경우 `/context`로 예산 확인 필요. `SLASH_COMMAND_TOOL_CHAR_BUDGET` 환경변수로 한도 조정 가능.
  - **`trine-context-management.md` 상충 여부**: 상충 없음. 규칙의 "3개 이상 파일 탐색 시 Explore 서브에이전트 위임" 원칙과 일치. 볼트 파일을 일괄 읽는 패턴은 오히려 규칙 위반이므로 주의 필요.
- **출처**: [Claude Code 공식 스킬 문서](https://code.claude.com/docs/en/skills) — 컨텍스트 예산 및 로딩 방식 섹션 (2026-03-10 접근)
- **신뢰도**: High (공식 문서)
- **비즈니스 적용**: 참고만 — 영상의 "Obsidian 볼트 전체가 컨텍스트로 로드된다"는 주장은 **과장**. 실제로는 CLAUDE.md가 핵심. Business 워크스페이스의 현재 구조(CLAUDE.md + 스킬 시스템)가 이미 올바른 방향. Obsidian 연동은 마크다운 파일 저장 및 그래프 뷰 시각화 목적으로는 유효하나, "AI 자동 학습"으로 오해하지 않도록 주의.

### 미조사 항목

- **"6분 완료" 파이프라인 실제 소요 시간**: 직접 실행 환경이 없어 측정 불가. 실제 테스트 시 NotebookLM 플랜(무료/Plus/Enterprise)별 차이를 비교할 것.
