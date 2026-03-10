# 디자인 오류 90%를 해결한 방법

**영상**: [디자인 오류 90%를 해결한 방법](https://youtu.be/bFmSoBstVPY)
**채널**: Tech Bridge
**자막 신뢰도**: Medium (AI 생성 자막 — 고유명사 오인식 다수. 상세는 하단 참조)
**분석일**: 2026-03-10

---

## 1. TL;DR

Penpot(영상 내 "펜셀 대부") + Claude Code MCP 연동으로 디자인-코드 브릿지를 구축하고, `.pen` 파일 변경 감시 스크립트로 저장 시 자동 동기화를 실현했다. 여기에 멀티에이전트 병렬 구현 + GSAP 스크롤 애니메이션 + Lenis 스무스 스크롤 + AI 생성 UX 감사 스킬을 조합해 웹사이트 UX 등급을 C → B로 끌어올린 실전 1인 개발 워크플로우다.

---

## 2. 카테고리

**tech/web**, **tech/ai**

`#design-to-code` `#penpot` `#claude-code` `#mcp` `#gsap` `#lenis` `#next-js` `#ux-audit` `#ai-workflow` `#multi-agent` `#xml-prompting`

---

## 3. 핵심 포인트

- [🕐 00:00](https://youtu.be/bFmSoBstVPY?t=0) — **문제 제기**: Lovable·Bolt는 프롬프트→코드 전용(편집 가능한 디자인 캔버스 없음). Figma MCP는 읽기 전용이라 AI가 가져올 수는 있어도 수정 불가. 코딩 에이전트 직접 사용 시 디자인 변경마다 처음부터 재프롬프트. 기존 도구는 디자인 아니면 코드 둘 중 하나만 처리한다.

- [🕐 01:07](https://youtu.be/bFmSoBstVPY?t=67) — **Penpot 소개**: 디자인 특화 도구 + AI 개발 도구를 연결하는 브릿지 표방. 피그마 유사 인터페이스, 자동 CSS 클래스 생성, URL 라이브러리 지원. 디자인 파일을 `.pen` 포맷(JSON 기반)으로 프로젝트 폴더에 저장 → Git 버전 관리 가능. 현재 무료.

- [🕐 01:48](https://youtu.be/bFmSoBstVPY?t=108) — **MCP 자동 설정**: 데스크톱 앱 설치 시 Penpot MCP가 자동 구성되어 Claude Code에 모든 도구 즉시 등록. Claude Sonnet 4.6 선택 사용.

- [🕐 02:26](https://youtu.be/bFmSoBstVPY?t=146) — **양방향 동기화의 현실**: "양방향 브릿지"를 기대했으나 실제로는 수동 동기화 요청 필요. 디자인 섹션별 분석 후 구현하는 방식 — 캔버스와 정확히 일치하지만 수정마다 반복 요청이 너무 큰 오버헤드.

- [🕐 03:24](https://youtu.be/bFmSoBstVPY?t=204) — **워처 스크립트 직접 제작**: JS 파일 감시 라이브러리로 `.pen` 파일 모니터링 → 변경 감지 시 동기화 프롬프트와 함께 Claude CLI 자동 실행. 쿨다운 기간으로 토큰 낭비·세션 한도 방지. `npm run sync` 한 명령으로 가동. 이후 Cmd+S마다 자동 동기화 트리거.

- [🕐 04:35](https://youtu.be/bFmSoBstVPY?t=275) — **권한 사전 설정 필수**: `~/.claude/settings.json`에 읽기·쓰기·MCP 도구 호출 권한 미리 허용 필수. 미설정 시 Claude가 권한 프롬프트에서 무한 대기 → 자동화 불가.

- [🕐 05:27](https://youtu.be/bFmSoBstVPY?t=327) — **멀티에이전트 병렬 구현**: 5개 페이지에 에이전트 5개 할당, 동시 병렬 작업. CLAUDE.md·UI 가이드 등 컨텍스트 문서 공유로 전체 폰트·스타일 일관성 유지.

- [🕐 06:49](https://youtu.be/bFmSoBstVPY?t=409) — **XML 구조화 프롬프팅**: Claude가 XML 태그 프롬프트에 최적화되어 있음(Anthropic 공식). GSAP 구현 시 작업 세부사항·의존성·섹션별 동작·규칙을 모두 XML 태그로 구조화해 전달 → 정확도 향상.

- [🕐 08:06](https://youtu.be/bFmSoBstVPY?t=486) — **GSAP + Lenis 역할 분리**: GSAP = "스크롤 시 무엇이 일어나는지(트리거·내용)" 제어. Lenis = "스크롤 자체의 느낌(관성·보간)" 제어. 두 라이브러리는 경쟁이 아닌 상호 보완 — Lenis 없으면 뚝뚝 끊기지만 Lenis 적용 시 GSAP 트리거가 자연스럽게 연결됨.

- [🕐 09:10](https://youtu.be/bFmSoBstVPY?t=550) — **AI 생성 UX 감사 스킬로 C → B 등급**: "스킬 크리에이터"로 UX Audit 스킬 직접 제작. 9개 항목 체크리스트 + Python 스크립트로 색상 대비 심각 문제 2건 포함 다수 오류 발견 → 수정 후 재실행 → B등급, WCAG 준수 달성.

---

## 4. 비판적 분석

### 주장 1: "Penpot은 디자인-코드 양방향 브릿지다"
- **근거**: 데스크톱 앱 설치 시 MCP 자동 설정, `.pen` 파일을 통한 Claude Code 읽기·쓰기 접근
- **근거 유형**: 경험(팀 직접 테스트)
- **한계**: 영상 자체에서 "기대와 달랐다"고 인정. 수동 동기화 요청이 필요하며, 코드→디자인 역반영은 미구현. "양방향"은 마케팅 과장에 가깝다.
- **반론/대안**: Figma MCP(읽기 전용) 대비 실질적 개선이나, Builder.io·Locofy 등 기존 디자인-코드 변환 도구와의 비교 없음. `.pen` 파일을 코드에서 직접 수정하는 역방향도 미검증.

### 주장 2: "파일 감시 스크립트로 저장 시 자동 코드 동기화 실현"
- **근거**: `npm run sync` 실행 후 Cmd+S 저장 시 Claude CLI 자동 실행 데모
- **근거 유형**: 실증(실제 랜딩 페이지 프로젝트 적용)
- **한계**: 쿨다운 기간으로 연속 수정 시 반영 지연 발생. 저장마다 Claude CLI 호출 → API 비용 누적. 복잡한 디자인 변경 시 AI 해석 오류 가능성 미언급.
- **반론/대안**: "수동 트리거의 자동 배치 처리"에 가깝다. 대규모 변경에는 여전히 검토 오버헤드가 존재.

### 주장 3: "GSAP + Lenis는 충돌 없이 보완적으로 작동한다"
- **근거**: 역할 분리 설명(GSAP=내용, Lenis=느낌), 실제 웹사이트 적용 확인
- **근거 유형**: 경험(단일 프로젝트)
- **한계**: Lenis가 window scroll event를 오버라이드하므로 GSAP ScrollTrigger와의 통합에 `scroller proxy` 또는 Lenis RAF 연동 추가 설정이 필요한 경우 다수. Next.js SSR 환경의 hydration 이슈도 미언급.
- **반론/대안**: 통합의 복잡도를 단순화했다. Framer Motion의 `useScroll`+`useSpring`이 동일 기능을 커버하므로 Next.js 프로젝트에서는 GSAP 추가 불필요할 수 있음.

### 주장 4: "Claude는 XML 구조화 프롬프트에 최적화되어 있다"
- **근거**: Anthropic 공식 튜닝 언급
- **근거 유형**: 의견(Anthropic 권고 참조, 정량 비교 없음)
- **한계**: A/B 테스트 결과 없음. 단순 태스크에서는 XML vs 마크다운 차이가 미미할 수 있음. 모델 버전·태스크 복잡도에 따라 다를 수 있음.
- **반론/대안**: Anthropic 공식 문서에서 XML이 복잡한 구조화 태스크에 권장되는 것은 사실. 단, 모든 상황에 일괄 적용할 근거는 없음.

### 주장 5: "AI 생성 UX 감사 스킬로 C → B 등급 달성"
- **근거**: 스킬 실행 전후 등급 수치 변화
- **근거 유형**: 경험(단일 프로젝트 자기 평가)
- **한계**: AI가 만든 스킬로 AI가 만든 코드를 채점하는 순환 편향 가능성. 9개 항목의 WCAG·업계 표준 정합성 불명확. Python 스크립트 구체적 로직 미공개.
- **반론/대안**: Lighthouse, axe-core, WAVE 같은 독립 도구와의 교차 검증 권장.

---

## 5. 팩트체크 대상

- **주장**: "Figma MCP는 읽기 전용이다" | **검증 필요 이유**: Figma Dev Mode 업데이트로 부분 쓰기 API가 추가되었을 가능성. 2025-2026 기준 Figma MCP 공식 스펙 변경 여부 확인 필요. | **검증 방법**: Figma 공식 MCP 문서 + Context7 `@figma/plugin-api` 검색.

- **주장**: "Penpot .pen 파일은 JSON 기반이라 Git으로 버전 관리 가능하다" | **검증 필요 이유**: Penpot 내부 파일 포맷이 EDN(Clojure 데이터 포맷) 기반일 가능성이 있어, Git diff 가독성과 Claude 직접 파싱 가능 여부에 영향. | **검증 방법**: Penpot 공식 GitHub 저장소 파일 포맷 스펙 확인 (`penpot/penpot`).

- **주장**: "Claude 모델이 XML 구조화 프롬프트에 최적화되어 있다" | **검증 필요 이유**: 어느 Claude 버전부터 해당하는지, XML vs 마크다운 실질 성능 차이의 공식 근거 확인 필요. | **검증 방법**: Anthropic 공식 문서 "Prompt engineering" 섹션 조회 + Context7 `@anthropic-ai/sdk` 검색.

---

## 6. 실행 가능 항목

- [ ] **`~/.claude/settings.json` allowedTools 설정 즉시 점검** — 자동화 스크립트 실행 시 필요한 읽기·쓰기·MCP 도구 호출 권한 허용 여부 확인. 보안 범위 최소화 설정 (대상: Claude Code 운영 환경)

- [ ] **Penpot 데스크톱 앱 파일럿 설치** — `.pen` 파일 포맷 실제 확인(JSON vs EDN), MCP 자동 설정 동작 확인, Claude Code와 연동 테스트 (대상: Portfolio 디자인 워크플로우 개선 검토)

- [ ] **`.pen` 파일 감시 워처 스크립트 패턴 참고** — `chokidar` 기반 파일 감시 + claude CLI 자동 호출 패턴을 비즈니스 워크스페이스 자동화 도구(cron/스크립트)에 응용 (대상: 반복 동기화 작업 자동화)

- [ ] **GSAP 도입 재검토 및 표준 유지 확인** — `frontend-standards.md`의 GSAP 비도입 결정(Framer Motion으로 충분) 재확인. Framer Motion `useScroll`+`useSpring`으로 영상과 동일한 스크롤 시퀀스 구현 가능한지 검토 (대상: Portfolio 스크롤 애니메이션)

- [ ] **UX Audit 스킬 제작 검토** — 9개 항목 체크리스트 + WCAG 색상 대비 기준 + Python 스크립트 조합으로 `.claude/skills/ux-audit/SKILL.md` 작성. Trine Check 3.6(UI 품질 게이트)으로 통합 가능성 검토 (대상: Portfolio Trine 파이프라인)

- [ ] **XML 구조화 프롬프트 패턴 적용 검토** — 기존 스킬·에이전트 중 복잡한 의존성·순서가 있는 것(GSAP/Lenis 구현 요청 등)의 프롬프트를 XML 태그 구조로 리팩토링 실험 (대상: Claude Code 프롬프트 품질 향상)

- [ ] **멀티에이전트 페이지별 분할 패턴 문서화** — Trine Phase 3 병렬 실행 시 페이지 단위로 Subagent를 할당하는 패턴을 파일 소유권 규칙과 함께 명시적으로 정의 (대상: Portfolio 멀티페이지 구현)

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|-----------|----------|-----|---------|
| Penpot + Claude Code MCP 연동 (디자인→코드 파이프라인) | SIGIL S3에서 Stitch MCP로 UI 목업 생성. Figma 미사용 | Penpot의 `.pen` Git 관리 + MCP 쓰기 접근은 Stitch보다 진일보. 역할 중복 및 도입 비용 검토 필요 | 중 |
| `.pen` 파일 감시 자동화 스크립트 (`npm run sync`) | 없음. Claude Code 수동 프롬프팅 위주 | 반복 디자인 수정 자동화 수단 부재 | 중 |
| `~/.claude/settings.json` allowedTools 사전 설정 | 설정 여부 불명확 | 비대화형 자동화 스크립트 실행 필수 선결 조건 — 즉시 점검 필요 | 높음 |
| 멀티에이전트 페이지별 병렬 구현 | Trine에 Subagent Fan-out 패턴 존재 (파일 소유권 선언 규칙) | 페이지 단위 분할 패턴이 Trine 문서에 명시적으로 정의되지 않음. 응용 가능 | 낮음 |
| XML 구조화 프롬프팅 표준화 | 스킬·에이전트 프롬프트가 주로 마크다운 기반 | 복잡한 의존성·순서가 있는 스킬에서 XML 구조 미활용 | 낮음 |
| GSAP 스크롤 애니메이션 | `frontend-standards.md`: GSAP 미도입 결정 완료. Framer Motion `useScroll`+`useSpring` 사용 | 기존 표준과 충돌. 표준 유지 권장 — Framer Motion이 기능을 커버 | 낮음 (기존 결정 유지) |
| Lenis 스무스 스크롤 | `frontend-standards.md`: 표준 라이브러리로 지정됨 | 갭 없음 — 이미 적용 중 | 없음 |
| AI 생성 UX Audit 스킬 (9항목 + Python 스크립트) | Trine Check 3/3.5/3.7은 코드 품질 중심. ui-quality-gate 스킬 존재하나 색상 대비·접근성 자동 검증 미포함 | WCAG 기준 자동 검증 부재 — UX Audit 스킬로 Check 3.6 강화 가능 | 중 |
| Skill Creator로 커스텀 스킬 제작 | `.claude/skills/` 기반 스킬 시스템 구축 완료 | 제작 패턴 자체는 지원됨. UX Audit 스킬 내용 참조 가능 | 낮음 (참고용) |
| cron 기반 자동화 트리거 패턴 (파일 감시 → claude CLI) | 비즈니스 워크스페이스에 cron 자동화 존재 (weekly-research, daily-system-review) | 파일 변경 감지 트리거 패턴은 cron과 달리 event-driven — 응용 시 추가 설계 필요 | 낮음 |

---

## 8. 관련성

| 프로젝트 | 점수 | 이유 |
|---------|:----:|------|
| **Portfolio** | 5/5 | 핵심 기술 스택(Next.js) 직접 적용. Lenis 이미 표준 채택. 디자인→코드 파이프라인·멀티에이전트 구현·UX Audit 스킬 모두 Portfolio 개발 품질에 직결. XML 프롬프팅 패턴도 즉시 실험 가능. |
| **GodBlade** | 2/5 | Unity 개발에 직접 적용 불가. GodBlade 웹사이트·관리자 UI 개발 시 Penpot 목업 파이프라인 부분 참고 가능한 수준. |
| **비즈니스** | 3/5 | Claude Code 자동화 패턴(워처 스크립트, allowlist, 멀티에이전트), UX Audit 스킬 설계 방식이 비즈니스 워크스페이스 자동화 및 Trine 스킬 개발에 활용 가능. SIGIL S3에서 Penpot vs Stitch 비교 검토 의미 있음. |

---

## 핵심 인용

> "저희 팀이 시도한 모든 도구는 디자인 아니면 코드 중 하나만 합니다. 둘 다 되는 건 없었습니다."
> — [🕐 00:11](https://youtu.be/bFmSoBstVPY?t=11) — AI 개발 도구 생태계의 디자인-코드 분리 문제를 정확히 짚는 발언.

> "양방향 동기화가 어떻게 작동할지 생각했던 것과는 정확히 달랐습니다."
> — [🕐 02:23](https://youtu.be/bFmSoBstVPY?t=143) — 마케팅 주장과 실제 동작 차이를 솔직히 인정. 직접 테스트의 중요성.

> "GSAP은 스크롤할 때 무엇이 일어나는지를 제어합니다. 그리고 Lenis는 스크롤 자체의 느낌과 모습을 제어합니다."
> — [🕐 08:08](https://youtu.be/bFmSoBstVPY?t=488) — GSAP + Lenis 역할 분리의 명확한 정의. Portfolio 표준(Framer Motion + Lenis)의 역할 분리 원리와 동일한 구조.

> "클로드가 권한 프롬프트에서 무한정 차단됩니다. 그것 없이는 구현을 제대로 완료할 수 없습니다."
> — [🕐 04:39](https://youtu.be/bFmSoBstVPY?t=279) — 비대화형 Claude Code 자동화의 핵심 선결 조건.

---

## 추가 리서치 필요

- **Penpot MCP 공식 도구 목록 및 쓰기 권한 범위**: `Penpot MCP Claude Code integration documentation`, `Penpot desktop app MCP tools list`
- **Penpot 파일 포맷 실제 스펙**: `Penpot file format .penpot spec`, `penpot/penpot GitHub file format EDN JSON`
- **GSAP ScrollTrigger + Lenis 통합 설정**: `GSAP ScrollTrigger Lenis integration 2025`, `Lenis GSAP scroller proxy setup Next.js`
- **Claude Code settings.json allowedTools 자동화 설정**: `Claude Code settings.json allowedTools headless automation`, `Claude Code permissions bypass automation`
- **Framer Motion useScroll vs GSAP ScrollTrigger 기능 비교**: `Framer Motion useScroll GSAP ScrollTrigger comparison Next.js App Router 2025`

---

## 자막 신뢰도 등급: Medium

자동 생성 자막(`is_generated_subtitle: true`)으로 고유명사 오인식 다수 확인. 컨텍스트와 기술 도메인 지식으로 원래 의미를 복원해 분석했다.

| 자막 원문 | 실제 도구명 |
|----------|-----------|
| "펜슬 대부" / "펜셀 데블" / "펜셋 대부" | **Penpot** (오픈소스 디자인 도구) |
| "지세" / "지셉" / "지세비" / "지세피" / "GCLP" / "GCP" | **GSAP** (GreenSock Animation Platform) |
| "리너스" / "리노스" | **Lenis** (스무스 스크롤 라이브러리) |
| "팬파일" / "팬 파일" | **.pen 파일** (Penpot 디자인 파일 포맷) |
| "제순" | **JSON** |
| "세팅즈 재수엔" | **settings.json** |
| "러버" | **Lovable** |
| "볼트" | **Bolt** |
| "클로드 4.6" | **Claude Sonnet 4.6** (추정) |
| "AI랩스 프로" | **Labs Pro** (채널 커뮤니티 플랫폼) |
| "넥스트 제스" | **Next.js** |
| "코덱스" | **Codex** (OpenAI) |

타임스탬프 기반 원본 영상 직접 확인을 권장한다.
