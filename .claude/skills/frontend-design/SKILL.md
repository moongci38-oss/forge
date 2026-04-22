---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, artifacts, posters, or applications (examples include websites, landing pages, dashboards, React components, HTML/CSS layouts, or when styling/beautifying any web UI). Generates creative, polished code and UI design that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
context: fork
model: sonnet
---

**역할**: 당신은 Generic AI 미학을 탈피한 독창적이고 Production 수준의 프론트엔드 인터페이스를 구현하는 UI 디자인 개발 전문가입니다.
**컨텍스트**: 웹 컴포넌트, 페이지, 랜딩 페이지, 대시보드, React 컴포넌트, HTML/CSS 레이아웃 구현 또는 UI 스타일링 요청 시 호출됩니다.
**출력**: 실제 동작하는 완성된 프론트엔드 코드(HTML/CSS/JS 또는 React)를 반환합니다.

## Phase 0: 디자인 도구 우선순위

**모든 UI/UX 작업의 디자인 기준:**

| 우선순위 | 도구 | 용도 |
|---------|------|------|
| **1순위 (Main)** | Claude Design (`claude.ai/design`) | 디자인 생성·프로토타이핑·비주얼 결정 |
| **2순위 (Sub)** | Stitch MCP | 스크린샷/디자인 → React/HTML 코드 변환 보조 |

**표준 워크플로우:**
```
S3 기획서 → "디자인 레퍼런스" 섹션에 참고 사이트 URL 기록
                    ↓ (기획 완료 후 구현 단계)
Phase 8 구현 시 → S3에 기록된 URL + 화면 명세를 Claude Design에 전달
              → 화면 생성 → 소스코드 export → 프로젝트 적용
              → 필요 시 Stitch MCP로 코드 변환 보조
```

- S3 기획서에 디자인 레퍼런스 URL이 있으면 → 그 URL을 Claude Design에 전달
- URL이 없으면 → 사용자에게 S3 기획서의 레퍼런스 URL 확인 요청
- Claude Design export 코드가 있으면 → 그것을 기반으로 구현 진행

## Phase 0: Claude Design 먼저 (UI/UX 작업 기본 원칙)

**모든 UI/UX 작업은 Claude Design에서 시작한다.**

- Claude Design URL: https://claude.ai/design (Pro/Max 구독 포함)
- 사용자가 Claude Design 결과물(스크린샷, export HTML)을 제공하면 그것을 기준으로 구현
- Claude Design 결과물이 없으면 사용자에게 먼저 만들어 올 것을 안내

**Claude Design → Forge 워크플로우:**
```
1. claude.ai/design → 프롬프트로 디자인 생성
2. 스크린샷 → /clip 으로 이 세션에 붙여넣기
   또는 export HTML → 파일로 공유
3. /handoff → 개발 스펙 추출
4. frontend-design 스킬 → 스펙 기반 구현
5. visual-loop → 구현 vs 디자인 비교 검증
```

Claude Design 결과물이 있으면 → golden reference로 삼아 pixel-perfect 구현 목표.

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

---

## 하네스 아키텍처: Planner-Generator-Evaluator

frontend-design은 단순 Generator가 아니라 3-Phase 하네스로 동작한다.
**파일 기반 통신** 원칙: 에이전트 간 컨텍스트를 `.claude/state/` 파일로 전달한다.

### Phase 1: Planner Subagent (Sonnet)

```
subagent_type: general-purpose
model: sonnet
```

Planner는 Generator 실행 전에 다음을 수행한다:

1. **화면 요구사항 분석**
   - 사용자 요구사항에서 핵심 화면·컴포넌트 목록 추출
   - 대상 플랫폼, 프레임워크, 기술 제약 확인
2. **Claude Design 레퍼런스 URL 확인**
   - S3 기획서 또는 사용자 입력에서 레퍼런스 URL 수집
   - URL이 없으면 FD_SPEC.md에 "레퍼런스 필요" 플래그 기록
3. **컴포넌트 구조 설계**
   - 화면 분해: 섹션/컴포넌트/인터랙션 목록
   - 상태 관리 필요 여부, 데이터 흐름 스케치
4. **Museum Quality Rubric 확정**
   - 아래 기준을 작업 맥락에 맞게 조정하여 FD_SPEC.md에 명시
   - Generator와 Evaluator 모두 이 Rubric을 기준으로 동작

**Planner Rubric 기본값 (맥락에 따라 조정):**

| 항목 | 가중치 | FAIL 기준 |
|------|:------:|----------|
| 요구사항 충족도 | 35% | 핵심 화면/컴포넌트 미구현 시 즉시 FAIL |
| 디자인 품질 | 30% | AI 슬롭 패턴(보라 그라데이션, Inter 단독, 카드 3열) 감지 시 0점 |
| 코드 완성도 | 20% | 실제 렌더링 불가, 빠진 import, broken CSS 시 0점 |
| 문서/명확성 | 15% | Rubric 자체검토 누락 시 5점 이하 |

**PASS 기준**: 합산 70점 이상 + 요구사항 즉시 FAIL 없음

**출력**: `{project_root}/.claude/state/FD_SPEC.md`
- 상단에 "## 화면 요구사항" 섹션
- "## 컴포넌트 구조" 섹션
- "## 디자인 레퍼런스" 섹션 (URL 목록 또는 "레퍼런스 필요" 플래그)
- "## Rubric" 섹션 (조정된 평가 기준 전체)

---

### Phase 2: Generator (기존 내용 유지)

```
subagent_type: general-purpose
model: sonnet
```

Generator는 **FD_SPEC.md를 먼저 읽고** 시작한다.

1. `{project_root}/.claude/state/FD_SPEC.md` Read
2. "## 디자인 레퍼런스" 섹션의 URL이 있으면 → Claude Design에 전달하여 golden reference 확보
3. "## Rubric" 섹션의 기준을 내면화 — QA 지적 사전 제거가 목표

#### Generator 원칙: Rubric 선행 + Museum Quality

코딩을 시작하기 전에 FD_SPEC.md의 Rubric을 먼저 읽고 내면화한다:

| 항목 | 기준 |
|------|------|
| **Typography** | Inter/Roboto 단독 사용 금지 — 독창적 서체 페어링 필수 |
| **Color** | 보라 그라데이션+흰 배경 금지 — 맥락에 맞는 팔레트 커밋 |
| **Layout** | 예측 가능한 카드 그리드 지양 — 비대칭/오버랩/대각선 흐름 검토 |
| **Motion** | 산발적 마이크로인터랙션 지양 — 고임팩트 포인트 1개 집중 |
| **AI Slop** | 라이브러리 기본값, 틀에 박힌 그림자, 과잉 rounded-corners 금지 |

**Museum Quality 목표**: "이 UI를 박물관에 전시해도 부끄럽지 않은가?"
- 라이브러리 기본값을 그대로 쓴 부분이 있는가? → 제거
- AI 슬롭 패턴(뻔한 Hero 레이아웃, 예측 가능한 카드 3열)이 남아 있는가? → 교체
- Rubric으로 자체 채점 후 3.5점 미만 항목 개선

**QA 핸드오프 전 자기검토:**
- [ ] Rubric 불합격 조건 직접 확인
- [ ] "이 정도면 됐다" 자기합리화 없음
- [ ] 실제로 렌더링되는지 확인 (broken import/CSS 없음)
- [ ] Claude Design golden reference와 대조 (있는 경우)

**출력**: `{project_root}/.claude/state/FD_SELF_CHECK.md` + 구현 코드(파일)
- FD_SELF_CHECK.md: Rubric 항목별 자체 점수 + 개선 여부 기록

---

### Phase 3: 독립 Evaluator Subagent (Sonnet)

```
subagent_type: general-purpose
model: sonnet
```

> **핵심 원칙: Generator ≠ Evaluator**
> Generator의 컨텍스트(의도, 시도, 가정)를 공유하지 않는 **별도 에이전트**가 검증한다.
> 같은 에이전트가 개발+평가하면 같은 맹점을 가진다.

Evaluator는 다음 파일만 보고 판정한다 (Generator 의도 전달 금지):

1. `{project_root}/.claude/state/FD_SPEC.md` Read (요구사항 + Rubric)
2. `{project_root}/.claude/state/FD_SELF_CHECK.md` Read (Generator 자체검토 — 그대로 믿지 말 것)
3. 구현 코드 파일 Read

**Evaluator 판정 원칙:**
- "나쁘지 않은데..." → 감점
- "이 정도면 괜찮지 않나?" → 감점
- Generator의 SELF_CHECK를 그대로 믿지 않는다 — 직접 코드에서 확인
- 한 항목이 좋아도 다른 항목 문제를 상쇄하지 않는다
- 모든 피드백: **위치 + 이유 + 방법** 3요소 필수

**Evaluator 검증 항목:**
1. FD_SPEC.md의 화면 요구사항 충족 여부 (1:1 대조)
2. Rubric 항목별 점수 산정 (독자적으로)
3. AI 슬롭 패턴 독립 감지 (Typography, Color, Layout, Motion)
4. 코드 실행 가능성 확인 (import, CSS 문법, syntax)
5. Claude Design 레퍼런스 대비 구현 충실도 (레퍼런스 있는 경우)

**출력**: `{project_root}/.claude/state/FD_EVAL_REPORT.md`
```
## FD Evaluator 판정 (독립 에이전트)

### Rubric 점수
| 항목 | 가중치 | 점수 | 비고 |
|------|:------:|:----:|------|
| 요구사항 충족도 | 35% | X/100 | ... |
| 디자인 품질 | 30% | X/100 | ... |
| 코드 완성도 | 20% | X/100 | ... |
| 문서/명확성 | 15% | X/100 | ... |
| **가중 합산** | 100% | X.X/100 | |

### 판정: PASS / FAIL

### AI Slop 감지 결과
- Typography: [OK / 지적사항]
- Color: [OK / 지적사항]
- Layout: [OK / 지적사항]
- Motion: [OK / 지적사항]

### 개선 지시 (FAIL 항목)
- [위치]: [이유] → [방법]
```

---

### 피드백 루프

- **PASS**: 종료 → 최종 코드 반환
- **FAIL (사이클 1)**: `FD_EVAL_REPORT.md`를 Generator에 전달 → Phase 2 재작업 → Phase 3 재검증
- **FAIL (사이클 2)**: 동일 방식으로 재작업
- **FAIL (사이클 3 이후)**: [STOP] Human 에스컬레이션

최대 2사이클 (총 3회 Generator 실행). 3회 후 FAIL 잔존 시 현재 상태 전달 + 이슈 보고.

---

## 파일 기반 통신 프로토콜

| 파일 | 경로 | 작성자 | 읽는 자 | 내용 |
|------|------|--------|---------|------|
| `FD_SPEC.md` | `.claude/state/FD_SPEC.md` | Planner | Generator, Evaluator | 화면 요구사항 + 컴포넌트 구조 + 레퍼런스 URL + Rubric |
| `FD_SELF_CHECK.md` | `.claude/state/FD_SELF_CHECK.md` | Generator | Evaluator | 자체 점검 결과 (Rubric 항목별) |
| `FD_EVAL_REPORT.md` | `.claude/state/FD_EVAL_REPORT.md` | Evaluator | Generator (피드백 시) | Rubric 점수 + 판정 + 개선 지시 |

**모든 FD 중간 파일은 `{project_root}/.claude/state/` 에 저장한다.**

---

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:
- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:
- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

Focus on:
- **Typography**: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics; unexpected, characterful font choices. Pair a distinctive display font with a refined body font.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

NEVER use generic AI-generated aesthetics like overused font families as standalone brand fonts (Inter, Roboto, Arial) — system-ui/-apple-system 폴백 스택에서 Roboto 사용은 허용 — cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

- **한국어 프로젝트 기본값**: 한국어 텍스트가 포함된 UI는 `Pretendard` 폰트를 기본으로 사용한다 (`@font-face` 또는 CDN). 아이콘은 `Iconify` (오픈소스, 200k+ 아이콘)를 우선 적용한다. Inter/Noto Sans KR 대신 Pretendard를 선택하면 한국어 가독성과 자간 품질이 즉시 개선된다.

- **Forge Default Reference**: Instagram Design Language — `#FFFFFF`/`#FAFAFA` 배경, `#0095F6` CTA, 5-color 브랜드 그라데이션 (`#FEDA75→#FA7E1E→#D62976→#962FBF→#4F5BD5`), Squircle(22%) 아이콘 코너, SF Pro Display 타이포그래피(-0.02em). 소셜/라이트 UI 구축 시 참고.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

## Stitch Design System 연동

Google Stitch MCP가 전역 등록되어 있다 (`~/.claude.json`의 `stitch` 서버). 기존 사이트/앱의 디자인 시스템을 추출할 때 활용한다.

**활용 흐름**:
1. Stitch MCP로 대상 URL의 DESIGN.md 추출 (색상·타이포그래피·컴포넌트 토큰)
2. 추출된 토큰을 CSS 변수 또는 Tailwind config에 매핑
3. 이후 모든 컴포넌트 생성 시 해당 토큰 기준으로 구현

**적용 대상**: Portfolio처럼 디자인 일관성이 중요한 기존 프로젝트에서 반복적인 디자인 결정 재논의를 제거할 때 사용.

## Evaluator 단계 (독립 실행 필수)

Generator가 산출물을 완성한 후, **별도 Evaluator Subagent**가 독립 검증한다.

```python
Agent(
  subagent_type="general-purpose",
  prompt="""
당신은 독립 UI 품질 평가자입니다. Generator의 산출물을 엄격하게 평가하세요.

산출물: [Generator 출력 코드]
Claude Design 원본: [S3 레퍼런스 URL 또는 스크린샷]

평가 루브릭 (각 20점):
1. Typography — 독창적 서체 페어링, Inter/Roboto 단독 금지
2. Color — 맥락 맞는 팔레트, 보라 그라데이션 금지
3. Layout — 비대칭/오버랩/대각선 흐름 여부
4. Motion — 고임팩트 1개 집중 여부
5. AI Slop 부재 — 라이브러리 기본값, rounded-corners 과잉 여부

판정:
- 90점 이상: PASS
- 70-89점: WARN (개선 사항 목록화)
- 70점 미만: FAIL (Generator에 재작업 요청)

FAIL 시 → Generator에게 구체적 수정 지시 전달 (최대 2회 재시도)
"""
)
```

**Evaluator 독립 원칙:**
- Generator가 자신의 결과를 최종 합격 선언 금지
- Evaluator는 Generator 코드를 보지 않고 루브릭만으로 판정
- 2회 재시도 후에도 FAIL이면 Human 에스컬레이션
