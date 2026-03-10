# 클로드 코드로 멋진 다이어그램을 만들어보세요 (전체 워크플로우)

**채널**: Tech Bridge
**영상**: https://youtu.be/uBLcY01m-vI
**자막 신뢰도**: Medium (자동 생성 자막, 한국어 원본)
**분석일**: 2026-03-10

---

## 1. TL;DR

Claude Code 같은 코딩 에이전트가 기본적으로 시각적 다이어그램 생성에 취약하다는 문제를 해결하기 위해, Excalidraw JSON 파일 생성 + PNG 자기 검증 루프를 하나의 재사용 가능한 스킬로 패키징하는 워크플로우를 소개한다. 단순히 다이어그램을 생성하는 것을 넘어, AI가 "시각적으로 논증"할 수 있도록 설계 철학과 커스터마이즈 방법까지 공유한다.

---

## 2. 카테고리

**tech/ai** · **dev/tooling**

`#claude-code` `#excalidraw` `#ai-skills` `#diagram-automation` `#agentic-engineering` `#코딩에이전트` `#워크플로우`

---

## 3. 핵심 포인트

- [🕐 00:06](https://youtu.be/uBLcY01m-vI?t=6) 코딩 에이전트는 기본적으로 시각적 설명에 취약 — 적절한 프롬프팅과 능력 부여 없이는 실망스러운 결과
- [🕐 00:37](https://youtu.be/uBLcY01m-vI?t=37) 전체 Excalidraw 다이어그램 워크플로우를 스킬로 패키징하여 어떤 코딩 에이전트든 사용할 수 있게 공개
- [🕐 01:04](https://youtu.be/uBLcY01m-vI?t=64) 설치 방법: GitHub 리포 클론 → `.claude/skills/` 폴더에 복사하면 바로 사용 가능
- [🕐 01:32](https://youtu.be/uBLcY01m-vI?t=92) `SKILL.md`가 핵심 지시 세트 — Claude Code가 `.excalidraw` JSON 파일을 만들며 시각적으로 논증하는 방법을 안내
- [🕐 02:54](https://youtu.be/uBLcY01m-vI?t=174) 워크플로우의 핵심 차별점: 생성 후 PNG 렌더링 → 스크린샷으로 자기 검증 → 불완전한 부분 반복 수정
- [🕐 03:33](https://youtu.be/uBLcY01m-vI?t=213) Python 스크립트로 렌더링 — 스킬의 유일한 초기 설정 작업이며, 에이전트에게 스킬 설정을 직접 맡기는 것이 가장 쉬운 방법
- [🕐 05:50](https://youtu.be/uBLcY01m-vI?t=350) 핵심 철학: AI에게 "시각적으로 논증"하는 방법을 가르치는 것 — 박스 나열이 아닌 구조와 레이블만으로 개념을 전달
- [🕐 07:13](https://youtu.be/uBLcY01m-vI?t=433) 복잡한 다이어그램은 섹션별로 분할 생성 필수 — Claude Code 32,000 토큰 출력 한계 회피
- [🕐 08:20](https://youtu.be/uBLcY01m-vI?t=500) 스킬 내 디자인 패턴 라이브러리: 멀티존 아키텍처, 컬러 시스템, 증거 아티팩트 — 다양성과 교육성 확보
- [🕐 08:47](https://youtu.be/uBLcY01m-vI?t=527) 컬러 팔레트 커스터마이즈: 자연어로 색상 요청하면 hex 코드 생성 → 브랜드 일관성 유지 가능

---

## 4. 비판적 분석

**주장 1: 코딩 에이전트는 기본적으로 시각적 다이어그램 생성에 취약하다**
- **근거**: 스킬 없이 Excalidraw 다이어그램을 생성하면 "박스투성이"가 된다고 직접 시연
- **근거 유형**: 경험적 (본인의 반복 사용 경험)
- **한계**: LLM의 시각적 추론 능력은 모델마다 다르며 최신 모델에서는 개선되었을 수 있음. Mermaid 같은 텍스트 기반 다이어그램 포맷과의 비교 없이 Excalidraw JSON만을 기준으로 주장
- **반론/대안**: Mermaid, PlantUML 같은 텍스트 기반 다이어그램 포맷은 LLM이 상당히 잘 생성한다. 시각적 아름다움이 중요한 경우에만 Excalidraw 접근이 필요하며, 기술 문서나 내부 자료에는 Mermaid가 더 실용적일 수 있음

**주장 2: PNG 렌더링을 통한 자기 검증 루프가 품질을 크게 향상시킨다**
- **근거**: 메타 다이어그램 제작 시 2-3번 반복으로 완성도 향상을 실제 비교해서 보여줌
- **근거 유형**: 경험적 (실제 결과물 비교)
- **한계**: 몇 번의 반복이 필요한지, 어떤 기준으로 "충분히 좋음"을 판단하는지 정량화된 기준 없음. 자기 검증이 실제로 얼마나 오류를 줄이는지 측정값 미제공
- **반론/대안**: Claude Code의 Vision 능력을 활용한 이 접근은 유효하나, 검증 기준을 더 구체화(예: 체크리스트)하면 일관성이 높아질 것

**주장 3: 스킬로 패키징하면 재사용성과 일관성이 보장된다**
- **근거**: `.claude/skills/` 폴더에 복사만 하면 어떤 코딩 에이전트든 사용 가능
- **근거 유형**: 의견 (재사용성에 대한 주관적 평가)
- **한계**: Claude Code 외의 코딩 에이전트(Cursor, Cline 등)에서 동일하게 동작하는지 검증 없음. 스킬 파일 구조가 에이전트마다 다를 수 있음
- **반론/대안**: 스킬의 재사용성은 해당 에이전트가 SKILL.md 규약을 얼마나 잘 따르는지에 달려 있으며, 이는 에이전트별로 테스트가 필요함

**주장 4: 복잡한 다이어그램은 32,000 토큰 한계로 섹션 분할이 필수다**
- **근거**: Claude Code의 실제 출력 토큰 한계를 직접 언급
- **근거 유형**: 실증적 (Claude Code 스펙 기반)
- **한계**: 32,000 토큰은 특정 시점 기준이며 향후 모델 업데이트로 변경될 수 있음. 실제로 몇 개의 요소부터 분할이 필요한지 구체적 임계값 없음
- **반론/대안**: 섹션 분할 후 병합 시 요소 간 정렬·연결선 처리가 복잡해지는 문제가 있으며 이에 대한 해결책은 미언급

---

## 5. 팩트체크 대상

- **주장**: "Claude Code에서 32,000 토큰 이상을 출력하려다 에러가 발생한다" | **검증 필요 이유**: Claude Code의 출력 토큰 한계는 모델 버전 및 설정에 따라 다를 수 있으며, 공식 문서에서 정확한 수치를 확인해야 함 | **검증 방법**: Anthropic 공식 Claude Code 문서 또는 API 문서에서 max_output_tokens 값 확인

- **주장**: "스킬 없이 Excalidraw 다이어그램을 생성하면 항상 박스투성이가 된다" | **검증 필요 이유**: 이는 특정 시점의 Claude 모델 기준이며, 최신 Claude 모델(Sonnet 4.5, Opus 4.6)에서는 결과가 다를 수 있음 | **검증 방법**: 동일한 프롬프트로 스킬 유무를 비교하는 A/B 테스트 직접 실행

- **주장**: "이 스킬이 매주 몇 시간씩 절약해 준다" | **검증 필요 이유**: 개인의 주관적 시간 절약 체감으로 일반화하기 어려우며, 다이어그램 유형·복잡도·사용자 숙련도에 따라 크게 다를 수 있음 | **검증 방법**: 스킬 사용 전후 다이어그램 제작 시간을 측정하는 통제된 실험

---

## 6. 실행 가능 항목

- [ ] **[Claude Code 사용자 전체]** GitHub 리포 클론 후 `.claude/skills/excal-diagram/` 폴더 생성 — 즉시 적용 가능
- [ ] **[Business 워크스페이스]** 기존 S3 기획서 다이어그램 생성 워크플로우에 Excalidraw 스킬 통합 — SIGIL S3 단계에서 `.md` 내 Mermaid를 보완하는 용도
- [ ] **[S4 UI/UX 기획서 작성 시]** Stitch MCP와 Excalidraw 스킬의 역할 분리 명확화 — Stitch는 UI 목업, Excalidraw는 플로우/아키텍처 다이어그램
- [ ] **[콘텐츠 제작 시]** YouTube 대본 → 다이어그램 워크플로우 실험 — 콘텐츠 시각화 자동화
- [ ] **[스킬 시스템 개선]** 현재 `.claude/skills/` 내 다이어그램 관련 스킬이 있다면 Excalidraw 스킬과 통합 또는 역할 분리 검토
- [ ] **[Python 환경 확인]** Excalidraw PNG 렌더링용 Python 스크립트 의존성 확인 — WSL 환경에서 Playwright/headless 브라우저 설치 필요 여부 파악

---

## 7. 시스템 적용 맥락

| 영상 제안 | 현재 상태 | 갭 | 우선순위 |
|-----------|-----------|-----|----------|
| Excalidraw 스킬을 `.claude/skills/`에 설치 | 현재 Business 워크스페이스에 미설치 | GitHub 리포 클론 후 스킬 폴더 배포 필요 | High |
| SIGIL S3 기획서에 Excalidraw 다이어그램 포함 | 현재 Mermaid + NanoBanana 조합 사용 | Excalidraw가 플로우/구조 다이어그램에서 Mermaid보다 시각적으로 우수할 수 있음 | Medium |
| 스킬 SKILL.md에 시각적 논증 원칙 내재화 | SKILL.md 시스템은 이미 구축됨 | Excalidraw 스킬의 "시각적 논증" 철학을 기존 스킬 작성 가이드에 참조로 추가 | Low |
| PNG 자기 검증 루프 패턴 | Claude Code의 Vision 기능으로 이미 가능 | Excalidraw JSON → PNG → 검증 루프를 자동화하는 Python 스크립트 설정 필요 | High |
| 섹션 분할 생성 (복잡한 다이어그램) | Trine 파이프라인에서 대형 산출물 처리 경험 있음 | Excalidraw 전용 분할 기준(요소 수, 토큰 예측)을 스킬 내 가이드라인으로 문서화 | Medium |
| 컬러 팔레트 브랜드 커스터마이즈 | Business 워크스페이스에 브랜드 가이드 미정의 | 브랜드 컬러를 Excalidraw 스킬 설정 파일에 저장하여 일관성 유지 | Low |

시스템 매핑:
- **Claude Code + Skills**: 직접 적용 대상 — Excalidraw 스킬을 `.claude/skills/`에 추가
- **SIGIL S3**: `기획서 시각 자료 필수 포함 규칙`의 Mermaid 보완 도구로 활용
- **SIGIL S4**: `s4-uiux-spec.md` 와이어프레임 섹션에서 Stitch(UI)와 Excalidraw(플로우)를 용도별로 분리 사용
- **NanoBanana/Stitch**: Excalidraw는 이 두 도구와 경쟁하지 않음 — NanoBanana(AI 이미지), Stitch(UI 목업), Excalidraw(플로우/아키텍처)로 역할 분리

---

## 8. 관련성

| 프로젝트 | 점수 | 근거 |
|---------|:----:|------|
| **Portfolio** | 4/5 | S3/S4 기획서 및 기술 아키텍처 다이어그램 생성에 즉시 적용 가능. Next.js/NestJS 시스템 구조 시각화에 유용 |
| **GodBlade** | 3/5 | 게임 시스템 구조(Core Loop, 상태 전이, 밸런싱 구조) 다이어그램에 활용 가능하나 코딩 에이전트 기반 개발보다 Unity IDE 중심 |
| **비즈니스** | 4/5 | SIGIL 파이프라인 S3 기획서 시각화, YouTube 콘텐츠 제작, 내부 프로세스 다이어그램에 즉시 활용 가능. 매주 몇 시간 절약 가능성 높음 |

---

## 핵심 인용

> "코딩 에이전트에게 시각적으로 논증하는 방법을 가르치는 겁니다. 단순히 여러 개의 박스에 넣는 게 아니라는 걸 설명하는 거죠." — 약 [🕐 05:52](https://youtu.be/uBLcY01m-vI?t=352)

> "시각적으로 논증한다는 건 구조와 레이블만으로 전체 개념을 설명할 수 있게 하는 겁니다. 다이어그램에서 모든 설명 텍스트를 제거하더라도 다이어그램이 시각적으로 무엇을 논증하는지 여전히 이해할 수 있어야 합니다." — 약 [🕐 06:05](https://youtu.be/uBLcY01m-vI?t=365)

---

## 추가 리서치 필요

- Excalidraw JSON 스키마 공식 문서 — 스킬 커스터마이즈 시 참조
- Claude Code 출력 토큰 한계 최신 스펙 확인 (32K 토큰 주장 검증)
- Mermaid vs Excalidraw 실용 비교 — 어떤 다이어그램 유형에 각각 더 적합한가
- Obsidian Excalidraw 플러그인 + Claude Code 통합 워크플로우 상세
- Python 렌더링 스크립트의 실제 의존성 (GitHub 리포 직접 확인 필요)

---

## 추가 리서치 결과

> 조사일: 2026-03-10 | 조사 항목: 5개

### 1. Claude Code 출력 토큰 한계 최신 스펙 (32K 주장 검증)

- **결론**: 32,000 토큰 한계는 실제로 존재하며 현재 진행 중인 버그이다. 기본값은 32K이지만 `CLAUDE_CODE_MAX_OUTPUT_TOKENS` 환경변수로 최대 64K(공식 문서 기준)까지 설정 가능하다. 단, 환경변수가 서브에이전트 API 호출에는 적용되지 않는다는 별도 이슈(#25569)도 열려 있다. Opus 4.6의 실제 API 한계는 128K이나 Claude Code 레이어에서 32-64K로 제한되는 것으로 보인다. 공식 해결은 아직 없다.
- **출처**:
  - [Claude Code Issue #24055 — 32000 토큰 에러](https://github.com/anthropics/claude-code/issues/24055) (2026-03-10 접근)
  - [Claude Code Issue #25569 — 서브에이전트 하드코딩 32K 한계](https://github.com/anthropics/claude-code/issues/25569) (2026-03-10 접근)
  - [Claude Code 설정 문서](https://code.claude.com/docs/en/settings) (2026-03-10 접근)
- **신뢰도**: High (공식 GitHub 이슈 + 다수 사용자 재현)
- **비즈니스 적용**: 적용 가능 — 영상의 "섹션 분할 생성" 전략은 현재 유효하다. 복잡한 Excalidraw 다이어그램 생성 시 반드시 섹션별 분할 접근을 사용해야 하며, `CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000` 설정을 시도할 수 있으나 완전한 해결책은 아님. Trine 파이프라인에서 대형 다이어그램 생성 태스크 설계 시 이 한계를 고려해야 한다.

### 2. Python 렌더링 스크립트 실제 의존성 (coleam00/excalidraw-diagram-skill)

- **결론**: 핵심 의존성은 **Playwright** 하나이다. 설치는 `uv sync` → `uv run playwright install chromium` 순서로 진행하며, `uv`(Python 패키지 매니저)가 선행 설치되어야 한다. 코딩 에이전트에게 SKILL.md 지시에 따라 설정을 직접 맡기는 방법도 지원된다.
- **출처**: [coleam00/excalidraw-diagram-skill GitHub](https://github.com/coleam00/excalidraw-diagram-skill) (2026-03-10 접근)
- **신뢰도**: High (GitHub 리포 직접 확인)
- **비즈니스 적용**: 적용 가능 — WSL 환경에서 `uv`와 Playwright가 이미 설치되어 있거나 설치 가능하므로 스킬 적용에 기술적 장벽은 낮다. `uv run playwright install chromium`으로 headless Chromium을 설치하면 PNG 렌더링 자기 검증 루프가 작동한다.

### 3. Excalidraw JSON 스키마 공식 문서

- **결론**: 공식 문서(docs.excalidraw.com)가 존재하나 element 타입의 완전한 목록을 제공하지는 않는다. 확인된 지원 element 타입: `rectangle`, `ellipse`, `diamond`, `arrow`, `line`, `freedraw`, `text`, `image`, `frame`. 각 element는 `id`, `type`, `x`, `y`, `width`, `height`를 기본 필드로 가지며, `roundness`, `containerId` 등 타입별 추가 속성이 있다. Mermaid → Excalidraw 변환 라이브러리(`@excalidraw/mermaid-to-excalidraw`)도 공식 제공된다.
- **출처**:
  - [Excalidraw JSON Schema 공식 문서](https://docs.excalidraw.com/docs/codebase/json-schema) (2026-03-10 접근)
  - [Excalidraw Element Format — DeepWiki](https://deepwiki.com/excalidraw/excalidraw-mcp/7.2-excalidraw-element-format) (2026-03-10 접근)
- **신뢰도**: High (공식 개발자 문서)
- **비즈니스 적용**: 적용 가능 — 스킬 SKILL.md 커스터마이즈 시 이 문서를 참조하면 된다. 특히 `@excalidraw/mermaid-to-excalidraw` 라이브러리는 기존 SIGIL S3 기획서의 Mermaid 다이어그램을 Excalidraw로 변환하는 자동화 파이프라인 구축에 활용할 수 있다.

### 4. Mermaid vs Excalidraw 실용 비교

- **결론**: 두 도구는 경쟁이 아닌 보완 관계이다. **Mermaid가 적합한 경우**: Git 기반 코드 문서, Markdown 파일 인라인 다이어그램, GitHub 자동 렌더링이 필요한 기술 문서. **Excalidraw가 적합한 경우**: 브레인스토밍, 아키텍처 시각화, 발표 자료, 손그림 스타일 선호 시. 공식 Mermaid → Excalidraw 변환 플레이그라운드(mermaid-to-excalidraw.vercel.app)도 존재하여 두 도구 간 전환이 가능하다.
- **출처**:
  - [Mermaid.js vs Excalidraw: Why Text-Based Diagrams Win — Medium](https://medium.com/activated-thinker/how-one-comment-changed-the-way-i-create-flowcharts-eba4e69eafa9) (2026-03-10 접근)
  - [Mermaid to Excalidraw 변환 플레이그라운드](https://mermaid-to-excalidraw.vercel.app/) (2026-03-10 접근)
- **신뢰도**: High (다중 소스 일치)
- **비즈니스 적용**: 적용 가능 — SIGIL 규칙의 기존 정책("Mermaid 다이어그램 필수")을 변경할 필요가 없다. Mermaid(기술 문서/GitHub 렌더링)와 Excalidraw(기획서 시각화/발표 자료)를 용도별로 분리 사용하는 것이 최적이다. 특히 S3 기획서의 `.pptx` 슬라이드에는 Excalidraw, `.md` 기획서 인라인에는 Mermaid라는 분리 원칙을 적용할 수 있다.

### 5. Obsidian Excalidraw + Claude Code 통합 워크플로우

- **결론**: `axtonliu/axton-obsidian-visual-skills` 리포가 Obsidian + Claude Code + Excalidraw 통합을 지원한다. 8가지 다이어그램 유형(플로우차트, 마인드맵, 계층도, 관계도, 비교도, 타임라인, 매트릭스, 자유형)을 텍스트 설명으로 생성 가능하다. 설치는 `~/.claude/skills/` 복사 방식으로 동일하다. Mermaid와 Canvas 다이어그램도 동일 스킬팩에서 지원한다.
- **출처**: [axtonliu/axton-obsidian-visual-skills GitHub](https://github.com/axtonliu/axton-obsidian-visual-skills) (2026-03-10 접근)
- **신뢰도**: Medium (단일 소스, 커뮤니티 리포)
- **비즈니스 적용**: 참고만 — Business 워크스페이스는 현재 Obsidian을 사용하지 않으므로 직접 적용은 해당 없음. 단, 동일한 `~/.claude/skills/` 설치 방식을 사용하므로 Claude Code 직접 활용 가능성은 있다.

### 미조사 항목

없음 — 5개 항목 모두 조사 완료.

---

## 자막 신뢰도

**등급: Medium** — `is_generated_subtitle: true`, 한국어 자동 생성 자막이며 기술 용어에서 오류가 다수 발생했다. 내용의 전반적 파악은 가능하나 세부 기술 사양은 GitHub 리포 직접 확인을 권장한다.

주요 자막 오류:
- "재순 파일" = JSON 파일 (`.excalidraw`)
- "기토부 리포지토리" = GitHub 리포지토리
- "다클로드" = `~/.claude/`
- "핵스코드" = hex 코드
- "박수투성이" = 박스투성이 (box-heavy diagram)
- "리듬이" = README
- "멀티줌 아키텍처" = multi-zone 또는 multi-section 구조
