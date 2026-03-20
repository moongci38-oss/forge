---
name: game-asset-generate
description: 게임 에셋(스프라이트, VFX, 배경, 3D, UI, 아이콘, 오디오)을 대량 생산하는 오케스트레이터. Library-First 탐색으로 MCP 비용을 절감하고, 12요소 Soul 프롬프트와 모델 어댑터(FLUX/Gemini/Replicate)로 품질을 극대화한다. style-guide.md가 준비된 후 게임 에셋 생성 시 사용. 리소스 파이프라인 P3 단계.
user-invocable: true
---

# Game Asset Generate

게임 에셋 대량 생산 오케스트레이터. Library-First 탐색으로 비용을 절감하고, 12요소 Soul-Injected 프롬프트로 품질을 극대화한다.

## 전제조건

1. `style-guide.md` 존재 필수 (없으면 `/style-train` 먼저 실행)
2. `art-direction-brief.md` 존재 권장 (없으면 경고 후 진행)
3. 관련 MCP 서버 연결 확인
4. `prompt-log.md` 존재 권장 (없으면 자동 생성)

## 에셋 유형별 라우팅

| 에셋 유형 | 1차 도구 | 폴백 | 비고 |
|---------|---------|------|------|
| 스프라이트 시트 | Ludo.ai MCP | NanoBanana + 수동 슬라이싱 | 캐릭터 애니메이션 |
| VFX 이펙트 시트 | Ludo.ai MCP | NanoBanana | 파티클, 이펙트 |
| 2D 배경/타일 | Replicate (LoRA) | NanoBanana MCP | 배경, 지형 |
| 3D 모델 (OBJ/GLB) | Ludo.ai MCP | Asset Store 구매 | 3D 오브젝트 |
| UI 요소 | Ludo.ai MCP | NanoBanana | 버튼, 프레임, 게이지 |
| 아이콘 세트 | Replicate / Ludo.ai | NanoBanana | 스킬, 아이템 아이콘 |
| 오디오/SFX | Ludo.ai MCP | — | BGM, 효과음 |

## 워크플로우 (12단계)

```
 1. style-guide.md 로드
    → 키워드, 팔레트, 모델별 어댑터(§6.1), 기술 규격(§9) 추출
    → 검증된 시드 레지스트리(§7.2) 로드

 2. art-direction-brief.md 로드
    → 디자인 철학 선언문(§5.5) 추출 → target_emotion, light_dark_principle
    → 감성→키워드 매핑(§1) 추출
    → 앵커 이미지 경로(§3) 추출
    → 의도적 긴장 규칙(§8) 로드

 3. 에셋 유형 판별
    → 라우팅 테이블에서 1차 도구 선택
    → 에셋 Tier 판별: T1(핵심)/T2(주요)/T3(대량)

 4. Library 탐색 (Library-First)
    → Prefab Library _metadata.json 로드 (경로: 환경변수 PREFAB_LIBRARY_PATH)
    → 요청 키워드 ↔ tags/style_tags 매칭
    → 분기:
      ├─ 완전 매칭 (quality_score 4.0+)
      │   → "Library에 [에셋명] 있습니다. 직접 사용할까요?" → Human 확인
      │   → 사용 → usage_count++ → Step 11로 (MCP 0회)
      ├─ 부분 매칭 (유사 에셋 존재)
      │   → "유사 에셋 [에셋명]을 base로 리터치할까요?" → Human 확인
      │   → edit_image로 변형 → Step 10으로
      └─ 매칭 없음 → Step 5로 (신규 생성)

 5. 모델 어댑터 선택
    → style-guide.md §6.1 모델별 어댑터 참조
    → 에셋 유형 + 씬 성격에 따라 분기:
      ├─ 감성/이펙트 → Gemini (NanoBanana)
      ├─ UI 레이아웃/구도 정확 → FLUX (Replicate)
      └─ LoRA 학습 완료 시 → Replicate LoRA

 6. 12요소 Soul 프롬프트 조립
    → Tier에 따라 깊이 차등:
      T1 = 12요소 풀 Soul (250-350 토큰)
      T2 = 8요소 + 선택 Soul (120-200 토큰)
      T3 = 최소 키워드 (30-80 토큰)

    12요소 슬롯:
    [1. 철학 메타]    → brief §5.5 디자인 철학에서 추출
    [2. 순간/서사]    → "the instant {moment}" 서사 키워드
    [3. 주체]         → 에셋 설명 + 물성 키워드
    [4. 구도/카메라]   → style-guide §8 카메라 사전 참조 + 긴장(비대칭)
    [5. 환경]         → 환경 키워드 + 텍스처
    [6. 색상(HEX)]    → 팔레트 HEX 직접 지정 + 긴장 악센트
    [7. 이펙트]       → 파티클/글로우 + 유기적 리듬
    [8. 감성 텍스처]   → brief 물성 키워드 사전 참조
    [9. 의도적 긴장]   → brief §8 긴장 규칙에서 1-2개 선택
    [10. 스타일]      → art style 키워드 + anti-AI미학
    [11. 기술 규격]    → style-guide §9 에셋 규격 참조
    [12. 제외]        → 안티패턴 금지 키워드 + Soul 안티 제외

    → 골든 레시피 확인: prompt-log.md에 동일 유형 성공 레시피 있으면 우선 참조

 7. 모델 어댑터 적용
    → Step 5에서 선택한 모델에 맞게 프롬프트 포맷 변환:
      ├─ FLUX: T5 서술형 문장 + CLIP 키워드 리스트. "prominently featuring" 강조
      ├─ Gemini: 메타 지시 → 상세 서술 단락. 앵커 이미지 첨부 (§3)
      └─ Replicate: {trigger_word} + 스타일 키워드 (150토큰 이내)

 8. MCP 도구 호출 → 에셋 생성
    → 생성 실패 시 → 폴백 도구로 자동 전환 + Human 알림
    → 다중 생성: 같은 프롬프트로 3장 생성 (T1/T2 에셋)

 9. 크리틱 6항목 자동 평가
    → ai-anti-patterns.md 크리틱 체크리스트 참조
    → 6항목: 계층/일관성/안티패턴/브리프/서사/물성
    → PASS: 평균 3.5+ & 항목5,6 각 3.0+
    → FAIL: §10 반복 개선 프로토콜 적용 (최대 3회 자동)

10. Human 확인 대기 (1장씩 순차)
    → 승인 (✅) → Step 11
    → 거부 (❌) → 실패 원인 분류 → prompt-log 기록 → Step 6 재시도

11. 승인 후 기록
    → resource-manifest.md 업데이트 (프롬프트 전문 + 시드 + 크리틱 점수)
    → prompt-log.md 기록 (Flywheel 루프 1: 성공 경험 축적)
    → Library 등록 후보 평가 (quality_score 4.0+ → 자동 등록 제안)
    → 앵커 이미지 후보 등록 (크리틱 평균 4.5+ → brief 앵커 후보)

12. 일관성 검증
    → 5개+ 누적 시 → 크로스 에셋 일관성 검증 제안
    → /screenshot-analyze 일관성 검증 모드 호출
```

## Flywheel 자동 행동

| 이벤트 | 자동 행동 |
|--------|----------|
| 에셋 ✅ 승인 | prompt-log 기록, 시드 레지스트리 갱신, 앵커 이미지 후보 등록 |
| 에셋 ❌ 거부 | 실패 원인 분류(구도/색상/스타일/디테일/안티패턴), 블랙리스트 갱신 |
| 동일 유형 성공 3건+ | 골든 레시피 자동 생성 제안 |
| 승인 에셋 20장+ | LoRA 학습 트리거 제안 (Human 승인 필요) |

## 입력

- **에셋 유형**: sprite / vfx / background / 3d / ui / icon / audio
- **설명**: 에셋 설명 (프롬프트에 포함)
- **수량**: 생성할 에셋 수 (순차 생성)
- **크기** (선택): 타겟 해상도 (미지정 시 style-guide §9 기본값)
- **Tier** (선택): T1(핵심) / T2(주요) / T3(대량) — 미지정 시 자동 판별

## 출력

- 생성된 에셋 파일 (프로젝트 에셋 경로에 저장)
- resource-manifest.md 업데이트 (프롬프트 전문 + 시드 + 크리틱 점수)
- prompt-log.md 업데이트 (성공/실패 기록)

## Diamond Architecture 단계

이 스킬은 리소스 파이프라인의 **P3 (대량 생산)** 단계를 담당한다.

```
P0 (/style-train) → P1 (Brief) → P2 (프로토타입) → P3 (/game-asset-generate) → P4 (검증)
```

## 주의사항

- **1장씩 순차 생성** — 병렬 생성 금지 (Human 피드백 루프)
- MCP 도구별 API 키 필요 (Replicate, Ludo.ai 등)
- 3D 모델 생성은 실험적 — 품질 불안정 시 Asset Store 구매 권장
- Git LFS 정책 준수: 10MB+ 파일은 LFS 트래킹 필수
- Library 탐색 실패(PREFAB_LIBRARY_PATH 미설정) 시 Step 4 스킵 → Step 5로
- 프롬프트 조립 시 골든 레시피가 있으면 반드시 참조 (재현성 확보)
