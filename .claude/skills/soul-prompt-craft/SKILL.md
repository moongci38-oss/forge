---
name: soul-prompt-craft
description: 12요소 Soul-Injected 이미지 생성 프롬프트를 조립하고 모델별 최적 포맷(FLUX/Gemini/Replicate)으로 변환한다. style-guide.md와 art-direction-brief.md에서 컨텍스트를 자동 추출하며, Tier(T1/T2/T3)에 따라 프롬프트 깊이를 차등 적용. /game-asset-generate 실행 전 고품질 프롬프트가 필요하거나, 프롬프트를 수동 미세조정할 때 사용.
user-invocable: true
context: fork
model: sonnet
---

# Soul Prompt Craft — 12요소 프롬프트 조립기

style-guide.md와 art-direction-brief.md에서 프로젝트 컨텍스트를 자동 추출하고, 12요소 Soul-Injected 프롬프트를 조립하여 모델별 최적 포맷으로 변환한다.

## 언제 사용하는가

- 이미지 생성 전 고품질 프롬프트가 필요할 때
- `/game-asset-generate`의 Step 6-7을 독립적으로 실행하고 싶을 때
- 프롬프트를 수동으로 미세 조정하고 싶을 때
- 프롬프트를 비교/검토한 후 직접 MCP 도구에 전달하고 싶을 때

## 전제조건

1. `style-guide.md` 존재 필수 (§6 모델별 어댑터, §8 카메라 사전, §9 에셋 규격)
2. `art-direction-brief.md` 존재 권장 (§5.5 디자인 철학, §8 의도적 긴장)
3. `prompt-log.md` 존재 권장 (골든 레시피 참조)

## 입력

- **에셋 설명**: 무엇을 생성할 것인가 (자연어)
- **에셋 유형**: sprite / vfx / background / ui / icon / hero / og / illustration
- **Tier**: T1(핵심) / T2(주요) / T3(대량) — 프롬프트 깊이 결정
- **모델** (선택): FLUX / Gemini / Replicate — 미지정 시 에셋 유형에 따라 자동 선택
- **순간/서사** (선택): 어떤 순간을 포착할 것인가

## 12요소 슬롯 구조

```
[1. 철학 메타]       ← art-direction-brief §5.5 디자인 철학에서 추출
                      "An image evoking {target_emotion} — {light_dark_principle}."

[2. 순간/서사]       ← Human 제공 또는 자동 생성
                      "{narrative_moment} — {physical_reaction}, {reveal_state}."

[3. 주체]            ← 에셋 설명 + 물성 키워드
                      "{subject} with {physicality_details}"

[4. 구도/카메라]      ← style-guide §8 카메라 사전 + 긴장 기법
                      "{camera_angle}, {composition_with_tension}"

[5. 환경]            ← style-guide §2 환경 키워드 + 텍스처
                      "{environment} with {texture_details}"

[6. 색상(HEX)]       ← 토큰 소스 우선순위:
                      1순위: Element Task Doc Section 10 (요소별 토큰) — 있으면 최우선
                      2순위: style-guide §1 팔레트 — 기본
                      3순위: instagram-default.json — 둘 다 없을 때 fallback
                      "dominant {palette_dominant} with {palette_accent},
                       {tension_color_accent}"

                      ★ Hex Code 강제 규칙 (MUST):
                      - 모든 색상은 반드시 #RRGGBB Hex Code로 명시
                      - 자연어 색상명 단독 사용 금지 ("파란색" ✗ → "#0095F6" ✓)
                      - 자연어 레이블은 Hex 뒤 괄호로만 허용: "#FFD700 (gold)"

[7. 이펙트]          ← style-guide §2 이펙트 키워드
                      "{effects} with organic rhythm, {particles}"

[8. 감성 텍스처]      ← art-direction-brief 물성 키워드 사전
                      "{physicality_keywords}"

[9. 의도적 긴장]      ← art-direction-brief §8 긴장 규칙에서 1-2개
                      "{intentional_imperfection}"

[10. 스타일]         ← style-guide §2 아트 스타일 + anti-AI미학
                      "{art_style}, painterly quality,
                       NOT photorealistic, NOT smooth plastic"

[11. 기술 규격]       ← style-guide §9 에셋 규격
                      "{resolution}, {aspect_ratio}, {format}"

[12. 제외]           ← ai-anti-patterns.md + style-guide 금지 키워드
                      "no perfect symmetry, no clean surfaces,
                       {project_exclusions}, no text"
```

## Tier별 깊이 차등

| Tier | 사용 슬롯 | Soul Layer | 토큰 범위 | 대상 |
|:----:|:--------:|:----------:|:--------:|------|
| **T1** | 12요소 전체 | 4/4 (철학+서사+텍스처+긴장) | 250-350 | 히어로, 메인 씬, 브랜딩 |
| **T2** | 슬롯 3-7,10-12 + 선택(8,9) | 2/4 (텍스처+서사) | 120-200 | UI 컴포넌트, 배경, 이펙트 |
| **T3** | 슬롯 3,6,10,11,12 | 0/4 (base 상속) | 30-80 | 변형, 색상 교체, 리사이즈 |

## 모델별 포맷 변환

조립된 12요소를 대상 모델에 맞게 포맷 변환한다:

### FLUX 1.1 Pro
```
포맷: T5 서술형 문장 + CLIP 키워드 리스트
특성: 네거티브 프롬프트 미지원 → 자연어 강조 사용
최대 토큰: 500

변환 규칙:
- 슬롯 1-9 → 연결된 서술형 문단 (T5 인코더)
- 슬롯 10-11 → 쉼표 구분 키워드 리스트 (CLIP 인코더)
- 슬롯 12 → "prominently featuring X, absolutely no Y" 자연어 변환
- "NOT X" → "absolutely no X, without any X"
```

### Gemini (NanoBanana)
```
포맷: 메타 지시 → 상세 서술 단락
특성: 참조 이미지 지원, 다중 턴 편집

변환 규칙:
- 슬롯 1 → 첫 줄 메타 지시 ("Create an image that...")
- 슬롯 2-9 → 상세 서술 단락 (자연어 문장)
- 슬롯 10-12 → 마지막 단락 (스타일 + 규격 + 제외)
- 앵커 이미지 경로 → 프롬프트 끝에 "style matching [참조이미지]" + 이미지 첨부
```

### Replicate (LoRA)
```
포맷: 트리거워드 + 스타일 키워드
특성: 150토큰 이내 권장, 트리거워드 필수

변환 규칙:
- 트리거워드를 프롬프트 맨 앞에 배치
- 슬롯 3,6,10 핵심만 추출 (압축)
- 슬롯 12 → negative prompt 별도 필드
- 총 150토큰 이내로 압축
```

## 골든 레시피 참조

prompt-log.md에 동일 에셋 유형의 골든 레시피가 있으면:

```
1. 골든 레시피 로드
2. 레시피 base 프롬프트에서 변경 필요 부분만 식별
3. 변경분만 오버라이드 → 나머지는 레시피 그대로
4. 결과: 검증된 base + 최소 변경 = 높은 성공률
```

## 출력

조립된 프롬프트를 3가지 형태로 출력한다:

### 1. 구조화 뷰 (슬롯별 분해)
```
[철학] An image evoking ancient awe — darkness gives meaning to light.
[서사] The exact moment the seal breaks — dust rising, light escaping.
[주체] A weathered stone treasure chest with tarnished gold bindings.
...
```

### 2. 모델 최적화 뷰 (실제 MCP 전달용)
```
// Gemini 포맷
Create an image that evokes ancient awe and destiny...
(전체 연결 프롬프트)
```

### 3. 프롬프트 메타 정보
```
모델: Gemini (NanoBanana)
Tier: T1
토큰 수: ~280
골든 레시피 참조: 있음 (chest-opening recipe)
앵커 이미지: _assets/p2-01-chest-opening.png
```

## 워크플로우

```
1. 입력 분석
   → 에셋 설명, 유형, Tier 확인
   → 모델 자동 선택 (미지정 시)

2. 컨텍스트 로드
   → style-guide.md 읽기 (§1 팔레트, §2 키워드, §6 어댑터, §8 카메라, §9 규격)
   → art-direction-brief.md 읽기 (§1 감성매핑, §5.5 철학, §8 긴장)
   → prompt-log.md 읽기 (골든 레시피 확인)

3. 12요소 슬롯 채우기
   → Tier에 따라 활성 슬롯 결정
   → 각 슬롯을 프로젝트 컨텍스트로 채움
   → 골든 레시피 있으면 base로 사용

4. 모델 어댑터 적용
   → 대상 모델 포맷으로 변환

5. 프롬프트 출력
   → 구조화 뷰 + 모델 최적화 뷰 + 메타 정보
   → Human 확인 후 수정 가능

6. (선택) 직접 MCP 호출
   → Human이 "이대로 생성해" 하면 MCP 도구 직접 호출
   → 생성 결과를 /asset-critic으로 자동 평가
```

## 프롬프트 압축 기법 (토큰 절감)

| 기법 | Before | After | 절감 |
|------|--------|-------|:----:|
| 형용사 통합 | "dark and mysterious and ancient" | "ancient dark" | 40% |
| HEX 직접 지정 | "a color like tarnished old gold" | "#B8860B tarnished gold" | 60% |
| 참조 에셋 활용 | 긴 스타일 묘사 | "style matching [앵커]" + 이미지 첨부 | 70% |
| 레시피 재사용 | 매번 풀 프롬프트 | 골든 레시피 base + 변경분만 | 50% |

## 주의사항

- style-guide.md가 없으면 에러 (§6 모델 어댑터가 필수)
- art-direction-brief.md가 없으면 슬롯 1,8,9를 기본값으로 채움 (경고 출력)
- T3 Tier는 Soul 레이어 없이 최소 프롬프트만 조립
- 500토큰 초과 시 자동 압축 경고 (FLUX 한계)
- 프롬프트 전문은 prompt-log.md에 기록할 것을 권장
