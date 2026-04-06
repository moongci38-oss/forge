# 문서 시각화 자동 선택 규칙 (전역)

> 모든 프로젝트(Business, Portfolio, GodBlade)의 문서 작업 시 적용.
> 다이어그램/시각 자료 작성 시 유형에 따라 아래 도구를 **자동 선택**한다.

## 도구 선택 기준 (자동 라우팅)

```
다이어그램 유형 판별
  │
  ├─ 게임 로직 (FSM, 확률, 시퀀스, 전투, 경제, 스킬 트리)
  │       → /game-logic-visualize
  │
  ├─ 인터랙티브 탐색 (UI 레이아웃, 디자인 토큰, 색상 시스템)
  │       → playground 스킬
  │
  ├─ 복잡한 아키텍처 / C4 Model (노드 15개 초과)
  │       → Draw.io MCP
  │
  ├─ 일반 플로우/시퀀스/상태도 (노드 15개 이하)
  │       → Mermaid (마크다운 인라인)
  │
  ├─ 게임·앱·웹 스크린샷 분석
  │       → /screenshot-analyze
  │
  └─ 게임 레퍼런스 통합 수집
          → /game-reference-collect
```

## 유형별 상세 기준

| 시각 자료 유형 | 도구 | 선택 조건 |
|-------------|------|---------|
| FSM, 상태 전이 다이어그램 | `/game-logic-visualize` | 게임 로직, 상태 기계 |
| 확률/경제 시뮬레이터 | `/game-logic-visualize` | 수치 시뮬레이션 포함 시 |
| DOTween Sequence 흐름 | `/game-logic-visualize` | 애니메이션 타임라인 |
| UI 레이아웃 탐색 (인터랙티브) | `playground` | 클릭/조작 가능한 탐색 필요 시 |
| 디자인 토큰 비교 | `playground` | 색상, 간격, 폰트 비교 |
| C4 아키텍처 다이어그램 | Draw.io MCP | 레벨 1-4, 컴포넌트 15+ |
| 시스템 구조 (복잡) | Draw.io MCP | 레이어/그룹 필요 시 |
| 워크플로우 (단순) | Mermaid | 5-15 노드 플로우 |
| 시퀀스 다이어그램 | Mermaid | API 호출 흐름, 이벤트 순서 |
| ER 다이어그램 | Mermaid | DB 스키마 |
| 스크린샷 → UI 분석 | `/screenshot-analyze` | 경쟁작 분석, 구현 검증 |
| 레퍼런스 수집 | `/game-reference-collect` | S3/S4 게임 리서치 |

## 적용 대상 문서 (모든 문서 작업)

**파일 형식 무관하게 모든 문서 작업에 적용한다.**

| 문서 유형 | 형식 | 적용 |
|----------|------|:----:|
| 기획서 (PRD / GDD) | `.md` + `.pptx` | **필수** |
| UI/UX 기획서 | `.md` + `.pptx` | **필수** |
| Spec 문서 | `.md` | **필수** |
| 상세 기획서 / 개발 계획서 | `.md` + `.pptx` | **필수** |
| 가이드 / 튜토리얼 | `.md` | **필수** |
| 리뷰 / 분석 리포트 | `.md` | **필수** |
| Forge Dev Walkthrough | `.md` | **필수** |
| 기타 모든 문서 | `.md` / `.pptx` | **필수** |

> **예외 없음**: 문서 종류와 파일 형식에 무관하게 다이어그램이 필요한 모든 문서에 적용한다.

## Library-First 원칙

시각화 에셋 생성 전 **반드시** Prefab Visual Library를 먼저 탐색한다.

1. `/library-search` 스킬로 기존 에셋 검색 (5,747개, `/home/damools/prefab-visual-library/`)
2. 완전매칭 → 재활용 / 부분매칭 → 조합 / 없음 → 신규 생성

## 스킬 오케스트레이터

MCP 도구를 직접 호출하지 않고, 스킬 파이프라인을 통해 생성한다:

```
/library-search → /game-asset-generate (오케스트레이터) → /asset-critic (검증)
                    ├─ /soul-prompt-craft (12요소 프롬프트)
                    └─ MCP 자동 라우팅:
                        ├─ 인포그래픽/개념도 → NanoBanana MCP (Gemini, 2K+)
                        ├─ UI 목업/화면 → Stitch MCP
                        ├─ 복잡 아키텍처 (노드 15+) → Draw.io MCP
                        └─ 단순 플로우 (노드 15 이하) → Mermaid
```

## 추가 도구 라우팅

| 시각 자료 유형 | 도구 | 선택 조건 |
|-------------|------|---------|
| 인포그래픽 / 개념도 이미지 | NanoBanana MCP (via `/game-asset-generate`) | 시각적 임팩트 필요, 고해상도 |
| UI 목업 / 화면 시각화 | Stitch MCP (via `/game-asset-generate`) | 플랫폼/앱 화면 표현 |

> **공식 문서 작성 시**: `docs-writing-pipeline.md` 전역 규칙도 함께 참조.

## 렌더링 레벨 연동

시각화 생성 전 프로젝트 style-guide의 `Rendering Level` 필드를 확인하고, 해당 레벨의 스타일을 적용한다.
**레벨 정의**: `shared/design-tokens/rendering-levels.md`

| 도구 | 레벨 적용 방식 |
|------|-------------|
| Draw.io | L1~L3 도형 스타일 차등 (fill/shadow/border) |
| Mermaid | L1~L2 테마 적용, L3+ → NanoBanana 이미지 대체 |
| NanoBanana | 레벨별 프롬프트 키워드 사전 자동 주입 |
| HTML 시각화 | 레벨별 CSS 스타일 차등 (glassmorphism/neon/3D) |
| playground | UI 탐색은 L3 하이파이 기본 |

## AI 행동 규칙

1. 문서에 다이어그램이 필요한 경우 **ASCII 대신** 위 도구를 사용한다
2. 유형을 판별해 **자동으로 도구를 선택**한다 — 사용자에게 도구를 묻지 않는다
3. 같은 문서에 여러 유형이 있으면 **유형별로 다른 도구를** 조합 사용한다
4. Mermaid가 적합하면 별도 도구 없이 마크다운 인라인으로 작성한다
5. 도구 호출 전 "X 다이어그램 → Y 도구로 생성합니다" 한 줄 선언 후 실행한다
6. **시각화 생성 전 렌더링 레벨을 확인**하고 해당 레벨 스타일을 적용한다

## 예시

```
# 문서 작성 중 도구 선택 예시

가챠 확률 테이블 시각화
  → "확률 시뮬레이터 → /game-logic-visualize 로 생성합니다"

Unity 에디터 레이아웃 설명
  → "UI 레이아웃 → playground 스킬로 인터랙티브 HTML 생성합니다"

API 호출 흐름 (5단계)
  → Mermaid sequenceDiagram 인라인 작성

마이크로서비스 아키텍처 (20개 서비스)
  → "복잡한 아키텍처 → Draw.io MCP로 생성합니다"
```

---

*Last Updated: 2026-03-27*
