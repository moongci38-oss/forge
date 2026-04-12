---
name: asset-extract
description: |
  게임/앱 UI 스크린샷에서 배경·버튼·컴포넌트를 게임 사용 가능한 투명 PNG로 추출.
  배경은 nanobanana edit_image(AI inpainting), 버튼/컴포넌트는 /clip 템플릿 매칭으로
  bbox를 찾고 SAM2로 pixel-accurate 세그멘테이션하여 투명 배경 PNG로 추출.
  트리거: 배경 뽑아줘, 버튼 추출해줘, 컴포넌트 분리해줘, 전부 다 추출해줘, 이미지 경로와 함께 추출 요청 시.
---

# Asset Extract

스크린샷에서 게임에 바로 사용 가능한 에셋 PNG를 추출한다.

## 도구 분담

| 대상 | 도구 | 결과 |
|------|------|------|
| 배경 | `mcp__nano-banana__edit_image` (inpainting) | UI 제거 후 자연스러운 배경 PNG |
| 버튼/컴포넌트 | /clip 템플릿 매칭 → SAM2 세그멘테이션 | 투명 배경 PNG (pixel-accurate) |

**버튼 추출에 nanobanana 사용 금지** — AI가 색상/형태를 재생성하여 원본과 달라짐.

## 의존성

- `pip install rembg` (SAM 모델 내장)
- 첫 실행 시 SAM ONNX 모델 자동 다운로드 (~375MB, ~/.u2net/)

## Step 1: 입력 파싱

```
IMAGE_PATH  : 이미지 절대 경로
TARGET      : 배경 | 버튼 | 전체 (기본: 전체)
OUTPUT_DIR  : {IMAGE_PATH 부모}/{파일명}-components/ (기본)
```

**Windows 경로 자동 변환**:
- `z:/home/damools/...` → `/home/damools/...`
- `C:/Users/...` → `/mnt/c/Users/...`

## Step 2: 버튼/컴포넌트 추출

### 2-1. /clip으로 추출 대상 받기

사용자에게 안내:
> "추출할 요소를 화면에서 스크린샷 찍어 `/clip`으로 올려주세요."

사용자가 /clip 실행하면 → `/tmp/clip.png` 저장됨.

### 2-2. 템플릿 매칭으로 bbox 자동 탐지

```bash
python3 ~/.claude/skills/asset-extract/scripts/match_bbox.py \
  --original "{IMAGE_PATH}" \
  --clip /tmp/clip.png
```

출력:
```
left,top,right,bottom
score:{SAD점수}
```

score > 20 이면 매칭 품질 경고 → 사용자에게 안내 후 계속 진행.

**bbox 확장**: match_bbox 결과에 상하좌우 10px씩 여유 추가 (SAM2가 전체 오브젝트를 포착하도록).

### 2-3. SAM2 세그멘테이션 → 투명 PNG

```bash
python3 ~/.claude/skills/asset-extract/scripts/segment_button.py \
  --image "{IMAGE_PATH}" \
  --bbox {left} {top} {right} {bottom} \
  --output "{OUTPUT_DIR}/buttons/{name}.png"
```

- 2x 업스케일 → rembg SAM 배경 제거 → 다각형 피팅 (직선 엣지)
- SAM 마스크 컨투어를 4점 사다리꼴로 단순화 → 좌우 대각선 완벽 직선
- 하단은 SAM 바닥 + 8px 연장 (다크 베이스 포함, 게임 배경 제외)
- 0.7px 안티앨리어싱으로 부드러운 테두리
- 결과 Read로 시각 확인

## Step 3: 배경 추출 (TARGET = 배경 | 전체)

```
imagePath : {IMAGE_PATH}
prompt    : "Remove all UI elements, buttons, cards, text, icons, and navigation
             bars from this screenshot. Keep only the background. Fill removed
             areas with the natural background color/gradient.
             Result: clean background with no UI elements."
aspectRatio: 원본 비율에 맞게 선택
resolution : 2K
```

결과를 `{OUTPUT_DIR}/backgrounds/bg_nano.png`로 복사.

## Step 4: 결과 출력

```
✅ 추출 완료
📁 {OUTPUT_DIR}

배경: backgrounds/bg_nano.png
버튼: {N}개 (투명 PNG — 게임 합성 가능)
  - buttons/{name}.png  ({w}×{h}px, IoU: {score})
```

## Kill Conditions

- 이미지 없음 → 즉시 오류
- /tmp/clip.png 없음 → "/clip으로 스크린샷을 올려주세요" 안내
- score > 20 → 매칭 품질 낮음 경고, 크롭 결과 확인 요청
- SAM2 IoU < 0.8 → 세그멘테이션 품질 경고, bbox 재조정 시도
- SAM2 미설치 → 설치 안내 출력
