---
name: screenshot-analyze
description: 게임/웹/앱 스크린샷(UI, HUD, 이펙트 프레임, 경쟁작, 구현 검증)을 Gemini Vision으로 분석하여 UI 구조/컬러 팔레트/구현 가이드를 생성하는 스킬. 정적 이미지 분석 전문.
user-invocable: true
context: fork
model: sonnet
---

**역할**: 당신은 게임/웹/앱 스크린샷을 Gemini Vision으로 분석하여 UI 구조와 구현 가이드를 생성하는 시각 분석 전문가입니다.
**컨텍스트**: 정적 이미지(게임 UI, HUD, 이펙트 프레임, 경쟁작, 구현 검증) 분석이 필요할 때 호출됩니다.
**출력**: UI 구조·컬러 팔레트·구현 가이드를 5개 필수 요소로 구성된 마크다운 분석 보고서로 반환합니다.

# Screenshot Analyze

스크린샷(게임/웹/앱)을 분석하여 UI 구조, 컬러 팔레트, 구현 가이드를 생성한다.

## 역할 분리

| 도구 | 입력 | 분석 대상 | 출력 |
|------|------|---------|------|
| `/video-reference-guide` | 동영상 (mp4/mov/YouTube) | 타이밍, 연출 시퀀스, 모션 | 타임스탬프별 연출 테이블 |
| **이 스킬** | 정적 이미지 (png/jpg/클립보드) | 레이아웃, 컬러, 컴포넌트 구조, 아이콘 | UI/레이아웃 분석 테이블 |
| `/yt` | YouTube (음성) | 강좌, 튜토리얼 내용 | 트랜스크립트 요약 |

## 지원 분석 유형

| 유형 | 분석 포커스 | 출력 형태 |
|------|-----------|----------|
| **UI 레이아웃** | 화면 구성, 계층, 여백, 정렬 | Canvas 구조 테이블 + Anchor 가이드 |
| **HUD 디자인** | 게임 중 표시 요소, 위치, 크기 | Safe Area 분석 + 정보 밀도 평가 |
| **아이콘/에셋** | 아이콘 스타일, 크기, 컬러 팔레트 | 아트 디렉션 + Sprite 규격 |
| **이펙트 프레임** | 정지 상태 이펙트 분석 | 파티클 방향, 블렌딩 모드, 레이어 |
| **경쟁작 비교** | A사 vs B사 동일 화면 비교 | 레이아웃 차이, UX 패턴 비교표 |
| **구현 검증** | 구현 스크린샷 vs 레퍼런스 비교 | 일치도 점수 + 개선 항목 |
| **스타일 추출** | 5-10개 에셋에서 공통 스타일 추출 | style-guide.md 자동 생성 |
| **일관성 검증** | 다수 에셋의 크로스 에셋 일관성 | 일관성 점수 + 불일치 에셋 식별 |

## 입력

사용자가 아래 중 하나를 제공한다:

1. **로컬 이미지 파일 또는 URL**: png, jpg, jpeg, webp, gif, bmp 경로 또는 http/https URL
2. **클립보드 이미지**: `/clip` 스킬로 캡처 후 전달
3. **분석 유형** (선택): UI 레이아웃 / HUD / 아이콘 / 이펙트 / 경쟁작 비교 / 구현 검증
4. **레퍼런스 이미지** (구현 검증 시 필수): 비교 대상 레퍼런스 이미지 경로/URL

## 워크플로우

### Step 1: 모드 판별 + 플랫폼 감지 + 입력 확인

출력 첫 줄에 모드와 플랫폼을 선언한다:

```
**분석 모드**: [기본 모드 / Task Doc 모드 / 시안 분석 모드 / 구현 검증 모드 / 컴포넌트 추출 모드]
**플랫폼**: [Game (Unity) / Web (HTML/CSS) / App (Mobile Native)]
```

모드 판별:
```
├─ `--extract` 플래그 또는 "분리해줘 / 추출해줘 / 컴포넌트 뽑아줘" 언급 → 컴포넌트 추출 모드
├─ `--mockup` 옵션 또는 _assets/ 경로의 우리 시안 → 시안 분석 모드 (확정값)
├─ Element Task Doc 작성 중 → Task Doc 모드 (추정값)
├─ 구현 검증 (레퍼런스 vs 구현 비교) → 구현 검증 모드
└─ 그 외 (경쟁작, 일반 참고) → 기본 모드 (추정값)
```

플랫폼 자동 감지:
```
├─ GodBlade 프로젝트 컨텍스트 또는 사용자 명시 → Game (Unity)
├─ Portfolio 프로젝트 컨텍스트 또는 웹사이트 URL → Web (HTML/CSS)
├─ 앱스토어 스크린샷 또는 모바일 UI → App (Mobile Native)
└─ 판단 불가 → 이미지 내용으로 추정 (브라우저 크롬 → Web, 게임 HUD → Game)
```

입력 추출:
```
- IMAGE_PATH: 이미지 경로 (여러 장이면 공백 구분)
- ANALYSIS_TYPE: 분석 유형 (기본: "UI 레이아웃")
- REF_NAME: 레퍼런스 이름 (파일명 또는 사용자 지정)
- PLATFORM: 플랫폼 (자동 감지 또는 사용자 지정)
- EXTRACT_MODE: 컴포넌트 추출 모드 여부 (true/false)
```

### Step 2: Gemini 프롬프트 조립

> **핵심 원칙**: MUST 출력 형식을 Gemini 프롬프트에 직접 포함한다.
> 스킬 문서의 출력 규격과 Gemini에 보내는 프롬프트가 일치해야 한다.

> **모델**: `--extract` 모드 → `GEMINI_MODEL=gemini-3.1-pro-preview` 고정 (정밀도 최우선)
> 기본 분석 → `gemini-2.5-flash` (기존 유지)

모든 분석 유형에 공통으로 포함되는 **분해 규칙 블록**:

```
## 분해 규칙 (필수 — 모든 분석에 적용)
1. 모든 시각 요소를 "고유 컴포넌트" 단위로 분해한다
2. 같은 디자인의 요소가 N개 반복되면 → 고유 컴포넌트 1개 + "반복: N개" 표기
3. 서로 다른 디자인의 요소가 N개면 → 각각 별도 고유 컴포넌트로 분해
4. 배경, 버튼, 텍스트, 아이콘, 구분선, 컨테이너, 이미지를 모두 분해
5. 요소가 서로 겹쳐(overlap) 있어도 각각 독립 컴포넌트로 분해 — Z-order(레이어 순서) 표기
6. 반투명 오버레이, 그림자, 글로우 등 시각 효과도 별도 컴포넌트로 분해
7. 모든 색상은 #RRGGBB Hex로 표기 (자연어 색상명만 쓰면 FAIL)

## 필수 출력 형식 (3개 테이블 + 1트리 + 1가이드)

### 1. 컴포넌트 분해 테이블
| # | 컴포넌트명 | 타입 | 반복 | Z순서 | 크기 (비율) | 색상 (Hex) | 텍스트 | 구현 노트 |

> 타입: Background, Container, Button, Text, Icon, Image, Divider, Overlay, Effect, ScrollView
> 겹치는 요소도 각각 분리. Z순서로 레이어 표기.

### 2. 컬러 팔레트 (최소 3색)
| # | 용도 | Hex | 사용 컴포넌트 | 토큰명 |

> 토큰명: --color-{용도}, --space-{크기}, --font-{레벨} 패턴

### 3. Prefab 계층 트리
Canvas (Screen Space - Overlay)
├── [컴포넌트] ([타입]) — [색상], [Anchor]
└── ...

> 컴포넌트 분해 테이블의 모든 요소가 트리에 포함되어야 함

### 4. 구현 가이드
- Canvas 설정 추정
- 주요 Anchor/Layout 추정
- 주의사항 (추정값에 (추정) 태그)
```

---

**분석 유형별 프롬프트** (위 공통 블록 + 아래 유형별 지시):

**UI 레이아웃 분석 (기본)** — 플랫폼별 분기:

Game (Unity):
```
다음 스크린샷의 UI를 개별 컴포넌트로 분해해주세요.

{공통 분해 규칙 블록}

+ Unity UGUI 구현 방법(Canvas 설정, Layout Group, Anchor)을 구현 가이드에 포함해주세요.
```

Web (HTML/CSS):
```
다음 스크린샷의 UI를 개별 컴포넌트로 분해해주세요.

{공통 분해 규칙 블록}

+ 구현 가이드에 아래를 포함해주세요:
  - HTML 시맨틱 태그 구조 (header, nav, main, section, aside, footer)
  - CSS 레이아웃 방식 (Flexbox/Grid 추천)
  - 반응형 breakpoint 추정 (mobile/tablet/desktop)
  - Tailwind CSS 유틸리티 클래스 제안
  - React 컴포넌트 분리 제안
```

App (Mobile Native):
```
다음 스크린샷의 UI를 개별 컴포넌트로 분해해주세요.

{공통 분해 규칙 블록}

+ 구현 가이드에 아래를 포함해주세요:
  - 네비게이션 패턴 (Tab Bar, Drawer, Stack)
  - Safe Area / Status Bar 처리
  - 터치 타겟 크기 (최소 44pt)
  - 플랫폼 디자인 가이드라인 준수 여부 (HIG/Material)
```

**HUD 분석**:
```
다음 게임 스크린샷에서 HUD(Head-Up Display) 요소를 분석해주세요.

{공통 분해 규칙 블록}

추가 요구:
- 각 HUD 요소의 Safe Area 기준 위치
- 가독성 평가 (대비 비율, 폰트 크기 추정)
- Unity Canvas Scaler 설정과 Anchor Preset 제안
```

**아이콘/에셋 분석**:
```
다음 스크린샷에서 아이콘과 시각 에셋을 분석해주세요.

{공통 분해 규칙 블록}

추가 요구:
- 아이콘 스타일(플랫/스큐어모픽/아웃라인)
- 크기 규격(px 추정)
- 아트 디렉션 키워드
- Sprite Atlas 구성 제안
```

**이펙트 프레임 분석**:
```
다음 스크린샷에서 시각 이펙트(파티클, 글로우, 블러 등)를 분석해주세요.

{공통 분해 규칙 블록}

추가 요구:
- 이펙트 방향, 블렌딩 모드(추정), 강도
- Unity Particle System 또는 Shader Graph 재현 방법
```

**경쟁작 비교**:
```
다음 스크린샷들을 비교 분석해주세요.

{공통 분해 규칙 블록}

추가 요구:
- 레이아웃 구조, 정보 배치, 컬러 사용, UX 패턴의 차이점과 공통점
- 각 접근법의 장단점 평가
```

**구현 검증**:
```
다음 두 스크린샷을 비교해주세요.
첫 번째는 레퍼런스(목표), 두 번째는 실제 구현 결과입니다.

비교 항목:
1. 레이아웃 일치도 (위치, 크기, 비율)
2. 컬러/스타일 일치도
3. 누락된 요소
4. 추가된 요소 (의도적 변경인지 누락인지)
5. 전체 완성도 점수 (1-10)
6. 개선 필요 항목

출력 형식:
| 항목 | 레퍼런스 | 구현 | 일치도 | 비고 |
```

**컴포넌트 추출 모드 전용 — bbox JSON 추가 지시 블록** (`--extract` 시 공통 분해 규칙 블록 뒤에 추가):

```
## 컴포넌트 추출 JSON (필수)

분석 결과 마지막에 아래 형식의 JSON 코드블록을 반드시 포함하라.

규칙:
1. bbox는 이미지 전체 크기 대비 정규화 좌표 (0.0~1.0)
2. bbox는 반드시 컴포넌트를 완전히 포함해야 한다 — 엣지 클리핑(잘림) 절대 금지
3. 인접한 다른 컴포넌트 영역을 침범하지 않는다 (형제 컴포넌트 겹침 최소화)
4. Background 타입은 반드시 {"x":0,"y":0,"w":1.0,"h":1.0}
5. id는 타입 접두어 사용: bg_*, btn_*, icon_*, overlay_*, text_*, img_*
6. 최대 50개 고유 컴포넌트

```json
{
  "components": [
    {
      "id": "bg_main",
      "name": "메인 배경",
      "type": "Background",
      "bbox": {"x": 0.0, "y": 0.0, "w": 1.0, "h": 1.0},
      "z_order": 0
    },
    {
      "id": "btn_attack",
      "name": "공격 버튼",
      "type": "Button",
      "bbox": {"x": 0.72, "y": 0.80, "w": 0.20, "h": 0.08},
      "z_order": 3
    },
    {
      "id": "icon_hp",
      "name": "HP 아이콘",
      "type": "Icon",
      "bbox": {"x": 0.05, "y": 0.04, "w": 0.06, "h": 0.06},
      "z_order": 2
    }
  ]
}
```
```

**컴포넌트 추출 모드 — Agent Teams 실행 구조**:

```
[오케스트레이터 — Sonnet]

Pass 1 (병렬):
  ├─ [Analyzer Agent × N] (gemini-3.1-pro-preview)
  │    → 이미지 N장 동시 분석, 각각 초안 bbox JSON 생성
  └─ [OverlapDetector] (내부 처리)
       → bbox 취합 후 형제 IoU 사전 검사

Pass 2 — 정밀 검증 (병렬, CRITICAL):
  └─ [Verifier Agent × M] (gemini-3.1-pro-preview)
       → 각 초안 bbox 크롭을 Gemini 재전송
       → 질문: "이 컴포넌트가 완전히 포함됐는가? 잘린 부분이 있는가?"
       → 잘림 감지 시: 확장 방향(상/하/좌/우) + 확장량(px) 반환 → bbox 보정

병렬 실행:
  ├─ [Extractor Agent] (Sonnet) → 보정 bbox → extract-components.py 실행
  └─ [Evaluator Agent] (내부)  → 루브릭 5항목 자기평가
```

### Step 3: 분석 실행

`analyze-screenshot.sh`를 호출하여 Gemini Vision API 분석을 실행한다.

**단일 이미지 분석:**
```bash
bash ~/.claude/scripts/analyze-screenshot.sh \
  "{IMAGE_PATH}" \
  "docs/assets/screenshot-refs/{YYYY-MM-DD}-{REF_NAME}-analysis.md" \
  "{Step 2에서 조립한 전체 프롬프트 — 공통 블록 포함}"
```

**멀티 이미지 비교 분석** (경쟁작 비교, 구현 검증):
```bash
bash ~/.claude/scripts/analyze-screenshot.sh \
  "{IMAGE1_PATH}" \
  "docs/assets/screenshot-refs/{YYYY-MM-DD}-{REF_NAME}-compare.md" \
  "{비교 분석 프롬프트}" \
  "{IMAGE2_PATH}" \
  "{IMAGE3_PATH}"  # 선택
```

> 멀티 이미지: 2-3장을 한 번의 API 호출로 Gemini에 전송하여 직접 비교.
> 기존 순차 분석 → 텍스트 비교 대비 정확도와 일관성 향상.

**모델 선택** (환경변수 `GEMINI_MODEL`):
```bash
# 기본: gemini-2.5-flash (빠르고 저렴)
# 고품질: gemini-2.5-pro (정밀 분해, 복잡한 UI)
GEMINI_MODEL=gemini-2.5-pro bash ~/.claude/scripts/analyze-screenshot.sh ...
```

### Step 3.5: 컴포넌트 추출 실행 (--extract 모드 전용)

Pass 1 분석 완료 후, Pass 2 Verifier와 Extractor를 Agent Teams로 병렬 실행한다.

**Pass 2 — Verifier (각 컴포넌트 병렬, gemini-3.1-pro-preview)**:

각 컴포넌트 bbox로 원본 이미지를 임시 크롭 → Gemini 재전송:
```bash
# 임시 크롭 생성
python3 -c "
from PIL import Image
img = Image.open('{IMAGE_PATH}')
w,h = img.size
bbox = {bbox_dict}
left = int(bbox['x']*w); top = int(bbox['y']*h)
right = int((bbox['x']+bbox['w'])*w); bottom = int((bbox['y']+bbox['h'])*h)
img.crop((left,top,right,bottom)).save('/tmp/verify_{comp_id}.png')
"

# Gemini 재확인
GEMINI_MODEL=gemini-3.1-pro-preview bash ~/.claude/scripts/analyze-screenshot.sh \
  "/tmp/verify_{comp_id}.png" \
  "" \
  "이 이미지에서 '{comp_name}'({comp_type}) 컴포넌트가 완전히 포함되어 있는가?
   잘린 부분(엣지 클리핑)이 있으면 JSON으로 응답:
   {\"clipped\": true, \"expand\": {\"top\": 0, \"bottom\": 0, \"left\": 0, \"right\": 0}}
   잘림 없으면: {\"clipped\": false}"
```

잘림 감지 시 bbox를 expand 값만큼 원본 이미지 기준으로 보정 후 재크롭.

**Extractor (Verifier 완료 후 즉시, Sonnet)**:

```bash
GEMINI_MODEL=gemini-3.1-pro-preview \
python3 ~/.claude/scripts/extract-components.py \
  --image "{IMAGE_PATH}" \
  --analysis "{ANALYSIS_MD_PATH}" \
  --output "docs/assets/screenshot-refs/{YYYY-MM-DD}-{REF_NAME}-components"
```

**Kill Conditions**:
- bbox JSON 미포함 → 재프롬프트 1회 → 실패 시 텍스트 분석만 반환 (폴백)
- Gemini API 오류 → 즉시 폴백, 오류 메시지 출력
- 이미지 20MB 초과 → 추출 모드 차단
- 크롭 결과 0개 → 오류 + 안내

**Canary**:
```
🟢 Green  = 루브릭 5항목 PASS (커버리지≥60% / 컴포넌트 2~50 / 크기≥16px / 파일정상 / 중복없음)
🟡 Yellow = 1~2항목 WARN
🔴 Red    = bbox JSON 없음 OR 추출 0개
```

### Step 4: 결과 검증 + 출력

Gemini 응답에서 아래 5개 필수 요소를 검증한다. **하나라도 누락되면 해당 섹션을 AI가 직접 보완**한다.

| # | 필수 요소 | 검증 기준 |
|---|---------|----------|
| 1 | 컴포넌트 분해 테이블 | 마크다운 테이블, 최소 5행 |
| 2 | 컬러 팔레트 | #RRGGBB Hex 최소 3색 |
| 3 | Prefab 계층 트리 | 트리 구조 코드 블록 |
| 4 | 구현 가이드 | Canvas/Anchor 설정 포함 |
| 5 | (추정)/(확정) 태그 | 모든 추정값에 태그 |

**--extract 모드 추가 검증 (루브릭 5항목)**:

| # | 항목 | PASS 기준 | FAIL 시 |
|---|------|----------|--------|
| 1 | bbox JSON | ```json {"components":[...]} ``` 블록 존재 | 재프롬프트 1회 → 없으면 폴백 |
| 2 | bbox 커버리지 | 컴포넌트 면적 합계 ≥ 화면 60% | 누락 컴포넌트 경고 |
| 3 | 컴포넌트 수 | 2 ≤ N ≤ 50 | 0~1: 재시도 / 51+: 상위 50개 |
| 4 | 파일 생성 | 추출 PNG 정상 저장 | 실패 목록 출력 |
| 5 | 겹침 상태 | _overlap-report.json GREEN | YELLOW/RED 경고 출력 |

#### 출력 모드별 포맷

**기본 모드**: 위 5개 요소를 순서대로 출력

**시안 분석 모드** (`--mockup`): 모든 값을 `(확정)` 태그로 추출

추가 출력:

##### Section 16-1 — 시안 바인딩 테이블

| 시안 경로 | 시안 내 요소 | 매핑 대상 섹션 | 매핑 파라미터 | 확정값 |
|----------|-----------|-------------|-----------|:-----:|

##### Section 10 — 디자인 토큰 바인딩 (확정)

| 요소 | 토큰명 | 값 | 출처 |
|------|--------|-----|------|

> 토큰명: 프로젝트 `style-guide.md` 기존 토큰 매칭 우선. 없으면 `--color-{용도}` 패턴.

##### Section 7 — Prefab 계층 구조 (확정)

트리 구조 + 컴포넌트 테이블 (기본 모드와 동일 형식, 값은 `(확정)`)

---

**Task Doc 모드**: Element Task Doc 섹션 형식으로 직접 출력 (경쟁작/참고 자료 — 추정값):

##### Section 7 — Prefab 계층 구조

> UI 프레임워크: [분석에서 감지된 프레임워크, 예: uGUI / NGUI]

```
Canvas (Screen Space - Overlay)
├── [관찰된 영역 A] (RectTransform) — [위치 설명]
│   ├── [자식 요소] ([컴포넌트 추정]) — [역할]
│   └── ...
```

| 오브젝트 | 컴포넌트 (추정) | 역할 | Anchor 추정 | Pivot 추정 | 비고 |
|---------|---------------|------|-----------|----------|------|

##### Section 10 — 디자인 토큰 바인딩

| 요소 | 토큰명 | 값 | 출처 |
|------|--------|-----|------|

> 토큰명: `--color-{용도}`, `--space-{크기}`, `--font-{레벨}` 패턴.

##### Section 16 — 레퍼런스 바인딩

| 레퍼런스 유형 | 원본 경로 | 참고 구간 | 적용 대상 | 분석 결과 요약 |
|-------------|----------|----------|----------|-------------|

---

### Step 5: 저장 + 후속

1. 구조화된 분석 결과를 사용자에게 출력
2. `docs/assets/screenshot-refs/`에 분석 파일 저장
3. **--extract 모드**: 추출 결과를 아래 경로에 저장
   ```
   docs/assets/screenshot-refs/{YYYY-MM-DD}-{REF_NAME}-components/
   ├── _manifest.json         ← 컴포넌트 메타데이터 + 픽셀 bbox
   ├── _overlap-report.json   ← IoU 겹침 경고 + 상태(GREEN/YELLOW/RED)
   ├── backgrounds/           bg_*.png
   ├── buttons/               btn_*.png
   ├── icons/                 icon_*.png
   ├── overlays/              overlay_*.png
   ├── text/                  text_*.png
   ├── images/                img_*.png
   ├── containers/            container_*.png
   └── etc/                   기타
   ```
4. GDD/Spec 작성 중이면 해당 섹션에 삽입 안내
5. **--extract 모드 후속**: `_manifest.json` 경로를 `game-asset-generate` 스킬에 전달 가능
   (추출된 컴포넌트를 에셋 생성 레퍼런스로 바로 활용)

## Trine 연동

| Phase | 사용 시점 | 행동 |
|-------|----------|------|
| **S3 (GDD)** | 6.3 UI/UX 가이드, 3.3 화면 상세 | 경쟁작 UI 비교 분석 |
| **S4 (UI/UX 기획서)** | 와이어프레임 + 레퍼런스 | 레퍼런스 분석 → 기획서에 삽입 |
| **Trine Phase 2 (Spec)** | Section 9.5 UI 상태 | 목업/스크린샷 기반 UI 구조 정의 |
| **Phase 2 (Element Task Doc)** | Complex UI 요소 상세 명세 시 | 스크린샷 분석 (Task Doc 모드) → Section 7 + 10 + 16 직접 출력 |
| **Trine Phase 3 (구현)** | 구현 시 레퍼런스 참조 | 분석 파일 재참조 |
| **Trine Phase 3 (역비교)** | 구현 완료 후 Check 3 PASS 후 | 구현 스크린샷 vs 레퍼런스 비교 (구현 검증 모드) |

## AI 행동 규칙

1. 이미지 분석 요청 시 Element Task Doc 작성 컨텍스트인지 먼저 판단한다
2. **Element Task Doc 작성 컨텍스트에서 호출되면 Task Doc 모드를 자동 적용한다**
3. 기본/Task Doc/시안/구현검증 모드 선택을 사용자에게 묻지 않는다 — 컨텍스트로 자동 판단한다
4. 분석 전 "X 분석 → [모드] 모드로 실행합니다" 한 줄 선언 후 실행한다
5. **Gemini 응답에 필수 요소가 누락되면 AI가 직접 보완한다** — 누락 상태로 출력 금지

## 스타일 추출 모드 (P0)

`/style-train` 스킬에서 호출되는 전용 모드. 5-10개 기존 에셋에서 공통 시각 패턴을 추출한다.

**분석 항목:**
- 컬러 팔레트 (Primary/Secondary/Accent/Background)
- 아트 스타일 키워드 (flat/minimal/painted 등)
- 일관성 패턴 (테두리, 여백, 그림자, 텍스처)
- 타이포그래피 추정 (폰트 스타일/크기)

**출력**: `style-guide-template.md` 형식에 맞춘 초안

## 일관성 검증 모드 (P4)

에셋 5개 이상이 생성된 후, 전체를 컴포지트 이미지로 배치하여 "같은 프로젝트의 에셋으로 보이는가?"를 검증한다.

**검증 항목:**
1. 컬러 팔레트 일관성
2. 아트 스타일 일관성 (선/채색/텍스처)
3. 비율/크기 규격 준수
4. 조명 방향 통일

**출력**: 일관성 점수 (High/Medium/Low) + 불일치 에셋 목록

## AI 크리틱 모드

에셋 생성 후 4항목 자동 검증:

1. **계층 (Hierarchy)**: 시각적 중요도 순서가 명확한가?
2. **일관성 (Consistency)**: style-guide.md 키워드/규격과 일치하는가?
3. **안티패턴 (Anti-pattern)**: `ai-anti-patterns.md` 항목에 해당하지 않는가?
4. **브리프 부합 (Brief Compliance)**: art-direction-brief.md와 일치하는가?

## 환경 요구사항

- `GEMINI_API_KEY` 환경변수 설정 필수
- `~/.claude/scripts/analyze-screenshot.sh` 스크립트 존재
- Python 3 (JSON 파싱용)
- curl (API 호출용)

## 주의사항

- 이미지 분석은 Gemini API 크레딧을 소비한다 — 불필요한 반복 분석 방지
- 캐싱: output-file이 이미 존재하면 API를 호출하지 않는다
- 이미지 크기 제한: 20MB 이하
- 비교 분석 시 멀티 이미지 모드(2-3장 동시 전송)를 우선 사용, 4장 이상은 순차 분석

## 보안 주의사항

이 스킬은 이미지 전체를 base64로 인코딩하여 **Google Gemini API로 전송**한다.
아래 유형의 이미지는 전송 전 확인이 필요하다:

| 주의 대상 | 이유 | 대안 |
|----------|------|------|
| 미공개 게임/앱 기능 스크린샷 | 사전 공개 위험 | 출시 후 또는 공개 베타 버전만 사용 |
| 경쟁사 NDA 적용 베타 화면 | 제3자 정보 무단 전송 | 공식 스토어/사이트 스크린샷만 사용 |
| PII가 포함된 화면 | 개인정보 유출 | 캡처 전 민감 정보 마스킹 처리 |

**권장**: 경쟁사 분석에는 App Store, Google Play, 공식 웹사이트의 **공개 스크린샷**만 활용한다.
