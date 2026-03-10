# Claude Playground 플러그인 완전 분석: AI가 만드는 인터랙티브 UI

> **영상**: [Claude가 UI를 직접 만들어줍니다! Playground 플러그인 활용법](https://youtu.be/VxEZ7-gxZCY)
> **채널**: Tech Bridge
> **자막 신뢰도**: Medium (자동 생성 자막, 한국어 — 발음 오류 다수 포함)

---

## 1. TL;DR

Claude Code의 공식 Playground 플러그인은 텍스트 프롬프트 대신 **시각적 인터페이스(슬라이더, 어노테이션, 컨셉맵 등)로 피드백을 입력**하고, 그 상호작용을 Claude가 실행 가능한 자연어 명령으로 자동 변환하는 도구다. 6개 기본 템플릿(디자인 플레이그라운드, 데이터 탐색기, 컨셉맵, 문서 비평, 디프뷰, 코드맵)과 커스텀 생성 기능을 제공하며, 모든 산출물은 외부 의존성 없는 단일 HTML 파일로 공유·재사용이 가능하다.

---

## 2. 카테고리

**tech/ai**, **tech/dev-tools**

`#claude-code` `#playground` `#ai-ux` `#interactive-ui` `#prompt-engineering` `#developer-tools` `#anthropic` `#mcp` `#skill-plugin`

---

## 3. 핵심 포인트

- [🕐 00:00](https://youtu.be/VxEZ7-gxZCY?t=0) — Playground 플러그인의 핵심 개념: 텍스트 입력 대신 Claude가 작업 맞춤형 인터랙티브 UI를 직접 생성하고, 시각적 조작을 Claude 명령으로 자동 변환한다.

- [🕐 00:52](https://youtu.be/VxEZ7-gxZCY?t=52) — 일반 MCP 서버·슬래시커맨드 플러그인과 달리, 이 플러그인은 "Claude에게 새 스킬을 가르치는" 방식(skill-based plugin)으로 동작한다. Claude가 자동으로 사용 시점을 판단한다.

- [🕐 02:37](https://youtu.be/VxEZ7-gxZCY?t=157) — 모든 Playground의 공통 아키텍처: ① 단일 HTML 파일(CSS·JS 인라인, 외부 의존성 없음) ② 3-패널 레이아웃(컨트롤 / 라이브 미리보기 / 프롬프트 출력) ③ 프롬프트 출력 패널(변경된 값만 자연어 명령으로 생성).

- [🕐 03:36](https://youtu.be/VxEZ7-gxZCY?t=216) — 기본 제공 6개 템플릿: 디자인 플레이그라운드, 데이터 탐색기, 컨셉맵, 문서 비평, 디프뷰, 코드맵. 범위를 벗어난 요청 시 커스텀 Playground를 새로 생성한다.

- [🕐 05:40](https://youtu.be/VxEZ7-gxZCY?t=340) — MCP 트릭 활용 사례: 피드백을 복사·붙여넣기 없이 Claude에 직접 전송. NanoBanana(이미지 생성 AI)와 연결해 이미지 어노테이션 → 정밀 피드백 → 이미지 재생성 루프 구현.

- [🕐 06:29](https://youtu.be/VxEZ7-gxZCY?t=389) — 커스텀 데모: 이미지 어노테이션 Playground 생성. 캔버스에 사각형을 그리고 피드백 코멘트를 추가하면 "어느 위치에 어떤 변경 요청"이라는 구조화된 프롬프트를 자동 출력한다.

- [🕐 09:17](https://youtu.be/VxEZ7-gxZCY?t=557) — 컨셉맵 데모: Claude 플러그인 시스템(Plugin→Skill→Hook→MCP 관계)을 물리 시뮬레이션 캔버스로 시각화. 개념별 지식 수준(이해/불확실/미지)을 표시하면 맞춤형 학습 프롬프트를 생성한다.

- [🕐 10:47](https://youtu.be/VxEZ7-gxZCY?t=647) — "지식 상태 캡처 도구"로서의 활용: 일반 설명 요청 대신 "무엇을 알고 / 불확실하고 / 전혀 모르는지"를 시각적으로 전달해 훨씬 정밀한 답변을 유도한다.

- [🕐 13:11](https://youtu.be/VxEZ7-gxZCY?t=791) — 실전 팁 6가지: ① HTML이므로 언제든 수정 가능 ② 프리셋 먼저 클릭(80% 해결) ③ 프롬프트 출력은 세션 간 완전한 컨텍스트 포함 ④ 컨셉맵은 Force-Directed 레이아웃, 자동 정렬 버튼 활용 ⑤ 템플릿 미일치 시 커스텀 요청 ⑥ NanoBanana 등 시각적 출력 도구와 시너지.

- [🕐 14:38](https://youtu.be/VxEZ7-gxZCY?t=878) — 핵심 가치 재정의: "더 나은 프롬프트"가 아닌 "피드백 루프"의 변화. 시각적 입력 → 텍스트 출력(명령) 패러다임.

---

## 4. 비판적 분석

### 주장 1: "Playground는 Claude와 소통하는 완전히 새로운 방식이다"

- **근거**: 슬라이더·캔버스·어노테이션 등 GUI 조작을 자연어 명령으로 자동 변환하는 단방향 브릿지를 제공한다.
- **근거 유형**: 경험적(데모 시연 기반)
- **한계**: Artifact나 Canvas 기능(ChatGPT, Claude.ai 웹)과 유사한 기능을 CLI 환경에 적용한 것으로, 완전히 새로운 패러다임이라기보다는 기존 GUI 피드백 방식의 CLI 이식에 가깝다.
- **반론/대안**: Cursor의 Inline Edit, GitHub Copilot Chat의 파일 첨부 등 기존 도구도 시각적 컨텍스트를 명령으로 변환하는 기능을 제공한다. "완전히 새로운"이라는 표현은 과장일 수 있다.

### 주장 2: "피드백 루프가 진짜 변화다 — 더 나은 프롬프트보다 중요하다"

- **근거**: 시각적 상호작용이 사용자의 의도를 더 정확하게 캡처하여 언어적 모호성을 줄인다.
- **근거 유형**: 논리적 추론(의견)
- **한계**: 피드백 루프의 실제 품질 향상이 정량적으로 검증되지 않았다. "더 유용한 답변이 돌아온다"는 주장은 주관적이다.
- **반론/대안**: 텍스트 프롬프트 자체의 품질(Chain-of-Thought, few-shot 등)이 여전히 결과에 더 큰 영향을 미칠 수 있다.

### 주장 3: "MCP 트릭으로 복사·붙여넣기 없이 피드백을 직접 전송할 수 있다"

- **근거**: 커뮤니티 사례(X에 공유된 예시)를 언급하며 MCP 연결을 통한 직접 전송 가능성을 제시한다.
- **근거 유형**: 경험적(커뮤니티 사례)
- **한계**: 구체적인 구현 방법이 영상에서 설명되지 않는다. MCP 서버 설정, 보안 고려사항, 지원 MCP 서버 목록 등이 누락되어 있다.
- **반론/대안**: MCP 직접 전송이 항상 유리하지 않을 수 있다. 단일 HTML 파일 특성상 서버 연결 없이 독립 실행되는 장점이 사라진다.

### 주장 4: "모든 Playground는 외부 의존성 없는 단일 HTML 파일이다"

- **근거**: CSS·JS 인라인, CDN 링크 없음, 빌드 과정 없음을 명시적으로 언급한다.
- **근거 유형**: 실증적(실제 파일 구조 시연)
- **한계**: 실제 생성 파일에서 일부 CDN 의존성이 포함될 가능성을 배제할 수 없다(Claude가 생성하는 코드에 따라 달라질 수 있음). 영상에서는 파일 내용을 직접 보여주지 않는다.
- **반론/대안**: 복잡한 Playground(물리 시뮬레이션, 데이터 시각화)의 경우 완전한 인라인 구현이 파일 크기를 크게 증가시킬 수 있다.

### 주장 5: "Playground를 재사용 가능한 스킬로 변환할 수 있다"

- **근거**: "만족하면 Claude에게 재사용 가능한 Playground 스킬로 만들어 달라고 요청하면 된다"고 언급한다.
- **근거 유형**: 경험적(간략 언급)
- **한계**: 스킬 변환 과정, 저장 위치, 팀 공유 방법에 대한 구체적 설명이 없다. `.claude/skills/` 구조와의 연동 방식이 명확하지 않다.
- **반론/대안**: 수동으로 생성한 Playground HTML을 직접 스킬 디렉토리에 배치하는 방식이 더 명확하고 버전 관리에 유리할 수 있다.

---

## 5. 팩트체크 대상

- **주장**: "Playground 플러그인은 Anthropic 공식 마켓플레이스에 있으며 Claude Code 기본 제공된다" | **검증 필요 이유**: 영상 제작 시점(2026-03-10 추정)의 상태이며, Anthropic의 플러그인 정책·마켓플레이스 구조가 변경되었을 수 있다. "기본 제공"이 Pro/Max 플랜에만 해당하는지 불명확하다. | **검증 방법**: `claude /plugins` 명령 실행 후 목록 확인, 또는 Anthropic 공식 문서(docs.anthropic.com) 내 Claude Code 플러그인 섹션 확인.

- **주장**: "Playground가 생성한 HTML 파일은 외부 의존성 없이 완전히 독립 실행된다" | **검증 필요 이유**: Force-Directed 레이아웃(물리 시뮬레이션), D3.js 수준의 데이터 시각화 등 복잡한 기능을 완전 인라인으로 구현하면 파일 크기가 수 MB가 될 수 있고, 실제로는 CDN 링크를 포함할 수 있다. | **검증 방법**: 실제 생성된 Playground HTML 파일을 텍스트 에디터로 열어 `<script src=`, `<link href=`, CDN URL 패턴 검색.

- **주장**: "MCP 트릭으로 Playground 피드백을 Claude에 직접(복사·붙여넣기 없이) 전송할 수 있다" | **검증 필요 이유**: 구체적인 구현 방법이 영상에서 설명되지 않았으며, Playground가 로컬 HTML 파일로 실행된다는 특성상 MCP 서버와의 통신에 CORS, 파일 프로토콜 제약이 있을 수 있다. | **검증 방법**: Anthropic 공식 Playground 플러그인 소스코드 또는 커뮤니티 문서에서 MCP 연동 예시 확인. GitHub에서 "claude playground mcp" 키워드 검색.

---

## 6. 실행 가능 항목

### 즉시 적용 (1주 이내)

- [ ] **Playground 플러그인 설치 확인**: `claude /plugins` 실행 후 `playground` 목록 확인. 없으면 마켓플레이스에서 설치.
  - 적용 대상: Claude Code 사용자 전원

- [ ] **6개 기본 템플릿 탐색**: `"디자인 플레이그라운드 만들어줘"` 등 각 템플릿을 한 번씩 생성해 동작 방식 파악.
  - 적용 대상: Claude Code 개발자

- [ ] **SIGIL S3 기획서 작업에 design-playground 적용**: 기획서 작성 전 디자인 방향 탐색 시 design-playground 템플릿을 활용해 슬라이더로 spacing·color·typography를 탐색하고 결정값을 Spec에 반영.
  - 적용 대상: SIGIL 파이프라인 S3 Phase — `trine-playground.md` 규칙 기반으로 이미 정의됨

- [ ] **NanoBanana + Playground 시너지 테스트**: NanoBanana로 이미지 생성 → 이미지 어노테이션 Playground에 로드 → 피드백 작성 → 재생성 워크플로 한 사이클 실행.
  - 적용 대상: Business 비주얼 콘텐츠 제작 시

### 중기 적용 (1개월 이내)

- [ ] **컨셉맵 Playground → SIGIL S1/S2 통합**: 복잡한 요구사항 의존성(4개 이상 질문 발생 시) 시각화에 컨셉맵 Playground 활용. 생성된 HTML은 `docs/assets/playground/phase1.5-{이름}.html`에 저장.
  - 적용 대상: `trine-playground.md` 규칙 적용 프로젝트

- [ ] **document-critique Playground → Walkthrough/Spec 리뷰 워크플로 통합**: Spec 문서 또는 Walkthrough 작성 완료 후 document-critique Playground로 섹션별 승인/거부/코멘트 수행. 프롬프트 출력을 Check 3.5 입력으로 활용.
  - 적용 대상: Trine Phase 3 → Check 3.5 프로세스

- [ ] **재사용 가능 Playground 스킬 생성**: 자주 사용하는 커스텀 Playground(예: NanoBanana 이미지 피드백용)를 `.claude/skills/` 하위에 스킬로 변환 저장. 팀 공유 가능한 형태로 관리.
  - 적용 대상: Business 워크스페이스 `.claude/skills/` 관리

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|-----------|-----------|-----|---------|
| design-playground로 UI 컴포넌트 디자인 탐색 | `trine-playground.md`에 Phase 2 연동 규칙 정의됨. S3 기획서에서 design-playground → frontend-design 스킬 연계 흐름 문서화. | 실제 사용 빈도 낮음. 습관화 필요 | HIGH — 이미 규칙 있음, 실행만 필요 |
| concept-map으로 요구사항 관계 시각화 | `trine-playground.md`에 Phase 1.5 연동 규칙 정의됨 (4개 이상 질문 시 트리거). | 사용 조건(4개 이상 질문)이 까다로워 실제 트리거 빈도 낮음 | MEDIUM — 기획 복잡도 높을 때 명시적 활용 |
| NanoBanana + Playground 이미지 피드백 루프 | NanoBanana MCP 설치됨. Playground 플러그인 연동 방식 미정의. | NanoBanana 생성 이미지를 Playground 어노테이션 도구에 로드하는 워크플로 없음 | HIGH — Business 이미지 생성 워크플로 개선에 직접 기여 |
| code-map으로 코드베이스 아키텍처 시각화 | SIGIL S4 C4 Model 아키텍처 다이어그램에서 Mermaid 사용 중. `trine-playground.md`에 Phase 1 연동 정의됨. | code-map Playground vs Mermaid 중 언제 무엇을 쓸지 기준 모호 | LOW — Mermaid로 충분한 경우가 많음 |
| document-critique로 문서 리뷰 | CLAUDE.md, Spec, Walkthrough 리뷰는 텍스트 기반 Check 3.5로 수행 중. | 비코드 문서(CLAUDE.md, Walkthrough, README) 리뷰 시 시각적 승인/거부 인터페이스 미활용 | MEDIUM — Check 3.5 보완 도구로 활용 가능 |
| diff-review로 코드 변경 시각 리뷰 | PR 코드 리뷰는 `gh pr review`, `code-reviewer` 에이전트로 수행 중. | `trine-playground.md` 미채택 사유에 "Trine 5-에이전트 병렬 code-review가 더 정교"로 명시됨. | LOW — 현재 프로세스로 충분 |
| Playground를 재사용 스킬로 변환 | Business `.claude/skills/` 체계 존재. manage-skills.sh 관리 도구 있음. | 커스텀 Playground HTML → `.claude/skills/` 스킬 변환 절차 미정의 | MEDIUM — 반복 사용 Playground 발생 시 체계화 필요 |
| MCP 직접 전송(복사 없이) | `~/.claude/` MCP 설정 구조, `.mcp.json` 관리 방식 정의됨. | Playground HTML에서 MCP 서버로 직접 전송하는 방식 미검증 | LOW — 검증 후 도입 검토 |

---

## 8. 관련성

| 프로젝트 | 점수 | 이유 |
|---------|------|------|
| Portfolio | 4/5 | Next.js 컴포넌트 디자인 탐색(design-playground), 코드베이스 아키텍처 시각화(code-map), Spec/Walkthrough 리뷰(document-critique)에 직접 활용 가능. `trine-playground.md` 규칙이 이미 적용됨. |
| GodBlade | 2/5 | Unity C# 코드베이스이므로 code-map/concept-map 활용 가능하나, UI 디자인 Playground는 적용 범위 제한적. 게임 밸런싱 수치 탐색용 커스텀 Playground 가능성 있음. |
| 비즈니스(SIGIL) | 5/5 | SIGIL S1~S4 전 단계에 Playground 활용 규칙이 `trine-playground.md`에 정의됨. NanoBanana와의 연동이 비즈니스 비주얼 콘텐츠 워크플로에 즉시 적용 가능. Business의 document-critique 활용(PRD, GDD 리뷰)도 핵심 사용처. |

---

## 핵심 인용

> "이건 프롬프트 도움미가 아니라고 말하는게 맞을 것 같습니다. 지식 상태 캡처 도구입니다. 여러분이 어디에 있는지 클로드에게 정확히 알려주면 거기에 맞는 프롬프트를 생성합니다." — [🕐 10:47](https://youtu.be/VxEZ7-gxZCY?t=647)

> "여기서 진짜 변화는 더 나은 프롬프트가 아닙니다. 피드백 루프입니다." — [🕐 14:58](https://youtu.be/VxEZ7-gxZCY?t=898)

> "어디에 있는지 설명하지 않았습니다. 그냥 가르쳤죠." — [🕐 07:53](https://youtu.be/VxEZ7-gxZCY?t=473)

---

## 추가 리서치 필요

- Anthropic 공식 Playground 플러그인 소스코드 또는 문서에서 MCP 직접 연동 방법 확인
- 생성된 Playground HTML 파일의 실제 구조 검증 (외부 의존성 여부)
- NanoBanana + Playground 이미지 피드백 루프 실제 구현 방법 (MCP 연결 or 복사·붙여넣기)
- 커스텀 Playground를 `.claude/skills/` 스킬로 변환하는 정확한 절차
- `claude /plugins` 마켓플레이스에서 `playground` 플러그인 현재 설치 상태 확인

---

## 추가 리서치 결과

> 조사일: 2026-03-10 | 조사 항목: 5개

### 1. Playground 플러그인 현재 설치 상태 및 플랜 요구사항

- **결론**: Anthropic 공식 마켓플레이스(`claude.com/plugins/playground`)에 등록되어 있으며 Anthropic Verified 배지 보유. 현재 **18,651회 설치**됨. 특정 플랜(Pro/Max) 제한이 공식 페이지에 명시되지 않아 기본 Claude Code 계정에서 설치 가능한 것으로 추정. Claude Code 시작 시 Anthropic 공식 마켓플레이스(`claude-plugins-official`)가 자동으로 사용 가능 상태가 됨.
- **출처**: [Playground – Claude Plugin | Anthropic](https://claude.com/plugins/playground) (2026-03-10 접근), [GitHub - anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) (2026-03-10 접근)
- **신뢰도**: High
- **비즈니스 적용**: 적용 가능 — 즉시 설치하여 사용 가능. Business 워크스페이스에서 `claude /plugins`로 설치 여부 확인 후 적용.

### 2. Playground HTML 파일 외부 의존성 여부

- **결론**: 공식 문서에서 "모든 CSS·JS가 인라인 포함된 단일 HTML 파일, 외부 의존성 없음(no external dependencies)"을 명시적으로 확인. 단, 이 표현은 Playground 플러그인 스킬이 Claude에게 제시하는 생성 지침 기반이며, **Claude가 실제로 코드를 생성할 때 D3.js CDN 링크 등을 포함시킬 가능성은 여전히 있음**. 영상의 주장("외부 의존성 없음")은 공식 설계 목표이지, 모든 생성 결과의 보장은 아님.
- **출처**: [Discover and install prebuilt plugins - Claude Code Docs](https://code.claude.com/docs/en/discover-plugins) (2026-03-10 접근), [playground by anthropics/claude-plugins-official](https://skills.sh/anthropics/claude-plugins-official/playground) (2026-03-10 접근)
- **신뢰도**: Medium — 공식 설계 의도는 확인됨, 개별 생성 결과는 Claude 판단에 따라 달라질 수 있음
- **비즈니스 적용**: 참고만 — 오프라인 공유나 민감 환경에서 사용 시 생성된 HTML을 열어 `<script src=` 패턴 검색으로 CDN 의존성 여부를 직접 확인 권장.

### 3. 커스텀 Playground를 `.claude/skills/` 스킬로 변환하는 절차

- **결론**: 공식 Skills 문서에서 정확한 절차 확인. 커스텀 Playground HTML을 스킬로 변환하는 방법은 다음과 같음:
  1. 스킬 디렉토리 생성: `.claude/skills/my-playground/`
  2. `SKILL.md` 작성 (YAML frontmatter 포함):
     ```yaml
     ---
     name: my-playground
     description: [언제 이 스킬을 사용할지 설명 — Claude가 자동 판단에 사용]
     ---
     ```
  3. 생성된 Playground HTML 파일을 스킬 디렉토리에 복사 (예: `my-playground.html`)
  4. `SKILL.md`에서 HTML 파일을 참조하고, 사용 방법을 지시
  - 프로젝트 전용: `.claude/skills/` / 전역(모든 프로젝트): `~/.claude/skills/`
  - `disable-model-invocation: true` 설정 시 사용자만 `/my-playground`로 수동 호출 가능 (Claude 자동 트리거 방지)
- **출처**: [Extend Claude with skills - Claude Code Docs](https://code.claude.com/docs/en/skills) (2026-03-10 접근), [How to create custom Skills | Claude Help Center](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills) (2026-03-10 접근)
- **신뢰도**: High — 공식 문서 기반
- **비즈니스 적용**: 적용 가능 — Business 워크스페이스 `.claude/skills/` 또는 `~/.claude/skills/`에 반복 사용 Playground를 스킬화 가능. `manage-skills.sh`로 관리.

### 4. Anthropic 공식 Playground 플러그인 MCP 직접 연동 방법

- **결론**: 공식 문서와 GitHub 소스에서 Playground 플러그인 자체에 MCP 서버가 내장된 직접 전송 기능을 확인하지 못함. 다만 **플러그인 시스템 자체가 MCP 서버를 번들링하는 구조를 지원**함 — 플러그인 루트의 `.mcp.json`에 MCP 서버를 정의하면 플러그인 활성화 시 해당 MCP가 자동 기동됨. 영상에서 언급한 "MCP 트릭"은 별도의 로컬 MCP 서버(예: `mcp-feedback-enhanced`)와 Playground HTML을 수동 연결하는 커뮤니티 구현으로 추정됨. Playground HTML에서 `fetch()` API로 localhost MCP 서버에 POST하는 방식이 기술적으로 가능하나, 공식 지원 구현은 아님.
- **출처**: [Connect Claude Code to tools via MCP - Claude Code Docs](https://code.claude.com/docs/en/mcp) (2026-03-10 접근), [GitHub - anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) (2026-03-10 접근)
- **신뢰도**: Medium — "가능성"은 확인, 공식 구현 미확인
- **비즈니스 적용**: 참고만 — MCP 직접 전송보다 프롬프트 출력 패널의 "복사" 버튼 사용이 현실적. 직접 연동이 필요하다면 커뮤니티 구현(`mcp-feedback-enhanced`) 탐색 필요.

### 5. NanoBanana + Playground 이미지 피드백 루프 구현 방법

- **결론**: 커뮤니티 실증 사례 확인 (elvis @elvissaravia, Substack). 구현 워크플로우는 다음과 같음:
  1. NanoBanana MCP(`mcp__nano-banana__generate_image`)로 이미지 생성 → 파일 저장
  2. 커스텀 이미지 어노테이션 Playground HTML에 이미지 로드 (`<img src>` 또는 base64)
  3. 캔버스에 사각형/화살표 그리기 → 코멘트 텍스트 입력
  4. Playground의 프롬프트 출력 패널에서 구조화된 피드백("좌측 상단 배경을 더 밝게") 생성
  5. 해당 피드백을 `mcp__nano-banana__continue_editing` 또는 `edit_image` 도구에 입력 → 이미지 수정
  - 완전 자동화(복사 없는 직접 전송)는 공식 지원 없음. 현재는 프롬프트 출력 패널 복사 후 Claude에 붙여넣기가 표준 방법.
  - NanoBanana MCP의 `continue_editing` 도구가 이전 생성 세션을 유지하므로 일관성 있는 수정 가능.
- **출처**: [Claude + Nano Banana 2: How I Changed My Creative Workflow Overnight](https://aimaker.substack.com/p/how-to-connect-image-generation-claude-mcp-nano-banana) (2026-03-10 접근, 일부 유료 구독 제한), [GitHub - YCSE/nanobanana-mcp](https://github.com/YCSE/nanobanana-mcp) (2026-03-10 접근), elvis @elvissaravia Substack Note (2026-03-10 접근)
- **신뢰도**: Medium — 커뮤니티 실증 확인, 완전 자동화 구현 상세는 미확인
- **비즈니스 적용**: 적용 가능 — Business 비주얼 콘텐츠 제작 시 NanoBanana로 생성 → 어노테이션 Playground로 정밀 피드백 → `continue_editing`으로 수정 사이클 활용 가능. 완전 자동화보다 현실적인 반자동 워크플로우로 적용 권장.

### 미조사 항목

- 없음 (5개 항목 전체 조사 완료)
